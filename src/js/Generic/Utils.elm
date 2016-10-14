module Generic.Utils exposing (..)

import Http

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
      "Server returned " ++ ( toString errCode ) ++ ". " ++ errDescription
