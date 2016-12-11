module Routes.Timelines.Timeline.Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Twitter.Types exposing (Tweet, TweetId)
import Time exposing (Time)


type alias Model =
    { tab : TabName
    , homeTab : Tab
    , mentionsTab : Tab
    , clock : Time
    }


type alias Tab =
    { tweets : List Tweet
    , newTweets : WebData (List Tweet)
    }


type TabName
    = HomeTab
    | MentionsTab


type FetchType
    = Refresh
    | BottomTweets TweetId


type Msg
    = DoNothing
    | UpdateClock Time
    | TweetFetch TabName FetchType (WebData (List Tweet))
    | ChangeTab TabName
    | FetchTweets TabName FetchType
    | Favorite Bool TweetId
    | DoRetweet Bool TweetId
    | SubmitTweet
    | SetReplyTweet Tweet


type alias UpdateConfig msg =
    { onUpdate : Msg -> msg
    , onLogout : msg
    , onSubmitTweet : msg
    , onSetReplyTweet : Tweet -> msg
    }
