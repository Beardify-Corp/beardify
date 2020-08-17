module Request.Artist exposing
    ( follow
    , get
    , getFollowedArtist
    , getItems
    , getRelatedArtists
    , getTopTrack
    )

import Data.Album.AlbumSimplified exposing (AlbumSimplified, decodeAlbumSimplified)
import Data.Artist.Artist exposing (Artist, decodeArtist, isFollowing)
import Data.Id exposing (Id, idToString)
import Data.Session exposing (Session)
import Data.Track as Track exposing (Track)
import Data.User as User
import Http
import Json.Decode as Decode
import Request.Api as Api
import Task exposing (Task)


get : Session -> Id -> Task ( Session, Http.Error ) Artist
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ idToString id
        , body = Http.emptyBody
        , resolver = decodeArtist |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTopTrack : Session -> Id -> Task ( Session, Http.Error ) (List Track)
getTopTrack session id =
    let
        country =
            Maybe.map (.country >> User.countryToString) session.user
                |> Maybe.withDefault "US"
    in
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ idToString id ++ "/top-tracks?country=" ++ country
        , body = Http.emptyBody
        , resolver = Decode.at [ "tracks" ] (Decode.list Track.decodeTrack) |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getItems : String -> Session -> Id -> Task ( Session, Http.Error ) (List AlbumSimplified)
getItems group session id =
    let
        country =
            Maybe.map (.country >> User.countryToString) session.user
                |> Maybe.withDefault "US"
    in
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ idToString id ++ "/albums" ++ "?country=" ++ country ++ "&limit=50&include_groups=" ++ group
        , body = Http.emptyBody
        , resolver = Decode.at [ "items" ] (Decode.list decodeAlbumSimplified) |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getRelatedArtists : Session -> Id -> Task ( Session, Http.Error ) (List Artist)
getRelatedArtists session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "artists/" ++ idToString id ++ "/related-artists"
        , body = Http.emptyBody
        , resolver = Decode.at [ "artists" ] (Decode.list decodeArtist) |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getFollowedArtist : Session -> Id -> Task ( Session, Http.Error ) (List Bool)
getFollowedArtist session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/following/contains?type=artist&ids=" ++ idToString id
        , body = Http.emptyBody
        , resolver = isFollowing |> Api.jsonResolver
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
