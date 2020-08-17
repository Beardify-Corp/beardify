module Data.Playlist exposing
    ( Playlist
    , PlaylistList
    , PlaylistOwner
    , decodePlaylist
    , decodePlaylistList
    )

import Data.Id
import Data.Image exposing (Image, decode)
import Json.Decode as Decode exposing (Decoder(..), at, field, null, string)


type alias PlaylistSimple =
    { id : Data.Id.Id
    , name : String
    }


decodePlaylistSimple : Decode.Decoder PlaylistSimple
decodePlaylistSimple =
    Decode.map2 PlaylistSimple
        (Decode.field "id" Data.Id.decodeId)
        (Decode.field "name" Decode.string)


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


type alias Playlist =
    { id : Data.Id.Id
    , images : List Image
    , name : String
    , uri : String
    , owner : PlaylistOwner
    , description : String
    }


decodePlaylist : Decode.Decoder Playlist
decodePlaylist =
    Decode.map6 Playlist
        (Decode.field "id" Data.Id.decodeId)
        (Decode.at [ "images" ] (Decode.list Data.Image.decode))
        (Decode.field "name" Decode.string)
        (Decode.field "uri" Decode.string)
        (Decode.at [ "owner" ] decodePlaylistOwner)
        (Decode.field "description" Decode.string)


type alias PlaylistList =
    { items : List PlaylistSimple
    , next : String
    , total : Int
    , offset : Int
    , limit : Int
    }


decodePlaylistList : Decode.Decoder PlaylistList
decodePlaylistList =
    Decode.map5 PlaylistList
        (Decode.at [ "items" ] (Decode.list decodePlaylistSimple))
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "total" Decode.int)
        (Decode.field "offset" Decode.int)
        (Decode.field "limit" Decode.int)
