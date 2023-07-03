---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the UserManagement_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_UserManagement'

-- Timer to notify all relevant events on-resume
local tmrUserManagement = Timer.create()
tmrUserManagement:setExpirationTime(300)
tmrUserManagement:setPeriodic(false)

-- Timer to hide message after a while
local tmrQuitMessage = Timer.create()
tmrQuitMessage:setExpirationTime(2000)
tmrQuitMessage:setPeriodic(false)

-- Reference to global handle
local userManagement_Model

-- ************************ UI Events Start ********************************

Script.serveEvent("CSK_UserManagement.OnNewUserToLogIn", "UserManagement_OnNewUserToLogIn")
Script.serveEvent("CSK_UserManagement.OnNewLogInPassword", "UserManagement_OnNewLogInPassword")
Script.serveEvent("CSK_UserManagement.OnNewLoggedInUser", "UserManagement_OnNewLoggedInUser")
Script.serveEvent("CSK_UserManagement.OnNewHideWrongPassword", "UserManagement_OnNewHideWrongPassword")

Script.serveEvent("CSK_UserManagement.OnUserLevelAdminActive", "UserManagement_OnUserLevelAdminActive")
Script.serveEvent("CSK_UserManagement.OnUserLevelOperatorActive", "UserManagement_OnUserLevelOperatorActive")
Script.serveEvent("CSK_UserManagement.OnUserLevelMaintenanceActive", "UserManagement_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_UserManagement.OnUserLevelServiceActive", "UserManagement_OnUserLevelServiceActive")

Script.serveEvent("CSK_UserManagement.OnNewUserList", "UserManagement_OnNewUserList")
Script.serveEvent("CSK_UserManagement.OnNewUserTableList", "UserManagement_OnNewUserTableList")

Script.serveEvent("CSK_UserManagement.OnNewUserToUpdate", "UserManagement_OnNewUserToUpdate")
Script.serveEvent("CSK_UserManagement.OnNewPasswordToUpdate", "UserManagement_OnNewPasswordToUpdate")
Script.serveEvent("CSK_UserManagement.OnNewHidePasswordInfo", "UserManagement_OnNewHidePasswordInfo")

Script.serveEvent("CSK_UserManagement.OnNewUserLevelToUpdate", "UserManagement_OnNewUserLevelToUpdate")

Script.serveEvent("CSK_UserManagement.OnNewStatusLoadParameterOnReboot", "UserManagement_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_UserManagement.OnPersistentDataModuleAvailable", "UserManagement_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_UserManagement.OnNewParameterName", "UserManagement_OnNewParameterName")
Script.serveEvent("CSK_UserManagement.OnDataLoadedOnReboot", "UserManagement_OnDataLoadedOnReboot")

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to get access to the userManagement_Model object
---@param handle handle Handle of userManagement_Model object
local function setUserManagement_Model_Handle(handle)
  userManagement_Model = handle
  Script.releaseObject(handle)
end

--- Function to hide messages after a while
local function handleOnExpired()
  Script.notifyEvent("UserManagement_OnNewHidePasswordInfo", true)
  Script.notifyEvent("UserManagement_OnNewHideWrongPassword", true)
end
Timer.register(tmrQuitMessage, 'OnExpired', handleOnExpired)

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrUserManagement()
  if not Timer.isRunning(tmrQuitMessage) then
    Script.notifyEvent("UserManagement_OnNewHidePasswordInfo", true)
    Script.notifyEvent("UserManagement_OnNewHideWrongPassword", true)
  end

  userManagement_Model.loginPassword = ''
  userManagement_Model.selectedUserToUpdate = nil
  userManagement_Model.newUsernameToAdd = ''
  userManagement_Model.newPassword = ''

  Script.notifyEvent("UserManagement_OnNewLogInPassword", '')

  if userManagement_Model.activeUser then
    Script.notifyEvent("UserManagement_OnNewLoggedInUser", 'Current logged in user = ' .. userManagement_Model.activeUser)

    if userManagement_Model.parameters.userLevel[userManagement_Model.activeUser] == 'Admin' then
      Script.notifyEvent("UserManagement_OnUserLevelAdminActive", true)
      Script.notifyEvent("UserManagement_OnUserLevelServiceActive", true)
      Script.notifyEvent("UserManagement_OnUserLevelMaintenanceActive", true)
      Script.notifyEvent("UserManagement_OnUserLevelOperatorActive", true)

      Script.notifyEvent("UserManagement_OnNewUserToUpdate", 'none')
      Script.notifyEvent("UserManagement_OnNewPasswordToUpdate", '')
      Script.notifyEvent("UserManagement_OnNewUserLevelToUpdate", 'Operator')

      Script.notifyEvent("UserManagement_OnNewUserTableList", userManagement_Model.helperFuncs.createJsonList(userManagement_Model.parameters.users))

    elseif userManagement_Model.parameters.userLevel[userManagement_Model.activeUser] == 'Service' then
      Script.notifyEvent("UserManagement_OnUserLevelAdminActive", false)
      Script.notifyEvent("UserManagement_OnUserLevelServiceActive", true)
      Script.notifyEvent("UserManagement_OnUserLevelMaintenanceActive", true)
      Script.notifyEvent("UserManagement_OnUserLevelOperatorActive", true)

    elseif userManagement_Model.parameters.userLevel[userManagement_Model.activeUser] == 'Maintenance' then
      Script.notifyEvent("UserManagement_OnUserLevelAdminActive", false)
      Script.notifyEvent("UserManagement_OnUserLevelServiceActive", false)
      Script.notifyEvent("UserManagement_OnUserLevelMaintenanceActive", true)
      Script.notifyEvent("UserManagement_OnUserLevelOperatorActive", true)

    elseif  userManagement_Model.parameters.userLevel[userManagement_Model.activeUser] == 'Operator' then
      Script.notifyEvent("UserManagement_OnUserLevelAdminActive", false)
      Script.notifyEvent("UserManagement_OnUserLevelServiceActive", false)
      Script.notifyEvent("UserManagement_OnUserLevelMaintenanceActive", false)
      Script.notifyEvent("UserManagement_OnUserLevelOperatorActive", true)
    end

  else
    Script.notifyEvent("UserManagement_OnNewLoggedInUser", 'No user is currently logged in.')
    Script.notifyEvent("UserManagement_OnUserLevelAdminActive", false)
    Script.notifyEvent("UserManagement_OnUserLevelServiceActive", false)
    Script.notifyEvent("UserManagement_OnUserLevelMaintenanceActive", false)
    Script.notifyEvent("UserManagement_OnUserLevelOperatorActive", false)
  end

  Script.notifyEvent("UserManagement_OnNewUserList", userManagement_Model.helperFuncs.createStringListBySimpleTable(userManagement_Model.parameters.users))
  Script.notifyEvent("UserManagement_OnNewUserToLogIn", userManagement_Model.selectedUser)

  Script.notifyEvent("UserManagement_OnNewStatusLoadParameterOnReboot", userManagement_Model.parameterLoadOnReboot)
  Script.notifyEvent("UserManagement_OnPersistentDataModuleAvailable", userManagement_Model.persistentModuleAvailable)
  Script.notifyEvent("UserManagement_OnNewParameterName", userManagement_Model.parametersName)

end
Timer.register(tmrUserManagement, "OnExpired", handleOnExpiredTmrUserManagement)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  tmrUserManagement:start()
  return ''
end
Script.serveFunction("CSK_UserManagement.pageCalled", pageCalled)

local function setLoginUser(user)
  _G.logger:info(nameOfModule .. ": Set login user = " .. tostring(user))
  userManagement_Model.selectedUser = user
end
Script.serveFunction("CSK_UserManagement.setLoginUser", setLoginUser)

local function setLoginPassword(password)
  _G.logger:info(nameOfModule .. ": Set password.")
  userManagement_Model.loginPassword = Cipher.AES.encrypt(password, userManagement_Model.key)
end
Script.serveFunction("CSK_UserManagement.setLoginPassword", setLoginPassword)

local function login()
  if Cipher.AES.decrypt(userManagement_Model.loginPassword, userManagement_Model.key) == Cipher.AES.decrypt(userManagement_Model.parameters.passwords[userManagement_Model.selectedUser], userManagement_Model.key) then
    _G.logger:info(nameOfModule .. ": LogIn user = " .. userManagement_Model.selectedUser)
    userManagement_Model.activeUser = userManagement_Model.selectedUser
  else
    Script.notifyEvent("UserManagement_OnNewHideWrongPassword", false)
    tmrQuitMessage:start()
    _G.logger:info(nameOfModule .. ": Wrong password for user = " .. userManagement_Model.selectedUser)
    Script.sleep(10)
  end
  handleOnExpiredTmrUserManagement()

end
Script.serveFunction("CSK_UserManagement.login", login)

local function logout()
  if userManagement_Model.activeUser ~= nil then
    _G.logger:info(nameOfModule .. ": Logout of user " .. userManagement_Model.activeUser)
    userManagement_Model.activeUser = nil
    handleOnExpiredTmrUserManagement()
  else
    _G.logger:info(nameOfModule .. ": No active user to logout.")
  end
end
Script.serveFunction("CSK_UserManagement.logout", logout)

local function selectUserToUpdate(user)
  local userExists = false
  for i=1, #userManagement_Model.parameters.users do
    if userManagement_Model.parameters.users[i] == userManagement_Model.newUsernameToAdd then
      userManagement_Model.selectedUserToUpdate = user
      _G.logger:info(nameOfModule .. ": User ".. user .. " selected to update.")
      userExists = true
    end
  end

  if userExists then
    return true
  else
    _G.logger:info(nameOfModule .. ": User to update does not exist.")
    return false
  end
end
Script.serveFunction("CSK_UserManagement.selectUserToUpdate", selectUserToUpdate)

local function selectedUserViaTable(selection)

  if selection == "" then
    userManagement_Model.selectedUserToUpdate = nil
  else
    local _, pos = string.find(selection, '"User":"')
    if pos == nil then
      _G.logger:info(nameOfModule .. ": Did not find User")
      userManagement_Model.selectedUserToUpdate = nil
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      local foundUser = string.sub(selection, pos+1, endPos-1)
      userManagement_Model.selectedUserToUpdate = string.sub(selection, pos+1, endPos-1)
    end
  end
  _G.logger:info(nameOfModule .. ": Selected User = " .. userManagement_Model.selectedUserToUpdate)

  Script.notifyEvent("UserManagement_OnNewUserToUpdate", userManagement_Model.selectedUserToUpdate)
  Script.notifyEvent("UserManagement_OnNewUserLevelToUpdate", userManagement_Model.parameters.userLevel[userManagement_Model.selectedUserToUpdate])
  userManagement_Model.newPassword = ''
  Script.notifyEvent("UserManagement_OnNewPasswordToUpdate", '')

end
Script.serveFunction("CSK_UserManagement.selectedUserViaTable", selectedUserViaTable)

local function setNewUsername(name)
  _G.logger:info(nameOfModule .. ": Set new username: " .. tostring(name))
  userManagement_Model.newUsernameToAdd = name
end
Script.serveFunction("CSK_UserManagement.setNewUsername", setNewUsername)

local function addUser()
  local userExists = false
  for i=1, #userManagement_Model.parameters.users do
    if userManagement_Model.parameters.users[i] == userManagement_Model.newUsernameToAdd then
      _G.logger:info(nameOfModule .. ": Will not add new user: " .. userManagement_Model.newUsernameToAdd .. " already exists.")
      userExists = true
      return
    end
  end
  if not userExists then
    _G.logger:info(nameOfModule .. ": Add new user: " .. userManagement_Model.newUsernameToAdd)
    table.insert(userManagement_Model.parameters.users, userManagement_Model.newUsernameToAdd)
    userManagement_Model.parameters.passwords[userManagement_Model.newUsernameToAdd] = Cipher.AES.encrypt('', userManagement_Model.key)
    userManagement_Model.parameters.userLevel[userManagement_Model.newUsernameToAdd] = 'Operator'
    selectUserToUpdate(userManagement_Model.newUsernameToAdd)
  end

  handleOnExpiredTmrUserManagement()

end
Script.serveFunction("CSK_UserManagement.addUser", addUser)

local function removeUser()
  for i=1, #userManagement_Model.parameters.users do
    if userManagement_Model.parameters.users[i] == userManagement_Model.selectedUserToUpdate then
      if userManagement_Model.parameters.users[i] ~= "Admin" then
        table.remove(userManagement_Model.parameters.users, i)
        userManagement_Model.parameters.passwords[userManagement_Model.selectedUserToUpdate] = nil
        userManagement_Model.parameters.userLevel[userManagement_Model.selectedUserToUpdate] = nil
        _G.logger:info(nameOfModule .. ": Removed user: " .. userManagement_Model.selectedUserToUpdate)
        break
      else
        _G.logger:info(nameOfModule .. ": Cannot remove user: Admin")
      end
    end
  end
  handleOnExpiredTmrUserManagement()
end
Script.serveFunction("CSK_UserManagement.removeUser", removeUser)

local function setNewPassword(password)
  local newPassword = Cipher.AES.encrypt(password, userManagement_Model.key)
  userManagement_Model.parameters.passwords[userManagement_Model.selectedUserToUpdate] = newPassword
  _G.logger:info(nameOfModule .. ": Set new password for user: " .. userManagement_Model.selectedUserToUpdate)
  Script.notifyEvent("UserManagement_OnNewHidePasswordInfo", false)
  tmrQuitMessage:start()
end
Script.serveFunction("CSK_UserManagement.setNewPassword", setNewPassword)

local function setNewUserLevel(level)
  if userManagement_Model.selectedUserToUpdate ~= 'admin' then
    userManagement_Model.parameters.userLevel[userManagement_Model.selectedUserToUpdate] = level
    _G.logger:info(nameOfModule .. ": Set new userLevel for user: " .. userManagement_Model.selectedUserToUpdate .. " to " .. level)
  else
    Script.notifyEvent("UserManagement_OnNewUserLevelToUpdate", 'Admin')
  end
end
Script.serveFunction("CSK_UserManagement.setNewUserLevel", setNewUserLevel)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  userManagement_Model.parametersName = name
  _G.logger:info(nameOfModule .. ": Set new parameter name: " .. tostring(name))
end
Script.serveFunction("CSK_UserManagement.setParameterName", setParameterName)

local function sendParameters()
  if userManagement_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(userManagement_Model.helperFuncs.convertTable2Container(userManagement_Model.parameters), userManagement_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, userManagement_Model.parametersName, userManagement_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send UserManagement parameters with name '" .. userManagement_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_UserManagement.sendParameters", sendParameters)

local function loadParameters()
  if userManagement_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(userManagement_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      userManagement_Model.parameters = userManagement_Model.helperFuncs.convertContainer2Table(data)
      CSK_UserManagement.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_UserManagement.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  userManagement_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_UserManagement.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    userManagement_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      userManagement_Model.parametersName = parameterName
      userManagement_Model.parameterLoadOnReboot = loadOnReboot
    end

    if userManagement_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('UserManagement_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

Script.register('CSK_PersistentData.OnNewUserManagementTrigger', handleOnExpiredTmrUserManagement)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setUserManagement_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

