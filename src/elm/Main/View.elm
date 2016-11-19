module Main.View exposing (..)

import Main.Types exposing
    ( Msg( TweetsMsg, TweetBarMsg, LoginMsg )
    , MainModel ( HomeRoute, LoginRoute)
    )
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.App

import Timeline.View
import TweetBar.View
import Login.View


view : MainModel -> Html Msg
view modelRoute =
    case modelRoute of
        LoginRoute model ->
            Html.div [ class "Main"]
            [ Login.View.root model
                |> Html.App.map LoginMsg
            ]

        HomeRoute model ->
            Html.div [ class "Main"]
                [ Timeline.View.root model.tweetsModel
                    |> Html.App.map TweetsMsg
                , TweetBar.View.root model.tweetBarModel
                    |> Html.App.map TweetBarMsg
                ]
