module Request.Playlist exposing
    ( addAlbum
    , get
    , getAll
    , getTracks
    , removeAlbum
    )

import Data.Id exposing (Id, idToString)
import Data.Paging exposing (Paging, decodePaging)
import Data.Playlist.Playlist exposing (Playlist, decodePlaylist)
import Data.Playlist.PlaylistSimplified exposing (PlaylistSimplified, decodePlaylistSimplified)
import Data.Session exposing (Session)
import Data.Track.Track exposing (Track, decodeTrack)
import Data.Track.TrackItem exposing (TrackItem, decodeTrackItem)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Request.Api as Api
import Task exposing (Task)


getAll : Session -> Int -> Task ( Session, Http.Error ) (Paging PlaylistSimplified)
getAll session offset =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/playlists" ++ "?offset=" ++ String.fromInt offset ++ "&limit=50"
        , body = Http.emptyBody
        , resolver = decodePaging decodePlaylistSimplified |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


get : Session -> Id -> Task ( Session, Http.Error ) Playlist
get session id =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ idToString id ++ "?fields=description,uri,id,images,name,uri,owner"
        , body = Http.emptyBody
        , resolver = decodePlaylist |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


getTracks : Session -> Id -> Int -> Task ( Session, Http.Error ) (Paging TrackItem)
getTracks session id offset =
    Http.task
        { method = "GET"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ idToString id ++ "/tracks?&offset=" ++ String.fromInt offset ++ "&limit=100"
        , body = Http.emptyBody
        , resolver = decodePaging decodeTrackItem |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session


addAlbum : Session -> String -> List String -> Task ( Session, Http.Error ) ()
addAlbum session playlistId uris =
    Http.task
        { method = "POST"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ playlistId ++ "/tracks?uris=" ++ String.join "," uris
        , body = Http.emptyBody
        , resolver = Api.valueResolver ()
        , timeout = Nothing
        }
        |> Api.mapError session


removeAlbum : Session -> String -> Track -> Task ( Session, Http.Error ) Track
removeAlbum session playlistId track =
    -- let
    --     _ =
    --         Debug.log "" track
    -- in
    Http.task
        { method = "DELETE"
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "playlists/" ++ playlistId ++ "/tracks"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "tracks", Encode.list Encode.object [ [ ( "uri", Encode.string track.uri ) ] ] ) ]
                )
        , resolver = decodeTrack |> Api.jsonResolver
        , timeout = Nothing
        }
        |> Api.mapError session
