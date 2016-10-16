module Tweets.Rest exposing (..)

import Tweets.Types exposing (..)
import Http
import Json.Decode exposing ( Decoder, string, int, bool, list )
import Json.Decode.Pipeline exposing ( decode, required )
import RemoteData exposing ( RemoteData ( Success, Failure ))
import Task


-- DECODERS



tweetDecoder : Decoder Tweet
tweetDecoder =
  decode Tweet
    |> required "user" userDecoder
    |> required "created_at" string
    |> required "text" string
    |> required "retweet_count" int
    |> required "favorite_count" int
    |> required "favorited" bool
    |> required "retweeted" bool



userDecoder : Decoder User
userDecoder =
  decode User
    |> required "name" string
    |> required "screen_name" string
    |> required "profile_image_url_https" string



serverMsgDecoder : Decoder ( List Tweet )
serverMsgDecoder =
  Json.Decode.at ["tweets"] ( list tweetDecoder )



-- DATA FETCHING



getTweets : TweetsPosition -> Route -> Cmd Msg
getTweets position route =
    let
        section =
            case route of
                HomeRoute ->
                    "home"

                MentionsRoute ->
                    "mentions"

        url = "http://localhost:8080/" ++ section
    in
        Http.get serverMsgDecoder url
            |> Task.perform Failure Success
            |> Cmd.map (TweetFetch position)
