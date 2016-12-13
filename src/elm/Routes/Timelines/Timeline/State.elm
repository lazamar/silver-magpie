module Routes.Timelines.Timeline.State exposing (init, update, refreshTweets)

import Routes.Timelines.Timeline.Rest exposing (getTweets, favoriteTweet, doRetweet)
import Routes.Timelines.Timeline.Types exposing (..)
import Twitter.Types exposing (Tweet, Retweet, Credential)
import Twitter.Serialisers
import Twitter.Deserialisers
import Generic.Utils exposing (toCmd)
import Generic.LocalStorage
import Main.Types
import RemoteData exposing (..)
import List.Extra
import Json.Encode
import Json.Decode
import Task
import Http
import Process
import Time


-- MAIN FUNCTIONS


initialModel : Model
initialModel =
    { tab = HomeTab
    , homeTab =
        { tweets = getPersistedTimeline HomeTab
        , newTweets = NotAsked
        }
    , mentionsTab =
        { tweets = getPersistedTimeline MentionsTab
        , newTweets = NotAsked
        }
    }


init : Config msg -> ( Model, Cmd msg )
init conf =
    ( initialModel
    , Cmd.batch
        [ toCmd (FetchTweets HomeTab Refresh)
        , toCmd (FetchTweets MentionsTab Refresh)
        ]
        |> Cmd.map conf.onUpdate
    )



-- UPDATE


update : Msg -> Config msg -> Credential -> Model -> ( Model, Cmd msg )
update msg conf credential model =
    case msg of
        DoNothing ->
            ( model, Cmd.none )

        FetchTweets tabName fetchType ->
            let
                tabBeingFetched =
                    getModelTab tabName model
            in
                ( updateModelTab tabName model { tabBeingFetched | newTweets = Loading }
                , getTweets credential fetchType tabName
                    |> Cmd.map conf.onUpdate
                )

        TweetFetch route fetchType request ->
            let
                routeTab =
                    case route of
                        HomeTab ->
                            model.homeTab

                        MentionsTab ->
                            model.mentionsTab
            in
                case request of
                    Success newTweets ->
                        ( updateModelTab route
                            model
                            { routeTab
                                | tweets = combineTweets fetchType routeTab.tweets newTweets
                                , newTweets = NotAsked
                            }
                        , persistTimeline route newTweets
                            |> Cmd.map conf.onUpdate
                        )

                    Failure (Http.BadStatus { status }) ->
                        let
                            newModel =
                                updateModelTab route model { routeTab | newTweets = request }
                        in
                            if status.code == 401 then
                                ( newModel
                                , toCmd <| conf.onLogout credential
                                )
                            else
                                ( newModel
                                , resetTweetFetch route fetchType 3000
                                    |> Cmd.map conf.onUpdate
                                )

                    Failure _ ->
                        ( updateModelTab route model { routeTab | newTweets = request }
                        , resetTweetFetch route fetchType 3000
                            |> Cmd.map conf.onUpdate
                        )

                    _ ->
                        ( updateModelTab route model { routeTab | newTweets = request }
                        , Cmd.none
                        )

        ChangeTab newRoute ->
            -- TODO: Conditionally reload this
            update DoNothing conf credential { model | tab = newRoute }

        Favorite shouldFavorite tweetId ->
            let
                currentTab =
                    getModelTab model.tab model
            in
                ( updateModelTab model.tab
                    model
                    { currentTab
                        | tweets = registerFavorite shouldFavorite tweetId currentTab.tweets
                    }
                , favoriteTweet credential shouldFavorite tweetId
                    |> Cmd.map conf.onUpdate
                )

        DoRetweet shouldRetweet tweetId ->
            let
                currentTab =
                    getModelTab model.tab model
            in
                ( updateModelTab model.tab
                    model
                    { currentTab
                        | tweets = registerRetweet shouldRetweet tweetId currentTab.tweets
                    }
                , doRetweet credential shouldRetweet tweetId
                    |> Cmd.map conf.onUpdate
                )

        SubmitTweet ->
            ( model
            , toCmd conf.onSubmitTweet
            )

        SetReplyTweet tweet ->
            ( model
            , toCmd (conf.onSetReplyTweet tweet)
            )


updateModelTab : TabName -> Model -> Tab -> Model
updateModelTab tabName model tab =
    case tabName of
        HomeTab ->
            { model | homeTab = tab }

        MentionsTab ->
            { model | mentionsTab = tab }


getModelTab : TabName -> Model -> Tab
getModelTab tabName model =
    case tabName of
        HomeTab ->
            model.homeTab

        MentionsTab ->
            model.mentionsTab


registerFavorite : Bool -> String -> List Tweet -> List Tweet
registerFavorite toFavorite tweetId tweetList =
    let
        tweetUpdate tweet =
            if tweet.id == tweetId && xor tweet.favorited toFavorite then
                { tweet
                    | favorite_count =
                        tweet.favorite_count
                            + if toFavorite then
                                1
                              else
                                -1
                    , favorited = toFavorite
                }
            else
                tweet
    in
        List.map (applyToRelevantTweet tweetUpdate) tweetList


registerRetweet : Bool -> String -> List Tweet -> List Tweet
registerRetweet shouldRetweet tweetId tweetList =
    let
        tweetUpdate tweet =
            if tweet.id == tweetId && xor tweet.retweeted shouldRetweet then
                { tweet
                    | retweet_count =
                        tweet.retweet_count
                            + if shouldRetweet then
                                1
                              else
                                -1
                    , retweeted = shouldRetweet
                }
            else
                tweet
    in
        List.map (applyToRelevantTweet tweetUpdate) tweetList



-- Applies a function on a tweet or, if it has a retweet in its retweet


applyToRelevantTweet : (Tweet -> Tweet) -> Tweet -> Tweet
applyToRelevantTweet func tweet =
    case tweet.retweeted_status of
        Nothing ->
            func tweet

        Just (Twitter.Types.Retweet rt) ->
            { tweet
                | retweeted_status =
                    func rt
                        |> Twitter.Types.Retweet
                        |> Just
            }


combineTweets : FetchType -> List Tweet -> List Tweet -> List Tweet
combineTweets fetchType oldTweets newTweets =
    case fetchType of
        Refresh ->
            newTweets

        BottomTweets lastTweetIdAtFetchTime ->
            List.Extra.last oldTweets
                |> Maybe.map
                    (\lastTweetNow ->
                        let
                            tweetListChangedSinceFetch =
                                lastTweetIdAtFetchTime /= lastTweetNow.id
                        in
                            if tweetListChangedSinceFetch then
                                oldTweets
                            else
                                List.concat [ oldTweets, newTweets ]
                    )
                -- We set the default to newtweets because if oldTweets does not
                -- have a last element, we are basically performing a refresh.
                |>
                    Maybe.withDefault newTweets


resetTweetFetch : TabName -> FetchType -> Float -> Cmd Msg
resetTweetFetch route fetchType time =
    Process.sleep time
        |> Task.attempt (\_ -> TweetFetch route fetchType NotAsked)



-- Public


refreshTweets : Config msg -> Credential -> Model -> ( Model, Cmd msg )
refreshTweets conf credential model =
    update (FetchTweets model.tab Refresh) conf credential model



-- Saves timeline to local storage


persistTimeline : TabName -> List Tweet -> Cmd Msg
persistTimeline route tweetList =
    tweetList
        |> List.map Twitter.Serialisers.serialiseTweet
        |> Json.Encode.list
        |> Json.Encode.encode 2
        |> Generic.LocalStorage.setItem ("Timeline-" ++ (toString route))
        |> \_ -> Cmd.none


getPersistedTimeline : TabName -> List Tweet
getPersistedTimeline route =
    let
        storageContent =
            Generic.LocalStorage.getItem ("Timeline-" ++ (toString route))
                |> Maybe.withDefault ""
                |> Json.Decode.decodeString
                    (Json.Decode.list Twitter.Deserialisers.deserialiseTweet)
    in
        case storageContent of
            Ok tweets ->
                tweets

            Err _ ->
                []
