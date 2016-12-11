module Routes.Timelines.TweetBar.Types
    exposing
        ( Model
        , TweetPostedResponse
        , Msg(..)
        , KeyboardNavigation(..)
        , UpdateConfig
        )

import Routes.Timelines.TweetBar.Handler exposing (Handler, HandlerMatch)
import Generic.Types exposing (SubmissionData)
import Twitter.Types exposing (Tweet, User)
import RemoteData exposing (WebData)
import Http


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


type alias UpdateConfig msg =
    { refreshTweets : msg
    , update : Msg -> msg
    }


type alias TweetPostedResponse =
    { created_at : String
    }


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
