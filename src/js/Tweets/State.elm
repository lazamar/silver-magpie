module Tweets.State exposing ( init, update, subscriptions )

import AJAX.Types exposing (serverMsgDecoder)
import Tweets.Types exposing (..)
import Task
import Http



-- MAIN FUNCTIONS



initialModel : Model
initialModel =
  { tab = "home"
  , error = Nothing
  , tweets = []
  }



init : ( Model, Cmd Msg )
init = ( initialModel, getTweets initialModel.tab )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    TweetFetchFail err ->
      ( { model | error = Just err }, Cmd.none )
    TweetFetchSucceed tweetList ->
      ( { model | tweets = tweetList }, Cmd.none )




subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HELPER FUNCTIONS



getTweets : String -> Cmd Msg
getTweets section =
  let
    url = "http://localhost:8080/" ++ section
  in
    Task.perform TweetFetchFail TweetFetchSucceed (Http.get serverMsgDecoder url)
