--------------------------------------------------------------------------
--- This module implements the management of sessions.
--- In particular, it defines a cookie that must be sent to the client
--- in order to enable the handling of sessions.
--- Based on sessions, this module also defines a session store
--- that can be used by various parts of the application in order
--- to hold some session-specific data.
--------------------------------------------------------------------------

module HTML.Session
  ( sessionCookie, doesSessionExist, withSessionCookie, withSessionCookieInfo
  , SessionStore, emptySessionStore
  , getSessionMaybeData, getSessionData, putSessionData, removeSessionData
  , updateSessionData
  ) where

import Global
import List         ( findIndex, replace )
import Maybe        ( fromMaybe )
import Time         ( ClockTime, addMinutes, clockTimeToInt, getClockTime )

import HTML.Base
import Crypto.Hash  ( randomString )

import Config.Storage

--- Prefix a file name with the directory where session data,
--- e.g., cookie information, is stored during run time.
--- As a default, it is the CGI execution directory but this should
--- be adapted to a non-public readable directory for security reasons.
--inDataDir :: String -> String
--inDataDir filename = filename

--- The life span in minutes to store data in sessions.
--- Thus, older data is deleted by a clean up that is initiated
--- whenever new data is stored in a session.
sessionLifespan :: Int
sessionLifespan = 60

--- The name of the persistent global where the last session id is stored.
sessionCookieName :: String
sessionCookieName = "currySessionId"

--- This global value saves time and last session id.
lastId :: Global (Int, Int)
lastId = global (0, 0) (Persistent (inDataDir sessionCookieName))


--- The abstract type to represent session identifiers.
data SessionId = SessionId String
 deriving Eq

getId :: SessionId -> String
getId (SessionId i) = i

--- Creates a new unused session id.
getUnusedId :: IO SessionId
getUnusedId = do
  (ltime,lsid) <- safeReadGlobal lastId (0,0)
  clockTime <- getClockTime
  if clockTimeToInt clockTime /= ltime
    then writeGlobal lastId (clockTimeToInt clockTime, 0)
    else writeGlobal lastId (clockTimeToInt clockTime, lsid+1)
  rans <- randomString 30
  return (SessionId (show (clockTimeToInt clockTime) ++ show (lsid+1) ++ rans))

--- Checks whether the current user session is initialized,
--- i.e., whether a session cookie has been already set.
doesSessionExist :: IO Bool
doesSessionExist = do
    cookies <- getCookies
    return $ maybe False (const True) (lookup sessionCookieName cookies)

--- Gets the id of the current user session.
--- If this is a new session, a new id is created and returned.
getSessionId :: IO SessionId
getSessionId = do
    cookies <- getCookies
    case (lookup sessionCookieName cookies) of
      Just sessionCookieValue -> return (SessionId sessionCookieValue)
      Nothing                 -> getUnusedId

--- Creates a cookie to hold the current session id.
--- This cookie should be sent to the client together with every HTML page.
sessionCookie :: IO PageParam
sessionCookie = do
  sessionId <- getSessionId
  clockTime <- getClockTime
  return (PageCookie sessionCookieName (getId (sessionId))
                     [CookiePath "/",
                      CookieExpire (addMinutes sessionLifespan clockTime)])

--- Decorates an HTML page with session cookie.
withSessionCookie :: HtmlPage -> IO HtmlPage
withSessionCookie p = do
  cookie <- sessionCookie
  return $ (p `addPageParam` cookie)

--- Decorates an HTML page with session cookie and shows an information
--- page when the session cookie is not set.
withSessionCookieInfo :: HtmlPage -> IO HtmlPage
withSessionCookieInfo p = do
  hassession <- doesSessionExist
  if hassession
    then do cookie <- sessionCookie
            return $ (p `addPageParam` cookie)
    else cookieInfoPage

-- Returns HTML page with information about the use of cookies.
cookieInfoPage :: IO HtmlPage
cookieInfoPage = do
  urlparam <- getUrlParameter
  withSessionCookie $ standardPage "Cookie Info"
    [ par [ htxt "This web site uses cookies for navigation and user inputs." ]
    , par [ htxt "In order to proceed, please click "
          , bold [href ('?' : urlparam) [htxt "here"]], htxt "." ] ]

----------------------------------------------------------------------------
-- Implementation of session stores.

--- The type of a session store that holds particular data used in a session.
--- A session store consists of a list of data items for each session in the
--- system together with the clock time of the last access.
--- The clock time is used to remove old data in the store.
data SessionStore a = SessionStore [(SessionId, Int, a)]

--- An initial value for the empty session store.
emptySessionStore :: SessionStore _
emptySessionStore = SessionStore []

--- Retrieves data for the current user session stored in a session store.
--- Returns `Nothing` if there is no data for the current session.
getSessionMaybeData :: Global (SessionStore a) -> IO (Maybe a)
getSessionMaybeData sessionData = do
    sid <- getSessionId
    SessionStore sdata <- safeReadGlobal sessionData emptySessionStore
    return (findInSession sid sdata)
  where
    findInSession si ((id, _, storedData):rest) =
      if getId id == getId si
        then Just storedData
        else findInSession si rest
    findInSession _ [] = Nothing
      
--- Retrieves data for the current user session stored in a session store
--- where the second argument is returned if there is no data
--- for the current session.
getSessionData :: Global (SessionStore a) -> a -> IO a
getSessionData sessionData defaultdata =
  getSessionMaybeData sessionData >>= return . fromMaybe defaultdata

--- Stores data related to the current user session in a session store.
putSessionData :: Global (SessionStore a) -> a -> IO ()
putSessionData sessionData newData = do
  sid <- getSessionId
  SessionStore sdata <- safeReadGlobal sessionData emptySessionStore
  currentTime <- getClockTime
  case findIndex (\ (id, _, _) -> id == sid) sdata of
    Just i ->
      writeGlobal sessionData
        (SessionStore (replace (sid, clockTimeToInt currentTime, newData) i
                               (cleanup currentTime sdata)))
    Nothing ->
      writeGlobal sessionData
                  (SessionStore ((sid, clockTimeToInt currentTime, newData)
                                  : cleanup currentTime sdata))

--- Updates the data of the current user session.
updateSessionData :: Global (SessionStore a) -> a -> (a -> a) -> IO ()
updateSessionData sessiondata defaultdata upd = do
  sd <- getSessionData sessiondata defaultdata
  putSessionData sessiondata (upd sd)

--- Removes data related to the current user session from a session store.
removeSessionData :: Global (SessionStore a) -> IO ()
removeSessionData sessionData = do
  sid <- getSessionId
  SessionStore sdata <- safeReadGlobal sessionData emptySessionStore
  currentTime <- getClockTime
  writeGlobal sessionData
              (SessionStore (filter (\ (id, _, _) -> id /= sid)
                                    (cleanup currentTime sdata)))

-- expects that clockTimeToInt converts time into ascending integers!
-- we should write our own conversion-function
cleanup :: ClockTime -> [(SessionId, Int, a)] -> [(SessionId, Int, a)]
cleanup currentTime sessionData =
  filter (\ (_, time, _) ->
            time > clockTimeToInt (addMinutes (0-sessionLifespan) currentTime))
         sessionData

--------------------------------------------------------------------------
