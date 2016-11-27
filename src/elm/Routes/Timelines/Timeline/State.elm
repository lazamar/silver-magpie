module Routes.Timelines.Timeline.State exposing ( init, update, refreshTweets )

import Routes.Timelines.Timeline.Rest exposing ( getTweets, favoriteTweet, doRetweet )
import Routes.Timelines.Timeline.Types exposing (..)
import Twitter.Types exposing ( Tweet, Retweet, Credentials )
import Twitter.Serialisers
import Twitter.Deserialisers
import Generic.Types exposing (never)
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


-- MAIN FUNCTIONS



initialModel : Credentials -> Model
initialModel credentials =
    { credentials = credentials
    , tab = HomeTab
    , homeTab =
        { tweets = getPersistedTimeline HomeTab
        , newTweets = NotAsked
        }
    , mentionsTab =
        { tweets = getPersistedTimeline MentionsTab
        , newTweets = NotAsked
        }
    }



init : Credentials -> ( Model, Cmd Msg, Cmd Broadcast )
init credentials =
    ( initialModel credentials
    , Cmd.none
    -- FIXME: Uncomment this
    -- , Cmd.batch
    --     [ toCmd ( FetchTweets HomeTab Refresh )
    --     , toCmd ( FetchTweets MentionsTab Refresh )
    --     ]
    , Cmd.none
    )



-- UPDATE



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Broadcast )
update msg model =
    let
        currentTab =
            getModelTab model.tab model
    in
    case msg of
        DoNothing ->
            ( model, Cmd.none, Cmd.none )

        FetchTweets route fetchType ->
            ( updateModelTab route model { currentTab | newTweets = Loading }
            , getTweets model.credentials fetchType model.tab
            , Cmd.none
            )


        TweetFetch route fetchType request ->
            let
                routeTab = case route of
                    HomeTab ->
                        model.homeTab

                    MentionsTab ->
                        model.mentionsTab
            in
                case request of
                    Success newTweets ->
                        ( updateModelTab route model
                            { routeTab
                            | tweets = combineTweets fetchType routeTab.tweets newTweets
                            , newTweets = NotAsked
                            }
                        , persistTimeline route newTweets
                        , Cmd.none
                        )

                    Failure ( Http.BadResponse 401 _ )->
                        ( updateModelTab route model { routeTab | newTweets = request }
                        , Cmd.none
                        , toCmd Logout
                        )

                    Failure _ ->
                        ( updateModelTab route model { routeTab | newTweets = request }
                        , resetTweetFetch route fetchType 3000
                        , Cmd.none
                        -- , resetTweetFetch fetchType 3000
                        )

                    _ ->
                        ( updateModelTab route model { routeTab | newTweets = request }
                        , Cmd.none
                        , Cmd.none
                        )

        ChangeTab newRoute ->
            -- FIXME: Conditionally reload this
            update DoNothing { model | tab = newRoute }

        Favorite shouldFavorite tweetId ->
            ( updateModelTab model.tab model
                { currentTab
                | tweets = registerFavorite shouldFavorite tweetId currentTab.tweets
                }
            , favoriteTweet model.credentials shouldFavorite tweetId
            , Cmd.none
            )

        DoRetweet shouldRetweet tweetId ->
            ( updateModelTab model.tab model
                { currentTab
                | tweets = registerRetweet shouldRetweet tweetId currentTab.tweets
                }
            , doRetweet model.credentials shouldRetweet tweetId
            , Cmd.none
            )

        MsgLogout ->
            ( model
            , Cmd.none
            , toCmd Logout
            )

        MsgSubmitTweet ->
            ( model
            , Cmd.none
            , toCmd SubmitTweet
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
                | favorite_count = tweet.favorite_count + if toFavorite then 1 else -1
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
                | retweet_count = tweet.retweet_count + if shouldRetweet then 1 else -1
                , retweeted = shouldRetweet
                }
            else
                tweet
    in
        List.map (applyToRelevantTweet tweetUpdate) tweetList



-- Applies a function on a tweet or, if it has a retweet in its retweet
applyToRelevantTweet : ( Tweet -> Tweet ) -> Tweet -> Tweet
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



combineTweets : FetchType -> (List Tweet) -> (List Tweet) -> (List Tweet)
combineTweets fetchType oldTweets newTweets =
      case fetchType of
          Refresh ->
              newTweets

          BottomTweets lastTweetIdAtFetchTime->
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
                |> Maybe.withDefault newTweets



resetTweetFetch : TabName -> FetchType -> Float -> Cmd Msg
resetTweetFetch route fetchType time =
    Process.sleep time
        |> Task.perform never (\_ -> TweetFetch route fetchType NotAsked)



-- Public
refreshTweets : Model -> ( Model, Cmd Msg, Cmd Broadcast )
refreshTweets =
    update ( FetchTweets HomeTab Refresh )



-- Saves timeline to local storage
persistTimeline : TabName -> List Tweet -> Cmd Msg
persistTimeline route tweetList =
    tweetList
        |> List.map Twitter.Serialisers.serialiseTweet
        |> Json.Encode.list
        |> Json.Encode.encode 2
        |> Generic.LocalStorage.setItem ( "Timeline-" ++ ( toString route ) )
        |> \_ -> Cmd.none



getPersistedTimeline : TabName -> List Tweet
getPersistedTimeline route =
    let
        storageContent =
            Generic.LocalStorage.getItem ( "Timeline-" ++ ( toString route ) )
                |> Maybe.withDefault ""
                |> Json.Decode.decodeString
                    (Json.Decode.list Twitter.Deserialisers.deserialiseTweet )
    in
        case storageContent of
            Ok tweets ->
                tweets

            Err _ ->
                []
