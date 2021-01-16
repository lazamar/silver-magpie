module Twitter.Decoders.UserDecoder exposing (userDecoder)

import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Twitter.Types exposing (User)


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "name" string
        |> required "screen_name" string
        |> required "profile_image_url_https" string
