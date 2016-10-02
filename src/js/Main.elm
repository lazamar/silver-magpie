module Main exposing (..)

import Html exposing (Html)
import Html.App
import Tweets.State
import Tweets.Types
import Tweets.View



-- MESSAGES


type Msg =
  TweetsMsg Tweets.Types.Msg


-- MODEL


type alias MainModel =
    { tweetsModel : Tweets.Types.Model
    }


initialModel : MainModel
initialModel =
  let
    (tweetsModel, tweetsCmd) = Tweets.State.init
  in
    { tweetsModel = tweetsModel
    }


initialCmd : Cmd Msg
initialCmd =
  let
    (tweetsModel, tweetsCmd) = Tweets.State.init
  in
    Cmd.batch
      [ Cmd.map TweetsMsg tweetsCmd
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
      ]


-- VIEW


view : MainModel -> Html Msg
view model =
    Html.div []
        [ Tweets.View.root model.tweetsModel
            |> Html.App.map TweetsMsg
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


-- APP


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
