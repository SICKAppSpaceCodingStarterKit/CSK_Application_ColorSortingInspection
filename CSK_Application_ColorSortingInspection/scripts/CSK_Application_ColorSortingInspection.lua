--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
_G.availableAPIs = require('Application.ColorSortingInspection.helper.checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device

--**************************************************************************
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

if not _G.availableAPIs.default then
  _G.logger:warning("Cannot start the Color Inspection And Sorting application, as relevant apps/features are missing...")
  print("WARNING: Cannot start the Color Inspection And Sorting application, as relevant apps/features are missing...")
end

--- Function to show UI of this app first
local function setAppAsMainWebpage()
  local defaultWebpage = Parameters.get("AEDefaultWebpage")
  if defaultWebpage == nil then
    _G.logger:warning("Device does not support setting the default webpage.")
  else
    assert(Parameters.set("AEDefaultWebpage", _APPNAME))
  end
end

-- Loading script regarding ColorSortingInspection_Model
-- Check this script regarding ColorSortingInspection_Model parameters and functions
_G.colorSortingInspection_Model = require('Application/ColorSortingInspection/ColorSortingInspection_Model')

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function handleOnStarted()

  _G.logger:info("Start the Color Inspection And Sorting application")
  setAppAsMainWebpage() -- Set UI of this app as default UI.
  CSK_ColorSortingInspection.pageCalled() -- Update UI
end
Script.register('Engine.OnStarted', handleOnStarted)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************
