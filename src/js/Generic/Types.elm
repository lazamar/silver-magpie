module Generic.Types exposing (..)



type SubmissionData e r c
    = NotSent c
    | Sending c
    | Success r
    | Failure e



never : Never -> a
never a =
    never a
