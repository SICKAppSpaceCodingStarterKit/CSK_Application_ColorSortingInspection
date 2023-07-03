---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_ColorSortingInspection'

local colorSortingInspection_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
colorSortingInspection_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
colorSortingInspection_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
colorSortingInspection_Model.parametersName = nameOfModule .. '_Parameter' -- name of parameter dataset to be used for this module
colorSortingInspection_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the colorSortingInspection_Model interface and give access
-- to the colorSortingInspection_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setColorSortingInspection_ModelHandle = require('Application/ColorSortingInspection/ColorSortingInspection_Controller')
setColorSortingInspection_ModelHandle(colorSortingInspection_Model)

--Loading helper functions if needed
colorSortingInspection_Model.helperFuncs = require('Application/ColorSortingInspection/helper/funcs')

-- Create parameters / instances for this module
colorSortingInspection_Model.selectedInstance = 1 -- Currently selected instance
colorSortingInspection_Model.emulation = true -- Status if running just on emulator/SAE on PC or on AppSpace device

-- Get SIM type
colorSortingInspection_Model.typeName = Engine.getTypeName() -- Full device typename of current used device
colorSortingInspection_Model.firmware = Engine.getFirmwareVersion() -- Firmware version of current used device
colorSortingInspection_Model.deviceType = '' -- Reduced device typename of current used device
colorSortingInspection_Model.forwardFunctionsTCPIP = {} -- Table to hold functions to forward results via TCP/IP

if colorSortingInspection_Model.typeName == 'AppStudioEmulator' or colorSortingInspection_Model.typeName == 'SICK AppEngine' then
  colorSortingInspection_Model.deviceType = 'AppStudioEmulator'
  colorSortingInspection_Model.emulation = true
else
  colorSortingInspection_Model.deviceType = string.sub(colorSortingInspection_Model.typeName, 1, 7)
  colorSortingInspection_Model.emulation = false
end
_G.logger:info(nameOfModule .. ": Running system: " .. colorSortingInspection_Model.deviceType .. ' with firmware: ' .. colorSortingInspection_Model.firmware)

-- Parameters to be saved permanently if wanted
colorSortingInspection_Model.parameters = {}
colorSortingInspection_Model.parameters.resultOutputTCPIP = false

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************


--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return colorSortingInspection_Model
