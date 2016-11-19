module Timeline.View exposing ( root )


import Timeline.Types exposing (..)
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
import Timeline.TweetView exposing ( tweetView )
import RemoteData exposing (..)


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

errorView : Http.Error -> Html Msg
errorView error =
    div [ class "Tweets-error animated fadeInDown" ]
        [ text ( errorMessage error)
        ]
