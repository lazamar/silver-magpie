module Tweets.View exposing (..)


import Tweets.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


root : Model -> Html Msg
root model = div [ class "Tweets"]
  [ text "Working! Oh yeah!"
  ]
