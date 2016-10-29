module Twitter.Decoders.UserDecoder exposing ( userDecoder )

import Twitter.Types exposing ( User )
import Json.Decode exposing ( Decoder, string )
import Json.Decode.Pipeline exposing ( decode, required )



userDecoder : Decoder User
userDecoder =
  decode User
    |> required "name" string
    |> required "screen_name" string
    |> required "profile_image_url_https" string
