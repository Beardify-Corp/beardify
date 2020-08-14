module Request.Album exposing (get)

import Data.Album
import Data.Artist as Artist exposing (Artist)
import Data.Session exposing (Session)
import Data.Track as Track exposing (Track)
import Data.User as User
import Http
import Json.Decode as Decode
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
