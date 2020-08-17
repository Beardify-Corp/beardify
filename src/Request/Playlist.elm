module Request.Playlist exposing
    ( addAlbum
    , get
    , getTracks
    )

import Data.Id exposing (Id, idToString)
import Data.Paging exposing (Paging, decodePaging)
import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Data.Track.TrackItem exposing (TrackItem, decodeTrackItem)
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Id -> Task ( Session, Http.Error ) Data.Playlist.Playlist
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ idToString id ++ "?fields=description,uri,id,images,name,uri,owner"
        , body = Http.emptyBody
        , resolver = Data.Playlist.decodePlaylist |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTracks : Session -> Id -> Int -> Task ( Session, Http.Error ) (Paging TrackItem)
getTracks session id offset =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ idToString id ++ "/tracks?&offset=" ++ String.fromInt offset ++ "&limit=100"
        , body = Http.emptyBody
        , resolver = decodePaging decodeTrackItem |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


addAlbum : Session -> String -> List String -> Task ( Session, Http.Error ) ()
addAlbum session playlistId uris =
    Http.task
        { method = "POST"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ playlistId ++ "/tracks?uris=" ++ String.join "," uris
        , body = Http.emptyBody
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session
