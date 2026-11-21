--[[
	碰杠
--]]
local PengOrGangCardMgr = class("PengOrGangCardMgr")
local Card = require(TpackageName..".2DMahjongCard.Card")
local OutCardMgr = require(TpackageName..".2DMahjongCard.OutCardMgr")
local GANGCARD = "gang"
function PengOrGangCardMgr:ctor(path)

end

function PengOrGangCardMgr:handData(playerType, plane, datas)
    plane:removeAllChildren()
    for i,data in ipairs(datas) do
        
        local cards = data.cards
        if type(data.cards[1]) == "number" then
            cards = {}
            for i,card in ipairs(data.cards) do
                local cardData = D3_CARDDATA:new(card, 1, CARDNODE_TYPE_NORMAL)
                table.insert(cards, cardData)
            end
        end

        if data.type == CONTROL_TYPE_PENG then
            -- self:addPengCards(playerType, plane, cards)
            local isPeng = true
            local isAnGang = false
            self:addGangCards(playerType, plane, cards, isAnGang, isPeng)
        else
            local isAnGang = false
            if data.type == GANG_TYPE_AN then
                isAnGang = true
            end
            self:addGangCards(playerType, plane, cards, isAnGang)
        end
    end
end

function PengOrGangCardMgr:addProg(playerType, plane, cards, cardsType)
    local cardsData = {}
    for i,card in ipairs(cards) do
        local cardData = D3_CARDDATA:new(card, 1, CARDNODE_TYPE_NORMAL)
        table.insert(cardsData, cardData)
    end
 
    if cardsType == CONTROL_TYPE_PENG then
        local isPeng = true
        local isAnGang = false
        self:addGangCards(playerType, plane, cardsData, isAnGang, isPeng)
        -- self:addPengCards(playerType, plane, cardsData)
    elseif cardsType == GANG_TYPE_AN then
        local isAnGang = true
        self:addGangCards(playerType, plane, cardsData, isAnGang)
    elseif cardsType == GANG_TYPE_BU then
        self:addGangCard(playerType, plane, cardsData[1])
    elseif cardsType == GANG_TYPE_PG then
        self:addGangCards(playerType, plane, cardsData)
    end

    if cardsType == GANG_TYPE_PG or cardsType == CONTROL_TYPE_PENG then
        if D3_WAIT_OPRATE_CARD and D3_WAIT_OPRATE_CARD:getParent() then
            for i,v in ipairs(D3_HIGHLIGHT_OUT_CARDS) do
                if v == D3_WAIT_OPRATE_CARD then
                    table.remove(D3_HIGHLIGHT_OUT_CARDS, i)
                end
            end
            D3_WAIT_OPRATE_CARD:removeFromParent()
            D3_WAIT_OPRATE_CARD = nil
        end
    end
end

function PengOrGangCardMgr:addGangCards(playerType, plane, cardDatas, isAnGang, isPeng)
    local card = Card:newPengOrGangCard(playerType, {m_value = 1})
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local scale = 1
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
    local pAndGNum = math.floor(#chlds/3)
    if playerType == CARD_PLAYERTYPE_MY then
        if lastChld then
            local pos = lastChld:getPosition()
            oriX = pos.x + 60
            oriY = pos.y
        else
            oriX = cardWidth / 2
            oriY = size.height / 2
        end
    elseif playerType == CARD_PLAYERTYPE_LEFT then
        if lastChld then
            local minP = 10000
            for i,node in ipairs(chlds) do
                local py = node:getPositionY()
                if minP > py then
                    minP = py
                    lastChld = node
                end
            end

            local pos = lastChld:getPosition()
            oriX = pos.x - 10
            oriY = pos.y - 40
        else
            oriX = size.width / 2
            oriY = size.height - cardHeight / 2
        end
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
        if lastChld then
            local minP = -10000
            for i,node in ipairs(chlds) do
                local py = node:getPositionY()
                if minP < py then
                    minP = py
                    lastChld = node
                end
            end
            local pos = lastChld:getPosition()
            oriX = pos.x - 9
            oriY = pos.y + 47
        else
            oriX = size.width / 2
            oriY = cardHeight / 2
        end
    elseif playerType == CARD_PLAYERTYPE_TOP then
        if lastChld then
            local pos = lastChld:getPosition()
            oriX = pos.x - 50
            oriY = pos.y
        else
            oriX = size.width - cardWidth / 4
            oriY = size.height / 2
        end
    end
  
    local idx = 1
    if playerType == CARD_PLAYERTYPE_MY then
        for idxx,cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
			local x = oriX + ( idx - 1 ) * (cardWidth - 7)
            local y = oriY
            if idxx == 3 and not isPeng then
                x = oriX + ( idx - 2 ) * (cardWidth - 7)
                y = oriY + 20
            else
                idx = idx + 1
                if isAnGang then
                    card:setAnGangCard()
                end
            end
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
            card:show()
            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end
    elseif playerType == CARD_PLAYERTYPE_LEFT then
        for idxx,cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
			local x = oriX - ( idx - 1 ) * 7
            local y = oriY - ( idx - 1 ) * 24
            if idxx == 3 and not isPeng then
                x = oriX - ( idx - 2 ) * 7 - 5
                y = oriY - ( idx - 2 ) * 24 + 9
                card:setLocalZOrder(5)
            else
                idx = idx + 1
            end
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
            card:show()
            --暗杆其他人也展示一张牌
            if idxx == 3 and not isPeng then

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
        for idxx,cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
			local x = oriX - ( idx - 1 ) * 6
            local y = oriY + ( idx - 1 ) * 23
            if idxx == 3 and not isPeng then
                x = oriX - ( idx - 2 ) * 6 + 5 
                y = oriY + ( idx - 2 ) * 23 + 9
                card:setLocalZOrder(5)
            else
				idx = idx + 1
                card:setLocalZOrder(-idx)
            end
           
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
            card:show()
            --if isAnGang then
            --    card:setAnGangCard()
            --end
            --暗杆其他人也展示一张牌
            if idxx == 3 and not isPeng then

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
        --对家的杠的位置 下移
        oriY = oriY - 20

        for idxx,cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
			local x = oriX - ( idx - 1 ) * 40
            local y = oriY
            if idxx == 3 and not isPeng then
                x = oriX - ( idx - 2 ) * 40
                y = oriY + 12
            else
				idx = idx + 1
            end
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
            card:show()
            --if isAnGang then
            --    card:setAnGangCard()
            --end
            --暗杆其他人也展示一张牌
            if idxx == 3 and not isPeng then

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