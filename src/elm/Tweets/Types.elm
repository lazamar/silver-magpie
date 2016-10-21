module Tweets.Types exposing (..)

import Http
import RemoteData exposing (WebData)



type alias Model =
  { tab: Route
  , tweets: List Tweet
  , newTweets: WebData ( List Tweet )
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



type alias User =
  { name : String
  , screen_name : String
  , profile_image_url_https : String
  }



  -- Rest Types



type alias Tweet =
  { user : User
  , created_at : String
  , text: String
  , retweet_count : Int
  , favorite_count : Int
  , favorited : Bool
  , retweeted : Bool
  , entities: TweetEntitiesRecord -- TODO: inline this
  }



type alias TweetEntitiesRecord =
    { hashtags : List HashtagRecord
    , urls : List UrlRecord
    , user_mentions : List UserMentionsRecord
    , media : List MediaRecord
    }



type alias UserMentionsRecord =
    { screen_name : String
    }



type alias MediaRecord =
    { media_url_https : String
    , url : String
    }



type alias HashtagRecord =
    { text : String
    }



type alias UrlRecord =
    { display_url : String
    , url : String
    }
