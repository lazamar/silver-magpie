module Main.Types exposing (..)

import Dict exposing (Dict)
import Http
import Random
import Time
import Timelines.Timeline.Types exposing (HomeTweets, MentionsTweets, TabName)
import Timelines.TweetBar.Types exposing (TweetText)
import Timelines.Types as TimelinesT exposing (SessionInfo)
import Twitter.Types exposing (Credential, Tweet)


type Msg
    = DoNothing
    | TimeZone Time.Zone
    | LoadedUsersDetails (List UserDetails)
    | TimelinesMsg TimelinesT.Msg
    | UserCredentialFetch SessionIDAuthentication
    | SelectAccount Credential
    | Logout Credential
    | CurrentFooterMsg FooterMsg
    | Detach
    | StoreHome Credential HomeTweets
    | StoreMentions Credential MentionsTweets
    | StoreTweetText Credential TweetText


type SessionIDAuthentication
    = NotAttempted SessionID
    | Authenticating SessionID
    | Authenticated SessionID UserDetails
    | AuthenticationFailed SessionID Http.Error


type FooterMsg
    = FooterMsg Int


type alias SessionID =
    String


type alias Model =
    { timelinesModel : Maybe TimelinesT.Model
    , sessionID : Maybe SessionIDAuthentication
    , usersDetails : List UserDetails
    , footerMessageNumber : FooterMsg
    , zone : Time.Zone
    , now : Time.Posix
    , randomSeed : Random.Seed

    -- this duplicates what is in `timelinesModel`
    -- but serves as a way to access local storage date
    -- synchronously
    , timelinesInfo : Dict Credential SessionInfo
    }


type alias UserDetails =
    { credential : Credential
    , handler : String
    , profile_image : String
    }


type alias LocalStorage =
    { footerMsg : FooterMsg
    , sessionID : Maybe SessionID
    , usersDetails : List UserDetails
    , timelinesInfo : Dict Credential SessionInfo
    }
