module Generic.UniqueID exposing ( generate )

import Native.UniqueID


generate : String -> String
generate seed =
    Native.UniqueID.generate seed
