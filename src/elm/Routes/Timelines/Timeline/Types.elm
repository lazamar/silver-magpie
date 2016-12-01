module Routes.Timelines.Timeline.Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Twitter.Types exposing ( Tweet, Credentials, TweetId )


type alias Model =
    { credentials : Credentials
    , tab : TabName
    , homeTab : Tab
    , mentionsTab : Tab
    }

type alias Tab =
    { tweets : List Tweet
    , newTweets : WebData ( List Tweet )
    }



type TabName
    = HomeTab
    | MentionsTab



type alias ResponseRound
    = Int


type FetchType
    = Refresh
    | BottomTweets TweetId
    | RespondedTweets ResponseRound



type Msg
  = DoNothing
  | TweetFetch TabName FetchType ( WebData (List Tweet) )
  | ChangeTab TabName
  | FetchTweets TabName FetchType
  | Favorite Bool TweetId
  | DoRetweet Bool TweetId
  | MsgLogout
  | MsgSubmitTweet
  | MsgSetReplyTweet Tweet


type Broadcast
    = Logout
    | SubmitTweet
    | SetReplyTweet Tweet
