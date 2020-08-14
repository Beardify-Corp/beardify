module Data.Album exposing
    ( AlbumSimplified
    , Id
    , Type(..)
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


type alias AlbumSimplified =
    { type_ : Type
    , artists : List ArtistSimplified
    , id : Id
    , images : List Image
    , name : String
    , releaseDate : String
    , uri : String
    }


type Type
    = Album
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
                        Decode.succeed Album

                    "appears_on" ->
                        Decode.succeed AppearsOn

                    "compilation" ->
                        Decode.succeed Compilation

                    "single" ->
                        Decode.succeed Single

                    _ ->
                        Decode.fail "Invalid Type"
            )


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


typeToString : Type -> String
typeToString type_ =
    case type_ of
        Album ->
            "album"

        AppearsOn ->
            "appears_on"

        Compilation ->
            "compilation"

        Single ->
            "single"
