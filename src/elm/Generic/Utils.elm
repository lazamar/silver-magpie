module Generic.Utils exposing (..)

import Debug
import Exts.Result exposing (either)
import Generic.Types exposing (..)
import Html exposing (Attribute)
import Html.Attributes exposing (attribute)
import Http
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Parser exposing ((|.), (|=), Parser)
import Result
import String
import Task
import Time exposing (Month, Posix)


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
            "Server returned " ++ String.fromInt status.code ++ ". " ++ status.message


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


dateDecoder : Decoder Posix
dateDecoder =
    let
        toDateTime str =
            Parser.run dateParser str
                |> either
                    (Decode.fail << Parser.deadEndsToString)
                    Decode.succeed

        twoDigits n =
            String.right 2 <| "0" ++ String.fromInt n

        toISO8601 (DateTime dt) =
            String.fromInt dt.year
                ++ "-"
                ++ twoDigits (monthNumber dt.month)
                ++ "-"
                ++ twoDigits dt.day
                ++ "T"
                ++ dt.time
                ++ dt.utcOffset

        toPosix dateTime =
            toISO8601 dateTime
                |> Encode.string
                |> Decode.decodeValue Iso8601.decoder
                |> either
                    (Decode.fail << Decode.errorToString)
                    Decode.succeed

        twitterDateRepresentation =
            Decode.string
                |> Decode.andThen toDateTime
                |> Decode.andThen toPosix
    in
    Decode.oneOf
        [ Decode.map Time.millisToPosix Decode.int
        , twitterDateRepresentation
        ]


type DateTime
    = DateTime
        { time : String
        , utcOffset : String
        , day : Int
        , month : Month
        , year : Int
        }


dateParser : Parser DateTime
dateParser =
    let
        take count =
            let
                char =
                    Parser.chompIf (\_ -> True)

                many n =
                    List.foldl (|.) (Parser.succeed ()) <| List.repeat n char
            in
            Parser.getChompedString <| many count

        createDateTime month d time offset year =
            DateTime
                { time = time
                , utcOffset = offset
                , day = d
                , month = month
                , year = year
                }

        parseDay =
            Parser.oneOf
                [ Parser.int

                -- Leading zero
                , Parser.succeed identity
                    |. Parser.chompIf (\v -> v == '0')
                    |= Parser.int
                ]

        parseMonth =
            Parser.andThen (either Parser.problem Parser.succeed) <|
                Parser.succeed stringToMonth
                    |= take 3
    in
    Parser.succeed createDateTime
        |. take 4
        |. Parser.spaces
        |= parseMonth
        |. Parser.spaces
        |= parseDay
        |. Parser.spaces
        |= take 8
        |. Parser.spaces
        |= take 5
        |. Parser.spaces
        |= Parser.int
        |. Parser.end


monthNumber : Time.Month -> Int
monthNumber m =
    case m of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


stringToMonth : String -> Result String Time.Month
stringToMonth str =
    case str of
        "Jan" ->
            Ok Time.Jan

        "Feb" ->
            Ok Time.Feb

        "Mar" ->
            Ok Time.Mar

        "Apr" ->
            Ok Time.Apr

        "May" ->
            Ok Time.May

        "Jun" ->
            Ok Time.Jun

        "Jul" ->
            Ok Time.Jul

        "Aug" ->
            Ok Time.Aug

        "Sep" ->
            Ok Time.Sep

        "Oct" ->
            Ok Time.Oct

        "Nov" ->
            Ok Time.Nov

        "Dec" ->
            Ok Time.Dec

        _ ->
            Err <| "Invalid month: " ++ str


monthName : Time.Month -> String
monthName month =
    case month of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"


timeDifference : Time.Zone -> Posix -> Posix -> String
timeDifference zone dateFrom dateTo =
    let
        minuteMilli =
            1000 * 60

        hourMilli =
            60 * minuteMilli

        dayMilli =
            hourMilli * 24

        aproxHour =
            minuteMilli * 50

        diff =
            Time.posixToMillis dateTo
                - Time.posixToMillis dateFrom
                |> abs
                |> toFloat
    in
    if diff < aproxHour then
        floor (diff / minuteMilli)
            |> max 1
            |> String.fromInt
            |> (\b a -> (++) a b) "m"

    else if diff < dayMilli then
        floor (diff / hourMilli)
            |> max 1
            |> String.fromInt
            |> (\b a -> (++) a b) "h"

    else
        let
            theYear =
                if Time.toYear zone dateFrom /= Time.toYear zone dateTo then
                    Time.toYear zone dateTo
                        |> String.fromInt
                        |> Just

                else
                    Nothing

            theMonth =
                monthName <| Time.toMonth zone dateTo

            theDay =
                Time.toDay zone dateTo
                    |> String.fromInt
        in
        case theYear of
            Just aYear ->
                theMonth ++ " " ++ theDay ++ " " ++ aYear

            Nothing ->
                theMonth ++ " " ++ theDay
