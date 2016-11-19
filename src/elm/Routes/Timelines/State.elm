module Routes.Timelines.State exposing ( init, update )

import Routes.Timelines.Types exposing (..)
import Routes.Timelines.Timeline.Types as TimelineT
import Routes.Timelines.Timeline.State as TimelineS
import Routes.Timelines.TweetBar.Types as TweetBarT
import Routes.Timelines.TweetBar.State as TweetBarS

import Twitter.Types exposing ( Credentials )
import Generic.Utils exposing ( toCmd )



init : Credentials -> ( Model, Cmd Msg, Cmd Broadcast )
init credentials =
    let
        ( timelineModel, timelineMsg, timelineBroadcast  ) =
            TimelineS.init credentials

        ( tweetBarModel, tweetBarMsg, tweetBarBroadcast ) =
            TweetBarS.init credentials
  in
        ( Model timelineModel tweetBarModel
        , Cmd.batch
            [ Cmd.map TimelineMsgLocal timelineMsg
            , Cmd.map TimelineMsgBroadcast timelineBroadcast
            , Cmd.map TweetBarMsgLocal tweetBarMsg
            , Cmd.map TweetBarMsgBroadcast tweetBarBroadcast
            ]
        , Cmd.none
        )



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Broadcast )
update msg model =
    case msg of
        TimelineMsgBroadcast subMsg ->
            ( model, Cmd.none, Cmd.none )

        TweetBarMsgBroadcast subMsg ->
            case subMsg of
                TweetBarT.Logout ->
                    ( model, Cmd.none, toCmd Logout )

                TweetBarT.RefreshTweets ->
                    ( model
                    , toCmd <| TimelineMsgLocal <| TimelineT.FetchTweets TimelineT.Refresh
                    , toCmd Logout
                    )

        TimelineMsgLocal subMsg ->
            let
                ( timelineModel, timelineMsg, timelineBroadcast ) =
                    TimelineS.update subMsg model.timelineModel
            in
                ( { model | timelineModel = timelineModel }
                , Cmd.batch
                    [ Cmd.map TimelineMsgLocal timelineMsg
                    , Cmd.map TimelineMsgBroadcast timelineBroadcast
                    ]
                , Cmd.none
                )

        TweetBarMsgLocal subMsg ->
            let
                ( tweetBarModel, tweetBarMsg, tweetBarBroadcast ) =
                    TweetBarS.update subMsg model.tweetBarModel
            in
                ( { model | tweetBarModel = tweetBarModel }
                , Cmd.batch
                    [ Cmd.map TweetBarMsgLocal tweetBarMsg
                    , Cmd.map TweetBarMsgBroadcast tweetBarBroadcast
                    ]
                , Cmd.none
                )
