module Tweets.View exposing (..)


import Tweets.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http


root : Model -> Html Msg
root model =
  div [ class "Tweets"]
    [ errorView model.error
    , tweetListView model.tweets
    ]


tweetListView : List Tweet -> Html Msg
tweetListView tweets =
  div []
   ( List.map tweetView tweets )


tweetView : Tweet -> Html Msg
tweetView tweet =
  div [ class "Tweet"]
  [ img
    [ class "Tweet-userImage"
    , src tweet.user.profile_image_url_https
    ] []
  , p [ class "Tweet-test" ]
    [ text tweet.text
    ]
  ]


errorView : (Maybe Http.Error) -> Html Msg
errorView err =
  case err of
    Nothing ->
      text ""

    Just error ->
      div [ class "Tweets-error" ]
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
      "Unable to parse server response:" ++ errDescription

    Http.BadResponse errCode errDescription ->
      "Server returned " ++ ( toString errCode ) ++ ". " ++ errDescription
