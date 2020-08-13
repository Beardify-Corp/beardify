module Views.Album exposing (view)

import Data.Album exposing (AlbumSimplified)
import Data.Image as Image
import Data.Player as Player exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Views.Artist


type alias Config msg =
    { playAlbum : String -> msg
    }


view : Config msg -> PlayerContext -> Bool -> AlbumSimplified -> Html msg
view config context showArtist album =
    let
        cover : Image.Image
        cover =
            Image.filterByWidth 600 album.images

        isCurrentlyPlaying : Bool
        isCurrentlyPlaying =
            album.uri == Player.getCurrentAlbumUri context

        releaseFormat : String -> String
        releaseFormat date =
            date
                |> String.split "-"
                |> List.take 1
                |> String.concat
    in
    div
        [ class "Album" ]
        [ div [ class "Album__link" ]
            [ a [ href "#" ] [ img [ attribute "loading" "lazy", class "Album__cover", src cover.url ] [] ]
            , button [ onClick <| config.playAlbum album.uri, class "Album__play" ] [ i [ class "icon-play" ] [] ]
            , button [ class "Album__add" ] [ i [ class "icon-add" ] [] ]
            ]
        , HE.viewIf showArtist (div [ class "Album__name" ] [ span [] (Views.Artist.view album.artists) ])
        , div [ class "Album__name" ] [ text album.name ]
        , div [ class "Album__release" ] [ text <| releaseFormat album.releaseDate ]
        , HE.viewIf isCurrentlyPlaying (i [ class "Album__playing icon-sound" ] [])
        ]
