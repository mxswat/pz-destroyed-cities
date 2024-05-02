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


return getClassFieldValueByName