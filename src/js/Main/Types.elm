module Main.Types exposing (..)

import Tweets.Types
import TweetBar.Types



type Msg
  = TweetsMsg Tweets.Types.Msg
  | TweetBarMsg TweetBar.Types.Msg



type alias MainModel =
    { tweetsModel : Tweets.Types.Model
    , tweetBarModel : TweetBar.Types.Model
    }
