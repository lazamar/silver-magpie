module Main.CredentialsHandler exposing (generateSessionID)

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
