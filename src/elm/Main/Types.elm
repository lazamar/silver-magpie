module Main.Types exposing (..)

import Tweets.Types
import TweetBar.Types
import Login.Types


type Msg
  = TweetsMsg Tweets.Types.Msg
  | TweetBarMsg TweetBar.Types.Msg
  | LoginMsg Login.Types.Msg



type alias MainModel =
    { tweetsModel : Tweets.Types.Model
    , tweetBarModel : TweetBar.Types.Model
    , loginModel : Login.Types.Model
    }
