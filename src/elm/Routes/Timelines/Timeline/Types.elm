module Routes.Timelines.Timeline.Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Twitter.Types exposing ( Tweet, Credentials, TweetId )


type alias Model =
    { credentials : Credentials
    , tab : Route
    , homeTab : Tab
    , mentionsTab : Tab
    }

type alias Tab =
    { tweets : List Tweet
    , newTweets : WebData ( List Tweet )
    }



type Route
    = HomeRoute
    | MentionsRoute



type FetchType
    = Refresh
    | BottomTweets TweetId



type Msg
  = DoNothing
  | TweetFetch Route FetchType ( WebData (List Tweet) )
  | ChangeRoute Route
  | FetchTweets Route FetchType
  | Favorite Bool TweetId
  | DoRetweet Bool TweetId
  | MsgLogout
  | MsgSubmitTweet


type Broadcast
    = Logout
    | SubmitTweet
