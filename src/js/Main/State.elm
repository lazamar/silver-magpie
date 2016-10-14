module Main.State exposing (..)

import Main.Types exposing (..)
import Tweets.State
import TweetBar.State


-- INITIALISATION



initialModel : MainModel
initialModel =
  let
    (tweetsModel, tweetsCmd) =
      Tweets.State.init
    (tweetBarModel, tweetBarCmd) =
      TweetBar.State.init
  in
    { tweetsModel = tweetsModel
    , tweetBarModel = tweetBarModel
    }



initialCmd : Cmd Msg
initialCmd =
  let
    (tweetsModel, tweetsCmd) =
      Tweets.State.init
    (tweetBarModel, tweetBarCmd) =
      TweetBar.State.init
  in
    Cmd.batch
      [ Cmd.map TweetsMsg tweetsCmd
      , Cmd.map TweetBarMsg tweetBarCmd
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
                ( { model | tweetsModel = updatedTweetsModel }, Cmd.map TweetsMsg tweetsCmd )

        TweetBarMsg subMsg ->
            let
                ( updatedTweetBarModel, tweetBarCmd ) =
                    TweetBar.State.update subMsg model.tweetBarModel
            in
                ( { model | tweetBarModel = updatedTweetBarModel }, Cmd.map TweetBarMsg tweetBarCmd )
