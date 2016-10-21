module Tweets.TweetParser exposing (..)

import Tweets.Types exposing
    ( Tweet
    , User
    , TweetEntitiesRecord
    , UserMentionsRecord
    , MediaRecord
    , HashtagRecord
    , UrlRecord
    )

import Json.Decode exposing ( Decoder, string, int, bool, list, dict, at )
import Json.Decode.Pipeline exposing ( decode, required, optional )



-- Types



-- Raw as in not preprocessed. It is just like the server sent
type alias RawTweet =
  { user : User
  , created_at : String
  , text: String
  , retweet_count : Int
  , favorite_count : Int
  , favorited : Bool
  , retweeted : Bool
  , entities: TweetEntitiesRecord
  , extended_entities: ExtendedEntitiesRecord
  }



type alias ExtendedEntitiesRecord =
    { media: List ExtendedMediaRecord
    }



type alias ExtendedMediaRecord =
    { url: String
    , variants: List ExtendedMediaVariantRecord
    }



type alias ExtendedMediaVariantRecord =
    { content_type: String
    , url: String
    }



-- DECODERS



tweetDecoder : Decoder Tweet
tweetDecoder =
    rawTweetDecoder
        |> Json.Decode.map preprocessTweet



preprocessTweet : RawTweet -> Tweet
preprocessTweet raw =
    Tweet
        raw.user
        raw.created_at
        raw.text
        raw.retweet_count
        raw.favorite_count
        raw.favorited
        raw.retweeted
        raw.entities



rawTweetDecoder : Decoder RawTweet
rawTweetDecoder =
    decode RawTweet
        |> required "user" userDecoder
        |> required "created_at" string
        |> required "text" string
        |> required "retweet_count" int
        |> required "favorite_count" int
        |> required "favorited" bool
        |> required "retweeted" bool
        |> required "entities" tweetEntitiesDecoder
        |> required "extended_entities" extendedEntitiesDecoder



userDecoder : Decoder User
userDecoder =
  decode User
    |> required "name" string
    |> required "screen_name" string
    |> required "profile_image_url_https" string



tweetEntitiesDecoder : Decoder TweetEntitiesRecord
tweetEntitiesDecoder =
    decode TweetEntitiesRecord
        |> required "hashtags" ( list hashtagDecoder )
        |> required "urls" ( list urlDecoder )
        |> required "user_mentions" ( list userMentionsDecoder )
        |> optional "media" ( list mediaDecoder ) []



userMentionsDecoder =
    decode UserMentionsRecord
        |> required "screen_name" string



mediaDecoder =
    decode MediaRecord
        |> required "media_url_https" string
        |> required "url" string -- this is the url contained in the tweet



hashtagDecoder =
    decode HashtagRecord
        |> required "text" string



urlDecoder =
    decode UrlRecord
        |> required "display_url" string
        |> required "url" string



-- EXTENDED ENTITIES



extendedEntitiesDecoder : Decoder ExtendedEntitiesRecord
extendedEntitiesDecoder =
    decode ExtendedEntitiesRecord
        |> optional "media" ( list extendedMediaRecordDecoder ) []




extendedMediaRecordDecoder : Decoder ExtendedMediaRecord
extendedMediaRecordDecoder =
    decode ExtendedMediaRecord
        |> required "url" string
        |> required "variants" (at ["video_info", "variants"] (list extendedMediaVariantRecordDecoder))




extendedMediaVariantRecordDecoder : Decoder ExtendedMediaVariantRecord
extendedMediaVariantRecordDecoder =
    decode ExtendedMediaVariantRecord
        |> required "content_type" string
        |> required "url" string
