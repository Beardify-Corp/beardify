module Helper exposing (convertDate)

import Iso8601
import Time exposing (Month(..))


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
