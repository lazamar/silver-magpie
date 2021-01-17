module Twitter.Serialisers exposing (serialiseTweet)

import Json.Encode as Encode exposing (bool, int, list, object, string)
import Time
import Twitter.Types exposing (..)



--
--      These functions transform and Elm representation of a tweet
--      into a String.
--


serialiseTweet : Tweet -> Encode.Value
serialiseTweet tweet =
    object
        [ ( "id", string tweet.id )
        , ( "user", serialiseUser tweet.user )
        , ( "created_at", posix tweet.created_at )
        , ( "text", string tweet.text )
        , ( "retweet_count", int tweet.retweet_count )
        , ( "favorite_count", int tweet.favorite_count )
        , ( "favorited", bool tweet.favorited )
        , ( "retweeted", bool tweet.retweeted )
        , ( "in_reply_to_status_id", serialiseMaybe string tweet.in_reply_to_status_id )
        , ( "entities", serialiseTweetEntitiesRecord tweet.entities )
        , ( "retweeted_status", serialiseMaybe serialiseRetweet tweet.retweeted_status )
        , ( "quoted_status", serialiseMaybe serialiseQuotedTweet tweet.quoted_status )
        ]


posix : Time.Posix -> Encode.Value
posix =
    Encode.int << Time.posixToMillis


serialiseRetweet : Retweet -> Encode.Value
serialiseRetweet (Retweet retweet) =
    serialiseTweet retweet


serialiseQuotedTweet : QuotedTweet -> Encode.Value
serialiseQuotedTweet (QuotedTweet quotedTweet) =
    serialiseTweet quotedTweet


serialiseUser : User -> Encode.Value
serialiseUser { name, screen_name, profile_image_url_https } =
    object
        [ ( "name", string name )
        , ( "screen_name", string screen_name )
        , ( "profile_image_url_https", string profile_image_url_https )
        ]


serialiseTweetEntitiesRecord : TweetEntitiesRecord -> Encode.Value
serialiseTweetEntitiesRecord { hashtags, media, urls, user_mentions } =
    object
        [ ( "hashtags", list serialiseHashtagRecord hashtags )
        , ( "media", list serialiseMediaRecord media )
        , ( "urls", list serialiseUrlRecord urls )
        , ( "user_mentions", list serialiseUserMentionsRecord user_mentions )
        ]


serialiseHashtagRecord : HashtagRecord -> Encode.Value
serialiseHashtagRecord { text } =
    object
        [ ( "text", string text )
        ]


serialiseUrlRecord : UrlRecord -> Encode.Value
serialiseUrlRecord { display_url, url } =
    object
        [ ( "display_url", string display_url )
        , ( "url", string url )
        ]


serialiseUserMentionsRecord : UserMentionsRecord -> Encode.Value
serialiseUserMentionsRecord { screen_name } =
    object
        [ ( "screen_name", string screen_name )
        ]


serialiseMediaRecord : MediaRecord -> Encode.Value
serialiseMediaRecord mediaRecord =
    case mediaRecord of
        MultiPhotoMedia multiPhoto ->
            object
                [ ( "MultiPhotoMedia", serialiseMultiPhoto multiPhoto )
                ]

        VideoMedia video ->
            object
                [ ( "VideoMedia", serialiseVideoMedia video )
                ]


serialiseMultiPhoto : MultiPhoto -> Encode.Value
serialiseMultiPhoto { url, display_url, media_url_list } =
    object
        [ ( "url", string url )
        , ( "display_url", string display_url )
        , ( "media_url_list", list string media_url_list )
        ]


serialiseVideoMedia : Video -> Encode.Value
serialiseVideoMedia { url, display_url, media_url, content_type } =
    object
        [ ( "url", string url )
        , ( "display_url", string display_url )
        , ( "media_url", string media_url )
        , ( "content_type", string content_type )
        ]


serialiseMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
serialiseMaybe subSerialiser value =
    case value of
        Nothing ->
            object
                [ ( "Nothing", string "Nothing" )
                ]

        Just subValue ->
            object
                [ ( "Just", subSerialiser subValue )
                ]
