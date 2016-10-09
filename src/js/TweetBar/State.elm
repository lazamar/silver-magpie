module TweetBar.State exposing ( init, update, subscriptions )
import TweetBar.Types exposing (..)


initialModel : Model
initialModel =
    { newTweetText = ""
    }


init : ( Model, Cmd Msg )
init = ( initialModel, Cmd.none)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LetterInput text ->
            ( { model | newTweetText = text }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
