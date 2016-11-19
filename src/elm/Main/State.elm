module Main.State exposing (..)

import Main.Types exposing (..)
import Login.Types
import Timeline.State
import TweetBar.State
import Login.State


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
        Login appToken ->
            initHomeRoute appToken

        Logout ->
            Login.State.logout ()
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
            Timeline.State.init appToken

        ( tweetBarModel, tweetBarCmd, tweetBarGlobalCmd ) =
            TweetBar.State.init appToken
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
                    Timeline.State.update subMsg model.tweetsModel
            in
                ( { model | tweetsModel = updatedTweetsModel }
                , Cmd.map TweetsMsg tweetsCmd
                )

        TweetBarMsg subMsg ->
            let
                ( updatedTweetBarModel, tweetBarCmd, globalCmd ) =
                    TweetBar.State.update subMsg model.tweetBarModel
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
        ( loginModel, loginCmd, globalCmd ) =
            Login.State.init ()
    in
        ( LoginRoute loginModel
        , Cmd.batch
            [ Cmd.map LoginMsg loginCmd
            , globalCmd
            ]
        )



updateLoginRoute : Msg -> Login.Types.Model -> ( Login.Types.Model, Cmd Msg )
updateLoginRoute msg model =
    case msg of
        LoginMsg subMsg ->
            let
                ( loginModel, loginCmd, globalCmd ) =
                    Login.State.update subMsg model
            in
                ( loginModel
                , Cmd.batch
                    [ Cmd.map LoginMsg loginCmd
                    , globalCmd
                    ]
                )

        _ ->
            ( model, Cmd.none )
