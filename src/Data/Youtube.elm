module Data.Youtube exposing (Video, decodeYoutube)

import Json.Decode as Decode


decodeVideoId : Decode.Decoder String
decodeVideoId =
    Decode.field "videoId" Decode.string


type alias Snippet =
    { channelId : String
    , channelTitle : String
    , title : String
    }


decodeSnippet : Decode.Decoder Snippet
decodeSnippet =
    Decode.map3 Snippet
        (Decode.field "channelId" Decode.string)
        (Decode.field "channelTitle" Decode.string)
        (Decode.field "title" Decode.string)


type alias Video =
    { id : String
    , snippet : Snippet
    }


decodeVideo : Decode.Decoder Video
decodeVideo =
    Decode.map2 Video
        (Decode.at [ "id" ] decodeVideoId)
        (Decode.at [ "snippet" ] decodeSnippet)


decodeYoutube : Decode.Decoder (List Video)
decodeYoutube =
    Decode.at [ "items" ] (Decode.list decodeVideo)
