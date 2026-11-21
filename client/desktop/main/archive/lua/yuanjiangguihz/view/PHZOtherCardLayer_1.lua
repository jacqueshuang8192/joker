local GameLogic = require("yuanjiangguihz.logic.GameLogic")
local CardConfig = require("yuanjiangguihz.logic.CardConfig")
local MCardWid = 32
local DI_CARD_SCALE = 0.3
local cardW = 30
local cardH = 145

local PHZOtherCardLayer = class("PHZOtherCardLayer", function ()
   return cc.CSLoader:createNode("yuanjiangguihz/res/PHZOtherCardLayer.csb")
end)

function PHZOtherCardLayer:ctor(data,diCardData)
	self.data = data
	self.diCardData = diCardData
	self:setNodeEventEnabled(true)

	self.m_GameLogic = GameLogic:new()
	self.m_CardConfig = CardConfig:new()

	self:initUI()
	g_PHZMainScene:setRootSize(self)
end

function PHZOtherCardLayer:onEnter()
end

function PHZOtherCardLayer:onExit()
	local children = self.m_diCardBg:getChildren()
    for i,v in ipairs(children) do
        if not v then return end
        v:stopAllActions()
    end
end

function PHZOtherCardLayer:initUI()
	self.m_cardBg = {}
    for i=1,2 do
    	self.m_cardBg[i] = self:getChildByName("v_"..i)
    end

    for k,v in pairs(self.data) do
    	if v.uid ~= USER_INFO.uid then
			local temp_sead_id = g_PHZMainScene.otherInfo[v.uid].seat_id
	    	local wViewId = g_PHZMainScene:getViewChairId(temp_sead_id)
	    	local weaveItem = self.m_GameLogic:getCurhandCard(v.handCardArr)
			dump(weaveItem)
	    	self:showWeaveCard(wViewId,weaveItem,v.uid)
    	end
    end
    self.m_diCardBg = self:getChildByName("v_0")
    self:showDiCard(self.diCardData)
end

--显示玩家手中剩余的牌
function PHZOtherCardLayer:showWeaveCard(wViewId,weaveItem,uid)
	self.m_cardBg[wViewId]:removeAllChildren()
	for k,v in pairs(weaveItem) do
		for k1,v1 in pairs(v) do
			local x = MCardWid/2 + (k-1)*MCardWid
			if wViewId == 2 then
				local tempSize = self.m_cardBg[wViewId]:getContentSize().width
	            x = tempSize - MCardWid/2 - (k-1)*MCardWid
			end
			local y = MCardWid/2 + (k1-1)*MCardWid
	        local imgPath = "yuanjiangguihz/res/CardLitter/Card_miniature_000.png"
			local cardInfo = self.m_CardConfig:getCardInfoByid(v1)
			if cardInfo then
	            imgPath = string.format("%s.png",cardInfo.CardIconA)
	        end
			local cardObj = display.newSprite()
	        local frame = display.newSpriteFrame(imgPath)
	        cardObj:setSpriteFrame(frame)
	        cardObj:setPosition(x,y)
	        self.m_cardBg[wViewId]:addChild(cardObj,10-k1)
		end
	end
end

--显示底牌
function PHZOtherCardLayer:showDiCard(weaveItem)
	self.m_diCardBg:removeAllChildren()
	local cardNum = #weaveItem
	local addX = (20-cardNum)*cardW/2
	for k,v in pairs(weaveItem) do
		local x = (k-1)*cardW+addX
		local y = cardH*0.5
		local imgPath = "yuanjiangguihz/res/CardLitter/Card_miniature_000.png"
		local cardInfo = self.m_CardConfig:getCardInfoByid(v)
		if cardInfo then
            imgPath = string.format("%s.png",cardInfo.CardIconC)
        end
        local cardObj = display.newSprite()
        local frame = display.newSpriteFrame(imgPath)
        cardObj:setSpriteFrame(frame)
        cardObj:setPosition(x,y)
        cardObj:setScale(DI_CARD_SCALE)
        cardObj:setVisible(false)
        self.m_diCardBg:addChild(cardObj)

        local callFuncAc = cc.CallFunc:create(function ()
            cardObj:setVisible(true)
        end)
        local delay= cc.DelayTime:create(k* 0.05)
        local seq  = cc.Sequence:create(delay,callFuncAc)

        cardObj:runAction(seq)
	end
end

return PHZOtherCardLayer	