module Views.Cover exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra as HE


view : String -> Html msg
view imageUrl =
    HE.viewIf (imageUrl /= "") (div [ class "Cover" ] [ img [ class "Cover__img", src imageUrl ] [] ])
