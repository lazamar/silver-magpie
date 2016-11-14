module Login.Types exposing ( Model, UserInfo, Msg ( UserCredentialsFetch ) )

import RemoteData exposing ( WebData )


type alias Model =
    { sessionID : String
    , userInfo : WebData UserInfo
    , loggedIn : Bool -- This will tell the main script whether to render the login page or not
    }



type alias UserInfo =
    { accessToken : String
    , screenName : String
    }



type Msg
    = UserCredentialsFetch ( WebData UserInfo )
