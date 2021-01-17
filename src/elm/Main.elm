module Main exposing (..)

import Browser
import Main.State exposing (init, subscriptions, update)
import Main.Types exposing (Model, Msg)
import Main.View exposing (view)



-- APP


main : Program ( Int, Int ) Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
