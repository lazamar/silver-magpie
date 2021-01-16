module Main exposing (..)

import Html
import Main.State exposing (init, subscriptions, update)
import Main.Types exposing (Model, Msg)
import Main.View exposing (view)



-- APP


main : Program Never Model Msg
main =
    Html.program
        { init = init ()
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
