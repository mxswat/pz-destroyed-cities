local MxDebug = require "MxUtilities/MxDebug"

local doneOnce = false

---@type type<string, Field>
local fieldCache = {}

-- Remember, this only work with "public" fields, not "private" or "protected"
local function getClassFieldValueByName(classInstance, fieldName)
  local cacheKey = tostring(classInstance) .. fieldName

  if fieldCache[cacheKey] then
    return getClassFieldVal(classInstance, fieldCache[cacheKey])
  end

  local fieldsCount = getNumClassFields(classInstance)
  for i = 0, fieldsCount - 1 do
    local field = getClassField(classInstance, i)

    if tostring(field):sub(-#fieldName) == fieldName then
      fieldCache[cacheKey] = field

      return getClassFieldVal(classInstance, field)
    end
  end
end

Events.LoadGridsquare.Add(function(square)
  -- MxDebug:print('X:', square:getX(), 'Y:', square:getY())
  -- MxDebug:print('getMetaGrid().Buildings', getWorld():getMetaGrid().Buildings)

  if doneOnce then return end

  local metaGrid = getWorld():getMetaGrid()
  local buildings = getClassFieldValueByName(metaGrid, 'Buildings')
  MxDebug:print('LoadGridsquare - metaGrid.Buildings', buildings)

  doneOnce = true
end);

Events.OnGameBoot.Add(function()
  -- MxDebug:print('OnGameStart')
  -- local num = getNumClassFields(IsoMetaGrid)
  -- for i = 0, num - 1 do
  --   print(getClassField(IsoMetaGrid, i), " --", i)
  -- end
end);
