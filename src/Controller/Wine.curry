module Controller.Wine
  ( mainWineController, newWineForm, editWineForm
  ) where

import Data.List ( sortBy )
import Data.Time
import HTML.Base
import HTML.Session
import HTML.WUI
import HTML.Styles.Bootstrap4 ( hrefSuccButton )
import Wine
import Config.EntityRoutes
import Config.UserProcesses
import System.SessionInfo
import System.Authorization
import System.AuthorizedActions
import System.Spicey
import View.Category         ( leqCategory )
import View.EntitiesToHtml
import View.Wine
import Database.CDBI.Connection

import System.PreludeHelpers

--- Choose the controller for a Wine entity according to the URL parameter.
mainWineController :: Controller
mainWineController =
  do args <- getControllerParams
     case args of
       [] -> listWineController Nothing False
       ["list"] -> listWineController Nothing False
       ["list","all"] -> listWineController Nothing True
       ["new"] -> newWineController
       ["cat",s] -> listWineController (readCategoryKey s) False
       ["cat",s,"all"] -> listWineController (readCategoryKey s) True
       ["show"   ,s] -> controllerOnKey s showWineController
       ["decr"   ,s] -> controllerOnKey s decrWineController
       ["edit"   ,s] -> controllerOnKey s editWineController
       ["delete" ,s] -> controllerOnKey s deleteWineController
       ["destroy",s] -> controllerOnKey s destroyWineController
       _ -> displayUrlError

getAllCats :: IO [Category]
getAllCats = runQ queryAllCategorys >>= return . sortBy leqCategory

--------------------------------------------------------------------------
--- The type of a new Wine entity.
type NewWine = (String,String,Int,String,Int,Category)

--- Shows a form to create a new Wine entity inside the given wine.
newWineController :: Controller
newWineController =
  checkAuthorization (wineOperationAllowed NewEntity) $ \sinfo -> do
    allCategorys <- getAllCats
    setParWuiStore newWineStore (sinfo,allCategorys)
      ("", "", 0, "", 0, head allCategorys)
    return [formElem newWineForm]

--- A WUI form to create a new Wine entity.
--- The default values for the fields are stored in 'newWineStore'.
newWineForm :: HtmlFormDef ((UserSessionInfo,[Category]),WuiStore NewWine)
newWineForm =
  pwui2FormDef "Controller.Wine.newWineForm"
    newWineStore
    (\(_,allCategorys) -> wWine allCategorys)
    (\_ entity -> transactionController (runT (createWineT entity))
                   (nextInProcessOr (listWineController Nothing False) Nothing))
    (\(sinfo,_) -> renderWUI sinfo "Neuer Wein" "Anlegen" "?Wine/list" ())

--- The data stored for executing the "new entity" WUI form.
newWineStore :: SessionStore ((UserSessionInfo,[Category]),WuiStore NewWine)
newWineStore = sessionStore "newWineStore"

--- Transaction to persist a new Wine entity to the database.
createWineT :: NewWine -> DBAction ()
createWineT (name,region,year,price,bottles,category) =
  newWineWithCategoryWineCategoryKey name region year price bottles
   (categoryKey category)
   >>= (\_ -> return ())

--------------------------------------------------------------------------
--- Shows a form to edit the given Wine entity.
editWineController :: Wine -> Controller
editWineController wineToEdit =
  checkAuthorization (wineOperationAllowed (UpdateEntity wineToEdit))
   $ \sinfo -> do
      allCategorys <- getAllCats
      wineCategoryCategory <- runJustT (getWineCategoryCategory wineToEdit)
      setParWuiStore editWineStore
        (sinfo, wineToEdit,wineCategoryCategory,allCategorys) wineToEdit
      return [formElem editWineForm]

--- A WUI form to edit a Wine entity.
--- The default values for the fields are stored in 'editWineStore'.
editWineForm
  :: HtmlFormDef ((UserSessionInfo,Wine,Category,[Category]),WuiStore Wine)
editWineForm =
  pwui2FormDef "Controller.Wine.editWineForm"
    editWineStore
    (\ (_,wine,winecat,allcats) -> wWineType wine winecat allcats)
    (\_ wine ->
       checkAuthorization (wineOperationAllowed (UpdateEntity wine)) $ \_ ->
         transactionController (runT (updateWineT wine))
           (nextInProcessOr
              (listWineController (Just (wineCategoryWineCategoryKey wine))
                                  False)
              Nothing))
    (\ (sinfo,wine,_,_) -> renderWUI sinfo "Ändere Wein" "Ändern"
         ("?Wine/cat/" ++ showCategoryIDKey (wineCategoryWineCategoryKey wine))
         ())

--- The data stored for executing the edit WUI form.
editWineStore
  :: SessionStore ((UserSessionInfo,Wine,Category,[Category]),WuiStore Wine)
editWineStore = sessionStore "editWineStore"

--- Decrement the number of bottles of the given Wine entity.
decrWineController :: Wine -> Controller
decrWineController wine =
  checkAuthorization (wineOperationAllowed (UpdateEntity wine)) $ \_ -> do
    transResult <- runT (updateWine
                          (setWineBottles wine (wineBottles wine - 1)))
    either (\ error -> displayError (show error))
           (\ _ -> listWineController
                       (Just (wineCategoryWineCategoryKey wine)) False)
           transResult

--- Transaction to persist modifications of a given Wine entity
--- to the database.
updateWineT :: Wine -> DBAction ()
updateWineT wine = updateWine wine

--------------------------------------------------------------------------
--- Deletes a given Wine entity (after asking for confirmation)
--- and proceeds with the list controller.
deleteWineController :: Wine -> Controller
deleteWineController wine =
  checkAuthorization (wineOperationAllowed (DeleteEntity wine))
   $ (\sinfo ->
     confirmDeletionPage sinfo
      (concat ["Really delete entity \"",wineToShortView wine,"\"?"]))

--- Deletes a given Wine entity
--- and proceeds with the list controller.
destroyWineController :: Wine -> Controller
destroyWineController wine =
  checkAuthorization (wineOperationAllowed (DeleteEntity wine)) $ \_ ->
    transactionController (runT (deleteWineT wine))
      (listWineController (Just (wineCategoryWineCategoryKey wine)) False)

--- Transaction to delete a given Wine entity.
deleteWineT :: Wine -> DBAction ()
deleteWineT wine = deleteWine wine

--------------------------------------------------------------------------
--- Lists all Wine entities with buttons to show, delete,
--- or edit an entity.
listWineController :: Maybe CategoryID -> Bool -> Controller
listWineController mbcat showall =
  checkAuthorization (wineOperationAllowed ListEntities) $ \sinfo -> do
    allwines <- runQ queryAllWines
    let wines = filter (\w -> showall || wineBottles w > 0) allwines
    let selwines =
          maybe wines
                (\c -> filter (\w -> wineCategoryWineCategoryKey w == c) wines)
                mbcat
    catname <- maybe (return "Alle Weine") getCategoryName mbcat
    let allbutton =
          if showall
            then hrefSuccButton
                   ("?Wine/" ++
                    maybe "list" (\c -> "cat/" ++ showCategoryIDKey c) mbcat)
                   [htxt "nur Weine mit Flaschen anzeigen"]
            else hrefSuccButton
                   ("?Wine/" ++
                    maybe "list/all"
                          (\c -> "cat/" ++ showCategoryIDKey c ++ "/all")
                          mbcat)
                   [htxt "auch Weine ohne Flaschen anzeigen"]
    allcats <- maybe (getAllCats >>= return . Just)
                     (\_ -> return Nothing)
                     mbcat
    return (listWineView sinfo catname allcats selwines allbutton)


--- Shows a Wine entity.
showWineController :: Wine -> Controller
showWineController wine =
  checkAuthorization (wineOperationAllowed (ShowEntity wine))
   $ (\sinfo ->
     do wineCategoryCategory <- runJustT (getWineCategoryCategory wine)
        return (showWineView sinfo wine wineCategoryCategory))

--- Gets the associated Category entity for a given Wine entity.
getWineCategoryCategory :: Wine -> DBAction Category
getWineCategoryCategory wCategory =
  getCategory (wineCategoryWineCategoryKey wCategory)

--- Gets the nane of a Category with a given key.
getCategoryName :: CategoryID -> IO String
getCategoryName catkey = do
  cat <- runT $ getCategory catkey
  return (either (const "") categoryName cat)
