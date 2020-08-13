module Page.Album exposing (Model, Msg(..), init, update, view)

-- import Data.Youtube as Youtube

import Data.Album as Album exposing (AlbumSimplified)
import Data.Artist as Artist exposing (Artist)
import Data.Image as Image
import Data.Player exposing (..)
import Data.Session exposing (Session)
import Data.Track exposing (Track)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Http
import Request.Artist
import Request.Player
import Route
import Task
import Task.Extra as TE
import Views.Album
import Views.Cover as Cover
import Views.Track


type alias Model =
    { test : String
    }


type Msg
    = NoOp


init : Album.Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { test = "bite"
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
