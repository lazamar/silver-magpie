module Generic.Utils exposing (..)

import Generic.Types exposing (..)
import Http
import Task
import Html exposing (Attribute)
import Html.Attributes exposing (attribute)


errorMessage : Http.Error -> String
errorMessage error =
    case error of
        Http.Timeout ->
            "The server didn't respond on time."

        Http.NetworkError ->
            "Unable to connect to server"

        Http.UnexpectedPayload errDescription ->
            "Unable to parse server response: " ++ errDescription

        Http.BadResponse errCode errDescription ->
            "Server returned " ++ (toString errCode) ++ ". " ++ errDescription


toCmd : msg -> Cmd msg
toCmd message =
    Task.perform never identity (Task.succeed message)


tooltip : String -> Attribute msg
tooltip =
    attribute "data-title"
