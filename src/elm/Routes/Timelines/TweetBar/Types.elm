module Routes.Timelines.TweetBar.Types exposing
    ( Model
    , TweetPostedResponse
    , Msg (..)
    , Broadcast (..)
    , KeyboardNavigation (..)
    )

import Routes.Timelines.TweetBar.Handler exposing ( Handler, HandlerMatch )
import Generic.Types exposing ( SubmissionData )
import Twitter.Types exposing ( User, Credentials )
import RemoteData exposing ( WebData )
import Http



type alias Model =
  { credentials: Credentials
  , submission : SubmissionData Http.Error TweetPostedResponse String
  , tweetText : String
  , handlerSuggestions :
      { handler : Maybe HandlerMatch
      , users : WebData ( List User )
      , userSelected : Maybe Int
      }
  }



type alias TweetPostedResponse =
    { created_at: String
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
    | MsgRefreshTweets
    | MsgLogout
    | SuggestedHandlersFetch Handler ( WebData ( List User ) )
    | SuggestedHandlersNavigation KeyboardNavigation



type Broadcast
    = Logout
    | RefreshTweets
