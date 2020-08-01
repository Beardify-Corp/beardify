module Page.Artist exposing (Model, Msg(..), init, update, view)

import Data.Album as Album exposing (AlbumSimplified)
import Data.Artist as Artist exposing (Artist)
import Data.Image as Image
import Data.Player as Player exposing (..)
import Data.Session exposing (Session)
import Data.Track as Track exposing (Track)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra as HE
import Http
import List.Extra as LE
import Request.Api as Api
import Request.Artist
import Request.Player
import Route
import Task
import Task.Extra as TE


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


init : Artist.Id -> Session -> ( Model, Session, Cmd Msg )
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


followCmd : Session -> String -> String -> Cmd Msg
followCmd session method id =
    Http.request
        { method = method
        , headers = [ Api.authHeader session ]
        , url = Api.url ++ "me/following?type=artist&ids=" ++ id
        , body = Http.emptyBody
        , expect = Http.expectWhatever ResultFollow
        , timeout = Nothing
        , tracker = Nothing
        }


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        Follow artistId ->
            ( model, session, followCmd session "PUT" artistId )

        UnFollow artistId ->
            ( model, session, followCmd session "DELETE" artistId )

        Fetched (Ok newModel) ->
            ( newModel, session, Cmd.none )

        Fetched (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )

        ResultFollow result ->
            let
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


topTrackViews : PlayerContext -> List Track -> List (Html Msg)
topTrackViews context tracks =
    let
        listTracksUri trackUri =
            tracks
                |> LE.dropWhile (\track -> track.uri /= trackUri)
                |> List.map .uri

        isTrackPlaying =
            Player.getCurrentTrackUri context

        trackView track =
            let
                cover =
                    Image.filterByWidth 64 track.album.images
            in
            div
                [ class "Track Flex centeredVertical"
                , classList [ ( "active", isTrackPlaying == track.uri ) ]
                , onClick <| PlayTracks (listTracksUri track.uri)
                ]
                [ img [ class "Track__cover", src cover.url ] []
                , div [ class "Track__name Flex__full" ] [ text track.name ]
                , div [ class "Track__duration" ] [ text <| Track.durationFormat track.duration ]
                ]
    in
    List.map trackView tracks
        |> List.take 5


albumsListView : PlayerContext -> List AlbumSimplified -> String -> Html Msg
albumsListView context albums listName =
    let
        viewAlbum album =
            let
                cover =
                    Image.filterByWidth 600 album.images

                isCurrentlyPlaying =
                    album.uri == Player.getCurrentAlbumUri context
            in
            div
                [ class "Album" ]
                [ div [ class "Album__link" ]
                    [ a [ href "#" ] [ img [ attribute "loading" "lazy", class "Album__cover", src cover.url ] [] ]
                    , button [ onClick <| PlayAlbum album.uri, class "Album__play" ] [ i [ class "icon-play" ] [] ]
                    , button [ class "Album__add" ] [ i [ class "icon-add" ] [] ]
                    ]
                , div [ class "Album__name" ] [ text album.name ]
                , div [ class "Album__release" ] [ text album.releaseDate ]
                , HE.viewIf isCurrentlyPlaying (i [ class "Album__playing icon-sound" ] [])
                ]
    in
    HE.viewIf (List.length albums > 0)
        (div []
            [ h2 [ class "Heading second" ] [ text listName ]
            , List.map viewAlbum albums
                |> div [ class "Artist__releaseList AlbumList" ]
            ]
        )


view : PlayerContext -> Model -> ( String, List (Html Msg) )
view context ({ artist, followed } as model) =
    let
        artistId =
            case Maybe.map .id artist of
                Just id ->
                    Artist.idToString id

                Nothing ->
                    ""

        artistCover =
            Maybe.withDefault [] (Maybe.map .images artist)
                |> List.take 1
                |> List.map (\e -> e.url)
                |> String.concat

        artistName =
            Maybe.withDefault "Artists" (Maybe.map .name artist)
    in
    ( artistName
    , [ div [ class "Flex fullHeight" ]
            [ div [ class "Flex__full HelperScrollArea" ]
                [ div [ class "Artist__body HelperScrollArea__target" ]
                    [ div [ class "Flex spaceBetween centeredVertical" ]
                        [ h1 [ class "Artist__name Heading first" ] [ text artistName ]
                        , div [ class "ArtistCover" ] [ img [ class "ArtistCover__img", src artistCover ] [] ]
                        , if followed /= [ True ] then
                            button [ onClick <| Follow artistId, class "Button big" ] [ text "Follow" ]

                          else
                            button [ onClick <| UnFollow artistId, class "Button big primary" ] [ text "Followed" ]
                        ]
                    , div [ class "Artist__links External" ]
                        [ a
                            [ class "External__item"
                            , target "_blank"
                            , href <| "https://fr.wikipedia.org/wiki/" ++ artistName
                            ]
                            [ i [ class "External__icon icon-wikipedia" ] [], text "Wikipedia" ]
                        , a
                            [ class "External__item"
                            , target "_blank"
                            , href <| "https://www.sputnikmusic.com/search_results.php?genreid=0&search_in=Bands&search_text=" ++ artistName ++ "&amp;x=0&amp;y=0"
                            ]
                            [ i [ class "External__icon icon-sputnik" ] [], text "Sputnik" ]
                        , a
                            [ class "External__item"
                            , target "_blank"
                            , href <| "https://www.discogs.com/fr/search/?q=" ++ artistName ++ "&amp;strict=true"
                            ]
                            [ i [ class "External__icon icon-discogs" ] [], text "Discogs" ]
                        , a
                            [ class "External__item"
                            , target "_blank"
                            , href <| "https://www.google.com/search?q=" ++ artistName
                            ]
                            [ i [ class "External__icon icon-magnifying-glass" ] [], text "Google" ]
                        ]
                    , div [ class "Artist__top" ]
                        [ topTrackViews context model.tracks
                            |> (::) (h2 [ class "Heading second" ] [ text "Top tracks" ])
                            |> div []
                        , relatedArtistsView model.relatedArtists
                            |> (::) (h2 [ class "Heading second" ] [ text "Similar artists" ])
                            |> div [ class "ArtistSimilar" ]
                        ]
                    , albumsListView context (List.filter (\a -> a.type_ == Album.Album) model.albums) "Albums"
                    , albumsListView context (List.filter (\a -> a.type_ == Album.Single) model.singles) "Singles / EPs"
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
