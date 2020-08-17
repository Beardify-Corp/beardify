module Data.Artist exposing
    ( Artist
    , ArtistList
    , ArtistSimplified
    , decode
    , decodeArtistList
    , decodeSimplified
    , isFollowing
    )

import Data.Id exposing (Id, decodeId)
import Data.Image as Image exposing (Image)
import Json.Decode as Decode exposing (Decoder(..), at, field, null, string)


type alias Artist =
    { id : Id
    , name : String
    , images : List Image
    , popularity : Int
    , type_ : String
    }


type alias ArtistSimplified =
    { id : Id
    , name : String
    }


type alias IsFollowing =
    List Bool


decode : Decoder Artist
decode =
    Decode.map5 Artist
        (Decode.field "id" decodeId)
        (Decode.field "name" Decode.string)
        (Decode.field "images" (Decode.list Image.decode))
        (Decode.field "popularity" Decode.int)
        (Decode.field "type" Decode.string)


decodeSimplified : Decoder ArtistSimplified
decodeSimplified =
    Decode.map2 ArtistSimplified
        (Decode.field "id" decodeId)
        (Decode.field "name" Decode.string)


isFollowing : Decoder IsFollowing
isFollowing =
    Decode.list Decode.bool


type alias ArtistList =
    { items : List Artist
    , next : String
    , total : Int
    , offset : Int
    , limit : Int
    }


decodeArtistList : Decode.Decoder ArtistList
decodeArtistList =
    Decode.map5 ArtistList
        (Decode.at [ "items" ] (Decode.list decode))
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "total" Decode.int)
        (Decode.field "offset" Decode.int)
        (Decode.field "limit" Decode.int)
