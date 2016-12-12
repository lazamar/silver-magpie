module Main.State exposing (..)

import Main.Types exposing (..)
import Main.Rest exposing (fetchCredential)
import Routes.Timelines.Types as TimelinesT
import Routes.Timelines.State as TimelinesS
import Generic.Utils exposing (toCmd)
import Generic.CredentialsHandler as CredentialsHandler
import Generic.LocalStorage as LocalStorage
import Twitter.Types exposing (Credential)
import RemoteData


-- INITIALISATION
-- TODO : Clean all of this impurity by using flags


init : () -> ( Model, Cmd Msg )
init _ =
    let
        initialModel =
            { timelinesModel = Nothing
            , sessionID =
                case (CredentialsHandler.retrieveSessionID ()) of
                    Nothing ->
                        CredentialsHandler.generateSessionID ()

                    Just sessionID ->
                        sessionID
            , credentials = CredentialsHandler.retrieveStored ()
            , authenticatingCredential = RemoteData.NotAsked
            }
    in
        ( initialModel
        , toCmd <| UserCredentialFetch initialModel.authenticatingCredential
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
            model.timelinesModel
                |> Maybe.map (TimelinesS.update subMsg timelinesConfig)
                |> updateTimelinesModel model

        -- TODO Implement this
        UserCredentialFetch request ->
            case request of
                RemoteData.Success credential ->
                    ( { model | authenticatingCredential = request }
                    , Cmd.batch
                        [ CredentialsHandler.store (\_ -> DoNothing) credential
                        , toCmd (Authenticated credential)
                        ]
                    )

                RemoteData.NotAsked ->
                    ( { model | authenticatingCredential = RemoteData.Loading }
                    , fetchCredential model.sessionID
                    )

                _ ->
                    ( { model | authenticatingCredential = request }
                    , Cmd.none
                    )

        -- TODO Implement this
        Logout credential ->
            CredentialsHandler.eraseFromStorage (\_ -> DoNothing) credential
                |> \_ -> init ()

        Authenticated credential ->
            -- TODO This is should be put into an array
            TimelinesS.init timelinesConfig credential
                |> Just
                |> updateTimelinesModel model


updateTimelinesModel : Model -> Maybe ( TimelinesT.Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateTimelinesModel model maybeTuple =
    case maybeTuple of
        Nothing ->
            ( model, Cmd.none )

        Just ( timelinesModel, cmd ) ->
            ( { model | timelinesModel = Just timelinesModel }
            , cmd
            )
