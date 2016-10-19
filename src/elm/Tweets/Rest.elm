module Tweets.Rest exposing (..)

import Tweets.Types exposing (..)
import Http
import Json.Decode exposing ( Decoder, string, int, bool, list, dict )
import Json.Decode.Pipeline exposing ( decode, required, optional )
import RemoteData exposing ( RemoteData ( Success, Failure ))
import Task


-- DECODERS

userMentionsDecoder =
    decode UserMentionsRecord
        |> required "screen_name" string



mediaDecoder =
    decode MediaRecord
        |> required "media_url_https" string
        |> required "url" string -- this is the url contained in the tweet



hashtagDecoder =
    decode HashtagRecord
        |> required "text" string



urlDecoder =
    decode UrlRecord
        |> required "display_url" string
        |> required "url" string



-- tweetEntitiesDecoder : Decoder
tweetEntitiesDecoder =
    decode TweetEntitiesRecord
        |> required "hashtags" ( list hashtagDecoder )
        |> required "urls" ( list urlDecoder )
        |> required "user_mentions" ( list userMentionsDecoder )
        |> optional "media" ( list mediaDecoder ) []



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
    |> required "entities" tweetEntitiesDecoder



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



getTweets : FetchType -> Route -> Cmd Msg
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
