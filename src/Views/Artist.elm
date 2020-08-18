module Views.Artist exposing (view)

import Data.Artist.ArtistSimplified exposing (ArtistSimplified)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route


view : List ArtistSimplified -> List (Html msg)
view =
    let
        item artist =
            a [ Route.Artist artist.id |> Route.href, class "Artist__link" ] [ text artist.name ]
    in
    List.map item >> List.intersperse (span [ class "Artist__coma" ] [ text ", " ])
