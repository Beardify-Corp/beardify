module Page.Artist exposing (Model, Msg(..), init, update, view)

import Data.Album.Album exposing (Album)
import Data.Album.AlbumSimplified exposing (AlbumSimplified)
import Data.Album.AlbumType
import Data.Artist.Artist exposing (Artist)
import Data.Id exposing (Id, idToString)
import Data.Image as Image
import Data.Player exposing (..)
import Data.Session exposing (Session)
import Data.Track.Track exposing (Track)
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
import Views.Cover as Cover
import Views.Track


type alias Model =
    { artist : Maybe Artist
    , albums : List AlbumSimplified
    , singles : List AlbumSimplified
    , tracks : List Track
    , relatedArtists : List Artist
    , followed : List Bool
    }


type Msg
    = Fetched (Result ( Session, Http.Error ) Model)
    | Follow String
    | UnFollow String
    | ResultFollow (Result Http.Error ())
    | PlayAlbum String
    | PlayTracks (List String)
    | Played (Result ( Session, Http.Error ) ())
    | GetAlbum Id
    | AddToPocket (Result ( Session, Http.Error ) Album)


init : Id -> Session -> ( Model, Session, Cmd Msg )
init id session =
    ( { artist = Nothing
      , albums = []
      , singles = []
      , tracks = []
      , relatedArtists = []
      , followed = []
      }
    , session
    , TE.map6 (Model << Just)
        (Request.Artist.get session id)
        (Request.Artist.getItems "album" session id)
        (Request.Artist.getItems "single" session id)
        (Request.Artist.getTopTrack session id)
        (Request.Artist.getRelatedArtists session id)
        (Request.Artist.getFollowedArtist session id)
        |> Task.attempt Fetched
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ pocket } as session) msg model =
    case msg of
        Follow artistId ->
            ( model, session, Request.Artist.follow session "PUT" artistId ResultFollow )

        UnFollow artistId ->
            ( model, session, Request.Artist.follow session "DELETE" artistId ResultFollow )

        Fetched (Ok newModel) ->
            ( newModel, session, Cmd.none )

        Fetched (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )

        ResultFollow result ->
            let
                revertedFollowedStatus : List Bool
                revertedFollowedStatus =
                    if model.followed == [ True ] then
                        [ False ]

                    else
                        [ True ]
            in
            case result of
                Ok _ ->
                    ( { model | followed = revertedFollowedStatus }, session, Cmd.none )

                Err _ ->
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
            ( model, { session | pocket = { pocket | albums = List.append firstTrackOfAlbum pocket.albums } }, Cmd.none )

        AddToPocket (Err _) ->
            ( model, session, Cmd.none )


relatedArtistsView : List Artist -> Html msg
relatedArtistsView artists =
    let
        relatedArtistView : Artist -> Html msg
        relatedArtistView artist =
            let
                cover : Image.Image
                cover =
                    Image.filterByWidth Image.Medium artist.images
            in
            a [ class "ArtistSimilar__item", Route.href (Route.Artist artist.id) ]
                [ img [ class "ArtistSimilar__avatar", src cover.url ] []
                , span [ class "ArtistSimilar__name" ] [ text artist.name ]
                ]
    in
    div []
        [ h2 [ class "Heading second" ] [ text "Related artists" ]
        , artists
            |> List.map relatedArtistView
            |> List.take 8
            |> div [ class "ArtistSimilar" ]
        ]


topTrackViews : PlayerContext -> List Track -> Html Msg
topTrackViews context tracks =
    div []
        [ h2 [ class "Heading second" ] [ text "Top tracks" ]
        , Views.Track.view { playTracks = PlayTracks } context tracks
            |> List.take 5
            |> div []
        ]


albumsListView : PlayerContext -> List AlbumSimplified -> String -> Html Msg
albumsListView context albums listName =
    let
        hasAlbums : Bool
        hasAlbums =
            List.length albums > 0

        albumList : Html Msg
        albumList =
            div []
                [ h2 [ class "Heading second" ] [ text listName ]
                , List.map (Views.Album.view { playAlbum = PlayAlbum, addToPocket = GetAlbum } context False) albums
                    |> div [ class "Artist__releaseList AlbumList" ]
                ]
    in
    HE.viewIf hasAlbums albumList


externalLink : String -> String -> String -> Html msg
externalLink url label iconLabel =
    a
        [ class "External__item"
        , target "_blank"
        , href <| url
        ]
        [ i [ classList [ ( "External__icon", True ), ( iconLabel, True ) ] ] [], text label ]


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view context ({ artist, followed } as model) =
    let
        artistId : String
        artistId =
            case Maybe.map .id artist of
                Just id ->
                    idToString id

                Nothing ->
                    ""

        artistCover : String
        artistCover =
            Maybe.withDefault [] (Maybe.map .images artist)
                |> List.take 1
                |> List.map (\e -> e.url)
                |> String.concat

        artistName : String
        artistName =
            Maybe.withDefault "" (Maybe.map .name artist)

        followedBtn : List Bool -> Html Msg
        followedBtn followedStatus =
            if followedStatus /= [ True ] then
                button [ onClick <| Follow artistId, class "Button big" ] [ text "Follow" ]

            else
                button [ onClick <| UnFollow artistId, class "Button big primary" ] [ text "Followed" ]

        externalLinkList : List (Html msg)
        externalLinkList =
            [ externalLink ("https://fr.wikipedia.org/wiki/" ++ artistName) "Wikipedia" "icon-wikipedia"
            , externalLink ("https://www.sputnikmusic.com/search_results.php?genreid=0&search_in=Bands&search_text=" ++ artistName ++ "&amp;x=0&amp;y=0") "Sputnik" "icon-sputnik"
            , externalLink ("https://www.discogs.com/fr/search/?q=" ++ artistName ++ "&amp;strict=true") "Discogs" "icon-discogs"
            , externalLink ("https://www.google.com/search?q=" ++ artistName) "Google" "icon-magnifying-glass"
            ]
    in
    ( artistName
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Artist__body HelperScrollArea__target" ]
                    [ div [ class "Flex spaceBetween centeredVertical" ]
                        [ h1 [ class "Artist__name Heading first" ] [ text artistName ]
                        , Cover.view artistCover Cover.Normal
                        , followedBtn followed
                        ]
                    , externalLinkList |> div [ class "Artist__links External" ]
                    , div [ class "Artist__top" ]
                        [ topTrackViews context model.tracks
                        , relatedArtistsView model.relatedArtists
                        ]
                    , albumsListView context (List.filter (\a -> a.type_ == Data.Album.AlbumType.AlbumType) model.albums) "Albums"
                    , albumsListView context (List.filter (\a -> a.type_ == Data.Album.AlbumType.Single) model.singles) "Singles / EPs"
                    ]
                ]
            , div [ class "Artist__videos HelperScrollArea" ]
                [ div [ class "Video HelperScrollArea__target" ]
                    [ h2 [ class "Heading second" ] [ text "Last videos" ]

                    -- , div [ class "Video__item" ]
                    --     [ iframe [ class "Video__embed", src "https://www.youtube.com/embed/MreXYqelGPM", width 230, height 130 ] []
                    --     , div [ class "Video__name" ] [ text "Pain Of Salvation - Meaningless (official video)" ]
                    --     , a [ href "#", class "Video__channel Link" ] [ text "painofsalvationVEVO" ]
                    --     ]
                    ]
                ]
            ]
      ]
    )
