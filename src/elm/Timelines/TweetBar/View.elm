module Timelines.TweetBar.View exposing (root, inputFieldId)

import Timelines.TweetBar.Types exposing (..)
import Timelines.TweetBar.Handler as TwHandler
import Twitter.Types exposing (User)
import Main.Types exposing (UserDetails)
import Generic.Utils exposing (errorMessage)
import Generic.Animations
import Generic.Types
    exposing
        ( SubmissionData
            ( NotSent
            , Sending
            , Success
            , Failure
            )
        )
import RemoteData exposing (RemoteData, WebData)
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline
import String
import Regex
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


root : UserDetails -> Model -> Html Msg
root userDetails model =
    case model.submission of
        NotSent ->
            div [ class "TweetBar" ]
                [ suggestions model.handlerSuggestions.users model.handlerSuggestions.userSelected
                , inputBoxView
                    model.tweetText
                    (RemoteData.toMaybe model.handlerSuggestions.users)
                    userDetails
                ]

        Sending _ ->
            div [ class "TweetBar" ]
                [ div
                    [ class "TweetBar-loading" ]
                    [ Generic.Animations.twistingCircle ]
                ]

        Success _ ->
            div [ class "TweetBar" ]
                [ div
                    [ class "TweetBar-loading" ]
                    [ Generic.Animations.tick ]
                ]

        Failure error ->
            div [ class "TweetBar" ]
                [ div
                    [ class "TweetBar-loading" ]
                    [ p [ class "loading-error" ]
                        [ text (errorMessage error) ]
                    , Generic.Animations.cross
                    ]
                ]


userSuggestion : User -> Bool -> Html Msg
userSuggestion user selected =
    let
        optionClass =
            if selected then
                "TweetBar-suggestions-option--selected"
            else
                "TweetBar-suggestions-option"
    in
        div
            [ class optionClass
            , onClick (SuggestedHandlerSelected user)
            ]
            [ img
                [ src user.profile_image_url_https
                , class "TweetBar-suggestions-option-image"
                ]
                []
            , span
                [ class "TweetBar-suggestions-option-screenName" ]
                [ text ("@" ++ user.screen_name) ]
            , span
                [ class "TweetBar-suggestions-option-name" ]
                [ text user.name ]
            ]


suggestions : WebData (List User) -> Maybe Int -> Html Msg
suggestions users userSelected =
    case users of
        RemoteData.Success users ->
            let
                isSelected =
                    (\n ->
                        case userSelected of
                            Nothing ->
                                False

                            Just num ->
                                num == n
                    )
            in
                div [ class "TweetBar-suggestions" ]
                    (List.indexedMap
                        (\index user -> userSuggestion user <| isSelected index)
                        users
                    )

        RemoteData.Loading ->
            div [ class "TweetBar-suggestions--loading" ]
                [ Generic.Animations.twistingCircle ]

        _ ->
            text ""


inputFieldId =
    "TweetBar-textBox-input"


inputBoxView : String -> Maybe (List User) -> UserDetails -> Html Msg
inputBoxView tweetText suggestions userDetails =
    let
        keyListener =
            case suggestions of
                Nothing ->
                    onKeyDown submitOnCtrlEnter

                Just _ ->
                    arrowNavigation SuggestedHandlersNavigation
    in
        div [ class "TweetBar-textBox" ]
            [ span
                [ class "TweetBar-textBox-leftColumn" ]
                [ img
                    [ src userDetails.profile_image
                    , class "TweetBar-userImage"
                    ]
                    []
                , remainingCharacters tweetText
                ]
            , div
                [ class "TweetBar-textBox-inputContainer" ]
                [ colouredTweetView tweetText
                , textarea
                    [ class "TweetBar-textBox-input"
                    , id inputFieldId
                    , placeholder "Write your tweet here ..."
                    , autofocus True
                    , keyListener
                    , onInput LetterInput
                    , value tweetText
                    ]
                    []
                ]
            ]


hashtagRegex : Regex.Regex
hashtagRegex =
    Regex.regex "(^|\\s)#[\\w]+"


colouredTweetView : String -> Html Msg
colouredTweetView tweetText =
    let
        replaceLineBreaks =
            Regex.replace Regex.All (Regex.regex "\\n") (\_ -> "<br/>")

        styledText =
            tweetText
                |> highlightMatches TwHandler.handlerRegex
                |> highlightMatches urlRegex
                |> highlightMatches hashtagRegex
                |> replaceLineBreaks
                |> (flip (++)) "&zwnj;"

        -- invisible character to allow line-breaks at the end of sentences
    in
        div
            [ class "TweetBar-textBox-display"
            , property "innerHTML" <| Json.Encode.string styledText
            ]
            []


urlRegex : Regex.Regex
urlRegex =
    Regex.regex "(https?:\\/\\/(?:www\\.|(?!www))[^\\s\\.]+\\.[^\\s]{2,}|www\\.[^\\s]+\\.[^\\s]{2,})"


highlightMatches : Regex.Regex -> String -> String
highlightMatches reg txt =
    Regex.replace
        Regex.All
        reg
        (\m -> "<span class='TweetBar-textBox-display-highlight'>" ++ m.match ++ "</span>")
        txt


arrowNavigation : (KeyboardNavigation -> msg) -> Attribute msg
arrowNavigation msg =
    let
        options =
            { preventDefault = True, stopPropagation = False }

        navigationDecoder =
            keyCode
                |> Json.Decode.andThen
                    (\code ->
                        case code of
                            13 ->
                                Json.Decode.succeed EnterKey

                            38 ->
                                Json.Decode.succeed ArrowUp

                            40 ->
                                Json.Decode.succeed ArrowDown

                            27 ->
                                Json.Decode.succeed EscKey

                            _ ->
                                Json.Decode.fail "Not handling that key"
                    )
                |> Json.Decode.map msg
    in
        onWithOptions "keydown" options navigationDecoder


onKeyDown : (KeyDownEvent -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.Decode.map tagger keyEventDecoder)


type alias KeyDownEvent =
    { keyCode : Int
    , ctrlKey : Bool
    }


keyEventDecoder : Json.Decode.Decoder KeyDownEvent
keyEventDecoder =
    Json.Decode.Pipeline.decode KeyDownEvent
        |> Json.Decode.Pipeline.required "keyCode" Json.Decode.int
        |> Json.Decode.Pipeline.required "ctrlKey" Json.Decode.bool


submitOnCtrlEnter : KeyDownEvent -> Msg
submitOnCtrlEnter { keyCode, ctrlKey } =
    if keyCode == 13 && ctrlKey then
        SubmitTweet
    else
        DoNothing


remainingCharacters : String -> Html Msg
remainingCharacters tweetText =
    let
        -- Urls occupy a maximum of 15 characters. Anything more than
        -- that should not be accounted for and should come out of
        -- the total number
        urlOverflow =
            Regex.find Regex.All urlRegex tweetText
                |> List.map .match
                |> List.map String.length
                |> List.map (\v -> v - 25 |> Basics.max 0)
                |> List.foldl (+) 0

        remaining =
            280
                - (String.length tweetText)
                + urlOverflow

        remainingText =
            remaining
                |> toString
                |> text
    in
        if remaining >= 50 then
            span [ class "TweetBar-textBox-charCount enough" ] [ remainingText ]
        else if remaining > 10 then
            span [ class "TweetBar-textBox-charCount quite-a-few" ] [ remainingText ]
        else if remaining >= 0 then
            span [ class "TweetBar-textBox-charCount few-left" ] [ remainingText ]
        else
            span [ class "TweetBar-textBox-charCount too-much" ] [ remainingText ]
