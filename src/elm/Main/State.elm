module Main.State exposing (..)

import Main.Types exposing (..)
import Login.Types
import Tweets.State
import TweetBar.State
import Login.State


-- INITIALISATION



init =
    initLoginRoute



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
            initLoginRoute

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
            Tweets.State.init appToken

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
                    Tweets.State.update subMsg model.tweetsModel
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



initLoginRoute : ( MainModel, Cmd Msg )
initLoginRoute =
    let
        ( loginModel, loginCmd ) =
            Login.State.init
    in
        ( LoginRoute loginModel
        , Cmd.map LoginMsg loginCmd
        )



updateLoginRoute : Msg -> Login.Types.Model -> ( Login.Types.Model, Cmd Msg )
updateLoginRoute msg model =
    case msg of
        LoginMsg subMsg ->
            let
                ( loginModel, loginCmd ) =
                    Login.State.update subMsg model
            in
                ( loginModel
                , Cmd.map LoginMsg loginCmd
                )

        _ ->
            ( model, Cmd.none )
