module Page.Playlist exposing (Model, Msg(..), init, update, view)

import Data.Player exposing (..)
import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Data.Track
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Player
import Request.Playlist
import Task
import Views.Track


type alias Model =
    { playlist : Maybe Data.Playlist.Playlist
    , tracks : Data.Track.TrackList
    }


type Msg
    = Fetched (Result ( Session, Http.Error ) Model)
    | PlayTracks (List String)
    | Played (Result ( Session, Http.Error ) ())


init : Data.Playlist.Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { playlist = Nothing
      , tracks =
            { tracks =
                { items = []
                , limit = 0
                , next = ""
                , offset = 0
                , total = 0
                }
            }
      }
    , session
    , Task.map2 (Model << Just)
        (Request.Playlist.get session id)
        (Request.Playlist.getTracks session id)
        |> Task.attempt Fetched
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        Fetched (Ok newModel) ->
            ( newModel, session, Cmd.none )

        Fetched (Err ( newSession, err )) ->
            let
                _ =
                    Debug.log "newSession" err
            in
            ( model, newSession, Cmd.none )

        PlayTracks uris ->
            ( model, session, Task.attempt Played (Request.Player.playTracks session uris) )

        Played (Ok _) ->
            ( model, session, Cmd.none )

        Played (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view context { playlist, tracks } =
    let
        playlistName : String
        playlistName =
            Maybe.withDefault "" (Maybe.map .name playlist)
    in
    ( playlistName
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Artist__body HelperScrollArea__target" ]
                    [ div [ class "Flex spaceBetween centeredVertical" ]
                        [ h1 [ class "Artist__name Heading first" ] [ text playlistName ]
                        , div [] [ text <| Debug.toString tracks ]

                        -- , Views.Track.view { playTracks = PlayTracks } context playlist.tracks
                        --     |> List.take 5
                        --     |> div []
                        ]

                    -- , playlist.tracks
                    --     |> List.map (Views.Track.view { playTracks = PlayTracks } context tracks)
                    --     |> List.take 5
                    --     |> div []
                    ]
                ]
            ]
      ]
    )
