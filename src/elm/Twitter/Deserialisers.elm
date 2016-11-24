module Twitter.Deserialisers exposing (..)

import Twitter.Types exposing (..)
import Twitter.Decoders.TweetDecoder exposing (..)
import Json.Decode exposing ( Decoder, string, int, bool, list, oneOf, at )
import Json.Decode.Pipeline exposing ( decode, required, hardcoded )


deserialiseTweet : Decoder Tweet
deserialiseTweet =
    deserialiseFirstPartOfTweet
        |> required "retweeted_status" ( deserialiseMaybe deserialiseRetweet )



deserialiseRetweet : Decoder Retweet
deserialiseRetweet =
    deserialiseFirstPartOfTweet
        |> hardcoded Nothing
        |> Json.Decode.map Retweet



deserialiseFirstPartOfTweet =
    decode Tweet
        |> required "id" string
        |> required "user" deserialiseUser
        |> required "created_at" string
        |> required "text" string
        |> required "retweet_count" int
        |> required "favorite_count" int
        |> required "favorited" bool
        |> required "retweeted" bool
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
        |> required "hashtags" ( list hashtagDecoder )
        |> required "media" ( list deserialiseMediaRecord )
        |> required "urls" ( list urlDecoder )
        |> required "user_mentions" ( list userMentionsDecoder )



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
        |> required "media_url_list" ( list string )



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
        [ at ["Nothing"] ( decode Nothing )
        , at ["Just"] decoder |> Json.Decode.map Just
        ]
