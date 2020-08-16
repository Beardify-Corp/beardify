module Request.Search exposing (get)

import Data.Search exposing (Search, decodeSearch)
import Data.Session exposing (Session)
import Http
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
