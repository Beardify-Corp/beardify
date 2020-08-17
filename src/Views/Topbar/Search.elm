module Views.Topbar.Search exposing (Model, Msg(..), defaultModel, init, update, view)

import Data.Album.AlbumSimplified
import Data.Artist
import Data.Image as Image
import Data.Search
import Data.Session exposing (Session)
import Data.Track
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Http
import Request.Player
import Request.Search
import Route
import Task
import Views.Artist


type alias Model =
    { searchQuery : String
    , artists : List Data.Artist.Artist
    , albums : List Data.Album.AlbumSimplified.AlbumSimplified
    , tracks : List Data.Track.Track
    }


defaultModel : Model
defaultModel =
    { searchQuery = ""
    , artists = []
    , albums = []
    , tracks = []
    }


init : Session -> ( Model, Cmd Msg )
init _ =
    ( defaultModel
    , Cmd.none
    )


type Msg
    = NoOp
    | Query String
    | Finded (Result ( Session, Http.Error ) Data.Search.Search)
    | PlayTrack (List String)
    | Played (Result ( Session, Http.Error ) ())
    | Bye


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )

        Query query ->
            ( { model | searchQuery = query }
            , session
            , Task.attempt Finded (Request.Search.get session query)
            )

        Finded (Ok response) ->
            ( { model
                | artists = response.artists.items |> List.take 6
                , albums = response.albums.items |> List.take 6
                , tracks = response.tracks.items |> List.take 7
              }
            , session
            , Cmd.none
            )

        Finded (Err _) ->
            ( model, session, Cmd.none )

        PlayTrack uris ->
            ( { model | searchQuery = "" }, session, Task.attempt Played (Request.Player.playTracks session uris) )

        Played (Ok _) ->
            ( model, session, Cmd.none )

        Played (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )

        Bye ->
            ( { model | searchQuery = "" }, session, Cmd.none )


view : Model -> Html Msg
view model =
    let
        artistView artist =
            li []
                [ a [ class "SearchResultArtist__item", onClick Bye, Route.href (Route.Artist artist.id) ]
                    [ img
                        [ class "SearchResult__img artist"
                        , src (Image.filterByWidth Image.Small artist.images).url
                        ]
                        []
                    , span [ class "SearchResult__label" ] [ text artist.name ]
                    ]
                ]

        albumView album =
            li []
                [ div [ class "SearchResultArtist__item" ]
                    [ a [ onClick Bye, Route.href (Route.Album album.id) ]
                        [ img
                            [ class "SearchResult__img"
                            , src (Image.filterByWidth Image.Small album.images).url
                            ]
                            []
                        ]
                    , div []
                        [ a [ onClick Bye, Route.href (Route.Album album.id), class "SearchResult__label" ] [ text album.name ]
                        , div [ class "SearchResult__subLabel" ] (Views.Artist.view album.artists)
                        ]
                    ]
                ]

        trackView track =
            li []
                [ div [ class "SearchResultArtist__item track", href "" ]
                    [ div [ onClick <| PlayTrack [ track.uri ] ] [ i [ class "icon-play" ] [] ]
                    , div []
                        [ div [ onClick <| PlayTrack [ track.uri ], class "SearchResult__label" ] [ text track.name ]
                        , div [ class "SearchResult__subLabel" ] (Views.Artist.view track.artists)
                        ]
                    ]
                ]
    in
    div [ class "Search" ]
        [ input [ onInput Query, class "Search__input", type_ "text", placeholder "Search artist, album or track..." ] []
        , HE.viewIf (model.searchQuery /= "")
            (div [ class "SearchResult" ]
                [ div [ class "SearchResult__section" ]
                    [ h3 [ class "SearchResult__title" ] [ text "Artists" ]
                    , ul [ class "SearchResult__list" ]
                        (model.artists |> List.map artistView)
                    ]
                , div [ class "SearchResult__section" ]
                    [ h3 [ class "SearchResult__title" ] [ text "Albums" ]
                    , ul [ class "SearchResult__list" ]
                        (model.albums |> List.map albumView)
                    ]
                , div [ class "SearchResult__section" ]
                    [ h3 [ class "SearchResult__title" ] [ text "Tracks" ]
                    , ul [ class "SearchResult__list" ]
                        (model.tracks |> List.map trackView)
                    ]
                ]
            )
        ]
