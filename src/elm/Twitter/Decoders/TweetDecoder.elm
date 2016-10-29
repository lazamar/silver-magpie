module Twitter.Decoders.TweetDecoder exposing (tweetDecoder)

import Twitter.Types exposing
    ( Tweet
    , User
    , TweetEntitiesRecord
    , UserMentionsRecord
    , MediaRecord (MultiPhotoMedia, VideoMedia)
    , Video
    , MultiPhoto
    , HashtagRecord
    , UrlRecord
    )

import Twitter.Decoders.UserDecoder exposing ( userDecoder )
import Json.Decode exposing ( Decoder, string, int, bool, list, dict, at, andThen, fail, (:=) )
import Json.Decode.Pipeline exposing ( decode, required, optional, requiredAt )



-- Types



-- Raw as in not preprocessed. It is just like the server sent
type alias RawTweet =
  { user : User
  , created_at : String
  , text: String
  , retweet_count : Int
  , favorite_count : Int
  , favorited : Bool
  , retweeted : Bool
  , entities: RawTweetEntitiesRecord
  , extended_entities: ExtendedEntitiesRecord
  }



type alias RawTweetEntitiesRecord =
    { hashtags : List HashtagRecord
    , urls : List UrlRecord
    , user_mentions : List UserMentionsRecord
    , media : List RawMediaRecord
    }



type alias RawMediaRecord =
    { url : String
    , display_url : String
    , media_url_https : String
    }



-- EXTENDED RECORDS



type alias ExtendedEntitiesRecord =
    { media: List ExtendedMedia
    }



type ExtendedMedia
    = ExtendedPhotoMedia ExtendedPhoto
    | ExtendedVideoMedia ExtendedVideo



type alias ExtendedPhoto =
    { url : String -- what is in the tweet
    , display_url : String -- what should be shown in the tweet
    , media_url_https : String -- the actuall address of the content
    }



type alias ExtendedVideo =
    { url : String
    , display_url : String
    , variants : List VariantRecord
    }



type alias VariantRecord =
    { content_type: String
    , url: String
    }



-- DECODERS



tweetDecoder : Decoder Tweet
tweetDecoder =
    rawTweetDecoder
        |> Json.Decode.map preprocessTweet



rawTweetDecoder : Decoder RawTweet
rawTweetDecoder =
    decode RawTweet
        |> required "user" userDecoder
        |> required "created_at" string
        |> required "text" string
        |> required "retweet_count" int
        |> required "favorite_count" int
        |> required "favorited" bool
        |> required "retweeted" bool
        |> required "entities" rawTweetEntitiesDecoder
        |> optional "extended_entities" extendedEntitiesDecoder ( ExtendedEntitiesRecord [] )



rawTweetEntitiesDecoder : Decoder RawTweetEntitiesRecord
rawTweetEntitiesDecoder =
    decode RawTweetEntitiesRecord
        |> required "hashtags" ( list hashtagDecoder )
        |> required "urls" ( list urlDecoder )
        |> required "user_mentions" ( list userMentionsDecoder )
        |> optional "media" ( list rawMediaRecordDecoder ) []



userMentionsDecoder : Decoder UserMentionsRecord
userMentionsDecoder =
    decode UserMentionsRecord
        |> required "screen_name" string



rawMediaRecordDecoder : Decoder RawMediaRecord
rawMediaRecordDecoder =
    decode RawMediaRecord
        |> required "url" string -- this is the url contained in the tweet
        |> required "display_url" string -- this is the url contained in the tweet
        |> required "media_url_https" string



hashtagDecoder : Decoder HashtagRecord
hashtagDecoder =
    decode HashtagRecord
        |> required "text" string



urlDecoder : Decoder UrlRecord
urlDecoder =
    decode UrlRecord
        |> required "display_url" string
        |> required "url" string



extendedEntitiesDecoder : Decoder ExtendedEntitiesRecord
extendedEntitiesDecoder =
    decode ExtendedEntitiesRecord
        |> optional "media" ( list extendedMediaDecoder ) []



extendedMediaDecoder : Decoder ExtendedMedia
extendedMediaDecoder =
    ( "type" := string )
        `andThen` \mtype ->
                if mtype == "video" || mtype == "animated_gif" then
                    extendedVideoRecordDecoder
                    `andThen` \x -> decode ( ExtendedVideoMedia x )

                else if mtype == "photo" then
                    extendedPhotoRecordDecoder
                    `andThen` \x -> decode ( ExtendedPhotoMedia x )
                    -- TODO: Multi-photo parse
                else
                    -- FIXME: This mustbe an appropriate
                    -- parser for an undefined option
                    fail ( mtype ++ " is not a recognised type.")



extendedPhotoRecordDecoder : Decoder ExtendedPhoto
extendedPhotoRecordDecoder =
    decode ExtendedPhoto
        |> required "url" string
        |> required "display_url" string
        |> required "media_url_https" string



extendedVideoRecordDecoder : Decoder ExtendedVideo
extendedVideoRecordDecoder =
    decode ExtendedVideo
        |> required "url" string
        |> required "display_url" string
        |> requiredAt ["video_info", "variants"] ( list variantRecordDecoder )



variantRecordDecoder : Decoder VariantRecord
variantRecordDecoder =
    decode VariantRecord
        |> required "content_type" string
        |> required "url" string



-- PROCESSING



preprocessTweet : RawTweet -> Tweet
preprocessTweet raw =
    Tweet
        raw.user
        raw.created_at
        raw.text
        raw.retweet_count
        raw.favorite_count
        raw.favorited
        raw.retweeted
        ( TweetEntitiesRecord
            raw.entities.hashtags
            ( mergeMediaLists raw.extended_entities.media raw.entities.media )
            raw.entities.urls
            raw.entities.user_mentions
        )


-- FIXME: It is currently ignoring the raw media
mergeMediaLists : List ExtendedMedia -> List RawMediaRecord -> List MediaRecord
mergeMediaLists extendedMedia media =
    let
        photos = getPhotos extendedMedia
        videos = getVideos extendedMedia
    in
        List.concat [photos, videos]



getPhotos : List ExtendedMedia -> List MediaRecord
getPhotos extendedMedia =
    extendedMedia
        |> List.filterMap toExtendedPhoto
        |> groupByUrl
        |> List.filterMap
            (\group ->
                List.foldr
                    (\extendedPhoto maybeMediaType ->
                        Just <| case maybeMediaType of
                            Nothing ->
                                MultiPhoto
                                    extendedPhoto.url
                                    extendedPhoto.display_url
                                    [ extendedPhoto.media_url_https ]

                            Just mediaType ->
                                { mediaType
                                | media_url_list =
                                    extendedPhoto.media_url_https :: mediaType.media_url_list
                                }
                    )
                    Nothing
                    group
            )
        |> List.map MultiPhotoMedia



toExtendedPhoto : ExtendedMedia -> Maybe ExtendedPhoto
toExtendedPhoto extendedMedia =
    case extendedMedia of
        ExtendedPhotoMedia extendedPhoto ->
            Just extendedPhoto

        otherwise ->
            Nothing



groupByUrl : List ExtendedPhoto -> List (List ExtendedPhoto)
groupByUrl mediaList =
    mediaList
        |> (flip List.foldr) []
            (\m uniqueUrls ->
                if List.member m.url uniqueUrls then
                    uniqueUrls
                else
                    m.url :: uniqueUrls
            )
        |> List.map
            (\url ->
                List.filter (\mediaItem -> mediaItem.url == url) mediaList
            )


getVideos : List ExtendedMedia -> List MediaRecord
getVideos extendedMedia =
    extendedMedia
        |> List.filterMap toExtendedVideo
        |> List.map extendedVideoToVideo
        |> List.map VideoMedia



toExtendedVideo : ExtendedMedia -> Maybe ExtendedVideo
toExtendedVideo extendedMedia =
    case extendedMedia of
        ExtendedVideoMedia extendedPhoto ->
            Just extendedPhoto

        otherwise ->
            Nothing



extendedVideoToVideo : ExtendedVideo -> Video
extendedVideoToVideo extendedVideo =
    let
        videoVariant =
            List.head extendedVideo.variants
                |> Maybe.withDefault ( VariantRecord "nothingHere" "nothingHere" )
    in
        Video
            extendedVideo.url
            extendedVideo.display_url
            videoVariant.url
            videoVariant.content_type
