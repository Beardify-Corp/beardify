module Views.Sidebar exposing (Model, Msg, defaultModel, init, update, view)

import Data.Playlist exposing (Playlist, PlaylistList)
import Data.Session exposing (Session)
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode exposing (nullable)
import Request.Sidebar
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


view : Model -> Html Msg
view { playlists } =
    div [ class "Sidebar" ]
        [ div [ class "Sidebar__item" ]
            [ h2 [ class "Sidebar__title Heading" ] [ text "Collections" ]
            , div [] [ text <| Debug.toString (List.length playlists.items) ]
            , div [ class "Sidebar__collections HelperScrollArea" ]
                [ ul [ class "HelperScrollArea__target List unstyled" ]
                    [ li [ class "List__item" ]
                        [ span []
                            [ i [ class "List__icon icon-collection" ] []
                            , text "Abricot"
                            ]
                        ]
                    , li [ class "List__item" ]
                        [ i [ class "List__icon icon-collection" ] []
                        , i [ class "List__collaborativeIcon icon-collaborative" ] []
                        , text "Ananas"
                        ]
                    , li [ class "List__item" ]
                        [ i [ class "List__icon icon-collection" ] []
                        , i [ class "List__collaborativeIcon icon-collaborative" ] []
                        , text "Citron"
                        ]
                    , li [ class "List__item" ]
                        [ i [ class "List__icon icon-collection" ] []
                        , text "Fruit de la passion"
                        ]
                    , li [ class "List__item active" ] [ i [ class "List__icon icon-collection" ] [], text "Pamplemousse" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Orange sanguine" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Groseille à maquereau" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Grenade" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Mûre" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Poire" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Pomme" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Reine-claude" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Mirabelle" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Groseille" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Clémentine" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Banane" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Châtaigne" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Kiwi" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Myrtille" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-collection" ] [], text "Pastèque" ]
                    ]
                ]
            ]
        , div [ class "Sidebar__item" ]
            [ h2 [ class "Sidebar__title Heading" ] [ text "Playlists" ]
            , div [ class "Sidebar__playlists HelperScrollArea" ]
                [ ul [ class "HelperScrollArea__target List unstyled" ]
                    [ li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Artichaut" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Champignon" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Céleri branche" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Topinambour" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Endive" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Oignon" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Poireau" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Carotte" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Betterave rouge" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Courgette" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Pâtisson" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Poivron" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Navet" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Chou Romanesco" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Brocoli" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Fenouil" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Epinard" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Potiron" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Salsifis" ]
                    , li [ class "List__item" ] [ i [ class "List__icon icon-music" ] [], text "Pomme de terre" ]
                    ]
                ]
            ]
        ]
