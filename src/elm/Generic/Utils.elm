module Generic.Utils exposing (..)

import Generic.Types exposing (..)
import Http
import Task
import Result
import Html exposing (Attribute)
import Html.Attributes exposing (attribute)


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
