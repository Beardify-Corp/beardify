module Request.Album exposing (get, getTracks)

import Data.Album
import Data.Session exposing (Session)
import Data.Track
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Data.Album.Id -> Task ( Session, Http.Error ) Data.Album.Album
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "albums/" ++ Data.Album.idToString id
        , body = Http.emptyBody
        , resolver = Data.Album.decodeAlbum |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTracks : Session -> Data.Album.Id -> Int -> Task ( Session, Http.Error ) Data.Track.AlbumTrackObject
getTracks session id offset =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "albums/" ++ Data.Album.idToString id ++ "/tracks?&offset=" ++ String.fromInt offset ++ "&limit=50"
        , body = Http.emptyBody
        , resolver = Data.Track.decodeAlbumTrackObject |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session
