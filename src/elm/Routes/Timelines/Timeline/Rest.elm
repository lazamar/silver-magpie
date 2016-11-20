module Routes.Timelines.Timeline.Rest exposing ( getTweets, favoriteTweet )

import Routes.Timelines.Timeline.Types exposing (..)
import Twitter.Decoders exposing ( tweetDecoder )
import Twitter.Types exposing ( Tweet, Credentials )
import Generic.Http

import Http
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
favoriteTweet : Credentials -> String -> Cmd Msg
favoriteTweet credentials tweetId =
    "{ \"id\": " ++ tweetId ++ " }"
        |> Http.string
        |> \body -> Generic.Http.post body credentials "/favourite"
        |> Http.fromJson string
        |> Task.perform (\_ -> DoNothing) (\_ -> DoNothing)
