module Generic.Types exposing (..)



type SubmissionData e r c
    = NotSent c
    | Sending
    | Success r
    | Failure e
