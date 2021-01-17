module Main.State exposing (credentialInUse, init, subscriptions, update)

import Generic.Detach
import Generic.LocalStorage as LocalStorage
import Generic.Utils exposing (toCmd)
import List.Extra
import Main.CredentialsHandler as CredentialsHandler
import Main.Rest exposing (fetchCredential)
import Main.Types exposing (..)
import Random
import RemoteData
import String
import Task
import Time exposing (Posix)
import Timelines.State as TimelinesS
import Timelines.Types as TimelinesT
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
    }


init : ( Int, Int ) -> ( Model, Cmd Msg )
init ( nowMillis, randomVal ) =
    ( emptyModel (Time.millisToPosix nowMillis) (Random.initialSeed randomVal)
    , Cmd.batch
        [ CredentialsHandler.retrieveUsersDetails
            |> Cmd.map LoadedUsersDetails
        , CredentialsHandler.retrieveSessionID
            |> Cmd.map SessionIdLoaded
        , Task.perform TimeZone Time.here
        , generateFooterMsgNumber
            |> Cmd.map CurrentFooterMsg
        ]
    )


timelinesConfig : TimelinesT.Config Msg
timelinesConfig =
    { onUpdate = TimelinesMsg
    , onLogout = Logout
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

        SessionIdLoaded msid ->
            case msid of
                Just sid ->
                    ( { model | sessionID = Just (NotAttempted sid) }, fetchCredential sid )

                Nothing ->
                    newSessionID model

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
                        , CredentialsHandler.storeUsersDetails newModel.usersDetails
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
            ( { model | footerMessageNumber = fmsg }
            , saveFooterMsg fmsg
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
                            newSessionID newModel

                        x :: _ ->
                            selectAccount newModel x.credential
            in
            ( m
            , Cmd.batch [ cmd, CredentialsHandler.storeUsersDetails newDetails ]
            )

        Detach ->
            ( model
            , Generic.Detach.detach 400 600
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

                ( timelinesModel, timelinesCmd ) =
                    TimelinesS.init timelinesConfig details.credential
            in
            ( { model
                | timelinesModel = Just timelinesModel
                , usersDetails = newUsersDetails
              }
            , Cmd.batch
                [ timelinesCmd
                , CredentialsHandler.storeUsersDetails newUsersDetails
                ]
            )


newSessionID : Model -> ( Model, Cmd Msg )
newSessionID model =
    let
        ( newSeed, sessionID ) =
            CredentialsHandler.generateSessionID
                model.now
                model.randomSeed
    in
    ( { model
        | randomSeed = newSeed
        , sessionID = Just (NotAttempted sessionID)
      }
    , Cmd.batch
        [ CredentialsHandler.saveSessionID sessionID
        , fetchCredential sessionID
        ]
    )


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


footerMsgNumber : String
footerMsgNumber =
    "footerMsgNumber"


generateFooterMsgNumber : Cmd FooterMsg
generateFooterMsgNumber =
    let
        withDefault =
            Maybe.andThen String.toInt
                >> Maybe.withDefault 0
                >> (+) 1
                >> FooterMsg
    in
    -- get last saved number
    LocalStorage.getItem footerMsgNumber
        |> Cmd.map withDefault


saveFooterMsg : FooterMsg -> Cmd a
saveFooterMsg (FooterMsg n) =
    String.fromInt n
        |> LocalStorage.setItem footerMsgNumber
