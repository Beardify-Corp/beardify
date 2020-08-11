module Request.Sidebar exposing (..)

import Data.Playlist exposing (PlaylistList, decodePlaylistList)
import Data.Session exposing (Session)
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Task ( Session, Http.Error ) PlaylistList
get session =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/playlists"
        , body = Http.emptyBody
        , resolver = decodePlaylistList |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session
