module Data.Album.Album exposing
    ( Album
    , decodeAlbum
    )

import Data.Album.Index
import Data.Artist as Artist exposing (ArtistSimplified)
import Data.Id
import Data.Image as Image exposing (Image)
import Data.Track
import Json.Decode as Decode exposing (Decoder, string)


type alias Album =
    { type_ : Data.Album.Index.Type
    , artists : List ArtistSimplified
    , id : Data.Id.Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    , tracks : Data.Track.AlbumTrackObject
    }


decodeAlbum : Decoder Album
decodeAlbum =
    Decode.map8 Album
        (Decode.field "album_type" Data.Album.Index.decodeType)
        (Decode.field "artists" (Decode.list Artist.decodeSimplified))
        (Decode.field "id" Data.Id.decodeId)
        (Decode.at [ "images" ] (Decode.list Image.decode))
        (Decode.field "name" Decode.string)
        (Decode.field "release_date" Decode.string)
        (Decode.field "uri" Decode.string)
        (Decode.field "tracks" Data.Track.decodeAlbumTrackObject)
