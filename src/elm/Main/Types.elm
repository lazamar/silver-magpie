module Main.Types exposing (..)

import Http
import Random
import Time
import Timelines.Types as TimelinesT
import Twitter.Types exposing (Credential)


type Msg
    = DoNothing
    | TimeZone Time.Zone
    | SessionIdLoaded (Maybe SessionID)
    | LoadedUsersDetails (List UserDetails)
    | TimelinesMsg TimelinesT.Msg
    | UserCredentialFetch SessionIDAuthentication
    | SelectAccount Credential
    | Logout Credential
    | CurrentFooterMsg FooterMsg
    | Detach


type SessionIDAuthentication
    = NotAttempted SessionID
    | Authenticating SessionID
    | Authenticated SessionID UserDetails
    | AuthenticationFailed SessionID Http.Error


type FooterMsg
    = FooterMsg Int


type alias SessionID =
    String


type alias Model =
    { timelinesModel : Maybe TimelinesT.Model
    , sessionID : Maybe SessionIDAuthentication
    , usersDetails : List UserDetails
    , footerMessageNumber : FooterMsg
    , zone : Time.Zone
    , now : Time.Posix
    , randomSeed : Random.Seed
    }


type alias UserDetails =
    { credential : Credential
    , handler : String
    , profile_image : String
    }
