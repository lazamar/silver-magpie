module Main.State exposing (init, update, subscriptions, credentialInUse)

import Main.Types exposing (..)
import Main.Rest exposing (fetchCredential)
import Main.CredentialsHandler as CredentialsHandler
import Timelines.Types as TimelinesT
import Timelines.State as TimelinesS
import Generic.Utils exposing (toCmd)
import Generic.LocalStorage as LocalStorage
import Twitter.Types exposing (Credential)
import RemoteData
import Generic.Detach
import List.Extra


-- INITIALISATION


emptyModel : SessionID -> List UserDetails -> Model
emptyModel sessionID usersDetails =
    { timelinesModel = Nothing
    , sessionID = NotAttempted sessionID
    , usersDetails = usersDetails
    , footerMessageNumber = generateFooterMsgNumber ()
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        -- TODO : Clean all of this impurity by using flags
        storedUsersDetails =
            CredentialsHandler.retrieveUsersDetails ()

        sessionID =
            CredentialsHandler.retrieveSessionID ()
                |> Maybe.withDefault (CredentialsHandler.generateSessionID ())

        ( initialModel, initialCmd ) =
            storedUsersDetails
                |> List.map .credential
                |> List.head
                |> Maybe.map SelectAccount
                |> Maybe.map (\msg -> update msg (emptyModel sessionID storedUsersDetails))
                |> Maybe.withDefault ( emptyModel sessionID [], Cmd.none )
    in
        ( initialModel
        , Cmd.batch
            [ fetchCredential sessionID
            , initialCmd
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
                Authenticated sessionID userDetails ->
                    let
                        newId =
                            CredentialsHandler.generateSessionID ()

                        ( newModel, newCmd ) =
                            update
                                (SelectAccount userDetails.credential)
                                { model
                                    | sessionID = NotAttempted newId
                                    , usersDetails = model.usersDetails ++ [ userDetails ]
                                }
                    in
                        ( newModel
                        , Cmd.batch
                            [ newCmd
                            , CredentialsHandler.storeUsersDetails
                                (\_ -> DoNothing)
                                newModel.usersDetails
                            ]
                        )

                NotAttempted anID ->
                    ( { model | sessionID = Authenticating anID }
                    , fetchCredential anID
                    )

                _ ->
                    ( { model | sessionID = authentication }
                    , Cmd.none
                    )

        SelectAccount credential ->
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
                            , timelinesCmd
                            )

        Logout credential ->
            model.usersDetails
                |> List.filter (\d -> d.credential /= credential)
                |> CredentialsHandler.storeUsersDetails (\_ -> DoNothing)
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
