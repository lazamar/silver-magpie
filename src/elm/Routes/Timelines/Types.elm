module Routes.Timelines.Types exposing (..)

import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.TweetBar.Types as TweetBarT
import Twitter.Types exposing (Tweet, Credentials)
import Time exposing (Time)


type Msg
    = TimelineMsg TimelineT.Msg
    | TweetBarMsg TweetBarT.Msg
    | Detach
    | Logout
    | RefreshTweets
    | SubmitTweet
    | SetReplyTweet Tweet
    | UpdateTime Time


type alias Model =
    { credentials : Credentials
    , timelineModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    , footerMessageNumber : Int
    , time : Time
    }


type alias Config msg =
    { onUpdate : Msg -> msg
    , onLogout : msg
    }
