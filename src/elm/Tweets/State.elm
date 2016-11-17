module Tweets.State exposing ( init, update, subscriptions )

import Tweets.Rest exposing ( getTweets )
import Tweets.Types exposing (..)
import Twitter.Types exposing ( Tweet )
import Generic.Types exposing (never)
import Generic.Utils exposing (toCmd)
import Main.Types
import RemoteData exposing (..)
import Task
import Http
import Process


-- MAIN FUNCTIONS



initialModel : String -> Model
initialModel credentials =
    { credentials = credentials
    , tab = HomeRoute
    , tweets = []
    , newTweets = Loading
    }



init : String -> ( Model, Cmd Msg )
init credentials =
    ( initialModel credentials, toCmd (FetchTweets Refresh) )



-- UPDATE



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchTweets tweetsPosition ->
            ( { model | newTweets = Loading }
            , getTweets tweetsPosition model.tab
            )

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
                    , Cmd.none
                    -- , resetTweetFetch tweetsPosition 3000
                    )

                _ ->
                    ( { model | newTweets = request }
                    , Cmd.none
                    )

        ChangeRoute route ->
            ( { model | tab = route }
            , Cmd.none
            )



combineTweets : FetchType -> (List Tweet) -> (List Tweet) -> (List Tweet)
combineTweets tweetsPosition newTweets oldTweets =
      case tweetsPosition of
          Refresh ->
              newTweets

          BottomTweets ->
              List.concat [ oldTweets, newTweets ]


-- SUBSCRIPTIONS



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



resetTweetFetch : FetchType -> Float -> Cmd Msg
resetTweetFetch tweetsPosition time =
    Process.sleep time
        |> Task.perform never (\_ -> TweetFetch tweetsPosition NotAsked)
