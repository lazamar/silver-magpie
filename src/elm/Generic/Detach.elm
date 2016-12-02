module Generic.Detach exposing ( detach )

import Native.Detach

detach : Int -> Int -> Cmd a
detach width height =
    Native.Detatch.detach { width = width, height = height }
        |> (\_ -> Cmd.none)
