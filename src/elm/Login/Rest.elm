module Login.Rest exposing ( fetchUserInfo )


import Login.Types exposing ( Msg ( UserCredentialsFetch ), UserInfo )
import Generic.Utils

import Http
import Json.Decode exposing ( Decoder, string )
import Json.Decode.Pipeline exposing ( decode, required )
import Task
import RemoteData



fetchUserInfo : String -> Cmd Msg
fetchUserInfo sessionID =
    let
        url = Generic.Utils.sameDomain ( "/app-get-access/?app_session_id=" ++ sessionID )
    in
        Http.get userInfoDecoder url
            |> Task.perform RemoteData.Failure RemoteData.Success
            |> Cmd.map UserCredentialsFetch



userInfoDecoder : Decoder UserInfo
userInfoDecoder =
    decode UserInfo
        |> required "access_token" string
        |> required "screen_name" string
