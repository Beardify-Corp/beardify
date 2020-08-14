module Helper exposing (convertDate, durationFormatMinutes, releaseDateFormat)

import Iso8601
import Time exposing (Month(..), millisToPosix, toHour, toMinute, utc)


toFrenchMonth : Month -> String
toFrenchMonth month =
    case month of
        Jan ->
            "01"

        Feb ->
            "02"

        Mar ->
            "03"

        Apr ->
            "04"

        May ->
            "05"

        Jun ->
            "06"

        Jul ->
            "07"

        Aug ->
            "08"

        Sep ->
            "09"

        Oct ->
            "10"

        Nov ->
            "11"

        Dec ->
            "12"


convertDate : String -> String
convertDate isoDate =
    let
        convertDateToPosix =
            case Iso8601.toTime isoDate of
                Ok date ->
                    date

                Err _ ->
                    Time.millisToPosix 0
    in
    String.fromInt (Time.toDay Time.utc convertDateToPosix) ++ "/" ++ toFrenchMonth (Time.toMonth Time.utc convertDateToPosix) ++ "/" ++ String.fromInt (Time.toYear Time.utc convertDateToPosix)


durationFormatMinutes : Int -> String
durationFormatMinutes duration =
    let
        toTime unit =
            duration
                |> millisToPosix
                |> unit utc

        hour =
            if toTime toHour > 0 then
                String.fromInt (toTime toHour) ++ " hr "

            else
                ""

        minute =
            String.fromInt (toTime toMinute) ++ " min"
    in
    hour ++ minute


releaseDateFormat : String -> String
releaseDateFormat date =
    date
        |> String.split "-"
        |> List.head
        |> Maybe.withDefault ""
