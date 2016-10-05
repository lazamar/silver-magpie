module AJAX.Types exposing (..)

import Json.Decode exposing ( Decoder, string, int, bool )
import Json.Decode.Pipeline exposing ( decode, required )


type alias Tweet =
  { user : User
  , created_at : String
  , text: String
  , retweet_count : Int
  , favorite_count : Int
  , favorited : Bool
  , retweeted : Bool
  }


tweetDecoder : Decoder Tweet
tweetDecoder =
  decode Tweet
    |> required "user" userDecoder
    |> required "created_at" string
    |> required "text" string
    |> required "retweet_count" int
    |> required "favorite_count" int
    |> required "favorited" bool
    |> required "retweeted" bool


type alias User =
  { name : String
  , screen_name : String
  , url : String
  , profile_image_url_https : String
  }


userDecoder : Decoder User
userDecoder =
  decode User
    |> required "name" string
    |> required "screen_name" string
    |> required "url" string
    |> required "profile_image_url_https" string


type Msg = Login
