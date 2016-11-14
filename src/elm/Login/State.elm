module Login.State exposing ( init, update, subscriptions )

import Login.Types exposing ( Module, UserInfo )
import Login.Rest exposing ( fetchUserInfo )
import Generic.LocalStorage
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



init : ( Model, Cmd Msg, Cmd Main.Types.Msg )
init =
    ( initialModel
    , Cmd.map UserCredentialsFetch <| Task.succeed initialModel.userInfo
    , Cmd.none
    )



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Main.Types.Msg )
update msg model =
    case msg of
        UserCredentialsFetch request ->
            case request of
                RemoteData.Success _ ->
                    ( { model | userInfo = request, loggedIn = True }
                    , Cmd.none
                    , Cmd.none
                    )

                RemoteData.NotAsked ->
                    ( { model | userInfo = request , loggedIn = False }
                    , fetchUserInfo
                    , Cmd.none
                    )

                _ ->
                    ( { model | userInfo = request , loggedIn = False }
                    , Cmd.none
                    , Cmd.none
                    )



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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
    Maybe.withDefault
        ( generateSessionID "random_string" )
        Generic.LocalStorage.getItem "sessionID"



-- Generates a random uinique session ID
generateSessionID : String -> String
generateSessionID seed =
    seed ++ "abc" -- TODO: Make this actually generate something random
