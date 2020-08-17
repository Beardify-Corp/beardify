module Data.Album.AlbumSimplified exposing
    ( AlbumSimplified
    , decodeAlbumSimplified
    )

import Data.Album.AlbumType
import Data.Artist.ArtistSimplified exposing (ArtistSimplified, decodeArtistSimplified)
import Data.Id exposing (Id, decodeId)
import Data.Image as Image exposing (Image)
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline as JDP


type alias AlbumSimplified =
    { type_ : Data.Album.AlbumType.Type
    , artists : List ArtistSimplified
    , id : Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    }


decodeAlbumSimplified : Decoder AlbumSimplified
decodeAlbumSimplified =
    Decode.succeed AlbumSimplified
        |> JDP.required "album_type" Data.Album.AlbumType.decodeType
        |> JDP.required "artists" (Decode.list decodeArtistSimplified)
        |> JDP.required "id" decodeId
        |> JDP.requiredAt [ "images" ] (Decode.list Image.decode)
        |> JDP.required "name" Decode.string
        |> JDP.required "release_date" Decode.string
        |> JDP.required "uri" Decode.string
