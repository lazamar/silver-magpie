module Routes.Timelines.Timeline.Rest exposing
    ( getTweets
    , favoriteTweet
    , doRetweet
    , sendLogoutMessasge
    , getTweetsById
    )

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



getTweets : Credentials -> FetchType -> TabName -> Cmd Msg
getTweets credentials fetchType route =
    let
        section =
            case route of
                HomeTab ->
                    "home"

                MentionsTab ->
                    "mentions"

        maxId =
            case fetchType of
                Refresh ->
                    ""

                BottomTweets tweetId ->
                    tweetId

                RespondedTweets _ ->
                    ""

    in
        Generic.Http.get credentials ("/" ++ section ++ "?maxId=" ++ maxId)
            |> Http.fromJson serverMsgDecoder
            |> Task.perform Failure Success
            |> Cmd.map (TweetFetch route fetchType)



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



sendLogoutMessasge : Credentials -> Cmd Msg
sendLogoutMessasge credentials =
    Generic.Http.delete credentials "/app-revoke-access"
        |> Http.fromJson string
        |> Task.perform ( \_ -> DoNothing ) ( \_ -> DoNothing )


getTweetsById : Credentials -> List String -> Cmd Msg
getTweetsById cred ids =
        let
            ignore = Debug.log "Ids with response:" ids
        in
            Cmd.none
