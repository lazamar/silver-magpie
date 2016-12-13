module Main.State exposing (init, update, subscriptions, credentialInUse)

import Main.Types exposing (..)
import Main.Rest exposing (fetchCredential)
import Routes.Timelines.Types as TimelinesT
import Routes.Timelines.State as TimelinesS
import Generic.Utils exposing (toCmd)
import Generic.CredentialsHandler as CredentialsHandler
import Generic.LocalStorage as LocalStorage
import Twitter.Types exposing (Credential)
import RemoteData
import Generic.Detach


-- INITIALISATION


init : () -> ( Model, Cmd Msg )
init _ =
    let
        -- TODO : Clean all of this impurity by using flags
        storedCredentials =
            CredentialsHandler.retrieveStored ()

        ( timelinesModel, timelinesCmd ) =
            List.head storedCredentials
                |> Maybe.map (TimelinesS.init timelinesConfig)
                |> Maybe.map (Tuple.mapFirst Just)
                |> Maybe.withDefault ( Nothing, Cmd.none )

        storedSessionID =
            CredentialsHandler.retrieveSessionID ()

        sessionID =
            storedSessionID
                |> Maybe.map Authenticating
                |> Maybe.withDefault NotAttempted

        authenticateSessionIDCmd =
            case storedSessionID of
                Nothing ->
                    if List.length storedCredentials == 0 then
                        toCmd <| UserCredentialFetch sessionID
                    else
                        Cmd.none

                Just anID ->
                    fetchCredential anID
    in
        ( { timelinesModel = timelinesModel
          , sessionID = sessionID
          , credentials = storedCredentials
          , footerMessageNumber = generateFooterMsgNumber ()
          }
        , Cmd.batch
            [ authenticateSessionIDCmd
            , timelinesCmd
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

        TimelinesMsg subMsg ->
            updateTimelinesModel model subMsg

        UserCredentialFetch authentication ->
            case authentication of
                Authenticated sessionID credential ->
                    let
                        ( timelinesModel, timelinesCmd ) =
                            TimelinesS.init timelinesConfig credential
                    in
                        ( { model
                            | sessionID = NotAttempted
                            , credentials =
                                credential :: model.credentials
                                -- TODO Timelinemodel must take a list of credentials
                            , timelinesModel = Just timelinesModel
                          }
                        , Cmd.batch
                            [ timelinesCmd
                            , CredentialsHandler.eraseSessionID DoNothing
                            , CredentialsHandler.store (\_ -> DoNothing) (Debug.log "Storing " credential)
                            ]
                        )

                NotAttempted ->
                    let
                        newSessionID =
                            CredentialsHandler.generateSessionID ()
                    in
                        ( { model | sessionID = Authenticating newSessionID }
                        , fetchCredential newSessionID
                        )

                _ ->
                    ( { model | sessionID = authentication }
                    , Cmd.none
                    )

        -- TODO Implement this
        Logout credential ->
            CredentialsHandler.eraseCredential (\_ -> DoNothing) credential
                |> \_ -> init ()

        Detach ->
            ( model
            , Generic.Detach.detach 400 600
            )


updateTimelinesModel : Model -> TimelinesT.Msg -> ( Model, Cmd Msg )
updateTimelinesModel model subMsg =
    let
        maybeTuple =
            Maybe.map2
                (\c m -> TimelinesS.update subMsg timelinesConfig c m)
                (credentialInUse model)
                model.timelinesModel
    in
        case maybeTuple of
            Nothing ->
                ( model, Cmd.none )

            Just ( timelinesModel, cmd ) ->
                ( { model | timelinesModel = Just timelinesModel }
                , cmd
                )


credentialInUse : Model -> Maybe Credential
credentialInUse model =
    List.head model.credentials


generateFooterMsgNumber : () -> Int
generateFooterMsgNumber _ =
    let
        -- get last saved number
        generated =
            LocalStorage.getItem "footerMsgNumber"
                |> Maybe.map String.toInt
                |> Maybe.withDefault (Ok 0)
                |> Result.withDefault 0
                |> (+) 1

        -- save the one we have
        save =
            toString generated
                |> LocalStorage.setItem "footerMsgNumber"
    in
        generated
