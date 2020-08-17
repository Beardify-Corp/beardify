module Data.Search exposing (Search, decodeSearch)

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeSimplified)
import Data.Artist exposing (ArtistList, decodeArtistList)
import Data.Paging exposing (Paging, decodePaging)
import Data.Track exposing (TrackList, decodeTrackList)
import Json.Decode as Decode


type alias Search =
    { albums : Paging AlbumSimplified
    , artists : ArtistList
    , tracks : TrackList
    }


decodeSearch : Decode.Decoder Search
decodeSearch =
    Decode.map3 Search
        (Decode.field "albums" (decodePaging decodeSimplified))
        (Decode.field "artists" decodeArtistList)
        (Decode.field "tracks" decodeTrackList)
