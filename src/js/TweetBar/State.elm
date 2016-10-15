module TweetBar.State exposing ( init, update, subscriptions )


import TweetBar.Rest exposing ( sendTweet )
import TweetBar.Types exposing (..)
import Generic.Types exposing
    ( SubmissionData
        ( Success
        , Failure
        , Sending
        , NotSent
        )
    )



initialModel : Model
initialModel =
    { newTweetText = NotSent ""
    }



init : ( Model, Cmd Msg )
init = ( initialModel, Cmd.none)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LetterInput text ->
            ( { model | newTweetText = NotSent text }, Cmd.none )

        SubmitButtonPressed ->
            case model.newTweetText of
                NotSent text ->
                    ( { model | newTweetText = Sending text }, sendTweet text )

                otherwise ->
                    ( model, Cmd.none )

        TweetSend status ->
            ( { model | newTweetText = status }, Cmd.none)



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
