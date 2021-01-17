module Timelines.View exposing (root)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Main.Types exposing (UserDetails)
import Time
import Timelines.Timeline.View
import Timelines.TweetBar.View
import Timelines.Types exposing (..)


root : Time.Zone -> UserDetails -> Model -> Html Msg
root zone userDetails model =
    div [ class "Timelines" ]
        [ Timelines.Timeline.View.root zone model.now model.timelineModel
            |> Html.map TimelineMsg
        , Timelines.TweetBar.View.root userDetails model.tweetBarModel
            |> Html.map TweetBarMsg
        ]
