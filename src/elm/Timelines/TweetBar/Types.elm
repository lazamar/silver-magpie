module Timelines.TweetBar.Types exposing
    ( Config
    , KeyboardNavigation(..)
    , Model
    , Msg(..)
    , TweetPostedResponse
    , TweetText
    )

import Generic.Types exposing (SubmissionData)
import Http
import RemoteData exposing (WebData)
import Timelines.TweetBar.Handler exposing (Handler, HandlerMatch)
import Twitter.Types exposing (Credential, Tweet, User)


type alias Model =
    { submission : SubmissionData Http.Error TweetPostedResponse String
    , tweetText : String
    , inReplyTo : Maybe Tweet
    , handlerSuggestions :
        { handler : Maybe HandlerMatch
        , users : WebData (List User)
        , userSelected : Maybe Int
        }
    }


type alias Config msg =
    { onRefreshTweets : msg
    , onUpdate : Msg -> msg
    , storeTweetText : Credential -> TweetText -> msg
    }


type alias TweetPostedResponse =
    { created_at : String
    }


type alias TweetText =
    String


type KeyboardNavigation
    = EnterKey
    | EscKey
    | ArrowUp
    | ArrowDown


type Msg
    = DoNothing
    | LetterInput String
    | SubmitTweet
    | TweetSend (SubmissionData Http.Error TweetPostedResponse String)
    | SuggestedHandlersFetch Handler (WebData (List User))
    | SuggestedHandlersNavigation KeyboardNavigation
    | SuggestedHandlerSelected User
    | SetReplyTweet Tweet
