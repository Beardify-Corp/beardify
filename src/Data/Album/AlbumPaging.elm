module Data.Album.AlbumPaging exposing
    ( AlbumPaging
    , decodeAlbumPaging
    )

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeSimplified)
import Json.Decode as Decode exposing (null, string)


type alias AlbumPaging =
    { items : List AlbumSimplified
    , next : String
    , total : Int
    , offset : Int
    , limit : Int
    }


decodeAlbumPaging : Decode.Decoder AlbumPaging
decodeAlbumPaging =
    Decode.map5 AlbumPaging
        (Decode.at [ "items" ] (Decode.list decodeSimplified))
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "total" Decode.int)
        (Decode.field "offset" Decode.int)
        (Decode.field "limit" Decode.int)
