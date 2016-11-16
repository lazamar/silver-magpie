module Generic.Http exposing ( get, post )

serverURL =
    "http://localhost:8080"



get : String -> String-> Cmd msg
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



post : String -> String-> Http.Body -> Cmd msg
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



headers : String -> List ( String, String )
headers appToken =
    [ ( "Content-Type", "application/json" )
    , ( "X-App-Token", appToken)
    ]



sameDomain : String -> String
sameDomain endPoint =
    serverURL ++ endPoint
