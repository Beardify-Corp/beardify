module Data.Album.AlbumList exposing
    ( AlbumList
    , decodeAlbumList
    )

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeSimplified)
import Json.Decode as Decode exposing (null, string)


type alias AlbumList =
    { items : List AlbumSimplified
    , next : String
    , total : Int
    , offset : Int
    , limit : Int
    }


decodeAlbumList : Decode.Decoder AlbumList
decodeAlbumList =
    Decode.map5 AlbumList
        (Decode.at [ "items" ] (Decode.list decodeSimplified))
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "total" Decode.int)
        (Decode.field "offset" Decode.int)
        (Decode.field "limit" Decode.int)
