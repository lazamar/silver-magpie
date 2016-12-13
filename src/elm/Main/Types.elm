module Main.Types exposing (..)

import Routes.Timelines.Types as TimelinesT
import Twitter.Types exposing (Credential)
import Http


type Msg
    = DoNothing
    | TimelinesMsg TimelinesT.Msg
    | UserCredentialFetch SessionIDAuthentication
    | Logout Credential


type SessionIDAuthentication
    = NotAttempted
    | Authenticating SessionID
    | Authenticated SessionID Credential
    | AuthenticationFailed SessionID Http.Error


type alias SessionID =
    String


type alias Model =
    { timelinesModel : Maybe TimelinesT.Model
    , sessionID : SessionIDAuthentication
    , credentials : List Credential
    }
