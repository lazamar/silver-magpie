module Json.Encode.Extra exposing (..)

import Json.Encode as Encode exposing (Value)


maybe : (a -> Value) -> Maybe a -> Value
maybe encode v =
    case v of
        Nothing ->
            Encode.null

        Just val ->
            encode val
