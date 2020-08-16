module Views.Topbar.Topbar exposing (Model, Msg(..), defaultModel, init, update, view)

import Browser.Navigation
import Data.Session exposing (Session)
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
init _ =
    ( defaultModel
    , Cmd.none
    )


type Msg
    = Back
    | Forward


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ navKey } as session) msg model =
    case msg of
        Back ->
            ( model, session, Browser.Navigation.back navKey 1 )

        Forward ->
            ( model, session, Browser.Navigation.forward navKey 1 )


view : Session -> Html Msg
view session =
    div [ class "Topbar" ]
        [ a [ Route.href Route.Home ] [ img [ class "Topbar__logo", src "./img/logo.svg" ] [] ]
        , div [ class "TopbarNavigation" ]
            [ button [ onClick Back, class "Button nude" ] [ i [ class "icon-previous TopbarNavigation__icon " ] [] ]
            , button [ onClick Forward, class "Button nude" ] [ i [ class "icon-next TopbarNavigation__icon " ] [] ]
            ]
        , Search.view
        , HE.viewMaybe User.view session.user
        ]
