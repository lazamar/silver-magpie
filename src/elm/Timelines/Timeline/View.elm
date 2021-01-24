module Timelines.Timeline.View exposing (root)

import Generic.Utils exposing (errorMessage, tooltip)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Html.Lazy
import Http
import List.Extra
import RemoteData exposing (..)
import Time exposing (Posix)
import Timelines.Timeline.TweetView exposing (tweetView)
import Timelines.Timeline.Types exposing (..)
import Twitter.Types
    exposing
        ( HashtagRecord
        , MediaRecord(..)
        , MultiPhoto
        , Retweet(..)
        , Tweet
        , UrlRecord
        , UserMentionsRecord
        , Video
        )


root : Time.Zone -> Posix -> Model -> Html Msg
root =
    -- Add memoisation to our view function and make it super performant! :D
    Html.Lazy.lazy3 view


view : Time.Zone -> Posix -> Model -> Html Msg
view zone now model =
    let
        ( newTweets, translation ) =
            case model.tab of
                HomeTab ->
                    ( model.homeTab.newTweets, "0%" )

                MentionsTab ->
                    ( model.mentionsTab.newTweets, "-100%" )

        keyedTweet ix tweet =
            ( tweet.id, tweetView zone now ix tweet )

        viewTweets tweets =
            Html.Keyed.node
                "div"
                []
                (List.indexedMap keyedTweet tweets)
    in
    div [ class "Timeline" ]
        [ div
            [ class "Tweets" ]
            [ loadingBar newTweets
            , div
                [ class "Timeline-home"
                , style "transform" ("translateX(" ++ translation ++ ")")
                ]
                [ viewTweets model.homeTab.tweets
                , loadMoreBtn model.tab model.homeTab.tweets model.homeTab.newTweets
                ]
            , div
                [ class "Timeline-mentions"
                , style "transform" ("translateX(" ++ translation ++ ")")
                ]
                [ viewTweets model.mentionsTab.tweets
                , loadMoreBtn model.tab model.mentionsTab.tweets model.mentionsTab.newTweets
                ]
            ]
        , actionBar model.tab
        ]


loadingBar : WebData (List Tweet) -> Html Msg
loadingBar request =
    case request of
        Loading ->
            section [ class "Tweets-loading" ]
                [ div [ class "load-bar" ]
                    [ div [ class "bar" ] []
                    , div [ class "bar" ] []
                    , div [ class "bar" ] []
                    ]
                ]

        Failure err ->
            div [] [ errorView err ]

        otherwise ->
            div [] []


errorView : Http.Error -> Html Msg
errorView error =
    div [ class "Tweets-error animated slideInDown" ]
        [ text (errorMessage error)
        ]


loadMoreBtn : TabName -> List Tweet -> WebData (List Tweet) -> Html Msg
loadMoreBtn route currentTweets newTweets =
    let
        fetchType =
            case List.Extra.last currentTweets of
                Nothing ->
                    Refresh

                Just lastTweet ->
                    BottomTweets lastTweet.id

        actionAttr =
            case newTweets of
                NotAsked ->
                    [ onClick (FetchTweets route fetchType) ]

                _ ->
                    [ disabled True ]

        attr =
            List.concat
                [ actionAttr
                , [ class "btn btn-default Tweets-loadMore" ]
                ]
    in
    button attr [ text "Load more" ]


actionBar : TabName -> Html Msg
actionBar route =
    div [ class "Timeline-actions" ]
        [ button
            [ class <|
                case route of
                    HomeTab ->
                        "btn btn-default Timeline-actions-route--selected"

                    _ ->
                        "btn btn-default Timeline-actions-route"
            , onClick (ChangeTab HomeTab)
            ]
            [ text "Home" ]
        , button
            [ class <|
                case route of
                    MentionsTab ->
                        "btn btn-default Timeline-actions-route--selected"

                    _ ->
                        "btn btn-default Timeline-actions-route"
            , onClick (ChangeTab MentionsTab)
            ]
            [ text "Mentions" ]
        , button
            [ class "zmdi zmdi-mail-send Timeline-sendBtn btn btn-default btn-icon"
            , onClick SubmitTweet
            , tooltip "Send"
            ]
            []
        , button
            [ class "zmdi zmdi-refresh-alt btn btn-default btn-icon"
            , onClick (FetchTweets route Refresh)
            , tooltip "Refresh"
            ]
            []
        ]
