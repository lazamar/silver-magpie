module Main exposing (..)

import Main.Types exposing (Model, Msg)
import Main.State exposing (init, subscriptions, update)
import Main.View exposing (view)
import Html


-- APP


main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
