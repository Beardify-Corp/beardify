module Page.Collection exposing (Model, Msg(..), init, update, view)

import Data.Id exposing (Id)
import Data.Player exposing (..)
import Data.Playlist exposing (..)
import Data.Session exposing (Session)
import Data.Track exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import List.Extra as LE
import Random
import Request.Player
import Request.Playlist
import String
import Task
import Views.Album
import Views.Cover as Cover


type alias Model =
    { playlist : Maybe Data.Playlist.Playlist
    , trackList : Data.Track.PlaylistTrackObject
    , dieFace : Int
    }


type Msg
    = AddTracklist (Result ( Session, Http.Error ) Data.Track.PlaylistTrackObject)
    | InitPlaylistInfos (Result ( Session, Http.Error ) Data.Playlist.Playlist)
    | Played (Result ( Session, Http.Error ) ())
    | PlayAlbum String
    | NewFace Int
    | NoOp Id


init : Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { playlist = Nothing
      , trackList =
            { items = []
            , limit = 0
            , next = ""
            , offset = 0
            , total = 0
            }
      , dieFace = 0
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
                ( model, session, Random.generate NewFace (Random.int 1 newModel.total) )

        AddTracklist (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )

        PlayAlbum uri ->
            ( model, session, Task.attempt Played (Request.Player.playThis session uri) )

        Played (Ok _) ->
            ( model, session, Cmd.none )

        Played (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )

        NewFace newFace ->
            ( { model | dieFace = newFace }
            , session
            , Cmd.none
            )

        NoOp _ ->
            ( model, session, Cmd.none )


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view context { playlist, trackList, dieFace } =
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

        tracks : List Data.Track.TrackItem
        tracks =
            trackList.items
                |> LE.uniqueBy (\e -> e.track.album.name)

        randomCover : String
        randomCover =
            case trackList.items |> LE.getAt dieFace of
                Just a ->
                    a.track.album.images |> List.take 1 |> List.map (\e -> e.url) |> String.concat

                Nothing ->
                    ""

        albumLength : String
        albumLength =
            tracks |> List.length |> String.fromInt
    in
    ( playlistName
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Playlist__body HelperScrollArea__target" ]
                    [ div [ class "Collection Flex " ]
                        [ div [ class "CollectionHead InFront" ]
                            [ h1 [ class "Artist__name Heading first" ]
                                [ text <| String.replace "#Collection " "" playlistName ]
                            , div [ class "CollectionHead__owner" ]
                                [ text playlistOwner.display_name
                                , text " - "
                                , text albumLength
                                , text " albums"
                                ]
                            , div [ class "CollectionHead__description" ] [ text playlistDescription ]
                            ]
                        , Cover.view randomCover Cover.Normal
                        ]
                    , div [ class "Playlist__content InFront" ]
                        [ div [ class "Artist__releaseList Paging" ]
                            (tracks
                                |> List.map
                                    (\a ->
                                        Views.Album.view { playAlbum = PlayAlbum, addToPocket = NoOp } context True a.track.album
                                    )
                            )
                        ]
                    ]
                ]
            ]
      ]
    )
