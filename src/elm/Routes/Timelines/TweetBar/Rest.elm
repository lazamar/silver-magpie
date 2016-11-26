module Routes.Timelines.TweetBar.Rest exposing ( sendTweet, fetchHandlerSuggestion )

import Generic.Types as SubmissionData
import Generic.Http
import Generic.Utils
import Routes.Timelines.TweetBar.Types exposing ( Msg ( TweetSend, SuggestedHandlersFetch, DoNothing ), TweetPostedResponse )
import Twitter.Decoders exposing ( userDecoder )
import Twitter.Types exposing ( User, Credentials )


import RemoteData exposing ( RemoteData )
import Http
import Task
import Json.Decode exposing ( Decoder, string, list )
import Json.Decode.Pipeline exposing ( decode, required, hardcoded )
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
        |> Generic.Http.toJsonBody




sendTweet : Credentials -> String -> Cmd Msg
sendTweet credentials tweetText =
    createSendBody tweetText
        |> Generic.Http.post credentials "/status-update"
        |> Http.fromJson tweetPostedDecoder
        |> Task.perform SubmissionData.Failure SubmissionData.Success
        |> Cmd.map TweetSend



fetchHandlerSuggestion : Credentials -> String -> Cmd Msg
fetchHandlerSuggestion credentials handler =
    Http.uriEncode handler
        |> (++) "/user-search?q="
        |> Generic.Http.get credentials
        |> Http.fromJson userListDecoder
        |> Task.perform RemoteData.Failure RemoteData.Success
        |> Cmd.map ( SuggestedHandlersFetch handler )
