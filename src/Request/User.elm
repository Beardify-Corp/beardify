module Request.User exposing (get)

import Data.Session exposing (Session)
import Data.User as User exposing (User)
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Task ( Session, Http.Error ) User
get session =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me"
        , body = Http.emptyBody
        , resolver = User.decode |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session
