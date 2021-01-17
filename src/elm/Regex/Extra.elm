module Regex.Extra exposing (..)

import Regex exposing (Regex)



-- Create a regex without failing.
-- Only use if you are sure that the Regex is valid


regex : String -> Regex
regex str =
    case Regex.fromString str of
        Just r ->
            r

        Nothing ->
            Regex.never
