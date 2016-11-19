module Main.State exposing (..)

import Main.Types exposing (..)
import Routes.Login.Types as LoginT
import Routes.Timelines.Timeline.State
import Routes.Timelines.TweetBar.State
import Routes.Login.State


translate : (a -> MainModel) -> (b -> Msg) -> (c -> Msg) -> ( a, Cmd b, Cmd c ) -> ( MainModel, Cmd Msg )
translate modelTag localMsgTag broadcastMsgTag ( model, localMsg, broadcastMsg ) =
    ( modelTag model
    , Cmd.batch
        [ Cmd.map localMsgTag localMsg
        , Cmd.map broadcastMsgTag broadcastMsg
        ]
    )




-- INITIALISATION



init : () -> ( MainModel, Cmd Msg )
init _ =
    Routes.Login.State.init ()
        |> translate LoginRoute LoginMsgLocal LoginMsgBroadcast




-- SUBSCIPTIONS



subscriptions : MainModel -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE



update : Msg -> MainModel -> ( MainModel, Cmd Msg )
update msg model =
    case msg of
        LoginMsgBroadcast ( LoginT.Authenticated appToken ) ->
            initHomeRoute appToken

        LoginMsgLocal subMsg ->
            case model of
                LoginRoute subModel ->
                    Routes.Login.State.update subMsg subModel
                        |> translate LoginRoute LoginMsgLocal LoginMsgBroadcast

                _ ->
                    ( model, Cmd.none )

        Logout ->
            let
                ignore = Routes.Login.State.logout ()
            in
                init ()

        _ ->
            case model of
                HomeRoute subModel ->
                    let
                        ( mdl, cmd ) = updateHomeRoute msg subModel
                    in
                        ( HomeRoute mdl, cmd )

                _ ->
                    ( model, Cmd.none )
                        |> Debug.log "ERROR SHOULD HAVE NEVER ARRIVED HERE"




--- HOME ROUTE



initHomeRoute : String -> ( MainModel, Cmd Msg )
initHomeRoute appToken =
    let
        ( tweetsModel, tweetsCmd ) =
            Routes.Timelines.Timeline.State.init appToken

        ( tweetBarModel, tweetBarCmd, tweetBarGlobalCmd ) =
            Routes.Timelines.TweetBar.State.init appToken
  in
        ( HomeRoute
            { tweetsModel = tweetsModel
            , tweetBarModel = tweetBarModel
            }
        , Cmd.batch
            [ Cmd.map TweetsMsg tweetsCmd
            , Cmd.map TweetBarMsg tweetBarCmd
            , tweetBarGlobalCmd
            ]
        )



updateHomeRoute : Msg -> HomeRouteModel -> ( HomeRouteModel, Cmd Msg )
updateHomeRoute msg model =
    case msg of
        TweetsMsg subMsg ->
            let
                ( updatedTweetsModel, tweetsCmd ) =
                    Routes.Timelines.Timeline.State.update subMsg model.tweetsModel
            in
                ( { model | tweetsModel = updatedTweetsModel }
                , Cmd.map TweetsMsg tweetsCmd
                )

        TweetBarMsg subMsg ->
            let
                ( updatedTweetBarModel, tweetBarCmd, globalCmd ) =
                    Routes.Timelines.TweetBar.State.update subMsg model.tweetBarModel
            in
                ( { model | tweetBarModel = updatedTweetBarModel }
                , Cmd.batch
                    [ Cmd.map TweetBarMsg tweetBarCmd
                    , globalCmd
                    ]
                )

        _ ->
            ( model, Cmd.none )
