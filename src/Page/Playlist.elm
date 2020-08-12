module Page.Playlist exposing (Model, Msg(..), init, update, view)

-- import Data.Youtube as Youtube

import Data.Player exposing (..)
import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Playlist
import Task


type alias Model =
    { playlist : Maybe Data.Playlist.Playlist
    }


type Msg
    = Fetched (Result ( Session, Http.Error ) Model)


init : Data.Playlist.Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { playlist = Nothing
      }
    , session
    , Task.map (Model << Just)
        (Request.Playlist.get session id)
        |> Task.attempt Fetched
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        Fetched (Ok newModel) ->
            ( newModel, session, Cmd.none )

        Fetched (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "artistName"
    , [ div [] [ text <| Debug.toString model ] ]
    )
