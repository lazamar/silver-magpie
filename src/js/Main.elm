module Main exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.App
import Tweets.State
import Tweets.Types
import Tweets.View
import TweetBar.State
import TweetBar.Types
import TweetBar.View


-- MESSAGES


type Msg
  = TweetsMsg Tweets.Types.Msg
  | TweetBarMsg TweetBar.Types.Msg

-- MODEL


type alias MainModel =
    { tweetsModel : Tweets.Types.Model
    , tweetBarModel : TweetBar.Types.Model
    }


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


-- VIEW


view : MainModel -> Html Msg
view model =
    Html.div [ class "Main"]
        [ Tweets.View.root model.tweetsModel
            |> Html.App.map TweetsMsg
        , TweetBar.View.root model.tweetBarModel
            |> Html.App.map TweetBarMsg
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


-- APP


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
