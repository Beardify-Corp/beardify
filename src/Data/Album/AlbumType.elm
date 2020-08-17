module Data.Album.AlbumType exposing (..)

import Json.Decode as Decode exposing (Decoder, string)


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
