module Routes.Login.Types
    exposing
        ( Model
        , Msg(..)
        , Broadcast(..)
        )

import RemoteData exposing (WebData)
import Twitter.Types exposing (Credentials)


type alias Model =
    { sessionID : String
    , credentials : WebData Credentials
    }


type Msg
    = UserCredentialsFetch (WebData Credentials)


type Broadcast
    = Authenticated Credentials
