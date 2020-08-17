module Data.Paging exposing
    ( Paging
    , decodePaging
    )

import Json.Decode as Decode exposing (Decoder, null, string)


type alias Paging a =
    { items : List a
    , next : String
    , total : Int
    , offset : Int
    , limit : Int
    }


decodePaging : Decoder a -> Decode.Decoder (Paging a)
decodePaging decoder =
    Decode.map5 Paging
        (Decode.at [ "items" ] (Decode.list decoder))
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "total" Decode.int)
        (Decode.field "offset" Decode.int)
        (Decode.field "limit" Decode.int)
