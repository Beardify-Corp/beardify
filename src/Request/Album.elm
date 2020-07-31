module Request.Album exposing (play)

import Data.Session exposing (Session)
import Http
import Json.Encode as Encode
import Request.Api as Api
import Task exposing (Task)


play : Session -> String -> Task ( Session, Http.Error ) ()
play session albumUri =
    Http.task
        { method = "PUT"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/player/play"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "context_uri", Encode.string albumUri )
                    ]
                )
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session
