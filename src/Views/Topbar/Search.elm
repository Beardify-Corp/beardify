module Views.Topbar.Search exposing (Model, Msg(..), defaultModel, init, update, view)

import Data.Album
import Data.Artist
import Data.Image as Image
import Data.Session exposing (Session)
import Data.Track
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Search
import Route
import Task
import Views.Artist


type alias Model =
    { searchQuery : String
    , artists : List Data.Artist.Artist
    , albums : List Data.Album.AlbumSimplified
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
    | Finded (Result ( Session, Http.Error ) Request.Search.Search)


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
                , tracks = response.tracks.items
              }
            , session
            , Cmd.none
            )

        Finded (Err _) ->
            ( model, session, Cmd.none )


view : Model -> Session -> Html Msg
view model session =
    let
        artistView artist =
            li []
                [ a [ class "SearchResultArtist__item", Route.href (Route.Artist artist.id) ]
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
                [ a [ class "SearchResultArtist__item", Route.href (Route.Album album.id) ]
                    [ img
                        [ class "SearchResult__img"
                        , src (Image.filterByWidth Image.Small album.images).url
                        ]
                        []
                    , div []
                        [ div [ class "SearchResult__label" ] [ text album.name ]
                        , div [ class "SearchResult__subLabel" ]
                            [ a [ href "", class "Artist__link" ] (Views.Artist.view album.artists)
                            ]
                        ]
                    ]
                ]
    in
    div [ class "Search" ]
        [ input [ onInput Query, class "Search__input", type_ "text", placeholder "Search..." ] []
        , div [ class "SearchResult" ]
            [ div [ class "SearchResult__section" ]
                [ h3 [ class "SearchResult__title" ] [ text "Artists" ]
                , ul [ class "SearchResultArtist List unstyled" ]
                    (model.artists |> List.map artistView)
                ]
            , div [ class "SearchResult__section" ]
                [ h3 [ class "SearchResult__title" ] [ text "Albums" ]
                , ul [ class "SearchResultArtist List unstyled" ]
                    (model.albums |> List.map albumView)
                ]
            , div [ class "SearchResult__section" ]
                [ h3 [ class "SearchResult__title" ] [ text "Tracks" ]
                , ul [ class "SearchResultArtist List unstyled" ]
                    [ li []
                        [ a [ class "SearchResultArtist__item track", href "" ]
                            [ img
                                [ class "SearchResult__img track"
                                , src "https://i.scdn.co/image/08de8ef442ead93a54ce23bc3a717edfbb3a6fd8"
                                ]
                                []
                            , div []
                                [ div [ class "SearchResult__label" ] [ text "Metallica (1991)" ]
                                , div [ class "SearchResult__subLabel" ]
                                    [ a [ href "", class "Artist__link" ] [ text "Metallica" ]
                                    ]
                                ]
                            ]
                        ]
                    , li []
                        [ a [ class "SearchResultArtist__item track", href "" ]
                            [ img
                                [ class "SearchResult__img track"
                                , src "https://i.scdn.co/image/4841b1ab42b7c3e0272c3b7df570bc96857e93e4"
                                ]
                                []
                            , div []
                                [ div [ class "SearchResult__label" ] [ text "Metal Galaxy (2019)" ]
                                , div [ class "SearchResult__subLabel" ]
                                    [ a [ href "", class "Artist__link" ] [ text "BABYMETAL" ]
                                    ]
                                ]
                            ]
                        ]
                    , li []
                        [ a [ class "SearchResultArtist__item track", href "" ]
                            [ img
                                [ class "SearchResult__img track"
                                , src "https://i.scdn.co/image/c1e6f8f6c02db088661f585c3cb67cddfb511c88"
                                ]
                                []
                            , div []
                                [ div [ class "SearchResult__label" ] [ text "Master Of Puppets (Remastered) (1986)" ]
                                , div [ class "SearchResult__subLabel" ]
                                    [ a [ href "", class "Artist__link" ] [ text "Metallica" ]
                                    ]
                                ]
                            ]
                        ]
                    , li []
                        [ a [ class "SearchResultArtist__item track", href "" ]
                            [ img
                                [ class "SearchResult__img track"
                                , src "https://i.scdn.co/image/69b5b8dcb648dc590e4fd21b7e6ef402ebb730e5"
                                ]
                                []
                            , div []
                                [ div [ class "SearchResult__label" ] [ text "...And Justice For All (1988)" ]
                                , div [ class "SearchResult__subLabel" ]
                                    [ a [ href "", class "Artist__link" ] [ text "Metallica" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
