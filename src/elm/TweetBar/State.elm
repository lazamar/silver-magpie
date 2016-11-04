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
import RemoteData exposing ( RemoteData )
import Task
import Process
import Regex
import String



initialModel : Model
initialModel =
    { submission = NotSent
    , tweetText = ""
    , handlerSuggestions =
        { handler = Nothing
        , users = RemoteData.NotAsked
        , userSelected = Nothing
        }
    }



init : ( Model, Cmd Msg, Cmd Main.Types.Msg )
init = ( initialModel, Cmd.none, Cmd.none)



hashtagRegex : Regex.Regex
hashtagRegex =
    -- matches @asdfasfd and has just one submatch which
    -- which is the handler part without the @
    Regex.regex "(?:^@|\\s@)(\\w{1,15})"



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Main.Types.Msg )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none, Cmd.none )

        LetterInput text ->
            let
                handlerMatch =
                    diffUsingPattern hashtagRegex model.tweetText text

                handlerText =
                    handlerMatch `Maybe.andThen` matchedText

                fetchCommand =
                    case handlerText of
                        Nothing ->
                            Cmd.none

                        Just handler ->
                            fetchHandlerSuggestion handler

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
                , fetchCommand
                , Cmd.none
                )

        SuggestedHandlersFetch handler fetchStatus ->
            let
                handlerSuggestions =
                    model.handlerSuggestions

                currentHandlerText =
                    handlerSuggestions.handler `Maybe.andThen` matchedText

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
                            replacement =
                                Maybe.map2
                                    (\users selected ->
                                        users
                                            |> List.drop selected
                                            |> List.head
                                    )
                                    (RemoteData.toMaybe handlerSuggestions.users)
                                    handlerSuggestions.userSelected
                                |> Maybe.withDefault Nothing
                                |> Maybe.map (\user -> user.screen_name)

                            newTweetText =
                                Maybe.map2
                                    (replaceHandler model.tweetText)
                                    handlerSuggestions.handler
                                    replacement
                                |> Maybe.withDefault model.tweetText

                        in
                            (   { model
                                | tweetText = newTweetText
                                , handlerSuggestions = initialModel.handlerSuggestions
                                }
                            , Cmd.none
                            , Cmd.none
                            )

                    EscKey ->
                        ( { model | handlerSuggestions = initialModel.handlerSuggestions }
                        , Cmd.none
                        , Cmd.none
                        )

                    _ ->
                        ( { model | handlerSuggestions = newHandlerSuggestions }
                        , Cmd.none
                        , Cmd.none
                        )

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
                    ( initialModel
                    , resetTweetText 1800
                    , Main.Global.refreshTweets
                    )

                Failure _ ->
                    ( { model | submission = status }, resetTweetText 4000, Cmd.none)

                _ ->
                    ( { model | submission = status }, Cmd.none, Cmd.none)

        RefreshTweets ->
            ( model, Cmd.none, Main.Global.refreshTweets)



replaceHandler : String -> Regex.Match -> String -> String
replaceHandler text match replacement =
    Regex.replace
        Regex.All
        hashtagRegex
        (\m ->
            if sameMatch m match then
                -- Replace just the handler from the match, not any
                -- spaces that my or may not exist before it
                Regex.replace
                    Regex.All
                    (Regex.regex "[^\\s@]+")
                    (\_ -> replacement)
                    m.match
            else
                m.match
        )
        text



sameMatch : Regex.Match -> Regex.Match -> Bool
sameMatch match1 match2 =
    match1.match == match2.match
    && match1.submatches == match2.submatches
    && match1.number == match2.number



removeFromString : String -> String -> String
removeFromString toRemove str =
    Regex.replace
        Regex.All
        ( Regex.regex ( Regex.escape toRemove ) )
        (\_ -> "")
        str



matchedText : Regex.Match -> Maybe String
matchedText match =
    List.head match.submatches
        -- This joins the Maybe(Maybe(val)) making it Maybe(val)
        |> Maybe.withDefault Nothing



diffUsingPattern : Regex.Regex -> String -> String -> Maybe Regex.Match
diffUsingPattern reg oldText newText =
    let
        oldMatches = Regex.find Regex.All reg oldText
        newMatches = Regex.find Regex.All reg newText
    in
        newMatches
            |> List.filter (\h ->  not <| List.member h oldMatches)
            |> List.head



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Delay a few seconds and then return the value to 0
resetTweetText : Float -> Cmd Msg
resetTweetText time =
    Process.sleep time
        `Task.andThen` Task.succeed
        |> Task.perform never (\_ -> TweetSend NotSent)
