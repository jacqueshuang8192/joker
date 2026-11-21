--[[
	玩家已经出的牌
--]]
local Card = require(TpackageName..".2DMahjongCard.Card")
local ClickCardView = require(TpackageName..".2DMahjongCard.ClickCardView")
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

	--出的牌 显示的位置
	local outCardNode = self:showOutCards(playerType, plane, cardDatas, number)

	local OrlPos = outCardNode:getPosition()
	D3_WAIT_OPRATE_CARD = outCardNode

	local startPos = outCardNode:getParent().outCardNodeStartPos
	outCardNode:stopAllActions()

	local Scale = outCardNode:getScale()
	outCardNode:setPosition(OrlPos)
	outCardNode:setScale(Scale)
	do
		if playerType == CARD_PLAYERTYPE_TOP or playerType == CARD_PLAYERTYPE_MY then
			outCardNode:setRotation(-90)
		end
		local size = outCardNode:getSize()
		size.width = 0.6*size.width 
		size.height = 0.6* size.height 
		local parent = outCardNode:getParent()
		local pos = (parent):convertToWorldSpace(outCardNode:getPosition()) --这样写是为了贴近函数的原始用法
		local newPos = parent:getParent():getParent():convertToNodeSpace(pos)
		if playerType == CARD_PLAYERTYPE_TOP or playerType == CARD_PLAYERTYPE_MY then
			newPos.x = newPos.x - size.width* 0.7
			newPos.y = newPos.y + size.width *0.4
			XPLPMJ_CARD_POINTER:setRotation(0)
		else
			if playerType == CARD_PLAYERTYPE_RIGHT then
				XPLPMJ_CARD_POINTER:setRotation(-90)
				newPos.y = newPos.y + size.height * 0.25
				newPos.x = newPos.x - size.width
			elseif playerType == CARD_PLAYERTYPE_LEFT then
				XPLPMJ_CARD_POINTER:setRotation(90)
				newPos.y = newPos.y + size.height * 0.25
				newPos.x = newPos.x + size.width
			end
		end
		--这是那个指向牌的黄色的点点
		XPLPMJ_CARD_POINTER:setVisible(true)
		XPLPMJ_CARD_POINTER:setPosition(newPos)
		return
	end
	local zindex = outCardNode:getZOrder()
	outCardNode:setZOrder(999)
	XPLPMJ_CARD_POINTER:setVisible(false)

	local size = outCardNode:getSize()
	local delayTo = cc.DelayTime:create(1)
    local MoveTo = cc.MoveTo:create(0.1, OrlPos)
    local ScaleTo = cc.ScaleTo:create(0.05, Scale)
    size.width = 0.6*size.width 
    size.height = 0.6* size.height 

	local CallFunc = cc.CallFunc:create(function()
		if playerType == CARD_PLAYERTYPE_TOP or playerType == CARD_PLAYERTYPE_MY then
			outCardNode:setRotation(-90)
		end

		local parent = outCardNode:getParent()
		local pos = (parent):convertToWorldSpace(outCardNode:getPosition()) --这样写是为了贴近函数的原始用法
		local newPos = parent:getParent():getParent():convertToNodeSpace(pos)

		if playerType == CARD_PLAYERTYPE_TOP or playerType == CARD_PLAYERTYPE_MY then
			newPos.x = newPos.x - size.width* 0.7
			newPos.y = newPos.y + size.width *0.4
			XPLPMJ_CARD_POINTER:setRotation(0)
		else

			if playerType == CARD_PLAYERTYPE_RIGHT then
				XPLPMJ_CARD_POINTER:setRotation(-90)
				newPos.y = newPos.y + size.height * 0.25
				newPos.x = newPos.x - size.width
			elseif playerType == CARD_PLAYERTYPE_LEFT then
				XPLPMJ_CARD_POINTER:setRotation(90)
				newPos.y = newPos.y + size.height * 0.25
				newPos.x = newPos.x + size.width
			end
		end

		
		--这是那个指向牌的黄色的点点
		XPLPMJ_CARD_POINTER:setVisible(true)
		XPLPMJ_CARD_POINTER:setPosition(newPos)


		--outCardNode:setZOrder(zindex)
	end)
	local Sequence = cc.Sequence:create(delayTo,MoveTo,ScaleTo,CallFunc)
	outCardNode:runAction(Sequence)
end

function OutCardMgr:showOutCards(playerType, plane, cardDatas, number)
	local lastOutCardNode = nil
	local card = Card:newOutCard(playerType,{m_value = 1})

	local cardsIdx = number
	local zIdx = 1
	local setRotate = false
	if not number then
		--这是直接加载的 出牌区的牌
		number = table.getn(cardDatas)
		cardsIdx = 1
		plane:removeAllChildren()
		setRotate = true
	else
		zIdx = number
	end

	local intervalScale = 0.3
	local showScale = 0.6

	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width

	if playerType == CARD_PLAYERTYPE_MY then
		
		local scale = showScale

		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth

		local intevalWidth = 42
		local intevalHeight = cardWidth

		local oriX = -cardWidth / 2
		local oriY = cardHeight / 2

		local col = 2
		local row = 15

		if XPLP_PLAYER_COUNT <= 2 then
			oriX = -cardWidth
			row = 18
		end

		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]

			local rowIdx = idx % row
			rowIdx = rowIdx == 0 and row or rowIdx

			local colIdx = math.ceil(idx/ row)
			local card = Card:newOutCard(playerType, cardData)
			if setRotate then
				card:setRotation(-90)
			end

			local x = oriX + (rowIdx - 1) * intevalWidth
			local y = oriY + (colIdx - 1) * intevalHeight

            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			plane:addChild(card)
			card:onClick(handler(self, self.onClickCard))
			lastOutCardNode = card
		end
	
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local scale = showScale

		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth

		local intevalWidth = 42 + 10
		local intevalHeight = 42

		local oriX = cardWidth / 2
		local oriY = size.height - cardHeight / 2

		local col = 10--一列有9个
		local row = 4

		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]
			local colIdx = idx % col
			colIdx = colIdx == 0 and col or colIdx

			local rowIdx = math.ceil(idx / col)

			local x = oriX + (rowIdx - 1) * intevalWidth 
			local y = oriY - (colIdx - 1) * intevalHeight

			local card = Card:newOutCard(playerType, cardData)
			card:onClick(handler(self, self.onClickCard))
            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			plane:addChild(card)
			-- card:setZOrder(zIdx * -colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = card
		end
	
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local scale = showScale
		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth
		
		local intevalWidth = 42 + 10
		local intevalHeight = 42

		local oriX = size.width - cardWidth / 2
		local oriY = size.height - cardHeight / 2

		local col = 10--一列有9个
		local row = 4

		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]
			local colIdx = idx % col
			colIdx = colIdx == 0 and col or colIdx

			local rowIdx = math.ceil(idx / col)

			local x = oriX - (rowIdx - 1) * intevalWidth
			local y = oriY - (colIdx - 1) * intevalHeight

			local card = Card:newOutCard(playerType, cardData)
			card:onClick(handler(self, self.onClickCard))
            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			plane:addChild(card)
			--card:setZOrder(zIdx * -colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = card
		end

	elseif playerType == CARD_PLAYERTYPE_TOP then
		local scale = showScale

		cardHeight = scale * cardHeight
		cardWidth = scale * cardWidth

		local intevalWidth = 42
		local intevalHeight = cardWidth

		local oriX = -cardWidth / 2
		local oriY = size.height - cardHeight / 2

		local col = 2
		local row = 15

		if XPLP_PLAYER_COUNT <= 2 then
			oriX = -cardWidth
			row = 18
		end

		for idx = cardsIdx, number do
			local cardData = cardDatas[idx]

			local rowIdx = idx % row
			rowIdx = rowIdx == 0 and row or rowIdx

			local colIdx = math.ceil(idx/row)
			local card = Card:newOutCard(playerType, cardData)
			if setRotate then
				card:setRotation(-90)
			end

			colIdx = colIdx - 1
			
			local x = oriX + (rowIdx - 1) * intevalWidth
			local y = oriY - colIdx*intevalHeight

            card:setPosition(cc.p(x, y))
			card:setScale(scale)
			card:onClick(handler(self, self.onClickCard))
			plane:addChild(card)
			--card:setZOrder(zIdx * - colIdx)
			zIdx = zIdx + 1
			lastOutCardNode = card
		end
	end
	return lastOutCardNode
end

function OutCardMgr:onClickCard(event)
	local target = event.target
	local parent = target:getParent()
	local chil = parent:getChildren()
	local cards = {}
	for i,v in ipairs(chil) do
		table.insert(cards, v.m_value)
	end
	ClickCardView.new(cards):addTo(SCENENOW.scene)
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