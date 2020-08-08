module Views.Track exposing (view)

import Data.Image as Image
import Data.Player as Player exposing (..)
import Data.Track as Track exposing (Track)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE


type alias Config msg =
    { playTracks : List String -> msg
    }


view : Config msg -> PlayerContext -> List Track -> Track -> Html msg
view config context trackList track =
    let
        listTracksUri : String -> List String
        listTracksUri trackUri =
            trackList
                |> LE.dropWhile (\t -> t.uri /= trackUri)
                |> List.map .uri

        isTrackPlaying : String
        isTrackPlaying =
            Player.getCurrentTrackUri context

        cover : Image.Image
        cover =
            Image.filterByWidth 64 track.album.images
    in
    div
        [ class "Track Flex centeredVertical"
        , classList [ ( "active", isTrackPlaying == track.uri ) ]
        , onClick <| config.playTracks (listTracksUri track.uri)
        ]
        [ img [ class "Track__cover", src cover.url ] []
        , div [ class "Track__name Flex__full" ] [ text track.name ]
        , div [ class "Track__duration" ] [ text <| Track.durationFormat track.duration ]
        ]



-- view :
--  let
--     listTracksUri : String -> List String
--     listTracksUri trackUri =
--         tracks
--             |> LE.dropWhile (\track -> track.uri /= trackUri)
--             |> List.map .uri
--     isTrackPlaying : String
--     isTrackPlaying =
--         Player.getCurrentTrackUri context
-- in
-- tracks
--     |> List.map trackView
--     |> List.take 5
