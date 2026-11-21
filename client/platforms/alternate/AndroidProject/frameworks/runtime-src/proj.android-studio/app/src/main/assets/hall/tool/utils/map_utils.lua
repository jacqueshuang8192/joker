local MapUtils = {}

local MapConst = _M("map.map_const")
local UNWALKABLE_VALUE = MapConst.UNWALKABLE_VALUE

local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local atan2 = math.atan2
local abs = math.abs
local pi = math.pi
local floor = math.floor
local ceil = math.ceil

function MapUtils.getSpeedFactor(angle)
	return sqrt(cos(angle) * cos(angle) + sin(angle) * sin(angle) / 2)
end

function MapUtils.getSpeed(moveSpeed, angle)
	local speed = moveSpeed * MapUtils.getSpeedFactor(angle)
	return speed
end

function MapUtils.getTilePos(self)
	return self._coords:screenToTileCoords(self:getX(), self:getY())
end

function MapUtils.distanceTo(self, x, y)
	local pos =  MapUtils.getTilePos(self)
	local dx, dy = pos.x - x, pos.y - y
	return sqrt(dx * dx + dy * dy)
end

function MapUtils.pixelDistanceTo(self, x, y)
	local dx, dy = x - self:getX(), y - self:getY()
	return sqrt(dx * dx + dy * dy)
end

function MapUtils.distanceWith(self, obj)
	local pos = MapUtils.getTilePos(obj)
	return self:distanceTo(pos.x, pos.y)
end

function MapUtils.pixelDistanceWith(self, obj)
	return MapUtils.pixelDistanceTo(self, obj:getX(), obj:getY())
end

function MapUtils.angleTo(self, angle, x, y)
	local toAngle = atan2(y - self:getY(), self:getX() - x)
	local detA = abs(toAngle - angle)
	if detA > pi then
		detA = 2 * pi - detA
	end
	return detA
end

function MapUtils.getIntersestTiles(coords, polygon)
	local tiles = {}
	local maxWidth, maxHeight = coords:getMapWidth(), coords:getMapHeight()
	local tileWidth = coords:getTileWidth()
	local left, top, right, bottom = polygon:boundingBox()
	local leftTop = coords:screenToTileCoordsF(left, top)
	local leftBottom = coords:screenToTileCoordsF(left, bottom)
	local rightTop = coords:screenToTileCoordsF(right, top)
	local rightBottom = coords:screenToTileCoordsF(right, bottom)
	local startTile = {x = floor(leftTop.x), y = floor(rightTop.y)}
	local endTile = {x = ceil(rightBottom.x), y = ceil(leftBottom.y)}

	for i = startTile.x, endTile.x do
		for j = startTile.y, endTile.y do
			local tilePolygon = coords:tileToScreenPolygon(i, j)
			local collide = polygon:collideWith(tilePolygon)
			if collide and i >= 0 and j >= 0 
				and i < maxWidth and j < maxHeight then
				tiles[#tiles + 1] = i
				tiles[#tiles + 1] = j
			end
		end
	end
	return tiles
end

return MapUtils
