module Timelines.View exposing (root)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Main.Types exposing (UserDetails)
import Timelines.Timeline.View
import Timelines.TweetBar.View
import Timelines.Types exposing (..)


root : UserDetails -> Model -> Html Msg
root userDetails model =
    div [ class "Timelines" ]
        [ Timelines.Timeline.View.root model.time model.timelineModel
            |> Html.map TimelineMsg
        , Timelines.TweetBar.View.root userDetails model.tweetBarModel
            |> Html.map TweetBarMsg
        ]
