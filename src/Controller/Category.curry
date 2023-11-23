module Controller.Category
  ( mainCategoryController, newCategoryForm, editCategoryForm
  ) where

import Data.List ( sortBy )
import Data.Time
import HTML.Base
import HTML.Session
import HTML.WUI

import System.Spicey
import Model.Wine
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
  checkAuthorization (categoryOperationAllowed NewEntity)
   $ (\sinfo ->
     do setParWuiStore newCategoryStore sinfo ""
        return [formElem newCategoryForm])

--- Supplies a WUI form to create a new Category entity.
--- The fields of the entity have some default values.
newCategoryForm :: HtmlFormDef (UserSessionInfo,WuiStore NewCategory)
newCategoryForm =
  pwui2FormDef "Controller.Category.newCategoryForm"
    newCategoryStore
    (\_ -> wCategory)
    (\_ entity -> transactionController (runT (createCategoryT entity))
         (nextInProcessOr (redirectController "?Category/list") Nothing))
    (\sinfo ->
      renderWUI sinfo "Neue Kategorie" "Speichern" "?Category/list" ())

--- The data stored for executing the "new entity" WUI form.
newCategoryStore :: SessionStore (UserSessionInfo,WuiStore NewCategory)
newCategoryStore = sessionStore "newCategoryStore"

--- Transaction to persist a new Category entity to the database.
createCategoryT :: String -> DBAction ()
createCategoryT name = newCategory name >+= (\_ -> return ())

--------------------------------------------------------------------------
--- Shows a form to edit the given Category entity.
editCategoryController :: Category -> Controller
editCategoryController categoryToEdit =
  checkAuthorization (categoryOperationAllowed (UpdateEntity categoryToEdit))
   $ (\sinfo ->
     do setParWuiStore editCategoryStore (sinfo,categoryToEdit) categoryToEdit
        return [formElem editCategoryForm])

--- A WUI form to edit a Category entity.
--- The default values for the fields are stored in 'editCategoryStore'.
editCategoryForm :: HtmlFormDef ((UserSessionInfo,Category),WuiStore Category)
editCategoryForm =
  pwui2FormDef "Controller.Category.editCategoryForm"
    editCategoryStore
    (\ (_,cat) -> wCategoryType cat)
    (\_ cat ->
       checkAuthorization
         (categoryOperationAllowed (UpdateEntity cat))
         (\_ ->
         transactionController (runT (updateCategoryT cat))
           (nextInProcessOr (redirectController "?Category/List") Nothing)))
    (\ (sinfo,_) ->
       renderWUI sinfo "Kategorie ändern" "Ändern" "?Category/list" ()) 

--- The data stored for executing the edit WUI form.
editCategoryStore
  :: SessionStore ((UserSessionInfo,Category),WuiStore Category)
editCategoryStore = sessionStore "editCategoryStore"

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
