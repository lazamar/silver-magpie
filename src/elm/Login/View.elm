module Login.View exposing ( root )

import Login.Types exposing (..)
import Generic.Animations
import Generic.Utils
import RemoteData exposing ( RemoteData )
import Http
import Html exposing (..)
import Html.Attributes exposing (..)



root : Model -> Html Msg
root model =
    div [ class "Login" ]
        [ div
            [ class "Login-content" ]
            [ img
                [ src "../images/logo.png"
                , class "Login-logo"
                ] []
            , loginContent model
            ]
        , div
            [ class "Login-footer" ]
            [ p []
                [ text "Created with "
                , i [ class "zmdi zmdi-favorite Login-footer-heartIcon" ] []
                , text " by "
                , a [ href "http://lazamar.github.io"]
                    [ text "Marcelo Lazaroni" ]
                ]
            , p []
                [ text "Poetically written in "
                , a [ href "http://elm-lang.org" ]
                    [ text "Elm"]
                ]
            ]

        ]


loginContent : Model -> Html Msg
loginContent model =
    case model.userInfo of
        RemoteData.Failure error ->
            case error of
                Http.BadResponse 401 errDescription ->
                    a   [ href <| Generic.Utils.sameDomain <| "/sign-in/?app_session_id=" ++ model.sessionID
                        , target "blank"
                        , class "Login-signinBtn"
                        ]
                        [ text "Sign in with Twitter "
                        ]

                -- TODO: Handle other HTTP errors properly
                _ ->
                    text "There was an error loading your credentials. Please retry."

        RemoteData.Loading ->
            Generic.Animations.twistingCircle

        RemoteData.Success _ ->
            text "You are logged in"

        RemoteData.NotAsked ->
            text "Uh, I'm stuck. Something went wrong."
