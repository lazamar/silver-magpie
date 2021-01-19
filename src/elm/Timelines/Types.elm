module Timelines.Types exposing (..)

import Time exposing (Posix)
import Timelines.Timeline.Types as TimelineT exposing (HomeTweets, MentionsTweets)
import Timelines.TweetBar.Types as TweetBarT
import Twitter.Types exposing (Credential, Tweet)


type Msg
    = TimelineMsg TimelineT.Msg
    | TweetBarMsg TweetBarT.Msg
    | Logout Credential
    | RefreshTweets
    | SubmitTweet
    | SetReplyTweet Tweet
    | UpdateTime Posix
    | StoreHome Credential HomeTweets
    | StoreMentions Credential MentionsTweets
    | StoreTweetText Credential String


type alias Model =
    { timelineModel : TimelineT.Model
    , tweetBarModel : TweetBarT.Model
    , now : Posix
    }


type alias Config msg =
    { onUpdate : Msg -> msg
    , onLogout : Credential -> msg
    , storeHome : Credential -> HomeTweets -> msg
    , storeMentions : Credential -> MentionsTweets -> msg
    , storeTweetText : Credential -> String -> msg
    }
