module Routes.Login.State exposing ( init, update, logout )

import Routes.Login.Types exposing ( Model, UserInfo, Msg (..) )
import Routes.Login.Rest exposing ( fetchUserInfo )
import Main.Types
import Generic.LocalStorage
import Generic.UniqueID
import Generic.Utils exposing ( toCmd )
import RemoteData exposing ( RemoteData )
import Task



initialModel : () -> Model
initialModel _ =
    let
        userInfo =
            getUserInfo ()
                |> Maybe.map RemoteData.Success
                |> Maybe.withDefault RemoteData.NotAsked

        loggedIn =
            case userInfo of
                RemoteData.Success _ ->
                    True

                _ ->
                    False
    in
        { sessionID = getSessionID ()
        , userInfo = userInfo
        , loggedIn = loggedIn
        }



init : () -> ( Model, Cmd Msg, Cmd Main.Types.Msg )
init _ =
    let
        model = initialModel ()
    in
        ( model
        , toCmd <| UserCredentialsFetch model.userInfo
        , Cmd.none
        )



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Main.Types.Msg )
update msg model =
    case msg of
        UserCredentialsFetch request ->
            case request of
                RemoteData.Success userInfo ->
                    ( { model | userInfo = request, loggedIn = True }
                    , Cmd.none
                    , Generic.Utils.toCmd ( Main.Types.Login userInfo.app_access_token )
                    )

                RemoteData.NotAsked ->
                    ( { model | userInfo = RemoteData.Loading , loggedIn = False }
                    , fetchUserInfo model.sessionID
                    , Cmd.none
                    )

                _ ->
                    ( { model | userInfo = request , loggedIn = False }
                    , Cmd.none
                    , Cmd.none
                    )



-- Gets user info from local storage
getUserInfo : () -> Maybe UserInfo
getUserInfo nothing =
    let
        app_access_token = Generic.LocalStorage.getItem "app_access_token"
        screenName = Generic.LocalStorage.getItem "screenName"
    in
        Maybe.map2 UserInfo app_access_token screenName



getSessionID : () -> String
getSessionID _ =
    let
        retrieved =
            Generic.LocalStorage.getItem "sessionID"
    in
        case Debug.log "retrieved value: " retrieved of
            Nothing ->
                generateSessionID "random_string"

            Just sessionID ->
                sessionID



-- Generates a random uinique session ID
generateSessionID : String -> String
generateSessionID seed =
    Generic.UniqueID.generate seed
        |> Generic.LocalStorage.setItem "sessionID"
        |> Debug.log "Generated session id"



-- Erase all stored credentials
logout : () -> Bool
logout _ =
    Generic.LocalStorage.clear ()
