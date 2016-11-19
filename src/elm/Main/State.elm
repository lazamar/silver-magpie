module Main.State exposing (..)

import Main.Types exposing (..)
import Generic.Types exposing ( SubMsg (..) )
import Routes.Login.Types as LoginT
import Routes.Timelines.Timeline.State
import Routes.Timelines.TweetBar.State
import Routes.Login.State


translate : (a -> MainModel) -> (b -> Msg) -> ( a, Cmd b ) -> ( MainModel, Cmd Msg )
translate modelTag msgTag ( one, two ) =
    ( modelTag one, Cmd.map msgTag two )




-- INITIALISATION



init =
    initLoginRoute ()
        |> translate LoginRoute LoginMsg



-- SUBSCIPTIONS



subscriptions : MainModel -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE



update : Msg -> MainModel -> ( MainModel, Cmd Msg )
update msg model =
    case msg of
        LoginMsg ( SubMsgBroadcast ( LoginT.Authenticated appToken ) ) ->
            initHomeRoute appToken

        LoginMsg ( SubMsgLocal subMsg ) ->
            case model of
                LoginRoute subModel ->
                    let
                        ( mdl, cmd ) = updateLoginRoute subMsg subModel
                    in
                        ( LoginRoute mdl, Cmd.map LoginMsg cmd )

                _ ->
                    ( model, Cmd.none )

        Logout ->
            let
                ignore = Routes.Login.State.logout ()
            in
                initLoginRoute ()
                    |> translate LoginRoute LoginMsg


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



--- LOGIN ROUTE



initLoginRoute : () -> ( LoginT.Model, Cmd ( SubMsg LoginT.Msg LoginT.Broadcast ) )
initLoginRoute _ =
    let
        ( loginModel, loginCmd, broadcastMsg ) =
            Routes.Login.State.init ()

    in
        ( loginModel
        , Cmd.batch
            [ Cmd.map SubMsgLocal loginCmd
            , Cmd.map SubMsgBroadcast broadcastMsg
            ]
        )



updateLoginRoute : LoginT.Msg -> LoginT.Model -> ( LoginT.Model, Cmd ( SubMsg LoginT.Msg LoginT.Broadcast ) )
updateLoginRoute msg model =
    let
        ( loginModel, loginCmd, broadcastMsg ) =
            Routes.Login.State.update msg model

    in
        ( loginModel
        , Cmd.batch
            [ Cmd.map SubMsgLocal loginCmd
            , Cmd.map SubMsgBroadcast broadcastMsg
            ]
        )
