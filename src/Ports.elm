port module Ports exposing (beardifyPlayer, saveStore, storeChanged)


port saveStore : String -> Cmd msg


port storeChanged : (String -> msg) -> Sub msg


port beardifyPlayer : (Bool -> msg) -> Sub msg
