module Main.CredentialsHandler
    exposing
        ( retrieveSessionID
        , generateSessionID
        , eraseSessionID
        , retrieveUsersDetails
        , storeUsersDetails
        )

import Main.Types exposing (UserDetails)
import Twitter.Types exposing (Credential)
import Generic.LocalStorage as LocalStorage
import Generic.Utils exposing (toCmd)
import Generic.UniqueID as UniqueID
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)


-- SESSION ID


retrieveSessionID : () -> Maybe String
retrieveSessionID _ =
    LocalStorage.getItem "sessionID"


generateSessionID : () -> String
generateSessionID _ =
    UniqueID.generate "seed"
        |> LocalStorage.setItem "sessionID"
        |> Debug.log "Generated session id"


eraseSessionID : msg -> Cmd msg
eraseSessionID msg =
    LocalStorage.removeItem (Debug.log "erasing" "sessionID")
        |> (\_ -> toCmd msg)



-- USER DETAILS


retrieveUsersDetails : () -> List UserDetails
retrieveUsersDetails _ =
    LocalStorage.getItem "usersDetails"
        |> Maybe.andThen deserialiseUserDetails
        |> Maybe.withDefault []


storeUsersDetails : (List UserDetails -> msg) -> List UserDetails -> Cmd msg
storeUsersDetails msg usersDetails =
    serialiseUsersDetails usersDetails
        |> LocalStorage.setItem "usersDetails"
        |> \_ -> toCmd (msg usersDetails)



-- PRIVATE


serialiseUsersDetails : List UserDetails -> String
serialiseUsersDetails =
    List.map userDetailsSerialiser
        >> Json.Encode.list
        >> Json.Encode.encode 2


userDetailsSerialiser : UserDetails -> Json.Encode.Value
userDetailsSerialiser { credential, handler, profile_image } =
    Json.Encode.object
        [ ( "credential", Json.Encode.string credential )
        , ( "handler", Json.Encode.string handler )
        , ( "profile_image", Json.Encode.string profile_image )
        ]


userDetailsDeserialiser : Json.Decode.Decoder UserDetails
userDetailsDeserialiser =
    decode UserDetails
        |> required "credential" Json.Decode.string
        |> required "handler" Json.Decode.string
        |> required "profile_image" Json.Decode.string


deserialiseUserDetails : String -> Maybe (List UserDetails)
deserialiseUserDetails =
    Json.Decode.decodeString (Json.Decode.list userDetailsDeserialiser)
        >> Result.toMaybe
