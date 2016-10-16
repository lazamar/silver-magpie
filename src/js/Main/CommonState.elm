module Main.CommonState exposing (..)

import Main.Types exposing (..)
import Tweets.Types
import Generic.Types exposing (never)
import Generic.Utils exposing (toCmd)

loadMoreTweets : Cmd Msg
loadMoreTweets =
    Tweets.Types.FetchTweets Tweets.Types.Refresh
        |> TweetsMsg
        |> toCmd
