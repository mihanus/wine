module Config.ControllerMapping where

import System.Spicey
import System.Routes
import Controller.SpiceySystem
import Config.RoutesData
import Controller.Category
import Controller.Wine

--- Maps the controllers associated to URLs in module RoutesData
--- into the actual controller operations.
getController :: ControllerReference -> Controller
getController fktref =
  case fktref of
    ProcessListController -> processListController
    LoginController -> loginController
    CategoryController -> mainCategoryController
    WineController -> mainWineController
    _ -> displayError "getController: no mapping found"