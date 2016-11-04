import Regex exposing (..)

t = "abc @abc @abc abc"
r = regex "@(\\w+)"

match1 = find (AtMost 2) r t |> List.head
-- Just { match = "@abc", submatches = [Just "abc"], index = 4, number = 1 }

replaced1 = replace All r (\m -> if Just m == a then "true" else "false") t
-- "abc false false abc"

replaced2 =replace All r (\m -> if Just (Debug.log "" m) == a then "true" else "false") t

-- : { match = "@abc", submatches = [Just "abc"], index = <internal structure>, number = 1 }
-- : { match = "@abc", submatches = [Just "abc"], index = <internal structure>, number = 2 }
-- "abc false false abc"
