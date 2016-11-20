module Main.Types exposing (..)

import Routes.Timelines.Types as TimelinesT
import Routes.Login.Types as LoginT


type Msg
  = TimelinesMsg TimelinesT.Msg
  | TimelinesBroadcast TimelinesT.Broadcast
  | LoginMsg LoginT.Msg
  | LoginBroadcast LoginT.Broadcast



type Model
    = LoginRoute LoginT.Model
    | TimelinesRoute TimelinesT.Model
