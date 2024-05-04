local MxDebug = require "MxUtilities/MxDebug"
local getClassFieldValueByName = require "DestroyedBuildings/getClassFieldValueByName"

---@class ClusterPoint
---@field x number
---@field y number
---@field def BuildingDef

---@class Cluster
---@field points ClusterPoint[]
---@field centerX number
---@field centerY number


--- Function to calculate the distance between two points
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
local function calculateDistance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

--- Function to calculate the radius of a cluster
---@param center table
---@param cluster table
---@return number
local function calculateRadius(center, cluster)
  local maxDistance = 0
  for _, point in ipairs(cluster.points) do
    local distance = calculateDistance(center.x, center.y, point.x, point.y)
    if distance > maxDistance then
      maxDistance = distance
    end
  end
  return maxDistance
end

--- Function to perform K-means clustering with additional criteria
---@param points ClusterPoint[]
---@param minBuildingCount number
---@param maxDistanceBetweenBuildings number
local function kmeansAuto(points, minBuildingCount, maxDistanceBetweenBuildings)
  ---@type Cluster[]
  local clusters = {}
  local clusterCount = 0

  while #points > 0 do
    local seedPoint = table.remove(points, 1)
    ---@type Cluster
    local cluster = { points = { seedPoint }, centerX = 0, centerY = 0 }

    for i = #points, 1, -1 do
      local point = points[i]
      local withinMaxDistance = true
      for _, existingPoint in ipairs(cluster.points) do
        local distance = calculateDistance(point.x, point.y, existingPoint.x, existingPoint.y)
        if distance > maxDistanceBetweenBuildings then
          withinMaxDistance = false
          break
        end
      end

      if withinMaxDistance then
        table.insert(cluster.points, point)
        table.remove(points, i)
      end
    end

    if #cluster.points >= minBuildingCount then
      clusterCount = clusterCount + 1
      table.insert(clusters, cluster)
    end
  end

  -- Calculate center coordinates of each cluster
  for _, cluster in ipairs(clusters) do
    local sumX, sumY = 0, 0
    for _, point in ipairs(cluster.points) do
      sumX = sumX + point.x
      sumY = sumY + point.y
    end
    cluster.centerX = sumX / #cluster.points
    cluster.centerY = sumY / #cluster.points
  end

  return clusters
end

--- Callback function for the game start event
local function generateBuildingClusters()
  local startedAt = getTimestampMs()
  local metaGrid = getWorld():getMetaGrid()

  ---@type table
  local buildings = getClassFieldValueByName(metaGrid, 'Buildings')
  local buildingsCount = buildings:size()

  MxDebug:print('OnGameStart - metaGrid.Buildings:size()', buildingsCount)

  ---@type ClusterPoint[]
  local points = {}
  for i = 1, buildingsCount do
    local buildingDef = buildings:get(i - 1) --[[@as BuildingDef]]
    -- Calculate the center coordinates of the building using getX() and getY() methods
    local centerX = (buildingDef:getX() + buildingDef:getX2()) / 2
    local centerY = (buildingDef:getY() + buildingDef:getY2()) / 2
    table.insert(points, { x = centerX, y = centerY, def = buildingDef })
  end

  -- Example usage
  local minBuildingCount = 50             -- Adjust as needed
  local maxDistanceBetweenBuildings = 450 -- Adjust as needed

  -- Perform automatic K-means clustering with additional criteria
  local clusters = kmeansAuto(points, minBuildingCount, maxDistanceBetweenBuildings)

  -- Sort the clusters by the x coordinate of their center coordinates
  -- Makes it easier to check the logged results visually
  table.sort(clusters, function(cluster1, cluster2)
    return cluster1.centerX < cluster2.centerX
  end)

  -- Print cluster information
  for _, cluster in ipairs(clusters) do
    local centerX = math.floor(cluster.centerX)
    local centerY = math.floor(cluster.centerY)
    local radius = math.floor(calculateRadius({ x = centerX, y = centerY }, cluster))
    local buildingCount = #cluster.points
    local totalDistance = 0

    -- Calculate total distance between all pairs of buildings
    for i = 1, buildingCount - 1 do
      for j = i + 1, buildingCount do
        local distance = calculateDistance(cluster.points[i].x, cluster.points[i].y, cluster.points[j].x,
          cluster.points[j].y)
        totalDistance = totalDistance + distance
      end
    end

    -- Calculate average distance between buildings
    local avgDistance = totalDistance / (buildingCount * (buildingCount - 1) / 2)

    -- Print center coordinates, radius, building count, and average distance
    print("------------", "X", "Y")
    print("City center:", centerX, centerY)
    print("City radius:", radius)
    print("Buildings count:", buildingCount)
    print("Buildings Avg distance:", string.format("%.2f", avgDistance))
    print("", "")
  end

  MxDebug:print("Time taken:", (getTimestampMs() - startedAt) / 1000, "s")


  return clusters
end

return generateBuildingClusters