module Views.User exposing (view)

import Data.Image as Image
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)


view : User -> Html msg
view user =
    let
        avatar =
            Image.filterByWidth 0 user.avatar
    in
    div [ class "User" ]
        [ img [ class "User__avatar", src avatar.url ] []
        , div [ class "UserMenu" ]
            [ div [ class "UserMenu__infos" ]
                [ div [] [ text user.displayName ]
                ]

            -- , ul [ class "List unstyled" ]
            --     [ li [] [ a [ class "UserMenu__link", href "" ] [ text "Logout" ] ]
            --     , li [] [ a [ class "UserMenu__link", href "" ] [ text "aodhazdiuzdah" ] ]
            --     , li [] [ a [ class "UserMenu__link", href "" ] [ text "adlkzadij" ] ]
            --     ]
            ]
        ]
