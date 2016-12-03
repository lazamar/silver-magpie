module Main.View exposing (..)

import Main.Types exposing (Msg(..), Model(..))
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.App
import Routes.Timelines.View
import Routes.Login.View


view : Model -> Html Msg
view modelRoute =
    case modelRoute of
        LoginRoute model ->
            Routes.Login.View.root model
                |> Html.App.map LoginMsg

        TimelinesRoute model ->
            Routes.Timelines.View.root model
                |> Html.App.map TimelinesMsg
