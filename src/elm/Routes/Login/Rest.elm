module Routes.Login.Rest exposing (fetchCredentials)

import Routes.Login.Types exposing (Msg(UserCredentialsFetch))
import Generic.Http
import Generic.Utils exposing (mapResult)
import Twitter.Types exposing (Credentials)
import Http
import Json.Decode exposing (Decoder, string, at)
import Json.Decode.Pipeline exposing (decode, required)
import Task
import RemoteData


fetchCredentials : String -> Cmd Msg
fetchCredentials sessionID =
    Generic.Http.get sessionID credentialsDecoder "/app-get-access"
        |> Task.attempt (mapResult RemoteData.Failure RemoteData.Success)
        |> Cmd.map UserCredentialsFetch


credentialsDecoder : Decoder Credentials
credentialsDecoder =
    at [ "app_access_token" ] string
