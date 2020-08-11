module Views.Sidebar exposing (Model, Msg, defaultModel, init, update, view)

import Data.Playlist exposing (Playlist, PlaylistList)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.Sidebar
import Route
import Task


type alias Model =
    { playlists : PlaylistList
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
        (Request.Sidebar.get session 0)
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
                    (Request.Sidebar.get session (newModel.playlists.offset + 50))
                    |> Task.attempt Fetched
                )

            else
                ( model, session, Cmd.none )

        Fetched (Err ( newSession, _ )) ->
            ( model, newSession, Cmd.none )


type PlaylistType
    = List
    | Collection


playlistItem : PlaylistList -> PlaylistType -> Html msg
playlistItem playlistList playlistType =
    if playlistType == Collection then
        div [ class "Sidebar__item" ]
            [ h2 [ class "Sidebar__title Heading" ] [ text "Collection" ]
            , div [ class "Sidebar__collections HelperScrollArea" ]
                [ ul [ class "HelperScrollArea__target List unstyled" ]
                    (playlistList.items
                        |> List.filter (\playlist -> String.startsWith "#Collection" playlist.name)
                        |> List.map
                            (\item ->
                                li [ class "List__item" ]
                                    [ i [ class "List__icon icon-collection" ] []
                                    , a [ class "List__link", Route.href (Route.Playlist item.id) ] [ text <| String.replace "#Collection " "" item.name ]
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
                                li [ class "List__item" ]
                                    [ i [ class "List__icon icon-playlist" ] []
                                    , a [ class "List__link", Route.href (Route.Playlist item.id) ] [ text item.name ]
                                    ]
                            )
                    )
                ]
            ]


view : Model -> Html Msg
view { playlists } =
    div [ class "Sidebar" ]
        [ playlistItem playlists Collection
        , playlistItem playlists List
        ]
