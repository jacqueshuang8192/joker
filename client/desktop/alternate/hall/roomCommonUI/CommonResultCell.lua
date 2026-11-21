--[[
* author:   zzy
* date:     2019-06-10
* describe: 大厅结算，玩家排列cell
* explain:  
]]
local ViewBaseLayer = require("hall.ViewBaseLayer")
local CommonResultCell = class("CommonResultCell", ViewBaseLayer)

function CommonResultCell:ctor(data)
	print("=====CommonResultCell:ctor======")
	print("=====CommonResultCell:ctor======")
	print("=====CommonResultCell:ctor======")
	print("=====CommonResultCell:ctor======")
	print("=====CommonResultCell:ctor======")
	dump(data)
    CommonResultCell.super.ctor(self, "hall/res/gameEndResult/CommonResultCell.csb")
    self:setNodeEventEnabled(true)
    self.data = data or {}
    self:initUI()

end

function CommonResultCell:onEnter()
end

function CommonResultCell:onExit()
end

function CommonResultCell:initUI()
	self:setUserInfo()
	self:refreshListView()
end

--设置玩家是否为最大玩家
function CommonResultCell:setMaxWinPlayer(_isMaxWin)
	self.img_winner_max_1:setVisible(_isMaxWin)
	self.img_winner_max_2:setVisible(_isMaxWin)
end

--设置玩家信息
function CommonResultCell:setUserInfo()

	local nickName = self.data.nickName or ""
	nickName = require("hall.GameCommon"):formatNick(nickName, 3)
	self.playerName:setString(nickName)

	local icon_url = self.data.portrait
	local sex = self.data.sex
	local uid = self.data.uid
	require("hall.GameCommon"):getUserHead(icon_url,uid,sex,self.playerImg, 96, false,nickName)

--	print ("self.data.score" , self.data.score)
	-- if self.data.score > 0 then
	-- 	self.data.score = "+"..self.data.score
	-- end

	self.txt_score:setString(self.data.score or "")

	self:setMaxWinPlayer(self.data.isMaxWin)

end

--刷新玩家每一局比赛分数情况
function CommonResultCell:refreshListView()

	self.ListView_1:removeAllChildren()
	if self.data.match_mount <= 0 then return end
	local cell = require("hall.roomCommonUI.CommonScoreInfoCell")
	local tempIndex = 1
	for k,v in pairs(self.data.matchlist) do
		self:addScoreCell(cell,v.matchScore,tempIndex)
		tempIndex = tempIndex + 1
	end

end

--增加玩家每一局的得分情况
function CommonResultCell:addScoreCell(_cell,_data,_tempIndex)
	local Widget = ccui.Widget:create()
    local item = _cell.new(_data,_tempIndex)
    Widget:addChild(item)
    Widget:setContentSize(240,44)
    self.ListView_1:pushBackCustomItem(Widget)
end

return CommonResultCell