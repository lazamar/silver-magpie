module Routes.Timelines.View exposing ( root )

import Routes.Timelines.Types exposing (..)
import Routes.Timelines.TweetBar.View
import Routes.Timelines.Timeline.View
import Html exposing ( Html, div )
import Html.App



root : Model -> Html Msg
root model =
    div []
        [ Routes.Timelines.Timeline.View.root model.timelineModel
            |> Html.App.map TimelineMsgLocal

        , Routes.Timelines.TweetBar.View.root model.tweetBarModel
            |> Html.App.map TweetBarMsgLocal
        ]
