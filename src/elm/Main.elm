module Main exposing (..)

import Main.State exposing (init, subscriptions, update)
import Main.View exposing (view)
import Html.App


-- APP


main : Program Never
main =
    Html.App.program
        { init = init ()
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
