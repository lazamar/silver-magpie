module Routes.Timelines.Timeline.Rest exposing (getTweets, favoriteTweet, doRetweet, sendLogoutMessasge)

import Routes.Timelines.Timeline.Types exposing (..)
import Twitter.Decoders exposing (tweetDecoder)
import Twitter.Types exposing (Tweet, Credentials)
import Generic.Http
import Generic.Utils exposing (mapResult)
import Http
import Json.Encode
import Json.Decode exposing (Decoder, string, int, bool, list, dict, at)
import Json.Decode.Pipeline exposing (decode, required, optional)
import RemoteData exposing (RemoteData(Success, Failure))
import Task


-- DECODERS


serverMsgDecoder : Decoder (List Tweet)
serverMsgDecoder =
    Json.Decode.at [ "tweets" ] (list tweetDecoder)



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
                    (Debug.log "Tweet id" tweetId)
    in
        Generic.Http.get credentials serverMsgDecoder ("/" ++ section ++ "?maxId=" ++ maxId)
            |> Task.attempt (mapResult Failure Success)
            |> Cmd.map (TweetFetch route fetchType)



-- TODO: A service worker must make sure that this
-- request is always successfully sent, even when offline.


favoriteTweet : Credentials -> Bool -> String -> Cmd Msg
favoriteTweet credentials shouldFavorite tweetId =
    let
        endpoint =
            "/favorite?id=" ++ tweetId

        request =
            if shouldFavorite then
                Generic.Http.post credentials string endpoint Http.emptyBody
            else
                Generic.Http.delete credentials string endpoint
    in
        Task.attempt ignoreResult request



-- TODO: A service worker must make sure that this
-- request is always successfully sent, even when offline.


doRetweet : Credentials -> Bool -> String -> Cmd Msg
doRetweet credentials shouldRetweet tweetId =
    let
        endpoint =
            ("/retweet?id=" ++ tweetId)

        request =
            if shouldRetweet then
                Generic.Http.post credentials string endpoint Http.emptyBody
            else
                Generic.Http.delete credentials string endpoint
    in
        Task.attempt ignoreResult request


sendLogoutMessasge : Credentials -> Cmd Msg
sendLogoutMessasge credentials =
    Generic.Http.delete credentials string "/app-revoke-access"
        |> Task.attempt ignoreResult


ignoreResult : Result a b -> Msg
ignoreResult r =
    DoNothing
