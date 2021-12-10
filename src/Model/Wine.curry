--- This file has been generated from
--- 
---     /home/mh/home/curry/applications/wine/Wine.erdterm
--- 
--- and contains definitions for all entities and relations
--- specified in this model.

module Wine where

import qualified Data.Time
import qualified Database.CDBI.ER
import qualified Database.CDBI.Criteria
import qualified Database.CDBI.Connection
import qualified Database.CDBI.Description

import Config.Globals

data Category = Category CategoryID String
 deriving (Eq,Show,Read)

data CategoryID = CategoryID Int
 deriving (Eq,Show,Read)

data Wine = Wine WineID String String Int String Int CategoryID
 deriving (Eq,Show,Read)

data WineID = WineID Int
 deriving (Eq,Show,Read)

--- The name of the SQLite database file.
sqliteDBFile :: String
sqliteDBFile = "/net/medoc/home/mh/home/data/wine/Wine.db"

--- The ER description of the `Category` entity.
category_CDBI_Description
  :: Database.CDBI.Description.EntityDescription Category
category_CDBI_Description =
  Database.CDBI.Description.ED "Category"
   [Database.CDBI.Connection.SQLTypeInt,Database.CDBI.Connection.SQLTypeString]
   (\(Category (CategoryID key) name) ->
     [Database.CDBI.Connection.SQLInt key
     ,Database.CDBI.Connection.SQLString name])
   (\(Category _ name) ->
     [Database.CDBI.Connection.SQLNull,Database.CDBI.Connection.SQLString name])
   (\[Database.CDBI.Connection.SQLInt key
     ,Database.CDBI.Connection.SQLString name] ->
     Category (CategoryID key) name)

--- The database table of the `Category` entity.
categoryTable :: Database.CDBI.Description.Table
categoryTable = "Category"

--- The database column `Key` of the `Category` entity.
categoryColumnKey :: Database.CDBI.Description.Column CategoryID
categoryColumnKey =
  Database.CDBI.Description.Column "\"Key\"" "\"Category\".\"Key\""

--- The database column `Name` of the `Category` entity.
categoryColumnName :: Database.CDBI.Description.Column String
categoryColumnName =
  Database.CDBI.Description.Column "\"Name\"" "\"Category\".\"Name\""

--- The description of the database column `Key` of the `Category` entity.
categoryKeyColDesc :: Database.CDBI.Description.ColumnDescription CategoryID
categoryKeyColDesc =
  Database.CDBI.Description.ColDesc "\"Category\".\"Key\""
   Database.CDBI.Connection.SQLTypeInt
   (\(CategoryID key) -> Database.CDBI.Connection.SQLInt key)
   (\(Database.CDBI.Connection.SQLInt key) -> CategoryID key)

--- The description of the database column `Name` of the `Category` entity.
categoryNameColDesc :: Database.CDBI.Description.ColumnDescription String
categoryNameColDesc =
  Database.CDBI.Description.ColDesc "\"Category\".\"Name\""
   Database.CDBI.Connection.SQLTypeString
   (\name -> Database.CDBI.Connection.SQLString name)
   (\(Database.CDBI.Connection.SQLString name) -> name)

--- Gets the attribute `Key` of the `Category` entity.
categoryKey :: Category -> CategoryID
categoryKey (Category a _) = a

--- Gets the attribute `Name` of the `Category` entity.
categoryName :: Category -> String
categoryName (Category _ a) = a

--- Sets the attribute `Key` of the `Category` entity.
setCategoryKey :: Category -> CategoryID -> Category
setCategoryKey (Category _ b1) a = Category a b1

--- Sets the attribute `Name` of the `Category` entity.
setCategoryName :: Category -> String -> Category
setCategoryName (Category a2 _) a = Category a2 a

--- id-to-value function for entity `Category`.
categoryID :: CategoryID -> Database.CDBI.Criteria.Value CategoryID
categoryID (CategoryID key) = Database.CDBI.Criteria.idVal key

--- id-to-int function for entity `Category`.
categoryKeyToInt :: CategoryID -> Int
categoryKeyToInt (CategoryID key) = key

--- Shows the key of a `Category` entity as a string.
--- This is useful if a textual representation of the key is necessary
--- (e.g., as URL parameters in web pages), but it should no be used
--- to store keys in other attributes!
showCategoryKey :: Category -> String
showCategoryKey entry =
  Database.CDBI.ER.showDatabaseKey "Category" categoryKeyToInt
   (categoryKey entry)

--- Shows the key of a `Category` entity as a string.
--- This is useful if a textual representation of the key is necessary
--- (e.g., as URL parameters in web pages), but it should no be used
--- to store keys in other attributes!
showCategoryIDKey :: CategoryID -> String
showCategoryIDKey = Database.CDBI.ER.showDatabaseKey "Category" categoryKeyToInt

--- Transforms a string into a key of a `Category` entity.
--- Nothing is returned if the string does not represent a meaningful key.
readCategoryKey :: String -> Maybe CategoryID
readCategoryKey = Database.CDBI.ER.readDatabaseKey "Category" CategoryID

--- Gets all `Category` entities.
queryAllCategorys :: Database.CDBI.Connection.DBAction [Category]
queryAllCategorys = Database.CDBI.ER.getAllEntries category_CDBI_Description

--- Gets all `Category` entities satisfying a given predicate.
queryCondCategory
  :: (Category -> Bool) -> Database.CDBI.Connection.DBAction [Category]
queryCondCategory = Database.CDBI.ER.getCondEntries category_CDBI_Description

--- Gets a `Category` entry by a given key.
getCategory :: CategoryID -> Database.CDBI.Connection.DBAction Category
getCategory =
  Database.CDBI.ER.getEntryWithKey category_CDBI_Description categoryColumnKey
   categoryID

--- Inserts a new `Category` entity.
newCategory :: String -> Database.CDBI.Connection.DBAction Category
newCategory name_p =
  Database.CDBI.ER.insertNewEntry category_CDBI_Description setCategoryKey
   CategoryID
   (Category (CategoryID 0) name_p)

--- Deletes an existing `Category` entry by its key.
deleteCategory :: Category -> Database.CDBI.Connection.DBAction ()
deleteCategory =
  Database.CDBI.ER.deleteEntry category_CDBI_Description categoryColumnKey
   (categoryID . categoryKey)

--- Updates an existing `Category` entry by its key.
updateCategory :: Category -> Database.CDBI.Connection.DBAction ()
updateCategory = Database.CDBI.ER.updateEntry category_CDBI_Description

--- The ER description of the `Wine` entity.
wine_CDBI_Description :: Database.CDBI.Description.EntityDescription Wine
wine_CDBI_Description =
  Database.CDBI.Description.ED "Wine"
   [Database.CDBI.Connection.SQLTypeInt
   ,Database.CDBI.Connection.SQLTypeString
   ,Database.CDBI.Connection.SQLTypeString
   ,Database.CDBI.Connection.SQLTypeInt
   ,Database.CDBI.Connection.SQLTypeString
   ,Database.CDBI.Connection.SQLTypeInt
   ,Database.CDBI.Connection.SQLTypeInt]
   (\(Wine
       (WineID key)
       name
       region
       year
       price
       bottles
       (CategoryID categoryWineCategoryKey)) ->
     [Database.CDBI.Connection.SQLInt key
     ,Database.CDBI.Connection.SQLString name
     ,Database.CDBI.Connection.SQLString region
     ,Database.CDBI.Connection.SQLInt year
     ,Database.CDBI.Connection.SQLString price
     ,Database.CDBI.Connection.SQLInt bottles
     ,Database.CDBI.Connection.SQLInt categoryWineCategoryKey])
   (\(Wine
       _ name region year price bottles (CategoryID categoryWineCategoryKey)) ->
     [Database.CDBI.Connection.SQLNull
     ,Database.CDBI.Connection.SQLString name
     ,Database.CDBI.Connection.SQLString region
     ,Database.CDBI.Connection.SQLInt year
     ,Database.CDBI.Connection.SQLString price
     ,Database.CDBI.Connection.SQLInt bottles
     ,Database.CDBI.Connection.SQLInt categoryWineCategoryKey])
   (\[Database.CDBI.Connection.SQLInt key
     ,Database.CDBI.Connection.SQLString name
     ,Database.CDBI.Connection.SQLString region
     ,Database.CDBI.Connection.SQLInt year
     ,Database.CDBI.Connection.SQLString price
     ,Database.CDBI.Connection.SQLInt bottles
     ,Database.CDBI.Connection.SQLInt categoryWineCategoryKey] ->
     Wine (WineID key) name region year price bottles
      (CategoryID categoryWineCategoryKey))

--- The database table of the `Wine` entity.
wineTable :: Database.CDBI.Description.Table
wineTable = "Wine"

--- The database column `Key` of the `Wine` entity.
wineColumnKey :: Database.CDBI.Description.Column WineID
wineColumnKey = Database.CDBI.Description.Column "\"Key\"" "\"Wine\".\"Key\""

--- The database column `Name` of the `Wine` entity.
wineColumnName :: Database.CDBI.Description.Column String
wineColumnName = Database.CDBI.Description.Column "\"Name\"" "\"Wine\".\"Name\""

--- The database column `Region` of the `Wine` entity.
wineColumnRegion :: Database.CDBI.Description.Column String
wineColumnRegion =
  Database.CDBI.Description.Column "\"Region\"" "\"Wine\".\"Region\""

--- The database column `Year` of the `Wine` entity.
wineColumnYear :: Database.CDBI.Description.Column Int
wineColumnYear = Database.CDBI.Description.Column "\"Year\"" "\"Wine\".\"Year\""

--- The database column `Price` of the `Wine` entity.
wineColumnPrice :: Database.CDBI.Description.Column String
wineColumnPrice =
  Database.CDBI.Description.Column "\"Price\"" "\"Wine\".\"Price\""

--- The database column `Bottles` of the `Wine` entity.
wineColumnBottles :: Database.CDBI.Description.Column Int
wineColumnBottles =
  Database.CDBI.Description.Column "\"Bottles\"" "\"Wine\".\"Bottles\""

--- The database column `CategoryWineCategoryKey` of the `Wine` entity.
wineColumnCategoryWineCategoryKey :: Database.CDBI.Description.Column CategoryID
wineColumnCategoryWineCategoryKey =
  Database.CDBI.Description.Column "\"CategoryWineCategoryKey\""
   "\"Wine\".\"CategoryWineCategoryKey\""

--- The description of the database column `Key` of the `Wine` entity.
wineKeyColDesc :: Database.CDBI.Description.ColumnDescription WineID
wineKeyColDesc =
  Database.CDBI.Description.ColDesc "\"Wine\".\"Key\""
   Database.CDBI.Connection.SQLTypeInt
   (\(WineID key) -> Database.CDBI.Connection.SQLInt key)
   (\(Database.CDBI.Connection.SQLInt key) -> WineID key)

--- The description of the database column `Name` of the `Wine` entity.
wineNameColDesc :: Database.CDBI.Description.ColumnDescription String
wineNameColDesc =
  Database.CDBI.Description.ColDesc "\"Wine\".\"Name\""
   Database.CDBI.Connection.SQLTypeString
   (\name -> Database.CDBI.Connection.SQLString name)
   (\(Database.CDBI.Connection.SQLString name) -> name)

--- The description of the database column `Region` of the `Wine` entity.
wineRegionColDesc :: Database.CDBI.Description.ColumnDescription String
wineRegionColDesc =
  Database.CDBI.Description.ColDesc "\"Wine\".\"Region\""
   Database.CDBI.Connection.SQLTypeString
   (\region -> Database.CDBI.Connection.SQLString region)
   (\(Database.CDBI.Connection.SQLString region) -> region)

--- The description of the database column `Year` of the `Wine` entity.
wineYearColDesc :: Database.CDBI.Description.ColumnDescription Int
wineYearColDesc =
  Database.CDBI.Description.ColDesc "\"Wine\".\"Year\""
   Database.CDBI.Connection.SQLTypeInt
   (\year -> Database.CDBI.Connection.SQLInt year)
   (\(Database.CDBI.Connection.SQLInt year) -> year)

--- The description of the database column `Price` of the `Wine` entity.
winePriceColDesc :: Database.CDBI.Description.ColumnDescription String
winePriceColDesc =
  Database.CDBI.Description.ColDesc "\"Wine\".\"Price\""
   Database.CDBI.Connection.SQLTypeString
   (\price -> Database.CDBI.Connection.SQLString price)
   (\(Database.CDBI.Connection.SQLString price) -> price)

--- The description of the database column `Bottles` of the `Wine` entity.
wineBottlesColDesc :: Database.CDBI.Description.ColumnDescription Int
wineBottlesColDesc =
  Database.CDBI.Description.ColDesc "\"Wine\".\"Bottles\""
   Database.CDBI.Connection.SQLTypeInt
   (\bottles -> Database.CDBI.Connection.SQLInt bottles)
   (\(Database.CDBI.Connection.SQLInt bottles) -> bottles)

--- The description of the database column `CategoryWineCategoryKey` of the `Wine` entity.
wineCategoryWineCategoryKeyColDesc
  :: Database.CDBI.Description.ColumnDescription CategoryID
wineCategoryWineCategoryKeyColDesc =
  Database.CDBI.Description.ColDesc "\"Wine\".\"CategoryWineCategoryKey\""
   Database.CDBI.Connection.SQLTypeInt
   (\(CategoryID categoryWineCategoryKey) ->
     Database.CDBI.Connection.SQLInt categoryWineCategoryKey)
   (\(Database.CDBI.Connection.SQLInt categoryWineCategoryKey) ->
     CategoryID categoryWineCategoryKey)

--- Gets the attribute `Key` of the `Wine` entity.
wineKey :: Wine -> WineID
wineKey (Wine a _ _ _ _ _ _) = a

--- Gets the attribute `Name` of the `Wine` entity.
wineName :: Wine -> String
wineName (Wine _ a _ _ _ _ _) = a

--- Gets the attribute `Region` of the `Wine` entity.
wineRegion :: Wine -> String
wineRegion (Wine _ _ a _ _ _ _) = a

--- Gets the attribute `Year` of the `Wine` entity.
wineYear :: Wine -> Int
wineYear (Wine _ _ _ a _ _ _) = a

--- Gets the attribute `Price` of the `Wine` entity.
winePrice :: Wine -> String
winePrice (Wine _ _ _ _ a _ _) = a

--- Gets the attribute `Bottles` of the `Wine` entity.
wineBottles :: Wine -> Int
wineBottles (Wine _ _ _ _ _ a _) = a

--- Gets the attribute `CategoryWineCategoryKey` of the `Wine` entity.
wineCategoryWineCategoryKey :: Wine -> CategoryID
wineCategoryWineCategoryKey (Wine _ _ _ _ _ _ a) = a

--- Sets the attribute `Key` of the `Wine` entity.
setWineKey :: Wine -> WineID -> Wine
setWineKey (Wine _ b6 b5 b4 b3 b2 b1) a = Wine a b6 b5 b4 b3 b2 b1

--- Sets the attribute `Name` of the `Wine` entity.
setWineName :: Wine -> String -> Wine
setWineName (Wine a2 _ b5 b4 b3 b2 b1) a = Wine a2 a b5 b4 b3 b2 b1

--- Sets the attribute `Region` of the `Wine` entity.
setWineRegion :: Wine -> String -> Wine
setWineRegion (Wine a3 a2 _ b4 b3 b2 b1) a = Wine a3 a2 a b4 b3 b2 b1

--- Sets the attribute `Year` of the `Wine` entity.
setWineYear :: Wine -> Int -> Wine
setWineYear (Wine a4 a3 a2 _ b3 b2 b1) a = Wine a4 a3 a2 a b3 b2 b1

--- Sets the attribute `Price` of the `Wine` entity.
setWinePrice :: Wine -> String -> Wine
setWinePrice (Wine a5 a4 a3 a2 _ b2 b1) a = Wine a5 a4 a3 a2 a b2 b1

--- Sets the attribute `Bottles` of the `Wine` entity.
setWineBottles :: Wine -> Int -> Wine
setWineBottles (Wine a6 a5 a4 a3 a2 _ b1) a = Wine a6 a5 a4 a3 a2 a b1

--- Sets the attribute `CategoryWineCategoryKey` of the `Wine` entity.
setWineCategoryWineCategoryKey :: Wine -> CategoryID -> Wine
setWineCategoryWineCategoryKey (Wine a7 a6 a5 a4 a3 a2 _) a =
  Wine a7 a6 a5 a4 a3 a2 a

--- id-to-value function for entity `Wine`.
wineID :: WineID -> Database.CDBI.Criteria.Value WineID
wineID (WineID key) = Database.CDBI.Criteria.idVal key

--- id-to-int function for entity `Wine`.
wineKeyToInt :: WineID -> Int
wineKeyToInt (WineID key) = key

--- Shows the key of a `Wine` entity as a string.
--- This is useful if a textual representation of the key is necessary
--- (e.g., as URL parameters in web pages), but it should no be used
--- to store keys in other attributes!
showWineKey :: Wine -> String
showWineKey entry =
  Database.CDBI.ER.showDatabaseKey "Wine" wineKeyToInt (wineKey entry)

--- Transforms a string into a key of a `Wine` entity.
--- Nothing is returned if the string does not represent a meaningful key.
readWineKey :: String -> Maybe WineID
readWineKey = Database.CDBI.ER.readDatabaseKey "Wine" WineID

--- Gets all `Wine` entities.
queryAllWines :: Database.CDBI.Connection.DBAction [Wine]
queryAllWines = Database.CDBI.ER.getAllEntries wine_CDBI_Description

--- Gets all `Wine` entities satisfying a given predicate.
queryCondWine :: (Wine -> Bool) -> Database.CDBI.Connection.DBAction [Wine]
queryCondWine = Database.CDBI.ER.getCondEntries wine_CDBI_Description

--- Gets a `Wine` entry by a given key.
getWine :: WineID -> Database.CDBI.Connection.DBAction Wine
getWine =
  Database.CDBI.ER.getEntryWithKey wine_CDBI_Description wineColumnKey wineID

--- Inserts a new `Wine` entity.
newWineWithCategoryWineCategoryKey
  :: String
  -> String
  -> Int
  -> String -> Int -> CategoryID -> Database.CDBI.Connection.DBAction Wine
newWineWithCategoryWineCategoryKey
    name_p region_p year_p price_p bottles_p categoryWineCategoryKey_p =
  Database.CDBI.ER.insertNewEntry wine_CDBI_Description setWineKey WineID
   (Wine (WineID 0) name_p region_p year_p price_p bottles_p
     categoryWineCategoryKey_p)

--- Deletes an existing `Wine` entry by its key.
deleteWine :: Wine -> Database.CDBI.Connection.DBAction ()
deleteWine =
  Database.CDBI.ER.deleteEntry wine_CDBI_Description wineColumnKey
   (wineID . wineKey)

--- Updates an existing `Wine` entry by its key.
updateWine :: Wine -> Database.CDBI.Connection.DBAction ()
updateWine = Database.CDBI.ER.updateEntry wine_CDBI_Description

--- Saves complete database as term files into an existing directory
--- provided as a parameter.
saveDBTo :: String -> IO ()
saveDBTo dir =
  do Database.CDBI.ER.saveDBTerms category_CDBI_Description sqliteDBFile dir
     Database.CDBI.ER.saveDBTerms wine_CDBI_Description sqliteDBFile dir

--- Restores complete database from term files which are stored
--- in a directory provided as a parameter.
restoreDBFrom :: String -> IO ()
restoreDBFrom dir =
  do Database.CDBI.ER.restoreDBTerms category_CDBI_Description sqliteDBFile dir
     Database.CDBI.ER.restoreDBTerms wine_CDBI_Description sqliteDBFile dir

--- Runs a DB action (typically a query).
runQ :: Database.CDBI.Connection.DBAction a -> IO a
runQ = Database.CDBI.ER.runQueryOnDB sqliteDBFile

--- Runs a DB action as a transaction.
runT
  :: Database.CDBI.Connection.DBAction a
  -> IO (Database.CDBI.Connection.SQLResult a)
runT = Database.CDBI.ER.runTransactionOnDB sqliteDBFile

--- Runs a DB action as a transaction. Emits an error in case of failure.
runJustT :: Database.CDBI.Connection.DBAction a -> IO a
runJustT = Database.CDBI.ER.runJustTransactionOnDB sqliteDBFile

------------------------------------------------------------------------------
--- Saves complete database as term files into storage directory.
saveDB :: IO ()
saveDB = saveDBTo wineDataDir

--- Restores complete database from term files in storage directory.
restoreDB :: IO ()
restoreDB = restoreDBFrom wineDataDir

