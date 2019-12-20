module Data.User exposing (User, countryToString, decode, idToString)

import Data.Image as Image exposing (Image)
import Json.Decode as Decode exposing (Decoder)


type alias User =
    { avatar : List Image
    , country : Country
    , displayName : String
    , id : Id
    }


type Id
    = Id String


type Country
    = Country String


countryToString : Country -> String
countryToString (Country country) =
    country


decode : Decoder User
decode =
    Decode.map4 User
        (Decode.field "images" (Decode.list Image.decode))
        (Decode.field "country" (Decode.map Country Decode.string))
        (Decode.field "display_name" Decode.string)
        (Decode.field "id" (Decode.map Id Decode.string))


idToString : Id -> String
idToString (Id id) =
    id
