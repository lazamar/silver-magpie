module Generic.LocalStorage exposing (setItem, getItem)

import Native.LocalStorage



setItem : String -> String -> String
setItem key value =
    Native.LocalStorage.setItem key value



getItem : String -> Maybe String
getItem key =
    Native.LocalStorage.getItem key
