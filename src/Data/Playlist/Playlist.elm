module Data.Playlist.Playlist exposing
    ( Playlist
    , decodePlaylist
    )

import Data.Id exposing (Id, decodeId)
import Data.Image exposing (Image, decode)
import Data.Playlist.PlaylistOwner exposing (PlaylistOwner, decodePlaylistOwner)
import Json.Decode as Decode exposing (Decoder(..), at, field, string)


type alias Playlist =
    { id : Id
    , images : List Image
    , name : String
    , uri : String
    , owner : PlaylistOwner
    , description : String
    }


decodePlaylist : Decode.Decoder Playlist
decodePlaylist =
    Decode.map6 Playlist
        (Decode.field "id" decodeId)
        (Decode.at [ "images" ] (Decode.list Data.Image.decode))
        (Decode.field "name" Decode.string)
        (Decode.field "uri" Decode.string)
        (Decode.at [ "owner" ] decodePlaylistOwner)
        (Decode.field "description" Decode.string)
