module Routes.Timelines.Timeline.Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Twitter.Types exposing ( Tweet, Credentials )


type alias Model =
  { credentials : Credentials
  , tab : Route
  , tweets : List Tweet
  , newTweets : WebData ( List Tweet )
  }



type Route
    = HomeRoute
    | MentionsRoute



type FetchType
    = Refresh
    | BottomTweets



type Msg
  = DoNothing
  | TweetFetch FetchType ( WebData (List Tweet) )
  | ChangeRoute Route
  | FetchTweets FetchType
  | Favorite Bool String


type Broadcast =
    Never
