module TweetBar.Types exposing (..)

import Generic.Types exposing ( SubmissionData )
import Http



type alias Model =
  { newTweetText: SubmissionData Http.Error TweetPostedResponse String
  }



type alias TweetPostedResponse =
    { created_at: String
    }



type Msg
    = LetterInput String
    | SubmitButtonPressed
    | TweetSend (SubmissionData Http.Error TweetPostedResponse String)
