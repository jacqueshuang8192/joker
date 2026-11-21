--[[
	玩家已经出的牌
--]]
local Card = require(TpackageName..".2DMahjongCard.Card")
local NewViewBaseLayer = require("hall.NewViewBaseLayer")
local Card = require(TpackageName..".2DMahjongCard.Card")
local OutCardMgr = class("OutCardMgr", NewViewBaseLayer)
local NEW_CARD_TAG = 20
function OutCardMgr:ctor()
    local csbPath = TpackageName.."/res/GameScene/GameScene.csb"
	OutCardMgr.super.ctor(self, csbPath, false, false)
	local size = self._csbNode:getContentSize()
	GameUtils.setNodeNameBindObj(self._csbNode)
	self._scene = self._csbNode
	self.tableNodes = {}
	self:initUI()
end

function OutCardMgr:initUI(plane)
	self._scene.hall:hide()
	self._scene.hupai_vw:hide()
	self._scene.zhama_vw:hide()
	local nodes = {
		self._scene.players.my_card_plane.outhand_plane,
		self._scene.players.left_card_plane.outhand_plane,
		self._scene.players.top_card_plane.outhand_plane,
		self._scene.players.right_card_plane.outhand_plane,
	}
	for i,outhand_plane in ipairs(nodes) do
		if not outhand_plane.outCardNodeStartPos then
			local pos = outhand_plane.outCardNode:getPosition()
			-- local pos = (outhand_plane):convertToWorldSpace(outhand_plane.outCardNode:getPosition()) --这样写是为了贴近函数的原始用法
			outhand_plane.outCardNodeStartPos = pos
			outhand_plane:removeAllChildren()
		end
	end
end

function OutCardMgr:clearHandCards(plane)
	-- local cardNode = plane:getChildByTag(NEW_CARD_TAG)
	-- if cardNode then
	-- 	cardNode:removeFromParent()
	-- else
	-- 	local chids = plane:getChildren()
	-- 	local node = chids[#chids]
	-- 	if node then
	-- 		node:removeSelf()
	-- 	end
	-- end
end

function OutCardMgr:playOutCard( playerType, plane, cardData )
	
	local number = plane:getChildrenCount() + 1
	local cardDatas = {}
	cardDatas[number] = cardData
	local outCardNode = self:showOutCards(playerType, plane, cardDatas, number)
	local OrlPos = outCardNode:getPosition()
	D3_WAIT_OPRATE_CARD = outCardNode

	local startPos = outCardNode:getParent().outCardNodeStartPos
	outCardNode:stopAllActions()
	local Scale = outCardNode:getScale()
	outCardNode:setScale(Scale * 1.5)
	outCardNode:setPosition(startPos)
	local zindex = outCardNode:getZOrder()
	outCardNode:setZOrder(999)
	YLMJ_CARD_POINTER:setVisible(false)

	local size = outCardNode:getSize()
    local MoveTo = cc.MoveTo:create(0.2, OrlPos)
    local ScaleTo = cc.ScaleTo:create(0.6, Scale)
	local CallFunc = cc.CallFunc:create(function()
		local parent = outCardNode:getParent()
		local pos = (parent):convertToWorldSpace(outCardNode:getPosition()) --这样写是为了贴近函数的原始用法
		local newPos = parent:getParent():getParent():convertToNodeSpace(pos)

		-- players
		newPos.y = newPos.y + size.height / 2
		YLMJ_CARD_POINTER:setVisible(true)
		YLMJ_CARD_POINTER:setPosition(newPos)
		outCardNode:setZOrder(zindex)
	end)
	local Sequence = cc.Sequence:create(MoveTo,CallFunc,ScaleTo)
	outCardNode:runAction(Sequence)
end

function OutCardMgr:showOutCards(playerType, plane, cardDatas, number)
	local lastOutCardNode = nil
	local card = Card:newOutCard(playerType,{m_value = 1})
	local cardsIdx = number
	local zIdx = 1
	if not number then
		number = table.getn(cardDatas)
		cardsIdx = 1
		plane:removeAllChildren()
	else
		zIdx = number
	end
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width

	if playerType == CARD_PLAYERTYPE_MY then
		local scale = 1.13

		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth
		local intevalWidth = 40 * scale
		local intevalHeight = 38 * scale
		local oriX = cardWidth / 2
		local oriY = size.height - cardHeight / 2
		local col = 4
		local row = 9
		if YL_PLAYER_COUNT <= 2 then
			row = 14
		end
		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]
			-- local colIdx = idx % col
			-- colIdx = colIdx == 0 and col or colIdx
			local rowIdx = idx % row
			rowIdx = rowIdx == 0 and row or rowIdx
			local colIdx = math.ceil(idx/ row)
			local card = Card:newOutCard(playerType, cardData)
			if colIdx >= 4 then
				colIdx = 4-colIdx
				card:setZOrder(-zIdx)
				zIdx = zIdx + 1
			end
			local x = oriX + (rowIdx - 1) * intevalWidth
			local y = oriY - (colIdx - 1) * intevalHeight
            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			plane:addChild(card)
			lastOutCardNode = card
		end
	
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local scale = 1.2
		local intevalWidth = 43 * scale
		local intevalHeight = 25 * scale
		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth
		local oriX = size.width - cardWidth / 2
		local oriY = size.height - cardHeight / 2
		local col = 9--一列有9个
		local row = 4
		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]
			local colIdx = idx % col
			colIdx = colIdx == 0 and col or colIdx
			-- local rowIdx = idx % row
			-- rowIdx = rowIdx == 0 and row or rowIdx
			local rowIdx = math.ceil(idx / col)
			local x = oriX - (rowIdx - 1) * intevalWidth - 1.5 * (colIdx - 1)
			local y = oriY - (colIdx - 1) * intevalHeight
			local card = Card:newOutCard(playerType, cardData)
            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			plane:addChild(card)
			-- card:setZOrder(zIdx * -colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = card
		end
	
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local scale = 1.2
		local intevalWidth = 44 * scale
		local intevalHeight = 25 * scale
		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth
		local oriX = cardWidth / 2
		local oriY = cardHeight / 2
		local col = 9--一列有9个
		local row = 4
		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]
			local colIdx = idx % col
			colIdx = colIdx == 0 and col or colIdx
			-- local rowIdx = idx % row
			-- rowIdx = rowIdx == 0 and row or rowIdx
			local rowIdx = math.ceil(idx / col)
			local x = oriX + (rowIdx - 1) * intevalWidth - 2 * (colIdx - 1)
			local y = oriY + (colIdx - 1) * intevalHeight
			local card = Card:newOutCard(playerType, cardData)
            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			plane:addChild(card)
			card:setZOrder(zIdx * -colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = card
		end

	elseif playerType == CARD_PLAYERTYPE_TOP then
		local scale = 0.98
		local intevalWidth = 40 * scale
		local intevalHeight = 38 * scale
		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth
		local oriX = size.width - cardWidth / 2
		local oriY = cardHeight / 2
		local col = 4
		local row = 9
		
		if YL_PLAYER_COUNT <= 2 then
			row = 14
		end
		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]
			-- local colIdx = idx % col
			-- colIdx = colIdx == 0 and col or colIdx
			local rowIdx = idx % row
			rowIdx = rowIdx == 0 and row or rowIdx
			local colIdx = math.ceil(idx/ row)
			local card = Card:newOutCard(playerType, cardData)
		
			if colIdx >= 4 then
				colIdx = 4-colIdx
				card:setZOrder(zIdx)
			end
			local x = oriX - (rowIdx - 1) * intevalWidth
			local y = oriY + (colIdx - 1) * intevalHeight

            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			plane:addChild(card)
			card:setZOrder(zIdx * -colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = card
		end
	end
	return lastOutCardNode
end

function OutCardMgr:showSelectedCards(cardValue)
    self:revertHighlightOutCards()
    D3_HIGHLIGHT_OUT_CARDS = {}
    for i,v in ipairs(D3_OUTHAND_ARR) do
        if v then
            --todo
            local children = v:getChildren()
            for i1,v1 in ipairs(children) do
                if v1.m_value == cardValue then
                    v1:setColor(cc.c3b(144, 238, 144))
                    table.insert(D3_HIGHLIGHT_OUT_CARDS, v1)
                end
            end
        end
    end
end

function OutCardMgr:revertHighlightOutCards()
    for i,v in ipairs(D3_HIGHLIGHT_OUT_CARDS) do
        if v then
            --todo
            v:setColor(cc.c3b(255, 255, 255))
        end
    end
end

function OutCardMgr:showMyCards(plane, cardDatas)
	if not plane then
		dump()
	end
	-- self:(plane)
	local card = Card:newMyInHandCard({m_value = 1})
	plane:removeAllChildren()
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local number = table.getn(cardDatas)
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = size.width - cardWidth / 2
	local oriY = cardHeight / 2
	for i=1,number do
		local cardData = cardDatas[i]
		local card = Card:newMyInHandCard(cardData)
		local x = oriX - ( i - 1 ) * cardWidth
		card:setTag(i)
		card:setPosition(cc.p(x, oriY))
		plane:addChild(card)
	end
end

return OutCardMgr