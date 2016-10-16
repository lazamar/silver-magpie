module TweetBar.Types exposing (..)

import Generic.Types exposing ( SubmissionData )
import Http



type alias Model =
  { submission: SubmissionData Http.Error TweetPostedResponse String
  , tweetText: String
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
