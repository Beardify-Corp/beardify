module Data.Track.TrackItem exposing (TrackItem, decodeTrackItem)

import Data.Track.Track exposing (Track, decodeTrack)
import Data.Track.TrackOwner exposing (TrackOwner, decodeTrackOwner)
import Json.Decode as Decode exposing (..)


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
