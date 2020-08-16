module Data.Image exposing (Image, Size(..), decode, filterByWidth)

import Json.Decode as Decode exposing (Decoder)
import List.Extra as LE


type Size
    = Small
    | Medium
    | Large


type alias Image =
    { height : Int
    , url : String
    , width : Int
    }


default : Image
default =
    { height = 0
    , url = ""
    , width = 0
    }


decode : Decoder Image
decode =
    Decode.map3 Image
        (Decode.field "height"
            (Decode.map
                (Maybe.withDefault 0)
                (Decode.maybe Decode.int)
            )
        )
        (Decode.field "url" Decode.string)
        (Decode.field "width"
            (Decode.map
                (Maybe.withDefault 0)
                (Decode.maybe Decode.int)
            )
        )


filterByWidth : Size -> List Image -> Image
filterByWidth width =
    case width of
        Small ->
            LE.getAt 2 >> Maybe.withDefault default

        Medium ->
            LE.getAt 1 >> Maybe.withDefault default

        Large ->
            LE.getAt 0 >> Maybe.withDefault default
