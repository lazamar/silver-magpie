module Routes.Timelines.View exposing (root)

import Routes.Timelines.Types exposing (..)
import Routes.Timelines.TweetBar.View
import Routes.Timelines.Timeline.View
import Html exposing (Html, div)
import Html.Attributes exposing (class)


root : Model -> Html Msg
root model =
    div [ class "Timelines" ]
        [ Routes.Timelines.Timeline.View.root model.time model.timelineModel
            |> Html.map TimelineMsg
        , Routes.Timelines.TweetBar.View.root model.tweetBarModel
            |> Html.map TweetBarMsg
        ]
