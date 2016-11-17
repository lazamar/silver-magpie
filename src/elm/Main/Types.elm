module Main.Types exposing (..)

import Tweets.Types
import TweetBar.Types
import Login.Types


type Msg
  = TweetsMsg Tweets.Types.Msg
  | TweetBarMsg TweetBar.Types.Msg
  | LoginMsg Login.Types.Msg
  | Logout
  | Login String



type MainModel
    = LoginRoute Login.Types.Model
    | HomeRoute HomeRouteModel



type alias HomeRouteModel =
    { tweetsModel : Tweets.Types.Model
    , tweetBarModel : TweetBar.Types.Model
    }
