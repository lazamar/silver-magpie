module Timelines.Types exposing (..)

import Time exposing (Posix)
import Timelines.Timeline.Types as TimelineT
import Timelines.TweetBar.Types as TweetBarT
import Twitter.Types exposing (Credential, Tweet)


type Msg
    = TimelineMsg TimelineT.Msg
    | TweetBarMsg TweetBarT.Msg
    | Logout Credential
    | RefreshTweets
    | SubmitTweet
    | SetReplyTweet Tweet
    | UpdateTime Posix


type alias Model =
    { timelineModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    , now : Posix
    }


type alias Config msg =
    { onUpdate : Msg -> msg
    , onLogout : Credential -> msg
    }
