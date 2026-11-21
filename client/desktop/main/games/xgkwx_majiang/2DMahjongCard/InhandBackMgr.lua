--[[
	其他玩家手牌牌背
--]]
local InhandBackMgr = class("InhandBackMgr")
local Card = require(TpackageName..".2DMahjongCard.Card")
local NEW_CARD_TAG = 20

function InhandBackMgr:ctor(path)

end

function InhandBackMgr:showCards(playerType, plane, cardDatas)
	local card = Card:newInhandBack(playerType)
	plane:removeAllChildren()
	if #cardDatas == 14 then
		table.remove( cardDatas, 1 )
		InhandBackMgr:setNewCard(playerType, plane)
	end
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local number = table.getn(cardDatas)

    if playerType == CARD_PLAYERTYPE_MY then
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local scale = 1
		cardHeight = 28
		cardWidth = 9.5 
		local oriX = size.width / 2 
		local oriY = 29.50
        for i=1,number do
            local cardData = cardDatas[i]
			local card = Card:newInhandBack(playerType)
			local x = oriX + ( i - 1 ) * cardWidth
			local y = oriY + ( i - 1 ) * cardHeight
            card:setTag(i)
            card:setPosition(cc.p(x, y))
			card:setZOrder(number - i)
            plane:addChild(card)
		end
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local scale = 1
		local oriX = size.width / 2
		local oriY = size.height - cardHeight / 2
		cardHeight = 27
		cardWidth = 9.5
        for i=1,number do
            local cardData = cardDatas[i]
			local card = Card:newInhandBack(playerType)
			local x = oriX + ( i - 1 ) * cardWidth
			local y = oriY - ( i - 1 ) * cardHeight
            card:setTag(i)
			card:setPosition(cc.p(x, y))
			-- card:setZOrder(number - i)
            plane:addChild(card)
		end
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local scale = 1
		cardHeight = cardHeight * scale
		cardWidth = cardWidth * scale
		local oriX = cardWidth / 2
		local oriY = size.height / 2
        for i=1,number do
            local cardData = cardDatas[i]
			local card = Card:newInhandBack(playerType)
			local x = oriX + ( i - 1 ) * cardWidth
            card:setTag(i)
            card:setPosition(cc.p(x, oriY))
            plane:addChild(card)
        end
    end
end

function InhandBackMgr:setNewCard(playerType, plane)
	local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
	if newCardNode then
		newCardNode:removeSelf()
	end
    if playerType == CARD_PLAYERTYPE_MY then
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local card = Card:newInhandBack(playerType)
		local x = 15
		local y = -15
		card:setTag(NEW_CARD_TAG)
		card:setPosition(cc.p(x, y))
		plane:addChild(card)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local card = Card:newInhandBack(playerType)
		local x = 12
		local y = 415
		card:setTag(NEW_CARD_TAG)
		card:setPosition(cc.p(x, y))
		plane:addChild(card)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local card = Card:newInhandBack(playerType)
		local x = -31.96
		local y = 24.50
		card:setTag(NEW_CARD_TAG)
		card:setPosition(cc.p(x, y))
		plane:addChild(card)
    end
end

function InhandBackMgr:playCard(playerType, plane, card)
    local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
	if newCardNode then
		newCardNode:removeFromParent()
		return
	end
	local chlds = plane:getChildren()
	if playerType == CARD_PLAYERTYPE_MY then
    elseif playerType == CARD_PLAYERTYPE_LEFT then
		table.sort(chlds, function(a,b)
			return a:getPositionY() > b:getPositionY()
		end)
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
		table.sort(chlds, function(a,b)
			return a:getPositionY() < b:getPositionY()
		end)
    elseif playerType == CARD_PLAYERTYPE_TOP then
		table.sort(chlds, function(a,b)
			return a:getPositionX() > b:getPositionX()
		end)
	end
	for i,cardNode in ipairs(chlds) do
		cardNode:removeFromParent()
		break
	end
end

--摊牌
function InhandBackMgr:showCardsForAll(playerType, plane, showCards, newCard)
	if playerType == CARD_PLAYERTYPE_MY then
		return
	end
	dump(showCards, newCard)
	dump(playerType,"麻将data------showCards----")
	local chids = plane:getChildren()
	local count = #chids
	local newCardNode = plane:getChildByTag(NEW_CARD_TAG)
	if newCard and newCardNode then
		newCardNode:setCardForAll(playerType, newCard)
		for idx,node in ipairs(chids) do
			if newCardNode == node then
				table.remove(chids, idx)
			end
		end
	end
	local scale = 1
	dump(chids,"-剩余麻将张数-----------------")
	if playerType == CARD_PLAYERTYPE_MY then
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		-- local orlPos = chids[#chids]:getPosition()
		table.sort(chids, function(a,b)
			return a:getPositionY() < b:getPositionY()
		end)
		local orlPos = chids[1]:getPosition()
		for idx, card in ipairs(showCards) do
			local node = chids[idx]
			if node then
				node:setCardForAll(playerType, card)
				-- local orlPos = node:getPosition()
				-- node:setPosition(orlPos.x - (( idx - 1 ) * 2), orlPos.y - (( idx -1 ) * 4) ) 
				-- node:setPosition(orlPos.x - (( idx - 1 ) * 3), orlPos.y + (( idx -1 ) * 4) ) 
				local x = orlPos.x + (( idx - 1 ) * 8 * scale)
				local y = orlPos.y + (( idx - 1 ) * 31 * scale)
				-- local x = orlPos.x + (( idx - 1 ) * 1.5) + 30
				node:setPosition(x, y) 
			end
		end
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		for idx, card in ipairs(showCards) do
			local node = chids[idx]
			if node then
				node:setCardForAll(playerType, card)
				local orlPos = node:getPosition()
				local x = orlPos.x - (( idx - 1 ) * 1 * scale)
				local y = orlPos.y + (( idx -1 ) * -4 * scale)
				node:setPosition(x, y ) 
			end
		end
	elseif playerType == CARD_PLAYERTYPE_TOP then
		for idx, card in ipairs(showCards) do
			local node = chids[idx]
			if node then
				local scale = 1
				node:setCardForAll(playerType, card)
				local orlPos = node:getPosition()
				node:setPosition((orlPos.x - (( idx - 3 ) * - 7)) *scale, orlPos.y*scale )
				node:setScale(scale)
			end
		end
		if newCardNode and newCard then
			-- local orlPos = newCardNode:getPosition()
			-- newCardNode:setPosition(orlPos.x - (( - 3) * -7), orlPos.y )
			local orlPos = newCardNode:getContentSize()
    		newCardNode:setPositionX(-orlPos.width) 
		end
    end
end

return InhandBackMgr