module Data.Artist exposing
    ( Artist
    , ArtistList
    , ArtistSimplified
    , Id
    , decode
    , decodeArtistList
    , decodeSimplified
    , idToString
    , isFollowing
    , parseId
    )

import Data.Image as Image exposing (Image)
import Json.Decode as Decode exposing (Decoder(..), at, field, null, string)
import Url.Parser as Parser exposing (Parser)


type alias Artist =
    { id : Id
    , name : String
    , images : List Image
    , popularity : Int
    , type_ : String
    }


type alias ArtistSimplified =
    { id : Id
    , name : String
    }


type alias IsFollowing =
    List Bool


type Id
    = Id String


decode : Decoder Artist
decode =
    Decode.map5 Artist
        (Decode.field "id" decodeId)
        (Decode.field "name" Decode.string)
        (Decode.field "images" (Decode.list Image.decode))
        (Decode.field "popularity" Decode.int)
        (Decode.field "type" Decode.string)


decodeId : Decoder Id
decodeId =
    Decode.map Id Decode.string


decodeSimplified : Decoder ArtistSimplified
decodeSimplified =
    Decode.map2 ArtistSimplified
        (Decode.field "id" decodeId)
        (Decode.field "name" Decode.string)


idToString : Id -> String
idToString (Id id) =
    id


isFollowing : Decoder IsFollowing
isFollowing =
    Decode.list Decode.bool


parseId : Parser (Id -> a) a
parseId =
    Parser.map Id Parser.string


type alias ArtistList =
    { items : List Artist
    , next : String
    , total : Int
    , offset : Int
    , limit : Int
    }


decodeArtistList : Decode.Decoder ArtistList
decodeArtistList =
    Decode.map5 ArtistList
        (Decode.at [ "items" ] (Decode.list decode))
        (Decode.field "next"
            (Decode.oneOf [ string, null "" ])
        )
        (Decode.field "total" Decode.int)
        (Decode.field "offset" Decode.int)
        (Decode.field "limit" Decode.int)
