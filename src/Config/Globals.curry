-- Some global settings for the wine manager
module Config.Globals where

--- Location of the directory containing private run-time data
--- such as session and authentication information.
spiceyDataDir :: String
spiceyDataDir = "data"

-- The directory containing all wine data:
wineDataDir :: String
wineDataDir = "/net/medoc/home/mh/home/data/wine"

-- Standard login name
defaultLoginName :: String
defaultLoginName = "sommelier"

-- File containing hash code of default login
defaultHashFile :: String
defaultHashFile = wineDataDir ++ "/.winelogin"
