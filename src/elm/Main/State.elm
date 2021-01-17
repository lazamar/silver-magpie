module Main.State exposing (credentialInUse, init, subscriptions, update)

import Generic.Detach
import Generic.LocalStorage as LocalStorage
import Generic.Utils exposing (toCmd)
import List.Extra
import Main.CredentialsHandler as CredentialsHandler
import Main.Rest exposing (fetchCredential)
import Main.Types exposing (..)
import RemoteData
import String
import Task
import Time
import Timelines.State as TimelinesS
import Timelines.Types as TimelinesT
import Twitter.Types exposing (Credential)



-- INITIALISATION


emptyModel : Model
emptyModel =
    { timelinesModel = Nothing
    , sessionID = Nothing
    , usersDetails = []
    , footerMessageNumber = generateFooterMsgNumber ()

    -- UTC temporarily while we fetch the local timezone
    , zone = Time.utc
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        -- TODO : Clean all of this impurity by using flags
        storedUsersDetails =
            CredentialsHandler.retrieveUsersDetails ()

        sessionID =
            case CredentialsHandler.retrieveSessionID () of
                Just anID ->
                    anID

                Nothing ->
                    CredentialsHandler.generateSessionID ()

        ( initialModel, initialCmd ) =
            storedUsersDetails
                |> List.map .credential
                |> List.head
                |> Maybe.map SelectAccount
                |> Maybe.map (\msg -> update msg emptyModel)
                |> Maybe.withDefault ( emptyModel, Cmd.none )
    in
    ( initialModel
    , Cmd.batch
        [ fetchCredential sessionID
        , initialCmd
        , Task.perform TimeZone Time.here
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
                                    | sessionID = Just <| NotAttempted newId
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
                    ( { model | sessionID = Just <| Authenticating anID }
                    , fetchCredential anID
                    )

                _ ->
                    ( { model | sessionID = Just <| authentication }
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
                    , Cmd.batch
                        [ timelinesCmd
                        , CredentialsHandler.storeUsersDetails
                            (\_ -> DoNothing)
                            newUsersDetails
                        ]
                    )

        Logout credential ->
            model.usersDetails
                |> List.filter (\d -> d.credential /= credential)
                |> CredentialsHandler.storeUsersDetails (\_ -> DoNothing)
                |> (\_ -> init ())

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
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 0
                |> (+) 1

        -- save the one we have
        save =
            String.fromInt generated
                |> LocalStorage.setItem "footerMsgNumber"
    in
    generated
