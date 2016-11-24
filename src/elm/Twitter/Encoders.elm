module Twitter.Encoders exposing ( encodeTweet )

import Twitter.Types exposing (..)

import Json.Encode



encodeTweet : Tweet -> Json.Encode.Value
encodeTweet _ =
    Json.Encode.string "Imagine a tweet"
