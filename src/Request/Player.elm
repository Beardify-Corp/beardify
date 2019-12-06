module Request.Player exposing
    ( get
    , next
    , pause
    , play
    , prev
    , seek
    )

import Data.Player as Player exposing (Player)
import Data.Session exposing (Session)
import Http
import Request.Api as Api
import Task exposing (Task)


get : Session -> Task ( Session, Http.Error ) Player
get session =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/player"
        , body = Http.emptyBody
        , resolver = Player.decode |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


next : Session -> Task ( Session, Http.Error ) ()
next session =
    Http.task
        { method = "POST"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/player/next"
        , body = Http.emptyBody
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session


pause : Session -> Task ( Session, Http.Error ) ()
pause session =
    Http.task
        { method = "PUT"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/player/pause"
        , body = Http.emptyBody
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session


play : Session -> Task ( Session, Http.Error ) ()
play session =
    Http.task
        { method = "PUT"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/player/play"
        , body = Http.emptyBody
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session


prev : Session -> Task ( Session, Http.Error ) ()
prev session =
    Http.task
        { method = "POST"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/player/previous"
        , body = Http.emptyBody
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session


seek : Session -> Int -> Task ( Session, Http.Error ) ()
seek session position =
    Http.task
        { method = "PUT"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/player/seek?position_ms=" ++ String.fromInt position
        , body = Http.emptyBody
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session