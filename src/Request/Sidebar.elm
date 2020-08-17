module Request.Sidebar exposing (..)

import Data.Paging exposing (Paging, decodePaging)
import Data.Playlist.PlaylistSimplified exposing (PlaylistSimplified, decodePlaylistSimplified)
import Data.Session exposing (Session)
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Int -> Task ( Session, Http.Error ) (Paging PlaylistSimplified)
get session offset =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/playlists" ++ "?offset=" ++ String.fromInt offset ++ "&limit=50"
        , body = Http.emptyBody
        , resolver = decodePaging decodePlaylistSimplified |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session
