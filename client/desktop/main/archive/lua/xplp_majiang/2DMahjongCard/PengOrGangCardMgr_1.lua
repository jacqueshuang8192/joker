--[[
	碰杠
    --]]
local PengOrGangCardMgr = class("PengOrGangCardMgr")
local Card = require(TpackageName .. ".2DMahjongCard.Card")
local OutCardMgr = require(TpackageName .. ".2DMahjongCard.OutCardMgr")
local ClickCardView = require(TpackageName..".2DMahjongCard.ClickCardView")
local GANGCARD = "gang"
function PengOrGangCardMgr:ctor(path)
end

function PengOrGangCardMgr:handData(playerType, plane, datas)
    plane:removeAllChildren()
    for i, data in ipairs(datas) do
        dump(data, "handData->data=>")
        local cards = data.cards
        if type(data.cards[1]) == "number" then
            cards = {}
            for i, card in ipairs(data.cards) do
                local cardData = D3_CARDDATA:new(card, 1, CARDNODE_TYPE_NORMAL)
                table.insert(cards, cardData)
            end
        end

        if data.type == CONTROL_TYPE_PENG then
            local isPeng = true
            local isAnGang = false
            dump(datas.pengCard, "datas.pengCard")
            self:addGangCards(playerType, plane, cards, isAnGang, isPeng, false, 0)
        elseif data.type == CONTROL_TYPE_CHI then
            dump(datas.ChiCard, "datas.ChiCard")
            self:addGangCards(playerType, plane, cards, false, false, true, data.cards[1].m_value)
        else
            local isAnGang = false
            if data.type == GANG_TYPE_AN then
                isAnGang = true
            end
            self:addGangCards(playerType, plane, cards, isAnGang)
        end
    end
end

function PengOrGangCardMgr:addProg(playerType, plane, cards, cardsType, proCard)
    dump("PengOrGangCardMgr--")
    local cardsData = {}
    for i, card in ipairs(cards) do
        local cardData = D3_CARDDATA:new(card, 1, CARDNODE_TYPE_NORMAL)
        table.insert(cardsData, cardData)
    end

    if cardsType == CONTROL_TYPE_PENG then
        local isPeng = true
        local isAnGang = false
        self:addGangCards(playerType, plane, cardsData, isAnGang, isPeng, false, proCard)
    elseif cardsType == GANG_TYPE_AN then
        local isAnGang = true
        self:addGangCards(playerType, plane, cardsData, isAnGang, proCard)
    elseif cardsType == GANG_TYPE_BU then
        self:addGangCard(playerType, plane, cardsData[1], proCard)
    elseif cardsType == GANG_TYPE_PG then
        self:addGangCards(playerType, plane, cardsData, proCard)
    elseif cardsType == CHI_TYPE_RIGHT or cardsType == CHI_TYPE_MIDDLE or cardsType == CHI_TYPE_LEFT then
        self:addGangCards(playerType, plane, cardsData, false, false, true, proCard)
    end

    if cardsType == GANG_TYPE_PG or cardsType == CONTROL_TYPE_PENG or cardsType == CHI_TYPE_RIGHT or cardsType == CHI_TYPE_MIDDLE or cardsType == CHI_TYPE_LEFT then
        if D3_WAIT_OPRATE_CARD and D3_WAIT_OPRATE_CARD:getParent() then
            --碰杠的时候 删牌可能失败 改变删牌逻辑----------------------------
            for i = #D3_HIGHLIGHT_OUT_CARDS, 1, -1 do
                if D3_HIGHLIGHT_OUT_CARDS[i] == D3_WAIT_OPRATE_CARD then
                    table.remove(D3_HIGHLIGHT_OUT_CARDS, i)
                end
            end

            D3_WAIT_OPRATE_CARD:removeFromParent()
            D3_WAIT_OPRATE_CARD = nil
        end
    end
end

function PengOrGangCardMgr:addGangCards(playerType, plane, cardDatas, isAnGang, isPeng, isChi, proCard)
    dump("proCard------first", proCard)
    local card = Card:newPengOrGangCard(playerType, {m_value = 1})
    local size = plane:getSize()
    local cardHeight = card:getSize().height
    local cardWidth = card:getSize().width
    local scale = 0.52

    cardHeight = cardHeight * scale
    cardWidth = cardWidth * scale

    local oriX = size.width / 2
    local oriY = size.height - cardHeight / 2

    local chlds = plane:getChildren()
    local lastChld = chlds[#chlds]
    for idx = #chlds, 1, -1 do
        local node = chlds[idx]
        local name = node:getName()
        if name == "" then
            lastChld = node
            break
        end
    end

    local initX = 0
    local initY = 0
    local pAndGNum = math.floor(#chlds / 3)
    if playerType == CARD_PLAYERTYPE_MY then
        if lastChld then
            local pos = lastChld:getPosition()
            oriX = pos.x + 70
            oriY = pos.y
        else
            oriX = 0
            oriY = size.height / 2
        end
    elseif playerType == CARD_PLAYERTYPE_LEFT then
        if lastChld then
            local minP = 0
            for i, node in ipairs(chlds) do
                local py = node:getPositionX()
                if minP < py then
                    minP = py
                    lastChld = node
                end
            end

            local pos = lastChld:getPosition()
            oriX = pos.x + cardWidth + 10
            oriY = -0.5 * cardHeight
        else
            --这是第一个坎
            oriX = cardWidth / 2
            oriY = -0.5 * cardHeight
        end
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
        if lastChld then
            local minP = 10000
            for i, node in ipairs(chlds) do
                local py = node:getPositionX()
                if minP > py then
                    minP = py
                    lastChld = node
                end
            end
            local pos = lastChld:getPosition()
            oriX = pos.x - cardWidth - 10
            oriY = -0.5 * cardHeight
        else
            oriX = cardWidth / 2
            oriY = -0.5 * cardHeight
        end
    elseif playerType == CARD_PLAYERTYPE_TOP then
        if lastChld then
            local pos = lastChld:getPosition()
            oriX = pos.x + cardWidth + 10
            oriY = 0
        else
            oriX = cardWidth / 2
            oriY = 0
        end
    end

    local idx = 1
    if playerType == CARD_PLAYERTYPE_MY then
        local pengCount = 0
        local scale = 0.95
        for idxx, cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)

            local cardHeight = card:getSize().height * scale
            local cardWidth = card:getSize().width * scale

            local x = oriX + (idxx - 1) * cardWidth
            local y = oriY
            if idxx == 4 and not isPeng and not isChi then
                -- idx = idx + 1
                -- x = oriX + (idx - 2) * (cardWidth - 7)
                -- y = oriY + 20
            else
                -- idx = idx + 1
                if isAnGang then
                    card:setAnGangCard()
                end
            end
            dump(cardData, "cardData== cardData")
            dump(proCard, "proCard== proCard")
            if cardData.m_value == proCard and isChi then
                dump("cardData== cardData", cardData)
                card:setColor(cc.c3b(140, 140, 140))
            end
            if isPeng and pengCount == 0 then
                pengCount = 1
                card:setColor(cc.c3b(140, 140, 140))
            end
            card:setScale(scale)
            card:setPosition(cc.p(x, y))
            plane:addChild(card)
            card:show()
            card:onClick(handler(self, self.onClickCard))
            card.clickdata = {
                index = idxx,
                isAnGang = isAnGang,
            }
            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end
    elseif playerType == CARD_PLAYERTYPE_LEFT then
        local pengCount = 0
        for idxx, cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)

            local x = oriX
            local y = oriY - (idx - 1) * 27
            idx = idx + 1
            if cardData.m_value == proCard and isChi then
                card:setColor(cc.c3b(140, 140, 140))
            end
            if isPeng and pengCount == 0 then
                pengCount = 1
                card:setColor(cc.c3b(140, 140, 140))
            end
            card:setScale(scale)
            card:setPosition(cc.p(x, y))
            plane:addChild(card)
            card:show()
            card:onClick(handler(self, self.onClickCard))
            card.clickdata = {
                index = idxx,
                isAnGang = isAnGang,
            }
            --暗杆其他人也展示一张牌
            if idxx == 4 and not isPeng and not isChi then
            else
                if isAnGang then
                    card:setAnGangCard()
                end
            end
            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
        local pengCount = 0
        for idxx, cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
            local x = oriX
            local y = oriY - (idx - 1) * 27
            idx = idx + 1

            if cardData.m_value == proCard and isChi then
                dump("cardData==proCard cardData==proCard")
                card:setColor(cc.c3b(140, 140, 140))
            end
            if isPeng and pengCount == 0 then
                pengCount = 1
                card:setColor(cc.c3b(140, 140, 140))
            end
            card:setScale(scale)
            card:setPosition(cc.p(x, y))
            plane:addChild(card)
            card:show()
            card:onClick(handler(self, self.onClickCard))
            card.clickdata = {
                index = idxx,
                isAnGang = isAnGang,
            }
            --暗杆其他人也展示一张牌
            if idxx == 4 and not isPeng and not isChi then
            else
                if isAnGang then
                    card:setAnGangCard()
                end
            end
            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end
    elseif playerType == CARD_PLAYERTYPE_TOP then
        local pengCount = 0
        for idxx, cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
            local x = oriX
            local y = oriY - (idx - 1) * 27
            idx = idx + 1

            --[[
            if idxx == 3 and not isPeng and not isChi then
                x = oriX + ( idx - 2 ) * 40
                y = oriY + 12
            else
				idx = idx + 1
            end--]]
            if cardData.m_value == proCard and isChi then
                card:setColor(cc.c3b(140, 140, 140))
            end
            if isPeng and pengCount == 0 then
                pengCount = 1
                card:setColor(cc.c3b(140, 140, 140))
            end
            card:setScale(scale)
            card:setPosition(cc.p(x, y))
            plane:addChild(card)
            card:show()
            card.clickdata = {
                index = idxx,
                isAnGang = isAnGang,
            }
            card:onClick(handler(self, self.onClickCard))
            --if isAnGang then
            --    card:setAnGangCard()
            --end
            --暗杆其他人也展示一张牌
            if idxx == 4 and not isPeng then
            else
                if isAnGang then
                    card:setAnGangCard()
                end
            end
            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end
    end
end

function PengOrGangCardMgr:onClickCard(event)
	local target = event.target
	local parent = target:getParent()
	local chil = parent:getChildren()
	local cards = {}
    local cardsArr = {}
	for idx,node in ipairs(chil) do
        local index = node.clickdata.index 
        local isAnGang = node.clickdata.isAnGang
		table.insert(cards, node.m_value)
        if chil[idx+1] and chil[idx+1].clickdata.index == 1 then
            table.insert(cardsArr, {cards = cards, isAnGang = isAnGang})
            cards = {}
        elseif not chil[idx+1] then
            table.insert(cardsArr, {cards = cards, isAnGang = isAnGang})
        end
	end
	ClickCardView.new(cardsArr, #chil):addTo(SCENENOW.scene)
end

function PengOrGangCardMgr:addGangCard(playerType, plane, cardData)
    local floorCard = plane:getChildByName(cardData.m_value .. GANGCARD)
    if not floorCard then
        return
    end
    local showType

    local cardNode = Card:newPengOrGangCard(playerType, cardData)
    cardNode:setScale(floorCard:getScale())

    local pos = floorCard:getPosition()
    local x = 0
    local y = 0
    if playerType == CARD_PLAYERTYPE_MY then
        x = pos.x
        y = pos.y + 20
    elseif playerType == CARD_PLAYERTYPE_LEFT then
        x = pos.x - 5
        y = pos.y + 9
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
        x = pos.x + 5
        y = pos.y + 9
    elseif playerType == CARD_PLAYERTYPE_TOP then
        x = pos.x
        y = pos.y + 12
    end
    cardNode:setPosition(cc.p(x, y))
    cardNode:setName("bugang")
    plane:addChild(cardNode)
end

return PengOrGangCardMgr
