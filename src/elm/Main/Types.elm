module Main.Types exposing (..)

import Timelines.Types as TimelinesT
import Twitter.Types exposing (Credential)
import Http
import Random exposing (Seed, Generator)
import Time exposing (Time)


type Msg
    = DoNothing
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

    -- We use these fields to produce unique IDs
    -- The startTime field only exists because during
    -- logout we need a new time value to restart the
    -- application
    , generator : Generator SessionID
    , seed : Seed
    , startTime : Time
    }


type alias UserDetails =
    { credential : Credential
    , handler : String
    , profile_image : String
    }
