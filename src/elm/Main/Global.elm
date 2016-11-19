module Main.Global exposing (..)

import Main.Types exposing (..)
import Timeline.Types
import Generic.Types exposing (never)
import Generic.Utils exposing (toCmd)

refreshTweets : Cmd Msg
refreshTweets =
    Timeline.Types.FetchTweets Timeline.Types.Refresh
        |> TweetsMsg
        |> toCmd
