module Generic.Utils exposing (..)

import Generic.Types exposing (..)
import Http
import Task
import Result
import Json.Decode
import Html exposing (Attribute)
import Html.Attributes exposing (attribute)
import Date exposing (Date)


errorMessage : Http.Error -> String
errorMessage error =
    case error of
        Http.BadUrl wrongUrl ->
            "Invalid url provided: " ++ wrongUrl

        Http.Timeout ->
            "The server didn't respond on time."

        Http.NetworkError ->
            "Unable to connect to server"

        Http.BadPayload errMessage { status } ->
            "Unable to parse server response: " ++ errMessage

        Http.BadStatus { status } ->
            "Server returned " ++ (toString status.code) ++ ". " ++ status.message


toCmd : msg -> Cmd msg
toCmd msg =
    Task.succeed ()
        |> Task.perform (\_ -> msg)


tooltip : String -> Attribute msg
tooltip =
    attribute "data-title"


mapResult : (a -> msg) -> (b -> msg) -> Result a b -> msg
mapResult failure success result =
    case result of
        Result.Ok r ->
            success r

        Result.Err r ->
            failure r


dateDecoder : Json.Decode.Decoder Date
dateDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (Date.fromString
                >> mapResult
                    Json.Decode.fail
                    Json.Decode.succeed
            )


aproxHour =
    1000 * 60 * 50


day =
    hour * 24


minute =
    1000 * 60


hour =
    60 * minute


timeDifference : Date -> Date -> String
timeDifference dateFrom dateTo =
    let
        diff =
            (Date.toTime dateTo)
                - (Date.toTime dateFrom)
                |> abs
    in
        if diff < aproxHour then
            floor (diff / minute)
                |> max 1
                |> toString
                |> (flip (++)) "m"
        else if diff < day then
            floor (diff / hour)
                |> max 1
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
                        Date.Jan ->
                            "Jan"

                        Date.Feb ->
                            "Feb"

                        Date.Mar ->
                            "Mar"

                        Date.Apr ->
                            "Apr"

                        Date.May ->
                            "May"

                        Date.Jun ->
                            "Jun"

                        Date.Jul ->
                            "Jul"

                        Date.Aug ->
                            "Aug"

                        Date.Sep ->
                            "Sep"

                        Date.Oct ->
                            "Oct"

                        Date.Nov ->
                            "Nov"

                        Date.Dec ->
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
