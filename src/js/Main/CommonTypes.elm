module Main.CommonTypes exposing (..)

import Tweets.Types



type alias NewRoute = Tweets.Types.Route



type Msg
    = ChangeRoute NewRoute
