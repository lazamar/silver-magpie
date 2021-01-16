module Main.Rest exposing (fetchCredential)

import Generic.Http
import Generic.Utils exposing (mapResult)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Main.Types exposing (..)
import Task
import Twitter.Types exposing (Credential)


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
        |> requiredAt [ "profile_image_url_https" ] string
