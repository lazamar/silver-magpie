port module Generic.LocalStorage exposing (set)

import Debug
import Json.Decode exposing (Decoder, Error, decodeString, null, oneOf, string, value)
import Json.Encode exposing (Value, encode)
import Result



{-
   Keeping a full DB in Elm is a pain because ports are async.

   To avoid the pain we only ever set data. Data is read back
   when the program starts.
-}


port port_LocalStorage_set : String -> Cmd a


set : Value -> Cmd a
set value =
    port_LocalStorage_set (encode 2 value)
