module Generic.Detach exposing ( generate )

import Native.Detach

detach : Int -> Int -> Cmd
detach =
    Native.Detatch.detach
        >> (\_ -> Cmd.none)
