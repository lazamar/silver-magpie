module Generic.Http exposing (get, post, delete, sameDomain, toJsonBody)

import Twitter.Types exposing (Credentials)
import Http
import Task exposing (Task)
import Json.Encode


type alias Endpoint =
    String


serverURL =
    "https://lazamar.co.uk/silver-magpie"



-- "http://localhost:8080"


get : Credentials -> Endpoint -> Task Http.RawError Http.Response
get =
    makeRequest "GET" Http.empty


delete : Credentials -> Endpoint -> Task Http.RawError Http.Response
delete =
    makeRequest "DELETE" Http.empty


post : Credentials -> Endpoint -> Http.Body -> Task Http.RawError Http.Response
post credentials endpoint body =
    makeRequest "POST" body credentials endpoint


makeRequest : String -> Http.Body -> Credentials -> Endpoint -> Task Http.RawError Http.Response
makeRequest method body appToken endpoint =
    let
        request =
            { verb = method
            , headers = headers appToken
            , url = sameDomain endpoint
            , body = body
            }
    in
        Http.send Http.defaultSettings request


headers : Credentials -> List ( String, String )
headers appToken =
    [ ( "Content-Type", "application/json" )
    , ( "X-App-Token", appToken )
    ]


sameDomain : String -> String
sameDomain =
    (++) serverURL


toJsonBody : List ( String, Json.Encode.Value ) -> Http.Body
toJsonBody tupleList =
    tupleList
        |> Json.Encode.object
        |> Json.Encode.encode 2
        |> Http.string
