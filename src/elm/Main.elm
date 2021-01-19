module Main exposing (..)

import Browser
import Json.Decode exposing (Value)
import Main.State exposing (Flags, init, subscriptions, update)
import Main.Types exposing (Model, Msg)
import Main.View exposing (view)



-- APP


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
