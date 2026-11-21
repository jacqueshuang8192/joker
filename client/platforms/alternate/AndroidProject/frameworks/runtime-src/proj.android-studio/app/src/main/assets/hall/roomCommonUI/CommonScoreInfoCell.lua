--[[
* author:   zzy
* date:     2019-06-10
* describe: 每一场局数得分情况
* explain:  
]]

local ViewBaseLayer = require("hall.ViewBaseLayer")
local CommonScoreInfoCell = class("CommonScoreInfoCell", ViewBaseLayer)

function CommonScoreInfoCell:ctor(data,_gameIndex)

    CommonScoreInfoCell.super.ctor(self, "hall/res/gameEndResult/CommonScoreInfoCell.csb")
    self:setNodeEventEnabled(true)
    self.data = data or 0 
    self._gameIndex = _gameIndex or 0
    self:initUI()

end

function CommonScoreInfoCell:onEnter()
end

function CommonScoreInfoCell:onExit()
end

--初始化UI
function CommonScoreInfoCell:initUI()

	if self._gameIndex == 0 then return end
	self.txt_jushu:setString("第"..self._gameIndex.."局")

	local _score = tonumber(self.data)
	if _score > 0 then
		_score = "+".._score
	end

	-- print(self.data)
	self.txt_score:setVisible(true)
	self.txt_score:setString(_score)
end

return CommonScoreInfoCell