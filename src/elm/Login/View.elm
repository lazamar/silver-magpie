module Login.View exposing ( root )

import Login.Types exposing (..)
import Generic.Animations
import RemoteData exposing ( RemoteData )
import Html exposing (..)
import Html.Attributes exposing (..)



root : Model -> Html Msg
root model =
    case model.userInfo of
        RemoteData.Failure error ->
            case error of
              Http.UnexpectedPayload errDescription ->
                div [ class "Login" ]
                    [ a [ href "http://localhost:8080/sign-in/?app_session_id=" ++ model.sessionID ]
                        [ text "Sign in with Twitter" ]
                    ]

              _ ->
                div [ class "Login" ]
                    [ text "There was an error loading your credentials. Please retry."
                    ]

        RemoteData.Loading ->
            div [ class "Login" ]
                [ Generic.Animations.twistingCircle ]

        RemoteData.Success ->
            div [ class "Login" ]
                [ text "You are logged in" ]

        RemoteData.NotAsked ->
            div [ class "Login" ]
                [ text "Uh, I'm stuck. Something went wrong." ]
