module Data.Artist.Artist exposing
    ( Artist
    , decodeArtist
    , isFollowing
    )

import Data.Id exposing (Id, decodeId)
import Data.Image as Image exposing (Image)
import Json.Decode as Decode exposing (Decoder(..), field, string)


type alias Artist =
    { id : Id
    , name : String
    , images : List Image
    , popularity : Int
    , type_ : String
    }


decodeArtist : Decoder Artist
decodeArtist =
    Decode.map5 Artist
        (Decode.field "id" decodeId)
        (Decode.field "name" Decode.string)
        (Decode.field "images" (Decode.list Image.decode))
        (Decode.field "popularity" Decode.int)
        (Decode.field "type" Decode.string)


type alias IsFollowing =
    List Bool


isFollowing : Decoder IsFollowing
isFollowing =
    Decode.list Decode.bool
