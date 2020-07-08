module View.EntitiesToHtml where

import Time
import HTML.Base
import HTML.Styles.Bootstrap4 ( hrefInfoBlock )
import HTML.WUI
import System.Spicey
import Wine

--- The list view of a Category entity in HTML format.
--- This view is used in a row of a table of all entities.
categoryToListView :: Category -> [[HtmlExp]]
categoryToListView category =
  [[hrefInfoBlock (showControllerURL "Wine" ["cat",showCategoryKey category])
                    [stringToHtml (categoryName category)]]]

--- The short view of a Category entity as a string.
--- This view is used in menus and comments to refer to a Category entity.
categoryToShortView :: Category -> String
categoryToShortView category = categoryName category

--- The detailed view of a Category entity in HTML format.
categoryToDetailsView :: Category -> [HtmlExp]
categoryToDetailsView category =
  [spTable
    (map (\(label,value) -> [label,value])
      (zip categoryLabelList detailedView))]
  where
    detailedView = [[stringToHtml (categoryName category)]]

--- The labels of a Category entity, as used in HTML tables.
categoryLabelList :: [[HtmlExp]]
categoryLabelList =
  [[textstyle "spicey_label spicey_label_for_type_string" "Name"]]

--- The list view of a Wine entity in HTML format.
--- This view is used in a row of a table of all entities.
wineToListView :: Wine -> [[HtmlExp]]
wineToListView wine =
  [[stringToHtml (wineName wine)],[stringToHtml (wineRegion wine)]
  ,[wineYearToHtml wine],[stringToHtml (winePrice wine)]
  ,[intToHtml (wineBottles wine)]]

--- The short view of a Wine entity as a string.
--- This view is used in menus and comments to refer to a Wine entity.
wineToShortView :: Wine -> String
wineToShortView wine = wineName wine

--- The detailed view of a Wine entity in HTML format.
--- It also takes associated entities for every associated entity type.
wineToDetailsView :: Wine -> Category -> [HtmlExp]
wineToDetailsView wine relatedCategory =
  [spTable
    (map (\(label,value) -> [label,value]) (zip wineLabelList detailedView))]
  where
    detailedView =
      [[stringToHtml (wineName wine)]
      ,[stringToHtml (wineRegion wine)]
      ,[wineYearToHtml wine]
      ,[stringToHtml (winePrice wine)]
      ,[intToHtml (wineBottles wine)]
      ,[htxt (categoryToShortView relatedCategory)]]

--- The labels of a Wine entity, as used in HTML tables.
wineLabelList :: [[HtmlExp]]
wineLabelList =
  [[textstyle "spicey_label spicey_label_for_type_string" "Name"]
  ,[textstyle "spicey_label spicey_label_for_type_string" "Region"]
  ,[textstyle "spicey_label spicey_label_for_type_int" "Jahr"]
  ,[textstyle "spicey_label spicey_label_for_type_string" "Preis"]
  ,[textstyle "spicey_label spicey_label_for_type_int" "Flaschen"]
  ,[textstyle "spicey_label spicey_label_for_type_relation" "Kategorie"]]


wineYearToHtml :: Wine -> HtmlExp
wineYearToHtml wine = let year = wineYear wine in
  if year==0 then nbsp else intToHtml year
