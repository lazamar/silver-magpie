module Tweets.View exposing (..)


import Tweets.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Array
import RemoteData exposing (..)


root : Model -> Html Msg
root model =
  div [ class "Tweets"]
    [ tweetListView model.tweets ]



tweetListView : WebData (List Tweet) -> Html Msg
tweetListView tweets =
    case tweets of
            NotAsked ->
                div [] [ text "Initialising" ]

            Loading ->
                div [ class "Tweets-loading" ] [ text "Loading..." ]

            Success tweetList ->
                div [] ( List.indexedMap tweetView tweetList )

            Failure err ->
                div [] [ errorView err ]



tweetView : Int -> Tweet -> Html Msg
tweetView index tweet =
  div
    [ class "Tweet"
    , style [ ("borderColor", ( getColor index ) )]
    ]
    [ img
        [ class "Tweet-userImage"
        , src tweet.user.profile_image_url_https
        ] []
    , div []
        [ div
            [ class "Tweet-userInfoContainer"]
            [ a
                [ class "Tweet-userName"
                , href ( "https://twitter.com/" ++ tweet.user.screen_name )
                , target "_blank"
                ]
                [ text tweet.user.name ]
            , a
                [ class "Tweet-userHandler"
                , href ( "https://twitter.com/" ++ tweet.user.screen_name )
                , target "_blank"
                ]
                [ text ( "@" ++ tweet.user.screen_name ) ]
            ]
        , p [ class "Tweet-text" ]
            [ text tweet.text ]
        ]
    ]


getColor : Int -> String
getColor index =
  let
    colorNum = index % Array.length colors
    defaultColor = "#F44336"
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
    , "#E91E63"
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


errorView : Http.Error -> Html Msg
errorView data =
    div [ class "Tweets-error animated fadeInDown" ]
        [ text ( errorMessage error)
        ]

errorMessage : Http.Error -> String
errorMessage error =
  case error of
    Http.Timeout ->
      "The server didn't respond on time."

    Http.NetworkError ->
      "Unable to connect to server"

    Http.UnexpectedPayload errDescription ->
      "Unable to parse server response: " ++ errDescription

    Http.BadResponse errCode errDescription ->
      "Server returned " ++ ( toString errCode ) ++ ". " ++ errDescription
