module Tweets.Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Twitter.Types exposing (Tweet)


type alias Model =
  { credentials : String
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
  = TweetFetch FetchType ( WebData (List Tweet) )
  | ChangeRoute Route
  | FetchTweets FetchType
