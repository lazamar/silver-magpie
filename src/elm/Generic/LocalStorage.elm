port module Generic.LocalStorage exposing (clear, listen, set)

import Debug
import Json.Decode exposing (Decoder, Error, decodeString, null, oneOf, string, value)
import Json.Encode exposing (Value, encode)
import Result



{-
   Keeping a full DB in Elm is a pain because there can be no communication
   between sending info and getting it back. It makes things like getting a value
   extremely convoluted.

   To simplify it we treat local storage as a store that can hold only one
   single string value.

   Then we keep all local storage state in the model and only update the DB
   when needed.
-}


{-| Clears entire local storage database
-}
port port_LocalStorage_clear : () -> Cmd a


clear : Cmd Bool
clear =
    port_LocalStorage_clear ()


port port_LocalStorage_set : String -> Cmd a


set : Value -> Cmd a
set value =
    port_LocalStorage_set (encode 2 value)


port port_LocalStorage_listen : (Value -> a) -> Sub a


listen : (Value -> msg) -> Sub msg
listen f =
    port_LocalStorage_listen f
