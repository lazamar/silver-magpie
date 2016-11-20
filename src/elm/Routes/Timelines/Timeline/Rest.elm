module Routes.Timelines.Timeline.Rest exposing ( getTweets, favoriteTweet )

import Routes.Timelines.Timeline.Types exposing (..)
import Twitter.Decoders exposing ( tweetDecoder )
import Twitter.Types exposing ( Tweet, Credentials )
import Generic.Http

import Http
import Json.Encode
import Json.Decode exposing ( Decoder, string, int, bool, list, dict, at )
import Json.Decode.Pipeline exposing ( decode, required, optional )
import RemoteData exposing ( RemoteData ( Success, Failure ))
import Task


-- DECODERS



serverMsgDecoder : Decoder ( List Tweet )
serverMsgDecoder =
  Json.Decode.at ["tweets"] ( list tweetDecoder )



-- DATA FETCHING



getTweets : Credentials -> FetchType -> Route -> Cmd Msg
getTweets credentials position route =
    let
        section =
            case route of
                HomeRoute ->
                    "home"

                MentionsRoute ->
                    "mentions"

    in
        Generic.Http.get credentials ("/" ++ section)
            |> Http.fromJson serverMsgDecoder
            |> Task.perform Failure Success
            |> Cmd.map (TweetFetch position)


-- TODO: A service worker must make sure that this
-- request is always successfully sent, even when offline.
favoriteTweet : Credentials -> Bool -> String -> Cmd Msg
favoriteTweet credentials shouldFavorite tweetId =
    [ ( "id", Json.Encode.string tweetId)
    , ( "favorite", Json.Encode.bool shouldFavorite )
    ]
        |> Generic.Http.toJsonBody
        |> Generic.Http.post credentials "/favourite"
        |> Http.fromJson string
        |> Task.perform (\_ -> DoNothing) (\_ -> DoNothing)
