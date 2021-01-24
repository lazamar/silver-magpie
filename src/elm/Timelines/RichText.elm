module Timelines.RichText exposing (..)

{-| This module transforms a string into an HTML incrementally
-}

import Html exposing (Html)
import List
import Regex exposing (Regex)


type Part msg
    = Text String
    | Html (Html msg)


replace : String -> (() -> Html msg) -> List (Part msg) -> List (Part msg)
replace needle f parts =
    let
        overText part =
            case part of
                Html _ ->
                    [ part ]

                Text haystack ->
                    case String.split needle haystack of
                        [ text ] ->
                            [ Text text ]

                        many ->
                            many
                                |> List.map Text
                                |> List.intersperse (Html <| f ())
    in
    List.concatMap overText parts


replaceRegex : Regex -> (Regex.Match -> Html msg) -> List (Part msg) -> List (Part msg)
replaceRegex pattern f parts =
    let
        overText part =
            case part of
                Html _ ->
                    [ part ]

                Text haystack ->
                    Regex.find pattern haystack
                        |> List.map (Html << f)
                        |> interleave (List.map Text <| Regex.split pattern haystack)

        interleave xs ys =
            case ( xs, ys ) of
                ( [], _ ) ->
                    ys

                ( _, [] ) ->
                    xs

                ( x :: xt, y :: yt ) ->
                    x :: y :: interleave xt yt
    in
    List.concatMap overText parts


toHtml : Part msg -> Html msg
toHtml part =
    case part of
        Text t ->
            Html.text t

        Html html ->
            html
