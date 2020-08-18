module Route exposing (Route(..), fromUrl, href, pushUrl)

import Browser.Navigation as Nav
import Data.Id exposing (Id, idToString, parseId)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, top)


type Route
    = Home
    | Artist Id
    | Playlist Id
    | Collection Id
    | Album Id
    | Login


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map Login (s "login")
        , Parser.map Artist (s "artist" </> parseId)
        , Parser.map Playlist (s "playlist" </> parseId)
        , Parser.map Collection (s "collection" </> parseId)
        , Parser.map Album (s "album" </> parseId)
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
                    [ "artist", idToString id ]

                Playlist id ->
                    [ "playlist", idToString id ]

                Collection id ->
                    [ "collection", idToString id ]

                Album id ->
                    [ "album", idToString id ]

                Home ->
                    []

                Login ->
                    [ "login" ]
    in
    "#/" ++ String.join "/" pieces
