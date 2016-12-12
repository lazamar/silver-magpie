module Main.Rest exposing (fetchCredential)

import Main.Types exposing (Msg(UserCredentialFetch))
import Generic.Http
import Generic.Utils exposing (mapResult)
import Twitter.Types exposing (Credential)
import Http
import Json.Decode exposing (Decoder, string, at)
import Json.Decode.Pipeline exposing (decode, required)
import Task
import RemoteData


fetchCredential : String -> Cmd Msg
fetchCredential sessionID =
    Generic.Http.get sessionID credentialDecoder "/app-get-access"
        |> Task.attempt (mapResult RemoteData.Failure RemoteData.Success)
        |> Cmd.map UserCredentialFetch


credentialDecoder : Decoder Credential
credentialDecoder =
    at [ "app_access_token" ] string
