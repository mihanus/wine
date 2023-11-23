module Config.EntityRoutes () where

import System.Spicey
import Model.Wine

instance EntityController Category where
  controllerOnKey s =
    applyControllerOn (readCategoryKey s) (runJustT . getCategory)

  entityRoute r ent = concat ["?Category/",r,"/",showCategoryKey ent]

instance EntityController Wine where
  controllerOnKey s = applyControllerOn (readWineKey s) (runJustT . getWine)

  entityRoute r ent = concat ["?Wine/",r,"/",showWineKey ent]