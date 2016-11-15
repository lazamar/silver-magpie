module TweetBar.Rest exposing ( sendTweet, fetchHandlerSuggestion )

import Generic.Types as SubmissionData
import Generic.Utils
import TweetBar.Types exposing ( Msg ( TweetSend, SuggestedHandlersFetch ), TweetPostedResponse )
import Twitter.Decoders exposing ( userDecoder )
import Twitter.Types exposing ( User )

import RemoteData exposing ( RemoteData )
import Http
import Task
import Json.Decode exposing ( Decoder, string, list )
import Json.Decode.Pipeline exposing ( decode, required )
import Json.Encode


tweetPostedDecoder : Decoder TweetPostedResponse
tweetPostedDecoder =
    decode TweetPostedResponse
        |> required "created_at" string



userListDecoder : Decoder ( List User )
userListDecoder =
    list userDecoder


-- DATA FETCHING



createSendBody : String -> Http.Body
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
            , url = Generic.Utils.sameDomain "/status-update"
            , body = createSendBody tweetText
            }
    in
        Http.send Http.defaultSettings request
            |> Http.fromJson tweetPostedDecoder
            |> Task.perform SubmissionData.Failure SubmissionData.Success
            |> Cmd.map TweetSend



fetchHandlerSuggestion : String -> Cmd Msg
fetchHandlerSuggestion handler =
    let
        url = Http.uriEncode handler
            |> (++) ( Generic.Utils.sameDomain "/user-search?q=" )
    in
        Http.get userListDecoder url
            |> Task.perform RemoteData.Failure RemoteData.Success
            |> Cmd.map ( SuggestedHandlersFetch handler )
