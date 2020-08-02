module Request.Artist exposing
    ( follow
    , get
    , getFollowedArtist
    , getItems
    , getRelatedArtists
    , getTopTrack
    , getVideos
    )

import Data.Album as Album exposing (AlbumSimplified)
import Data.Artist as Artist exposing (Artist)
import Data.Session exposing (Session)
import Data.Track as Track exposing (Track)
import Data.User as User
import Data.Youtube as Youtube
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


getVideos : Session -> String -> Task ( Session, Http.Error ) (List Youtube.Video)
getVideos session query =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = "https://www.googleapis.com/youtube/v3/search?part=snippet&eventType=completed&q=azdazd&key=AIzaSyCaIDkQCdyo9oF9dZqC0vci30rlzdVInFs"
        , body = Http.emptyBody
        , resolver = Youtube.decodeYoutube |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session



-- q=AJIMAL&type=video&maxResults=4&part=snippet&key=AIzaSyDjlO4Gb0jCsxrot8KcNslXNSN_cIN5yqs
--   'https://www.googleapis.com/youtube/v3/search?part=snippet&eventType=completed&q=azdazd&key=AIzaSyBupy7Lc86eLHpnYun6uoEDW_73mI6bG34' \
-- AIzaSyBupy7Lc86eLHpnYun6uoEDW_73mI6bG34
-- Http.get ("https://www.googleapis.com/youtube/v3/search?q=" ++ query ++ "&type=video&maxResults=4&part=snippet&key=AIzaSyDjlO4Gb0jCsxrot8KcNslXNSN_cIN5yqs") decodeYoutube
