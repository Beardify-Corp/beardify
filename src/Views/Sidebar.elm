module Views.Sidebar exposing (Model, Msg, defaultModel, init, update, view)

import Data.Id exposing (idToString)
import Data.Paging exposing (Paging)
import Data.Playlist.PlaylistSimplified exposing (PlaylistSimplified)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.Playlist
import Route
import Task
import Url exposing (Url)


type alias Model =
    {}


type Msg
    = Fetched (Result ( Session, Http.Error ) (Paging PlaylistSimplified))


defaultModel : Model
defaultModel =
    {}


init : Session -> ( Model, Cmd Msg )
init session =
    ( defaultModel
    , Task.attempt Fetched (Request.Playlist.getAll session 0)
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ playlists } as session) msg model =
    case msg of
        Fetched (Ok newModel) ->
            if newModel.total > newModel.offset then
                ( model
                , { session
                    | playlists =
                        { playlists
                            | items = List.append playlists.items newModel.items
                            , offset = newModel.offset
                        }
                  }
                , Task.attempt Fetched (Request.Playlist.getAll session (newModel.offset + 50))
                )

            else
                ( model, session, Cmd.none )

        Fetched (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


type PlaylistType
    = List
    | Collection


collectionView : Url -> PlaylistSimplified -> Html msg
collectionView currentUrl item =
    li
        [ class "List__item"
        , classList [ ( "active", Maybe.withDefault "" currentUrl.fragment == "/collection/" ++ idToString item.id ) ]
        ]
        [ i [ class "List__icon icon-collection" ] []
        , a [ class "List__link", Route.href (Route.Collection item.id) ] [ text <| String.replace "#Collection " "" item.name ]
        ]


playlistView : Url -> PlaylistSimplified -> Html msg
playlistView currentUrl item =
    li
        [ class "List__item"
        , classList [ ( "active", Maybe.withDefault "" currentUrl.fragment == "/playlist/" ++ idToString item.id ) ]
        ]
        [ i [ class "List__icon icon-playlist" ] []
        , a [ class "List__link", Route.href (Route.Playlist item.id) ] [ text item.name ]
        ]


playlistItem : Url -> Paging PlaylistSimplified -> PlaylistType -> Html msg
playlistItem currentUrl playlistList playlistType =
    if playlistType == Collection then
        div [ class "Sidebar__item" ]
            [ h2 [ class "Sidebar__title Heading" ] [ text "Collections" ]
            , div [ class "Sidebar__collections HelperScrollArea" ]
                [ ul [ class "HelperScrollArea__target List unstyled" ]
                    (playlistList.items
                        |> List.filter (\playlist -> String.startsWith "#Collection" playlist.name)
                        |> List.map (collectionView currentUrl)
                    )
                ]
            ]

    else
        div [ class "Sidebar__item" ]
            [ h2 [ class "Sidebar__title Heading" ] [ text "Playlists" ]
            , div [ class "Sidebar__collections HelperScrollArea" ]
                [ ul [ class "HelperScrollArea__target List unstyled" ]
                    (playlistList.items
                        |> List.filter (\playlist -> not (String.startsWith "#Collection" playlist.name))
                        |> List.map (playlistView currentUrl)
                    )
                ]
            ]


view : Session -> Html Msg
view { playlists, currentUrl } =
    div [ class "Sidebar" ]
        [ playlistItem currentUrl playlists Collection
        , playlistItem currentUrl playlists List
        ]
