module Main.State exposing (..)

import Main.Types exposing (..)
import Tweets.State
import TweetBar.State
import Login.State


-- INITIALISATION



initialModel : MainModel
initialModel =
  let
    ( tweetsModel, tweetsCmd ) =
        Tweets.State.init

    ( tweetBarModel, tweetBarCmd, tweetBarGlobalCmd ) =
        TweetBar.State.init

    ( loginModel, loginCmd ) =
        Login.State.init

  in
    { tweetsModel = tweetsModel
    , tweetBarModel = tweetBarModel
    , loginModel = loginModel
    }



initialCmd : Cmd Msg
initialCmd =
  let
    ( tweetsModel, tweetsCmd ) =
        Tweets.State.init

    ( tweetBarModel, tweetBarCmd, tweetBarGlobalCmd ) =
        TweetBar.State.init

    ( loginModel, loginCmd ) =
        Login.State.init

  in
    Cmd.batch
      [ Cmd.map TweetsMsg tweetsCmd
      , Cmd.map TweetBarMsg tweetBarCmd
      , Cmd.map LoginMsg loginCmd
      , tweetBarGlobalCmd
      ]



init : ( MainModel, Cmd Msg )
init =
    ( initialModel, initialCmd )



-- SUBSCIPTIONS



subscriptions : MainModel -> Sub Msg
subscriptions model =
    Sub.batch
      [ Tweets.State.subscriptions model.tweetsModel
          |> Sub.map TweetsMsg
      , TweetBar.State.subscriptions model.tweetBarModel
          |> Sub.map TweetBarMsg
      ]



-- UPDATE



update : Msg -> MainModel -> ( MainModel, Cmd Msg )
update message model =
    case message of
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

        LoginMsg subMsg ->
            let
                ( updatedLoginModel, loginCmd ) =
                    Login.State.update subMsg model.loginModel
            in
                ( { model | loginModel = updatedLoginModel }
                , Cmd.map LoginMsg loginCmd
                )
