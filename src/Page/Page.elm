module Page.Page exposing (Config, frame)

-- import Views.Modal as Modal

import Browser exposing (Document)
import Data.Device exposing (Device)
import Data.Player exposing (PlayerContext)
import Data.Session exposing (Notif, Session)
import Html exposing (..)
import Html.Attributes exposing (class)
import Views.Notif as Notif
import Views.Player.Device as Device
import Views.Player.Player as Player
import Views.Sidebar as Sidebar
import Views.Topbar.Topbar as Topbar


type alias Config msg =
    { session : Session
    , clearNotification : Notif -> msg
    , playerMsg : Player.Msg -> msg
    , deviceMsg : Device.Msg -> msg
    , player : PlayerContext
    , devices : List Device
    , sidebar : Sidebar.Model
    , sidebarMsg : Sidebar.Msg -> msg
    , topbarMsg : Topbar.Msg -> msg
    }


frame : Config msg -> ( String, List (Html msg) ) -> Document msg
frame { topbarMsg, sidebar, sidebarMsg, session, clearNotification, playerMsg, deviceMsg, player, devices } ( title, content ) =
    { title = title ++ " | Beardify "
    , body =
        [ Notif.component
            { clear = clearNotification
            , notifs = session.notifications
            }

        -- , Modal.view
        , case session.store.auth of
            Just _ ->
                main_ [ class "App" ]
                    [ Topbar.view session
                        |> Html.map topbarMsg
                    , div [ class "App__body" ]
                        [ Sidebar.view sidebar session.currentUrl
                            |> Html.map sidebarMsg
                        , div [ class "Content" ]
                            [ div [ class "Page HelperScrollArea" ] content
                            , div [ class "Content__bottom" ]
                                [ Player.view player
                                    |> Html.map playerMsg
                                , Device.view devices
                                    |> Html.map deviceMsg
                                ]
                            ]
                        ]
                    ]

            Nothing ->
                main_ [ class "App" ] content
        ]
    }
