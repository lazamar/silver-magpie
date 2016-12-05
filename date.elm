-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/user_input/buttons.html


module Main exposing (..)

import Html exposing (program, div, button, text)
import Html.Events exposing (onClick)
import Date exposing (..)
import Date
import Task


type alias Model =
    { mainDate : Maybe Date
    , tryingToParse : Maybe Date
    }


type Msg
    = MainDate (Result String Date.Date)
    | TryingDate (Result String Date.Date)


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : ( Model, Cmd Msg )
init =
    let
        initialModel =
            { mainDate = Nothing
            , tryingToParse = Nothing
            }

        initialCommand =
            Cmd.batch
                [ Task.attempt MainDate Date.now
                , Date.fromString "Sun Dec 04 12:00:39 +0000 2016"
                    |> TryingDate
                    |> toCmd
                ]
    in
        ( initialModel, initialCommand )


toCmd msg =
    Task.succeed ()
        |> Task.perform (\_ -> msg)


view { mainDate, tryingToParse } =
    Maybe.map2
        timeDiff
        mainDate
        tryingToParse
        |> Maybe.withDefault ("")
        |> toString
        |> text


aproxHour =
    1000 * 60 * 50


aproxDay =
    1000 * 60 * 60 * 23


minute =
    1000 * 60


hour =
    60 * minute


timeDiff : Date -> Date -> String
timeDiff dateFrom dateTo =
    let
        diff =
            (-)
                (Debug.log "Date to" (Date.toTime dateTo))
                (Debug.log "Date from" (Date.toTime dateFrom))
                |> abs
    in
        if (Debug.log "Diff" diff) < aproxHour then
            floor (diff / minute)
                |> toString
                |> (flip (++)) "m"
        else if diff < aproxDay then
            floor (diff / hour)
                |> toString
                |> (flip (++)) "h"
        else
            let
                year =
                    if Date.year dateFrom /= Date.year dateTo then
                        Date.year dateTo
                            |> toString
                            |> Just
                    else
                        Nothing

                month =
                    case Date.month dateTo of
                        Jan ->
                            "Jan"

                        Feb ->
                            "Feb"

                        Mar ->
                            "Mar"

                        Apr ->
                            "Apr"

                        May ->
                            "May"

                        Jun ->
                            "Jun"

                        Jul ->
                            "Jul"

                        Aug ->
                            "Aug"

                        Sep ->
                            "Sep"

                        Oct ->
                            "Oct"

                        Nov ->
                            "Nov"

                        Dec ->
                            "Dec"

                day =
                    Date.day dateTo
                        |> toString
            in
                case year of
                    Just aYear ->
                        month ++ " " ++ day ++ " " ++ aYear

                    Nothing ->
                        month ++ " " ++ day


update msg model =
    case msg of
        MainDate (Ok d) ->
            ( { model | mainDate = Just d }, Cmd.none )

        MainDate (Err d) ->
            ( { model | mainDate = Nothing }, Cmd.none )

        TryingDate (Ok d) ->
            ( { model | tryingToParse = Just d }, Cmd.none )

        TryingDate (Err d) ->
            ( { model | tryingToParse = Nothing }, Cmd.none )
