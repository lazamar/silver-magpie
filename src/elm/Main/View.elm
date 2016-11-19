module Main.View exposing (..)

import Main.Types exposing ( Msg (..), Model (..) )
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.App

import Routes.Timelines.View
import Routes.Login.View


view : Model -> Html Msg
view modelRoute =
    case modelRoute of
        LoginRoute model ->
            Html.div [ class "Main"]
                [ Routes.Login.View.root model
                    |> Html.App.map LoginMsgLocal
                ]

        TimelinesRoute model ->
            Html.div [ class "Main"]
                [ Routes.Timelines.View.root model
                    |> Html.App.map TimelinesMsgLocal
                ]
