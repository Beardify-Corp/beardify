module Request.Playlist exposing
    ( -- follow
      get
      -- , getFollowedArtist
      -- , getItems
      -- , getRelatedArtists
      -- ,  getTopTrack
      -- , getVideos
    )

-- import Data.Youtube as Youtube

import Data.Album as Album exposing (AlbumSimplified)
import Data.Artist as Artist exposing (Artist)
import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Data.Track as Track exposing (Track)
import Data.User as User
import Http
import Json.Decode as Decode
import Request.Api as Api
import Task exposing (Task)


get : Session -> Data.Playlist.Id -> Task ( Session, Http.Error ) Data.Playlist.Playlist
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ Data.Playlist.idToString id ++ "?fields=description%2Curi%2Cid%2Cimages%2Cname%2Curi%2Cowner"
        , body = Http.emptyBody
        , resolver = Data.Playlist.decodePlaylist |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session



-- getTopTrack : Session -> Artist.Id -> Task ( Session, Http.Error ) (List Track)
-- getTopTrack session id =
--     let
--         country =
--             Maybe.map (.country >> User.countryToString) session.user
--                 |> Maybe.withDefault "US"
--     in
--     Http.task
--         { method = "GET"
--         , headers = [ Api.authHeader session ]
--         , url = Api.url ++ "artists/" ++ Artist.idToString id ++ "/top-tracks?country=" ++ country
--         , body = Http.emptyBody
--         , resolver = Decode.at [ "tracks" ] (Decode.list Track.decode) |> Api.jsonResolver
--         , timeout = Nothing
--         }
--         |> Api.mapError session
-- getItems : String -> Session -> Artist.Id -> Task ( Session, Http.Error ) (List AlbumSimplified)
-- getItems group session id =
--     let
--         country =
--             Maybe.map (.country >> User.countryToString) session.user
--                 |> Maybe.withDefault "US"
--     in
--     Http.task
--         { method = "GET"
--         , headers = [ Api.authHeader session ]
--         , url = Api.url ++ "artists/" ++ Artist.idToString id ++ "/albums" ++ "?country=" ++ country ++ "&limit=50&include_groups=" ++ group
--         , body = Http.emptyBody
--         , resolver = Decode.at [ "items" ] (Decode.list Album.decodeSimplified) |> Api.jsonResolver
--         , timeout = Nothing
--         }
--         |> Api.mapError session
-- getRelatedArtists : Session -> Artist.Id -> Task ( Session, Http.Error ) (List Artist)
-- getRelatedArtists session id =
--     Http.task
--         { method = "GET"
--         , headers = [ Api.authHeader session ]
--         , url = Api.url ++ "artists/" ++ Artist.idToString id ++ "/related-artists"
--         , body = Http.emptyBody
--         , resolver = Decode.at [ "artists" ] (Decode.list Artist.decode) |> Api.jsonResolver
--         , timeout = Nothing
--         }
--         |> Api.mapError session
-- getFollowedArtist : Session -> Artist.Id -> Task ( Session, Http.Error ) (List Bool)
-- getFollowedArtist session id =
--     Http.task
--         { method = "GET"
--         , headers = [ Api.authHeader session ]
--         , url = Api.url ++ "me/following/contains?type=artist&ids=" ++ Artist.idToString id
--         , body = Http.emptyBody
--         , resolver = Artist.isFollowing |> Api.jsonResolver
--         , timeout = Nothing
--         }
--         |> Api.mapError session
-- follow : Session -> String -> String -> (Result Http.Error () -> msg) -> Cmd msg
-- follow session method id msg =
--     Http.request
--         { method = method
--         , headers = [ Api.authHeader session ]
--         , url = Api.url ++ "me/following?type=artist&ids=" ++ id
--         , body = Http.emptyBody
--         , expect = Http.expectWhatever msg
--         , timeout = Nothing
--         , tracker = Nothing
--         }
-- getVideos : Session -> String -> Task ( Session, Http.Error ) (List Youtube.Video)
-- getVideos session query =
--     Http.task
--         { method = "GET"
--         , headers = [ Http.header "Authorization" "Bearer " ]
--         , url = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&q=surfing&key="
--         , body = Http.emptyBody
--         , resolver = Youtube.decodeYoutube |> Api.jsonResolver
--         , timeout = Nothing
--         }
--         |> Api.mapError session
