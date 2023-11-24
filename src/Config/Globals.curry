-- Some global settings for the wine manager
module Config.Globals where

import System.FilePath ( (</>) )

-- The directory containing all wine data:
wineDataDir :: String
--wineDataDir = "/net/medoc/home/mh/home/data/wine"
wineDataDir = "../wineData"

-- File containing the standard login name
defaultLoginFile :: String
defaultLoginFile = wineDataDir </> ".winelogin"

-- File containing hash code of default login
defaultHashFile :: String
defaultHashFile = wineDataDir </> ".winehash"
