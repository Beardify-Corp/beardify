module Data.Album.Album exposing
    ( Album
    , decodeAlbum
    )

import Data.Album.AlbumType
import Data.Artist.ArtistSimplified exposing (ArtistSimplified, decodeArtistSimplified)
import Data.Id exposing (Id, decodeId)
import Data.Image as Image exposing (Image)
import Data.Track
import Json.Decode as Decode exposing (Decoder, string)


type alias Album =
    { type_ : Data.Album.AlbumType.Type
    , artists : List ArtistSimplified
    , id : Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    , tracks : Data.Track.AlbumTrackObject
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
        (Decode.field "tracks" Data.Track.decodeAlbumTrackObject)
