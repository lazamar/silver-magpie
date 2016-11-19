module Routes.Login.Rest exposing ( fetchUserInfo )


import Routes.Login.Types exposing ( Msg ( UserCredentialsFetch ), UserInfo )
import Generic.Http
import Twitter.Types exposing ( Credentials )

import Http
import Json.Decode exposing ( Decoder, string )
import Json.Decode.Pipeline exposing ( decode, required )
import Task
import RemoteData



fetchUserInfo : Credentials -> Cmd Msg
fetchUserInfo sessionID =
    Generic.Http.get sessionID "/app-get-access"
        |> Http.fromJson userInfoDecoder
        |> Task.perform RemoteData.Failure RemoteData.Success
        |> Cmd.map UserCredentialsFetch



userInfoDecoder : Decoder UserInfo
userInfoDecoder =
    decode UserInfo
        |> required "app_access_token" string
        |> required "screen_name" string
