module Generic.Http exposing ( get, post, delete, sameDomain )

import Twitter.Types exposing ( Credentials )
import Http
import Task exposing ( Task )



type alias Endpoint
    = String


serverURL =
    "http://localhost:8080"



get : Credentials -> Endpoint -> Task Http.RawError Http.Response
get =
    makeRequest "GET" Http.empty



delete : Credentials -> Endpoint -> Task Http.RawError Http.Response
delete =
    makeRequest "DELETE" Http.empty



post : Http.Body -> Credentials -> Endpoint -> Task Http.RawError Http.Response
post =
    makeRequest "POST"



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
    , ( "X-App-Token", appToken)
    ]



sameDomain : String -> String
sameDomain =
    (++) serverURL
