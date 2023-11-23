-- Some global settings for the wine manager
module Config.Globals where

import System.FilePath ( (</>) )

-- The directory containing all wine data:
wineDataDir :: String
--wineDataDir = "/net/medoc/home/mh/home/data/wine"
wineDataDir = "../wineData"

-- Standard login name
defaultLoginName :: String
defaultLoginName = "sommelier"

-- File containing hash code of default login
defaultHashFile :: String
defaultHashFile = wineDataDir </> ".winelogin"
