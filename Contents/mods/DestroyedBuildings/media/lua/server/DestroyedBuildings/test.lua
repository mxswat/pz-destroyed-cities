local MxDebug = require "MxUtilities/MxDebug"
local getClassFieldValueByName = require "DestroyedBuildings/getClassFieldValueByName"

Events.OnGameStart.Add(function()
  local metaGrid = getWorld():getMetaGrid()
  ---@type ArrayList
  local buildings = getClassFieldValueByName(metaGrid, 'Buildings')
  MxDebug:print('OnGameStart - metaGrid.Buildings', buildings)
  MxDebug:print('OnGameStart - metaGrid.Buildings', buildings:size())
end);
