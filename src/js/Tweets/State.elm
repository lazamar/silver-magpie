module Tweets.State exposing ( init, update, subscriptions )

import Tweets.Rest exposing ( getTweets )
import Tweets.Types exposing (..)
import RemoteData exposing (..)
import Task
import Http


-- MAIN FUNCTIONS



initialModel : Model
initialModel =
    { tab = HomeRoute
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

        ChangeRoute route ->
            ( { model | tab = route }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
