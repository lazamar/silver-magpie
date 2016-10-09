module TweetBar.View exposing (..)


import TweetBar.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

root : Model -> Html Msg
root model = div [ class "TweetBar"]
  [ div [ class "TweetBar-actions" ]
    [ button [ class "zmdi zmdi-mail-send TweetBar-sendBtn btn btn-default btn-icon" ] []
    ]
  , div [ class "TweetBar-textBox" ]
      [ span
            [ class "TweetBar-textBox-charCount" ]
            [ remainingCharacters model.newTweetText ]
      , textarea
            [ class "TweetBar-textBox-input"
            , onInput LetterInput
            ] []
      ]
  ]

remainingCharacters : String -> Html Msg
remainingCharacters tweetText =
    let
        remaining = 140 - ( String.length tweetText )
        remainingText =
            remaining
                |> toString
                |> text
    in
        if remaining >= 50 then
            span [ class "enough" ] [ remainingText ]

        else if remaining > 10 then
            span [ class "quite-a-few" ] [ remainingText ]

        else if remaining >= 0 then
            span [ class "few-left" ] [ remainingText ]

        else
            span [ class "too-much" ] [ remainingText ]
