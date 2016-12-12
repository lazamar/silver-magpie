module Routes.Login.Types
    exposing
        ( Model
        , Msg(..)
        , Broadcast(..)
        )

import RemoteData exposing (WebData)
import Twitter.Types exposing (Credential)


type alias Model =
    { sessionID : String
    , credential : WebData Credential
    }


type Msg
    = UserCredentialFetch (WebData Credential)
    | DoNothing


type Broadcast
    = Authenticated Credential
