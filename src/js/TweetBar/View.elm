module TweetBar.View exposing (..)


import TweetBar.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


root : Model -> Html Msg
root model = div [ class "TweetBar"]
  [ div [ class "TweetBar-actions" ]
    [ button [ class "zmdi zmdi-mail-send TweetBar-sendBtn btn btn-default btn-icon" ] [ ]
    ]
  , div [ class "TweetBar-textBox" ]
      [ span [ class "TweetBar-textBox-charCount" ] [ text "140" ]
      , textarea [ class "TweetBar-textBox-input" ] [ ]
      ]
  ]
