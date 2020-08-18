module Data.Track.TrackOwner exposing (TrackOwner, decodeTrackOwner)

import Json.Decode as Decode exposing (..)


type alias TrackOwner =
    { id : String }


decodeTrackOwner : Decode.Decoder TrackOwner
decodeTrackOwner =
    Decode.map TrackOwner
        (Decode.field "id" Decode.string)
