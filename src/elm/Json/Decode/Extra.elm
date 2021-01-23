module Json.Decode.Extra exposing
    ( custom
    , hardcoded
    , optional
    , required
    , requiredAt
    )

import Json.Decode as Decode exposing (Decoder)
import Maybe


apply : Decoder a -> Decoder (a -> b) -> Decoder b
apply da df =
    df
        |> Decode.andThen (\f -> Decode.map f da)


required : String -> Decoder a -> Decoder (a -> b) -> Decoder b
required str decoder =
    apply <| Decode.field str decoder


requiredAt : List String -> Decoder a -> Decoder (a -> b) -> Decoder b
requiredAt str path =
    apply <| Decode.at str path


{-| Returns Nothing if the field is missing and also if the
value decoder fails.
-}
optional : String -> Decoder a -> a -> Decoder (a -> b) -> Decoder b
optional str decoder default =
    Decode.maybe (Decode.field str decoder)
        |> Decode.map (Maybe.withDefault default)
        |> apply


custom : Decoder a -> Decoder (a -> b) -> Decoder b
custom =
    apply


hardcoded : a -> Decoder (a -> b) -> Decoder b
hardcoded =
    apply << Decode.succeed
