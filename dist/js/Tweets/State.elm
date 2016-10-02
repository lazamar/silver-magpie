module Tweets.State exposing ( init, update, subscriptions )
import Tweets.Types exposing (..)


initialModel : Model
initialModel = { user = "anonymous" }


init : ( Model, Cmd Msg )
init = ( initialModel, Cmd.none)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
