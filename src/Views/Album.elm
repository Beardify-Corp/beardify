module Views.Album exposing (view, viewSolo)

import Data.Album.Album exposing (Album)
import Data.Album.AlbumSimplified exposing (AlbumSimplified)
import Data.Id exposing (Id)
import Data.Image as Image
import Data.Player as Player exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Route
import Views.Artist


type alias Config msg =
    { playAlbum : String -> msg
    , addToPocket : Id -> msg
    }


view : Config msg -> PlayerContext -> Bool -> AlbumSimplified -> Html msg
view config context showArtist album =
    let
        cover : Image.Image
        cover =
            Image.filterByWidth Image.Medium album.images

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
            [ a [ Route.href (Route.Album album.id) ] [ img [ attribute "loading" "lazy", class "Album__cover", src cover.url ] [] ]
            , button [ onClick <| config.playAlbum album.uri, class "Album__play" ] [ i [ class "icon-play" ] [] ]
            , button [ onClick <| config.addToPocket album.id, class "Album__add" ] [ i [ class "icon-add" ] [] ]
            , HE.viewIf isCurrentlyPlaying (i [ class "Album__playing icon-sound" ] [])
            ]
        , div [ class "Album__name" ] [ text album.name ]
        , HE.viewIf showArtist (div [ class "Album__name" ] [ span [] (Views.Artist.view album.artists) ])
        , div [ class "Album__release" ] [ text <| releaseFormat album.releaseDate ]
        ]


viewSolo : Config msg -> PlayerContext -> Album -> Html msg
viewSolo config context album =
    let
        cover : Image.Image
        cover =
            Image.filterByWidth Image.Large album.images

        isCurrentlyPlaying : Bool
        isCurrentlyPlaying =
            album.uri == Player.getCurrentAlbumUri context
    in
    div
        [ class "Album" ]
        [ div [ class "Album__link" ]
            [ img [ attribute "loading" "lazy", class "Album__cover", src cover.url ] []
            , button [ onClick <| config.playAlbum album.uri, class "Album__play" ] [ i [ class "icon-play" ] [] ]
            , button [ onClick <| config.addToPocket album.id, class "Album__add" ] [ i [ class "icon-add" ] [] ]
            , HE.viewIf isCurrentlyPlaying (i [ class "Album__playing icon-sound" ] [])
            ]
        ]
