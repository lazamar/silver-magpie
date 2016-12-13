module Generic.LocalStorage exposing (setItem, getItem, clear, removeItem)

import Native.LocalStorage
import Json.Decode exposing (Decoder, null, decodeString, string, oneOf)
import Result


clear : () -> Bool
clear _ =
    let
        void =
            Native.LocalStorage.clear ()
    in
        True


setItem : String -> String -> String
setItem key value =
    Native.LocalStorage.setItem { key = key, value = value }


getItem : String -> Maybe String
getItem key =
    Native.LocalStorage.getItem key
        |> decodeString (nullOr string)
        |> Result.withDefault Nothing


removeItem : String -> String
removeItem key =
    Native.LocalStorage.removeItem key
        |> \_ -> key


nullOr : Decoder a -> Decoder (Maybe a)
nullOr decoder =
    oneOf
        [ null Nothing
        , Json.Decode.map Just decoder
        ]
