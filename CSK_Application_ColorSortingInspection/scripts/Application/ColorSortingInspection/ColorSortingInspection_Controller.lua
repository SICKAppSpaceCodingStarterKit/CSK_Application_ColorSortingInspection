---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the ColorSortingInspection_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_ColorSortingInspection'

-- Timer to update UI via events after page was loaded
local tmrColorSortingInspection = Timer.create()
tmrColorSortingInspection:setExpirationTime(300)
tmrColorSortingInspection:setPeriodic(false)

local cpuMonitor = Monitor.CPU.create() -- For debugging
local ramMonitor = Monitor.Memory.create() -- For debugging

-- Reference to global handle
local colorSortingInspection_Model

-- ************************ UI Events Start ********************************

Script.serveEvent("CSK_ColorSortingInspection.OnNewDeviceType", "ColorSortingInspection_OnNewDeviceType")
Script.serveEvent("CSK_ColorSortingInspection.OnNewOfflineImageMode", "ColorSortingInspection_OnNewOfflineImageMode")
Script.serveEvent("CSK_ColorSortingInspection.OnNewStatusResultOutputTCPIP", "ColorSortingInspection_OnNewStatusResultOutputTCPIP")

Script.serveEvent("CSK_ColorSortingInspection.OnNewParameterName", "ColorSortingInspection_OnNewParameterName")
Script.serveEvent("CSK_ColorSortingInspection.OnNewStatusLoadParameterOnReboot", "ColorSortingInspection_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_ColorSortingInspection.OnPersistentDataModuleAvailable", "ColorSortingInspection_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_ColorSortingInspection.OnDataLoadedOnReboot", "ColorSortingInspection_OnDataLoadedOnReboot")

Script.serveEvent('CSK_ColorSortingInspection.OnUserLevelOperatorActive', 'ColorSortingInspection_OnUserLevelOperatorActive')
Script.serveEvent('CSK_ColorSortingInspection.OnUserLevelMaintenanceActive', 'ColorSortingInspection_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_ColorSortingInspection.OnUserLevelServiceActive', 'ColorSortingInspection_OnUserLevelServiceActive')
Script.serveEvent('CSK_ColorSortingInspection.OnUserLevelAdminActive', 'ColorSortingInspection_OnUserLevelAdminActive')

Script.serveEvent('CSK_ColorSortingInspection.OnNewStatusSetupHardware', 'ColorSortingInspection_OnNewStatusSetupHardware')

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("ColorSortingInspection_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("ColorSortingInspection_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("ColorSortingInspection_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("ColorSortingInspection_OnUserLevelAdminActive", status)
end

--- Function to get access to the colorSortingInspection_Model object
---@param handle handle Handle of colorSortingInspection_Model object
local function setColorSortingInspection_Model_Handle(handle)
  colorSortingInspection_Model = handle
  if colorSortingInspection_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user level, e.g. for UI
local function updateUserLevel()
  if colorSortingInspection_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("ColorSortingInspection_OnUserLevelAdminActive", true)
    Script.notifyEvent("ColorSortingInspection_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("ColorSortingInspection_OnUserLevelServiceActive", true)
    Script.notifyEvent("ColorSortingInspection_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrColorSortingInspection()

  updateUserLevel()

  Script.notifyEvent("ColorSortingInspection_OnNewParameterName", colorSortingInspection_Model.parametersName)

  Script.notifyEvent("ColorSortingInspection_OnNewDeviceType", colorSortingInspection_Model.deviceType)
  Script.notifyEvent("ColorSortingInspection_OnNewStatusResultOutputTCPIP", colorSortingInspection_Model.parameters.resultOutputTCPIP)

  Script.notifyEvent("ColorSortingInspection_OnNewStatusLoadParameterOnReboot", colorSortingInspection_Model.parameterLoadOnReboot)
  Script.notifyEvent("ColorSortingInspection_OnPersistentDataModuleAvailable", colorSortingInspection_Model.persistentModuleAvailable)
  Script.notifyEvent("ColorSortingInspection_OnNewParameterName", colorSortingInspection_Model.parametersName)

  Script.notifyEvent("ColorSortingInspection_OnNewStatusSetupHardware", false)

  CSK_MultiColorSelection.pageCalled() -- Update parameters of CSK_MultiColorSelection UI
  CSK_MultiRemoteCamera.pageCalled() -- Update parameters of CSK_MultiRemoteCamera UI
  CSK_MultiColorSelection.setSelectedStep('5') -- per default set to '5' so that images are processed

end
Timer.register(tmrColorSortingInspection, "OnExpired", handleOnExpiredTmrColorSortingInspection)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  tmrColorSortingInspection:start()
  return ''
end
Script.serveFunction("CSK_ColorSortingInspection.pageCalled", pageCalled)

local function setResultOutputViaTCPIP(status)
  colorSortingInspection_Model.parameters.resultOutputTCPIP = status
  if status then

    for i=1, CSK_MultiColorSelection.getInstancesAmount() do
      if colorSortingInspection_Model.forwardFunctionsTCPIP[i] then
        Script.deregister("CSK_MultiColorSelection.OnNewResult"..tostring(i), colorSortingInspection_Model.forwardFunctionsTCPIP[i])
      end

      -- Internal function to send data via TCP with info of instance
      local function handleOnNewResult(inst, result, subResults, timestamp)
        if subResults then
          CSK_TCPIPClient.sendDataViaTCPIP(inst .. ',' .. tostring(result) .. ',' .. subResults)
        else
          CSK_TCPIPClient.sendDataViaTCPIP(inst .. ',' .. tostring(result))
        end
      end

      -- Internal function to hand over data from event
      local function forwardData(res, subRes, tmstmp)
        handleOnNewResult(tostring(i), res, subRes, tmstmp)
      end
      colorSortingInspection_Model.forwardFunctionsTCPIP[i] = forwardData

      Script.register("CSK_MultiColorSelection.OnNewResult"..tostring(i), colorSortingInspection_Model.forwardFunctionsTCPIP[i])
    end
  else
    for i=1, CSK_MultiColorSelection.getInstancesAmount() do
      if colorSortingInspection_Model.forwardFunctionsTCPIP[i] then
        Script.deregister("CSK_MultiColorSelection.OnNewResult"..tostring(i), colorSortingInspection_Model.forwardFunctionsTCPIP[i])
      end
    end
  end
end
Script.serveFunction("CSK_ColorSortingInspection.setResultOutputViaTCPIP", setResultOutputViaTCPIP)

local function registerToOfflineImagePlayer()
  CSK_MultiColorSelection.setRegisterEvent('CSK_ImagePlayer.OnNewImage')
end
Script.serveFunction('CSK_ColorSortingInspection.registerToOfflineImagePlayer', registerToOfflineImagePlayer)

local function registerToRemoteCamera()
  CSK_MultiColorSelection.setRegisterEvent('CSK_MultiRemoteCamera.OnNewImageCamera1')
end
Script.serveFunction('CSK_ColorSortingInspection.registerToRemoteCamera', registerToRemoteCamera)

--- Function to listen for "TRG" commando via TCPIP communication to trigger new SW image
---@param data string Handle of logger_Model object
local function handleOnNewDataReceived(data)

  -- Check if cmd includes parameters seperated by a ','
  local _, pos = string.find(data, ',')

  if pos then
    -- Check for command with parameter attached
    local cmd = string.sub(data, 1, pos-1)
    if cmd == 'TRG' then
      local camera = tonumber(string.sub(data, pos + 1))
      CSK_MultiRemoteCamera.cameraSpecificSoftwareTrigger(camera)
    end
  end
end
Script.register("CSK_TCPIPClient.OnNewDataReceived", handleOnNewDataReceived)

local function reboot()
  Parameters.savePermanent()
  Engine.reloadApps()
end
Script.serveFunction("CSK_ColorSortingInspection.reboot", reboot)

local function saveAllConfigs()

  --Save everything from all instances
  CSK_PersistentData.setPath('/public/' .. colorSortingInspection_Model.parametersName .. '.bin')

  CSK_ColorSortingInspection.setLoadOnReboot(true)
  CSK_ColorSortingInspection.sendParameters()

  if not colorSortingInspection_Model.emulation then

    CSK_DigitalIOManager.setLoadOnReboot(true)
    CSK_DigitalIOManager.sendParameters()

    CSK_PowerManager.setLoadOnReboot(true)
    CSK_PowerManager.sendParameters()
  end

  for i = 1, CSK_MultiColorSelection.getInstancesAmount() do

    CSK_MultiColorSelection.setInstance(i)
    CSK_MultiColorSelection.setLoadOnReboot(true)
    CSK_MultiColorSelection.sendParameters()
  end

  for j = 1, CSK_MultiRemoteCamera.getInstancesAmount() do
    CSK_MultiRemoteCamera.setSelectedCam(j)
    CSK_MultiRemoteCamera.setLoadOnReboot(true)
    CSK_MultiRemoteCamera.sendParameters()
  end

  CSK_MultiColorSelection.setInstance(colorSortingInspection_Model.selectedInstance)

  if colorSortingInspection_Model.userManagementModuleAvailable then
    CSK_UserManagement.setLoadOnReboot(true)
    CSK_UserManagement.sendParameters()
  end

  CSK_DateTime.setLoadOnReboot(true)
  CSK_DateTime.sendParameters()

  CSK_TCPIPClient.setLoadOnReboot(true)
  CSK_TCPIPClient.sendParameters()

  CSK_ImagePlayer.setLoadOnReboot(true)
  CSK_ImagePlayer.sendParameters()

  CSK_Logger.setLoadOnReboot(true)
  CSK_Logger.sendParameters()

  handleOnExpiredTmrColorSortingInspection()
end
Script.serveFunction("CSK_ColorSortingInspection.saveAllConfigs", saveAllConfigs)

local function setDefaultSetup()

  -- Possible devices
  -- 'SIM1004' 'SIM1012' 'SIM2x00' 'SIM2000' 'SIM2500' 'SIM4000' 'AppStudioEmulator''SICK AppEngine'

  -- Show on UI that app is currently processing
  Script.notifyEvent("ColorSortingInspection_OnNewStatusSetupHardware", true)

  CSK_MultiColorSelection.setInstance(1)

  if colorSortingInspection_Model.emulation then

    -- Only emulation
    CSK_MultiColorSelection.setRegisterEvent('CSK_ImagePlayer.OnNewImage')

  else
    -- Running on real SIM
    if colorSortingInspection_Model.deviceType == 'SIM1012' or colorSortingInspection_Model.deviceType == 'SIM2x00' or
       colorSortingInspection_Model.deviceType == 'SIM2500' or colorSortingInspection_Model.deviceType == 'SIM2000' or
       colorSortingInspection_Model.deviceType == 'SIM4000' then

       CSK_MultiColorSelection.setRegisterEvent('CSK_MultiRemoteCamera.OnNewImageCamera'..tostring(colorSortingInspection_Model.selectedInstance))

      local statusS2 = CSK_PowerManager.getCurrentPortStatus('S2')
      if not statusS2 then
        CSK_PowerManager.changeStatusOfPort('S2') -- Power for camera
        if not colorSortingInspection_Model.deviceType == 'SIM1012' then

          -- Check to not power camera twice via POE
          local statusPOE2 = CSK_PowerManager.getCurrentPortStatus('POE2')
          if not statusPOE2 then
            CSK_PowerManager.changeStatusOfPort('POE2')
          end
        end
        CSK_PowerManager.setAllStatus()
      end

      Script.sleep(12000) -- Wait for camera bootup

      CSK_MultiRemoteCamera.setCameraIP('192.168.1.100')
      CSK_MultiRemoteCamera.setAcquisitionMode('FIXED_FREQUENCY')
      CSK_MultiRemoteCamera.setProcessingMode('APP')
      CSK_MultiRemoteCamera.setResizeFactor(0.5)

      if colorSortingInspection_Model.deviceType == 'SIM1012' and string.sub(colorSortingInspection_Model.firmware, 1, 1) == '1' then
        CSK_MultiRemoteCamera.setColorMode('COLOR8')
        CSK_MultiRemoteCamera.setGigEVision(false)
      else
        CSK_MultiRemoteCamera.setColorMode('COLOR8')
        CSK_MultiRemoteCamera.setGigEVision(true)
      end
      CSK_MultiRemoteCamera.connectCamera()

      local statusS1 = CSK_PowerManager.getCurrentPortStatus('S1')
      if not statusS1 then
        CSK_PowerManager.changeStatusOfPort('S1')
        CSK_PowerManager.setAllStatus()
      end

      -- Forward incoming trigger of digital switch on S3 to camera on S2
      CSK_DigitalIOManager.setInputForLink('S3DI1')
      CSK_DigitalIOManager.setOutputForLink('S2DO1')
      CSK_DigitalIOManager.addLink()

      -- Forward result of internal event CSK_MultiColorSelection.OnNewResult1 to digital output on S4
      CSK_DigitalIOManager.setTriggerEvent('CSK_MultiColorSelection.OnNewResult1')
      CSK_DigitalIOManager.setOutputToTrigger('S4DO1')
      CSK_DigitalIOManager.addTriggerEvent()
      CSK_DigitalIOManager.selectOutputInterface('S4DO1')
      CSK_DigitalIOManager.setActiveStatusOutput(true)

      -- For SIM1012 sensor port needs to be powered for digital output
      if colorSortingInspection_Model.deviceType == 'SIM1012' then
        local statusS4 = CSK_PowerManager.getCurrentPortStatus('S4')
        if not statusS4 then
          CSK_PowerManager.changeStatusOfPort('S4')
          CSK_PowerManager.setAllStatus()
        end
      end

      CSK_Logger.setLoadOnReboot(true)
      CSK_DateTime.setLoadOnReboot(true)
      CSK_DigitalIOManager.setLoadOnReboot(true)
      CSK_ImagePlayer.setLoadOnReboot(true)
      CSK_MultiColorSelection.setLoadOnReboot(true)
      CSK_MultiRemoteCamera.setLoadOnReboot(true)
      CSK_PowerManager.setLoadOnReboot(true)
      CSK_TCPIPClient.setLoadOnReboot(true)
      CSK_UserManagement.setLoadOnReboot(true)

    elseif colorSortingInspection_Model.deviceType == 'SIM1004' then
      _G.logger:warning(nameOfModule .. ": SIM1004 currently not supported with this app version. Use an older version...")

    else
      _G.logger:warning(nameOfModule .. ": Device is not supported.")
    end
  end

  saveAllConfigs()

  Script.notifyEvent("ColorSortingInspection_OnNewStatusSetupHardware", false)
end
Script.serveFunction("CSK_ColorSortingInspection.setDefaultSetup", setDefaultSetup)

local function setInstance(instance)
  if instance ~= colorSortingInspection_Model.selectedInstance then
    CSK_MultiColorSelection.sendParameters()
  end

    colorSortingInspection_Model.selectedInstance = instance

    CSK_MultiColorSelection.setInstance(instance)

    handleOnExpiredTmrColorSortingInspection()
end
Script.serveFunction('CSK_ColorSortingInspection.setInstance', setInstance)

--- Function to react on 'CSK_MultiColorSelection.OnNewSelectedInstance' event to update selected instance
---@param selectedObject int Selected instance
local function handleOnNewSelectedInstance(selectedObject)
  colorSortingInspection_Model.selectedInstance = selectedObject
end
Script.register("CSK_MultiColorSelection.OnNewSelectedInstance", handleOnNewSelectedInstance)

--- Function to react on 'CSK_MultiColorSelection.OnNewStatusRegisteredEvent' event if OfflineImageMode is active
---@param eventname string Name of event
local function handleOnNewStatusRegisteredEvent(eventname)
  if eventname == 'CSK_ImagePlayer.OnNewImage' then
    Script.notifyEvent('ColorSortingInspection_OnNewOfflineImageMode', true)
  else
    Script.notifyEvent('ColorSortingInspection_OnNewOfflineImageMode', false)
  end
end
Script.register('CSK_MultiColorSelection.OnNewStatusRegisteredEvent', handleOnNewStatusRegisteredEvent)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ': Set parameter name: ' .. tostring(name))
  colorSortingInspection_Model.parametersName = name
end
Script.serveFunction("CSK_ColorSortingInspection.setParameterName", setParameterName)

local function sendParameters()
  if colorSortingInspection_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(colorSortingInspection_Model.helperFuncs.convertTable2Container(colorSortingInspection_Model.parameters), colorSortingInspection_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, colorSortingInspection_Model.parametersName, colorSortingInspection_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send ColorSortingInspection parameters with name '" .. colorSortingInspection_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_ColorSortingInspection.sendParameters", sendParameters)

local function loadParameters()
  if colorSortingInspection_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(colorSortingInspection_Model.parametersName)

    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      colorSortingInspection_Model.parameters = colorSortingInspection_Model.helperFuncs.convertContainer2Table(data)

      if colorSortingInspection_Model.parameters.resultOutputTCPIP then
        setResultOutputViaTCPIP(true)
      end

      CSK_ColorSortingInspection.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_ColorSortingInspection.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  colorSortingInspection_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_ColorSortingInspection.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then
    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    colorSortingInspection_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      colorSortingInspection_Model.parametersName = parameterName
      colorSortingInspection_Model.parameterLoadOnReboot = loadOnReboot
    end

    if colorSortingInspection_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('ColorSortingInspection_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

--- Function to react on 'CSK_MultiColorSelection.OnDataLoadedOnReboot' event
local function handleOnDataLoadedOnReboot()
  if colorSortingInspection_Model.parameters.resultOutputTCPIP then
    setResultOutputViaTCPIP(true)
  end
end
Script.register('CSK_MultiColorSelection.OnDataLoadedOnReboot', handleOnDataLoadedOnReboot)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setColorSortingInspection_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

