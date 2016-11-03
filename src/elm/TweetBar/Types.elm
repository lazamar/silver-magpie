module TweetBar.Types exposing
    ( Model
    , TweetPostedResponse
    , Msg (..)
    , KeyboardNavigation (..)
    )

import Generic.Types exposing ( SubmissionData )
import Twitter.Types exposing ( User )
import RemoteData exposing ( WebData )
import Http
import Regex



type alias Model =
  { submission : SubmissionData Http.Error TweetPostedResponse String
  , tweetText : String
  , handlerSuggestions :
      { handler : Maybe Regex.Match
      , users : WebData ( List User )
      , userSelected : Maybe Int
      }
  }



type alias TweetPostedResponse =
    { created_at: String
    }



type alias Handler =
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
    | RefreshTweets
    | SuggestedHandlersFetch Handler ( WebData ( List User ) )
    | SuggestedHandlersNavigation KeyboardNavigation
