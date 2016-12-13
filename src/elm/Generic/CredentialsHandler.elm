module Generic.CredentialsHandler
    exposing
        ( retrieveSessionID
        , generateSessionID
        , retrieveStored
        , store
        , eraseCredential
        , eraseSessionID
        )

import Twitter.Types exposing (Credential)
import Generic.LocalStorage
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


eraseSessionID : msg -> Cmd msg
eraseSessionID msg =
    Generic.LocalStorage.removeItem (Debug.log "erasing" "sessionID")
        |> (\_ -> toCmd msg)


retrieveStored : () -> List Credential
retrieveStored _ =
    Generic.LocalStorage.getItem "credential"
        |> Maybe.andThen decodeStringList
        |> Maybe.withDefault []


store : (List Credential -> msg) -> Credential -> Cmd msg
store msg credential =
    retrieveStored ()
        |> (++) [ credential ]
        |> setStoredCredential msg


eraseCredential : (List Credential -> msg) -> Credential -> Cmd msg
eraseCredential msg credential =
    retrieveStored ()
        |> List.filter (\c -> c /= credential)
        |> setStoredCredential msg



-- PRIVATE


setStoredCredential : (List Credential -> msg) -> List Credential -> Cmd msg
setStoredCredential msg credentialList =
    encodeStringList credentialList
        |> Generic.LocalStorage.setItem "credential"
        |> \_ -> toCmd (msg credentialList)


encodeStringList : List String -> String
encodeStringList =
    List.map Json.Encode.string
        >> Json.Encode.list
        >> Json.Encode.encode 2


decodeStringList : String -> Maybe (List String)
decodeStringList =
    Json.Decode.decodeString (Json.Decode.list Json.Decode.string)
        >> Result.toMaybe
