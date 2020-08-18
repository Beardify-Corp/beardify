module Data.Artist.ArtistSimplified exposing
    ( ArtistSimplified
    , decodeArtistSimplified
    )

import Data.Id exposing (Id, decodeId)
import Json.Decode as Decode exposing (Decoder(..), field, string)


type alias ArtistSimplified =
    { id : Id
    , name : String
    }


decodeArtistSimplified : Decoder ArtistSimplified
decodeArtistSimplified =
    Decode.map2 ArtistSimplified
        (Decode.field "id" decodeId)
        (Decode.field "name" Decode.string)
