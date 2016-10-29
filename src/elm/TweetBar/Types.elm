module TweetBar.Types exposing (Model, TweetPostedResponse, Msg (..))

import Generic.Types exposing ( SubmissionData )
import Twitter.Types exposing ( User )
import RemoteData exposing ( WebData )
import Http



type alias Model =
  { submission : SubmissionData Http.Error TweetPostedResponse String
  , tweetText : String
  , handlerSuggestions :
      { handler : Maybe String
      , users : WebData ( List User )
      }
  }



type alias TweetPostedResponse =
    { created_at: String
    }

type alias Handler =
    String

type Msg
    = DoNothing
    | LetterInput String
    | SubmitTweet
    | TweetSend (SubmissionData Http.Error TweetPostedResponse String)
    | RefreshTweets
    | SuggestedHandlersFetch Handler ( WebData ( List User ) )
