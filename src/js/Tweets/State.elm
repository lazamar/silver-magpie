module Tweets.State exposing ( init, update, subscriptions )

import Tweets.Rest exposing ( getTweets )
import Tweets.Types exposing (..)
import Generic.Types exposing (never)
import RemoteData exposing (..)
import Task
import Http
import Process

-- MAIN FUNCTIONS



initialModel : Model
initialModel =
    { tab = HomeRoute
    , tweets = []
    , newTweets = Loading
    }



init : ( Model, Cmd Msg )
init = ( initialModel, getTweets TopTweets initialModel.tab )



-- UPDATE



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TweetFetch tweetsPosition request ->
            case request of
                Success newTweets ->
                    ( { model
                        | tweets = combineTweets tweetsPosition newTweets model.tweets
                        , newTweets = NotAsked
                        }
                    , Cmd.none
                    )

                Failure error ->
                    ( { model | newTweets = request }
                    , resetTweetFetch tweetsPosition 3000
                    )

                _ ->
                    ( { model | newTweets = request }
                    , Cmd.none
                    )

        ChangeRoute route ->
            ( { model | tab = route }
            , Cmd.none
            )



combineTweets : TweetsPosition -> (List Tweet) -> (List Tweet) -> (List Tweet)
combineTweets tweetsPosition newTweets oldTweets =
      case tweetsPosition of
          TopTweets ->
              List.concat [ newTweets, oldTweets ]

          BottomTweets ->
              List.concat [ oldTweets, newTweets ]


-- SUBSCRIPTIONS



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



resetTweetFetch : TweetsPosition -> Float -> Cmd Msg
resetTweetFetch tweetsPosition time =
    Process.sleep time
        |> Task.perform never (\_ -> TweetFetch tweetsPosition NotAsked)
