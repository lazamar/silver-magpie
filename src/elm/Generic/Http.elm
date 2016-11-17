module Generic.Http exposing ( get, post )

import Generic.Types exposing ( Credentials )
import Http
import Task exposing ( Task )


serverURL =
    "http://localhost:8080"



get : Credentials -> String-> Task Http.RawError Http.Response
get appToken endpoint =
    let
        request =
            { verb = "GET"
            , headers = headers appToken
            , url = sameDomain endpoint
            , body = Http.empty
            }
    in
        Http.send Http.defaultSettings request



post : Credentials -> String-> Http.Body -> Task Http.RawError Http.Response
post appToken endpoint body =
    let
        request =
            { verb = "POST"
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
sameDomain endPoint =
    serverURL ++ endPoint
