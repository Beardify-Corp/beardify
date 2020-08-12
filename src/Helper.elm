module Helper exposing (convertDate)

import Iso8601
import Time exposing (Month(..))


toFrenchMonth : Month -> String
toFrenchMonth month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Fev"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "Mai"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"


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
    String.fromInt (Time.toDay Time.utc convertDateToPosix) ++ "-" ++ toFrenchMonth (Time.toMonth Time.utc convertDateToPosix) ++ "-" ++ String.fromInt (Time.toYear Time.utc convertDateToPosix)
