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
    , tweets = Loading
    }



init : ( Model, Cmd Msg )
init = ( initialModel, getTweets initialModel.tab )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TweetFetch request ->
            ( { model | tweets = request }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
