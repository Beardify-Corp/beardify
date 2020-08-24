module Main exposing (main)

import Browser exposing (Document)
import Browser.Events exposing (onKeyDown)
import Browser.Navigation as Nav
import Data.Authorization as Authorization
import Data.Paging exposing (defaultPaging)
import Data.Player as PlayerData exposing (Player, PlayerContext)
import Data.Pocket exposing (defaultPocket)
import Data.Session as Session exposing (Notif, Session)
import Data.User exposing (User)
import Html exposing (..)
import Http
import Json.Decode as Decode exposing (map)
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)
import Page.Album as Album
import Page.Artist as Artist
import Page.Collection as Collection
import Page.Home as Home
import Page.Login as Login
import Page.Page as Page
import Page.Playlist as Playlist
import Ports
import Request.Player
import Request.User as RequestUser
import Route exposing (Route)
import Task
import Time exposing (Posix)
import Url exposing (Url)
import Views.Player.Device as Device
import Views.Player.Player as Player
import Views.Pocket as Pocket
import Views.Sidebar as Sidebar
import Views.Topbar.Nav as Topbar
import Views.Topbar.Search as Search


type alias Flags =
    { clientUrl : String
    , rawStore : String
    , clientId : String
    , randomBytes : String
    , authUrl : String
    }


type Page
    = ArtistPage Artist.Model
    | AlbumPage Album.Model
    | PlaylistPage Playlist.Model
    | CollectionPage Collection.Model
    | Blank
    | HomePage Home.Model
    | LoginPage Login.Model
    | NotFound


type alias Model =
    { page : Page
    , session : Session
    , player : PlayerContext
    , devices : Device.Model
    , sidebar : Sidebar.Model
    , topbar : Topbar.Model
    , search : Search.Model
    , pocket : Pocket.Model
    }


type Msg
    = ArtistMsg Artist.Msg
    | AlbumMsg Album.Msg
    | PlaylistMsg Playlist.Msg
    | CollectionMsg Collection.Msg
    | ClearNotification Notif
    | DeviceMsg Device.Msg
    | HomeMsg Home.Msg
    | LoginMsg Login.Msg
    | SidebarMsg Sidebar.Msg
    | PocketMsg Pocket.Msg
    | TopbarMsg Topbar.Msg
    | SearchMsg Search.Msg
    | PlayerMsg Player.Msg
    | PlayerControls Player.Controls
    | RefreshNotifications Posix
    | StoreChanged String
    | UserFetched (Result ( Session, Http.Error ) ( User, Maybe Url ))
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | HandleKeyboardEvent KeyboardEvent


initComponent : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initComponent ( model, msgCmd ) =
    let
        ( playerModel, playerCmd ) =
            Player.init model.session

        ( deviceModel, deviceCmd ) =
            Device.init model.session

        ( sidebarModel, sidebarCmd ) =
            Sidebar.init model.session

        ( topbarModel, topbarCmd ) =
            Topbar.init model.session

        ( searchModel, searchCmd ) =
            Search.init model.session
    in
    ( { model
        | player = playerModel
        , devices = deviceModel
        , sidebar = sidebarModel
        , topbar = topbarModel
        , search = searchModel
      }
    , Cmd.batch
        [ msgCmd
        , Cmd.map PlayerMsg playerCmd
        , Cmd.map DeviceMsg deviceCmd
        , Cmd.map SidebarMsg sidebarCmd
        , Cmd.map TopbarMsg topbarCmd
        , Cmd.map SearchMsg searchCmd
        ]
    )


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        toPage page subInit subMsg =
            let
                ( subModel, newSession, subCmds ) =
                    subInit model.session

                storeCmd =
                    if model.session.store /= newSession.store then
                        newSession.store |> Session.serializeStore |> Ports.saveStore

                    else
                        Cmd.none
            in
            ( { model
                | session = newSession
                , page = page subModel
              }
            , Cmd.batch
                [ Cmd.map subMsg subCmds
                , storeCmd
                ]
            )
    in
    case ( model.session.store.auth /= Nothing, maybeRoute ) of
        ( True, Nothing ) ->
            ( { model | page = NotFound }
            , Cmd.none
            )

        ( True, Just Route.Home ) ->
            toPage HomePage Home.init HomeMsg

        ( True, Just (Route.Artist id) ) ->
            toPage ArtistPage (Artist.init id) ArtistMsg

        ( True, Just (Route.Album id) ) ->
            toPage AlbumPage (Album.init id) AlbumMsg

        ( True, Just (Route.Playlist id) ) ->
            toPage PlaylistPage (Playlist.init id) PlaylistMsg

        ( True, Just (Route.Collection id) ) ->
            toPage CollectionPage (Collection.init id) CollectionMsg

        ( True, Just Route.Login ) ->
            toPage LoginPage Login.init LoginMsg

        ( False, Nothing ) ->
            ( { model | page = NotFound }
            , Cmd.none
            )

        ( False, _ ) ->
            toPage LoginPage Login.init LoginMsg


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        session =
            { clientUrl = flags.clientUrl
            , navKey = navKey
            , clientId = flags.clientId
            , authUrl = flags.authUrl
            , randomBytes = flags.randomBytes
            , notifications = []
            , user = Nothing
            , store = Session.deserializeStore flags.rawStore
            , currentUrl = url
            , pocket = defaultPocket
            , playlists = defaultPaging
            }

        model =
            { page = Blank
            , session = session
            , devices = Device.defaultModel
            , player = PlayerData.defaultPlayerContext
            , sidebar = Sidebar.defaultModel
            , topbar = Topbar.defaultModel
            , search = Search.defaultModel
            , pocket = Pocket.defaultModel
            }
    in
    case ( url.fragment, url.query ) of
        ( Just fragment, Nothing ) ->
            case Authorization.parseAuth fragment of
                Authorization.Empty ->
                    ( model
                    , Task.attempt UserFetched (RequestUser.get session (Just url))
                    )

                Authorization.AuthError _ ->
                    --TODO: How do we diplay us this error to user?
                    ( model, Route.pushUrl session.navKey Route.Login )

                Authorization.AuthSuccess auth ->
                    if auth.state /= session.store.state then
                        -- TODO: auth state is corrupted, we need display something to the user
                        ( model, Route.pushUrl session.navKey Route.Login )

                    else
                        let
                            newSession : Session
                            newSession =
                                Session.updateAuth (Just auth) session
                        in
                        ( { model | session = newSession }
                        , Cmd.batch
                            [ newSession.store
                                |> Session.serializeStore
                                |> Ports.saveStore
                            , RequestUser.get newSession Nothing
                                |> Task.attempt UserFetched
                            ]
                        )

        -- Api spotify error use query string rather than fragment
        ( Nothing, Just query ) ->
            case Authorization.parseAuth query of
                Authorization.AuthError _ ->
                    setRoute (Route.fromUrl url) model

                _ ->
                    setRoute (Route.fromUrl url) model

        ( _, _ ) ->
            setRoute (Route.fromUrl url) model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ page, session, search } as model) =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newSession, newCmd ) =
                    subUpdate session subMsg subModel

                storeCmd : Cmd msg
                storeCmd =
                    if session.store /= newSession.store then
                        newSession.store |> Session.serializeStore |> Ports.saveStore

                    else
                        Cmd.none
            in
            ( { model | session = newSession, page = toModel newModel }
            , Cmd.map toMsg
                (Cmd.batch
                    [ newCmd
                    , storeCmd
                    , if newSession.store.auth == Nothing then
                        Route.pushUrl session.navKey Route.Login

                      else
                        Cmd.none
                    ]
                )
            )
    in
    case ( msg, page ) of
        -- Pages
        ( ArtistMsg artistMsg, ArtistPage artistModel ) ->
            toPage ArtistPage ArtistMsg Artist.update artistMsg artistModel

        ( AlbumMsg albumMsg, AlbumPage albumModel ) ->
            toPage AlbumPage AlbumMsg Album.update albumMsg albumModel

        ( PlaylistMsg playlistMsg, PlaylistPage playlistModel ) ->
            toPage PlaylistPage PlaylistMsg Playlist.update playlistMsg playlistModel

        ( CollectionMsg collectionMsg, CollectionPage collectionModel ) ->
            toPage CollectionPage CollectionMsg Collection.update collectionMsg collectionModel

        ( HomeMsg homeMsg, HomePage homeModel ) ->
            toPage HomePage HomeMsg Home.update homeMsg homeModel

        ( LoginMsg loginMsg, LoginPage loginModel ) ->
            toPage LoginPage LoginMsg Login.update loginMsg loginModel

        -- Components
        ( DeviceMsg deviceMsg, _ ) ->
            let
                ( deviceModel, newSession, deviceCmd ) =
                    Device.update session deviceMsg model.devices

                updateContext context =
                    { context | refreshTick = 1000 }
            in
            case deviceMsg of
                Device.Activated (Ok _) ->
                    ( { model
                        | session = newSession
                        , player = updateContext model.player
                      }
                    , Cmd.batch
                        [ Cmd.map DeviceMsg deviceCmd
                        , if session.store /= newSession.store then
                            newSession.store |> Session.serializeStore |> Ports.saveStore

                          else
                            Cmd.none
                        , if newSession.store.auth == Nothing then
                            Route.pushUrl session.navKey Route.Login

                          else
                            Cmd.none
                        ]
                    )

                _ ->
                    ( { model
                        | session = newSession
                        , devices = deviceModel
                      }
                    , Cmd.batch
                        [ Cmd.map DeviceMsg deviceCmd
                        , if session.store /= newSession.store then
                            newSession.store |> Session.serializeStore |> Ports.saveStore

                          else
                            Cmd.none
                        , if newSession.store.auth == Nothing then
                            Route.pushUrl session.navKey Route.Login

                          else
                            Cmd.none
                        ]
                    )

        ( PlayerMsg playerMsg, _ ) ->
            let
                ( componentModel, newSession, componentCmd ) =
                    Player.update session playerMsg model.player
            in
            ( { model
                | session = newSession
                , player = componentModel
              }
            , Cmd.batch
                [ Cmd.map PlayerMsg componentCmd
                , if session.store /= newSession.store then
                    newSession.store |> Session.serializeStore |> Ports.saveStore

                  else
                    Cmd.none
                , if newSession.store.auth == Nothing then
                    Route.pushUrl session.navKey Route.Login

                  else
                    Cmd.none
                ]
            )

        ( PlayerControls playerControls, _ ) ->
            let
                ( componentModel, newSession, componentCmd ) =
                    Player.updateControls session playerControls model.player
            in
            ( { model
                | session = newSession
                , player = componentModel
              }
            , Cmd.batch
                [ Cmd.map PlayerMsg componentCmd
                , if session.store /= newSession.store then
                    newSession.store |> Session.serializeStore |> Ports.saveStore

                  else
                    Cmd.none
                , if newSession.store.auth == Nothing then
                    Route.pushUrl session.navKey Route.Login

                  else
                    Cmd.none
                ]
            )

        ( SidebarMsg componentMsg, _ ) ->
            let
                ( componentModel, newSession, componentCmd ) =
                    Sidebar.update session componentMsg model.sidebar
            in
            ( { model
                | session = newSession
                , sidebar = componentModel
              }
            , Cmd.batch [ Cmd.map SidebarMsg componentCmd ]
            )

        ( TopbarMsg componentMsg, _ ) ->
            let
                ( componentModel, newSession, componentCmd ) =
                    Topbar.update session componentMsg model.topbar
            in
            ( { model
                | session = newSession
                , topbar = componentModel
              }
            , Cmd.batch [ Cmd.map TopbarMsg componentCmd ]
            )

        ( SearchMsg componentMsg, _ ) ->
            let
                ( componentModel, newSession, componentCmd ) =
                    Search.update session componentMsg model.search
            in
            ( { model
                | session = newSession
                , search = componentModel
              }
            , Cmd.batch [ Cmd.map SearchMsg componentCmd ]
            )

        ( PocketMsg componentMsg, _ ) ->
            let
                ( componentModel, newSession, componentCmd ) =
                    Pocket.update session componentMsg model.pocket
            in
            ( { model
                | session = newSession
                , pocket = componentModel
              }
            , Cmd.batch [ Cmd.map PocketMsg componentCmd ]
            )

        -- Store
        ( StoreChanged json, _ ) ->
            ( { model | session = { session | store = Session.deserializeStore json } }
            , Cmd.none
            )

        -- Routing
        ( UrlRequested urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( { model | session = { session | currentUrl = url } }, Nav.pushUrl session.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            setRoute (Route.fromUrl url) model

        ( UserFetched (Ok ( user, url )), _ ) ->
            case url of
                Just url_ ->
                    setRoute (Route.fromUrl url_)
                        { page = Blank
                        , devices = Device.defaultModel
                        , player = PlayerData.defaultPlayerContext
                        , session = Session.updateUser user model.session
                        , sidebar = Sidebar.defaultModel
                        , topbar = Topbar.defaultModel
                        , search = Search.defaultModel
                        , pocket = Pocket.defaultModel
                        }
                        |> initComponent

                Nothing ->
                    ( { model | session = Session.updateUser user model.session }, Route.pushUrl session.navKey Route.Home )
                        |> initComponent

        ( UserFetched (Err ( newSession, _ )), _ ) ->
            ( { model | session = newSession }, Route.pushUrl session.navKey Route.Login )

        -- Notifications
        ( ClearNotification notif, _ ) ->
            ( { model | session = session |> Session.closeNotification notif }
            , Cmd.none
            )

        ( RefreshNotifications _, _ ) ->
            ( { model
                | session =
                    session
                        |> Session.tickNotifications Session.notificationTick
              }
            , Cmd.none
            )

        ( HandleKeyboardEvent event, _ ) ->
            case ( event.shiftKey, event.key ) of
                ( _, Just "Escape" ) ->
                    ( { model | search = { search | searchQuery = "" } }
                    , Cmd.none
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        -- Misc
        ( _, NotFound ) ->
            ( { model | page = NotFound }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , onKeyDown (Decode.map HandleKeyboardEvent decodeKeyboardEvent)
        , if List.length model.session.notifications > 0 then
            Time.every Session.notificationTick RefreshNotifications

          else
            Sub.none
        , Player.subscriptions model.player
            |> Sub.map PlayerMsg
        , if model.search.searchQuery /= "" then
            Sub.none

          else
            Player.subscriptionsControls
                |> Sub.map PlayerControls
        , case model.page of
            HomePage homeModel ->
                Home.subscriptions homeModel
                    |> Sub.map HomeMsg

            _ ->
                Sub.none
        ]


view : Model -> Document Msg
view { sidebar, page, session, player, devices, search, pocket } =
    let
        frame =
            Page.frame
                { session = session
                , clearNotification = ClearNotification
                , player = player
                , playerMsg = PlayerMsg
                , devices = devices
                , deviceMsg = DeviceMsg
                , sidebar = sidebar
                , sidebarMsg = SidebarMsg
                , topbarMsg = TopbarMsg
                , search = search
                , searchMsg = SearchMsg
                , pocket = pocket
                , pocketMsg = PocketMsg
                }

        mapMsg msg ( title, content ) =
            ( title, content |> List.map (Html.map msg) )
    in
    case page of
        ArtistPage artistModel ->
            Artist.view player artistModel
                |> mapMsg ArtistMsg
                |> frame

        AlbumPage albumModel ->
            Album.view player albumModel
                |> mapMsg AlbumMsg
                |> frame

        PlaylistPage playlistModel ->
            Playlist.view player playlistModel
                |> mapMsg PlaylistMsg
                |> frame

        CollectionPage collectionModel ->
            Collection.view player collectionModel
                |> mapMsg CollectionMsg
                |> frame

        HomePage homeModel ->
            Home.view session homeModel
                |> mapMsg HomeMsg
                |> frame

        LoginPage loginModel ->
            Login.view session loginModel
                |> mapMsg LoginMsg
                |> frame

        NotFound ->
            ( "Not Found", [ Html.text "Not found" ] )
                |> frame

        Blank ->
            ( "", [] )
                |> frame


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }
