module Routes.Timelines.Types exposing (..)

import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.TweetBar.Types as TweetBarT
import Twitter.Types exposing (Tweet, Credentials)


type Msg
    = TimelineMsg TimelineT.Msg
    | TweetBarMsg TweetBarT.Msg
    | Detach
    | MsgLogout
    | RefreshTweets
    | SubmitTweet
    | SetReplyTweet Tweet


type Broadcast
    = Logout


type alias Model =
    { credentials : Credentials
    , timelineModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    , footerMessageNumber : Int
    }
