module Views.Cover exposing (Opacity(..), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra as HE


type Opacity
    = Normal
    | Light


view : String -> Opacity -> Html msg
view imageUrl opacity =
    case opacity of
        Normal ->
            HE.viewIf (imageUrl /= "") (div [ class "Cover" ] [ img [ class "Cover__img", src imageUrl ] [] ])

        Light ->
            HE.viewIf (imageUrl /= "") (div [ class "Cover Cover--light" ] [ img [ class "Cover__img", src imageUrl ] [] ])
