module Data.Playlist exposing
    ( Id
    ,  Playlist
       -- , PlaylistId

    ,  PlaylistList
       -- , PlaylistPaging
       -- , PlaylistPagingSimplified
       -- , PlaylistSimplified

    , decodePlaylist
    ,  decodePlaylistList
       -- , decodePlaylistPaging
       -- , decodePlaylistPagingSimplified
       -- , decodePlaylistSimplified
       -- , decodePlaylistTrack
       -- , playlistInit

    , idToString
    , parseId
    )

-- import Data.Track exposing (Track, decode)

import Data.Image exposing (Image, decode)
import Json.Decode as Decode exposing (Decoder(..), at, field, null, string)
import Url.Parser as Parser exposing (Parser)



-- type alias PlaylistId =
--     String
-- playlistInit : Playlist
-- playlistInit =
--     { id = ""
--     , images = []
--     , name = ""
--     , uri = ""
--     }


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


type alias Playlist =
    { id : Id
    , images : List Image
    , name : String
    , uri : String
    }


decodePlaylist : Decode.Decoder Playlist
decodePlaylist =
    Decode.map4 Playlist
        (Decode.field "id" decodeId)
        (Decode.at [ "images" ] (Decode.list Data.Image.decode))
        (Decode.field "name" Decode.string)
        (Decode.field "uri" Decode.string)



-- type alias PlaylistSimplified =
--     { id : String
--     , images : List Image
--     , name : String
--     , uri : String
--     }
-- decodePlaylistSimplified : Decode.Decoder PlaylistSimplified
-- decodePlaylistSimplified =
--     Decode.map4 PlaylistSimplified
--         (Decode.field "id" Decode.string)
--         (Decode.at [ "images" ] (Decode.list Data.Image.decode))
--         (Decode.field "name" Decode.string)
--         (Decode.field "uri" Decode.string)
-- type alias PlaylistPagingSimplified =
--     { items : List PlaylistSimplified
--     , next : String
--     }
-- decodePlaylistPagingSimplified : Decode.Decoder PlaylistPagingSimplified
-- decodePlaylistPagingSimplified =
--     Decode.map2 PlaylistPagingSimplified
--         (Decode.at [ "items" ] (Decode.list decodePlaylistSimplified))
--         (Decode.field "next"
--             (Decode.oneOf [ string, null "" ])
--         )
-- decodePlaylistTrack : Decode.Decoder Track
-- decodePlaylistTrack =
--     Decode.field "track" Data.Track.decode
-- type alias PlaylistPaging =
--     { items : List Track
--     , next : String
--     }
-- decodePlaylistPaging : Decode.Decoder PlaylistPaging
-- decodePlaylistPaging =
--     Decode.map2 PlaylistPaging
--         (Decode.at [ "items" ] (Decode.list decodePlaylistTrack))
--         (Decode.field "next"
--             (Decode.oneOf [ string, null "" ])
--         )


type alias PlaylistList =
    { items : List Playlist
    , next : String
    , total : Int
    , offset : Int
    , limit : Int
    }


decodePlaylistList : Decode.Decoder PlaylistList
decodePlaylistList =
    Decode.map5 PlaylistList
        (Decode.at [ "items" ] (Decode.list decodePlaylist))
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "total" Decode.int)
        (Decode.field "offset" Decode.int)
        (Decode.field "limit" Decode.int)
