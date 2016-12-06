module Routes.Timelines.View exposing (root)

import Routes.Timelines.Types exposing (..)
import Routes.Timelines.TweetBar.View
import Routes.Timelines.Timeline.View
import Generic.Utils exposing (tooltip)
import List.Extra
import Html exposing (Html, div, button, text, span)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html


root : Model -> Html Msg
root model =
    div [ class "Timelines" ]
        [ Routes.Timelines.Timeline.View.root model.timelineModel
            |> Html.map TimelineMsg
        , Routes.Timelines.TweetBar.View.root model.tweetBarModel
            |> Html.map TweetBarMsg
        , footer model.footerMessageNumber
        ]


footer : Int -> Html Msg
footer footerMessageNumber =
    div [ class "Timelines-footer" ]
        [ button
            [ class "zmdi zmdi-collection-item btn btn-default btn-icon"
            , tooltip "Detach window"
            , onClick Detach
            ]
            []
        , span
            [ class "Timelines-footer-cues animated fadeInUp" ]
            [ text <| footerMessage footerMessageNumber ]
        , button
            [ class "zmdi zmdi-power btn btn-default btn-icon"
            , tooltip "Logout"
            , onClick MsgLogout
            ]
            []
        ]


footerMessage : Int -> String
footerMessage seed =
    let
        messagesLength =
            List.length footerMessages

        msgNumber =
            seed % messagesLength
    in
        List.Extra.getAt msgNumber footerMessages
            |> Maybe.withDefault ""


footerMessages =
    [ "You can open Silver Magpie with Ctrl+Alt+1"
    , "Use Ctrl+Enter to send your tweet"
    , "Use arrows to navigate handler suggestions"
    ]
