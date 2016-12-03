module Generic.Animations exposing (..)

import Svg exposing (node, svg)
import Svg.Attributes exposing (class, viewBox, fill)
import Html.Attributes exposing (attribute)
import Html exposing (Html)


twistingCircle =
    svg
        [ class "loading-spinner"
        , viewBox "0 0 66 66"
        , attribute "xmlns" "http://www.w3.org/2000/svg"
        ]
        [ node "circle"
            [ class "loading-spinner-path"
            , attribute "cx" "33"
            , attribute "cy" "33"
            , fill "none"
            , attribute "r" "30"
            , attribute "stroke-linecap" "round"
            , attribute "stroke-width" "6"
            ]
            []
        ]


tick =
    svg
        [ class "loading-tick"
        , attribute "height" "40"
        , attribute "width" "50"
        ]
        [ node "polyline"
            [ attribute "points" "4,15 17,30 43,8"
            , attribute "style" "fill:none;stroke:#3367D6;stroke-width:5"
            ]
            []
        ]


cross =
    svg
        [ class "loading-cross"
        , attribute "height" "44"
        , attribute "width" "44"
        ]
        [ node "polyline"
            [ class "loading-cross-first"
            , attribute "points" "0,0 44,44"
            , attribute "style" "fill:none;stroke:firebrick"
            ]
            []
        , node "polyline"
            [ class "loading-cross-second"
            , attribute "points" "44,0 0,44"
            , attribute "style" "fill:none;stroke:firebrick"
            ]
            []
        ]
