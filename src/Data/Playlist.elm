module Data.Playlist exposing
    ( Id
    , Playlist
    , PlaylistList
    , PlaylistOwner
    , decodePlaylist
    , decodePlaylistList
    , idToString
    , parseId
    )

import Data.Image exposing (Image, decode)
import Json.Decode as Decode exposing (Decoder(..), at, field, null, string)
import Url.Parser as Parser exposing (Parser)



-- ROUTING


parseId : Parser (Id -> a) a
parseId =
    Parser.map Id Parser.string


idToString : Id -> String
idToString (Id id) =
    id


type Id
    = Id String


decodeId : Decoder Id
decodeId =
    Decode.map Id Decode.string



-- DECODERS


type alias PlaylistSimple =
    { id : Id
    , name : String
    }


decodePlaylistSimple : Decode.Decoder PlaylistSimple
decodePlaylistSimple =
    Decode.map2 PlaylistSimple
        (Decode.field "id" decodeId)
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
