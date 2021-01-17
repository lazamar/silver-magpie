module Timelines.TweetBar.Rest exposing (fetchHandlerSuggestion, sendTweet)

import Generic.Http
import Generic.Types as SubmissionData
import Generic.Utils
import Http
import Json.Decode exposing (Decoder, list, string)
import Json.Decode.Extra exposing (hardcoded, required)
import Json.Encode
import RemoteData exposing (RemoteData)
import Task
import Timelines.TweetBar.Types exposing (Msg(..), TweetPostedResponse)
import Twitter.Decoders exposing (userDecoder)
import Twitter.Types exposing (Credential, Tweet, User)
import Url


tweetPostedDecoder : Decoder TweetPostedResponse
tweetPostedDecoder =
    Json.Decode.succeed TweetPostedResponse
        |> required "created_at" string


userListDecoder : Decoder (List User)
userListDecoder =
    list userDecoder



-- DATA FETCHING


createSendBody : String -> Maybe Tweet -> Http.Body
createSendBody tweetText replyTweet =
    let
        bodyFields =
            case replyTweet of
                Nothing ->
                    [ ( "status", Json.Encode.string tweetText ) ]

                Just tweetBeingReplied ->
                    [ ( "status", Json.Encode.string tweetText )
                    , ( "in_reply_to_status_id", Json.Encode.string tweetBeingReplied.id )
                    ]
    in
    Generic.Http.toJsonBody bodyFields


sendTweet : Credential -> Maybe Tweet -> String -> Cmd Msg
sendTweet credential replyTweet tweetText =
    createSendBody tweetText replyTweet
        |> Generic.Http.post credential tweetPostedDecoder "/status-update"
        |> Task.attempt
            (Generic.Utils.mapResult SubmissionData.Failure SubmissionData.Success)
        |> Cmd.map TweetSend


fetchHandlerSuggestion : Credential -> String -> Cmd Msg
fetchHandlerSuggestion credential handler =
    Url.percentEncode handler
        |> (++) "/user-search?q="
        |> Generic.Http.get credential userListDecoder
        |> Task.attempt
            (Generic.Utils.mapResult RemoteData.Failure RemoteData.Success)
        |> Cmd.map (SuggestedHandlersFetch handler)
