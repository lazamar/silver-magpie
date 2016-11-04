module TweetBar.Handler exposing
    ( Handler
    , HandlerMatch
    , findChanged
    , replaceMatch
    , matchedName
    )

import Regex



type alias Handler
    = String



type alias HandlerMatch
    = Regex.Match



handlerRegex : Regex.Regex
handlerRegex =
    -- matches @asdfasfd and has just one submatch which
    -- which is the handler part without the @
    Regex.regex "(?:^@|\\s@)(\\w{1,15})"



find : String -> List HandlerMatch
find txt =
    Regex.find Regex.All handlerRegex txt



findChanged : String -> String -> Maybe HandlerMatch
findChanged oldText newText =
    let
        oldMatches = find oldText
        newMatches = find newText
    in
        newMatches
            |> List.filter (\h ->  not <| List.member h oldMatches)
            |> List.head



replaceMatch : String -> HandlerMatch -> Handler -> String
replaceMatch text match replacement =
    Regex.replace
        Regex.All
        handlerRegex
        (\m ->
            if sameMatch m match then
                -- Replace just the handler from the match, not any
                -- spaces that my or may not exist before it
                Regex.replace
                    Regex.All
                    (Regex.regex "[^\\s@]+")
                    (\_ -> replacement ++ " ")
                    m.match
            else
                m.match
        )
        text



-- Disregards the index, as the string may have changed in
-- other places.
sameMatch : HandlerMatch -> HandlerMatch -> Bool
sameMatch match1 match2 =
    { match1 | index = 0 } == { match2 | index = 0 }



matchedName : HandlerMatch -> Maybe String
matchedName match =
    List.head match.submatches
        -- This joins the Maybe(Maybe(val)) making it Maybe(val)
        |> Maybe.withDefault Nothing
