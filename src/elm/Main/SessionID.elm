module Main.SessionID exposing (..)

import Time exposing (Time)
import Random exposing (Generator)


type SessionID
    = SessionID String


idGenerator : Time -> Generator SessionID
idGenerator time =
    Random.int 0 Random.maxInt
        |> Random.map toString
        |> Random.map (\v -> toString time ++ "." ++ v)
        |> Random.map SessionID
