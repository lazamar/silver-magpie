module TweetBar.Types exposing (..)

import Generic.Types exposing (..)
import Http

type alias Model =
  { newTweetText: SubmissionData Http.Error String String
  }


type Msg =
    LetterInput String
