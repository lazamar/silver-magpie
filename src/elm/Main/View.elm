module Main.View exposing (..)

import Main.State exposing (credentialInUse)
import Main.Types exposing (..)
import Main.LoginView
import Twitter.Types exposing (Credential)
import Timelines.View
import Generic.Utils exposing (tooltip)
import List.Extra
import Html exposing (Html, div, button, text, span)
import Html.Attributes exposing (class, tabindex)
import Html.Events exposing (onClick)
import Twitter.Types exposing (Credential)
import Html


view : Model -> Html Msg
view model =
    let
        footer =
            credentialInUse model
                |> Maybe.map (footerView model.footerMessageNumber)
                |> Maybe.withDefault (div [] [])
    in
        case timelinesView model of
            Nothing ->
                Main.LoginView.root model

            Just aView ->
                div [ class "Main" ]
                    [ aView
                    , footer
                    ]


timelinesView : Model -> Maybe (Html Msg)
timelinesView model =
    model.timelinesModel
        |> Maybe.map (\m -> Timelines.View.root m)
        |> Maybe.map (Html.map TimelinesMsg)


footerView : Int -> Credential -> Html Msg
footerView footerMessageNumber credential =
    div [ class "Timelines-footer" ]
        [ button
            [ class "zmdi zmdi-collection-item btn btn-default btn-icon"
            , tooltip "Detach window"
            , tabindex -1
            , onClick Detach
            ]
            []
        , span
            [ class "Timelines-footer-cues animated fadeInUp" ]
            [ text <| footerMessage footerMessageNumber ]
        , button
            [ class "zmdi zmdi-power btn btn-default btn-icon"
            , tabindex -1
            , tooltip "Logout"
            , onClick <| Logout credential
            ]
            []
        ]


footerMessage : Int -> String
footerMessage seed =
    let
        messagesLength =
            List.length footerMessages

        msgNumber =
            seed % messagesLength
    in
        List.Extra.getAt msgNumber footerMessages
            |> Maybe.withDefault ""


footerMessages =
    [ "Press Tab to navigate the timeline using the arrow keys :)"
    , "You can open Silver Magpie with Ctrl+Alt+1"
    , "Use Ctrl+Enter to send your tweet"
    , "Use arrows to navigate handler suggestions"
    ]
