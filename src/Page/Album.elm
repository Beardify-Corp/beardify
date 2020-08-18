module Page.Album exposing (Model, Msg(..), init, update, view)

import Data.Album.Album exposing (Album, defaultAlbum)
import Data.Artist.ArtistSimplified exposing (ArtistSimplified)
import Data.Id exposing (Id)
import Data.Paging exposing (Paging)
import Data.Player as Player exposing (..)
import Data.Session exposing (Session)
import Data.Track.TrackSimplified exposing (TrackSimplified)
import Helper
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Http
import List.Extra as LE
import Request.Album
import Request.Player
import Task
import Views.Album
import Views.Artist
import Views.Cover as Cover


type alias Model =
    { album : Maybe Album
    , trackList : Paging TrackSimplified
    }


type Msg
    = InitAlbumInfos (Result ( Session, Http.Error ) Album)
    | AddTracklist (Result ( Session, Http.Error ) (Paging TrackSimplified))
    | PlayAlbum String
    | PlayTracks (List String)
    | Played (Result ( Session, Http.Error ) ())
    | GetAlbum Id
    | AddToPocket (Result ( Session, Http.Error ) Album)


init : Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { album = Nothing
      , trackList =
            { items = []
            , limit = 0
            , next = ""
            , offset = 0
            , total = 0
            }
      }
    , session
    , Task.attempt InitAlbumInfos (Request.Album.get session id)
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ pocket } as session) msg ({ trackList } as model) =
    case msg of
        InitAlbumInfos (Ok albumInfos) ->
            ( { model | album = Just albumInfos }
            , session
            , Task.attempt AddTracklist (Request.Album.getTracks session albumInfos.id 0)
            )

        InitAlbumInfos (Err _) ->
            ( model, session, Cmd.none )

        AddTracklist (Ok newModel) ->
            if newModel.total > newModel.offset then
                let
                    moreTracks =
                        case model.album of
                            Just a ->
                                Task.attempt AddTracklist (Request.Album.getTracks session a.id (newModel.offset + 100))

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

        AddTracklist (Err _) ->
            ( model, session, Cmd.none )

        PlayAlbum uri ->
            ( model, session, Task.attempt Played (Request.Player.playThis session uri) )

        PlayTracks uris ->
            ( model, session, Task.attempt Played (Request.Player.playTracks session uris) )

        Played (Ok _) ->
            ( model, session, Cmd.none )

        Played (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )

        GetAlbum albumId ->
            ( model, session, Task.attempt AddToPocket (Request.Album.get session albumId) )

        AddToPocket (Ok album) ->
            let
                firstTrackOfAlbum =
                    album.tracks.items |> List.take 1 |> List.map .uri
            in
            ( model, { session | pocket = { pocket | albums = List.append firstTrackOfAlbum pocket.albums |> LE.unique } }, Cmd.none )

        AddToPocket (Err _) ->
            ( model, session, Cmd.none )


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view context { album, trackList } =
    let
        albumCover : String
        albumCover =
            Maybe.withDefault [] (Maybe.map .images album)
                |> List.take 1
                |> List.map (\e -> e.url)
                |> String.concat

        albumName : String
        albumName =
            Maybe.withDefault "" (Maybe.map .name album)

        albumReleaseDate : String
        albumReleaseDate =
            Maybe.withDefault "" (Maybe.map .releaseDate album)

        artists : List ArtistSimplified
        artists =
            Maybe.withDefault [] (Maybe.map .artists album)

        isTrackPlaying : String
        isTrackPlaying =
            Player.getCurrentTrackUri context

        listTracksUri : String -> List String
        listTracksUri trackUri =
            List.map (\e -> e.uri) trackList.items
                |> LE.dropWhile (\t -> t /= trackUri)

        artistName : String
        artistName =
            artists
                |> List.map .name
                |> List.take 1
                |> String.concat

        albumObject : Album
        albumObject =
            Maybe.withDefault defaultAlbum album

        trackSumDuration =
            trackList.items
                |> List.map (\t -> t.duration)
                |> List.sum
    in
    ( albumName
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Artist__body HelperScrollArea__target" ]
                    [ div [ class "AlbumPage__head" ]
                        [ div []
                            [ h1 [ class "AlbumPage__title Heading first" ] [ text albumName ]
                            , Cover.view albumCover Cover.Normal
                            ]
                        , div [ class "InFront" ]
                            [ span [] (Views.Artist.view artists)
                            , span [] [ text " ⋅ " ]
                            , span [] [ text <| Helper.releaseDateFormat albumReleaseDate ]
                            , span [] [ text " ⋅ " ]
                            , span [] [ text <| Helper.durationFormatMinutes trackSumDuration ]
                            ]
                        ]
                    , div [ class "AlbumPage__body InFront" ]
                        [ HE.viewIf (albumCover /= "")
                            (div [ class "AlbumPage__cover" ]
                                [ Views.Album.viewSolo { playAlbum = PlayAlbum, addToPocket = GetAlbum } context albumObject ]
                            )
                        , div [ class "AlbumPage__tracklist" ]
                            (trackList.items
                                |> List.map
                                    (\trackItem ->
                                        div
                                            [ class "AlbumPageTrack"
                                            , onClick <| PlayTracks (listTracksUri trackItem.uri)
                                            , classList [ ( "active", isTrackPlaying == trackItem.uri ) ]
                                            ]
                                            [ div [ class "AlbumPageTrack__left" ]
                                                [ div [] [ text <| String.fromInt trackItem.trackNumber ]
                                                , div [ class "AlbumPageTrack__name" ] [ text trackItem.name ]
                                                , div []
                                                    (Views.Artist.view
                                                        (trackItem.artists
                                                            |> List.filter (\e -> e.name /= artistName)
                                                        )
                                                    )
                                                , div [ class "AlbumPageTrack__duration" ] [ text <| Helper.durationFormat trackItem.duration ]
                                                ]
                                            ]
                                    )
                            )
                        ]
                    ]
                ]
            ]
      ]
    )
