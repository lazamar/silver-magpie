module Timelines.Timeline.Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Twitter.Types exposing (Credential, Tweet, TweetId)


type alias Model =
    { tab : TabName
    , homeTab : Tab
    , mentionsTab : Tab
    }


type alias Tab =
    { tweets : List Tweet
    , newTweets : WebData (List Tweet)
    }


type TabName
    = HomeTab
    | MentionsTab


type FetchType
    = ClearFetch
    | Refresh
    | BottomTweets TweetId


type Msg
    = DoNothing
    | TweetFetch TabName FetchType (WebData (List Tweet))
    | ChangeTab TabName
    | FetchTweets TabName FetchType
    | Favorite Bool TweetId
    | DoRetweet Bool TweetId
    | SubmitTweet
    | SetReplyTweet Tweet


type alias Config msg =
    { onUpdate : Msg -> msg
    , onLogout : Credential -> msg
    , onSubmitTweet : msg
    , onSetReplyTweet : Tweet -> msg
    }
