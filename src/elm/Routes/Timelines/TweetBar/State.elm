module Routes.Timelines.TweetBar.State exposing ( init, update, submitTweet, setReplyTweet )

import Routes.Timelines.TweetBar.Types exposing (..)
import Routes.Timelines.TweetBar.Rest exposing ( sendTweet, fetchHandlerSuggestion )
import Routes.Timelines.TweetBar.Handler as TwHandler exposing ( Handler, HandlerMatch )
import Routes.Timelines.TweetBar.View exposing ( inputFieldId )
import Twitter.Types exposing ( Credentials, User, Tweet )
import Generic.Utils exposing ( toCmd )
import Generic.LocalStorage
import Generic.Types exposing
    ( SubmissionData
        ( Success
        , Failure
        , Sending
        , NotSent
        )
    , never
    )
import RemoteData exposing ( RemoteData )
import Dom
import Task
import Process
import Regex
import String



emptySuggestions =
    { handler = Nothing
    , users = RemoteData.NotAsked
    , userSelected = Nothing
    }



emptyModel : Credentials -> Model
emptyModel credentials =
    { credentials = credentials
    , submission = NotSent
    , tweetText = ""
    , inReplyTo = Nothing
    , handlerSuggestions = emptySuggestions
    }



init : Credentials -> ( Model, Cmd Msg, Cmd Broadcast )
init credentials =
    let
        model =
            emptyModel credentials
                |> \m ->
                    { m | tweetText = getPersistedTweetText () }
    in
        ( model, Cmd.none, Cmd.none)



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Broadcast )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none, Cmd.none )

        LetterInput text ->
            let
                handlerMatch =
                    TwHandler.findChanged model.tweetText text

                handlerText =
                    handlerMatch `Maybe.andThen` TwHandler.matchedName

                fetchCommand =
                    case handlerText of
                        Nothing ->
                            Cmd.none

                        Just handler ->
                            fetchHandlerSuggestion model.credentials handler

                usersStatus =
                    case handlerMatch of
                        Nothing ->
                            RemoteData.NotAsked

                        Just handler ->
                            RemoteData.Loading

            in
                (   { model
                    | tweetText = text
                    , handlerSuggestions =
                        { handler = handlerMatch
                        , users = usersStatus
                        , userSelected = Nothing
                        }
                    }
                , Cmd.batch
                    [ fetchCommand
                    , persistTweetText text
                    ]
                , Cmd.none
                )

        SuggestedHandlersFetch handler fetchStatus ->
            let
                handlerSuggestions =
                    model.handlerSuggestions

                currentHandlerText =
                    handlerSuggestions.handler `Maybe.andThen` TwHandler.matchedName

            in
                -- If the users that arrived are for the handlers we are waiting for
                if Just handler == currentHandlerText then
                    (   { model
                        | handlerSuggestions =
                            { handlerSuggestions
                            | users = fetchStatus
                            , userSelected = Just 0
                            }
                        }
                    , Cmd.none
                    , Cmd.none
                    )

            else
                ( model, Cmd.none, Cmd.none )

        SuggestedHandlerSelected user ->
            ( selectUserSuggestion model user
            , Cmd.none
            , Cmd.none
            )

        SuggestedHandlersNavigation keyPressed ->
            let
                handlerSuggestions =
                    model.handlerSuggestions

                suggestionsCount =
                    handlerSuggestions.users
                        |> RemoteData.toMaybe
                        |> Maybe.map List.length

                userShift =
                    case keyPressed of
                        ArrowUp ->
                            -1

                        ArrowDown ->
                            1

                        _ ->
                            0

                newUserSelected =
                    handlerSuggestions.userSelected
                        |> Maybe.map (\x -> x + userShift)
                        |> Maybe.map2 (\x y -> y % x) suggestionsCount
                        |> Maybe.withDefault 0
                        |> Just

                newHandlerSuggestions =
                    { handlerSuggestions | userSelected = newUserSelected }

            in
                case keyPressed of
                    EnterKey ->
                        let
                            userSelected =
                                Maybe.map2
                                    (\users selected ->
                                        users
                                            |> List.drop selected
                                            |> List.head
                                    )
                                    (RemoteData.toMaybe handlerSuggestions.users)
                                    handlerSuggestions.userSelected
                                |> Maybe.withDefault Nothing

                            newModel =
                                userSelected
                                    |> Maybe.map (selectUserSuggestion model)
                                    |> Maybe.withDefault model
                        in
                            ( newModel
                            , Cmd.none
                            , Cmd.none
                            )

                    EscKey ->
                        ( { model | handlerSuggestions = emptySuggestions }
                        , Cmd.none
                        , Cmd.none
                        )

                    _ ->
                        ( { model | handlerSuggestions = newHandlerSuggestions }
                        , Cmd.none
                        , Cmd.none
                        )
        SetReplyTweet tweet ->
            ( { model
              | tweetText = "@" ++ tweet.user.screen_name ++ " "
              , inReplyTo = Just tweet
              , handlerSuggestions = emptySuggestions
              }
            ,  Dom.focus inputFieldId
                |> Task.perform (\_ -> DoNothing) (\_ -> DoNothing)
            , Cmd.none
            )

        SubmitTweet ->
            case model.submission of
                NotSent ->
                    ( { model | submission = Sending model.tweetText }
                    , sendTweet model.credentials model.inReplyTo model.tweetText
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none, Cmd.none )

        TweetSend status ->
            case status of
                Success _ ->
                    let
                        emptiedModel = emptyModel model.credentials
                    in
                    ( { emptiedModel | submission = status }
                    , Cmd.batch
                        [ resetTweetText 1800
                        , persistTweetText ""
                        ]
                    , toCmd RefreshTweets
                    )

                Failure _ ->
                    ( { model | submission = status }
                    , resetTweetText 3000
                    , Cmd.none
                    )

                _ ->
                    ( { model | submission = status }, Cmd.none, Cmd.none)



selectUserSuggestion : Model -> User -> Model
selectUserSuggestion model user =
    case model.handlerSuggestions.handler of
        Nothing ->
            model

        Just handlerMatch ->
            TwHandler.replaceMatch
            model.tweetText
            handlerMatch
            user.screen_name
                |> \newTweetText ->
                    { model
                    | tweetText = newTweetText
                    , handlerSuggestions = emptySuggestions
                    }


-- Delay a few seconds and then return the value to 0
resetTweetText : Float -> Cmd Msg
resetTweetText time =
    Task.perform
        never
        (\_ -> let t = Debug.log "NOw!" "now" in TweetSend NotSent)
        ( Task.andThen (Process.sleep time) (Task.succeed) )


persistTweetText : String -> Cmd Msg
persistTweetText text =
    Generic.LocalStorage.setItem "TweetText" text
        |> \_ -> Cmd.none



getPersistedTweetText : () -> String
getPersistedTweetText _ =
    Generic.LocalStorage.getItem "TweetText"
        |> Maybe.withDefault ""


-- Public
submitTweet : Model -> ( Model, Cmd Msg, Cmd Broadcast )
submitTweet =
    update SubmitTweet

-- Public
setReplyTweet : Model -> Tweet -> ( Model, Cmd Msg, Cmd Broadcast )
setReplyTweet model tweet =
    update ( SetReplyTweet tweet ) model
