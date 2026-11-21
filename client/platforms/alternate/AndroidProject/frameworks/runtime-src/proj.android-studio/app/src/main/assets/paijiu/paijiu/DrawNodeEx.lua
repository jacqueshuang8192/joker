local c = cc
local DrawNode = c.DrawNode

local drawPolygon = cc.DrawNode.drawPolygon
function DrawNode:drawPolygon(points, pointsCount, fillColor, borderWidth, borderColor)
    drawPolygon(self, points, pointsCount, fillColor, borderWidth, borderColor)
    return self
end

local drawDot = DrawNode.drawDot
function DrawNode:drawDot(point, radius, color)
    drawDot(self, point, radius, color)
    return self
end