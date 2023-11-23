module System.AuthorizedActions where

import System.Authorization
import System.Authentication
import System.SessionInfo
import Model.Wine

anyOperationAllowed :: AccessType _ -> UserSessionInfo -> IO AccessResult
anyOperationAllowed at sinfo = return $
  case at of
    ListEntities -> AccessGranted
    _            -> if isAdminSession sinfo
                      then AccessGranted
                      else AccessDenied "Operation not allowed!"

--- Checks whether the application of an operation to a Category
--- entity is allowed.
categoryOperationAllowed :: AccessType Category -> UserSessionInfo
                         -> IO AccessResult
categoryOperationAllowed = anyOperationAllowed

--- Checks whether the application of an operation to a Wine
--- entity is allowed.
wineOperationAllowed :: AccessType Wine -> UserSessionInfo -> IO AccessResult
wineOperationAllowed = anyOperationAllowed
