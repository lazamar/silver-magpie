module Main.Types exposing (..)

import Http
import Time
import Timelines.Types as TimelinesT
import Twitter.Types exposing (Credential)


type Msg
    = DoNothing
    | TimeZone Time.Zone
    | TimelinesMsg TimelinesT.Msg
    | UserCredentialFetch SessionIDAuthentication
    | SelectAccount Credential
    | Logout Credential
    | Detach


type SessionIDAuthentication
    = NotAttempted SessionID
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
    , zone : Time.Zone
    }


type alias UserDetails =
    { credential : Credential
    , handler : String
    , profile_image : String
    }
