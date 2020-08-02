module Request.Artist exposing
    ( follow
    , get
    , getFollowedArtist
    , getItems
    , getRelatedArtists
    , getTopTrack
    )

import Data.Album as Album exposing (AlbumSimplified)
import Data.Artist as Artist exposing (Artist)
import Data.Session exposing (Session)
import Data.Track as Track exposing (Track)
import Data.User as User
import Http
import Json.Decode as Decode
import Request.Api as Api
import Task exposing (Task)


get : Session -> Artist.Id -> Task ( Session, Http.Error ) Artist
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ Artist.idToString id
        , body = Http.emptyBody
        , resolver = Artist.decode |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTopTrack : Session -> Artist.Id -> Task ( Session, Http.Error ) (List Track)
getTopTrack session id =
    let
        country =
            Maybe.map (.country >> User.countryToString) session.user
                |> Maybe.withDefault "US"
    in
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ Artist.idToString id ++ "/top-tracks?country=" ++ country
        , body = Http.emptyBody
        , resolver = Decode.at [ "tracks" ] (Decode.list Track.decode) |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getItems : String -> Session -> Artist.Id -> Task ( Session, Http.Error ) (List AlbumSimplified)
getItems group session id =
    let
        country =
            Maybe.map (.country >> User.countryToString) session.user
                |> Maybe.withDefault "US"
    in
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ Artist.idToString id ++ "/albums" ++ "?country=" ++ country ++ "&limit=50&include_groups=" ++ group
        , body = Http.emptyBody
        , resolver = Decode.at [ "items" ] (Decode.list Album.decodeSimplified) |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getRelatedArtists : Session -> Artist.Id -> Task ( Session, Http.Error ) (List Artist)
getRelatedArtists session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ Artist.idToString id ++ "/related-artists"
        , body = Http.emptyBody
        , resolver = Decode.at [ "artists" ] (Decode.list Artist.decode) |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getFollowedArtist : Session -> Artist.Id -> Task ( Session, Http.Error ) (List Bool)
getFollowedArtist session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/following/contains?type=artist&ids=" ++ Artist.idToString id
        , body = Http.emptyBody
        , resolver = Artist.isFollowing |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


follow : Session -> String -> String -> (Result Http.Error () -> msg) -> Cmd msg
follow session method id msg =
    Http.request
        { method = method
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/following?type=artist&ids=" ++ id
        , body = Http.emptyBody
        , expect = Http.expectWhatever msg
        , timeout = Nothing
        , tracker = Nothing
        }
