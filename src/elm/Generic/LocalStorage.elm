module Generic.LocalStorage exposing ( setItem, getItem, clear )

import Native.LocalStorage
import Json.Decode exposing ( Decoder, null , decodeString, string, oneOf )
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
        |> decodeString ( nullOr string )
        |> Result.withDefault Nothing



nullOr : Decoder a -> Decoder (Maybe a)
nullOr decoder =
    oneOf
    [ null Nothing
    , Json.Decode.map Just decoder
    ]
