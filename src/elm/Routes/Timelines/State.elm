module Routes.Timelines.State exposing (init, update, subscriptions)

import Routes.Timelines.Types exposing (..)
import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.Timeline.State as TimelineS
import Routes.Timelines.TweetBar.Types as TweetBarT
import Routes.Timelines.TweetBar.State as TweetBarS
import Twitter.Types exposing (Credentials)
import Generic.Utils exposing (toCmd)
import Generic.LocalStorage
import Generic.Detach


init : Credentials -> ( Model, Cmd Msg, Cmd Broadcast )
init credentials =
    let
        ( timelineModel, timelineMsg, timelineBroadcast ) =
            TimelineS.init credentials

        ( tweetBarModel, tweetBarMsg, tweetBarBroadcast ) =
            TweetBarS.init

        footerMessageNumber =
            generateFooterMsgNumber ()

        initialModel =
            { credentials = credentials
            , timelineModel = timelineModel
            , tweetBarModel = tweetBarModel
            , footerMessageNumber = footerMessageNumber
            }
    in
        ( initialModel
        , Cmd.batch
            [ Cmd.map TimelineMsg timelineMsg
            , Cmd.map TimelineBroadcast timelineBroadcast
            , Cmd.map TweetBarMsg tweetBarMsg
            , Cmd.map TweetBarBroadcast tweetBarBroadcast
            ]
        , Cmd.none
        )


subscriptions : Sub Msg
subscriptions =
    Sub.map TimelineMsg TimelineS.subscriptions


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Broadcast )
update msg model =
    case msg of
        -- Broadcast
        TimelineBroadcast subMsg ->
            case subMsg of
                TimelineT.Logout ->
                    ( model, Cmd.none, toCmd Logout )

                TimelineT.SubmitTweet ->
                    TweetBarS.submitTweet model.credentials model.tweetBarModel
                        |> tweetBarUpdate model

                TimelineT.SetReplyTweet tweet ->
                    TweetBarS.setReplyTweet model.credentials model.tweetBarModel tweet
                        |> tweetBarUpdate model

        TweetBarBroadcast (TweetBarT.RefreshTweets) ->
            TimelineS.refreshTweets model.timelineModel
                |> timelineUpdate model

        -- Msg
        TimelineMsg subMsg ->
            TimelineS.update subMsg model.timelineModel
                |> timelineUpdate model

        TweetBarMsg subMsg ->
            TweetBarS.update subMsg model.credentials model.tweetBarModel
                |> tweetBarUpdate model

        -- Own messages
        MsgLogout ->
            ( model, Cmd.none, toCmd Logout )

        Detach ->
            ( model
            , Generic.Detach.detach 400 600
            , Cmd.none
            )


timelineUpdate :
    Model
    -> ( TimelineT.Model, Cmd TimelineT.Msg, Cmd TimelineT.Broadcast )
    -> ( Model, Cmd Msg, Cmd Broadcast )
timelineUpdate model ( timelineModel, timelineMsg, timelineBroadcast ) =
    ( { model | timelineModel = timelineModel }
    , Cmd.batch
        [ Cmd.map TimelineMsg timelineMsg
        , Cmd.map TimelineBroadcast timelineBroadcast
        ]
    , Cmd.none
    )


tweetBarUpdate :
    Model
    -> ( TweetBarT.Model, Cmd TweetBarT.Msg, Cmd TweetBarT.Broadcast )
    -> ( Model, Cmd Msg, Cmd Broadcast )
tweetBarUpdate model ( tweetBarModel, tweetBarMsg, tweetBarBroadcast ) =
    ( { model | tweetBarModel = tweetBarModel }
    , Cmd.batch
        [ Cmd.map TweetBarMsg tweetBarMsg
        , Cmd.map TweetBarBroadcast tweetBarBroadcast
        ]
    , Cmd.none
    )


generateFooterMsgNumber : () -> Int
generateFooterMsgNumber _ =
    let
        -- get last saved number
        generated =
            Generic.LocalStorage.getItem "footerMsgNumber"
                |> Maybe.map String.toInt
                |> Maybe.withDefault (Ok 0)
                |> Result.withDefault 0
                |> (+) 1

        -- save the one we have
        save =
            toString generated
                |> Generic.LocalStorage.setItem "footerMsgNumber"
    in
        generated
