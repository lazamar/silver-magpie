module Main.Types exposing (..)

import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.TweetBar.Types as TweetBarT
import Routes.Login.Types as LoginT


type Msg
  = TweetsMsg TimelineT.Msg
  | TweetBarMsg TweetBarT.Msg
  | LoginMsgLocal LoginT.Msg
  | LoginMsgBroadcast LoginT.Broadcast
  | Logout



type MainModel
    = LoginRoute LoginT.Model
    | HomeRoute HomeRouteModel



type alias HomeRouteModel =
    { tweetsModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    }
