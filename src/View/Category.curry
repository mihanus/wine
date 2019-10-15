module View.Category
  ( wCategory, tuple2Category, category2Tuple, wCategoryType
  , showCategoryView, listCategoryView, leqCategory
  ) where

import HTML.WUI
import HTML.Base
import Time
import Sort
import HTML.Styles.Bootstrap3
import System.Authentication
import System.Spicey
import System.SessionInfo
import Wine
import View.WineEntitiesToHtml

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
showCategoryView :: UserSessionInfo -> Category -> [HtmlExp]
showCategoryView _ category =
  categoryToDetailsView category
   ++ [hrefButton "?Category/list" [htxt "back to Category list"]]

--- Compares two Category entities. This order is used in the list view.
leqCategory :: Category -> Category -> Bool
leqCategory x1 x2 = categoryName x1 <= categoryName x2

--- Supplies a list view for a given list of Category entities.
--- Shows also buttons to show, delete, or edit entries.
listCategoryView :: UserSessionInfo -> [Category] -> [HtmlExp]
listCategoryView sinfo categorys =
  [h1 [htxt "Weinkategorien:"],
   spTable
    (--[take 1 categoryLabelList] ++
     map listCategory (mergeSortBy leqCategory categorys))]
  where listCategory :: Category -> [[HtmlExp]]
        listCategory category =
          categoryToListView category ++
           if not (isAdminSession sinfo) then [] else
           [--[spHref ("?Category/show/" ++ showCategoryKey category)
            --  [htxt "show"]]
            [spHref ("?Category/edit/" ++ showCategoryKey category)
              [editIcon]]
           
           ,[spHref ("?Category/delete/" ++ showCategoryKey category)
              [deleteIcon]]]
