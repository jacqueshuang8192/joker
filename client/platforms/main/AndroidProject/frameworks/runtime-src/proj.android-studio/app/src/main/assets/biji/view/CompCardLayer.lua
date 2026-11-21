
--[[
* author:   zwm
* date:     2018-11-27
* describe: 比牌界面
--]]

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local csbPath = TpackageName.."/res/layout/compCardLayer.csb"

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)

    return value
end

local pai_path = TpackageName.."/res/images/pokercard/"
local COMP_NODE = {}

local CompCardLayer = class("CompCardLayer", function ()
	return cc.CSLoader:createNode(csbPath)
end)

function CompCardLayer:ctor()
	self.baseScaleTime = 0.5
	self:getVarietyNode()
	self:init()
end

function CompCardLayer:getVarietyNode()
	for i = 1, 6 do
		COMP_NODE[i] = self:getChildByName("comp_"..i)
		COMP_NODE[i]:setVisible(false)
	end
	self.beginAni = self:getChildByName("beginAni")
	self.beginAni:setVisible(false)
	self.btnKanpai = self:getChildByName("btnKanpai")
	self.btnKanpai:addTouchEventListener(handler(self, self.onTouchEvent))
	self.btnKanpai:setVisible(false)
end

function CompCardLayer:init()
	print("init ------------------------", debug.traceback())
	local setIndex = {}
	for i = 1, 6 do
		COMP_NODE[i]:setVisible(false)
		for j = 1, 3 do
			local pierNode = COMP_NODE[i]:getChildByName("pier_"..j)
			pierNode:getChildByName("cardType"):setVisible(false)
			pierNode:getChildByName("score"):setVisible(false)
			self:changeImgByPath(pierNode:getChildByName("card_1"), pai_path .. "card_up.png")
			self:changeImgByPath(pierNode:getChildByName("card_2"), pai_path .. "card_up.png")
			self:changeImgByPath(pierNode:getChildByName("card_3"), pai_path .. "card_up.png")
		end
	end
end

function CompCardLayer:onTouchEvent(sender, event)
	if event == TOUCH_EVENT_ENDED then
		self.isMingPai = not self.isMingPai
		if COMP_NODE[1]:isVisible() and self.info == nil and self.kanCardsInfo ~= nil then
			self:setSelfCardVard(self.isMingPai)
		end
	end
end

function CompCardLayer:getCardPathByValue( v )
	local result = ""
	local cardVariety = getVariety(v or 1)
	local cardValue = getValue(v or 1)
	if cardVariety == VARIETY_DIAMOND then -- 方块
		result = pai_path .. "lord_card_diamond_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_CLUB then-- 梅花
		result = pai_path .. "lord_card_heart_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_HEART then-- 红桃
		result = pai_path .. "lord_card_spade_" .. string.format("%d", cardValue) .. ".png"
	elseif cardVariety == VARIETY_SPADE then-- 黑桃
		result = pai_path .. "lord_card_club_" .. string.format("%d", cardValue) .. ".png"
	end
	return result
end

function CompCardLayer:setSelfCardVard(isMingPai)
	if isMingPai then
		for i,v in ipairs(self.kanCardsInfo) do
			local pierNode = COMP_NODE[1]:getChildByName("pier_"..i)
			local path1 = self:getCardPathByValue(v.son_card[1])
			local path2 = self:getCardPathByValue(v.son_card[2])
			local path3 = self:getCardPathByValue(v.son_card[3])
			self:changeImgByPath(pierNode:getChildByName("card_1"), path1)
			self:changeImgByPath(pierNode:getChildByName("card_2"), path2)
			self:changeImgByPath(pierNode:getChildByName("card_3"), path3)
		end
	else
		for i = 1, 3 do
			local pierNode = COMP_NODE[1]:getChildByName("pier_"..i)
			self:changeImgByPath(pierNode:getChildByName("card_1"), pai_path .. "card_up.png")
			self:changeImgByPath(pierNode:getChildByName("card_2"), pai_path .. "card_up.png")
			self:changeImgByPath(pierNode:getChildByName("card_3"), pai_path .. "card_up.png")
		end
	end
end

function CompCardLayer:showCompNodeByInfo()
	local seatTab = {}
	for i,v in ipairs(self.info.userinfos) do
		seatTab[BIJI_PLAYERTYPE_TABLE[v.uid]] = true
	end

	for i = 1, 6 do
		if seatTab[i] then
			COMP_NODE[i]:setVisible(true)
		else
			COMP_NODE[i]:setVisible(false)
		end
	end
end

function CompCardLayer:showOpenCard(info)
	self.info = info
	self.kanCardsInfo = nil
	self:showCompNodeByInfo()
	self:playerBeginAniByType(2)
end

function CompCardLayer:toShowOpenCard()
	self.beginAni:setVisible(false)
	for i = 1, 3 do
		self:showPierCardByIndex(i)
	end
end

function CompCardLayer:showPierCardByIndex(index)
	for i,v in ipairs(self.info.userinfos) do
		local pierCards = v.openCard[index]
		local compItem = COMP_NODE[BIJI_PLAYERTYPE_TABLE[v.uid]]:getChildByName("pier_"..index)--self["compItem"..tostring(BIJI_PLAYERTYPE_TABLE[v.uid])]
		self:toAni(compItem, pierCards, index, i)
	end
end

function CompCardLayer:toAni(node, cardsInfo, pier, uIndex)
	-- self:playCardsTypeVoice(cardsInfo.open_type)
	-- self:setCardsValue(node, cardsInfo)
	node.effectPath = self:playCardsTypeVoice(cardsInfo.open_type)
	node.uIndex = uIndex
	self:playAni(node, pier, uIndex, cardsInfo)
end

function CompCardLayer:playCardsTypeVoice( type )
	local path = nil
	local head = USER_INFO.sex == 2 and TpackageName.."/sound/man/" or TpackageName.."/sound/woman/"
	if type == 1 then
		path = head .. "wulong.mp3"
	elseif type == 2 then
		path = head .. "duizi.mp3"
	elseif type == 3 then
		path = head .. "sunzi.mp3"
	elseif type == 4 then
		path = head .. "tonghua.mp3"
	elseif type == 5 then
		path = head .. "tonghuasun.mp3"
	elseif type == 6 then
		path = head .. "santiao.mp3"
	end
	return path
	-- if path then
	-- 	require("hall.GameCommon"):playEffectSound(path)
	-- end
end

function CompCardLayer:setCardsValue(node, cardsInfo)
	for i,v in ipairs(cardsInfo.son_card) do
		local cardImg = node:getChildByName("card_"..tostring(i))
		local cardVariety = getVariety(v or 1)
		local cardValue = getValue(v or 1)
		if cardVariety == VARIETY_DIAMOND then -- 方块
			self:changeImgByPath(cardImg, pai_path .. "lord_card_diamond_" .. string.format("%d", cardValue) .. ".png")
		elseif cardVariety == VARIETY_CLUB then-- 梅花
			self:changeImgByPath(cardImg, pai_path .. "lord_card_spade_" .. string.format("%d", cardValue) .. ".png")
		elseif cardVariety == VARIETY_HEART then-- 红桃
			self:changeImgByPath(cardImg, pai_path .. "lord_card_heart_" .. string.format("%d", cardValue) .. ".png")
		elseif cardVariety == VARIETY_SPADE then-- 黑桃
			self:changeImgByPath(cardImg, pai_path .. "lord_card_club_" .. string.format("%d", cardValue) .. ".png")
		end
	end
	local cardType = node:getChildByName("cardType")
	cardType:setVisible(true)
	local cardTypePath = self:playCardsTypeImg(cardsInfo.open_type)
	self:changeImgByPath(cardType, cardTypePath)
end

function CompCardLayer:changeImgByPath(sp, path)
	if path == nil or sp == nil then return end
	local cache = cc.Director:getInstance():getTextureCache():addImage(path)
	if cache == nil then return end
	sp:setTexture(cache)
end

function CompCardLayer:playCardsTypeImg( type )
	local path = nil
	if type == 1 then
		path = TpackageName.."/res/images/fontWulong.png"
	elseif type == 2 then
		path = TpackageName.."/res/images/fontDuizi.png"
	elseif type == 3 then
		path = TpackageName.."/res/images/fontSunzi.png"
	elseif type == 4 then
		path = TpackageName.."/res/images/fontTonghua.png"
	elseif type == 5 then
		path = TpackageName.."/res/images/fontTonghuasun.png"
	elseif type == 6 then
		path = TpackageName.."/res/images/fontSantiao.png"
	end

	return path
end

function CompCardLayer:playAni(node, pier, uIndex, cardsInfo)
	node:setZOrder(pier)
	local scaleAction1 = cc.ScaleTo:create(self.baseScaleTime, 1.5)
	local scaleAction2 = cc.ScaleTo:create(self.baseScaleTime, 1)
	local times = (pier-1)*(#self.info.userinfos)+(uIndex-1)
	local delay= cc.DelayTime:create(times*2*self.baseScaleTime)
    local callFuncAc = cc.CallFunc:create(function ()
        node:setZOrder(pier)
        handler(self, self.showScoreByIndex)(node, pier)
    end)

    local callFuncAc1 = cc.CallFunc:create(function ()
    	if node.effectPath then
			require("hall.GameCommon"):playEffectSound(node.effectPath)
		end
    	node:setZOrder(10+pier)
    	handler(self, self.setCardsValue)(node, cardsInfo)
    end)
    local se  = cc.Sequence:create(delay,scaleAction1,scaleAction2,callFuncAc)
    local delay1 = cc.DelayTime:create((times)*2*self.baseScaleTime)
    local se1  = cc.Sequence:create(delay1, callFuncAc1)
    node:runAction(se1)
    node:runAction(se)
end

function CompCardLayer:showScoreByIndex(node, pier)
	print("showScoreByIndex --------------", pier)
	if node.uIndex ~= #self.info.userinfos then return end

	local idx = pier
	for i, v in ipairs(self.info.userinfos) do
		local pierNode = COMP_NODE[BIJI_PLAYERTYPE_TABLE[v.uid]]:getChildByName("pier_"..idx)--self["compItem"..tostring(BIJI_PLAYERTYPE_TABLE[v.uid])] 
		local scoreLable = pierNode:getChildByName("score")
		scoreLable:setVisible(true)
		if scoreLable == nil then return end
		-- local tempScore = tonumber(v.chip_list[idx]/100)
		local tempScore = tonumber(v.chip_list[idx])
		local color = v.chip_list[idx] > 0 and cc.c3b(252,255,23) or cc.c3b(30,235,231)
		local scoreStr = tempScore > 0 and "+"..tostring(tempScore) or tempScore
		scoreLable:setColor(color)
		scoreLable:setString(scoreStr)
	end
	--open result
	if pier == 3 and node.uIndex == #self.info.userinfos then
		for k,v in ipairs(self.info.userinfos) do
			--要动画后再显示
        	GamePlaneOperator:setTotalBetChip(BIJI_PLAYERTYPE_TABLE[v.uid], v.m_chips)
		end
		self.delayHandler = scheduler.performWithDelayGlobal(handler(self, self.delayOpenResult), 0.5)
	end
end

function CompCardLayer:delayOpenResult()
	self:init()
	-- self:setVisible(false)
	local layerPath = TpackageName .. ".view.GameResult"
    local resultLayer = require(TpackageName .. ".view.GameResult").new()

    resultLayer:addTo(SCENENOW["scene"], 1000)
    resultLayer:setName("layout_newGameResultLayer")
    resultLayer:init(self.info)
    self.delayHandler = nil
    self.info = nil
end

function CompCardLayer:setUserScoreByPier()
	local idx = self.curPier
	for i, v in ipairs(self.info.userinfos) do
		local pierNode = self["compItem"..tostring(BIJI_PLAYERTYPE_TABLE[v.uid])]:getChildByName("pier_"..idx)
		local scoreLable = pierNode:getChildByName("score")
		if scoreLable == nil then return end
		local color = v.chip_list[idx] > 0 and cc.c3b(0,0,0) or cc.c3b(0,0,0)
		local tempScore = tonumber(v.chip_list[idx]/100)
		local scoreStr = tempScore > 0 and "+"..tostring(tempScore) or tempScore
		scoreLable:setColor(color)
		scoreLable:setString(scoreStr)
	end
end

function CompCardLayer:showCompNodeByUid(userId, idx, cardInfo)
	if idx then
		if idx == 1 then
			self.kanCardsInfo = cardInfo
			self.btnKanpai:setVisible(true)
		end
		
		COMP_NODE[idx]:setVisible(true)
	else
		COMP_NODE[BIJI_PLAYERTYPE_TABLE[userId]]:setVisible(true)
	end
end

function CompCardLayer:playerBeginAniByType(t, handlerFunc, info)
	self.beginAni:setVisible(true)
	self.beginAni:setScale(0.05)
	local base = t == 1 and 1 or 0
	local soundPath = t == 1 and TpackageName.."/sound/gamestart.mp3" or TpackageName.."/sound/start_compare.mp3"
	local imgPath = t == 1 and TpackageName.."/res/images/kaisipaiju.png" or TpackageName.."/res/images/kaisibipai.png"
	self:changeImgByPath(self.beginAni, imgPath)
	require("hall.GameCommon"):playEffectSound(soundPath)
	local scaleAction1 = cc.ScaleTo:create(0.4, 2)
	local scaleAction2 = cc.ScaleTo:create(0.3, 1)
	local scaleAction3 = cc.ScaleTo:create(0.2, 1)
	local callFuncAc = cc.CallFunc:create(function ()
		if t == 2 then
			handler(self, self.toShowOpenCard)()
		else
			self.beginAni:setVisible(false)
			handlerFunc(info)
		end
    end)
	local se  = cc.Sequence:create(scaleAction1,scaleAction2,scaleAction3,callFuncAc)
	self.beginAni:runAction(se)
end

function CompCardLayer:stopAniAndHideSelf()
	self:init()
	if self.info == nil then return end

	self.beginAni:stopAllActions()
	for i = 1, 3 do
		for j = 1, 6 do
			local compItem = COMP_NODE[j]:getChildByName("pier_"..i)
			compItem:stopAllActions()
		end
	end
end

function CompCardLayer:onExit()
	self:init()
end

return CompCardLayer