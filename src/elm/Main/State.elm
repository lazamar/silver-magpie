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
        |> translate LoginRoute LoginMsg LoginBroadcast




-- SUBSCIPTIONS



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
    -- Broadcast
        LoginBroadcast ( LoginT.Authenticated appToken ) ->
            TimelinesS.init appToken
                |> translate TimelinesRoute TimelinesMsg TimelinesBroadcast

        TimelinesBroadcast TimelinesT.Logout ->
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
                    TimelinesS.update subMsg subModel
                        |> translate TimelinesRoute TimelinesMsg TimelinesBroadcast

                _ ->
                    ( model, Cmd.none )
