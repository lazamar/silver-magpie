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
            [ Cmd.map TimelineMsg timelineMsg
            , Cmd.map TimelineBroadcast timelineBroadcast
            , Cmd.map TweetBarMsg tweetBarMsg
            , Cmd.map TweetBarBroadcast tweetBarBroadcast
            ]
        , Cmd.none
        )



update : Msg -> Model -> ( Model, Cmd Msg, Cmd Broadcast )
update msg model =
    case msg of
    -- Broadcast
        TimelineBroadcast subMsg ->
            ( model, Cmd.none, Cmd.none )

        TweetBarBroadcast subMsg ->
            case subMsg of
                TweetBarT.Logout ->
                    ( model, Cmd.none, toCmd Logout )

                TweetBarT.RefreshTweets ->
                            TimelineS.refreshTweets model.timelineModel
                                |> timelineUpdate model
    -- Msg
        TimelineMsg subMsg ->
            TimelineS.update subMsg model.timelineModel
                |> timelineUpdate model

        TweetBarMsg subMsg ->
            TweetBarS.update subMsg model.tweetBarModel
                |> tweetBarUpdate model



timelineUpdate : Model
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



tweetBarUpdate : Model
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
