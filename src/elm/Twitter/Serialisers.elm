module Twitter.Serialisers exposing ( serialiseTweet )

import Twitter.Types exposing (..)
import Json.Encode exposing (string, int, bool, list, object)


serialiseTweet : Tweet -> Json.Encode.Value
serialiseTweet tweet =
    object
        [ ( "id", string tweet.id )
        , ( "user", serialiseUser tweet.user )
        , ( "created_at", string tweet.created_at )
        , ( "text", string tweet.text )
        , ( "retweet_count", int tweet.retweet_count )
        , ( "favorite_count", int tweet.favorite_count )
        , ( "favorited", bool tweet.favorited )
        , ( "retweeted", bool tweet.retweeted )
        , ( "entities", serialiseTweetEntitiesRecord tweet.entities )
        , ( "retweeted_status", serialiseRetweet tweet.retweeted_status )
        ]



serialiseRetweet : Maybe Retweet -> Json.Encode.Value
serialiseRetweet maybeRetweet =
    case maybeRetweet of
        Nothing ->
            object
                [ ( "type", string "Nothing" )
                , ( "content", string "" )
                ]

        Just ( Retweet retweet ) ->
            object
                [ ( "type", string "Just" )
                , ( "content", serialiseTweet retweet )
                ]



serialiseUser : User -> Json.Encode.Value
serialiseUser { name, screen_name, profile_image_url_https } =
    object
        [ ( "name", string name )
        , ( "screen_name", string screen_name )
        , ( "profile_image_url_https", string profile_image_url_https )
        ]



serialiseTweetEntitiesRecord : TweetEntitiesRecord -> Json.Encode.Value
serialiseTweetEntitiesRecord { hashtags, media, urls, user_mentions } =
    object
        [ ( "hashtags", list <| List.map serialiseHashtagRecord hashtags )
        , ( "media", list <| List.map serialiseMediaRecord media  )
        , ( "urls", list <| List.map serialiseUrlRecord urls )
        , ( "user_mentions", list <| List.map serialiseUserMentionsRecord user_mentions )
        ]



serialiseHashtagRecord : HashtagRecord -> Json.Encode.Value
serialiseHashtagRecord { text } =
    object
        [ ( "text", string text )
        ]



serialiseUrlRecord : UrlRecord -> Json.Encode.Value
serialiseUrlRecord { display_url, url } =
    object
        [ ( "display_url", string display_url )
        , ( "url", string url )
        ]



serialiseUserMentionsRecord : UserMentionsRecord -> Json.Encode.Value
serialiseUserMentionsRecord { screen_name } =
    object
        [ ( "screen_name", string screen_name )
        ]



serialiseMediaRecord : MediaRecord -> Json.Encode.Value
serialiseMediaRecord mediaRecord =
    case mediaRecord of
        MultiPhotoMedia multiPhoto ->
            object
                [ ( "type", string "MultiPhotoMedia" )
                , ( "content", serialiseMultiPhoto multiPhoto )
                ]

        VideoMedia video ->
            object
                [ ( "type", string "VideoMedia" )
                , ( "content", serialiseVideoMedia video )
                ]



serialiseMultiPhoto : MultiPhoto -> Json.Encode.Value
serialiseMultiPhoto { url, display_url, media_url_list } =
    object
        [ ( "url", string url )
        , ( "display_url", string display_url )
        , ( "media_url_list", list <| List.map string media_url_list )
        ]



serialiseVideoMedia : Video -> Json.Encode.Value
serialiseVideoMedia { url, display_url, media_url, content_type } =
    object
        [ ( "url", string url )
        , ( "display_url", string display_url )
        , ( "media_url", string media_url )
        , ( "content_type", string content_type )
        ]
