module Routes.Timelines.Timeline.View exposing ( root )


import Routes.Timelines.Timeline.Types exposing (..)
import Twitter.Types exposing
    ( Tweet
    , Retweet (..)
    , UrlRecord
    , UserMentionsRecord
    , HashtagRecord
    , MediaRecord (VideoMedia, MultiPhotoMedia)
    , MultiPhoto
    , Video
    )

import Http
import Generic.Utils exposing ( errorMessage )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )
import Routes.Timelines.Timeline.TweetView exposing ( tweetView )
import RemoteData exposing (..)
import List.Extra


root : Model -> Html Msg
root model =
    div [ class "Tweets"]
        [ loadingBar model.newTweets
        , div [] ( List.indexedMap tweetView model.tweets )
        , loadMoreBtnView model.newTweets model.tweets
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
        [ text ( errorMessage error)
        ]



loadMoreBtnView : WebData ( List Tweet ) -> ( List Tweet ) -> Html Msg
loadMoreBtnView newTweets currentTweets =
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
                    [ onClick ( FetchTweets fetchType ) ]

                _ ->
                    [ disabled True ]

        attr =
            List.concat
                [ actionAttr
                , [ class "btn btn-default Tweets-loadMore" ]
                ]
    in
    button attr [ text "Load more" ]
