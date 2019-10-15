--------------------------------------------------------------------------
--- This module implements the views related to the standard controllers
--- in a Spicey application.
--- In particular, it defines a default view for login
--- and a view of a list of user processes.
--------------------------------------------------------------------------

module View.SpiceySystem
  ( loginView, processListView, historyView )
 where

import HTML.Base
import HTML.Styles.Bootstrap3 (defaultButton, primButton)

import Config.Globals
import Config.UserProcesses
import System.Processes
import System.Spicey
import System.Authentication

-----------------------------------------------------------------------------
--- View for login/logout. If the passed login name is the empty string,
--- we offer a login dialog, otherwise a logout dialog.
loginView :: Controller -> Maybe String -> [HtmlExp]
loginView controller currlogin =
  case currlogin of
   Nothing -> [h3 [htxt "Manager password:"],
               password passwdfield,
               defaultButton "Login" loginHandler]
   Just _  -> [h3 [htxt "Really logout?"],
               primButton "Logout" (logoutHandler True),
               defaultButton "Cancel" (logoutHandler False)]
 where
  passwdfield free

  loginHandler env = do
    let loginname = defaultLoginName
        passwd = env passwdfield
    if null passwd
      then done
      else do hash <- getUserHash loginname passwd
              storedhash <- readFile defaultHashFile
              if hash==storedhash
                then do loginToSession loginname
                        setPageMessage ("Logged in as: "++loginname)
                else setPageMessage "Login failed: wrong password"
    nextInProcessOr controller Nothing >>= getPage
  
  logoutHandler confirm _ = do
    if confirm then logoutFromSession >> setPageMessage "Logged out"
               else done
    nextInProcessOr controller Nothing >>= getPage

-----------------------------------------------------------------------------
--- A view for all processes contained in a given process specification.
processListView :: Processes a -> [HtmlExp]
processListView procs =
  [h1 [htxt "Processes"],
   ulist (map processColumn (zip (processNames procs) [1..]))]
 where
   processColumn (pname, id) =
     [href ("?spiceyProcesses/"++show id) [htxt pname]]

-----------------------------------------------------------------------------
--- A view for all URLs of a session.
historyView :: [String] -> [HtmlExp]
historyView urls =
  [h1 [htxt "History"],
   ulist (map (\url -> [href ("?"++url) [htxt url]])
              (filter (not . null) urls))]

-----------------------------------------------------------------------------
