module View.Wine
  ( wWine, tuple2Wine, wine2Tuple, wWineType
  , showWineView, listWineView ) where

import HTML.WUI
import HTML.Base
import Time
import Sort
import HTML.Styles.Bootstrap4
import System.Authentication
import Wine
import Config.EntityRoutes
import System.SessionInfo
import System.Spicey
import View.EntitiesToHtml

--- The WUI specification for the entity type Wine.
--- It also includes fields for associated entities.
wWine :: [Category] -> WuiSpec (String,String,Int,String,Int,Category)
wWine categoryList =
  withRendering
   (w6Tuple wRequiredString wRequiredString wInt wRequiredString wInt
     (wSelect categoryToShortView categoryList))
   (renderLabels wineLabelList)

--- Transformation from data of a WUI form to entity type Wine.
tuple2Wine :: Wine -> (String,String,Int,String,Int,Category) -> Wine
tuple2Wine wineToUpdate (name,region,year,price,bottles,category) =
  setWineName
   (setWineRegion
     (setWineYear
       (setWinePrice
         (setWineBottles
           (setWineCategoryWineCategoryKey wineToUpdate
             (categoryKey category))
           bottles)
         price)
       year)
     region)
   name

--- Transformation from entity type Wine to a tuple
--- which can be used in WUI specifications.
wine2Tuple :: Category -> Wine -> (String,String,Int,String,Int,Category)
wine2Tuple category wine =
  (wineName wine
  ,wineRegion wine
  ,wineYear wine
  ,winePrice wine
  ,wineBottles wine
  ,category)

--- WUI Type for editing or creating Wine entities.
--- Includes fields for associated entities.
wWineType :: Wine -> Category -> [Category] -> WuiSpec Wine
wWineType wine category categoryList =
  transformWSpec (tuple2Wine wine,wine2Tuple category) (wWine categoryList)

--------------------------------------------------------------------------
--- Supplies a view to show the details of a Wine.
showWineView :: UserSessionInfo -> Wine -> Category -> [HtmlExp]
showWineView _ wine relatedCategory =
  wineToDetailsView wine relatedCategory
   ++ [hrefPrimSmButton "?Wine/list" [htxt "back to Wine list"]]

--- Compares two Wine entities. This order is used in the list view.
leqWine :: Wine -> Wine -> Bool
leqWine x1 x2 =
  (wineName x1,wineRegion x1,wineYear x1,winePrice x1,wineBottles x1)
   <= (wineName x2,wineRegion x2,wineYear x2,winePrice x2,wineBottles x2)

--- Supplies a list view for a given list of Wine entities.
--- Shows also show/edit/delete buttons if the user is logged in.
--- The arguments are the session info and the list of Wine entities.
listWineView :: UserSessionInfo -> String -> Maybe [Category] -> [Wine]
             -> HtmlExp -> [HtmlExp]
listWineView sinfo catname mballcats wines allbutton =
  [h1 [htxt catname]
  ,spTable ([take 5 wineLabelList] ++ listWines mballcats)
  ,allbutton]
  where
   listWines Nothing     = map listWine (mergeSortBy leqWine wines)
   listWines (Just cats) = concatMap listWinesOfCat cats

   listWinesOfCat cat =
     let catwines =
           filter (\w -> wineCategoryWineCategoryKey w == categoryKey cat) wines
      in if null catwines
         then []
         else [categoryToListView cat] ++
              map listWine (mergeSortBy leqWine catwines) ++
              [[[italic [stringToHtml "Anzahl Flaschen: "]],[],[],[],
                [italic [stringToHtml
                           (show (foldr (+) 0 (map wineBottles catwines)))]]]]

   listWine :: Wine -> [[HtmlExp]]
   listWine wine =
     wineToListView wine ++
      if not (isAdminSession sinfo)
        then []
        else [[hrefPrimBadge (entityRoute "decr" wine) [htxt "-1"]]
             ,[hrefLightBadge (editRoute   wine) [editIcon]]
             ,[hrefLightBadge (deleteRoute wine) [deleteIcon]]]
