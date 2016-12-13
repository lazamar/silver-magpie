module Main.Rest exposing (fetchCredential)

import Main.Types exposing (..)
import Generic.Http
import Generic.Utils exposing (mapResult)
import Twitter.Types exposing (Credential)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Task


fetchCredential : SessionID -> Cmd Msg
fetchCredential sessionID =
    Generic.Http.get sessionID detailsDecoder "/app-get-access"
        |> Task.attempt
            (mapResult
                (AuthenticationFailed sessionID)
                (Authenticated sessionID)
            )
        |> Cmd.map UserCredentialFetch


detailsDecoder : Decoder UserDetails
detailsDecoder =
    decode UserDetails
        |> requiredAt [ "app_access_token" ] string
        |> requiredAt [ "screen_name" ] string
