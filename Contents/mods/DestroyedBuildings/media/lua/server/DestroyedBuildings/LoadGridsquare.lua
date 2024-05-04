local getExplosionMatrix = require "DestroyedBuildings/getExplosionMatrix"

---@param square IsoGridSquare
local function burnSquare(square)
  square:getObjects():clear();
  square:getSpecialObjects():clear();

  if square:getZ() > 0 then return end

  square:addFloor("floors_burnt_01_0")
end

Events.LoadGridsquare.Add(function(square)
  local x, y, z = square:getX(), square:getY(), square:getZ()

  local explosionMatrix = getExplosionMatrix()

  local explosionType = explosionMatrix[y] and explosionMatrix[y][x]

  if explosionType == nil then
    return
  end

  burnSquare(square)
end);
