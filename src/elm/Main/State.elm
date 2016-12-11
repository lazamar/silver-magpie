module Main.State exposing (..)

import Main.Types exposing (..)
import Routes.Login.Types as LoginT
import Routes.Login.State as LoginS
import Routes.Timelines.Types as TimelinesT
import Routes.Timelines.State as TimelinesS


-- INITIALISATION


init : () -> ( Model, Cmd Msg )
init _ =
    LoginS.init ()
        |> translate LoginRoute LoginMsg LoginBroadcast


timelinesConfig : TimelinesT.Config Msg
timelinesConfig =
    { onUpdate = TimelinesMsg
    , onLogout = Logout
    }



-- SUBSCIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map TimelinesMsg TimelinesS.subscriptions



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Broadcast
        LoginBroadcast (LoginT.Authenticated appToken) ->
            TimelinesS.init timelinesConfig appToken
                |> Tuple.mapFirst TimelinesRoute

        Logout ->
            LoginS.logout ()
                |> \_ -> init ()

        -- Msg
        LoginMsg subMsg ->
            case model of
                LoginRoute subModel ->
                    LoginS.update subMsg subModel
                        |> translate LoginRoute LoginMsg LoginBroadcast

                _ ->
                    ( model, Cmd.none )

        TimelinesMsg subMsg ->
            case model of
                TimelinesRoute subModel ->
                    TimelinesS.update subMsg timelinesConfig subModel
                        |> Tuple.mapFirst TimelinesRoute

                _ ->
                    ( model, Cmd.none )


translate : (a -> Model) -> (b -> Msg) -> (c -> Msg) -> ( a, Cmd b, Cmd c ) -> ( Model, Cmd Msg )
translate modelTag localMsgTag broadcastMsgTag ( model, localMsg, broadcastMsg ) =
    ( modelTag model
    , Cmd.batch
        [ Cmd.map localMsgTag localMsg
        , Cmd.map broadcastMsgTag broadcastMsg
        ]
    )
