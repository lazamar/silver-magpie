module Generic.Detach exposing ( detach )

import Native.Detach

detach : Int -> Int -> Cmd a
detach width height =
    Native.Detach.detach { width = width, height = height }
        |> (\_ -> Cmd.none)
