module Main.View exposing (..)

import Main.State exposing (credentialInUse)
import Main.Types exposing (..)
import Main.LoginView
import Twitter.Types exposing (Credential)
import Timelines.View
import Generic.Utils exposing (tooltip)
import List.Extra
import Html exposing (Html, div, button, text, span, img)
import Html.Attributes exposing (class, tabindex, src)
import Html.Events exposing (onClick)
import Twitter.Types exposing (Credential)
import Html


view : Model -> Html Msg
view model =
    case timelinesView model of
        Nothing ->
            Main.LoginView.root model

        Just aView ->
            div [ class "Main" ]
                [ aView
                , footerView model.footerMessageNumber model.usersDetails
                ]


timelinesView : Model -> Maybe (Html Msg)
timelinesView model =
    model.timelinesModel
        |> Maybe.map (\m -> Timelines.View.root m)
        |> Maybe.map (Html.map TimelinesMsg)


footerView : Int -> List UserDetails -> Html Msg
footerView footerMessageNumber usersDetails =
    let
        currentCredential =
            credentialInUse usersDetails
                |> Maybe.withDefault ""

        -- TODO Remove this
    in
        div [ class "Main-footer" ]
            [ button
                [ class "zmdi zmdi-collection-item btn btn-default btn-icon"
                , tooltip "Detach window"
                , tabindex -1
                , onClick Detach
                ]
                []
            , span
                [ class "Main-footer-accounts" ]
                (accountsView usersDetails)
              -- , span
              --     [ class "Timelines-footer-cues animated fadeInUp" ]
              --     [ text <| footerMessage footerMessageNumber ]
            , button
                [ class "zmdi zmdi-power btn btn-default btn-icon"
                , tabindex -1
                , tooltip "Logout"
                , onClick <| Logout currentCredential
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


accountsView : List UserDetails -> List (Html Msg)
accountsView =
    List.map .profile_image
        >> List.map
            (\url ->
                img
                    [ src url
                    , class "Main-footer-accounts-img"
                    ]
                    []
            )
