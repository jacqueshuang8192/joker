
--[[
* author:   zwm
* date:     2018-11-21
* describe: 单局结算界面
--]]
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local newGameResultCsb = TpackageName.."/res/layout/newGameResultLayer.csb"

local GameResult = class("GameResult", function ()
	return cc.CSLoader:createNode(newGameResultCsb)
end)

function GameResult:ctor()
	self:setScale(SCREEN_WIDTH/1280,SCREEN_HEIGHT/720)
	-- self:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
	self:addListenBtn()
	self:initGetValidNode()
end

function GameResult:init( info )
	if info == nil then return end
	self:setTitle(info)
	self:addResultItem(info)
end

function GameResult:addListenBtn()
	self.btnClose = self:getChildByName("btnClose")
	self.btnContinue = self:getChildByName("btnContinue")
	self.btnClose:addTouchEventListener(handler(self, self.onTouchEvent))
	self.btnContinue:addTouchEventListener(handler(self, self.onTouchEvent))
	self:showReadyCountDown()
end

function GameResult:initGetValidNode()
	self.titleWinBg = self:getChildByName("titleWinBg")
	self.titleWinFont = self.titleWinBg:getChildByName("titleFont")
	self.titleLoseBg = self:getChildByName("titleLoseBg")
	self.itemNode = self:getChildByName("itemNode")
end

function GameResult:onTouchEvent(sender, event)
	if event == TOUCH_EVENT_BEGAN then
		sender:setScale(0.9)
	elseif event == TOUCH_EVENT_ENDED then
		sender:setScale(1)
		local name = sender:getName()
		if name == "btnClose" then
			BiJiSendHandle:CLI_READYNOW_ROOM()
			GamePlaneOperator:openNetRanking()
			self:removeSelf()
		elseif name == "btnContinue" then
			BiJiSendHandle:CLI_READYNOW_ROOM()
			GamePlaneOperator:openNetRanking()
			self:removeSelf()
		end
	end
end

function GameResult:setTitle(info)
	local tag = 0
	for i,v in ipairs(info["userinfos"]) do
		if v["uid"] == USER_INFO["uid"] then
			if v.chip_list[1] > 0 and v.chip_list[2] > 0 and v.chip_list[3] > 0 then
				tag = 1
			elseif (v.chip_list[1] + v.chip_list[2] + v.chip_list[3]) > 0 then
				tag = 2
			else
				tag = 3
			end
		end
	end
	if tag == 1 then --表示完胜
		self.titleWinBg:setVisible(true)
		self.titleLoseBg:setVisible(false)
		local path = TpackageName.."/res/images/gameResult/fontWangsheng.png"
		self:changeImgByPath(path)
	elseif tag == 2 then -- 表示胜利
		self.titleWinBg:setVisible(true)
		self.titleLoseBg:setVisible(false)
		local path = TpackageName.."/res/images/gameResult/shengli.png"
		self:changeImgByPath(path)
	elseif tag == 3 then -- 表示失败
		self.titleWinBg:setVisible(false)
		self.titleLoseBg:setVisible(true)
	end
	
end

function GameResult:addResultItem(info)
	local resultNode = require(TpackageName .. ".view.GameResultItem")
	for i,v in ipairs(info["userinfos"]) do
		if resultNode then
			local item = resultNode.new()
			item:init(v)
			item:setPosition(cc.p((i - 1)*207,130))
			-- item:setContentSize(cc.size(207, 505))
			self.itemNode:addChild(item)
		end
	end
	local offset = 10
	local itemSize = #info["userinfos"]
	self.itemNode:setPositionX(((6-itemSize)/2) * 207 + offset)
end

function GameResult:changeImgByPath(path)
	local cache = cc.Director:getInstance():getTextureCache():addImage(path)
	self.titleWinFont:setTexture(cache)
end

function GameResult:showReadyCountDown()
	self.desCountDown = self:getChildByName("countDown")
	self.beginTime = 5
	self.desCountDown:setString(string.format("(%s)", self.beginTime))
	self.readyCountDowmHandler = scheduler.scheduleGlobal(handler(self, self.playCountDown), 1.0)
end

function GameResult:playCountDown()
	self.beginTime = (self.beginTime or 0) - 1
	if self.beginTime == 0 then
		scheduler.unscheduleGlobal(self.readyCountDowmHandler)
		self.readyCountDowmHandler = nil
		BiJiSendHandle:CLI_READYNOW_ROOM()
		self:removeSelf()
	else
		if self.desCountDown ~= nil then
			self.desCountDown:setString(string.format("(%s)", self.beginTime))
		end
	end
end

function GameResult:removeSelfAndCancelCountDowm()
	if self.readyCountDowmHandler then
		scheduler.unscheduleGlobal(self.readyCountDowmHandler)
		self.readyCountDowmHandler = nil
	end
	self:removeSelf()
end

function GameResult:onExit( )
	if self.readyCountDowmHandler then
		scheduler.unscheduleGlobal(self.readyCountDowmHandler)
		self.readyCountDowmHandler = nil
	end
end

return GameResult