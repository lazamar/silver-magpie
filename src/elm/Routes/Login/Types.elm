module Routes.Login.Types exposing
    ( Model
    , UserInfo
    , Msg (..)
    , BroadcastMsg (..)
    )

import RemoteData exposing ( WebData )
import Twitter.Types exposing ( Credentials )

type alias Model =
    { sessionID : String
    , userInfo : WebData UserInfo
    , loggedIn : Bool -- This will tell the main script whether to render the login page or not
    }



type alias UserInfo =
    { app_access_token : String
    , screenName : String
    }



type Msg
    = UserCredentialsFetch ( WebData UserInfo )



type BroadcastMsg
    = Authenticated Credentials
