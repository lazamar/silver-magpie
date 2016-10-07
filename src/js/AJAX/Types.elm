module AJAX.Types exposing (..)

import Json.Decode exposing ( Decoder, string, int, bool, list )
import Json.Decode.Pipeline exposing ( decode, required )
import Tweets.Types



tweetDecoder : Decoder Tweets.Types.Tweet
tweetDecoder =
  decode Tweets.Types.Tweet
    |> required "user" userDecoder
    |> required "created_at" string
    |> required "text" string
    |> required "retweet_count" int
    |> required "favorite_count" int
    |> required "favorited" bool
    |> required "retweeted" bool


userDecoder : Decoder Tweets.Types.User
userDecoder =
  decode Tweets.Types.User
    |> required "name" string
    |> required "screen_name" string
    |> required "profile_image_url_https" string


serverMsgDecoder : Decoder ( List Tweets.Types.Tweet )
serverMsgDecoder =
  Json.Decode.at ["tweets"] ( list tweetDecoder )
