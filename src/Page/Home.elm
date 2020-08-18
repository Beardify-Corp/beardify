module Page.Home exposing (Model, Msg(..), init, subscriptions, update, view)

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    {}


type Msg
    = NoOp


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( {}
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Session -> Model -> ( String, List (Html Msg) )
view _ _ =
    ( "Home"
    , [ div [ class "Page__body HelperScrollArea__target" ]
            [ div [ class "Flex fullHeight" ]
                [ div [ class "Home Flex__full HelperScrollArea" ]
                    [ h1 [ class "Home__title" ] [ text "Bienvenue, espèce de nullos !" ]
                    , p []
                        [ text "Bon. Voici la"
                        , b [] [ text " version alpha " ]
                        , text "de notre client Spotify. Comme tu va pouvoir le remarquer, il y a encore pas mal de bugs, mais c'est normal puis que c'est une alpha donc ca va venir au fur et à mesure !"
                        , b [] [ text " Donc tu te calmes !" ]
                        ]
                    , h2 [ class "Home__title" ] [ text "Pourquoi un client Spotify ?" ]
                    , p []
                        [ text "Vous avez remarqué que sur Spotify (ainsi que les autres plateformes de streaming audio) ne fonctionnent que par des listes de morceaux ? Moi oui et ca m'agace, je fonctionne par album. Donc j'ai décidé de créer un client Spotify customisé, ou je pourrais créer des"
                        , b [] [ text " listes d'albums" ]
                        , text ". L'ennui, c'est que cette fonctionnalité n'existe pas dans Spotify, j'ai donc du ruser en contournant le fonctionnement initial des playlists, pour en faire 2 affichages différents :"
                        ]
                    , ul []
                        [ li [] [ text "Un affichage classique de liste de morceaux" ]
                        , li [] [ text "Un affichage de liste d'albums (donc les 'Collections')" ]
                        ]
                    , p []
                        [ text "Afin d'éviter de flinguer votre organisation de playlists Spotify, l'astuce conciste à changer son nom en rajoutant"
                        , b [] [ text " un mot clé devant " ]
                        , text "pour que Beardify le détecte et modifie l'affichage en fonction. Exemple :"
                        ]
                    , ul []
                        [ li [] [ text "La playlist 'Roche and Roule'" ]
                        , li [] [ text "Deviendra: '#Collection Roche and Roule'" ]
                        , li [] [ text "Et HOP ! Magie, votre playlist viens de se transformer en liste d'albums !" ]
                        ]
                    , h2 [ class "Home__title" ] [ text "Ce qui est fait, ou pas." ]
                    , h3 [ class "Home__title" ] [ text "Les fonctionnalités opérationnelles" ]
                    , ul []
                        [ li [] [ text "Les collections" ]
                        , li [] [ text "Les playlists" ]
                        , li [] [ text "Le player (quasiment)" ]
                        , li [] [ text "Le choix du périphérique sur lequel jouer ta musique" ]
                        , li [] [ text "La recherche" ]
                        , li [] [ text "Les pages artiste, album, playlist, collection" ]
                        , li [] [ text "L'ajout d'albums dans des collections" ]
                        ]
                    , h3 [ class "Home__title" ] [ text "Les fonctionnalités prévues et/ou en cours de faisage" ]
                    , ul []
                        [ li [] [ text "Le player (en fait, juste les bouton 'shuffle' et 'repeat'" ]
                        , li [] [ text "L'ajout de morceaux dans des playlists" ]
                        , li [] [ text "La sidebar de la page artiste qui contiendra ses dernières vidéos sur youtube" ]
                        , li [] [ text "Déplacer/renommer/ajouter/supprimer une collection ou une playlist" ]
                        , li [] [ text "Page utilisateur" ]
                        ]
                    , h2 [ class "Home__title" ] [ text "FAQ" ]
                    , h3 [ class "Home__title" ] [ text "Putain ils sont ou mes dossiers ?!" ]
                    , p [] [ text "C'est chiant hein ? Bah je ne peux actuellement rien faire pour ca, les outils que mette à disposition Spotify (Web API) ne nous mettent pas disposition vos dossiers, donc... On ne peut pas les afficher :(" ]
                    , h3 [ class "Home__title" ] [ text "Attends mais sur le client web officiel, ils les affichent !" ]
                    , p [] [ text "Ouais, sauf qu'ils n'utilisent pas la même API que celle qu'ils mettent à disposition publiquement les radins !" ]
                    , h3 [ class "Home__title" ] [ text "Attends mais ca marche pas ton truc, je ne voit rien qui se lance, pas même le player !" ]
                    , p []
                        [ text "Il faut comprendre une chose. Beardify se comporte actuellement (en espérant qu'on puisse remédier a ce problème rapidement) comme une sorte de 'télécommande'. C'est à dire qu'en soit, Beardify n'est"
                        , b [] [ text " pas encore " ]
                        , text "un client Spotify complet. Ce qui veux dire (ouais je sais c'est chiant mais pour l'instant faudra faire avec) qu'"
                        , b [] [ text "il faut lancer le client Spotify sur votre ordi en fond" ]
                        , text " pour qu'il comprenne que votre ordinateur est un périphérique de lecture actif."
                        ]
                    , h3 [ class "Home__title" ] [ text "Mais du coup, il est prévu quoi dans le futur ?" ]
                    , p [] [ text "Dans un futur plus ou moins proche, voici les choses qui sont prévues :" ]
                    , ul []
                        [ li [] [ text "Version compatible mobile" ]
                        , li [] [ text "La possibilité de parcourir/lire des podcasts" ]
                        , li [] [ text "La possibilité de partager des collections d'albums publiquement, sans devoir se connecter avec un compte Spotify" ]
                        , li [] [ text "Fusionner mon outil de veille de sorties d'albums à Beardify (en gros c'est un outil que j'ai crée qui récupère des sorties d'album et qui en crée une 'todo list', qu'on peut donc cocher au fur et a mesure de s'il nous intéresse ou qu'on l'a déjà écouté)" ]
                        ]
                    , br [] []
                    , br [] []
                    , br [] []
                    , br [] []
                    ]
                ]
            ]
      ]
    )
