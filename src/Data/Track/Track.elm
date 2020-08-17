module Data.Track.Track exposing
    ( Track
    , decodeTrack
    )

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeAlbumSimplified)
import Data.Artist.ArtistSimplified exposing (ArtistSimplified, decodeArtistSimplified)
import Data.Id exposing (Id, decodeId)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline as JDP


type alias Track =
    { album : AlbumSimplified
    , artists : List ArtistSimplified
    , discNumber : Int
    , duration : Int
    , explicit : Bool
    , href : String
    , id : Id
    , name : String
    , popularity : Int
    , trackNumber : Int
    , uri : String
    }


decodeTrack : Decoder Track
decodeTrack =
    Decode.succeed Track
        |> JDP.required "album" decodeAlbumSimplified
        |> JDP.required "artists" (Decode.list decodeArtistSimplified)
        |> JDP.required "disc_number" Decode.int
        |> JDP.required "duration_ms" Decode.int
        |> JDP.required "explicit" Decode.bool
        |> JDP.required "href" Decode.string
        |> JDP.required "id" decodeId
        |> JDP.required "name" Decode.string
        |> JDP.required "popularity" Decode.int
        |> JDP.required "track_number" Decode.int
        |> JDP.required "uri" Decode.string
