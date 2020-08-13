module Views.Track exposing (view)

import Data.Image as Image
import Data.Player as Player exposing (..)
import Data.Track
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE


type alias Config msg =
    { playTracks : List String -> msg
    }


view : Config msg -> PlayerContext -> List Data.Track.Track -> List (Html msg)
view config context trackList =
    let
        listTracksUri : String -> List String
        listTracksUri trackUri =
            trackList
                |> LE.dropWhile (\t -> t.uri /= trackUri)
                |> List.map .uri

        isTrackPlaying : String
        isTrackPlaying =
            Player.getCurrentTrackUri context
    in
    trackList
        |> List.map
            (\track ->
                let
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
                    , div [ class "Track__duration" ] [ text <| Data.Track.durationFormat track.duration ]
                    ]
            )
