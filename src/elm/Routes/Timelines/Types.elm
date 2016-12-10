module Routes.Timelines.Types exposing (..)

import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.TweetBar.Types as TweetBarT
import Twitter.Types exposing (Credentials)


type Msg
    = TimelineMsg TimelineT.Msg
    | TimelineBroadcast TimelineT.Broadcast
    | TweetBarMsg TweetBarT.Msg
    | TweetBarBroadcast TweetBarT.Broadcast
    | Detach
    | MsgLogout


type Broadcast
    = Logout


type alias Model =
    { credentials : Credentials
    , timelineModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    , footerMessageNumber : Int
    }
