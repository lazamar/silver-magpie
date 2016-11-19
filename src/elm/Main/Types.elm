module Main.Types exposing (..)

import Routes.Timelines.Types as TimelinesT
import Routes.Login.Types as LoginT


type Msg
  = TimelinesMsgLocal TimelinesT.Msg
  | TimelinesMsgBroadcast TimelinesT.Broadcast
  | LoginMsgLocal LoginT.Msg
  | LoginMsgBroadcast LoginT.Broadcast



type Model
    = LoginRoute LoginT.Model
    | TimelinesRoute TimelinesT.Model
