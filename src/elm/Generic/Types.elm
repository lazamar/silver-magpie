module Generic.Types exposing (..)


type SubmissionData e r c
    = NotSent
    | Sending c
    | Success r
    | Failure e
