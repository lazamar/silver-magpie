module Routes.Timelines.Types exposing (..)

import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.TweetBar.Types as TweetBarT
import Twitter.Types exposing (Tweet, Credential)
import Time exposing (Time)


type Msg
    = TimelineMsg TimelineT.Msg
    | TweetBarMsg TweetBarT.Msg
    | Detach
    | Logout Credential
    | RefreshTweets
    | SubmitTweet
    | SetReplyTweet Tweet
    | UpdateTime Time


type alias Model =
    { credential : Credential
    , timelineModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    , footerMessageNumber : Int
    , time : Time
    }


type alias Config msg =
    { onUpdate : Msg -> msg
    , onLogout : Credential -> msg
    }
