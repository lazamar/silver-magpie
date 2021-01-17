module Main.CredentialsHandler exposing
    ( generateSessionID
    , retrieveSessionID
    , retrieveUsersDetails
    , storeUsersDetails
    )

import Generic.LocalStorage as LocalStorage
import Generic.UniqueID as UniqueID
import Generic.Utils exposing (toCmd)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Extra exposing (required)
import Json.Encode as Encode
import Main.Types exposing (UserDetails)
import Twitter.Types exposing (Credential)



-- SESSION ID


retrieveSessionID : () -> Maybe String
retrieveSessionID _ =
    LocalStorage.getItem "sessionID"


generateSessionID : () -> String
generateSessionID _ =
    UniqueID.generate "seed"
        |> LocalStorage.setItem "sessionID"
        |> Debug.log "Generated session id"



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
        |> (\_ -> toCmd (msg usersDetails))



-- PRIVATE


serialiseUsersDetails : List UserDetails -> String
serialiseUsersDetails =
    Encode.list userDetailsSerialiser
        >> Encode.encode 2


userDetailsSerialiser : UserDetails -> Value
userDetailsSerialiser { credential, handler, profile_image } =
    Encode.object
        [ ( "credential", Encode.string credential )
        , ( "handler", Encode.string handler )
        , ( "profile_image", Encode.string profile_image )
        ]


userDetailsDeserialiser : Decoder UserDetails
userDetailsDeserialiser =
    Decode.succeed UserDetails
        |> required "credential" Decode.string
        |> required "handler" Decode.string
        |> required "profile_image" Decode.string


deserialiseUserDetails : String -> Maybe (List UserDetails)
deserialiseUserDetails =
    Decode.decodeString (Decode.list userDetailsDeserialiser)
        >> Result.toMaybe
