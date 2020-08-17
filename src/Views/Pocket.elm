module Views.Pocket exposing (Model, Msg, defaultModel, init, update, view)

import Data.Pocket exposing (Pocket, defaultPocket)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Playlist
import Task


type alias Model =
    { pocket : Pocket
    }


type Msg
    = NoOp
    | Reset
    | Add
    | Played (Result ( Session, Http.Error ) ())


defaultModel : Model
defaultModel =
    { pocket = defaultPocket }


init : Session -> ( Model, Cmd Msg )
init session =
    ( defaultModel
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ pocket } as session) msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )

        Reset ->
            ( model, { session | pocket = { pocket | albums = [] } }, Cmd.none )

        Add ->
            let
                uris =
                    pocket.albums
            in
            ( model, session, Task.attempt Played (Request.Playlist.addAlbum session "3CL7dAZOAWOfJWLkO3YyTo" pocket.albums) )

        Played (Ok _) ->
            ( model, session, Cmd.none )

        Played (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


view : Model -> Session -> Html Msg
view model session =
    div [ class "Pocket" ]
        [ div [ class "Pocket__head" ] [ button [ onClick Reset ] [ text "Reset" ] ]
        , div []
            (session.pocket.albums
                |> List.map (\e -> div [] [ text e ])
            )
        , button [ onClick Add ] [ text "GO" ]
        ]
