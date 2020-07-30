module Page.Artist exposing (Model, Msg(..), init, update, view)

import Data.Album as Album exposing (AlbumSimplified)
import Data.Artist as Artist exposing (Artist)
import Data.Image as Image
import Data.Session exposing (Session)
import Data.Track as Track exposing (Track)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.Artist as Request
import Route
import Task


type alias Model =
    { artist : Maybe Artist
    , albums : List AlbumSimplified
    , tracks : List Track
    , relatedArtists : List Artist
    , followed : List Bool
    }


type Msg
    = Fetched (Result ( Session, Http.Error ) Model)
    | Follow


init : Artist.Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { artist = Nothing
      , albums = []
      , tracks = []
      , relatedArtists = []
      , followed = []
      }
    , session
    , Task.map5 (Model << Just)
        (Request.get session id)
        (Request.getAlbums session id)
        (Request.getTopTrack session id)
        (Request.getRelatedArtists session id)
        (Request.getFollowedArtist session id)
        |> Task.attempt Fetched
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        Follow ->
            ( model, session, Cmd.none )

        Fetched (Ok newModel) ->
            ( newModel, session, Cmd.none )

        Fetched (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


relatedArtistsView : List Artist -> List (Html msg)
relatedArtistsView artists =
    let
        relatedArtistView artist =
            let
                cover =
                    Image.filterByWidth 160 artist.images
            in
            a [ class "ArtistSimilar__item", Route.href (Route.Artist artist.id) ]
                [ img [ class "ArtistSimilar__avatar", src cover.url ] []
                , span [ class "ArtistSimilar__name" ] [ text artist.name ]
                ]
    in
    List.map relatedArtistView artists
        |> List.take 4


topTrackViews : List Track -> List (Html msg)
topTrackViews tracks =
    let
        trackView track =
            let
                cover =
                    Image.filterByWidth 64 track.album.images
            in
            div [ class "Track Flex centeredVertical" ]
                [ img [ class "Track__cover", src cover.url ] []
                , div [ class "Track__name Flex__full" ] [ text track.name ]
                , div [ class "Track__duration" ] [ text <| Track.durationFormat track.duration ]
                ]
    in
    List.map trackView tracks
        |> List.take 5


albumsListView : List AlbumSimplified -> String -> Html msg
albumsListView albums listName =
    let
        viewAlbum album =
            let
                cover =
                    Image.filterByWidth 600 album.images
            in
            div [ class "Album" ]
                [ a [ class "Album__link", href "#" ]
                    [ img [ class "Album__cover", src cover.url ] []
                    , button [ class "Album__play" ] [ i [ class "icon-play" ] [] ]
                    , button [ class "Album__add" ] [ i [ class "icon-add" ] [] ]
                    ]
                , div [ class "Album__name" ] [ text album.name ]
                , div [ class "Album__release" ] [ text album.releaseDate ]
                ]
    in
    if List.length albums > 0 then
        div []
            [ h2 [ class "Heading second" ] [ text listName ]
            , List.map viewAlbum albums
                |> div [ class "Artist__releaseList AlbumList" ]
            ]

    else
        text ""


view : Model -> ( String, List (Html Msg) )
view ({ artist, followed } as model) =
    let
        _ =
            Debug.log "artist" followed
    in
    ( Maybe.withDefault "Artists" (Maybe.map .name artist)
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Artist__body HelperScrollArea__target" ]
                    [ div [ class "Flex spaceBetween centeredVertical" ]
                        [ h1 [ class "Artist__name Heading first" ] [ Maybe.map .name model.artist |> Maybe.withDefault "" |> text ]
                        , if followed /= [ True ] then
                            button [ class "Button big" ] [ text "Follow" ]

                          else
                            button [ class "Button big primary" ] [ text "Followed" ]
                        ]
                    , div [ class "Artist__links External" ]
                        [ a [ class "External__item", href "#" ] [ i [ class "External__icon icon-wikipedia" ] [], text "Wikipedia" ]
                        , a [ class "External__item", href "#" ] [ i [ class "External__icon icon-sputnik" ] [], text "Sputnik" ]
                        , a [ class "External__item", href "#" ] [ i [ class "External__icon icon-discogs" ] [], text "Discogs" ]
                        , a [ class "External__item", href "#" ] [ i [ class "External__icon icon-magnifying-glass" ] [], text "Google" ]
                        ]
                    , div [ class "Artist__top" ]
                        [ topTrackViews model.tracks
                            |> (::) (h2 [ class "Heading second" ] [ text "Top tracks" ])
                            |> div []
                        , relatedArtistsView model.relatedArtists
                            |> (::) (h2 [ class "Heading second" ] [ text "Similar artists" ])
                            |> div [ class "ArtistSimilar" ]
                        ]
                    , albumsListView (List.filter (\a -> a.type_ == Album.Album) model.albums) "Albums"
                    , albumsListView (List.filter (\a -> a.type_ == Album.Compilation) model.albums) "EPs"
                    , albumsListView (List.filter (\a -> a.type_ == Album.Single) model.albums) "Singles"
                    ]
                ]
            , div [ class "Artist__videos HelperScrollArea" ]
                [ div [ class "Video HelperScrollArea__target" ]
                    [ h2 [ class "Heading second" ] [ text "Last videos" ]
                    , div [ class "Video__item" ]
                        [ iframe [ class "Video__embed", src "https://www.youtube.com/embed/MreXYqelGPM", width 230, height 130 ] []
                        , div [ class "Video__name" ] [ text "Pain Of Salvation - Meaningless (official video)" ]
                        , a [ href "#", class "Video__channel Link" ] [ text "painofsalvationVEVO" ]
                        ]
                    , div [ class "Video__item" ]
                        [ iframe [ class "Video__embed", src "https://www.youtube.com/embed/MreXYqelGPM", width 230, height 130 ] []
                        , div [ class "Video__name" ] [ text "Pain Of Salvation - Meaningless (official video)" ]
                        , a [ href "#", class "Video__channel Link" ] [ text "painofsalvationVEVO" ]
                        ]
                    , div [ class "Video__item" ]
                        [ iframe [ class "Video__embed", src "https://www.youtube.com/embed/MreXYqelGPM", width 230, height 130 ] []
                        , div [ class "Video__name" ] [ text "Pain Of Salvation - Meaningless (official video)" ]
                        , a [ href "#", class "Video__channel Link" ] [ text "painofsalvationVEVO" ]
                        ]
                    , div [ class "Video__item" ]
                        [ iframe [ class "Video__embed", src "https://www.youtube.com/embed/MreXYqelGPM", width 230, height 130 ] []
                        , div [ class "Video__name" ] [ text "Pain Of Salvation - Meaningless (official video)" ]
                        , a [ href "#", class "Video__channel Link" ] [ text "painofsalvationVEVO" ]
                        ]
                    , div [ class "Video__item" ]
                        [ iframe [ class "Video__embed", src "https://www.youtube.com/embed/MreXYqelGPM", width 230, height 130 ] []
                        , div [ class "Video__name" ] [ text "Pain Of Salvation - Meaningless (official video)" ]
                        , a [ href "#", class "Video__channel Link" ] [ text "painofsalvationVEVO" ]
                        ]
                    ]
                ]
            ]
      ]
    )



-- <iframe class="PageArtistVideo__video" allowfullscreen="" frameborder="0" width="250" height="140" src="https://www.youtube.com/embed/MreXYqelGPM"></iframe>
