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
    { submission = NotSent
    , tweetText = ""
    }



init : ( Model, Cmd Msg )
init = ( initialModel, Cmd.none)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LetterInput text ->
            ( { model | tweetText = text }, Cmd.none )

        SubmitButtonPressed ->
            case model.submission of
                NotSent ->
                    ( { model | submission = Sending model.tweetText }
                    , sendTweet model.tweetText
                    )

                otherwise ->
                    ( model, Cmd.none )

        TweetSend status ->
            case status of
                Success _ ->
                    ( { model | tweetText = "", submission = status }, resetTweetText 1800)

                Failure _ ->
                    ( { model | submission = status }, resetTweetText 4000)

                _ ->
                    ( { model | submission = status }, Cmd.none)



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Delay a few seconds and then return the value to 0
resetTweetText : Float -> Cmd Msg
resetTweetText time =
    Process.sleep time
        `Task.andThen` (\_ -> Task.succeed "")
        |> Task.perform never (\_ -> NotSent)
        |> Cmd.map TweetSend
