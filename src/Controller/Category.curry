module Controller.Category
  ( mainCategoryController, newCategoryForm, editCategoryForm
  ) where

import Global
import Maybe
import Sort   ( sortBy )
import Time

import HTML.Base
import HTML.Session
import HTML.WUI

import Config.Storage
import System.Spicey
import Wine
import View.Category
import System.SessionInfo
import System.Authorization
import System.AuthorizedActions
import Config.EntityRoutes
import Config.UserProcesses
import View.EntitiesToHtml
import Database.CDBI.Connection

--- Choose the controller for a Category entity according to the URL parameter.
mainCategoryController :: Controller
mainCategoryController =
  do args <- getControllerParams
     case args of
       [] -> listCategoryController
       ["list"] -> listCategoryController
       ["new"] -> newCategoryController
       ["show",s] -> controllerOnKey s showCategoryController
       ["edit",s] -> controllerOnKey s editCategoryController
       ["delete",s] -> controllerOnKey s deleteCategoryController
       ["destroy",s] -> controllerOnKey s destroyCategoryController
       _ -> displayUrlError

--------------------------------------------------------------------------
--- The type of a new Category entity.
type NewCategory = String

--- Shows a form to create a new Category entity inside the given category.
newCategoryController :: Controller
newCategoryController =
  checkAuthorization (categoryOperationAllowed NewEntity) $ \_ -> do
    setWuiStore wuiNewCategoryStore ""
    return [formExp newCategoryForm]

--- Supplies a WUI form to create a new Category entity.
--- The fields of the entity have some default values.
newCategoryForm :: HtmlFormDef (WuiStore NewCategory)
newCategoryForm =
  wui2FormDef "Controller.Category.newCategoryForm"
    wuiNewCategoryStore
    wCategory
    (\entity -> transactionController (runT (createCategoryT entity))
                  (nextInProcessOr listCategoryController Nothing))
    (renderWUI "Neue Kategorie" "Speichern" "?Category/list" ())

---- The data stored for executing the WUI form.
wuiNewCategoryStore :: Global (SessionStore (WuiStore NewCategory))
wuiNewCategoryStore =
  global emptySessionStore (Persistent (inDataDir "wuiNewCategoryStore"))

--- Transaction to persist a new Category entity to the database.
createCategoryT :: String -> DBAction ()
createCategoryT name = newCategory name >+= (\_ -> return ())

--------------------------------------------------------------------------
--- Shows a form to edit the given Category entity.
editCategoryController :: Category -> Controller
editCategoryController categoryToEdit =
  checkAuthorization (categoryOperationAllowed (UpdateEntity categoryToEdit))
   $ \_ -> do
      setParWuiStore wuiEditCategoryStore categoryToEdit categoryToEdit
      return [formExp editCategoryForm]

--- Supplies a WUI form to edit a given Category entity.
--- The fields of the entity have some default values.
editCategoryForm :: HtmlFormDef (Category, WuiStore Category)
editCategoryForm =
  pwui2FormDef "Controller.Category.editCategoryForm"
    wuiEditCategoryStore
    (\cat -> wCategoryType cat)
    (\cat entity ->
       checkAuthorization (categoryOperationAllowed (UpdateEntity cat)) $ \_ ->
         transactionController (runT (updateCategoryT entity))
           (nextInProcessOr listCategoryController Nothing))
    (renderWUI "Kategorie ändern" "Ändern" "?Category/list")

---- The data stored for executing the WUI form.
wuiEditCategoryStore :: Global (SessionStore (Category, WuiStore Category))
wuiEditCategoryStore =
  global emptySessionStore (Persistent (inDataDir "wuiEditCategoryStore"))

--- Transaction to persist modifications of a given Category entity
--- to the database.
updateCategoryT :: Category -> DBAction ()
updateCategoryT category = updateCategory category

--------------------------------------------------------------------------
--- Deletes a given Category entity (after asking for confirmation)
--- and proceeds with the list controller.
deleteCategoryController :: Category -> Controller
deleteCategoryController category =
  checkAuthorization (categoryOperationAllowed (DeleteEntity category))
   $ (\sinfo ->
     confirmDeletionPage sinfo
      (concat ["Really delete entity \"",categoryToShortView category,"\"?"]))

--- Deletes a given Category entity
--- and proceeds with the list controller.
destroyCategoryController :: Category -> Controller
destroyCategoryController category =
  checkAuthorization (categoryOperationAllowed (DeleteEntity category)) $ \_ ->
    transactionController (runT (deleteCategoryT category))
      listCategoryController

--- Transaction to delete a given Category entity.
deleteCategoryT :: Category -> DBAction ()
deleteCategoryT category = deleteCategory category

--------------------------------------------------------------------------
--- Lists all Category entities with buttons to show, delete,
--- or edit an entity.
listCategoryController :: Controller
listCategoryController =
  checkAuthorization (categoryOperationAllowed ListEntities)
   $ (\sinfo ->
     do categorys <- runQ queryAllCategorys >>= return . sortBy leqCategory
        return (listCategoryView sinfo categorys))

--- Shows a Category entity.
showCategoryController :: Category -> Controller
showCategoryController category =
  checkAuthorization (categoryOperationAllowed (ShowEntity category))
   $ (\sinfo -> do return (showCategoryView sinfo category))
