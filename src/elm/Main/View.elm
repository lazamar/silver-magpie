module Main.View exposing (..)

import Main.Types exposing (..)
import Main.LoginView
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html
import Routes.Timelines.View


view : Model -> Html Msg
view model =
    Maybe.map2
        (\c m -> Routes.Timelines.View.root c m)
        (List.head model.credentials)
        model.timelinesModel
        |> Maybe.map (Html.map TimelinesMsg)
        |> Maybe.withDefault (Main.LoginView.root model)
