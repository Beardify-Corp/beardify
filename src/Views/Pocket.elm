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
import String.Extra as SE
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
view _ session =
    HE.viewIf (List.length session.pocket.albums > 0)
        (div [ class "Pocket" ]
            [ div [ class "Pocket__head" ]
                [ div [] [ text <| SE.pluralize "album" "albums" (List.length session.pocket.albums) ++ " in pocket" ]
                , button [ onClick Reset, class "Pocket__close" ] [ i [ class "icon-close" ] [] ]
                ]
            , div [ class "PocketPlaylists" ]
                [ div [ class "PocketPlaylists__addTo" ] [ text "Add to :" ]
                , div []
                    (session.playlists.items
                        |> List.filter (\playlist -> String.startsWith "#Collection" playlist.name)
                        |> List.map
                            (\playlist ->
                                div [ onClick <| Add (idToString playlist.id), class "PocketPlaylists__item" ] [ i [ class "List__icon icon-collection" ] [], text <| String.replace "#Collection " "" playlist.name ]
                            )
                    )
                ]
            ]
        )
