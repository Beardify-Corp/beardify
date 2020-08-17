module Views.List exposing (collection, playlist)

import Data.Id exposing (idToString)
import Data.Playlist.Playlist exposing (Playlist)
import Data.Playlist.PlaylistSimplified exposing (PlaylistSimplified)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Url exposing (Url)


collection : Url -> PlaylistSimplified -> Html msg
collection currentUrl playlistItem =
    li
        [ class "List__item"
        , classList [ ( "active", Maybe.withDefault "" currentUrl.fragment == "/collection/" ++ idToString playlistItem.id ) ]
        ]
        [ i [ class "List__icon icon-collection" ] []
        , a [ class "List__link", Route.href (Route.Collection playlistItem.id) ] [ text <| String.replace "#Collection " "" playlistItem.name ]
        ]


playlist : Url -> PlaylistSimplified -> Html msg
playlist currentUrl playlistItem =
    li
        [ class "List__item"
        , classList [ ( "active", Maybe.withDefault "" currentUrl.fragment == "/playlist/" ++ idToString playlistItem.id ) ]
        ]
        [ i [ class "List__icon icon-playlist" ] []
        , a [ class "List__link", Route.href (Route.Playlist playlistItem.id) ] [ text playlistItem.name ]
        ]
