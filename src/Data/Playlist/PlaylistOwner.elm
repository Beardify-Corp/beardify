module Data.Playlist.PlaylistOwner exposing (PlaylistOwner, decodePlaylistOwner)

import Data.Id exposing (Id, decodeId)
import Data.Image exposing (Image, decode)
import Json.Decode as Decode exposing (Decoder(..), at, field, null, string)


type alias PlaylistOwner =
    { display_name : String
    , href : String
    , id : String
    , uri : String
    }


decodePlaylistOwner : Decode.Decoder PlaylistOwner
decodePlaylistOwner =
    Decode.map4 PlaylistOwner
        (Decode.field "display_name" Decode.string)
        (Decode.field "href" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "uri" Decode.string)
