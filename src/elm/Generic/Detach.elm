port module Generic.Detach exposing (detach)

import Debug


port port_Detatch_detach : { width : Int, height : Int } -> Cmd a


detach : Int -> Int -> Cmd a
detach width height =
    port_Detatch_detach { width = width, height = height }
