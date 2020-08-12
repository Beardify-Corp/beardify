module Request.Playlist exposing
    ( get
    , getTracks
    )

import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Data.Track
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Data.Playlist.Id -> Task ( Session, Http.Error ) Data.Playlist.Playlist
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ Data.Playlist.idToString id
        , body = Http.emptyBody
        , resolver = Data.Playlist.decodePlaylist |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTracks : Session -> Data.Playlist.Id -> Task ( Session, Http.Error ) Data.Track.TrackList
getTracks session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ Data.Playlist.idToString id ++ "?fields=tracks"
        , body = Http.emptyBody
        , resolver = Data.Track.decodeTrackList |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session
