module Generic.CredentialsHandler
    exposing
        ( retrieveSessionID
        , generateSessionID
        , retrieveStored
        , store
        , eraseFromStorage
        )

import Twitter.Types exposing (Credentials)
import Generic.LocalStorage exposing (getItem, setItem)
import Generic.Utils exposing (toCmd)
import Generic.UniqueID
import Json.Encode
import Json.Decode


retrieveSessionID : () -> Maybe String
retrieveSessionID _ =
    Generic.LocalStorage.getItem "sessionID"


generateSessionID : () -> String
generateSessionID _ =
    Generic.UniqueID.generate "seed"
        |> Generic.LocalStorage.setItem "sessionID"
        |> Debug.log "Generated session id"


retrieveStored : () -> List Credentials
retrieveStored _ =
    Generic.LocalStorage.getItem "credentials"
        |> Maybe.andThen decodeStringList
        |> Maybe.withDefault []


store : (List Credentials -> msg) -> Credentials -> Cmd msg
store msg credentials =
    retrieveStored ()
        |> (++) [ credentials ]
        |> setStoredCredentials msg


eraseFromStorage : (List Credentials -> msg) -> Credentials -> Cmd msg
eraseFromStorage msg credentials =
    retrieveStored ()
        |> List.filter (\c -> c /= credentials)
        |> setStoredCredentials msg



-- PRIVATE


setStoredCredentials : (List Credentials -> msg) -> List Credentials -> Cmd msg
setStoredCredentials msg credentialsList =
    encodeStringList credentialsList
        |> Generic.LocalStorage.setItem "credentials"
        |> \_ -> toCmd (msg credentialsList)


encodeStringList : List String -> String
encodeStringList =
    List.map Json.Encode.string
        >> Json.Encode.list
        >> Json.Encode.encode 2


decodeStringList : String -> Maybe (List String)
decodeStringList =
    Json.Decode.decodeString (Json.Decode.list Json.Decode.string)
        >> Result.toMaybe
