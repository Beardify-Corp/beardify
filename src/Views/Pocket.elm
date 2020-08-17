module Views.Pocket exposing (Model, Msg, defaultModel, init, update, view)

import Data.Pocket exposing (Pocket, defaultPocket)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { pocket : Pocket
    }


type Msg
    = NoOp


defaultModel : Model
defaultModel =
    { pocket = defaultPocket }


init : Session -> ( Model, Cmd Msg )
init session =
    ( defaultModel
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


view : Model -> Session -> Html Msg
view model session =
    div [ class "Pocket" ]
        [ text "pocket"
        ]
