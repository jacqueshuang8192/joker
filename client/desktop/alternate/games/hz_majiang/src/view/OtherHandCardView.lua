--[[
	其他玩家手牌牌背
--]]
local OtherHandCardView = class("OtherHandCardView")
local PokerCard = require("hz_majiang.src.PokerCard")
local card14 = "card14"
function OtherHandCardView:ctor(inhand_vw, viewId)
	self.inhand_vw = inhand_vw
	self.viewId = viewId
	self.handNodes = {}
	self:clearData()
end

function OtherHandCardView:clearData()
	self.inhand_vw:removeAllChildren()
	self.handNodes = {}
end

function OtherHandCardView:getCardSize(cardNode)
	return cardNode:getContentSize()
end

function OtherHandCardView:showCards(cards)
	self.inhand_vw:removeAllChildren()
	if #cards == 14 then
		table.remove( cards, 1 )
		self:setNewCard()
	end
	local size = self.inhand_vw:getSize()
	local number = table.getn(cards)

    if self.viewId == g_308.viewId_left then
		
        for idx=1,number do
			local cardNode = PokerCard:newInhandBack(self.viewId)
			local cardSize = cardNode:getContentSize()

			local scale = 1
			local cardHeight = 28
			local cardWidth = 9.5 
			local oriX = size.width / 2 
			local oriY = cardSize.height / 2

			local x = oriX + ( idx - 1 ) * cardWidth
			local y = oriY + ( idx - 1 ) * cardHeight
            
            cardNode:setPosition(cc.p(oriX, y))
			cardNode:setRotation(-17)
			cardNode:setZOrder(number - idx)
            self.inhand_vw:addChild(cardNode)
		end
	elseif self.viewId == g_308.viewId_right then
		for idx=1,number do
			local cardNode = PokerCard:newInhandBack(self.viewId)
			local cardSize = cardNode:getContentSize()

			local scale = 1
			local oriX = size.width / 2
			local oriY = size.height - cardSize.height / 2
			local cardHeight = 27
			local cardWidth = 9.5

			local x = oriX + ( idx - 1 ) * cardWidth
			local y = oriY - ( idx - 1 ) * cardHeight
            
			cardNode:setPosition(cc.p(oriX, y))
			cardNode:setRotation(17)
            self.inhand_vw:addChild(cardNode)
		end
	elseif self.viewId == g_308.viewId_top then
        for idx=1,number do
			local cardNode = PokerCard:newInhandBack(self.viewId)
			local cardSize = cardNode:getContentSize()
			local scale = 1
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = cardWidth / 2
			local oriY = size.height / 2

			local x = oriX + ( idx - 1 ) * cardWidth
            
            cardNode:setPosition(cc.p(x, oriY))
            self.inhand_vw:addChild(cardNode)
        end
    end
	self.handNodes = self.inhand_vw:getChildren()
end

function OtherHandCardView:setNewCard()
	local size = self.inhand_vw:getSize()
	local number = -1
	local idx = -1
    if self.viewId == g_308.viewId_left then
		
		local cardNode = PokerCard:newInhandBack(self.viewId)
		cardNode:setName(card14)
		local cardSize = cardNode:getContentSize()

		local scale = 1
		local cardHeight = 28
		local cardWidth = 9.5 
		local oriX = size.width / 2 
		local oriY = cardSize.height / 2

		local x = oriX + ( idx - 1 ) * cardWidth
		local y = oriY + ( idx - 1 ) * cardHeight
		
		cardNode:setPosition(cc.p(oriX, y))
		cardNode:setRotation(-17)
		-- cardNode:setZOrder(number - idx)
		self.inhand_vw:addChild(cardNode)
	elseif self.viewId == g_308.viewId_right then
		local cardNode = PokerCard:newInhandBack(self.viewId)
		cardNode:setName(card14)
		local cardSize = cardNode:getContentSize()

		local scale = 1
		local oriX = size.width / 2
		local oriY = size.height - cardSize.height / 2
		local cardHeight = 27
		local cardWidth = 9.5

		local x = oriX + ( idx - 1 ) * cardWidth
		local y = oriY - ( idx - 1 ) * cardHeight
		
		cardNode:setPosition(cc.p(oriX, y))
		cardNode:setRotation(17)
		self.inhand_vw:addChild(cardNode)
	elseif self.viewId == g_308.viewId_top then
		local cardNode = PokerCard:newInhandBack(self.viewId)
		cardNode:setName(card14)
		local cardSize = cardNode:getContentSize()
		local scale = 1
		local cardHeight = cardSize.height * scale
		local cardWidth = cardSize.width * scale
		local oriX = cardWidth / 2
		local oriY = size.height / 2

		local x = oriX + ( idx - 1 ) * cardWidth
		
		cardNode:setPosition(cc.p(x, oriY))
		self.inhand_vw:addChild(cardNode)
    end
end

function OtherHandCardView:removeHandCardNodes(cards)
	for _,card in ipairs(cards) do
		local idx = #self.handNodes
		local node = table.remove(self.handNodes, idx)
		if node then
			node:removeSelf()
		end
	end
end

function OtherHandCardView:playOutCard(card)
    local newCardNode = self.inhand_vw:getChildByName(card14)
	if newCardNode then
		newCardNode:removeFromParent()
	end
end

--摊牌
function OtherHandCardView:showCardsForAll(cards, newCard)
	self.inhand_vw:removeAllChildren()
	local size = self.inhand_vw:getSize()
	local number = table.getn(cards)

    if self.viewId == g_308.viewId_left then
		for idx, card in ipairs(cards) do
			local cardNode = PokerCard:setCardForAll(self.viewId, card)
			local cardSize = cardNode:getContentSize()

			local scale = 1.3
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = size.width / 2 
			local oriY = cardHeight / 2

			local x = oriX + ( idx - 1 ) * cardWidth
			local y = oriY + ( idx - 1 ) * (cardHeight * 0.65)
            
            cardNode:setPosition(cc.p(oriX, y))
			cardNode:setRotation(-17)
			cardNode:setZOrder(number - idx)
			cardNode:setScale(scale)
            self.inhand_vw:addChild(cardNode)
		end
        
	elseif self.viewId == g_308.viewId_right then
		for idx, card in ipairs(cards) do
			local cardNode = PokerCard:setCardForAll(self.viewId, card)
			local cardSize = cardNode:getContentSize()

			local scale = 1.3
			local oriX = size.width / 2
			local oriY = size.height - cardSize.height / 2
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale

			local x = oriX + ( idx - 1 ) * cardWidth
			local y = oriY - ( idx - 1 ) * (cardHeight * 0.65)
            
			cardNode:setPosition(cc.p(oriX, y))
			cardNode:setRotation(17)
			cardNode:setScale(scale)
            self.inhand_vw:addChild(cardNode)
		end
		
	elseif self.viewId == g_308.viewId_top then
		for idx, card in ipairs(cards) do
			local cardNode = PokerCard:setCardForAll(self.viewId, card)
			local cardSize = cardNode:getContentSize()
			local scale = 1
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = cardWidth / 2
			local oriY = size.height / 2

			local x = oriX + ( idx - 1 ) * (cardWidth * 0.88)
            cardNode:setPosition(cc.p(x, oriY))
			cardNode:setScale(scale)
            self.inhand_vw:addChild(cardNode)
		end
        
	end
	self.handNodes = self.inhand_vw:getChildren()
end

function OtherHandCardView:showNewCardForAll(card)
	local size = self.inhand_vw:getSize()
	local number = -1
	local idx = -0.5
    if self.viewId == g_308.viewId_left then
			local cardNode = PokerCard:setCardForAll(self.viewId, card)
			local cardSize = cardNode:getContentSize()

			local scale = 1.3
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = size.width / 2 
			local oriY = cardHeight / 2

			local x = oriX + ( idx - 1 ) * cardWidth
			local y = oriY + ( idx - 1 ) * (cardHeight * 0.65)
            
            cardNode:setPosition(cc.p(oriX, y))
			cardNode:setRotation(-17)
			cardNode:setZOrder(number - idx)
			cardNode:setScale(scale)
            self.inhand_vw:addChild(cardNode)
        
	elseif self.viewId == g_308.viewId_right then
			local cardNode = PokerCard:setCardForAll(self.viewId, card)
			local cardSize = cardNode:getContentSize()

			local scale = 1.3
			local oriX = size.width / 2
			local oriY = size.height - cardSize.height / 2
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale

			local x = oriX + ( idx - 1 ) * cardWidth
			local y = oriY - ( idx - 1 ) * (cardHeight * 0.65)
            
			cardNode:setPosition(cc.p(oriX, y))
			cardNode:setRotation(17)
			cardNode:setScale(scale)
            self.inhand_vw:addChild(cardNode)
		
	elseif self.viewId == g_308.viewId_top then
			local cardNode = PokerCard:setCardForAll(self.viewId, card)
			local cardSize = cardNode:getContentSize()
			local scale = 1
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = cardWidth / 2
			local oriY = size.height / 2

			local x = oriX + ( idx - 1 ) * (cardWidth * 0.88)
            cardNode:setPosition(cc.p(x, oriY))
			cardNode:setScale(scale)
            self.inhand_vw:addChild(cardNode)
        
    end
end

return OtherHandCardView