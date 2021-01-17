module Main.Rest exposing (fetchCredential)

import Generic.Http
import Generic.Utils exposing (mapResult)
import Http
import Json.Decode as Decode exposing (Decoder, at, field, string)
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
    Decode.map3 UserDetails
        (field "app_access_token" string)
        (field "screen_name" string)
        (field "profile_image_url_https" string)
