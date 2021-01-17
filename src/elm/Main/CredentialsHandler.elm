module Main.CredentialsHandler exposing
    ( generateSessionID
    , retrieveSessionID
    , retrieveUsersDetails
    , saveSessionID
    , storeUsersDetails
    )

import Generic.LocalStorage as LocalStorage
import Generic.UniqueID as UniqueID
import Generic.Utils exposing (toCmd)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Extra exposing (required)
import Json.Encode as Encode
import Main.Types exposing (SessionID, UserDetails)
import Random
import Time exposing (Posix)
import Twitter.Types exposing (Credential)



-- SESSION ID


retrieveSessionID : Cmd (Maybe SessionID)
retrieveSessionID =
    LocalStorage.getItem "sessionID"


saveSessionID : SessionID -> Cmd a
saveSessionID =
    LocalStorage.setItem "sessionID"


generateSessionID : Posix -> Random.Seed -> ( Random.Seed, SessionID )
generateSessionID now seed =
    let
        ( rand, newSeed ) =
            Random.step (Random.int -10000 10000) seed

        uuid =
            String.fromInt (Time.posixToMillis now)
                ++ String.fromInt rand
    in
    ( newSeed, uuid )



-- USER DETAILS


retrieveUsersDetails : Cmd (List UserDetails)
retrieveUsersDetails =
    LocalStorage.getItem "usersDetails"
        |> Cmd.map
            (Maybe.andThen deserialiseUserDetails
                >> Maybe.withDefault []
            )


storeUsersDetails : List UserDetails -> Cmd a
storeUsersDetails usersDetails =
    serialiseUsersDetails usersDetails
        |> LocalStorage.setItem "usersDetails"



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
