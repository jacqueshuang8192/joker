--[[
	方向
]]

local Direction = {
    EAST  = 1,
    NORTH = 2,
    WEST  = 3,
    SOUTH = 4,
}

local ANGLE_PER_DIR = math.rad(90)
local HALF_AGNEL_PER_DIR = ANGLE_PER_DIR / 2

--获取方向
function Direction.getDir(angle)
	if angle >= HALF_AGNEL_PER_DIR and angle < HALF_AGNEL_PER_DIR * 3 then
		return Direction.NORTH
	elseif angle > HALF_AGNEL_PER_DIR * 3 and angle < HALF_AGNEL_PER_DIR * 5 then
		return Direction.WEST
	elseif angle > HALF_AGNEL_PER_DIR * 5 and angle < HALF_AGNEL_PER_DIR * 7 then
		return Direction.SOUTH
	else
		return Direction.EAST
	end
end

--获取角度
function Direction.getAngle(dir)
	return (dir - 1) * ANGLE_PER_DIR
end

return Direction