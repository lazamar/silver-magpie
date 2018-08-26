module Main.CredentialsHandler
    exposing
        ( idGenerator
        , retrieveSessionID
        , generateSessionID
        , retrieveUsersDetails
        , storeUsersDetails
        )

import Main.Types exposing (UserDetails, SessionID)
import Twitter.Types exposing (Credential)
import Generic.LocalStorage as LocalStorage
import Generic.Utils exposing (toCmd)
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Time exposing (Time)
import Random exposing (Generator, Seed)


-- SESSION ID


idGenerator : Time -> Generator SessionID
idGenerator time =
    Random.int 0 Random.maxInt
        |> Random.map toString
        |> Random.map (\v -> toString time ++ "." ++ v)


retrieveSessionID : () -> Maybe String
retrieveSessionID _ =
    LocalStorage.getItem "sessionID"


generateSessionID : Generator SessionID -> Seed -> ( String, Seed )
generateSessionID generator seed =
    Random.step generator seed
        |> Tuple.mapFirst (LocalStorage.setItem "sessionID")
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
