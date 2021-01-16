module Twitter.Types exposing (..)

import Date exposing (Date)


type alias Credential =
    String


type alias TweetId =
    String


type alias User =
    { name : String
    , screen_name : String
    , profile_image_url_https : String
    }


type alias Tweet =
    { id : String
    , user : User
    , created_at : Date
    , text : String
    , retweet_count : Int
    , favorite_count : Int
    , favorited : Bool
    , retweeted : Bool
    , in_reply_to_status_id : Maybe String
    , entities :
        TweetEntitiesRecord

    -- TODO: inline this
    , retweeted_status : Maybe Retweet
    , quoted_status : Maybe QuotedTweet
    }


type Retweet
    = Retweet Tweet


type QuotedTweet
    = QuotedTweet Tweet


type alias TweetEntitiesRecord =
    { hashtags : List HashtagRecord
    , media : List MediaRecord
    , urls : List UrlRecord
    , user_mentions : List UserMentionsRecord
    }


type alias UserMentionsRecord =
    { screen_name : String
    }


type MediaRecord
    = MultiPhotoMedia MultiPhoto
    | VideoMedia Video


type alias MultiPhoto =
    { url :
        String

    -- what is in the tweet
    , display_url :
        String

    -- what should be shown in the tweet
    , media_url_list :
        List String

    -- the actuall addresses of the contents
    }


type alias Video =
    { url :
        String

    -- what is in the tweet
    , display_url :
        String

    -- what should be shown in the tweet
    , media_url :
        String

    -- the actuall addresses of the contents
    , content_type : String
    }


type alias HashtagRecord =
    { text : String
    }


type alias UrlRecord =
    { display_url : String
    , url : String
    }
