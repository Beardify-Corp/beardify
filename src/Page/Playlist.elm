module Page.Playlist exposing (Model, Msg(..), init, update, view)

import Data.Album.AlbumType
import Data.Id
import Data.Player as Player exposing (..)
import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Data.Track
import Helper
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Http
import List.Extra as LE
import Request.Player
import Request.Playlist
import Route
import String
import Task
import Views.Artist
import Views.Cover as Cover


type alias Model =
    { playlist : Maybe Data.Playlist.Playlist
    , trackList : Data.Track.PlaylistTrackObject
    }


type Msg
    = AddTracklist (Result ( Session, Http.Error ) Data.Track.PlaylistTrackObject)
    | InitPlaylistInfos (Result ( Session, Http.Error ) Data.Playlist.Playlist)
    | PlayTracks (List String)
    | Played (Result ( Session, Http.Error ) ())


init : Data.Id.Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { playlist = Nothing
      , trackList =
            { items = []
            , limit = 0
            , next = ""
            , offset = 0
            , total = 0
            }
      }
    , session
    , Task.attempt InitPlaylistInfos (Request.Playlist.get session id)
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ trackList } as model) =
    case msg of
        InitPlaylistInfos (Ok playlistInfo) ->
            ( { model | playlist = Just playlistInfo }
            , session
            , Task.attempt AddTracklist (Request.Playlist.getTracks session playlistInfo.id 0)
            )

        InitPlaylistInfos (Err _) ->
            ( model, session, Cmd.none )

        AddTracklist (Ok newModel) ->
            if newModel.total > newModel.offset then
                let
                    moreTracks =
                        case model.playlist of
                            Just a ->
                                Task.attempt AddTracklist (Request.Playlist.getTracks session a.id (newModel.offset + 100))

                            Nothing ->
                                Cmd.none
                in
                ( { model
                    | trackList =
                        { trackList
                            | items = trackList.items ++ newModel.items
                            , offset = trackList.offset + newModel.offset
                        }
                  }
                , session
                , moreTracks
                )

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
            trackList.items

        isTrackPlaying : String
        isTrackPlaying =
            Player.getCurrentTrackUri context

        listTracksUri : String -> List String
        listTracksUri trackUri =
            List.map (\e -> e.track.uri) trackList.items
                |> LE.dropWhile (\t -> t /= trackUri)

        setIcon : Data.Album.AlbumType.Type -> Html msg
        setIcon albumType =
            case albumType of
                Data.Album.AlbumType.AlbumType ->
                    i [ class "PlaylistTracks__icon PlaylistTracks__icon--primary icon-discogs" ] []

                Data.Album.AlbumType.Single ->
                    i [ class "PlaylistTracks__icon PlaylistTracks__icon--secondary icon-pizza" ] []

                _ ->
                    i [ class "PlaylistTracks__icon icon-discogs" ] []

        trackView : Data.Track.TrackItem -> Html Msg
        trackView trackItem =
            div [ class "Playlist__content InFront" ]
                [ div
                    [ onClick <| PlayTracks (listTracksUri trackItem.track.uri)
                    , class "PlaylistTracks"
                    , classList [ ( "active", isTrackPlaying == trackItem.track.uri ) ]
                    ]
                    [ div [ class "PlaylistTracks__item" ]
                        [ div [ class "PlaylistTracks__name" ] [ text trackItem.track.name ]
                        , a [ class "PlaylistTracks__album", Route.href (Route.Album trackItem.track.album.id) ] [ setIcon trackItem.track.album.type_, text trackItem.track.album.name ]
                        ]
                    , div [ class "PlaylistTracks__item" ] (Views.Artist.view trackItem.track.artists)
                    , div [ class "PlaylistTracks__item" ] [ text <| trackItem.addedBy.id ]
                    , div [ class "PlaylistTracks__item" ] [ text <| Helper.convertDate trackItem.addedAt ]
                    , div [ class "PlaylistTracks__item" ] [ text <| Data.Track.durationFormat trackItem.track.duration ]
                    ]
                ]
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
                        (tracks |> List.map trackView)
                    ]
                ]
            ]
      ]
    )
