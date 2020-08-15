module Views.Topbar.Topbar exposing (Model, Msg(..), defaultModel, init, update, view)

import Data.Session as Session exposing (Session, switchTheme)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Extra as HE
import Route
import Views.Topbar.Search as Search exposing (..)
import Views.Topbar.User as User exposing (..)


type alias Model =
    { test : String
    }


defaultModel : Model
defaultModel =
    { test = "coucou"
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( defaultModel
    , Cmd.none
    )


type Msg
    = NoOp


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ store } as session) msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


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
