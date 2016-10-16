module Main.View exposing (..)

import Main.Types exposing ( Msg(TweetsMsg, TweetBarMsg), MainModel )
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.App

import Tweets.View
import TweetBar.View



view : MainModel -> Html Msg
view model =
    Html.div [ class "Main"]
        [ Tweets.View.root model.tweetsModel
            |> Html.App.map TweetsMsg
        , TweetBar.View.root model.tweetBarModel
            |> Html.App.map TweetBarMsg
        ]
