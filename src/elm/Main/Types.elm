module Main.Types exposing (..)

import Routes.Timelines.Types as TimelinesT
import Routes.Login.Types as LoginT


type Msg
    = TimelinesMsg TimelinesT.Msg
    | LoginMsg LoginT.Msg
    | LoginBroadcast LoginT.Broadcast
    | Logout


type Model
    = LoginRoute LoginT.Model
    | TimelinesRoute TimelinesT.Model
