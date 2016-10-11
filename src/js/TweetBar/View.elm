module TweetBar.View exposing (..)


import TweetBar.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Generic.Types exposing (..)
import String


root : Model -> Html Msg
root model = div [ class "TweetBar"]
  [ div [ class "TweetBar-actions" ]
    [ button [ class "zmdi zmdi-mail-send TweetBar-sendBtn btn btn-default btn-icon" ] []
    ]
  , inputBoxView model
  ]


inputBoxView : Model -> Html Msg
inputBoxView model =
    case model.newTweetText of
        NotSent tweetText ->
            div [ class "TweetBar-textBox" ]
                [ span
                      [ class "TweetBar-textBox-charCount" ]
                      [ remainingCharacters tweetText ]
                , textarea
                      [ class "TweetBar-textBox-input"
                      , onInput LetterInput
                      ] []
                ]

        otherwise ->
            div [] [ text "Something else is going on." ]


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
