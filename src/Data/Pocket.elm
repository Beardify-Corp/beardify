module Data.Pocket exposing (Pocket, defaultPocket)


type alias Pocket =
    { albums : List String
    , tracks : List String
    }


defaultPocket : Pocket
defaultPocket =
    { albums = []
    , tracks = []
    }
