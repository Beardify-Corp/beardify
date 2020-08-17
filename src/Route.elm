module Route exposing (Route(..), fromUrl, href, pushUrl)

import Browser.Navigation as Nav
import Data.Artist as Artist
import Data.Id
import Data.Playlist as Playlist
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, top)


type Route
    = Home
    | Artist Data.Id.Id
    | Playlist Data.Id.Id
    | Collection Data.Id.Id
    | Album Data.Id.Id
    | Login


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map Login (s "login")
        , Parser.map Artist (s "artist" </> Data.Id.parseId)
        , Parser.map Playlist (s "playlist" </> Data.Id.parseId)
        , Parser.map Collection (s "collection" </> Data.Id.parseId)
        , Parser.map Album (s "album" </> Data.Id.parseId)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser


href : Route -> Attribute msg
href route =
    Attr.href (toString route)


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (toString route)


toString : Route -> String
toString route =
    let
        pieces =
            case route of
                Artist id ->
                    [ "artist", Data.Id.idToString id ]

                Playlist id ->
                    [ "playlist", Data.Id.idToString id ]

                Collection id ->
                    [ "collection", Data.Id.idToString id ]

                Album id ->
                    [ "album", Data.Id.idToString id ]

                Home ->
                    []

                Login ->
                    [ "login" ]
    in
    "#/" ++ String.join "/" pieces
