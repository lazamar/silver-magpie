module TweetBar.State exposing ( init, update, subscriptions )


import Main.Global
import Main.Types
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



init : ( Model, Cmd Msg, Cmd Main.Types.Msg )
init = ( initialModel, Cmd.none, Cmd.none)



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Main.Types.Msg )
update msg model =
    case msg of
        LetterInput text ->
            ( { model | tweetText = text }, Cmd.none, Cmd.none )

        SubmitButtonPressed ->
            case model.submission of
                NotSent ->
                    ( { model | submission = Sending model.tweetText }
                    , sendTweet model.tweetText
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none, Cmd.none )

        TweetSend status ->
            case status of
                Success _ ->
                    ( { model | tweetText = "", submission = status }
                    , resetTweetText 1800
                    , Cmd.none
                    )

                Failure _ ->
                    ( { model | submission = status }, resetTweetText 4000, Cmd.none)

                _ ->
                    ( { model | submission = status }, Cmd.none, Cmd.none)

        RefreshTweets ->
            ( model, Cmd.none, Main.Global.loadMoreTweets)



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Delay a few seconds and then return the value to 0
resetTweetText : Float -> Cmd Msg
resetTweetText time =
    Process.sleep time
        `Task.andThen` Task.succeed
        |> Task.perform never (\_ -> TweetSend NotSent)
