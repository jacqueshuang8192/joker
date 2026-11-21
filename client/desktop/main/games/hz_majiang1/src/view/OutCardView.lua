--[[
	玩家已经出的牌
--]]
local PokerCard = require("hz_majiang.src.PokerCard")
local OutCardView = class("OutCardView")

function OutCardView:ctor(out_cards_vw, card_pointer, viewId)
	self.card_pointer = card_pointer
	self.out_cards_vw = out_cards_vw
	self.viewId = viewId
	self.startPos = self.out_cards_vw.outCardNode:getPosition()
	self.name = self.out_cards_vw:getName()
    self:clearData()
end

function OutCardView:clearData()
	self.out_cards_vw:removeAllChildren()
	self.card_pointer:hide()
end

function OutCardView:playOutCard(cardValue)
	self.card_pointer:setVisible(false)
	local outCardNode = self:showOutCards({cardValue})
	local OrlPos = outCardNode:getPosition()
	local Scale = outCardNode:getScale()
	outCardNode:setScale(Scale * 1.5)
	outCardNode:setPosition(self.startPos)

	local zindex = outCardNode:getZOrder()
	outCardNode:setZOrder(999)
	local size = outCardNode:getSize()

    local MoveTo = cc.MoveTo:create(0.2, OrlPos)
    local ScaleTo = cc.ScaleTo:create(0.6, Scale)
	local CallFunc = cc.CallFunc:create(function()
		local pos = (outCardNode:getParent()):convertToWorldSpace(outCardNode:getPosition())
		local pos = (self.out_cards_vw:getParent():getParent()):convertToNodeSpace(pos)
		pos.y = pos.y + size.height / 2
		self.card_pointer:setVisible(true)
		self.card_pointer:setPosition(pos)
		outCardNode:setZOrder(zindex)
	end)
	local Sequence = cc.Sequence:create(MoveTo,CallFunc,ScaleTo)
	outCardNode:runAction(Sequence)
end

function OutCardView:showOutCards(cards)
	local lastOutCardNode
	local startIdx = self.out_cards_vw:getChildrenCount()
	local zIdx = #cards + startIdx
	local size = self.out_cards_vw:getSize()

	if self.viewId == g_308.viewId_my then
		local scale = 1
		local col = 4
		local row = 9
		if g_308.TOTAL_PLAYERNUM <= 2 then
			row = 15
		end
		for index, cardValue in ipairs(cards) do
			local idx = index + startIdx
			local cardNode = PokerCard:newOutCard(self.viewId, cardValue)

			local cardHeight = cardNode:getContentSize().height
			local cardWidth = cardNode:getContentSize().width
			cardHeight = scale * cardHeight
			cardWidth = scale * cardWidth
			local intevalWidth = cardWidth - 5 * scale
			local intevalHeight = cardHeight - 15 * scale
			local oriX = cardWidth / 2
			local oriY = size.height - cardHeight / 2

			local rowIdx = idx % row
			rowIdx = rowIdx == 0 and row or rowIdx
			local colIdx = math.ceil(idx / row)
			if colIdx >= 4 then
				colIdx = 4-colIdx
				cardNode:setZOrder(-zIdx)
				zIdx = zIdx + 1
			end
			local x = oriX + (rowIdx - 1) * intevalWidth
			local y = oriY - (colIdx - 1) * intevalHeight
            cardNode:setPosition(cc.p(x, y))
			cardNode:setScale(scale)
			self.out_cards_vw:addChild(cardNode)
			lastOutCardNode = cardNode
		end
	elseif self.viewId == g_308.viewId_left then
		local scale = 1.1
		
		local col = 9--一列有9个
		local row = 4
		for index, cardValue in ipairs(cards) do
			local idx = index + startIdx
			local cardNode = PokerCard:newOutCard(self.viewId, cardValue)

			local cardHeight = cardNode:getContentSize().height
			local cardWidth = cardNode:getContentSize().width
			local intevalWidth = cardWidth
			local intevalHeight = cardHeight - 10 * scale
			cardHeight = scale * cardHeight
			cardWidth = scale * cardWidth
			local oriX = size.width - cardWidth / 2
			local oriY = size.height - cardHeight / 2

			local colIdx = idx % col
			colIdx = colIdx == 0 and col or colIdx
			local rowIdx = math.ceil(idx / col)
			local x = oriX - (rowIdx - 1) * intevalWidth - 1.5 * (colIdx - 1)
			local y = oriY - (colIdx - 1) * intevalHeight
            cardNode:setPosition(cc.p(x, y))
			cardNode:setScale(scale)
			self.out_cards_vw:addChild(cardNode)
			zIdx = zIdx + 1
			cardNode:setZOrder(-rowIdx)
			lastOutCardNode = cardNode
		end
	
	elseif self.viewId == g_308.viewId_right then
		local scale = 1.1
		local col = 9--一列有9个
		local row = 4
		for index, cardValue in ipairs(cards) do
			local idx = index + startIdx
			local cardNode = PokerCard:newOutCard(self.viewId, cardValue)

			local cardHeight = cardNode:getContentSize().height
			local cardWidth = cardNode:getContentSize().width
			local intevalWidth = cardWidth - 2 * scale
			local intevalHeight = cardHeight - 10 * scale
			cardHeight = scale * cardHeight
			cardWidth = scale * cardWidth
			local oriX = cardWidth / 2
			local oriY = cardHeight / 2

			local colIdx = idx % col
			colIdx = colIdx == 0 and col or colIdx
			local rowIdx = math.ceil(idx / col)
			local x = oriX + (rowIdx - 1) * intevalWidth - 2 * (colIdx - 1)
			local y = oriY + (colIdx - 1) * intevalHeight
            cardNode:setPosition(cc.p(x, y))
			cardNode:setScale(scale)
			self.out_cards_vw:addChild(cardNode)
			cardNode:setZOrder(zIdx * -colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = cardNode
		end
	elseif self.viewId == g_308.viewId_top then
		local scale = 0.85
		
		local col = 4
		local row = 9
		if g_308.TOTAL_PLAYERNUM <= 2 then
			row = 15
		end
		for index, cardValue in ipairs(cards) do
			local idx = index + startIdx
			local cardNode = PokerCard:newOutCard(self.viewId, cardValue)

			local cardHeight = cardNode:getContentSize().height
			local cardWidth = cardNode:getContentSize().width
			local intevalWidth = (cardWidth - 3.5) * scale
			local intevalHeight = (cardHeight - 9) * scale

			cardHeight = scale * cardHeight
			cardWidth = scale * cardWidth
			local oriX = size.width - cardWidth / 2
			local oriY = cardHeight / 2

			local rowIdx = idx % row
			rowIdx = rowIdx == 0 and row or rowIdx
			local colIdx = math.ceil(idx/ row)
			if colIdx >= 4 then
				colIdx = 4-colIdx
				cardNode:setZOrder(zIdx)
			end
			local x = oriX - (rowIdx - 1) * intevalWidth
			local y = oriY + (colIdx - 1) * intevalHeight

            cardNode:setPosition(cc.p(x, y))
			cardNode:setScale(scale)
			self.out_cards_vw:addChild(cardNode)
			cardNode:setZOrder(zIdx * -colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = cardNode
		end
	end
	self.lastOutCardNode = lastOutCardNode
	return lastOutCardNode
end

function OutCardView:removeCard(cardValue)
	if not tolua.isnull(self.lastOutCardNode) then
		self.lastOutCardNode:removeSelf()
		self.lastOutCardNode = nil
		self.card_pointer:hide()
	end
end

function OutCardView:showSelectedCards(cardValue)
	local childs = self.out_cards_vw:getChildren()
	for i1,v1 in ipairs(childs) do
		if v1._cardValue == cardValue then
			v1:setColor(cc.c3b(144, 238, 144))
		else
			v1:setColor(cc.c3b(255, 255, 255))
		end
	end
end

function OutCardView:getCards()
	local childs = self.out_cards_vw:getChildren()
	local cards = {}
	for i1,v1 in ipairs(childs) do
		table.insert(cards, v1._cardValue)
	end
	return cards
end

return OutCardView