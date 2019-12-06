module Views.User exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div [ class "User" ]
        [ img [ class "User__avatar", src "https://i.imgur.com/WHnO4oy.png" ] []
        , i [ class "User__moreIcon icon-caret-down" ] []
        , div [ class "UserMenu" ]
            [ div [ class "UserMenu__infos" ]
                [ div [ class "UserMenu__displayName" ] [ text "Guy Montagné" ]
                , div [ class "UserMenu__email" ] [ text "gmontagne@gmail.com" ]
                ]
            , ul [ class "UserMenuActions" ]
                [ li []
                    [ a [ class "UserMenuActions__item", href "" ]
                        [ i [ class "icon-logout UserMenuActions__icon" ] []
                        , text "Logout"
                        ]
                    ]
                , li []
                    [ a [ class "UserMenuActions__item", href "" ]
                        [ i [ class "icon-settings UserMenuActions__icon" ] []
                        , text "Settings"
                        ]
                    ]
                ]
            ]
        ]
