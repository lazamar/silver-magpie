module Generic.Http exposing (delete, get, post, sameDomain, toJsonBody)

import Http
import Json.Decode exposing (Decoder)
import Json.Encode
import Task exposing (Task)
import Twitter.Types exposing (Credential)


type alias Endpoint =
    String


serverURL : String
serverURL =
    --"http://localhost:8080/"
    "https://lazamar.co.uk/silver-magpie"


get : Credential -> Decoder a -> Endpoint -> Task Http.Error a
get credential decoder endpoint =
    makeRequest "GET" Http.emptyBody credential decoder endpoint
        |> Http.toTask


delete : Credential -> Decoder a -> Endpoint -> Task Http.Error a
delete credential decoder endpoint =
    makeRequest "DELETE" Http.emptyBody credential decoder endpoint
        |> Http.toTask


post : Credential -> Decoder a -> Endpoint -> Http.Body -> Task Http.Error a
post credential decoder endpoint body =
    makeRequest "POST" body credential decoder endpoint
        |> Http.toTask


makeRequest : String -> Http.Body -> Credential -> Decoder a -> Endpoint -> Http.Request a
makeRequest method body credential decoder endpoint =
    let
        options =
            { method = method
            , headers = headers credential
            , url = sameDomain endpoint
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }
    in
    Http.request options


headers : Credential -> List Http.Header
headers appToken =
    [ Http.header "X-App-Token" appToken
    ]


sameDomain : String -> String
sameDomain =
    (++) serverURL


toJsonBody : List ( String, Json.Encode.Value ) -> Http.Body
toJsonBody tupleList =
    tupleList
        |> Json.Encode.object
        |> Http.jsonBody
