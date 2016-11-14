module Main.View exposing (..)

import Main.Types exposing ( Msg( TweetsMsg, TweetBarMsg, LoginMsg ), MainModel )
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.App

import Tweets.View
import TweetBar.View
import Login.View


view : MainModel -> Html Msg
view model =
    case model.loginModel.loggedIn of
        True ->
            Html.div [ class "Main"]
                [ Tweets.View.root model.tweetsModel
                    |> Html.App.map TweetsMsg
                , TweetBar.View.root model.tweetBarModel
                    |> Html.App.map TweetBarMsg
                ]

        False ->
            Html.div [ class "Main"]
                [ Login.View.root model.loginModel
                    |> Html.App.map LoginMsg
                ]
