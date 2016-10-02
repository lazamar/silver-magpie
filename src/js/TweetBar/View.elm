module TweetBar.View exposing (..)


import TweetBar.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


root : Model -> Html Msg
root model = div [ class "TweetBar"]
  [ button [ class "zmdi zmdi-mail-send" ] [ ]
  ]
