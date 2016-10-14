module Tweets.Types exposing (..)

import Http
import RemoteData exposing (WebData)



type alias Model =
  { tab: Route
  , tweets: WebData ( List Tweet )
  }



type Route
    = HomeRoute
    | MentionsRoute



type alias Tweet =
  { user : User
  , created_at : String
  , text: String
  , retweet_count : Int
  , favorite_count : Int
  , favorited : Bool
  , retweeted : Bool
  }



type alias User =
  { name : String
  , screen_name : String
  , profile_image_url_https : String
  }



type Msg
  = TweetFetch ( WebData (List Tweet) )
  | ChangeRoute Route
