--[[
	碰杠
--]]
local PAndGView = class("PAndGView")
local PokerCard = require("hz_majiang.src.PokerCard")
local GANGCARD = "gang"

function PAndGView:ctor(PAndG_vw, viewId)
    self.PAndG_vw = PAndG_vw
    self.viewId = viewId
    self.data = {}
    self:clearData()
end

function PAndGView:clearData()
    self.data = {}
	self.PAndG_vw:removeAllChildren()
end

function PAndGView:addPOrGCards(cards, _type)
    local isAnGang, isPeng = false, false
   if bit.band(_type, g_308.gang_an) > 0 then
        isAnGang = true
	elseif bit.band(_type, g_308.t_peng) > 0 then
        isPeng = true
	elseif bit.band(_type, g_308.t_chi) > 0 then
    end
    


	local size = self.PAndG_vw:getSize()
    local initPos
    local data = {}
    if self.data[#self.data] then
        initPos = self.data[#self.data].initPos
    end
    local idx = 1
    if self.viewId == g_308.viewId_my then
        for idxx,card in ipairs(cards) do
            local cardNode = PokerCard:setCardForAll(self.viewId, card)
            local cardSize = cardNode:getContentSize()
			local scale = 1
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = cardWidth / 2
			local oriY = size.height / 2
            if initPos then
                oriX = initPos.x + cardWidth
            end

			local x = oriX + ( idx - 1 ) * (cardWidth - 7)
            local y = oriY
            if idxx == 3 and not isPeng then
                x = oriX + ( idx - 2 ) * (cardWidth - 7)
                y = oriY + 20
            else
                idx = idx + 1
                if isAnGang then
                    cardNode:setAnGangCard()
                end
            end
			cardNode:setScale(scale)
			cardNode:setPosition(cc.p(x, y))
			self.PAndG_vw:addChild(cardNode)
            cardNode:show()
            if isPeng and idxx == 2 then
                cardNode:setName(card..GANGCARD)
            end
            data.initPos = cc.p(x, y)
        end
    elseif self.viewId == g_308.viewId_left then
        for idxx,card in ipairs(cards) do
            local cardNode = PokerCard:setCardForAll(self.viewId, card)
            local cardSize = cardNode:getContentSize()
			local scale = 1.3
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = size.width / 2 
			local oriY = cardHeight / 2
            if initPos then
                oriY = initPos.y - cardHeight
            end
			local x = oriX
			local y = oriY - ( idx - 1 ) * (cardHeight * 0.65)
            if idxx == 3 and not isPeng then
                x = oriX - 5
                y = oriY - ( idx - 2 ) * (cardHeight * 0.65) + 9
                cardNode:setLocalZOrder(5)
            else
                idx = idx + 1
            end
			cardNode:setScale(scale)
			cardNode:setPosition(cc.p(x, y))
			cardNode:setRotation(-17)
			self.PAndG_vw:addChild(cardNode)
            cardNode:show()
            --暗杆其他人也展示一张牌
            if isAnGang and idxx ~= 3 then
                cardNode:setAnGangCard()
            end
            if isPeng and idxx == 2 then
                cardNode:setName(card..GANGCARD)
            end
            data.initPos = cc.p(x, y)
        end
		
    elseif self.viewId == g_308.viewId_right then
        for idxx,card in ipairs(cards) do
            local cardNode = PokerCard:setCardForAll(self.viewId, card)

            local cardSize = cardNode:getContentSize()
			local scale = 1.3
            local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = size.width / 2
            local oriY = cardHeight / 2
            if initPos then
                oriY = initPos.y + cardHeight
            end

			local x = oriX
			local y = oriY + ( idx - 1 ) * (cardHeight * 0.65)
            if idxx == 3 and not isPeng then
                x = oriX + 5 
                y = oriY + ( idx - 2 ) * (cardHeight * 0.65) + 9
                cardNode:setLocalZOrder(5)
            else
				idx = idx + 1
                cardNode:setLocalZOrder(-idx)
            end
           
			cardNode:setScale(scale)
			cardNode:setPosition(cc.p(x, y))
			cardNode:setRotation(17)
			self.PAndG_vw:addChild(cardNode)
            cardNode:show()
            --暗杆其他人也展示一张牌
            if isAnGang and idxx ~= 3 then
                cardNode:setAnGangCard()
            end
            if isPeng and idxx == 2 then
                cardNode:setName(card..GANGCARD)
            end
            data.initPos = cc.p(x, y)
        end

    elseif self.viewId == g_308.viewId_top then
        for idxx,card in ipairs(cards) do
            local cardNode = PokerCard:setCardForAll(self.viewId, card)

            local cardSize = cardNode:getContentSize()
			local scale = 1
			local cardHeight = cardSize.height * scale
			local cardWidth = cardSize.width * scale
			local oriX = size.width - cardWidth / 2
			local oriY = size.height / 2
            if initPos then
                oriX = initPos.x - cardWidth
            end

			local x = oriX - ( idx - 1 ) * 40
            local y = oriY
            if idxx == 3 and not isPeng then
                x = oriX - ( idx - 2 ) * 40
                y = oriY + 12
            else
				idx = idx + 1
            end
			cardNode:setScale(scale)
			cardNode:setPosition(cc.p(x, y))
			self.PAndG_vw:addChild(cardNode)
            --暗杆其他人也展示一张牌
            if isAnGang and idxx ~= 3 then
                cardNode:setAnGangCard()
            end
            if isPeng and idxx == 2 then
                cardNode:setName(card..GANGCARD)
            end
            data.initPos = cc.p(x, y)
        end
    end
    data.card = cards[1]
    table.insert(self.data, data)
end

function PAndGView:addBuGangCard(card)
    local floorCard = self.PAndG_vw:getChildByName(card..GANGCARD)
    if not floorCard then
        return
    end
    local showType

    local cardNode = PokerCard:setCardForAll(self.viewId, card)
    cardNode:setScale(floorCard:getScale())

    local pos = floorCard:getPosition()
    local x = 0
    local y = 0
    if self.viewId == g_308.viewId_my then
        x = pos.x
        y = pos.y + 20
    elseif self.viewId == g_308.viewId_left then
        x = pos.x - 5
        y = pos.y + 9
        cardNode:setRotation(-17)
    elseif self.viewId == g_308.viewId_right then
        x = pos.x + 5
        y = pos.y + 9
        cardNode:setRotation(17)
    elseif self.viewId == g_308.viewId_top then
        x = pos.x
        y = pos.y + 12
    end
    cardNode:setPosition(cc.p(x, y))
    cardNode:setName("bugang")
    self.PAndG_vw:addChild(cardNode)
end

return PAndGView