module Tweets.Rest exposing (..)

import Tweets.Types exposing (..)
import Twitter.Decoders exposing ( tweetDecoder )
import Twitter.Types exposing ( Tweet )
import Generic.Utils

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



getTweets : FetchType -> Route -> Cmd Msg
getTweets position route =
    let
        section =
            case route of
                HomeRoute ->
                    "home"

                MentionsRoute ->
                    "mentions"

        url =
            Generic.Utils.sameDomain <| "/" ++ section

    in
        Http.get serverMsgDecoder url
            |> Task.perform Failure Success
            |> Cmd.map (TweetFetch position)
