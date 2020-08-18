module Data.Search exposing (Search, decodeSearch)

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeAlbumSimplified)
import Data.Artist.Artist exposing (Artist, decodeArtist)
import Data.Paging exposing (Paging, decodePaging)
import Data.Track.Track exposing (Track, decodeTrack)
import Json.Decode as Decode


type alias Search =
    { albums : Paging AlbumSimplified
    , artists : Paging Artist
    , tracks : Paging Track
    }


decodeSearch : Decode.Decoder Search
decodeSearch =
    Decode.map3 Search
        (Decode.field "albums" (decodePaging decodeAlbumSimplified))
        (Decode.field "artists" (decodePaging decodeArtist))
        (Decode.field "tracks" (decodePaging decodeTrack))
