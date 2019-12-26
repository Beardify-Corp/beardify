module Request.User exposing (get)

import Data.Session exposing (Session)
import Data.User as User exposing (User)
import Http
import Request.Api as Api
import Task exposing (Task)
import Url exposing (Url)


get : Session -> Maybe Url -> Task ( Session, Http.Error ) ( User, Maybe Url )
get session url =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me"
        , body = Http.emptyBody
        , resolver = User.decode |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Task.map (\user -> ( user, url ))
        |> Api.mapError session
