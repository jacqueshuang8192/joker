local Card = require("mhxl_majiang.card.card")
local cardUtils = require("mhxl_majiang.utils.cardUtils")

local InhandPlaneOperator = class("InhandPlaneOperator")

local SPLIT_NEWCARD = 25

local selectedTag = 99

local NEW_CARD_TAG = 20

local cardTemp = nil

function InhandPlaneOperator:init(playerType, plane)
	planeTemp = plane

	plane:removeAllChildren()

	-- if playerType == CARD_PLAYERTYPE_MY then
	-- 	--todo
	-- 	plane:setSize(cc.size(0, plane:getSize().height))
	-- elseif playerType == CARD_PLAYERTYPE_LEFT then
	-- 	plane:setSize(cc.size(plane:getSize().width, 0))
	-- elseif playerType == CARD_PLAYERTYPE_RIGHT then
	-- 	plane:setSize(cc.size(plane:getSize().width, 0))
	-- elseif playerType == CARD_PLAYERTYPE_TOP then
	-- 	plane:setSize(cc.size(0, plane:getSize().height))
	-- end
	
end

function InhandPlaneOperator:revertOutCardPosition()
	if cardTemp and self.oriSelectedPosition then
		--todo
		selectedTag = 99
		cardTemp:setPosition(self.oriSelectedPosition)
	end
end

function InhandPlaneOperator:showHuCard(playerType, plane, value)
	local cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)

	if value == XLMH_LAIZI then
		cardData = D3_CARDDATA:new(value, 0, CARDNODE_TYPE_LAIZI)
	end

	D3_OPERATOR:getNewCard(playerType, plane, cardData, true)
end

function InhandPlaneOperator:showCards(playerType, plane, cardDatas, tingFlag)
	table.sort(cardDatas)

	local cardsSeq = {}
	local laiziSeq = {}
	--癞子放到左侧
	for k,v in pairs(cardDatas) do
        if v == XLMH_LAIZI then
			local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)

			table.insert(laiziSeq, 1, cardData)
		else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(cardsSeq, cardData)
		end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(cardsSeq, 1, v)
	end

	D3_OPERATOR:showCards(playerType, plane, cardsSeq)
end

function InhandPlaneOperator:showCardsForAll(playerType, plane, cardDatas, anke, liangCards)
	table.sort(cardDatas)

	local cardsSeq = {}
	local laiziSeq = {}
	--癞子放到左侧
	for k,v in pairs(cardDatas) do
        if v == XLMH_LAIZI then
			local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)

			table.insert(laiziSeq, 1, cardData)
		else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(cardsSeq, cardData)
		end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(cardsSeq, 1, v)
	end

	local anCards = {}
	laiziSeq = {}

	for i,v in ipairs(anke) do
		if v == XLMH_LAIZI then
			local cardData = D3_CARDDATA:new(v, 0, CARDNODE_TYPE_LAIZI)

			table.insert(laiziSeq, 1, cardData)
		else
			local cardData = D3_CARDDATA:new(v, 1, CARDNODE_TYPE_NORMAL)

			table.insert(anCards, cardData)
		end
	end

	for i,v in ipairs(laiziSeq) do
		table.insert(anCards, 1, v)
	end

	D3_OPERATOR:showCardsForAll( playerType, plane, anCards, cardsSeq )
end

function InhandPlaneOperator:getNewCard(playerType, plane, value)

	local cardData = nil

	if value == XLMH_LAIZI then
		cardData = D3_CARDDATA:new(value, 0, CARDNODE_TYPE_LAIZI)
	else
		cardData = D3_CARDDATA:new(value, 1, CARDNODE_TYPE_NORMAL)
	end

	D3_OPERATOR:getNewCard(playerType, plane, cardData, false)
	
end

function InhandPlaneOperator:showTingCards(plane, cards, tingSeq)
	plane:removeAllChildren()

	selectedTag = 99

	local oriX = 0
	local oriY = plane:getSize().height / 2

		for i=1,table.getn(cards) do
			local data = cards[i]

			local isTing = false

			for k,v in pairs(tingSeq) do
				if data == v.card then
					--todo
					isTing = true
					break
				end
			end

			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)
			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))
			card:setTag(i)

			if isTing then
				--todo
				card:setTouchEnabled(true)

				card:addTouchEventListener(function(sender, event)

				

				if event == TOUCH_EVENT_ENDED then
					--todo
					print("card value")
					dump(sender.m_value, "card value") 
					dump(sender:getAnchorPoint())

					
					if selectedTag == sender:getTag() then
						
							-- dump(sender.m_value, "liang card test")
							-- XLMH_CONTROLLER:requestLiang(sender.m_value)
							
						else
							self:cancelSelectingCard(plane)

							local p = sender:getPosition()

							-- sender:setScale(1.2)
							-- local offsetX = 0.1 * sender:getSize().width

							-- sender:setPosition(cc.p(p.x + offsetX / 2, p.y + 30))
							sender:setPosition(cc.p(p.x, p.y + 30))

							local tag = sender:getTag()
							selectedTag = tag
							-- tag = tag + 1
							-- local nextCard = plane:getChildByTag(tag)
							-- while nextCard do
							-- 	--todo
							-- 	nextCard:setPosition(cc.p(nextCard:getPosition().x + offsetX, nextCard:getPosition().y))

							-- 	tag = tag + 1
							-- 	nextCard = plane:getChildByTag(tag)
							-- end

							for k,v in pairs(tingSeq) do
								if v.card == sender.m_value then
									--todo
									XLMH_CONTROLLER:showComponentSelectBox(v)

									break
								end
							end
						end
				end

				end)
			else
				card:setTouchEnabled(false)
				card:setColor(cc.c3b(150, 150, 150))
			end

			card:setTag(i)

			plane:addChild(card)

			oriX = oriX + card:getSize().width * card:getScale()
		end

		local width = oriX
		plane:setSize(cc.size(width, plane:getSize().height))
end

return InhandPlaneOperator