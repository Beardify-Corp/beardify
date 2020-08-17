module Data.Search exposing (Search, decodeSearch)

import Data.Album.AlbumList
import Data.Artist exposing (ArtistList, decodeArtistList)
import Data.Track exposing (TrackList, decodeTrackList)
import Json.Decode as Decode


type alias Search =
    { albums : Data.Album.AlbumList.AlbumList
    , artists : ArtistList
    , tracks : TrackList
    }


decodeSearch : Decode.Decoder Search
decodeSearch =
    Decode.map3 Search
        (Decode.field "albums" Data.Album.AlbumList.decodeAlbumList)
        (Decode.field "artists" decodeArtistList)
        (Decode.field "tracks" decodeTrackList)
