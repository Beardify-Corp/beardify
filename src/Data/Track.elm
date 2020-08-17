module Data.Track exposing
    ( AlbumTrackObject
    , PlaylistTrackObject
    , Track
    , TrackItem
    , TrackList
    , TrackSimplified
    , decodeAlbumTrackObject
    , decodePlaylistTrackObject
    , decodeTrack
    , decodeTrackList
    , decodeTrackSimplified
    , durationFormat
    )

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeAlbumSimplified)
import Data.Artist.ArtistSimplified exposing (ArtistSimplified, decodeArtistSimplified)
import Data.Id exposing (Id, decodeId)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline as JDP
import Time


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



--  TRACK


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


type alias PlaylistTrackObject =
    { items : List TrackItem
    , limit : Int
    , next : String
    , offset : Int
    , total : Int
    }


decodePlaylistTrackObject : Decode.Decoder PlaylistTrackObject
decodePlaylistTrackObject =
    Decode.map5 PlaylistTrackObject
        (Decode.at [ "items" ] (Decode.list decodeTrackItem))
        (Decode.field "limit" Decode.int)
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "offset" Decode.int)
        (Decode.field "total" Decode.int)


type alias AlbumTrackObject =
    { items : List TrackSimplified
    , limit : Int
    , next : String
    , offset : Int
    , total : Int
    }


decodeAlbumTrackObject : Decode.Decoder AlbumTrackObject
decodeAlbumTrackObject =
    Decode.map5 AlbumTrackObject
        (Decode.at [ "items" ] (Decode.list decodeTrackSimplified))
        (Decode.field "limit" Decode.int)
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "offset" Decode.int)
        (Decode.field "total" Decode.int)


type alias TrackOwner =
    { id : String }


decodeTrackOwner : Decode.Decoder TrackOwner
decodeTrackOwner =
    Decode.map TrackOwner
        (Decode.field "id" Decode.string)


type alias TrackItem =
    { addedAt : String
    , addedBy : TrackOwner
    , track : Track
    }


decodeTrackItem : Decode.Decoder TrackItem
decodeTrackItem =
    Decode.map3 TrackItem
        (Decode.field "added_at" Decode.string)
        (Decode.at [ "added_by" ] decodeTrackOwner)
        (Decode.at [ "track" ] decodeTrack)


type alias TrackList =
    { items : List Track
    , limit : Int
    , next : String
    , offset : Int
    , total : Int
    }


decodeTrackList : Decode.Decoder TrackList
decodeTrackList =
    Decode.map5 TrackList
        (Decode.at [ "items" ] (Decode.list decodeTrack))
        (Decode.field "limit" Decode.int)
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "offset" Decode.int)
        (Decode.field "total" Decode.int)
