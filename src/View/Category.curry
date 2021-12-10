module View.Category
  ( wCategory, tuple2Category, category2Tuple, wCategoryType
  , showCategoryView, listCategoryView, leqCategory
  ) where

import Data.List
import Data.Time
import HTML.Base
import HTML.Styles.Bootstrap4
import HTML.WUI
import Wine
import Config.EntityRoutes
import System.Authentication
import System.SessionInfo
import System.Spicey
import View.EntitiesToHtml

--- The WUI specification for the entity type Category.
wCategory :: WuiSpec String
wCategory = withRendering wRequiredString (renderLabels categoryLabelList)

--- Transformation from data of a WUI form to entity type Category.
tuple2Category :: Category -> String -> Category
tuple2Category categoryToUpdate name = setCategoryName categoryToUpdate name

--- Transformation from entity type Category to a tuple
--- which can be used in WUI specifications.
category2Tuple :: Category -> String
category2Tuple category = categoryName category

--- WUI Type for editing or creating Category entities.
--- Includes fields for associated entities.
wCategoryType :: Category -> WuiSpec Category
wCategoryType category =
  transformWSpec (tuple2Category category,category2Tuple) wCategory

--------------------------------------------------------------------------
--- Supplies a view to show the details of a Category.
showCategoryView :: UserSessionInfo -> Category -> [BaseHtml]
showCategoryView _ category =
  categoryToDetailsView category
   ++ [hrefPrimSmButton "?Category/list" [htxt "back to Category list"]]

--- Compares two Category entities. This order is used in the list view.
leqCategory :: Category -> Category -> Bool
leqCategory x1 x2 = categoryName x1 <= categoryName x2

--- Supplies a list view for a given list of Category entities.
--- Shows also show/edit/delete buttons if the user is logged in.
--- The arguments are the session info and the list of Category entities.
listCategoryView :: UserSessionInfo -> [Category] -> [BaseHtml]
listCategoryView sinfo categorys =
  [h1 [htxt "Weinkategorien:"],
   spTable
    (--[take 1 categoryLabelList] ++
     map listCategory (sortBy leqCategory categorys))
  ]
  where
   listCategory category =
     categoryToListView category ++
      if not (isAdminSession sinfo)
        then []
        else [--[hrefPrimBadge (showRoute category) [htxt "Show"]]
              [hrefLightBadge (editRoute category)   [editIcon]]
             ,[hrefLightBadge (deleteRoute category) [deleteIcon]]
             ]
