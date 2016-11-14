module Generic.LocalStorage exposing (setItem, getItem)

import Native.LocalStorage
import Json.Decode exposing ( Decoder, null , decodeString, string, oneOf )
import Result

setItem : String -> String -> String
setItem key value =
    Native.LocalStorage.setItem key value


getItem : String -> Maybe String
getItem key =
    Native.LocalStorage.getItem key
        |> decodeString ( nullOr string )
        |> Result.withDefault Nothing
        |> Debug.log "Value parsed"



nullOr : Decoder a -> Decoder (Maybe a)
nullOr decoder =
    oneOf
    [ null Nothing
    , Json.Decode.map Just decoder
    ]
