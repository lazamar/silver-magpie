module Twitter.Deserialisers exposing (..)

import Generic.Utils
import Json.Decode as Decode exposing (Decoder, at, bool, field, int, list, oneOf, string)
import Json.Decode.Extra exposing (custom, hardcoded, required)
import Twitter.Decoders.TweetDecoder exposing (..)
import Twitter.Types exposing (..)


deserialiseTweet : Decoder Tweet
deserialiseTweet =
    deserialiseFirstPartOfTweet
        |> required "retweeted_status" (deserialiseMaybe deserialiseRetweet)
        |> required "quoted_status" (deserialiseMaybe deserialiseQuotedTweet)


deserialiseRetweet : Decoder Retweet
deserialiseRetweet =
    deserialiseShallowTweet
        |> Decode.map Retweet


deserialiseQuotedTweet : Decoder QuotedTweet
deserialiseQuotedTweet =
    deserialiseShallowTweet
        |> Decode.map QuotedTweet


deserialiseShallowTweet : Decoder Tweet
deserialiseShallowTweet =
    deserialiseFirstPartOfTweet
        |> hardcoded Nothing
        |> hardcoded Nothing


deserialiseFirstPartOfTweet =
    Decode.succeed Tweet
        |> required "id" string
        |> required "user" deserialiseUser
        |> required "created_at" Generic.Utils.dateDecoder
        |> required "text" string
        |> required "retweet_count" int
        |> required "favorite_count" int
        |> required "favorited" bool
        |> required "retweeted" bool
        |> required "in_reply_to_status_id" (deserialiseMaybe string)
        |> required "entities" deserialiseTweetEntitiesRecord


deserialiseUser : Decoder User
deserialiseUser =
    Decode.succeed User
        |> required "name" string
        |> required "screen_name" string
        |> required "profile_image_url_https" string


deserialiseTweetEntitiesRecord : Decoder TweetEntitiesRecord
deserialiseTweetEntitiesRecord =
    Decode.succeed TweetEntitiesRecord
        |> required "hashtags" (list hashtagDecoder)
        |> required "media" (list deserialiseMediaRecord)
        |> required "urls" (list urlDecoder)
        |> required "user_mentions" (list userMentionsDecoder)


deserialiseMediaRecord : Decoder MediaRecord
deserialiseMediaRecord =
    oneOf
        [ at [ "MultiPhotoMedia" ] deserialiseMultiPhoto
            |> Decode.map MultiPhotoMedia
        , at [ "VideoMedia" ] deserialiseVideo
            |> Decode.map VideoMedia
        ]


deserialiseMultiPhoto : Decoder MultiPhoto
deserialiseMultiPhoto =
    Decode.succeed MultiPhoto
        |> required "url" string
        |> required "display_url" string
        |> required "media_url_list" (list string)


deserialiseVideo : Decoder Video
deserialiseVideo =
    Decode.succeed Video
        |> required "url" string
        |> required "display_url" string
        |> required "media_url" string
        |> required "content_type" string


deserialiseMaybe : Decoder a -> Decoder (Maybe a)
deserialiseMaybe decoder =
    oneOf
        [ at [ "Nothing" ] (Decode.succeed Nothing)
        , at [ "Just" ] decoder |> Decode.map Just
        ]
