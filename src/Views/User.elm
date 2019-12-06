module Views.User exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div [ class "User" ]
        [ img [ class "User__avatar", src "https://i.imgur.com/WHnO4oy.png" ] []
        , div [ class "UserMenu" ]
            [ div [ class "UserMenu__infos" ]
                [ div [] [ text "Guy Montagné" ]
                , div [] [ text "gmontagne@gmail.com" ]
                ]
            , ul [ class "List unstyled" ]
                [ li [] [ a [ class "UserMenu__link", href "" ] [ text "Logout" ] ]
                , li [] [ a [ class "UserMenu__link", href "" ] [ text "aodhazdiuzdah" ] ]
                , li [] [ a [ class "UserMenu__link", href "" ] [ text "adlkzadij" ] ]
                ]
            ]
        ]
