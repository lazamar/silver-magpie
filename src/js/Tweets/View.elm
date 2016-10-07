module Tweets.View exposing (..)


import Tweets.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


root : Model -> Html Msg
root model =
  div [ class "Tweets"]
    [ tweetListView model.tweets ]

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
