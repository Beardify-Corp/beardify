module Data.Id exposing (Id, createId, decodeId, idToString, parseId)

import Json.Decode as Decode exposing (Decoder, string)
import Url.Parser as Parser exposing (Parser)


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


createId : String -> Id
createId string =
    Id string
