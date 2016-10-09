module TweetBar.Types exposing (..)


type alias Model =
  { newTweetText: String
  }


type Msg =
    LetterInput String
