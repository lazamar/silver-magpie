module Generic.LocalStorage exposing (clear, getItem, removeItem, setItem)

import Debug
import Json.Decode exposing (Decoder, decodeString, null, oneOf, string)
import Result


clear : () -> Cmd Bool
clear _ =
    {- let
           void =
               Native.LocalStorage.clear ()
       in
       True
    -}
    Debug.todo "Native.LocalStorage.clear"


setItem : String -> String -> Cmd a
setItem key value =
    -- Native.LocalStorage.setItem { key = key, value = value }
    Debug.todo "Native.LocalStorage.setItem"


getItem : String -> Cmd (Maybe String)
getItem key =
    -- Native.LocalStorage.getItem key
    --     |> decodeString (nullOr string)
    --     |> Result.withDefault Nothing
    Debug.todo "Native.LocalStorage.getItem"


removeItem : String -> String
removeItem key =
    -- Native.LocalStorage.removeItem key
    --     |> (\_ -> key)
    Debug.todo "Native.LocalStorage.removeItem"


nullOr : Decoder a -> Decoder (Maybe a)
nullOr decoder =
    oneOf
        [ null Nothing
        , Json.Decode.map Just decoder
        ]
