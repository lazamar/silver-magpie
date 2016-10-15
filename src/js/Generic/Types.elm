module Generic.Types exposing (..)



type SubmissionData e r c
    = NotSent c
    | Sending c
    | Success r
    | Failure e
