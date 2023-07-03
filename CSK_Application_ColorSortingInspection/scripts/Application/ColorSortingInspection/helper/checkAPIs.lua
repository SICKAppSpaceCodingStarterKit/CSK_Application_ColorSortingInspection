---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

local function loadAPIs()
  CSK_ColorSortingInspection = require 'API.CSK_ColorSortingInspection'

  Container = require 'API.Container'
  DateTime = require 'API.DateTime'
  Engine = require 'API.Engine'
  File = require 'API.File'
  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'
  Monitor = {}
  Monitor.CPU = require 'API.Monitor.CPU'
  Monitor.Memory = require 'API.Monitor.Memory'
  Object = require 'API.Object'
  Parameters = require 'API.Parameters'
  Timer = require 'API.Timer'

  CSK_DateTime = require 'API.CSK_DateTime'
  CSK_DigitalIOManager = require 'API.CSK_DigitalIOManager'
  CSK_ImagePlayer = require 'API.CSK_ImagePlayer'
  CSK_Logger = require 'API.CSK_Logger'
  CSK_MultiColorSelection = require 'API.CSK_MultiColorSelection'
  CSK_MultiRemoteCamera = require 'API.CSK_MultiRemoteCamera'
  CSK_PersistentData = require 'API.CSK_PersistentData'
  CSK_PowerManager = require 'API.CSK_PowerManager'
  CSK_TCPIPClient = require 'API.CSK_TCPIPClient'
end

local function loadUM_API()
  CSK_UserManagement = require 'API.CSK_UserManagement'
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.UM = xpcall(loadUM_API, debug.traceback) -- TRUE if UserManagement APIs were loaded correctly

return availableAPIs
--**************************************************************************