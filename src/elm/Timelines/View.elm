module Timelines.View exposing (root)

import Timelines.Types exposing (..)
import Timelines.TweetBar.View
import Timelines.Timeline.View
import Html exposing (Html, div)
import Html.Attributes exposing (class)


root : Model -> Html Msg
root model =
    div [ class "Timelines" ]
        [ Timelines.Timeline.View.root model.time model.timelineModel
            |> Html.map TimelineMsg
        , Timelines.TweetBar.View.root model.tweetBarModel
            |> Html.map TweetBarMsg
        ]
