--[[
	自己的手牌
--]]
local HandCardView = class("HandCardView")
local PokerCard = require("hz_majiang.src.PokerCard")
local SendHandle = require("hz_majiang.src.handle.SendHandle")

function HandCardView:ctor(GameSceneView, inhand_vw)
    self.GameSceneView = GameSceneView
    self.TingView = GameSceneView.TingView
	self.inhand_vw = inhand_vw
    self.name = self.inhand_vw:getName()
    self.click_mask = self.GameSceneView.cards_vw.click_mask:hide()
    display.doLayout(self.click_mask)
    self:clearData()
    self.outCardLingPosY = 180
    self.GameSceneView.cards_vw:onClick(function(  )
        self:setNodePos()

        self.TingView:setTingNode(0)
        self.TingView:setTingNodeAndCount(0)
    end)
end

function HandCardView:clearData()
	self.inhand_vw:removeAllChildren()
    self:setClickMask(false)
end

function HandCardView:showCards(cards)
	self.inhand_vw:removeAllChildren()
	local size = self.inhand_vw:getSize()
    local scale = 1
    local newCards = {}

    cards = self:sortCards(cards)

    for idx, card in ipairs(cards) do
        table.insert(newCards, 1, card)
    end
    for idx, card in ipairs(newCards) do
        local cardNode = PokerCard:newMyInHandCard(card)
        
        local cardHeight = cardNode:getSize().height
        local cardWidth = cardNode:getSize().width
        cardHeight = cardHeight * scale
        cardWidth = cardWidth * scale
        local oriX = size.width - cardWidth / 2 - cardWidth - cardWidth
        local oriY = cardHeight / 2

		local x = oriX - ( idx-1 ) * cardWidth
		cardNode:setPosition(cc.p(x, oriY))
		self.inhand_vw:addChild(cardNode)
		cardNode:onTouch(handler(self, self.onClickHandCard))
    end
end

function HandCardView:setNewCard(card)
    local childs = self.inhand_vw:getChildren()
    for idx, node in ipairs(childs) do
        node:setNodeEventEnabled(false)
    end

    
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
    cardNode:setNodeEventEnabled(true, function(event)
        if event.name == "exit" then
            self.cardNode14 = nil
        end
    end)
    self.cardNode14 = cardNode
end

function HandCardView:playOutCard(card)
	if not tolua.isnull(self.cardNode14) then
		self.cardNode14:removeFromParent()
		self.TingView:showTingHuData(self.cardNode14._cardValue)
	end
end

function HandCardView:removeHandCardNodes(cards)
	for _,card in ipairs(cards) do
        local childs = self.inhand_vw:getChildren()
        for idx, node in ipairs(childs) do
            if node._cardValue == card then
                node:removeSelf()
                break
            end 
        end
	end
end

function HandCardView:getCurHandCards()
    local childs = self.inhand_vw:getChildren()
    local cards = {}
    for idx, node in ipairs(childs) do
        if cards[node._cardValue] == nil then
            cards[node._cardValue] = 0
        end 
        cards[node._cardValue] = cards[node._cardValue] + 1
    end
    return cards
end

function HandCardView:handRemoveCards(_type, card)
    local cards = {}
    if bit.band(_type, g_308.gang_bu) > 0 then
        table.insert(cards, card)
    elseif bit.band(_type, g_308.t_peng) > 0 then --碰
        table.insert(cards, card)
        table.insert(cards, card)
    elseif bit.band(_type, g_308.t_gang) > 0 then
        table.insert(cards, card)
        table.insert(cards, card)
        table.insert(cards, card)
    elseif bit.band(_type, g_308.t_chi) > 0 then
        if _type == g_308.chi_right then
            table.insert(cards, card - 2)
            table.insert(cards, card - 1)
        elseif _type == g_308.chi_middle then
            table.insert(cards, card + 1)
            table.insert(cards, card - 1)
        elseif _type == g_308.chi_left then
            table.insert(cards, card + 1)
            table.insert(cards, card + 2)
        end
    end
    self:removeHandCardNodes(cards)
end

function HandCardView:onClickHandCard(event)
	local target = event.target
    if event.name == "began" then
        self:setClickMask(true)
        local x, y = event.x, event.y
        target.orlPos = target:getPosition()
        target.beganPos = cc.p(x,y)
        local cardId = target._cardValue
        self.isMove = false
    elseif event.name == "moved" then
        local beganPos = target.beganPos
        local orlPos = target.orlPos
        local x, y = event.x, event.y
        x = x - beganPos.x
        y = y - beganPos.y
        x = x + orlPos.x
        y = y + orlPos.y
        target:setPosition(x, y)
        if math.abs(x - orlPos.x) > 10 or math.abs(y - orlPos.y) > 10 then
            self.isMove = true--手机可能会误点 加个容错
        end
    elseif event.name == "ended" or event.name == "cancelled" then
        self:setClickMask(false)
        local pos = target:getPosition()
        local _cardValue = target._cardValue
        self.GameSceneView:showSelectedCards(_cardValue)

        self.TingView:setTingNode(_cardValue)
        self.TingView:setTingNodeAndCount(_cardValue)

        local isCanChuCard = false
        if self.isMove then
            if pos.y > self.outCardLingPosY then
                isCanChuCard = true
            end
        else
            if g_308.isDanJi then
                isCanChuCard = true
            else    
                isCanChuCard = target.selected
            end
        end

        if g_308.isCanChuCard and not g_308.laiziCards[_cardValue] and isCanChuCard then
			dump("出牌", _cardValue)
			SendHandle:SEND_CARD(_cardValue)
            target:removeSelf()
            self:moveCardsPos()
			-- self.GameSceneView:isShowChuPai(false)
			-- self.GameSceneView:hideAllPlayerLight()
			-- self.GameSceneView:showActionOutIngCard( g_308.my_seat_id, _cardValue, false)
			-- SoundUtils:SoundCard(_cardValue, g_308.my_seat_id)
			-- self.GameSceneView:showOutCard()
            self.TingView:showTingHuData(_cardValue)
            self:setTings()
        else
            target:setPosition(target.orlPos)
            self:setNodePos(target)
        end
        self.isMove = false
	end
end

function HandCardView:setNodePos(clickNode)
    local childs = self.inhand_vw:getChildren()
    for idx, node in ipairs(childs) do
        local cardHeight = node:getSize().height
        local oriY = cardHeight / 2
        if node == clickNode then
            if node.selected == true then
                node.selected = false
                node:setPositionY(oriY)
            else
                node.selected = true
                node:setPositionY(oriY + 25)
            end
        else
            node:setPositionY(oriY)
            node.selected = false
        end
	end
end

function HandCardView:sortCards(cards)
    table.sort(cards)
    local newCards = {}
    for i, card in ipairs(cards) do
        if g_308.laiziCards[card] then
            table.insert(newCards, 1, card)
        else
            table.insert(newCards, card)
        end
    end
    return newCards
end

function HandCardView:sortChilds(childs)
    table.sort(childs, function( a, b )
        return a._cardValue < b._cardValue
    end)
    local newChilds = {}
    for i, node in ipairs(childs) do
        if g_308.laiziCards[node._cardValue] then
            table.insert(newChilds, 1, node)
        else
            table.insert(newChilds, node)
        end
    end
    return newChilds
end

function HandCardView:sore_reverse(arr)
    local newArr = {}
    for i, v in ipairs(arr) do
        table.insert(newArr, 1, v)
    end
    return newArr
end

function HandCardView:moveCardsPos()
    local childs = self.inhand_vw:getChildren()
    table.sort(childs, function( a, b )
        return a:getPositionX() > b:getPositionX()
    end)
    for idx,node in ipairs(childs) do
        if node == self.cardNode14 then
            table.remove(childs, idx)
            break
        end
    end
    local starIdx = #childs + 1
    if self.cardNode14 and g_308.laiziCards[self.cardNode14._cardValue] then
        for idx,node in ipairs(childs) do
            if node._cardValue > self.cardNode14._cardValue then
                starIdx = idx - 1
                break
            end
        end
    elseif self.cardNode14 then
        for idx,node in ipairs(childs) do
            if g_308.laiziCards[node._cardValue] then
                starIdx = idx
                break
            end
            if node._cardValue < self.cardNode14._cardValue then
                starIdx = idx
                break
            end
        end
    end
    if self.cardNode14 then
        table.insert(childs, starIdx, self.cardNode14)
        if starIdx < 0 then
            starIdx = 0
        elseif starIdx > #childs then
            starIdx = #childs
        end
    end
    
    local size = self.inhand_vw:getSize()
    local scale = 1
    local starPos
    local time = 0.2
    local totalTime = 0
    for idx, cardNode in ipairs(childs) do
        local indx = idx
        local cardHeight = cardNode:getSize().height
        local cardWidth = cardNode:getSize().width
        cardHeight = cardHeight * scale
        cardWidth = cardWidth * scale
        local oriX = size.width - cardWidth / 2 - cardWidth - cardWidth
        local oriY = cardHeight / 2
        local x = oriX - ( indx-1 ) * cardWidth
        local pos = cc.p(x, oriY)
        if idx == starIdx then
            starPos = pos
        else
            local MoveTo = cc.MoveTo:create(time, pos)
            local Sequence = cc.Sequence:create(MoveTo)
            cardNode:runAction(Sequence)
        end
    end
    totalTime = totalTime + time
    if self.cardNode14 and starPos then
        local DelayTime = cc.DelayTime:create(time)
        local JumpTo = cc.JumpTo:create(time, starPos, starPos.y + 150, 1)
        local Sequence = cc.Sequence:create(DelayTime, JumpTo)
        self.cardNode14:runAction(Sequence)
        self.cardNode14:setNodeEventEnabled(false)
        self.cardNode14 = nil
        totalTime = totalTime + time
        totalTime = totalTime + time
    end
    self.click_mask:show()
    local DelayTime = cc.DelayTime:create(totalTime)
    local JumpTo = cc.Hide:create()
    local Sequence = cc.Sequence:create(DelayTime, JumpTo)
    self.click_mask:runAction(Sequence)

end

function HandCardView:setClickMask( isShow )
    self.click_mask:setVisible(isShow)
end


function HandCardView:setTings(tingData, maxCard)
    tingData = tingData or {}
    local childs = self.inhand_vw:getChildren()
    for idx, cardNode in ipairs(childs) do
        cardNode:hideDian()
        if cardNode._cardValue == maxCard then
            cardNode:showTxtDian()
        elseif tingData[cardNode._cardValue] then
            cardNode:showDian()
        end
    end
end

function HandCardView:getCards()
	local childs = self.inhand_vw:getChildren()
	local cards = {}
	for i1,v1 in ipairs(childs) do
		table.insert(cards, v1._cardValue)
	end
	return cards
end

return HandCardView