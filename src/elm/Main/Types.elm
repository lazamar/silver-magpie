module Main.Types exposing (..)

import Routes.Timelines.Types as TimelinesT
import Twitter.Types exposing (Credential)
import RemoteData exposing (WebData)


type Msg
    = DoNothing
    | TimelinesMsg TimelinesT.Msg
    | UserCredentialFetch (WebData Credential)
    | Logout Credential
    | Authenticated Credential


type alias SessionID =
    String


type alias Model =
    { timelinesModel : Maybe TimelinesT.Model
    , sessionID : SessionID
    , credentials : List Credential
    , authenticatingCredential :
        WebData Credential
        -- Credential sent to the server for authentication
    }
