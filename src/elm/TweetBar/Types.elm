module TweetBar.Types exposing (..)

import Generic.Types exposing ( SubmissionData )
import Twitter.Types exposing ( User )
import RemoteData exposing ( WebData )
import Http



type alias Model =
  { submission : SubmissionData Http.Error TweetPostedResponse String
  , tweetText : String
  , suggestedHandlers : WebData ( List User )
  }



type alias TweetPostedResponse =
    { created_at: String
    }



type Msg
    = DoNothing
    | LetterInput String
    | SubmitTweet
    | TweetSend (SubmissionData Http.Error TweetPostedResponse String)
    | RefreshTweets
    | SuggestedHandlersFetch ( WebData ( List User ) )
