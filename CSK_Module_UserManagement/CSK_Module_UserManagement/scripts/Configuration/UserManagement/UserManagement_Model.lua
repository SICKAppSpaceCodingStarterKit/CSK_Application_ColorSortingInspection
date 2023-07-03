---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_UserManagement'

local userManagement_Model = {}

-- Check if CSK_PersistentData module can be used if wanted
userManagement_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
userManagement_Model.parametersName = 'CSK_UserManagement_Parameter' -- name of parameter dataset to be used for this module
userManagement_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the UserManagement_Model interface and give access
-- to the UserManagement_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setUserManagement_ModelHandle = require('Configuration/UserManagement/UserManagement_Controller')
setUserManagement_ModelHandle(userManagement_Model)

--Loading helper functions if needed
userManagement_Model.helperFuncs = require('Configuration/UserManagement/helper/funcs')

-- Create parameters / instances for this module
userManagement_Model.key = '1234567890123456' -- key to encrypt passwords, should be adapted!
userManagement_Model.selectedUser = nil -- selected user to login
userManagement_Model.loginPassword = nil -- latest password to loging
userManagement_Model.selectedUserToUpdate = nil -- selected user to update parameters
userManagement_Model.activeUser = nil -- current logged in user
userManagement_Model.newUsernameToAdd = '' -- username to add
userManagement_Model.newPassword = '' -- password to add
userManagement_Model.newUserLevel = '' -- UserLevel to set

-- Parameters to be saved permanently if wanted
userManagement_Model.parameters = {}
userManagement_Model.parameters.users = {} -- list of available users
table.insert(userManagement_Model.parameters.users, 'Admin')
userManagement_Model.selectedUser = userManagement_Model.parameters.users[1]

userManagement_Model.parameters.passwords = {} -- passwords of users (encrypted)
userManagement_Model.parameters.passwords['Admin'] = Cipher.AES.encrypt('admin', userManagement_Model.key)
userManagement_Model.parameters.userLevel = {} -- userlevel of users
userManagement_Model.parameters.userLevel['Admin'] = 'Admin'

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************


--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return userManagement_Model
