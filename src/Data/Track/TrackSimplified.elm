module Data.Track.TrackSimplified exposing
    ( TrackSimplified
    , decodeTrackSimplified
    )

import Data.Artist.ArtistSimplified exposing (ArtistSimplified, decodeArtistSimplified)
import Data.Id exposing (Id, decodeId)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline as JDP


type alias TrackSimplified =
    { artists : List ArtistSimplified
    , discNumber : Int
    , duration : Int
    , explicit : Bool
    , href : String
    , id : Id
    , name : String
    , trackNumber : Int
    , uri : String
    }


decodeTrackSimplified : Decoder TrackSimplified
decodeTrackSimplified =
    Decode.succeed TrackSimplified
        |> JDP.required "artists" (Decode.list decodeArtistSimplified)
        |> JDP.required "disc_number" Decode.int
        |> JDP.required "duration_ms" Decode.int
        |> JDP.required "explicit" Decode.bool
        |> JDP.required "href" Decode.string
        |> JDP.required "id" decodeId
        |> JDP.required "name" Decode.string
        |> JDP.required "track_number" Decode.int
        |> JDP.required "uri" Decode.string
