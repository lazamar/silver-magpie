module Main.View exposing (..)

import Browser
import Generic.Http
import Generic.Utils exposing (tooltip)
import Html exposing (Html, a, button, div, img, span, text)
import Html.Attributes exposing (class, href, src, tabindex, target, title)
import Html.Events exposing (onClick)
import List.Extra
import Main.LoginView
import Main.State exposing (credentialInUse)
import Main.Types exposing (..)
import Timelines.View
import Twitter.Types exposing (Credential)


view : Model -> Browser.Document Msg
view model =
    { title = "Silver Magpie"
    , body =
        List.singleton <|
            case timelinesView model of
                Nothing ->
                    Main.LoginView.root model

                Just aView ->
                    div [ class "Main" ]
                        [ aView
                        , model.sessionID
                            |> Maybe.map (footerView model.footerMessageNumber model.usersDetails << getSessionID)
                            |> Maybe.withDefault (div [] [])
                        ]
    }


timelinesView : Model -> Maybe (Html Msg)
timelinesView model =
    Maybe.map2
        (Timelines.View.root model.zone)
        (List.head model.usersDetails)
        model.timelinesModel
        |> Maybe.map (Html.map TimelinesMsg)


footerView : FooterMsg -> List UserDetails -> SessionID -> Html Msg
footerView footerMsg usersDetails sessionID =
    let
        currentCredential =
            credentialInUse usersDetails
                |> Maybe.withDefault ""
    in
    div [ class "Main-footer" ]
        [ button
            [ class "zmdi zmdi-collection-item btn btn-default btn-icon"
            , title "Detach window"
            , tabindex -1
            , onClick Detach
            ]
            []
        , span
            [ class "Main-footer-cues animated fadeInUp" ]
            [ text <| footerMessage footerMsg ]
        , accountsView sessionID usersDetails
        , button
            [ class "zmdi zmdi-power btn btn-default btn-icon"
            , tabindex -1
            , title "Logout"
            , onClick <| Logout currentCredential
            ]
            []
        ]


footerMessage : FooterMsg -> String
footerMessage (FooterMsg seed) =
    let
        messagesLength =
            List.length footerMessages

        msgNumber =
            modBy messagesLength seed
    in
    List.Extra.getAt msgNumber footerMessages
        |> Maybe.withDefault ""


footerMessages =
    [ "Hover the footer to login with a second account"
    , "Press Tab to navigate the timeline using the arrow keys :)"
    , "You can open Silver Magpie with Ctrl+Alt+1"
    , "Use Ctrl+Enter to send your tweet"
    , "Use arrows to navigate handler suggestions"
    ]


accountsView : SessionID -> List UserDetails -> Html Msg
accountsView sessionID usersDetails =
    let
        avatarClass idx =
            if idx == 0 then
                "Main-footer-accounts-img--selected"

            else
                "Main-footer-accounts-img"

        createAvatar idx acc =
            img
                [ src acc.profile_image
                , class <| avatarClass idx
                , onClick <| SelectAccount acc.credential
                , title <| "@" ++ acc.handler
                , tabindex -1
                ]
                []

        accountsAvatars =
            usersDetails
                |> List.indexedMap (\idx u -> ( u, createAvatar idx u ))
                |> List.sortBy (Tuple.first >> .handler)
                |> List.map Tuple.second

        addAccountButton =
            a
                [ class "zmdi zmdi-plus btn btn-default btn-icon Main-footer-addAccount"
                , target "blank"
                , title "Add another account"
                , tabindex -1
                , href <| Generic.Http.sameDomain <| "/sign-in/?app_session_id=" ++ sessionID
                ]
                []
    in
    div [ class "Main-footer-accounts-wrapper" ]
        [ span
            [ class "Main-footer-accounts" ]
            (addAccountButton :: accountsAvatars)
        ]


getSessionID : SessionIDAuthentication -> SessionID
getSessionID auth =
    case auth of
        NotAttempted id ->
            id

        Authenticating id ->
            id

        Authenticated id _ ->
            id

        AuthenticationFailed id _ ->
            id
