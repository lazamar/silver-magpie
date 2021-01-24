module Timelines.Timeline.TweetView exposing (tweetView)

import Array
import Generic.Utils exposing (timeDifference, tooltip)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode
import List.Extra
import Maybe
import Regex
import Regex.Extra exposing (regex)
import String
import Time exposing (Posix)
import Timelines.Timeline.Types exposing (..)
import Twitter.Types
    exposing
        ( HashtagRecord
        , MediaRecord(..)
        , MultiPhoto
        , QuotedTweet(..)
        , Retweet(..)
        , Tweet
        , UrlRecord
        , User
        , UserMentionsRecord
        , Video
        )


tweetView : Time.Zone -> Posix -> Int -> Tweet -> Html Msg
tweetView zone now index mainTweet =
    let
        tweet =
            getMainContent mainTweet
    in
    div
        [ class "Tweet"

        -- , style [ ( "borderColor", (getColor index) ) ]
        ]
        [ retweetInfo mainTweet
        , tweetContent zone now tweet
        , quotedContent zone now tweet
        , tweetActions tweet
        ]


getMainContent : Tweet -> Tweet
getMainContent tweet =
    tweet
        |> .retweeted_status
        |> Maybe.map (\(Retweet retweet) -> retweet)
        |> Maybe.withDefault tweet


timeInfo : Time.Zone -> Posix -> Tweet -> Html Msg
timeInfo zone now tweet =
    let
        info =
            timeDifference zone now tweet.created_at
    in
    a
        [ class "Tweet-timeInfo"
        , target "blank"
        , href <| "https://twitter.com/" ++ tweet.user.name ++ "/status/" ++ tweet.id
        ]
        [ text info ]


retweetInfo : Tweet -> Html Msg
retweetInfo topTweet =
    case topTweet.retweeted_status of
        Nothing ->
            text ""

        Just _ ->
            div [ class "Tweet-retweet-info" ]
                [ i [ class "zmdi zmdi-repeat Tweet-retweet-info-icons" ] []
                , text "retweeted by "
                , a
                    [ href <| userProfileLink topTweet.user
                    , target "blank"
                    ]
                    [ text ("@" ++ topTweet.user.screen_name) ]
                ]


tweetContent : Time.Zone -> Posix -> Tweet -> Html Msg
tweetContent zone now tweet =
    div [ class "Tweet-body" ]
        [ img
            [ class "Tweet-userImage"
            , src tweet.user.profile_image_url_https
            ]
            []
        , div [ class "Tweet-content" ]
            [ div
                [ class "Tweet-content-header" ]
                [ div
                    [ class "Tweet-userInfoContainer" ]
                    [ a
                        [ class "Tweet-userName"
                        , href <| userProfileLink tweet.user
                        , target "_blank"
                        ]
                        [ text tweet.user.name ]
                    , a
                        [ class "Tweet-userHandler"
                        , href <| userProfileLink tweet.user
                        , target "_blank"
                        ]
                        [ text ("@" ++ tweet.user.screen_name) ]
                    ]
                , timeInfo zone now tweet
                ]
            , p [ class "Tweet-text" ] (tweetTextView_ tweet)
            , div
                [ class "Tweet-media" ]
                [ mediaView tweet ]
            ]
        ]


{-| Type used to support the transformation of parts
of a tweet into HTML incrementally
-}
type TweetPart
    = Text String
    | Html (Html Msg)


tweetTextView_ : Tweet -> List (Html Msg)
tweetTextView_ { text, entities, quoted_status } =
    let
        flip f b a =
            f a b

        toHtml part =
            case part of
                Text t ->
                    Html.text t

                Html html ->
                    html

        -- Anamorphism
        overL f items tweetParts =
            List.foldl (List.concatMap << overTextL << f) tweetParts items

        overTextL f part =
            case part of
                Text t ->
                    f t

                Html html ->
                    [ part ]

        overText f part =
            case part of
                Text t ->
                    Text (f t)

                Html html ->
                    part
    in
    [ Text text ]
        |> overL linkUrl entities.urls
        |> flip (List.foldl (List.map << overText << removeMediaUrl)) entities.media
        |> List.map (overText <| removeQuotedTweetUrl quoted_status entities.urls)
        |> overL linkHashtags entities.hashtags
        |> overL linkUserMentions entities.user_mentions
        |> List.concatMap (overTextL addLineBreaks_)
        |> List.map toHtml


linkUrl : UrlRecord -> String -> List TweetPart
linkUrl url tweetText =
    case String.split url.url tweetText of
        [ text ] ->
            -- Avoid creating the HTML element
            [ Text text ]

        parts ->
            let
                link =
                    Html.a
                        [ target "_blank"
                        , href url.url
                        ]
                        [ text url.display_url
                        ]
            in
            List.intersperse (Html link) <| List.map Text parts


linkHashtags : HashtagRecord -> String -> List TweetPart
linkHashtags { text } tweetText =
    let
        hash =
            "#" ++ text
    in
    case String.split hash tweetText of
        [ t ] ->
            -- Avoid creating the HTML element
            [ Text t ]

        parts ->
            let
                hashLink =
                    Html.a
                        [ target "_blank"
                        , href <| "https://twitter.com/hashtag/" ++ text ++ "?src=hash"
                        ]
                        [ Html.text hash
                        ]
            in
            List.intersperse (Html hashLink) <| List.map Text parts


linkUserMentions : UserMentionsRecord -> String -> List TweetPart
linkUserMentions { screen_name } tweetText =
    let
        handler =
            "@" ++ screen_name
    in
    case String.split handler tweetText of
        [ t ] ->
            -- Avoid creating the HTML element
            [ Text t ]

        parts ->
            let
                link =
                    Html.a
                        [ target "_blank"
                        , href <| "https://twitter.com/" ++ screen_name
                        ]
                        [ Html.text handler
                        ]
            in
            List.intersperse (Html link) <| List.map Text parts


addLineBreaks_ : String -> List TweetPart
addLineBreaks_ tweetText =
    case String.split "\\n" tweetText of
        [ t ] ->
            [ Text t ]

        parts ->
            List.intersperse (Html <| Html.br [] []) <| List.map Text parts


quotedContent : Time.Zone -> Posix -> Tweet -> Html Msg
quotedContent zone now mainTweet =
    case mainTweet.quoted_status of
        Nothing ->
            text ""

        Just (QuotedTweet tweet) ->
            div [ class "Tweet-quoted" ]
                [ tweetContent zone now tweet
                ]


userProfileLink : User -> String
userProfileLink user =
    "https://twitter.com/" ++ user.screen_name


tweetActions : Tweet -> Html Msg
tweetActions tweet =
    div [ class "Tweet-actions" ]
        [ button
            [ class "Tweet-actions-reply zmdi zmdi-mail-reply"
            , onClick (SetReplyTweet tweet)
            , tooltip "Reply"
            ]
            []
        , button
            (if tweet.favorited then
                [ class "Tweet-actions-favourite--favorited"
                , onClick <| Favorite (not tweet.favorited) tweet.id
                , tooltip "Undo like"
                ]

             else
                [ class "Tweet-actions-favourite"
                , onClick <| Favorite (not tweet.favorited) tweet.id
                , tooltip "Like"
                ]
            )
            [ i [ class "zmdi zmdi-favorite" ] []
            , text (toStringNotZero tweet.favorite_count)
            ]
        , button
            (if tweet.retweeted then
                [ class "Tweet-actions-retweet--retweeted"
                , onClick <| DoRetweet (not tweet.retweeted) tweet.id
                , tooltip "Undo retweet"
                ]

             else
                [ class "Tweet-actions-retweet"
                , onClick <| DoRetweet (not tweet.retweeted) tweet.id
                , tooltip "Retweet"
                ]
            )
            [ i [ class "zmdi zmdi-repeat" ] []
            , text (toStringNotZero tweet.retweet_count)
            ]
        ]


getColor : Int -> String
getColor index =
    let
        colorNum =
            modBy (Array.length colors) index

        defaultColor =
            "#F44336"
    in
    case Array.get colorNum colors of
        Just color ->
            color

        Nothing ->
            defaultColor


colors : Array.Array String
colors =
    Array.fromList
        [ "#F44336"
        , "#009688"
        , "#e61865"
        , "#9E9E9E"
        , "#FF9800"
        , "#03A9F4"
        , "#8BC34A"
        , "#FF5722"
        , "#607D8B"
        , "#3F51B5"
        , "#CDDC39"
        , "#2196F3"
        , "#F44336"
        , "#000000"
        , "#E91E63"
        , "#FFEB3B"
        , "#9C27B0"
        , "#673AB7"
        , "#795548"
        , "#4CAF50"
        , "#FFC107"
        ]


toStringNotZero : Int -> String
toStringNotZero num =
    if num > 0 then
        String.fromInt num

    else
        ""


removeMediaUrl : MediaRecord -> String -> String
removeMediaUrl record tweetText =
    case record of
        VideoMedia video ->
            String.replace video.url "" tweetText

        MultiPhotoMedia photo ->
            String.replace photo.url "" tweetText


removeQuotedTweetUrl : Maybe QuotedTweet -> List UrlRecord -> String -> String
removeQuotedTweetUrl maybeQuoted urls tweetText =
    case maybeQuoted of
        Nothing ->
            tweetText

        Just _ ->
            let
                lastUrl =
                    List.Extra.last urls
                        |> Maybe.map .display_url
                        |> Maybe.withDefault ""
            in
            String.replace lastUrl "" tweetText


mediaView : Tweet -> Html Msg
mediaView tweet =
    tweet.entities.media
        |> List.map
            (\media ->
                case media of
                    VideoMedia videoMedia ->
                        videoView videoMedia

                    MultiPhotoMedia multiPhoto ->
                        multiPhotoView multiPhoto
            )
        |> div []


videoView : Video -> Html Msg
videoView videoMedia =
    a
        [ href <| "https://" ++ videoMedia.display_url
        , target "_blank"
        ]
        [ video
            [ src videoMedia.media_url
            , autoplay True
            , loop True
            , muted True
            , class "Tweet-media-video"
            ]
            []
        ]


muted : Bool -> Html.Attribute Msg
muted v =
    property "muted" <| Json.Encode.bool v


multiPhotoView : MultiPhoto -> Html Msg
multiPhotoView multiPhoto =
    multiPhoto.media_url_list
        |> List.map
            (\imgUrl ->
                a
                    [ href <| "https://" ++ multiPhoto.display_url
                    , target "_blank"
                    ]
                    [ img
                        [ src imgUrl
                        , class "Tweet-media-photo"
                        ]
                        []
                    ]
            )
        |> div []
