module Twitter.Decoders.UserDecoder exposing (userDecoder)

import Json.Decode as Decode exposing (Decoder, field, string)
import Twitter.Types exposing (User)


userDecoder : Decoder User
userDecoder =
    Decode.map3 User
        (field "name" string)
        (field "screen_name" string)
        (field "profile_image_url_https" string)
