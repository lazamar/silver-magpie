module Main.View exposing (..)

import Main.Types exposing (..)
import Main.LoginView
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html
import Routes.Timelines.View


view : Model -> Html Msg
view model =
    case model.timelinesModel of
        Nothing ->
            Main.LoginView.root model

        Just timelinesModel ->
            Routes.Timelines.View.root timelinesModel
                |> Html.map TimelinesMsg
