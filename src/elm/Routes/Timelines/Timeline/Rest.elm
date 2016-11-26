module Routes.Timelines.Timeline.Rest exposing ( getTweets, favoriteTweet, doRetweet )

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
getTweets credentials fetchType route =
    let
        section =
            case route of
                HomeRoute ->
                    "home"

                MentionsRoute ->
                    "mentions"

        fromId =
            case fetchType of
                Refresh ->
                    ""

                BottomTweets tweetId ->
                    (Debug.log "Tweet id" tweetId)

    in
        Generic.Http.get credentials ("/" ++ section ++ "?fromId=" ++ fromId)
            |> Http.fromJson serverMsgDecoder
            |> Task.perform Failure Success
            |> Cmd.map (TweetFetch fetchType)



-- TODO: A service worker must make sure that this
-- request is always successfully sent, even when offline.
favoriteTweet : Credentials -> Bool -> String -> Cmd Msg
favoriteTweet credentials shouldFavorite tweetId =
    let
        httpMethod =
            if shouldFavorite then
                (\cred endpoint -> Generic.Http.post cred endpoint Http.empty)
            else
                Generic.Http.delete
    in
        httpMethod credentials ( "/favorite?id=" ++ tweetId )
            |> Http.fromJson string
            |> Task.perform (\_ -> DoNothing) (\_ -> DoNothing)



-- TODO: A service worker must make sure that this
-- request is always successfully sent, even when offline.
doRetweet : Credentials -> Bool -> String -> Cmd Msg
doRetweet credentials shouldRetweet tweetId =
    let
        httpMethod =
            if shouldRetweet then
                (\cred endpoint -> Generic.Http.post cred endpoint Http.empty)
            else
                Generic.Http.delete
    in
        httpMethod credentials ( "/retweet?id=" ++ tweetId )
            |> Http.fromJson string
            |> Task.perform (\_ -> DoNothing) (\_ -> DoNothing)
