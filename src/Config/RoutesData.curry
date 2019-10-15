module Config.RoutesData where

import System.Authentication
import System.SessionInfo

data ControllerReference = ProcessListController
                         | LoginController
                         | CategoryController
                         | WineController

data UrlMatch = Exact String
              | Prefix String String
              | Matcher (String -> Bool)
              | Always

type Route = (String,UrlMatch,ControllerReference)

--- This constant specifies the association of URLs to controllers.
--- Controllers are identified here by constants of type
--- ControllerReference. The actual mapping of these constants
--- into the controller operations is specified in the module
--- ControllerMapping.
getRoutes :: IO [Route]
getRoutes = do
  sinfo <- getUserSessionInfo
  let mblogin = userLoginOfSession sinfo
  return $
     [--("Processes",Exact "spiceyProcesses",ProcessListController)
      ("Kategorien",Prefix "Category" "list",CategoryController)] ++
     (if isAdminSession sinfo
        then [("Neue Kategorie",Prefix "Category" "new",CategoryController)
             ,("Neuer Wein",Prefix "Wine" "new",WineController)]
        else []) ++
     [("Alle Weine",Prefix "Wine" "list",WineController)
     ,(maybe "Login" (const "Logout") mblogin,Exact "login",LoginController)
     ,("default",Always,CategoryController)]
