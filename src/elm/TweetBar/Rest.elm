module TweetBar.Rest exposing (..)

import Generic.Types exposing ( SubmissionData ( Failure, Success ) )
import TweetBar.Types exposing ( Msg ( TweetSend ), TweetPostedResponse )

import Http
import Task
import Json.Decode exposing ( Decoder, string )
import Json.Decode.Pipeline exposing ( decode, required )
import Json.Encode


tweetPostedDecoder : Decoder TweetPostedResponse
tweetPostedDecoder =
    decode TweetPostedResponse
        |> required "created_at" string



-- DATA FETCHING



createSendBody: String -> Http.Body
createSendBody tweetText =
    [ ( "status", (Json.Encode.string tweetText) ) ]
        |> Json.Encode.object
        |> Json.Encode.encode 2
        |> Http.string




sendTweet : String -> Cmd Msg
sendTweet tweetText =
    let
        request =
            { verb = "POST"
            , headers = [ ("Content-Type", "application/json") ]
            , url = "http://localhost:8080/statusUpdate"
            , body = createSendBody tweetText
            }
    in
        Http.send Http.defaultSettings request
            |> Http.fromJson tweetPostedDecoder
            |> Task.perform Failure Success
            |> Cmd.map TweetSend
