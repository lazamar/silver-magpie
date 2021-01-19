module Timelines.State exposing (init, subscriptions, update)

import Generic.Utils exposing (toCmd)
import Task
import Time
import Timelines.Timeline.State as TimelineS
import Timelines.Timeline.Types as TimelineT exposing (HomeTweets, MentionsTweets)
import Timelines.TweetBar.State as TweetBarS
import Timelines.TweetBar.Types as TweetBarT
import Timelines.Types exposing (..)
import Twitter.Types exposing (Credential)


init :
    String
    -> HomeTweets
    -> MentionsTweets
    -> Config msg
    -> Credential
    -> ( Model, Cmd msg )
init t h m conf credential =
    let
        placeholderTime =
            Time.millisToPosix 0

        ( timelineModel, timelineMsg ) =
            TimelineS.init h m timelineConfig

        ( tweetBarModel, tweetBarMsg ) =
            TweetBarS.init t tweetBarConfig

        initialModel =
            { timelineModel = timelineModel
            , tweetBarModel = tweetBarModel
            , now = placeholderTime
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
    , storeTweetText = StoreTweetText
    }


timelineConfig : TimelineT.Config Msg
timelineConfig =
    { onUpdate = TimelineMsg
    , onLogout = Logout
    , onSubmitTweet = SubmitTweet
    , onSetReplyTweet = SetReplyTweet
    , storeHome = StoreHome
    , storeMentions = StoreMentions
    }


minute =
    1000 * 60


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Time.every minute UpdateTime

        -- The refresh has to be every one and a half minute
        -- because of Twitter's rest API restrictions
        , Time.every (1.5 * minute) (\_ -> RefreshTweets)
        ]


update : Msg -> Config msg -> Credential -> Model -> ( Model, Cmd msg )
update msg conf credential model =
    case msg of
        TimelineMsg subMsg ->
            TimelineS.update subMsg timelineConfig credential model.timelineModel
                |> timelineUpdate conf.onUpdate model

        TweetBarMsg subMsg ->
            TweetBarS.update subMsg tweetBarConfig credential model.tweetBarModel
                |> tweetBarUpdate conf.onUpdate model

        UpdateTime time ->
            ( { model | now = time }, Cmd.none )

        SubmitTweet ->
            TweetBarS.submitTweet tweetBarConfig credential model.tweetBarModel
                |> tweetBarUpdate conf.onUpdate model

        SetReplyTweet tweet ->
            TweetBarS.setReplyTweet tweetBarConfig credential model.tweetBarModel tweet
                |> tweetBarUpdate conf.onUpdate model

        RefreshTweets ->
            TimelineS.refreshTweets timelineConfig credential model.timelineModel
                |> timelineUpdate conf.onUpdate model

        StoreHome c h ->
            ( model, toCmd <| conf.storeHome c h )

        StoreMentions c m ->
            ( model, toCmd <| conf.storeMentions c m )

        StoreTweetText c t ->
            ( model, toCmd <| conf.storeTweetText c t )

        Logout creds ->
            ( model, toCmd (conf.onLogout creds) )


timelineUpdate : (Msg -> msg) -> Model -> ( TimelineT.Model, Cmd Msg ) -> ( Model, Cmd msg )
timelineUpdate onUpdate model =
    Tuple.mapFirst (\m -> { model | timelineModel = m })
        >> Tuple.mapSecond (Cmd.map onUpdate)


tweetBarUpdate : (Msg -> msg) -> Model -> ( TweetBarT.Model, Cmd Msg ) -> ( Model, Cmd msg )
tweetBarUpdate onUpdate model =
    Tuple.mapFirst (\m -> { model | tweetBarModel = m })
        >> Tuple.mapSecond (Cmd.map onUpdate)
