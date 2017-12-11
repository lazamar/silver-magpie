module Generic.Http exposing (get, post, delete, sameDomain, toJsonBody)

import Twitter.Types exposing (Credential)
import Http
import Task exposing (Task)
import Json.Encode
import Json.Decode exposing (Decoder)


type alias Endpoint =
    String


serverURL : String
serverURL =
    "https://lazamar.co.uk/silver-magpie"



-- "http://localhost:8080"


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
