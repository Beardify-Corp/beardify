module Data.Search exposing (Search, decodeSearch)

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeAlbumSimplified)
import Data.Artist.Artist exposing (Artist, decodeArtist)
import Data.Paging exposing (Paging, decodePaging)
import Data.Track exposing (TrackList, decodeTrackList)
import Json.Decode as Decode


type alias Search =
    { albums : Paging AlbumSimplified
    , artists : Paging Artist
    , tracks : TrackList
    }


decodeSearch : Decode.Decoder Search
decodeSearch =
    Decode.map3 Search
        (Decode.field "albums" (decodePaging decodeAlbumSimplified))
        (Decode.field "artists" (decodePaging decodeArtist))
        (Decode.field "tracks" decodeTrackList)
