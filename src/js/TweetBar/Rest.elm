module TweetBar.Rest exposing (..)

import Generic.Types exposing ( SubmissionData ( Failure, Success ) )
import TweetBar.Types exposing ( Msg ( TweetSend ), TweetPostedResponse )

import Http
import Task
import Json.Decode exposing ( Decoder, string )
import Json.Decode.Pipeline exposing ( decode, required )



tweetPostedDecoder : Decoder TweetPostedResponse
tweetPostedDecoder =
    decode TweetPostedResponse
        |> required "created_at" string



-- DATA FETCHING



createSendBody: String -> Http.Body
createSendBody tweetText =
    Http.multipart
        [ Http.stringData "status" tweetText
        ]



sendTweet : String -> Cmd Msg
sendTweet tweetText =
    let
        url = "http://localhost:8080/statusUpdate"
    in
        Http.post tweetPostedDecoder url (createSendBody tweetText )
            |> Task.perform Failure Success
            |> Cmd.map TweetSend
