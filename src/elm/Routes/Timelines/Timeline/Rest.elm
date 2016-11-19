module Routes.Timelines.Timeline.Rest exposing (..)

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