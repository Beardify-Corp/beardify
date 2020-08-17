module Data.Playlist.PlaylistSimplified exposing
    ( PlaylistSimplified
    , decodePlaylistSimplified
    )

import Data.Id exposing (Id, decodeId)
import Data.Image exposing (Image, decode)
import Json.Decode as Decode exposing (Decoder(..), at, field, null, string)


type alias PlaylistSimplified =
    { id : Id
    , name : String
    }


decodePlaylistSimplified : Decode.Decoder PlaylistSimplified
decodePlaylistSimplified =
    Decode.map2 PlaylistSimplified
        (Decode.field "id" decodeId)
        (Decode.field "name" Decode.string)
