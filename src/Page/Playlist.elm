module Page.Playlist exposing (Model, Msg(..), init, update, view)

import Data.Album
import Data.Player exposing (..)
import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Data.Track
import Helper
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Http
import Request.Player
import Request.Playlist
import String
import Task
import Views.Artist
import Views.Cover as Cover


type alias Model =
    { playlist : Maybe Data.Playlist.Playlist
    , trackList : Data.Track.TrackList
    }


type Msg
    = AddTracklist (Result ( Session, Http.Error ) Data.Track.TrackList)
    | InitPlaylistInfos (Result ( Session, Http.Error ) Data.Playlist.Playlist)
    | PlayTracks (List String)
    | Played (Result ( Session, Http.Error ) ())


init : Data.Playlist.Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { playlist = Nothing
      , trackList =
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
    , Cmd.batch
        [ Task.attempt InitPlaylistInfos (Request.Playlist.get session id)
        , Task.attempt AddTracklist (Request.Playlist.getTracks session id 0)
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ trackList, playlist } as model) =
    case msg of
        InitPlaylistInfos (Ok playlistInfo) ->
            ( { model | playlist = Just playlistInfo }, session, Cmd.none )

        InitPlaylistInfos (Err _) ->
            ( model, session, Cmd.none )

        AddTracklist (Ok newModel) ->
            if newModel.tracks.total > newModel.tracks.offset then
                ( { model | trackList = newModel }, session, Cmd.none )
                -- case playlist of
                --     Just a ->
                --         ( newModel
                --         , session
                --         , Task.map2 (Model << Just)
                --             (Request.Playlist.get session a.id)
                --             (Request.Playlist.getTracks session a.id (newModel.trackList.tracks.offset + 100))
                --             |> Task.attempt Fetched
                --         )
                --     Nothing ->
                --         ( model, session, Cmd.none )

            else
                ( model, session, Cmd.none )

        AddTracklist (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )

        PlayTracks uris ->
            ( model, session, Task.attempt Played (Request.Player.playTracks session uris) )

        Played (Ok _) ->
            ( model, session, Cmd.none )

        Played (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view context { playlist, trackList } =
    let
        playlistName : String
        playlistName =
            Maybe.withDefault "" (Maybe.map .name playlist)

        playlistDescription : String
        playlistDescription =
            Maybe.withDefault "" (Maybe.map .description playlist)

        playlistOwner : Data.Playlist.PlaylistOwner
        playlistOwner =
            Maybe.withDefault
                { display_name = ""
                , href = ""
                , id = ""
                , uri = ""
                }
                (Maybe.map .owner playlist)

        artistCover : String
        artistCover =
            Maybe.withDefault [] (Maybe.map .images playlist)
                |> List.take 1
                |> List.map (\e -> e.url)
                |> String.concat

        tracks : List Data.Track.TrackItem
        tracks =
            trackList.tracks.items

        setIcon : Data.Album.Type -> Html msg
        setIcon albumType =
            case albumType of
                Data.Album.Album ->
                    i [ class "PlaylistTracks__icon PlaylistTracks__icon--primary icon-discogs" ] []

                Data.Album.Single ->
                    i [ class "PlaylistTracks__icon PlaylistTracks__icon--secondary icon-pizza" ] []

                _ ->
                    i [ class "PlaylistTracks__icon icon-discogs" ] []
    in
    ( playlistName
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Playlist__body HelperScrollArea__target" ]
                    [ div [ class "Playlist__content Flex spaceBetween centeredVertical" ]
                        [ div [ class "PlaylistHead InFront" ]
                            [ HE.viewIf (artistCover /= "") (img [ class "PlaylistHead__cover", src artistCover, width 100, height 100 ] [])
                            , div []
                                [ h1 [ class "Artist__name Heading first" ]
                                    [ text playlistName
                                    , span [ class "PlaylistHead__owner" ] [ text <| "by " ++ playlistOwner.display_name ]
                                    ]
                                , div [] [ text playlistDescription ]
                                ]
                            ]
                        , Cover.view artistCover Cover.Light
                        ]
                    , div [ class "Playlist__content InFront" ]
                        (tracks
                            |> List.map
                                (\e ->
                                    div [ class "PlaylistTracks" ]
                                        [ div [ class "PlaylistTracks__item" ]
                                            [ div [ class "PlaylistTracks__name" ] [ text e.track.name ]
                                            , div [] [ setIcon e.track.album.type_, text e.track.album.name ]
                                            ]
                                        , div [ class "PlaylistTracks__item" ] (Views.Artist.view e.track.artists)
                                        , div [ class "PlaylistTracks__item" ] [ text <| e.addedBy.id ]
                                        , div [ class "PlaylistTracks__item" ] [ text <| Helper.convertDate e.addedAt ]
                                        , div [ class "PlaylistTracks__item" ] [ text <| Data.Track.durationFormat e.track.duration ]
                                        ]
                                )
                        )
                    ]
                ]
            ]
      ]
    )
