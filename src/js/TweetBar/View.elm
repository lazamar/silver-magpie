module TweetBar.View exposing (..)


import TweetBar.Types exposing (..)
import Generic.Utils exposing ( errorMessage )
import Generic.Types exposing
    ( SubmissionData
        ( NotSent
        , Sending
        , Success
        , Failure
        )
    )

import String
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import TweetBar.Animations


root : Model -> Html Msg
root model =
    case model.newTweetText of
        NotSent tweetText ->
            div [ class "TweetBar"]
                [ actionBar
                , inputBoxView tweetText
                ]

        Sending _ ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ TweetBar.Animations.twistingCircle ]
                ]

        Success _ ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ TweetBar.Animations.tick ]
                ]

        Failure error ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading--failure" ]
                    [ text ( errorMessage error ) ]
                ]



actionBar : Html Msg
actionBar =
    div [ class "TweetBar-actions" ]
        [ button
            [ class "zmdi zmdi-mail-send TweetBar-sendBtn btn btn-default btn-icon"
            , onClick SubmitButtonPressed
            ] []
        ]



inputBoxView : String -> Html Msg
inputBoxView tweetText =
    div [ class "TweetBar-textBox" ]
        [ span
              [ class "TweetBar-textBox-charCount" ]
              [ remainingCharacters tweetText ]
        , textarea
              [ class "TweetBar-textBox-input"
              , onInput LetterInput
              ] []
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
