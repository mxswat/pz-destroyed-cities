local MxDebug = require "MxUtilities/MxDebug"
local getClassFieldValueByName = require "DestroyedBuildings/getClassFieldValueByName"

-- Function to calculate the distance between two points
local function calculateDistance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- Function to calculate the radius of a cluster
local function calculateRadius(center, cluster)
  local maxDistance = 0
  for _, point in ipairs(cluster) do
    local distance = calculateDistance(center.x, center.y, point.x, point.y)
    if distance > maxDistance then
      maxDistance = distance
    end
  end
  return maxDistance
end

-- Function to perform K-means clustering with additional criteria
local function kmeansAuto(points, minBuildingCount, maxDistanceBetweenBuildings)
  local clusters = {}
  local clusterCount = 0

  while #points > 0 do
    local seedPoint = table.remove(points, 1)
    local cluster = { seedPoint }

    for i = #points, 1, -1 do
      local point = points[i]
      local withinMaxDistance = true
      for _, existingPoint in ipairs(cluster) do
        local distance = calculateDistance(point.x, point.y, existingPoint.x, existingPoint.y)
        if distance > maxDistanceBetweenBuildings then
          withinMaxDistance = false
          break
        end
      end
      if withinMaxDistance then
        table.insert(cluster, point)
        table.remove(points, i)
      end
    end

    if #cluster >= minBuildingCount then
      clusterCount = clusterCount + 1
      clusters[clusterCount] = cluster
    end
  end

  return clusters
end

function DestroyedBuildingsInit()
  local startedAt = getTimestampMs()
  local metaGrid = getWorld():getMetaGrid()

  ---@type ArrayList
  local buildings = getClassFieldValueByName(metaGrid, 'Buildings')
  local buildingsCount = buildings:size()

  MxDebug:print('OnGameStart - metaGrid.Buildings:size()', buildingsCount)

  ---@type {x: number, y: number}[]
  local points = {}
  for i = 1, buildingsCount do
    local buildingDef = buildings:get(i - 1) --[[@as BuildingDef]]
    -- Calculate the center coordinates of the building using getX() and getY() methods
    local centerX = (buildingDef:getX() + buildingDef:getX2()) / 2
    local centerY = (buildingDef:getY() + buildingDef:getY2()) / 2
    table.insert(points, { x = centerX, y = centerY })
  end

  -- Example usage
  local minBuildingCount = 40             -- Adjust as needed
  local maxDistanceBetweenBuildings = 400 -- Adjust as needed

  -- Perform automatic K-means clustering with additional criteria
  local clusters = kmeansAuto(points, minBuildingCount, maxDistanceBetweenBuildings)

  -- Pre-calculate the center coordinates of each cluster
  for _, cluster in ipairs(clusters) do
    local sumX, sumY = 0, 0
    for _, point in ipairs(cluster) do
      sumX = sumX + point.x
      sumY = sumY + point.y
    end
    cluster.centerX = sumX / #cluster
    cluster.centerY = sumY / #cluster
  end

  -- Sort the clusters by the x coordinate of their center coordinates
  table.sort(clusters, function(cluster1, cluster2)
    return cluster1.centerX < cluster2.centerX
  end)

  -- Calculate and print the center coordinates, radius, and average distance between buildings in each cluster (city)
  for _, cluster in ipairs(clusters) do
    local centerX = cluster.centerX
    local centerY = cluster.centerY
    local radius = calculateRadius({ x = centerX, y = centerY }, cluster)
    local buildingCount = #cluster
    local totalDistance = 0

    -- Calculate total distance between all pairs of buildings
    for i = 1, buildingCount - 1 do
      for j = i + 1, buildingCount do
        local distance = calculateDistance(cluster[i].x, cluster[i].y, cluster[j].x, cluster[j].y)
        totalDistance = totalDistance + distance
      end
    end

    -- Calculate average distance between buildings
    local avgDistance = totalDistance / (buildingCount * (buildingCount - 1) / 2)

    -- Print center coordinates, radius, building count, and average distance
    print("------------", "X", "Y")
    print("City center:", math.floor(centerX), math.floor(centerY))
    print("City radius:", math.floor(radius))
    print("Buildings count:", buildingCount)
    print("Buildings Avg distance:", string.format("%.2f", avgDistance))
    print("", "")
  end

  MxDebug:print("Time taken:", (getTimestampMs() - startedAt) / 1000, "s")
end

Events.OnGameStart.Add(function()
  DestroyedBuildingsInit()
end);
