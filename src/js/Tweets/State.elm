module Tweets.State exposing ( init, update, subscriptions )

import Tweets.Rest exposing ( getTweets )
import Tweets.Types exposing (..)
import RemoteData exposing (..)
import Task
import Http


-- MAIN FUNCTIONS



initialModel : Model
initialModel =
    { tab = "home"
    , error = Nothing
    , tweets = NotAsked
    }



init : ( Model, Cmd Msg )
init = ( initialModel, getTweets initialModel.tab )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TweetFetch request ->
            case request of
                NotAsked ->
                    ( { model | tweets = Loading, error = Nothing }
                    , getTweets initialModel.tab
                    )

                Loading ->
                    ( { model | error = Nothing }, Cmd.none )

                Success tweetList ->
                    ( { model | tweets = Success tweetList }, Cmd.none )

                Failure err ->
                    ( { model | error = Just err }, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
