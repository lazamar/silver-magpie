module Routes.Timelines.Types exposing (..)

import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.TweetBar.Types as TweetBarT



type Msg
    = TimelineMsgLocal TimelineT.Msg
    | TimelineMsgBroadcast TimelineT.Broadcast
    | TweetBarMsgLocal TweetBarT.Msg
    | TweetBarMsgBroadcast TweetBarT.Broadcast



type Broadcast
    = Logout



type alias Model =
    { timelineModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    }
