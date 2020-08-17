module Views.Sidebar exposing (Model, Msg, defaultModel, init, update, view)

import Data.Id exposing (idToString)
import Data.Paging exposing (Paging)
import Data.Playlist.Playlist exposing (Playlist)
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
    { playlists : Paging PlaylistSimplified
    }


type Msg
    = Fetched (Result ( Session, Http.Error ) Model)


defaultModel : Model
defaultModel =
    { playlists =
        { items = []
        , next = ""
        , total = 0
        , offset = 0
        , limit = 0
        }
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( defaultModel
    , Task.map Model
        (Request.Playlist.getAll session 0)
        |> Task.attempt Fetched
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ playlists } as model) =
    case msg of
        Fetched (Ok newModel) ->
            if newModel.playlists.total > newModel.playlists.offset then
                ( { playlists =
                        { playlists
                            | items = List.append playlists.items newModel.playlists.items
                            , offset = newModel.playlists.offset
                        }
                  }
                , session
                , Task.map Model
                    (Request.Playlist.getAll session (newModel.playlists.offset + 50))
                    |> Task.attempt Fetched
                )

            else
                ( model, session, Cmd.none )

        Fetched (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


type PlaylistType
    = List
    | Collection


playlistItem : Url -> Paging PlaylistSimplified -> PlaylistType -> Html msg
playlistItem currentUrl playlistList playlistType =
    if playlistType == Collection then
        div [ class "Sidebar__item" ]
            [ h2 [ class "Sidebar__title Heading" ] [ text "Collection" ]
            , div [ class "Sidebar__collections HelperScrollArea" ]
                [ ul [ class "HelperScrollArea__target List unstyled" ]
                    (playlistList.items
                        |> List.filter (\playlist -> String.startsWith "#Collection" playlist.name)
                        |> List.map
                            (\item ->
                                li
                                    [ class "List__item"
                                    , classList [ ( "active", Maybe.withDefault "" currentUrl.fragment == "/collection/" ++ idToString item.id ) ]
                                    ]
                                    [ i [ class "List__icon icon-collection" ] []
                                    , a [ class "List__link", Route.href (Route.Collection item.id) ] [ text <| String.replace "#Collection " "" item.name ]
                                    ]
                            )
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
                        |> List.map
                            (\item ->
                                li
                                    [ class "List__item"
                                    , classList [ ( "active", Maybe.withDefault "" currentUrl.fragment == "/playlist/" ++ idToString item.id ) ]
                                    ]
                                    [ i [ class "List__icon icon-playlist" ] []
                                    , a [ class "List__link", Route.href (Route.Playlist item.id) ] [ text item.name ]
                                    ]
                            )
                    )
                ]
            ]


view : Model -> Url -> Html Msg
view { playlists } currentUrl =
    div [ class "Sidebar" ]
        [ playlistItem currentUrl playlists Collection
        , playlistItem currentUrl playlists List
        ]
