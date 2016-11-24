module Routes.Login.State exposing ( init, update, logout )

import Routes.Login.Types exposing
    ( Model
    , Msg (..)
    , Broadcast ( Authenticated )
    )
import Routes.Login.Rest exposing ( fetchCredentials )
import Generic.LocalStorage
import Generic.UniqueID
import Generic.Utils exposing ( toCmd )
import RemoteData exposing ( RemoteData )
import Twitter.Types exposing ( Credentials )
import Task



initialModel : () -> Model
initialModel _ =
    let
        credentials =
            getSavedCredentials ()
                |> Maybe.map RemoteData.Success
                |> Maybe.withDefault RemoteData.NotAsked
    in
        { sessionID = getSessionID ()
        , credentials = credentials
        }



init : () -> ( Model, Cmd Msg, Cmd Broadcast )
init _ =
    let
        model = initialModel ()
    in
        ( model
        , toCmd <| UserCredentialsFetch model.credentials
        , Cmd.none
        )



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Broadcast )
update msg model =
    case msg of
        UserCredentialsFetch request ->
            case request of
                RemoteData.Success credentials ->
                    ( { model | credentials = request }
                    , saveCredentials credentials
                    , Generic.Utils.toCmd ( Authenticated credentials )
                    )

                RemoteData.NotAsked ->
                    ( { model | credentials = RemoteData.Loading }
                    , fetchCredentials model.sessionID
                    , Cmd.none
                    )

                _ ->
                    ( { model | credentials = request }
                    , Cmd.none
                    , Cmd.none
                    )



-- Generates a random uinique session ID
generateSessionID : String -> String
generateSessionID seed =
    Generic.UniqueID.generate seed
        |> Generic.LocalStorage.setItem "sessionID"
        |> Debug.log "Generated session id"



getSessionID : () -> String
getSessionID _ =
    let
        retrieved =
            Generic.LocalStorage.getItem "sessionID"
    in
        case Debug.log "retrieved value: " retrieved of
            Nothing ->
                generateSessionID "random_string"

            Just sessionID ->
                sessionID



saveCredentials : Credentials -> Cmd msg
saveCredentials credentials =
    Generic.LocalStorage.setItem "credentials" credentials
        |> \_ -> Cmd.none



getSavedCredentials : () -> Maybe Credentials
getSavedCredentials _ =
    Generic.LocalStorage.getItem "credentials"



-- Erase all stored credentials
logout : () -> Bool
logout _ =
    Generic.LocalStorage.clear ()
