module Data.Search exposing (Search, decodeSearch)

import Data.Album.AlbumPaging exposing (AlbumPaging, decodeAlbumPaging)
import Data.Artist exposing (ArtistList, decodeArtistList)
import Data.Track exposing (TrackList, decodeTrackList)
import Json.Decode as Decode


type alias Search =
    { albums : AlbumPaging
    , artists : ArtistList
    , tracks : TrackList
    }


decodeSearch : Decode.Decoder Search
decodeSearch =
    Decode.map3 Search
        (Decode.field "albums" decodeAlbumPaging)
        (Decode.field "artists" decodeArtistList)
        (Decode.field "tracks" decodeTrackList)
