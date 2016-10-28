import Html exposing (Html, Attribute, text, div, input)
import Html.App exposing (beginnerProgram)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import String
import Regex exposing (..)


main =
  beginnerProgram { model = initialModel, view = view, update = update }


type alias Model =
  { suggestions : List String
  , text : String
  , changed : String
  }


globalSuggestions = [ "adam", "albert", "adenor", "alabama" ]



initialModel : Model
initialModel =
  { suggestions = globalSuggestions
  , text = ""
  , changed = ""
  }

-- UPDATE

type Msg = NewContent String


update : Msg -> Model -> Model
update msg model =
  case msg of
    NewContent newText ->
        let
            changedHandler =
                changedMatchingPattern (regex "(^@|\\s@)(\\w){1,15}") model.text newText
                    |> Maybe.map (replace All (regex "@") (\_ -> ""))
            changedUrl =
                changedMatchingPattern (regex "(^|\\s)(http|https)://[^\\s]+") model.text newText
            changed =
                Maybe.oneOf [changedHandler, changedUrl]
        in
            case changed of
                Nothing ->
                    { model
                    | text = newText
                    , suggestions = []
                    , changed = ""
                    }

                Just changedWord ->
                    { model
                    | text = newText
                    , suggestions = startingWithText changedWord globalSuggestions
                    , changed = changedWord
                    }



startingWithText : String -> List String -> List String
startingWithText text list =
    escape text
        |> (++) "^"
        |> regex
        |> caseInsensitive
        |> contains
        |> (flip List.filter) list



getMatches : Regex -> String -> List String
getMatches reg text =
    find All reg text
        |> List.map (\match -> match.match)



changedMatchingPattern : Regex -> String -> String -> Maybe String
changedMatchingPattern reg oldText newText =
    let
        oldMatches = getMatches reg oldText
        newMatches = getMatches reg newText
    in
        newMatches
            |> List.filter (\h ->  not <| List.member h oldMatches)
            |> List.head



-- VIEW



view : Model -> Html Msg
view model =
  div []
    [ input [ placeholder "Text to reverse", onInput NewContent, myStyle ] []
    , div [ myStyle ]
        (List.map (\s -> text (s ++ " - ")) model.suggestions)
    , div [ myStyle ]
        [ text model.changed ]
    ]



myStyle =
  style
    [ ("width", "100%")
    , ("height", "40px")
    , ("padding", "10px 0")
    , ("font-size", "2em")
    , ("text-align", "center")
    ]
