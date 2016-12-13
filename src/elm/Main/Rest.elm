module Main.Rest exposing (fetchCredential)

import Main.Types exposing (..)
import Generic.Http
import Generic.Utils exposing (mapResult)
import Twitter.Types exposing (Credential)
import Http
import Json.Decode exposing (Decoder, string, at)
import Json.Decode.Pipeline exposing (decode, required)
import Task


fetchCredential : SessionID -> Cmd Msg
fetchCredential sessionID =
    Generic.Http.get sessionID credentialDecoder "/app-get-access"
        |> Task.attempt
            (mapResult
                (AuthenticationFailed sessionID)
                (Authenticated sessionID)
            )
        |> Cmd.map UserCredentialFetch


credentialDecoder : Decoder Credential
credentialDecoder =
    at [ "app_access_token" ] string
