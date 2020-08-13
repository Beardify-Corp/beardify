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
        , url = Api.url ++ "playlists/" ++ Data.Playlist.idToString id ++ "?fields=description,uri,id,images,name,uri,owner"
        , body = Http.emptyBody
        , resolver = Data.Playlist.decodePlaylist |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTracks : Session -> Data.Playlist.Id -> Int -> Task ( Session, Http.Error ) Data.Track.PlaylistTrackObject
getTracks session id offset =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ Data.Playlist.idToString id ++ "/tracks?limit=100&offset=" ++ String.fromInt offset
        , body = Http.emptyBody
        , resolver = Data.Track.decodePlaylistTrackObject |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session



-- getTracks : Session -> Data.Playlist.Id -> Int -> Task ( Session, Http.Error ) Data.Track.TrackList
-- getTracks session id offset =
--     Http.task
--         { method = "GET"
--         , headers = [ Api.authHeader session ]
--         , url = Api.url ++ "playlists/" ++ Data.Playlist.idToString id ++ "?fields=tracks" ++ "&offset=" ++ String.fromInt offset ++ "&limit=100"
--         , body = Http.emptyBody
--         , resolver = Data.Track.decodeTrackList |> Api.jsonResolver
--         , timeout = Nothing
--         }
--         |> Api.mapError session
-- , url = Api.url ++ "me/playlists" ++ "?offset=" ++ String.fromInt offset ++ "&limit=50"
-- https://api.spotify.com/v1/playlists/1UwI3YEeGUcnZi73hoVPwM/tracks?fields=items&limit=1&offset=10
-- https://api.spotify.com/v1/playlists/1UwI3YEeGUcnZi73hoVPwM/tracks&limit=100&offset=100
