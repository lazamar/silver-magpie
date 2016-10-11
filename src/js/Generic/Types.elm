module Generic.Types exposing (..)



type SubmissionData e r c
    = NotSent c
    | Loading
    | Success r
    | Failure e
