module Controller.Wine
  ( mainWineController, newWineForm, editWineForm
  ) where

import Global
import Sort   ( sortBy )
import Time

import HTML.Base
import HTML.Session
import HTML.WUI

import Config.Storage
import System.Spicey
import Wine
import View.Category
import View.Wine
import Maybe
import System.SessionInfo
import System.Authorization
import System.AuthorizedActions
import Config.Globals
import Config.UserProcesses
import View.WineEntitiesToHtml
import Database.CDBI.Connection

--- Choose the controller for a Wine entity according to the URL parameter.
mainWineController :: Controller
mainWineController =
  do args <- getControllerParams
     case args of
       [] -> listWineController Nothing
       ["list"] -> listWineController Nothing
       ["new"] -> newWineController
       ["cat",s] -> listWineController (readCategoryKey s)
       ["show",s] -> applyWineControllerOn s showWineController
       ["decr",s] -> applyWineControllerOn s decrWineController
       ["edit",s] -> applyWineControllerOn s editWineController
       ["delete",s] -> applyWineControllerOn s deleteWineController
       ["destroy",s] -> applyWineControllerOn s destroyWineController
       _ -> displayUrlError

--- Applies a wine controller on the wine specified by the
--- key (first argument).
applyWineControllerOn
  :: String -> (Wine -> Controller) -> Controller
applyWineControllerOn s =
  applyControllerOn (readWineKey s) (runJustT . getWine)

getAllCats :: IO [Category]
getAllCats = runQ queryAllCategorys >>= return . sortBy leqCategory

--------------------------------------------------------------------------
--- The type of a new Wine entity.
type NewWine = (String,String,Int,String,Int,Category)

--- Shows a form to create a new Wine entity inside the given wine.
newWineController :: Controller
newWineController =
  checkAuthorization (wineOperationAllowed NewEntity) $ \_ -> do
    allCategorys <- getAllCats
    setParWuiStore wuiNewWineStore allCategorys
      ("", "", 0, "", 0, head allCategorys)
    return [formExp newWineForm]

--- Supplies a WUI form to create a new Wine entity.
--- The fields of the entity have some default values.
newWineForm :: HtmlFormDef ([Category], WuiStore NewWine)
newWineForm =
  pwui2FormDef "Controller.Wine.newWineForm"
    wuiNewWineStore
    (\allCategorys -> wWine allCategorys)
    (\_ entity -> transactionController (runT (createWineT entity))
                    (nextInProcessOr (listWineController Nothing) Nothing))
    (renderWuiExp "Neuer Wein" "Anlegen" (listWineController Nothing))

---- The data stored for executing the WUI form.
wuiNewWineStore :: Global (SessionStore ([Category], WuiStore NewWine))
wuiNewWineStore =
  global emptySessionStore (Persistent (inDataDir "wuiNewWineStore"))

--- Transaction to persist a new Wine entity to the database.
createWineT :: (String,String,Int,String,Int,Category) -> DBAction ()
createWineT (name,region,year,price,bottles,category) =
  newWineWithCategoryWineCategoryKey name region year price bottles
   (categoryKey category)
   >+= (\_ -> return ())

--------------------------------------------------------------------------
--- Shows a form to edit the given Wine entity.
editWineController :: Wine -> Controller
editWineController wineToEdit =
  checkAuthorization (wineOperationAllowed (UpdateEntity wineToEdit))
   $ \_ -> do
      allCategorys <- getAllCats
      wineCategoryCategory <- runJustT (getWineCategoryCategory wineToEdit)
      setParWuiStore wuiEditWineStore
        (wineToEdit,wineCategoryCategory,allCategorys) wineToEdit
      return [formExp editWineForm]

--- Supplies a WUI form to edit a given Wine entity.
--- The fields of the entity have some default values.
editWineForm :: HtmlFormDef ((Wine,Category,[Category]), WuiStore Wine)
editWineForm =
  pwui2FormDef "Controller.Wine.editWineForm"
    wuiEditWineStore
    (\ (wine,winecat,allcats) -> wWineType wine winecat allcats)
    (\_ wine ->
       checkAuthorization (wineOperationAllowed (UpdateEntity wine)) $ \_ ->
         transactionController (runT (updateWineT wine))
           (nextInProcessOr
              (listWineController (Just (wineCategoryWineCategoryKey wine)))
              Nothing))
    (\ (wine,_,_) -> renderWuiExp "Ändere Wein" "Ändern"
         (listWineController (Just (wineCategoryWineCategoryKey wine))) ())

---- The data stored for executing the WUI form.
wuiEditWineStore ::
  Global (SessionStore ((Wine,Category,[Category]), WuiStore Wine))
wuiEditWineStore =
  global emptySessionStore (Persistent (inDataDir "wuiEditWineStore"))

--- Decrement the number of bottles of the given Wine entity.
decrWineController :: Wine -> Controller
decrWineController wine =
  checkAuthorization (wineOperationAllowed (UpdateEntity wine)) $ \_ -> do
    transResult <- runT (updateWine
                          (setWineBottles wine (wineBottles wine - 1)))
    either (\ error -> displayError (show error))
           (\ _ -> listWineController
                       (Just (wineCategoryWineCategoryKey wine)))
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
  checkAuthorization (wineOperationAllowed (DeleteEntity wine)) $ \_ ->
     confirmDeletionPage $ concat
       ["Really delete entity \"", wineToShortView wine, "\"?"]

--- Deletes a given Wine entity
--- and proceeds with the list controller.
destroyWineController :: Wine -> Controller
destroyWineController wine =
  checkAuthorization (wineOperationAllowed (DeleteEntity wine)) $ \_ ->
    transactionController (runT (deleteWineT wine))
      (listWineController (Just (wineCategoryWineCategoryKey wine)))

--- Transaction to delete a given Wine entity.
deleteWineT :: Wine -> DBAction ()
deleteWineT wine = deleteWine wine

--------------------------------------------------------------------------
--- Lists all Wine entities with buttons to show, delete,
--- or edit an entity.
listWineController :: Maybe CategoryID -> Controller
listWineController mbcat =
  checkAuthorization (wineOperationAllowed ListEntities)
   $ (\sinfo ->
     do wines <- runQ queryAllWines
        let selwines =
              maybe wines
                (\c -> filter (\w -> wineCategoryWineCategoryKey w == c) wines)
                mbcat
        catname <- maybe (return "Alle Weine") getCategoryName mbcat
        allcats <- maybe (getAllCats >>= return . Just)
                         (\_ -> return Nothing)
                         mbcat
        return (listWineView sinfo catname allcats selwines))


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
