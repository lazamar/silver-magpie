module Generic.Http exposing (get, post, delete, sameDomain, toJsonBody)

import Twitter.Types exposing (Credentials)
import Http
import Task exposing (Task)
import Json.Encode
import Json.Decode exposing (Decoder)


type alias Endpoint =
    String


serverURL =
    -- "http://localhost:8080"
    "https://lazamar.co.uk/silver-magpie"


get : Credentials -> Decoder a -> Endpoint -> Task Http.Error a
get credentials decoder endpoint =
    makeRequest "GET" Http.emptyBody credentials decoder endpoint
        |> Http.toTask


delete : Credentials -> Decoder a -> Endpoint -> Task Http.Error a
delete credentials decoder endpoint =
    makeRequest "DELETE" Http.emptyBody credentials decoder endpoint
        |> Http.toTask


post : Credentials -> Decoder a -> Endpoint -> Http.Body -> Task Http.Error a
post credentials decoder endpoint body =
    makeRequest "POST" body credentials decoder endpoint
        |> Http.toTask


makeRequest : String -> Http.Body -> Credentials -> Decoder a -> Endpoint -> Http.Request a
makeRequest method body credentials decoder endpoint =
    let
        options =
            { method = method
            , headers = headers credentials
            , url = sameDomain endpoint
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }
    in
        Http.request options


headers : Credentials -> List Http.Header
headers appToken =
    [ Http.header "Content-Type" "application/json"
    , Http.header "X-App-Token" appToken
    ]


sameDomain : String -> String
sameDomain =
    (++) serverURL


toJsonBody : List ( String, Json.Encode.Value ) -> Http.Body
toJsonBody tupleList =
    tupleList
        |> Json.Encode.object
        |> Http.jsonBody
