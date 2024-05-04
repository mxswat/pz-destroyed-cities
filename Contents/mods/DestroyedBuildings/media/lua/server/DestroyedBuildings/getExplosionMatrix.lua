local generateBuildingClusters = require "DestroyedBuildings/generateBuildingClusters"

---@alias ExplosionMatrix table<number, table<number, number?>>

---@type ExplosionMatrix?
local matrixCache = nil

---@return ExplosionMatrix
local function getMatrixModData()
  return ModData.getOrCreate("ExplosionMatrix");
end

local function lshift(x, by)
  return x * 2 ^ by
end

---@param matrix ExplosionMatrix
---@param cx number
---@param cy number
---@param r number
---@param value number
local function fillrow(matrix, x0, x1, y, cx, cy, r, value)
  x0 = math.floor(x0)
  x1 = math.floor(x1)
  y  = math.floor(y)

  matrix[y] = matrix[y] or {}

  local squares = matrix[y]
  for i = x1, x0, 1 do
    squares[i] = 1
  end
end

local function midpointCircleFill(matrix, cx, cy, radius)
  local x = radius - 1
  local y = 0
  local dx = 1
  local dy = 1
  local err = dx - lshift(radius, 1)

  while x >= y do
    fillrow(matrix, cx + y, cx - y, cy - x, cx, cy, radius, 1)
    fillrow(matrix, cx + x, cx - x, cy - y, cx, cy, radius, 1)
    fillrow(matrix, cx + x, cx - x, cy + y, cx, cy, radius, 1)
    fillrow(matrix, cx + y, cx - y, cy + x, cx, cy, radius, 1)

    if (err <= 0) then
      y = y + 1
      err = err + dy
      dy = dy + 2
    end

    if (err > 0) then
      x = x - 1
      dx = dx + 2
      err = err + dx - lshift(radius, 1)
    end
  end
end

local function generateExplosionMatrix()
  local clusters = generateBuildingClusters()
  matrixCache = {}

  for i = 1, #clusters do
    local cluster = clusters[i]

    print("Drawing cicle on Cluster num:", i)

    midpointCircleFill(matrixCache, cluster.centerX, cluster.centerY, 243)
  end

  return matrixCache
end

---@return ExplosionMatrix
local function getExplosionMatrix()
  return matrixCache or generateExplosionMatrix()
end

return getExplosionMatrix
