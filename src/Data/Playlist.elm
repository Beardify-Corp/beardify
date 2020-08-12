module Data.Playlist exposing
    ( Id
    , Playlist
    , PlaylistList
    , decodePlaylist
    , decodePlaylistList
    , idToString
    , parseId
    )

import Data.Image exposing (Image, decode)
import Data.Track
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



-- "owner": {
--     "display_name": "Boulinosaure",
--     "external_urls": {
--       "spotify": "https://open.spotify.com/user/11138153489"
--     },
--     "href": "https://api.spotify.com/v1/users/11138153489",
--     "id": "11138153489",
--     "type": "user",
--     "uri": "spotify:user:11138153489"
--   },


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
    , tracks : Data.Track.TrackList
    }


decodePlaylist : Decode.Decoder Playlist
decodePlaylist =
    Decode.map7 Playlist
        (Decode.field "id" decodeId)
        (Decode.at [ "images" ] (Decode.list Data.Image.decode))
        (Decode.field "name" Decode.string)
        (Decode.field "uri" Decode.string)
        (Decode.at [ "owner" ] decodePlaylistOwner)
        (Decode.field "description" Decode.string)
        (Decode.at [ "tracks" ] Data.Track.decodeTrackList)



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
