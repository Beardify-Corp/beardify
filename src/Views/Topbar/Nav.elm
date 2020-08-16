module Views.Topbar.Nav exposing (Model, Msg(..), defaultModel, init, update, view)

import Browser.Navigation
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


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


view : Html Msg
view =
    div [ class "Nav" ]
        [ button [ onClick Back, class "Button nude" ] [ i [ class "icon-previous Nav__icon " ] [] ]
        , button [ onClick Forward, class "Button nude" ] [ i [ class "icon-next Nav__icon " ] [] ]
        ]
