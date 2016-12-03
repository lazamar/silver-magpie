module Routes.Login.Rest exposing (fetchCredentials)

import Routes.Login.Types exposing (Msg(UserCredentialsFetch))
import Generic.Http
import Twitter.Types exposing (Credentials)
import Http
import Json.Decode exposing (Decoder, string, at)
import Json.Decode.Pipeline exposing (decode, required)
import Task
import RemoteData


fetchCredentials : Credentials -> Cmd Msg
fetchCredentials sessionID =
    Generic.Http.get sessionID "/app-get-access"
        |> Http.fromJson credentialsDecoder
        |> Task.perform RemoteData.Failure RemoteData.Success
        |> Cmd.map UserCredentialsFetch


credentialsDecoder : Decoder Credentials
credentialsDecoder =
    at [ "app_access_token" ] string
