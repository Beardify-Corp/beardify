module Page.Album exposing (Model, Msg(..), init, update, view)

-- import Data.Youtube as Youtube

import Data.Album
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
import Request.Album
import Request.Artist
import Request.Player
import Route
import Task
import Task.Extra as TE
import Views.Album
import Views.Artist
import Views.Cover as Cover
import Views.Track


type alias Model =
    { album : Maybe Data.Album.Album
    , trackList : Data.Track.AlbumTrackObject
    }


type Msg
    = InitAlbumInfos (Result ( Session, Http.Error ) Data.Album.Album)
    | AddTracklist (Result ( Session, Http.Error ) Data.Track.AlbumTrackObject)


init : Data.Album.Id -> Session -> ( Model, Session, Cmd Msg )
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
update session msg ({ trackList } as model) =
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

        artists : List Artist.ArtistSimplified
        artists =
            Maybe.withDefault [] (Maybe.map .artists album)
    in
    ( "artistName"
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Artist__body HelperScrollArea__target" ]
                    [ div [ class "AlbumPage__head" ]
                        [ div [ class "Flex spaceBetween centeredVertical" ]
                            [ h1 [ class "Artist__name Heading first" ] [ text albumName ]
                            , Cover.view albumCover Cover.Normal
                            ]
                        , div [ class "InFront" ] (Views.Artist.view artists)
                        ]
                    , div [ class "AlbumPage__body InFront" ]
                        [ div [] [ HE.viewIf (albumCover /= "") (img [ class "AlbumPage__cover", src albumCover, width 300, height 300 ] []) ]
                        , div [ class "AlbumPage__tracklist" ]
                            (trackList.items
                                |> List.map
                                    (\trackItem ->
                                        div [ class "AlbumPageTrack" ]
                                            [ div [ class "AlbumPageTrack__left" ]
                                                [ div [ class "AlbumPageTrack__number" ] [ text <| String.fromInt trackItem.trackNumber ]
                                                , div [ class "AlbumPageTrack__name" ] [ text trackItem.name ]
                                                ]
                                            , div [] [ text <| Data.Track.durationFormat trackItem.duration ]
                                            ]
                                    )
                            )
                        ]
                    ]
                ]
            ]
      ]
    )
