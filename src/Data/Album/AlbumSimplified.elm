module Data.Album.AlbumSimplified exposing
    ( AlbumSimplified
    , decodeSimplified
    )

import Data.Album.AlbumType
import Data.Artist as Artist exposing (ArtistSimplified)
import Data.Id
import Data.Image as Image exposing (Image)
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline as JDP


type alias AlbumSimplified =
    { type_ : Data.Album.AlbumType.Type
    , artists : List ArtistSimplified
    , id : Data.Id.Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    }


decodeSimplified : Decoder AlbumSimplified
decodeSimplified =
    Decode.succeed AlbumSimplified
        |> JDP.required "album_type" Data.Album.AlbumType.decodeType
        |> JDP.required "artists" (Decode.list Artist.decodeSimplified)
        |> JDP.required "id" Data.Id.decodeId
        |> JDP.requiredAt [ "images" ] (Decode.list Image.decode)
        |> JDP.required "name" Decode.string
        |> JDP.required "release_date" Decode.string
        |> JDP.required "uri" Decode.string
