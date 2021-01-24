module Timelines.TweetBar.View exposing (inputFieldId, root)

import Generic.Animations
import Generic.Types
    exposing
        ( SubmissionData(..)
        )
import Generic.Utils exposing (errorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode
import Main.Types exposing (UserDetails)
import Regex
import Regex.Extra exposing (regex)
import RemoteData exposing (RemoteData, WebData)
import String
import Timelines.RichText as RichText
import Timelines.TweetBar.Handler as TwHandler
import Timelines.TweetBar.Types exposing (..)
import Twitter.Types exposing (User)


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
suggestions wusers userSelected =
    case wusers of
        RemoteData.Success users ->
            let
                isSelected =
                    \n ->
                        case userSelected of
                            Nothing ->
                                False

                            Just num ->
                                num == n
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
inputBoxView tweetText msuggestions userDetails =
    let
        keyListener =
            case msuggestions of
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
    regex "(^|\\s)#[\\w]+"


colouredTweetView : String -> Html Msg
colouredTweetView tweetText =
    let
        replaceLineBreaks =
            RichText.replace "\\n" (\() -> Html.br [] [])

        styledText =
            [ RichText.Text tweetText ]
                |> highlightMatches TwHandler.handlerRegex
                |> highlightMatches urlRegex
                |> highlightMatches hashtagRegex
                |> replaceLineBreaks
                -- invisible character to allow line-breaks at the end of sentences
                |> (\parts -> parts ++ [ RichText.Text "\u{200C}" ])
                |> List.map RichText.toHtml
    in
    div [ class "TweetBar-textBox-display" ] styledText


urlRegex : Regex.Regex
urlRegex =
    regex "(https?:\\/\\/(?:www\\.|(?!www))[^\\s\\.]+\\.[^\\s]{2,}|www\\.[^\\s]+\\.[^\\s]{2,})"


highlightMatches : Regex.Regex -> List (RichText.Part Msg) -> List (RichText.Part Msg)
highlightMatches reg parts =
    let
        highlighted m =
            Html.span
                [ class "TweetBar-textBox-display-highlight" ]
                [ text m.match ]
    in
    RichText.replaceRegex reg highlighted parts


arrowNavigation : (KeyboardNavigation -> msg) -> Attribute msg
arrowNavigation msg =
    let
        alwaysPrventDefaultOn event decoder =
            decoder
                |> Decode.map (\v -> ( v, True ))
                |> preventDefaultOn event

        navigationDecoder =
            keyCode
                |> Decode.andThen
                    (\code ->
                        case code of
                            13 ->
                                Decode.succeed EnterKey

                            38 ->
                                Decode.succeed ArrowUp

                            40 ->
                                Decode.succeed ArrowDown

                            27 ->
                                Decode.succeed EscKey

                            _ ->
                                Decode.fail "Not handling that key"
                    )
                |> Decode.map msg
    in
    alwaysPrventDefaultOn "keydown" navigationDecoder


onKeyDown : (KeyDownEvent -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyEventDecoder)


type alias KeyDownEvent =
    { keyCode : Int
    , ctrlKey : Bool
    }


keyEventDecoder : Decode.Decoder KeyDownEvent
keyEventDecoder =
    Decode.map2 KeyDownEvent
        (Decode.field "keyCode" Decode.int)
        (Decode.field "ctrlKey" Decode.bool)


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
            Regex.find urlRegex tweetText
                |> List.map .match
                |> List.map String.length
                |> List.map (\v -> v - 25 |> Basics.max 0)
                |> List.foldl (+) 0

        remaining =
            280
                - String.length tweetText
                + urlOverflow

        remainingText =
            remaining
                |> String.fromInt
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
