port module Main.State exposing
    ( Flags
    , credentialInUse
    , init
    , subscriptions
    , update
    )

import Dict
import Generic.Detach
import Generic.Http
import Generic.LocalStorage as LocalStorage
import Generic.Utils exposing (toCmd)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Extra as D
import Json.Encode as Encode
import Json.Encode.Extra as E
import List.Extra
import Main.CredentialsHandler as CredentialsHandler
import Main.Rest exposing (fetchCredential)
import Main.Types exposing (..)
import Process
import Random
import RemoteData
import String
import Task
import Time exposing (Posix)
import Timelines.State as TimelinesS
import Timelines.Timeline.Types exposing (HomeTweets(..), MentionsTweets(..))
import Timelines.Types as TimelinesT exposing (SessionInfo)
import Twitter.Deserialisers as Twitter
import Twitter.Serialisers as Twitter
import Twitter.Types exposing (Credential)



-- INITIALISATION


emptyModel : Posix -> Random.Seed -> Model
emptyModel now seed =
    { timelinesModel = Nothing
    , sessionID = Nothing
    , usersDetails = []
    , footerMessageNumber = FooterMsg 0
    , randomSeed = seed
    , now = now

    -- UTC temporarily while we fetch the local timezone
    , zone = Time.utc
    , timelinesInfo = Dict.empty
    }


initSessionID : Model -> ( Model, Cmd Msg )
initSessionID model =
    case model.sessionID of
        Just (NotAttempted sid) ->
            ( model, fetchCredential sid )

        _ ->
            Tuple.second <| newSessionID model


type alias Flags =
    { localStorage : Value
    , timeNow : Int
    , randomInt : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ldecoder =
            Decode.string
                |> Decode.andThen
                    (\str ->
                        case Decode.decodeString localStorageDecoder str of
                            Ok r ->
                                Decode.succeed r

                            Err err ->
                                Decode.fail <| Decode.errorToString err
                    )

        mLocalStorage =
            Decode.decodeValue ldecoder flags.localStorage
                |> Debug.log "decoded local storage"
                |> Result.toMaybe

        modelRaw =
            emptyModel
                (Time.millisToPosix flags.timeNow)
                (Random.initialSeed flags.randomInt)

        addLocalStorage aModel =
            case mLocalStorage of
                Nothing ->
                    aModel

                Just ls ->
                    loadLocalStorage ls aModel

        selectFirstCredential aModel =
            case aModel.usersDetails of
                u :: _ ->
                    selectAccount aModel u.credential

                _ ->
                    ( aModel, Cmd.none )

        ( model, cmds ) =
            ( addLocalStorage modelRaw, Cmd.none )
                |> andThen initSessionID
                |> andThen selectFirstCredential
    in
    ( model
    , Cmd.batch
        [ Task.perform TimeZone Time.here
        , cmds
        ]
    )


andThen : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
andThen f ( model, cmd ) =
    let
        ( newModel, newCmds ) =
            f model
    in
    ( newModel, Cmd.batch [ cmd, newCmds ] )


timelinesConfig : TimelinesT.Config Msg
timelinesConfig =
    { onUpdate = TimelinesMsg
    , onLogout = Logout
    , storeHome = StoreHome
    , storeMentions = StoreMentions
    , storeTweetText = StoreTweetText
    }



-- SUBSCIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map TimelinesMsg TimelinesS.subscriptions



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none )

        TimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        LoadedUsersDetails usersDetails ->
            case usersDetails of
                [] ->
                    ( model, Cmd.none )

                x :: _ ->
                    update
                        (SelectAccount x.credential)
                        { model | usersDetails = usersDetails }

        TimelinesMsg subMsg ->
            updateTimelinesModel model subMsg

        UserCredentialFetch authentication ->
            case authentication of
                Authenticated sessionID userDetails ->
                    let
                        ( newSeed, newId ) =
                            CredentialsHandler.generateSessionID
                                model.now
                                model.randomSeed

                        ( newModel, newCmd ) =
                            update
                                (SelectAccount userDetails.credential)
                                { model
                                    | sessionID = Just <| NotAttempted newId
                                    , usersDetails = model.usersDetails ++ [ userDetails ]
                                    , randomSeed = newSeed
                                }
                    in
                    ( newModel
                    , Cmd.batch
                        [ newCmd
                        , saveLocalStorage newModel
                        ]
                    )

                NotAttempted anID ->
                    ( { model | sessionID = Just <| Authenticating anID }
                    , fetchCredential anID
                    )

                _ ->
                    ( { model | sessionID = Just <| authentication }
                    , Cmd.none
                    )

        SelectAccount credential ->
            selectAccount model credential

        CurrentFooterMsg fmsg ->
            let
                newModel =
                    { model | footerMessageNumber = fmsg }
            in
            ( newModel
            , saveLocalStorage newModel
            )

        Logout credential ->
            let
                newDetails =
                    List.filter
                        (\d -> d.credential /= credential)
                        model.usersDetails

                newModel =
                    { model | usersDetails = newDetails }

                ( m, cmd ) =
                    case newDetails of
                        [] ->
                            Tuple.second <| newSessionID newModel

                        x :: _ ->
                            selectAccount newModel x.credential
            in
            ( m
            , Cmd.batch
                [ cmd
                , saveLocalStorage m
                ]
            )

        StoreHome cred h ->
            storeTimelineInfo
                cred
                { emptySessionInfo | homeTweets = h }
                (\s -> { s | homeTweets = h })
                model

        StoreMentions cred m ->
            storeTimelineInfo
                cred
                { emptySessionInfo | mentionsTweets = m }
                (\s -> { s | mentionsTweets = m })
                model

        StoreTweetText cred t ->
            storeTimelineInfo
                cred
                { emptySessionInfo | tweetText = t }
                (\s -> { s | tweetText = t })
                model

        Detach ->
            ( model
            , Generic.Detach.detach 400 600
            )

        SignIn ->
            let
                ( sid, ( newModel, cmd ) ) =
                    newSessionID model
            in
            ( newModel
            , Cmd.batch
                [ cmd

                -- We redirect to twitter after a delay to make sure that
                -- the new session ID will have time to be saved.
                , Process.sleep 50
                    |> Task.perform (always <| RedirectToTwitter sid)
                ]
            )

        RedirectToTwitter sid ->
            ( model
            , "/sign-in/?app_session_id="
                ++ sid
                |> Generic.Http.sameDomain
                |> port_Main_openInNewTab
            )


selectAccount : Model -> Credential -> ( Model, Cmd Msg )
selectAccount model credential =
    let
        selectedUserDetails =
            List.Extra.find
                (\d -> d.credential == credential)
                model.usersDetails
    in
    case selectedUserDetails of
        Nothing ->
            ( model, Cmd.none )

        Just details ->
            let
                newUsersDetails =
                    model.usersDetails
                        |> List.filter ((/=) details)
                        |> (::) details

                cred =
                    details.credential

                ( timelinesModel, timelinesCmd ) =
                    case Dict.get cred model.timelinesInfo of
                        Nothing ->
                            TimelinesS.init emptySessionInfo timelinesConfig details.credential

                        Just sessionInfo ->
                            TimelinesS.init sessionInfo timelinesConfig details.credential

                newModel =
                    { model
                        | timelinesModel = Just timelinesModel
                        , usersDetails = newUsersDetails
                    }
            in
            ( newModel
            , Cmd.batch
                [ timelinesCmd
                , saveLocalStorage newModel
                ]
            )


newSessionID : Model -> ( SessionID, ( Model, Cmd Msg ) )
newSessionID model =
    let
        ( newSeed, sessionID ) =
            CredentialsHandler.generateSessionID
                model.now
                model.randomSeed

        newModel =
            { model
                | randomSeed = newSeed
                , sessionID = Just (Authenticating sessionID)
            }
    in
    ( sessionID
    , ( newModel
      , Cmd.batch
            [ saveLocalStorage newModel
            , fetchCredential sessionID
            ]
      )
    )


emptySessionInfo : SessionInfo
emptySessionInfo =
    { tweetText = ""
    , homeTweets = HomeTweets []
    , mentionsTweets = MentionsTweets []
    }


updateTimelinesModel : Model -> TimelinesT.Msg -> ( Model, Cmd Msg )
updateTimelinesModel model subMsg =
    let
        maybeTuple =
            Maybe.map2
                (\c m -> TimelinesS.update subMsg timelinesConfig c m)
                (credentialInUse model.usersDetails)
                model.timelinesModel
    in
    case maybeTuple of
        Nothing ->
            ( model, Cmd.none )

        Just ( timelinesModel, cmd ) ->
            ( { model | timelinesModel = Just timelinesModel }
            , cmd
            )


credentialInUse : List UserDetails -> Maybe Credential
credentialInUse =
    List.head
        >> Maybe.map .credential


saveLocalStorage : Model -> Cmd msg
saveLocalStorage =
    LocalStorage.set << encodeLocalStorage << toLocalStorage


toLocalStorage : Model -> LocalStorage
toLocalStorage model =
    let
        getSessionId s =
            case s of
                NotAttempted id ->
                    id

                Authenticating id ->
                    id

                Authenticated id _ ->
                    id

                AuthenticationFailed id _ ->
                    id
    in
    { footerMsg = model.footerMessageNumber
    , sessionID = Maybe.map getSessionId model.sessionID
    , usersDetails = model.usersDetails
    , timelinesInfo = model.timelinesInfo
    }


loadLocalStorage : LocalStorage -> Model -> Model
loadLocalStorage ls model =
    { model
        | footerMessageNumber = ls.footerMsg
        , sessionID = Debug.log "loaded session id" <| Maybe.map NotAttempted ls.sessionID
        , usersDetails = ls.usersDetails
        , timelinesInfo = ls.timelinesInfo
    }


storeTimelineInfo :
    Credential
    -> SessionInfo
    -> (SessionInfo -> SessionInfo)
    -> Model
    -> ( Model, Cmd Msg )
storeTimelineInfo cred def f model =
    let
        g minfo =
            case minfo of
                Nothing ->
                    Just def

                Just val ->
                    Just (f val)

        newModel =
            { model
                | timelinesInfo = Dict.update cred g model.timelinesInfo
            }
    in
    ( newModel, saveLocalStorage newModel )


encodeLocalStorage : LocalStorage -> Value
encodeLocalStorage l =
    let
        encodeSessionInfo : SessionInfo -> Value
        encodeSessionInfo s =
            let
                (HomeTweets h) =
                    s.homeTweets

                (MentionsTweets m) =
                    s.mentionsTweets
            in
            Encode.object
                [ ( "tweetText", Encode.string s.tweetText )
                , ( "homeTweets", Encode.list Twitter.serialiseTweet h )
                , ( "mentionsTweets", Encode.list Twitter.serialiseTweet m )
                ]

        encodeFooterMsg (FooterMsg m) =
            Encode.int m
    in
    Encode.object
        [ ( "footerMsg", encodeFooterMsg l.footerMsg )
        , ( "sessionID", E.maybe Encode.string l.sessionID )
        , ( "usersDetails", Encode.list CredentialsHandler.userDetailsSerialiser l.usersDetails )
        , ( "timelinesInfo", Encode.dict identity encodeSessionInfo l.timelinesInfo )
        ]


localStorageDecoder : Decoder LocalStorage
localStorageDecoder =
    let
        sessionInfoDecoder : Decoder SessionInfo
        sessionInfoDecoder =
            Decode.succeed SessionInfo
                |> D.required "tweetText" Decode.string
                |> D.required "homeTweets" (Decode.map HomeTweets <| Decode.list Twitter.deserialiseTweet)
                |> D.required "mentionsTweets" (Decode.map MentionsTweets <| Decode.list Twitter.deserialiseTweet)

        footerMsgDecoder =
            Decode.map FooterMsg Decode.int
    in
    Decode.succeed LocalStorage
        |> D.required "footerMsg" footerMsgDecoder
        |> D.optional "sessionID" (Decode.map Just Decode.string) Nothing
        |> D.required "usersDetails" (Decode.list CredentialsHandler.userDetailsDeserialiser)
        |> D.required "timelinesInfo" (Decode.dict sessionInfoDecoder)


port port_Main_openInNewTab : String -> Cmd a
