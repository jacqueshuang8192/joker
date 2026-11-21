--[[
	自己的手牌
--]]
local HandCardView = class("HandCardView")
local PokerCard = require("hz_majiang.src.PokerCard")
local SendHandle = require("hz_majiang.src.handle.SendHandle")

function HandCardView:ctor(GameSceneView, inhand_vw)
    self.GameSceneView = GameSceneView
	self.inhand_vw = inhand_vw
    self.name = self.inhand_vw:getName()
    self.click_mask = self.GameSceneView.cards_vw.click_mask:hide()
    display.doLayout(self.click_mask)
    self:clearData()
end

function HandCardView:clearData()
	self.inhand_vw:removeAllChildren()
    self:setClickMask(false)
end

function HandCardView:showCards(cards)
	self.inhand_vw:removeAllChildren()
	local size = self.inhand_vw:getSize()
    local scale = 1
    for idx, card in ipairs(cards) do
        local cardNode = PokerCard:newMyInHandCard(card)
        
        local cardHeight = cardNode:getSize().height
        local cardWidth = cardNode:getSize().width
        cardHeight = cardHeight * scale
        cardWidth = cardWidth * scale
        local oriX = cardWidth / 2 + 25
        local oriY = cardHeight / 2

		local x = oriX + ( idx-1 ) * cardWidth
		cardNode:setPosition(cc.p(x, oriY))
		self.inhand_vw:addChild(cardNode)
		cardNode:onTouch(handler(self, self.onClickHandCard))
    end
end

function HandCardView:setNewCard(card)
    local size = self.inhand_vw:getSize()
    local scale = 1
    local idx = 14.5
    local cardNode = PokerCard:newMyInHandCard(card)
    
    local cardHeight = cardNode:getSize().height
    local cardWidth = cardNode:getSize().width
    cardHeight = cardHeight * scale
    cardWidth = cardWidth * scale
    local oriX = cardWidth / 2 + 25
    local oriY = cardHeight / 2

    local x = oriX + ( idx-1 ) * cardWidth
    cardNode:setPosition(cc.p(x, oriY))
    self.inhand_vw:addChild(cardNode)
    cardNode:onTouch(handler(self, self.onClickHandCard))
end

function HandCardView:playOutCard()

end

function HandCardView:removeHandCardNodes(cards)
    local childs = self.inhand_vw:getChildren()
	for _,card in ipairs(cards) do
		local idx = #childs
		local node = table.remove(childs, idx)
		if node then
			node:removeSelf()
		end
	end
end

function HandCardView:onClickHandCard(event)
	local target = event.target
    if event.name == "began" then
        self:setClickMask(true)
        local x, y = event.x, event.y
        target.orlPos = target:getPosition()
        target.beganPos = cc.p(x,y)
        local cardId = target._pokerCard
        self:setTingIcon( target )
    elseif event.name == "moved" then
        local beganPos = target.beganPos
        local orlPos = target.orlPos
        local x, y = event.x, event.y
        x = x - beganPos.x
        y = y - beganPos.y
        x = x + orlPos.x
        y = y + orlPos.y
        target:setPosition(x, y)
    elseif event.name == "ended" or event.name == "cancelled" then
        -- self.GameSceneView:isShowLine(false)
        self:setClickMask(false)
        local pos = target:getPosition()
        if g_308.isCanChuCard and pos.y > self.outCardLingPosY and target._cardType ~= g_308.t_wei then
            g_308.chuPos = cc.p(event.x, event.y)
            local _pokerCard = target._pokerCard
			dump("出牌", _pokerCard)
			SendHandle:CLI_PLAYER_OUT_CARD(_pokerCard)
			-- self.GameSceneView:isShowChuPai(false)
			-- self.GameSceneView:hideAllPlayerLight()
			target:removeSelf()
			self:setCurHandCardsPos()
			-- self.GameSceneView:showActionOutIngCard( g_308.my_seat_id, _pokerCard, false)
			-- SoundUtils:SoundCard(_pokerCard, g_308.my_seat_id)
			-- self.GameSceneView:showOutCard()
			self:setTingHuBtn(_pokerCard)
        else
            self:setTingIcon( target )
            self:moveCardsPos(target)
            target:setPosition(target.orlPos)
        end
	end
end

function HandCardView:moveCardsPos(cardNode)

end

function HandCardView:setClickMask( isShow )
    self.click_mask:setVisible(isShow)
end

function HandCardView:setTingIcon( target )
    -- local cardId = target._pokerCard
    -- local cards = self.tingData[cardId]
    -- if cards then
    --     self.TingView:setTing2(cards)
    --     target:setTing()
    -- end    
end

function HandCardView:setTings(data)
    -- self:clearTingData()
    -- for idx,datai in ipairs(data) do
    --     self.tingData[datai.card] = datai.tingHuCards
    -- end
    -- local childs = self.hand_vw:getChildren()
    -- for idx,cardNode in ipairs(childs) do
    --     local _pokerCard = cardNode._pokerCard
    --     if self.tingData[_pokerCard] then
    --         cardNode:setTing()
    --     else
    --         cardNode:hideTing()
    --     end
    -- end
end

function HandCardView:setTingHuBtn( cardId )
    -- local cards = self.tingData[cardId]
    -- self:clearTingData()
    -- if cards then
    --     self.tingData = {}      --听牌数据
    --     self.tingHuCards = cards      --听牌胡数据
    --     self.TingView:setTingHuCards(self.tingHuCards)
    --     self.TingView:setTing2(self.tingHuCards)
    -- end
    -- local childs = self.hand_vw:getChildren()
    -- for k,node in ipairs(childs) do
    --     node:hideTing()
    -- end
end

function HandCardView:setTingHuData( cards )
    -- self:clearTingData()
    -- if cards then
    --     self.tingData = {}      --听牌数据
    --     self.tingHuCards = cards      --听牌胡数据
    --     self.TingView:setTingHuCards(self.tingHuCards)
    --     self.TingView:setTing2(self.tingHuCards)
    -- end
    -- local childs = self.hand_vw:getChildren()
    -- for k,node in ipairs(childs) do
    --     node:hideTing()
    -- end
end
return HandCardView