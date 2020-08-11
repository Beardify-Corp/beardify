module Page.Playlist exposing (Model, Msg(..), init, update, view)

-- import Data.Youtube as Youtube

import Data.Player exposing (..)
import Data.Playlist as Playlist exposing (..)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { test : String
    }


type Msg
    = NoOp


init : Playlist.Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { test = Playlist.idToString id
      }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view context model =
    ( "artistName"
    , [ div [] [ text model.test ] ]
    )
