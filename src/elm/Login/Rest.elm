module Login.Rest exposing ( fetchUserInfo )


import Login.Types exposing (..)
import Http
import Json.Decode exposing ( Decoder, string )
import Json.Decode.Pipeline exposing ( decode, required )



fetchUserInfo : String -> Cmd Msg
fetchUserInfo sessionID =
    let
        url = "http://localhost:8080/app-get-access/?app_session_id=" ++ sessionID
    in
        Http.get userInfoDecoder url
            |> Task.perform UserCredentialsFetch UserCredentialsFetch



userInfoDecoder : Decoder UserInfo
userInfoDecoder =
    decode UserInfo
        |> required "accessToken" string
        |> required "screenName" string
