module Main.State exposing (..)

import Main.Types exposing (..)
import Routes.Login.Types as LoginT
import Routes.Login.State as LoginS
import Routes.Timelines.Types as TimelinesT
import Routes.Timelines.State as TimelinesS


translate : (a -> Model) -> (b -> Msg) -> (c -> Msg) -> ( a, Cmd b, Cmd c ) -> ( Model, Cmd Msg )
translate modelTag localMsgTag broadcastMsgTag ( model, localMsg, broadcastMsg ) =
    ( modelTag model
    , Cmd.batch
        [ Cmd.map localMsgTag localMsg
        , Cmd.map broadcastMsgTag broadcastMsg
        ]
    )




-- INITIALISATION



init : () -> ( Model, Cmd Msg )
init _ =
    LoginS.init ()
        |> translate LoginRoute LoginMsgLocal LoginMsgBroadcast




-- SUBSCIPTIONS



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginMsgBroadcast ( LoginT.Authenticated appToken ) ->
            TimelinesS.init appToken
                |> translate TimelinesRoute TimelinesMsgLocal TimelinesMsgBroadcast

        LoginMsgLocal subMsg ->
            case model of
                LoginRoute subModel ->
                    LoginS.update subMsg subModel
                        |> translate LoginRoute LoginMsgLocal LoginMsgBroadcast

                _ ->
                    ( model, Cmd.none )

        TimelinesMsgBroadcast TimelinesT.Logout ->
            LoginS.logout ()
                |> \_ -> init ()

        TimelinesMsgLocal subMsg ->
            case model of
                TimelinesRoute subModel ->
                    TimelinesS.update subMsg subModel
                        |> translate TimelinesRoute TimelinesMsgLocal TimelinesMsgBroadcast

                _ ->
                    ( model, Cmd.none )
