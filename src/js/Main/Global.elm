module Main.Global exposing (..)

import Main.Types exposing (..)
import Tweets.Types
import Generic.Types exposing (never)
import Generic.Utils exposing (toCmd)

refreshTweets : Cmd Msg
refreshTweets =
    Tweets.Types.FetchTweets Tweets.Types.Refresh
        |> TweetsMsg
        |> toCmd
