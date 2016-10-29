module TweetBar.State exposing ( init, update, subscriptions )


import Main.Global
import Main.Types
import TweetBar.Rest exposing ( sendTweet, fetchHandlerSuggestion )
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
import RemoteData exposing ( RemoteData ( NotAsked ) )
import Task
import Process
import Regex
import String



initialModel : Model
initialModel =
    { submission = NotSent
    , tweetText = ""
    , suggestedHandlers = NotAsked
    }



init : ( Model, Cmd Msg, Cmd Main.Types.Msg )
init = ( initialModel, Cmd.none, Cmd.none)



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Main.Types.Msg )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none, Cmd.none )

        LetterInput text ->
            let
                handlerBeingTyped =
                    diffUsingPattern (Regex.regex "(^@|\\s@)(\\w){1,15}") model.tweetText text
                        |> Maybe.map ( removeFromString "@" )
                        |> Maybe.map ( removeFromString " " )

                suggestionCommand =
                    case handlerBeingTyped of
                        Nothing ->
                            Cmd.none

                        Just handler ->
                            fetchHandlerSuggestion handler
            in
                ( { model | tweetText = text }, suggestionCommand, Cmd.none )

        SuggestedHandlersFetch fetchStatus ->
            ( { model | suggestedHandlers = fetchStatus }, Cmd.none, Cmd.none )

        SubmitTweet ->
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
                    ( { model | tweetText = "", submission = status, suggestedHandlers = NotAsked }
                    , resetTweetText 1800
                    , Main.Global.refreshTweets
                    )

                Failure _ ->
                    ( { model | submission = status }, resetTweetText 4000, Cmd.none)

                _ ->
                    ( { model | submission = status }, Cmd.none, Cmd.none)

        RefreshTweets ->
            ( model, Cmd.none, Main.Global.refreshTweets)



removeFromString : String -> String -> String
removeFromString toRemove str =
    Regex.replace
        Regex.All
        ( Regex.regex ( Regex.escape toRemove ) )
        (\_ -> "")
        str



diffUsingPattern : Regex.Regex -> String -> String -> Maybe String
diffUsingPattern reg oldText newText =
    let
        oldMatches = getMatches reg oldText
        newMatches = getMatches reg newText
    in
        newMatches
            |> List.filter (\h ->  not <| List.member h oldMatches)
            |> List.head



getMatches : Regex.Regex -> String -> List String
getMatches reg text =
    Regex.find Regex.All reg text
        |> List.map (\match -> match.match)



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Delay a few seconds and then return the value to 0
resetTweetText : Float -> Cmd Msg
resetTweetText time =
    Process.sleep time
        `Task.andThen` Task.succeed
        |> Task.perform never (\_ -> TweetSend NotSent)
