module Request.Search exposing (Search, decodeSearch, get)

import Data.Album exposing (AlbumList, decodeAlbumList)
import Data.Artist exposing (ArtistList, decodeArtistList)
import Data.Session exposing (Session)
import Data.Track exposing (TrackList, decodeTrackList)
import Http
import Json.Decode as Decode
import Request.Api as Api
import Task exposing (Task)


get : Session -> String -> Task ( Session, Http.Error ) Search
get session query =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "search" ++ "?q=" ++ query ++ "&type=artist,album,track"
        , body = Http.emptyBody
        , resolver = decodeSearch |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


type alias Search =
    { albums : AlbumList
    , artists : ArtistList
    , tracks : TrackList
    }


decodeSearch : Decode.Decoder Search
decodeSearch =
    Decode.map3 Search
        (Decode.field "albums" decodeAlbumList)
        (Decode.field "artists" decodeArtistList)
        (Decode.field "tracks" decodeTrackList)
