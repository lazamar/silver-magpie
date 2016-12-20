module Timelines.View exposing (root)

import Timelines.Types exposing (..)
import Timelines.TweetBar.View
import Timelines.Timeline.View
import Main.Types exposing (UserDetails)
import Html exposing (Html, div)
import Html.Attributes exposing (class)


root : UserDetails -> Model -> Html Msg
root userDetails model =
    div [ class "Timelines" ]
        [ Timelines.Timeline.View.root model.time model.timelineModel
            |> Html.map TimelineMsg
        , Timelines.TweetBar.View.root userDetails model.tweetBarModel
            |> Html.map TweetBarMsg
        ]
