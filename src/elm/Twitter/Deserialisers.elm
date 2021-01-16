module Twitter.Deserialisers exposing (..)

import Date
import Generic.Utils
import Json.Decode exposing (Decoder, at, bool, field, int, list, oneOf, string)
import Json.Decode.Pipeline exposing (custom, decode, hardcoded, required)
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
        |> Json.Decode.map Retweet


deserialiseQuotedTweet : Decoder QuotedTweet
deserialiseQuotedTweet =
    deserialiseShallowTweet
        |> Json.Decode.map QuotedTweet


deserialiseShallowTweet : Decoder Tweet
deserialiseShallowTweet =
    deserialiseFirstPartOfTweet
        |> hardcoded Nothing
        |> hardcoded Nothing


deserialiseFirstPartOfTweet =
    decode Tweet
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
    decode User
        |> required "name" string
        |> required "screen_name" string
        |> required "profile_image_url_https" string


deserialiseTweetEntitiesRecord : Decoder TweetEntitiesRecord
deserialiseTweetEntitiesRecord =
    decode TweetEntitiesRecord
        |> required "hashtags" (list hashtagDecoder)
        |> required "media" (list deserialiseMediaRecord)
        |> required "urls" (list urlDecoder)
        |> required "user_mentions" (list userMentionsDecoder)


deserialiseMediaRecord : Decoder MediaRecord
deserialiseMediaRecord =
    oneOf
        [ at [ "MultiPhotoMedia" ] deserialiseMultiPhoto
            |> Json.Decode.map MultiPhotoMedia
        , at [ "VideoMedia" ] deserialiseVideo
            |> Json.Decode.map VideoMedia
        ]


deserialiseMultiPhoto : Decoder MultiPhoto
deserialiseMultiPhoto =
    decode MultiPhoto
        |> required "url" string
        |> required "display_url" string
        |> required "media_url_list" (list string)


deserialiseVideo : Decoder Video
deserialiseVideo =
    decode Video
        |> required "url" string
        |> required "display_url" string
        |> required "media_url" string
        |> required "content_type" string


deserialiseMaybe : Decoder a -> Decoder (Maybe a)
deserialiseMaybe decoder =
    oneOf
        [ at [ "Nothing" ] (decode Nothing)
        , at [ "Just" ] decoder |> Json.Decode.map Just
        ]
