module Main.Global exposing (..)

import Main.Types exposing (..)
import Routes.Timelines.Timeline.Types
import Generic.Types exposing (never)
import Generic.Utils exposing (toCmd)

refreshTweets : Cmd Msg
refreshTweets =
    Routes.Timelines.Timeline.Types.FetchTweets Routes.Timelines.Timeline.Types.Refresh
        |> TweetsMsg
        |> toCmd
