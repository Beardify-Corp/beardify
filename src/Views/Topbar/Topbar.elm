module Views.Topbar.Topbar exposing (Msg(..), view)

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra as HE
import Route
import Views.Topbar.Search as Search exposing (..)
import Views.Topbar.User as User exposing (..)


type Msg
    = NoOp


view : Session -> Html Msg
view session =
    div [ class "Topbar" ]
        [ a [ Route.href Route.Home ] [ img [ class "Topbar__logo", src "./img/logo.svg" ] [] ]
        , div [ class "TopbarNavigation" ]
            [ button [ class "Button nude" ] [ i [ class "icon-previous TopbarNavigation__icon " ] [] ]
            , button [ class "Button nude disabled" ] [ i [ class "icon-next TopbarNavigation__icon " ] [] ]
            ]
        , Search.view
        , HE.viewMaybe User.view session.user
        ]
