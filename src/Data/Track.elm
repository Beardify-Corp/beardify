module Data.Track exposing (Track, TrackList, decodeTrack, decodeTrackList, durationFormat)

import Data.Album as Album exposing (AlbumSimplified)
import Data.Artist as Artist exposing (ArtistSimplified)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline as JDP
import Time


decodeId : Decoder Id
decodeId =
    Decode.map Id Decode.string


type Id
    = Id String


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
    , previewUrl : Maybe String
    , trackNumber : Int
    , uri : String
    , isLocal : Bool
    }


durationFormat : Int -> String
durationFormat duration =
    let
        toTime unit =
            duration
                |> Time.millisToPosix
                |> unit Time.utc

        hour =
            if toTime Time.toHour > 0 then
                String.fromInt (toTime Time.toHour) ++ ":"

            else
                ""

        minute =
            String.fromInt (toTime Time.toMinute) ++ ":"

        second =
            if toTime Time.toSecond < 10 then
                "0" ++ String.fromInt (toTime Time.toSecond)

            else
                String.fromInt (toTime Time.toSecond)
    in
    hour ++ minute ++ second


decodeTrack : Decoder Track
decodeTrack =
    Decode.succeed Track
        |> JDP.required "album" Album.decodeSimplified
        |> JDP.required "artists" (Decode.list Artist.decodeSimplified)
        |> JDP.required "disc_number" Decode.int
        |> JDP.required "duration_ms" Decode.int
        |> JDP.required "explicit" Decode.bool
        |> JDP.required "href" Decode.string
        |> JDP.required "id" decodeId
        |> JDP.required "name" Decode.string
        |> JDP.required "popularity" Decode.int
        |> JDP.optional "preview_url" (Decode.map Just Decode.string) Nothing
        |> JDP.required "track_number" Decode.int
        |> JDP.required "uri" Decode.string
        |> JDP.required "is_local" Decode.bool


type alias PlaylistTrackObject =
    { track : Track
    }


decodePlaylistTrackObject : Decode.Decoder PlaylistTrackObject
decodePlaylistTrackObject =
    Decode.map PlaylistTrackObject
        (Decode.at [ "track" ] decodeTrack)


type alias TrackList =
    { items : List PlaylistTrackObject
    , limit : Int
    , next : String
    , offset : Int
    , total : Int
    }


decodeTrackList : Decode.Decoder TrackList
decodeTrackList =
    Decode.map5 TrackList
        (Decode.at [ "items" ] (Decode.list decodePlaylistTrackObject))
        (Decode.field "limit" Decode.int)
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "offset" Decode.int)
        (Decode.field "total" Decode.int)
