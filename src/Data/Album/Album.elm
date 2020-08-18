module Data.Album.Album exposing
    ( Album
    , decodeAlbum
    , defaultAlbum
    )

import Data.Album.AlbumType
import Data.Artist.ArtistSimplified exposing (ArtistSimplified, decodeArtistSimplified)
import Data.Id exposing (Id, createId, decodeId)
import Data.Image as Image exposing (Image)
import Data.Paging exposing (Paging, decodePaging, defaultPaging)
import Data.Track.TrackSimplified exposing (TrackSimplified, decodeTrackSimplified)
import Json.Decode as Decode exposing (Decoder, string)


defaultAlbum : Album
defaultAlbum =
    { type_ = Data.Album.AlbumType.AlbumType
    , artists = []
    , id = createId ""
    , images = []
    , name = ""
    , releaseDate = ""
    , uri = ""
    , tracks = defaultPaging
    }


type alias Album =
    { type_ : Data.Album.AlbumType.Type
    , artists : List ArtistSimplified
    , id : Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    , tracks : Paging TrackSimplified
    }


decodeAlbum : Decoder Album
decodeAlbum =
    Decode.map8 Album
        (Decode.field "album_type" Data.Album.AlbumType.decodeType)
        (Decode.field "artists" (Decode.list decodeArtistSimplified))
        (Decode.field "id" decodeId)
        (Decode.at [ "images" ] (Decode.list Image.decode))
        (Decode.field "name" Decode.string)
        (Decode.field "release_date" Decode.string)
        (Decode.field "uri" Decode.string)
        (Decode.field "tracks" (decodePaging decodeTrackSimplified))
