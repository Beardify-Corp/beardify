module Request.Album exposing (get, getTracks)

import Data.Album.Album exposing (Album)
import Data.Id exposing (Id, idToString)
import Data.Session exposing (Session)
import Data.Track
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Id -> Task ( Session, Http.Error ) Album
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "albums/" ++ idToString id
        , body = Http.emptyBody
        , resolver = Data.Album.Album.decodeAlbum |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTracks : Session -> Id -> Int -> Task ( Session, Http.Error ) Data.Track.AlbumTrackObject
getTracks session id offset =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "albums/" ++ idToString id ++ "/tracks?&offset=" ++ String.fromInt offset ++ "&limit=50"
        , body = Http.emptyBody
        , resolver = Data.Track.decodeAlbumTrackObject |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session
