module Routes.Timelines.TweetBar.Rest exposing (sendTweet, fetchHandlerSuggestion)

import Generic.Types as SubmissionData
import Generic.Http
import Generic.Utils
import Routes.Timelines.TweetBar.Types exposing (Msg(TweetSend, SuggestedHandlersFetch, DoNothing), TweetPostedResponse)
import Twitter.Decoders exposing (userDecoder)
import Twitter.Types exposing (Tweet, User, Credentials)
import RemoteData exposing (RemoteData)
import Http
import Task
import Json.Decode exposing (Decoder, string, list)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode


tweetPostedDecoder : Decoder TweetPostedResponse
tweetPostedDecoder =
    decode TweetPostedResponse
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


sendTweet : Credentials -> Maybe Tweet -> String -> Cmd Msg
sendTweet credentials replyTweet tweetText =
    createSendBody tweetText replyTweet
        |> Generic.Http.post credentials tweetPostedDecoder "/status-update"
        |> Task.attempt
            (Generic.Utils.mapResult SubmissionData.Failure SubmissionData.Success)
        |> Cmd.map TweetSend


fetchHandlerSuggestion : Credentials -> String -> Cmd Msg
fetchHandlerSuggestion credentials handler =
    Http.encodeUri handler
        |> (++) "/user-search?q="
        |> Generic.Http.get credentials userListDecoder
        |> Task.attempt
            (Generic.Utils.mapResult RemoteData.Failure RemoteData.Success)
        |> Cmd.map (SuggestedHandlersFetch handler)
