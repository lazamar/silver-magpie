module Routes.Login.State exposing (init, update, logout)

import Routes.Login.Types
    exposing
        ( Model
        , Msg(..)
        , Broadcast(Authenticated)
        )
import Routes.Login.Rest exposing (fetchCredential)
import Generic.LocalStorage
import Generic.UniqueID
import Generic.CredentialsHandler as CredentialsHandler
import Generic.Utils exposing (toCmd)
import RemoteData exposing (RemoteData)
import Twitter.Types exposing (Credential)
import Task


initialModel : () -> Model
initialModel _ =
    let
        credential =
            CredentialsHandler.retrieveStored ()
                |> List.head
                |> Maybe.map RemoteData.Success
                |> Maybe.withDefault RemoteData.NotAsked
    in
        { sessionID = getSessionID ()
        , credential = credential
        }


init : () -> ( Model, Cmd Msg, Cmd Broadcast )
init _ =
    let
        model =
            initialModel ()
    in
        ( model
        , toCmd <| UserCredentialFetch model.credential
        , Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Broadcast )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none, Cmd.none )

        UserCredentialFetch request ->
            case request of
                RemoteData.Success credential ->
                    ( { model | credential = request }
                    , CredentialsHandler.store (\_ -> DoNothing) credential
                    , Generic.Utils.toCmd (Authenticated credential)
                    )

                RemoteData.NotAsked ->
                    ( { model | credential = RemoteData.Loading }
                    , fetchCredential model.sessionID
                    , Cmd.none
                    )

                _ ->
                    ( { model | credential = request }
                    , Cmd.none
                    , Cmd.none
                    )



-- Generates a random uinique session ID


getSessionID : () -> String
getSessionID _ =
    let
        retrieved =
            Generic.LocalStorage.getItem "sessionID"
    in
        case Debug.log "retrieved value: " retrieved of
            Nothing ->
                CredentialsHandler.generateSessionID ()

            Just sessionID ->
                sessionID


saveCredential : Credential -> Cmd msg
saveCredential credential =
    Generic.LocalStorage.setItem "credential" credential
        |> \_ -> Cmd.none



-- Erase all stored credential


logout : () -> Bool
logout _ =
    Generic.LocalStorage.clear ()
