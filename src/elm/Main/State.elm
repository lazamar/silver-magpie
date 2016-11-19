module Main.State exposing (..)

import Main.Types exposing (..)
import Routes.Login.Types
import Routes.Timelines.Timeline.State
import Routes.Timelines.TweetBar.State
import Routes.Login.State


-- INITIALISATION



init =
    initLoginRoute ()



-- SUBSCIPTIONS



subscriptions : MainModel -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE



update : Msg -> MainModel -> ( MainModel, Cmd Msg )
update msg model =
    case msg of
        LoginBroadcast ( Routes.Login.Types.Authenticated appToken ) ->
            initHomeRoute appToken

        Logout ->
            Routes.Login.State.logout ()
                |> \_ -> initLoginRoute ()

        _ ->
            case model of
                LoginRoute subModel ->
                    let
                        ( mdl, cmd ) = updateLoginRoute msg subModel
                    in
                        ( LoginRoute mdl, cmd )

                HomeRoute subModel ->
                    let
                        ( mdl, cmd ) = updateHomeRoute msg subModel
                    in
                        ( HomeRoute mdl, cmd )




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



initLoginRoute : () -> ( MainModel, Cmd Msg )
initLoginRoute _ =
    let
        ( loginModel, loginCmd, broadcastMsg ) =
            Routes.Login.State.init ()
    in
        ( LoginRoute loginModel
        , Cmd.batch
            [ Cmd.map LoginMsg loginCmd
            , Cmd.map LoginBroadcast broadcastMsg
            ]
        )



updateLoginRoute : Msg -> Routes.Login.Types.Model -> ( Routes.Login.Types.Model, Cmd Msg )
updateLoginRoute msg model =
    case msg of
        LoginMsg subMsg ->
            let
                ( loginModel, loginCmd, broadcastMsg ) =
                    Routes.Login.State.update subMsg model
            in
                ( loginModel
                , Cmd.batch
                    [ Cmd.map LoginMsg loginCmd
                    , Cmd.map LoginBroadcast broadcastMsg
                    ]
                )

        _ ->
            ( model, Cmd.none )
