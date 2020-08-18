module Views.Pocket exposing (Model, Msg, defaultModel, init, update, view)

import Data.Id exposing (idToString)
import Data.Pocket exposing (Pocket, defaultPocket)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Http
import Request.Playlist
import Task


type alias Model =
    { pocket : Pocket
    }


type Msg
    = Reset
    | Add String
    | Played (Result ( Session, Http.Error ) ())


defaultModel : Model
defaultModel =
    { pocket = defaultPocket }


init : Session -> ( Model, Cmd Msg )
init _ =
    ( defaultModel
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ pocket } as session) msg model =
    case msg of
        Reset ->
            ( model, { session | pocket = { pocket | albums = [] } }, Cmd.none )

        Add playlistId ->
            ( model
            , { session | pocket = { pocket | albums = [] } }
            , Task.attempt Played (Request.Playlist.addAlbum session playlistId pocket.albums)
            )

        Played (Ok _) ->
            ( model, session, Cmd.none )

        Played (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


view : Model -> Session -> Html Msg
view model session =
    HE.viewIf (model.pocket.albums == [])
        (div [ class "Pocket" ]
            [ div [ class "Pocket__head" ] [ button [ onClick Reset ] [ text "Reset" ] ]
            , div []
                (session.pocket.albums
                    |> List.map (\e -> div [] [ text e ])
                )
            , div [ class "PocketPlaylists" ]
                (session.playlists.items
                    |> List.filter (\playlist -> String.startsWith "#Collection" playlist.name)
                    |> List.map
                        (\playlist ->
                            div [ onClick <| Add (idToString playlist.id), class "PocketPlaylists__item" ] [ text playlist.name ]
                        )
                )
            ]
        )
