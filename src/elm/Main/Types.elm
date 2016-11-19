module Main.Types exposing (..)

import Timeline.Types
import TweetBar.Types
import Login.Types


type Msg
  = TweetsMsg Timeline.Types.Msg
  | TweetBarMsg TweetBar.Types.Msg
  | LoginMsg Login.Types.Msg
  | Logout
  | Login String



type MainModel
    = LoginRoute Login.Types.Model
    | HomeRoute HomeRouteModel



type alias HomeRouteModel =
    { tweetsModel : Timeline.Types.Model
    , tweetBarModel : TweetBar.Types.Model
    }
