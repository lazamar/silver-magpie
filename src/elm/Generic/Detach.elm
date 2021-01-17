module Generic.Detach exposing (detach)

import Debug


detach : Int -> Int -> Cmd a
detach width height =
    --Native.Detach.detach { width = width, height = height }
    --|> (\_ -> Cmd.none)
    Debug.todo "Detach" Debug.todo "Detach"
