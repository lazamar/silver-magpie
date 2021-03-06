module Timelines.TweetBar.State exposing (init, setReplyTweet, submitTweet, update)

import Browser.Dom
import Generic.LocalStorage
import Generic.Types
    exposing
        ( SubmissionData(..)
        )
import Generic.Utils exposing (toCmd)
import Process
import Regex
import RemoteData exposing (RemoteData)
import String
import Task
import Timelines.TweetBar.Handler as TwHandler exposing (Handler, HandlerMatch)
import Timelines.TweetBar.Rest exposing (fetchHandlerSuggestion, sendTweet)
import Timelines.TweetBar.Types exposing (..)
import Timelines.TweetBar.View exposing (inputFieldId)
import Twitter.Types exposing (Credential, Tweet, User)


emptySuggestions =
    { handler = Nothing
    , users = RemoteData.NotAsked
    , userSelected = Nothing
    }


emptyModel : String -> Model
emptyModel savedText =
    { submission = NotSent
    , tweetText = savedText
    , inReplyTo = Nothing
    , handlerSuggestions = emptySuggestions
    }


init : String -> Config msg -> ( Model, Cmd msg )
init savedText config =
    ( emptyModel savedText
    , Cmd.none
    )


update : Msg -> Config msg -> Credential -> Model -> ( Model, Cmd msg )
update msg conf credential model =
    case msg of
        DoNothing ->
            ( model, Cmd.none )

        LetterInput text ->
            let
                handlerMatch =
                    TwHandler.findChanged model.tweetText text

                handlerText =
                    handlerMatch |> Maybe.andThen TwHandler.matchedName

                fetchCommand =
                    case handlerText of
                        Nothing ->
                            Cmd.none

                        Just handler ->
                            fetchHandlerSuggestion credential handler

                usersStatus =
                    case handlerMatch of
                        Nothing ->
                            RemoteData.NotAsked

                        Just handler ->
                            RemoteData.Loading
            in
            ( { model
                | tweetText = text
                , handlerSuggestions =
                    { handler = handlerMatch
                    , users = usersStatus
                    , userSelected = Nothing
                    }
              }
            , Cmd.batch
                [ Cmd.map conf.onUpdate fetchCommand
                , toCmd <| conf.storeTweetText credential text
                ]
            )

        SuggestedHandlersFetch handler fetchStatus ->
            let
                handlerSuggestions =
                    model.handlerSuggestions

                currentHandlerText =
                    handlerSuggestions.handler
                        |> Maybe.andThen TwHandler.matchedName
            in
            -- If the users that arrived are for the handlers we are waiting for
            if Just handler == currentHandlerText then
                ( { model
                    | handlerSuggestions =
                        { handlerSuggestions
                            | users = fetchStatus
                            , userSelected = Just 0
                        }
                  }
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        SuggestedHandlerSelected user ->
            ( selectUserSuggestion model user, Cmd.none )

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
                        |> Maybe.map2 (\x y -> modBy x y) suggestionsCount
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
                    ( newModel, Cmd.none )

                EscKey ->
                    ( { model | handlerSuggestions = emptySuggestions }, Cmd.none )

                _ ->
                    ( { model | handlerSuggestions = newHandlerSuggestions }, Cmd.none )

        SetReplyTweet tweet ->
            ( { model
                | tweetText = "@" ++ tweet.user.screen_name ++ " "
                , inReplyTo = Just tweet
                , handlerSuggestions = emptySuggestions
              }
            , Browser.Dom.focus inputFieldId
                |> Task.attempt (\_ -> conf.onUpdate DoNothing)
            )

        SubmitTweet ->
            case model.submission of
                NotSent ->
                    ( { model | submission = Sending model.tweetText }
                    , sendTweet credential model.inReplyTo model.tweetText
                        |> Cmd.map conf.onUpdate
                    )

                otherwise ->
                    ( model, Cmd.none )

        TweetSend status ->
            case status of
                Success _ ->
                    let
                        newModel =
                            emptyModel ""
                    in
                    ( { newModel | submission = status }
                    , Cmd.batch
                        [ resetTweetText 1800 |> Cmd.map conf.onUpdate
                        , toCmd <| conf.storeTweetText credential ""
                        , toCmd conf.onRefreshTweets
                        ]
                    )

                Failure _ ->
                    ( { model | submission = status }
                    , resetTweetText 3000
                        |> Cmd.map conf.onUpdate
                    )

                _ ->
                    ( { model | submission = status }, Cmd.none )


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
                |> (\newTweetText ->
                        { model
                            | tweetText = newTweetText
                            , handlerSuggestions = emptySuggestions
                        }
                   )



-- Delay a few seconds and then return the value to 0


resetTweetText : Float -> Cmd Msg
resetTweetText time =
    Task.attempt (\_ -> TweetSend NotSent) (Process.sleep time)



-- Public


submitTweet : Config msg -> Credential -> Model -> ( Model, Cmd msg )
submitTweet =
    update SubmitTweet



-- Public
-- TODO: This should be in the parent


setReplyTweet : Config msg -> Credential -> Model -> Tweet -> ( Model, Cmd msg )
setReplyTweet conf credential model tweet =
    update (SetReplyTweet tweet) conf credential model
