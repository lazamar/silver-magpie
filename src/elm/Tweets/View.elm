module Tweets.View exposing ( root )


import Tweets.Types exposing (..)
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

import Generic.Utils exposing ( errorMessage )
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Array
import Regex
import RemoteData exposing (..)
import Json.Encode

import Tweets.TweetView exposing ( tweetView )


root : Model -> Html Msg
root model =
  div [ class "Tweets"]
    [ loadingBar model.newTweets
    , div [] ( List.indexedMap tweetView model.tweets )
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
