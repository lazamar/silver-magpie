module Login.State exposing ( init, update )

import Login.Types exposing ( Model, UserInfo, Msg (..) )
import Login.Rest exposing ( fetchUserInfo )
import Generic.LocalStorage
import Generic.UniqueID
import RemoteData exposing ( RemoteData )
import Task



initialModel : Model
initialModel =
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



init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Task.perform identity identity <| Task.succeed ( UserCredentialsFetch initialModel.userInfo )
    )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserCredentialsFetch request ->
            case request of
                RemoteData.Success _ ->
                    ( { model | userInfo = request, loggedIn = True }
                    , Cmd.none
                    )

                RemoteData.NotAsked ->
                    ( { model | userInfo = RemoteData.Loading , loggedIn = False }
                    , fetchUserInfo model.sessionID
                    )

                _ ->
                    ( { model | userInfo = request , loggedIn = False }
                    , Cmd.none
                    )



-- Gets user info from local storage
getUserInfo : () -> Maybe UserInfo
getUserInfo nothing =
    let
        accessToken = Generic.LocalStorage.getItem "accessToken"
        screenName = Generic.LocalStorage.getItem "screenName"
    in
        Maybe.map2 UserInfo accessToken screenName



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
