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
    , never
    )
import Task
import Process


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
            case status of
                Success _ ->
                    ( { model | newTweetText = status }, resetTweetText)

                Failure _ ->
                    ( { model | newTweetText = status }, Cmd.none)

                _ ->
                    ( { model | newTweetText = status }, Cmd.none)



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none




-- Delay a few seconds and then return the value to 0
resetTweetText : Cmd Msg
resetTweetText =
    Process.sleep 1800
        `Task.andThen` (\_ -> Task.succeed "")
        |> Task.perform never NotSent
        |> Cmd.map TweetSend
