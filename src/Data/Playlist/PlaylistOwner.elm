module Data.Playlist.PlaylistOwner exposing (PlaylistOwner, decodePlaylistOwner)

import Json.Decode as Decode exposing (Decoder(..), field, string)


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
