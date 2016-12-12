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
import Time exposing (Time)
import Task


init : Config msg -> Credentials -> ( Model, Cmd msg )
init conf credentials =
    let
        ( timelineModel, timelineMsg ) =
            TimelineS.init timelineConfig

        ( tweetBarModel, tweetBarMsg ) =
            TweetBarS.init tweetBarConfig

        footerMessageNumber =
            generateFooterMsgNumber ()

        initialModel =
            { credentials = credentials
            , timelineModel = timelineModel
            , tweetBarModel = tweetBarModel
            , footerMessageNumber = footerMessageNumber
            , time = 0.0
            }
    in
        ( initialModel
        , Cmd.batch
            [ timelineMsg
            , tweetBarMsg
            , Task.perform UpdateTime Time.now
            ]
            |> Cmd.map conf.onUpdate
        )


tweetBarConfig : TweetBarT.Config Msg
tweetBarConfig =
    { onRefreshTweets = RefreshTweets
    , onUpdate = TweetBarMsg
    }


timelineConfig : TimelineT.Config Msg
timelineConfig =
    { onUpdate = TimelineMsg
    , onLogout = Logout
    , onSubmitTweet = SubmitTweet
    , onSetReplyTweet = SetReplyTweet
    }


subscriptions : Sub Msg
subscriptions =
    Time.every Time.minute UpdateTime


update : Msg -> Config msg -> Model -> ( Model, Cmd msg )
update msg conf model =
    case msg of
        TimelineMsg subMsg ->
            TimelineS.update subMsg timelineConfig model.credentials model.timelineModel
                |> timelineUpdate conf.onUpdate model

        TweetBarMsg subMsg ->
            TweetBarS.update subMsg tweetBarConfig model.credentials model.tweetBarModel
                |> tweetBarUpdate conf.onUpdate model

        UpdateTime time ->
            ( { model | time = time }, Cmd.none )

        SubmitTweet ->
            TweetBarS.submitTweet tweetBarConfig model.credentials model.tweetBarModel
                |> tweetBarUpdate conf.onUpdate model

        SetReplyTweet tweet ->
            TweetBarS.setReplyTweet tweetBarConfig model.credentials model.tweetBarModel tweet
                |> tweetBarUpdate conf.onUpdate model

        RefreshTweets ->
            TimelineS.refreshTweets timelineConfig model.credentials model.timelineModel
                |> timelineUpdate conf.onUpdate model

        Logout ->
            ( model, toCmd conf.onLogout )

        Detach ->
            ( model
            , Generic.Detach.detach 400 600
                |> Cmd.map conf.onUpdate
            )


timelineUpdate : (Msg -> msg) -> Model -> ( TimelineT.Model, Cmd Msg ) -> ( Model, Cmd msg )
timelineUpdate onUpdate model =
    Tuple.mapFirst (\m -> { model | timelineModel = m })
        >> Tuple.mapSecond (Cmd.map onUpdate)


tweetBarUpdate : (Msg -> msg) -> Model -> ( TweetBarT.Model, Cmd Msg ) -> ( Model, Cmd msg )
tweetBarUpdate onUpdate model =
    Tuple.mapFirst (\m -> { model | tweetBarModel = m })
        >> Tuple.mapSecond (Cmd.map onUpdate)


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
