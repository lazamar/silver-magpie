module Routes.Timelines.View exposing ( root )

import Routes.Timelines.Types exposing (..)
import Routes.Timelines.TweetBar.View
import Routes.Timelines.Timeline.View
import Html exposing ( Html, div )
import Html.Attributes exposing ( class )
import Html.App



root : Model -> Html Msg
root model =
    div [ class "Timelines" ]
        [ Routes.Timelines.Timeline.View.root model.timelineModel
            |> Html.App.map TimelineMsg

        , Routes.Timelines.TweetBar.View.root model.tweetBarModel
            |> Html.App.map TweetBarMsg
        ]
