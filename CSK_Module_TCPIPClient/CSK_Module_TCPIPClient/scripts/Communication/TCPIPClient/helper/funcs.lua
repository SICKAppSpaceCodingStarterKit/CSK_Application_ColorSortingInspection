---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find helper functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

local funcs = {}

funcs.json = require('Communication/TCPIPClient/helper/Json')

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to create a JSON string out of a table content
---@param content string[] Lua Table with entries for list
---@return string jsonstring List created of table entries
local function createJsonList(content)
  local commandList = {}
  if content == nil then
    commandList = {{TriggerCommand = '-', notifyEvent = '-'},}
  else
    local size = 0
      for key, value in pairs(content) do
        table.insert(commandList, {TriggerCommand = key, notifyEvent = 'CSK_TCPIPClient.' .. value})
        size = size + 1
      end
      if size == 0 then
        commandList = {{TriggerCommand = '-', notifyEvent = '-'},}
      end
  end

  local jsonstring = funcs.json.encode(commandList)
  return jsonstring
end
funcs.createJsonList = createJsonList

--- Function to create a list from a table
---@param data string[] Lua Table with entries for list
---@return string list List created of table entries
local function createStringList(data)
  local list = "["
  if #data >= 1 then
    list = list .. '"' .. data[1] .. '"'
  end
  if #data >= 2 then
    for i=2, #data do
      list = list .. ', ' .. '"' .. data[i] .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringList = createStringList

--- Function to convert a table into a Container object
---@param content auto[] Lua Table to convert to Container
---@return Container cont Created Container
local function convertTable2Container(content)
  local cont = Container.create()
  for key, value in pairs(content) do
    if type(value) == 'table' then
      cont:add(key, convertTable2Container(value), nil)
    else
      cont:add(key, value, nil)
    end
  end
  return cont
end
funcs.convertTable2Container = convertTable2Container

--- Function to convert a Container into a table
---@param cont Container Container to convert to Lua table
---@return auto[] data Created Lua table
local function convertContainer2Table(cont)
  local data = {}
  local containerList = Container.list(cont)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i=1, #containerList do

    local subContainer

    if containerCheck then
      subContainer = Container.get(cont, tostring(i) .. '.00')
    else
      subContainer = Container.get(cont, containerList[i])
    end
    if type(subContainer) == 'userdata' then
      if Object.getType(subContainer) == "Container" then

        if containerCheck then
          table.insert(data, convertContainer2Table(subContainer))
        else
          data[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck then
          table.insert(data, subContainer)
        else
          data[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck then
        table.insert(data, subContainer)
      else
        data[containerList[i]] = subContainer
      end
    end
  end
  return data
end
funcs.convertContainer2Table = convertContainer2Table

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************