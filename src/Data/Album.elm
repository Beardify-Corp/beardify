module Data.Album exposing
    ( Album
    , AlbumSimplified
    , Id
    , Type(..)
    , decodeAlbum
    , decodeSimplified
    , idToString
    , parseId
    , typeToString
    )

import Data.Artist as Artist exposing (ArtistSimplified)
import Data.Image as Image exposing (Image)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Url.Parser as Parser exposing (Parser)



-- ROUTING


parseId : Parser (Id -> a) a
parseId =
    Parser.map Id Parser.string


idToString : Id -> String
idToString (Id id) =
    id


type Id
    = Id String


decodeId : Decoder Id
decodeId =
    Decode.map Id Decode.string


type alias Album =
    { type_ : Type
    , artists : List ArtistSimplified
    , id : Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    }


decodeAlbum : Decoder Album
decodeAlbum =
    Decode.map7 Album
        (Decode.field "album_type" decodeType)
        (Decode.field "artists" (Decode.list Artist.decodeSimplified))
        (Decode.field "id" decodeId)
        (Decode.at [ "images" ] (Decode.list Image.decode))
        (Decode.field "name" Decode.string)
        (Decode.field "release_date" Decode.string)
        (Decode.field "uri" Decode.string)


type alias AlbumSimplified =
    { type_ : Type
    , artists : List ArtistSimplified
    , id : Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    }


decodeSimplified : Decoder AlbumSimplified
decodeSimplified =
    Decode.succeed AlbumSimplified
        |> JDP.required "album_type" decodeType
        |> JDP.required "artists" (Decode.list Artist.decodeSimplified)
        |> JDP.required "id" decodeId
        |> JDP.requiredAt [ "images" ] (Decode.list Image.decode)
        |> JDP.required "name" Decode.string
        |> JDP.required "release_date" Decode.string
        |> JDP.required "uri" Decode.string


type Type
    = AlbumType
    | AppearsOn
    | Compilation
    | Single


decodeType : Decoder Type
decodeType =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "album" ->
                        Decode.succeed AlbumType

                    "appears_on" ->
                        Decode.succeed AppearsOn

                    "compilation" ->
                        Decode.succeed Compilation

                    "single" ->
                        Decode.succeed Single

                    _ ->
                        Decode.fail "Invalid Type"
            )


typeToString : Type -> String
typeToString type_ =
    case type_ of
        AlbumType ->
            "album"

        AppearsOn ->
            "appears_on"

        Compilation ->
            "compilation"

        Single ->
            "single"
