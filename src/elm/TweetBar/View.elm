module TweetBar.View exposing (..)


import TweetBar.Types exposing (..)
import TweetBar.Handler as TwHandler
import Twitter.Types exposing ( User )
import Generic.Utils exposing ( errorMessage )
import Generic.Animations
import Generic.Types exposing
    ( SubmissionData
        ( NotSent
        , Sending
        , Success
        , Failure
        )
    )
import RemoteData exposing ( RemoteData, WebData )
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline
import String
import Regex
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


root : Model -> Html Msg
root model =
    case model.submission of
        NotSent ->
            div [ class "TweetBar"]
                [ actionBar
                , suggestions model.handlerSuggestions.users model.handlerSuggestions.userSelected
                , inputBoxView model.tweetText ( RemoteData.toMaybe model.handlerSuggestions.users )
                ]

        Sending _ ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ Generic.Animations.twistingCircle ]
                ]

        Success _ ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ Generic.Animations.tick ]
                ]

        Failure error ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ p [ class "loading-error" ]
                        [ text ( errorMessage error ) ]
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
        div [ class optionClass ]
            [ img
                [ src user.profile_image_url_https
                , class "TweetBar-suggestions-option-image"
                ] []
            , span
                [ class "TweetBar-suggestions-option-screenName" ]
                [ text ( "@" ++ user.screen_name ) ]
            , span
                [ class "TweetBar-suggestions-option-name" ]
                [ text user.name ]
            ]



suggestions : WebData ( List User ) -> Maybe Int -> Html Msg
suggestions users userSelected =
    case users of
        RemoteData.Success users ->
            let
                isSelected =
                    (\n -> case userSelected of
                        Nothing ->
                            False

                        Just num ->
                            num == n
                    )

            in
                div [ class "TweetBar-suggestions"]
                    ( List.indexedMap
                        (\index user -> userSuggestion user <| isSelected index )
                        users
                    )

        RemoteData.Loading ->
            div [ class "TweetBar-suggestions--loading"]
                [ Generic.Animations.twistingCircle ]

        _ ->
            text ""



actionBar : Html Msg
actionBar =
    div [ class "TweetBar-actions" ]
        [ button
            [ class "zmdi zmdi-mail-send TweetBar-sendBtn btn btn-default btn-icon"
            , onClick SubmitTweet
            ] []
        , button
            [ class "zmdi zmdi-refresh-alt btn btn-default btn-icon"
            , onClick RefreshTweets
            ] []
        ]



inputBoxView : String -> Maybe ( List User ) -> Html Msg
inputBoxView tweetText suggestions =
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
                  [ class "TweetBar-textBox-charCount" ]
                  [ remainingCharacters tweetText ]
            , div
                [ class "TweetBar-textBox-inputContainer"]
                [ colouredTweetView tweetText
                , textarea
                    [ class "TweetBar-textBox-input"
                    , placeholder "Write you tweet here ..."
                    , autofocus True
                    , keyListener
                    , onInput LetterInput
                    , value tweetText
                    ] []
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
                |> (flip (++) ) "&zwnj;" -- invisible character to allow line-breaks at the end of sentences
    in
        div
            [ class "TweetBar-textBox-display"
            , property "innerHTML" <| Json.Encode.string styledText
            ] []



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
            Json.Decode.customDecoder keyCode
                (\code ->
                        case code of
                            13 ->
                                Ok EnterKey

                            38 ->
                                Ok ArrowUp

                            40 ->
                                Ok ArrowDown

                            27 ->
                                Ok EscKey

                            _ ->
                                Err "Not handling that key"
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
submitOnCtrlEnter  { keyCode, ctrlKey } =
    if keyCode == 13 && ctrlKey then
        SubmitTweet
    else
        DoNothing



remainingCharacters : String -> Html Msg
remainingCharacters tweetText =
    let
        remaining = 140 - ( String.length tweetText )
        remainingText =
            remaining
                |> toString
                |> text
    in
        if remaining >= 50 then
            span [ class "enough" ] [ remainingText ]

        else if remaining > 10 then
            span [ class "quite-a-few" ] [ remainingText ]

        else if remaining >= 0 then
            span [ class "few-left" ] [ remainingText ]

        else
            span [ class "too-much" ] [ remainingText ]
