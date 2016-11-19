module Main.Types exposing (..)

import Routes.Timelines.Timeline.Types
import Routes.Timelines.TweetBar.Types
import Routes.Login.Types


type Msg
  = TweetsMsg Routes.Timelines.Timeline.Types.Msg
  | TweetBarMsg Routes.Timelines.TweetBar.Types.Msg
  | LoginMsg Routes.Login.Types.Msg
  | LoginBroadcast Routes.Login.Types.BroadcastMsg
  | Logout



type MainModel
    = LoginRoute Routes.Login.Types.Model
    | HomeRoute HomeRouteModel



type alias HomeRouteModel =
    { tweetsModel : Routes.Timelines.Timeline.Types.Model
    , tweetBarModel : Routes.Timelines.TweetBar.Types.Model
    }
