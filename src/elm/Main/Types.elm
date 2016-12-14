module Main.Types exposing (..)

import Timelines.Types as TimelinesT
import Twitter.Types exposing (Credential)
import Http


type Msg
    = DoNothing
    | TimelinesMsg TimelinesT.Msg
    | UserCredentialFetch SessionIDAuthentication
    | SelectAccount Credential
    | Logout Credential
    | Detach


type SessionIDAuthentication
    = NotAttempted
    | Authenticating SessionID
    | Authenticated SessionID UserDetails
    | AuthenticationFailed SessionID Http.Error


type alias SessionID =
    String


type alias Model =
    { timelinesModel : Maybe TimelinesT.Model
    , sessionID : SessionIDAuthentication
    , usersDetails : List UserDetails
    , footerMessageNumber : Int
    }


type alias UserDetails =
    { credential : Credential
    , handler : String
    , profile_image : String
    }
