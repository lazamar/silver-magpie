module Tweets.Types exposing (..)

import Http

type alias Model =
  { tab: String
  , error: Maybe Http.Error
  , tweets: List Tweet
  }


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
  , url : String
  , profile_image_url_https : String
  }


type Msg
  = TweetFetchFail Http.Error
  | TweetFetchSucceed (List Tweet)
