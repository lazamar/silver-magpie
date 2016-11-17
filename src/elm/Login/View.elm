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
    case model.userInfo of
        RemoteData.Failure error ->
            case error of
                Http.BadResponse 401 errDescription ->
                    div [ class "Login" ]
                        [ a [ href <| Generic.Utils.sameDomain <| "/sign-in/?app_session_id=" ++ model.sessionID
                        , target "blank"
                        ]
                            [ text "Sign in with Twitter" ]
                        ]

                -- TODO: Handle other HTTP errors properly
                _ ->
                    div [ class "Login" ]
                        [ text "There was an error loading your credentials. Please retry."
                        ]

        RemoteData.Loading ->
            div [ class "Login" ]
                [ Generic.Animations.twistingCircle ]

        RemoteData.Success _ ->
            div [ class "Login" ]
                [ text "You are logged in" ]

        RemoteData.NotAsked ->
            div [ class "Login" ]
                [ text "Uh, I'm stuck. Something went wrong." ]
