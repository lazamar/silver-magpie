module TweetBar.Animations exposing (..)
import Svg exposing (node, svg)
import Svg.Attributes exposing (class, viewBox, fill)
import Html.Attributes exposing (attribute)
import Html exposing (Html)



twistingCircle =
    svg [ class "TweetBar-loading-spinner"
        , viewBox "0 0 66 66"
        , attribute "xmlns" "http://www.w3.org/2000/svg"
        ]
        [ node "circle"
            [ class "TweetBar-loading-spinner-path"
            , attribute "cx" "33"
            , attribute "cy" "33"
            , fill "none"
            , attribute "r" "30"
            , attribute "stroke-linecap" "round"
            , attribute "stroke-width" "6"
            ] []
        ]



tick =
    svg
        [ class "TweetBar-loading-tick"
        , attribute "height" "120"
        , attribute "width" "140"
        ]
        [ node "polyline"
            [ attribute "points" "10,45 50,90 130,20"
            , attribute "style" "fill:none;stroke:#3367D6;stroke-width:15"
            ] []
        ]
