--[[
	碰杠
--]]
local PengOrGangCardMgr = class("PengOrGangCardMgr")
local cardUtils = require(TpackageName..".utils.cardUtils")
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

        local fromplayerType = cardUtils:getPlayerType(data.targetSeatId)
        dump(fromplayerType,"handData->fromplayerType = ")

        if data.type == CONTROL_TYPE_PENG then
            local isPeng = true
            local isAnGang = false
            self:addGangCards(playerType, plane, cards, isAnGang, isPeng,false,fromplayerType)
        elseif data.type == CONTROL_TYPE_CHI  then
            self:addGangCards(playerType, plane, cards, false, false,true,false,fromplayerType)
        else
            local isAnGang = false
            if data.type == GANG_TYPE_AN then
                isAnGang = true
            end
            self:addGangCards(playerType, plane, cards, isAnGang,false,false,fromplayerType)
        end
    end
end

function PengOrGangCardMgr:addProg(playerType, plane, cards, cardsType,fromplayerType)
    local cardsData = {}
    for i,card in ipairs(cards) do
        local cardData = D3_CARDDATA:new(card, 1, CARDNODE_TYPE_NORMAL)
        table.insert(cardsData, cardData)
    end
 
    if cardsType == CONTROL_TYPE_PENG then
        local isPeng = true
        local isAnGang = false
        self:addGangCards(playerType, plane, cardsData, isAnGang, isPeng,false,fromplayerType)
    elseif cardsType == GANG_TYPE_AN then
        local isAnGang = true
        self:addGangCards(playerType, plane, cardsData, isAnGang,false,false,fromplayerType)
    elseif cardsType == GANG_TYPE_BU then
        self:addGangCard(playerType, plane, cardsData[1],false,false,false,fromplayerType)
    elseif cardsType == GANG_TYPE_PG then
        self:addGangCards(playerType, plane, cardsData,false,false,false,fromplayerType)
    elseif cardsType == CHI_TYPE_RIGHT 
        or cardsType == CHI_TYPE_MIDDLE 
        or cardsType == CHI_TYPE_LEFT then
        self:addGangCards(playerType, plane, cardsData,false,false,true,fromplayerType)      
    end

    if cardsType == GANG_TYPE_PG or cardsType == CONTROL_TYPE_PENG or 
        cardsType == CHI_TYPE_RIGHT 
        or cardsType == CHI_TYPE_MIDDLE 
        or cardsType == CHI_TYPE_LEFT
        then

        if D3_WAIT_OPRATE_CARD and D3_WAIT_OPRATE_CARD:getParent() then
            --碰杠的时候 删牌可能失败 改变删牌逻辑----------------------------
            for i=#D3_HIGHLIGHT_OUT_CARDS,1,-1 do
                if D3_HIGHLIGHT_OUT_CARDS[i] == D3_WAIT_OPRATE_CARD then
                    table.remove(D3_HIGHLIGHT_OUT_CARDS, i)
                end
            end
            
            D3_WAIT_OPRATE_CARD:removeFromParent()
            D3_WAIT_OPRATE_CARD = nil
        end
    end
end

function PengOrGangCardMgr:addGangCards(playerType, plane, cardDatas, isAnGang, isPeng,isChi,fromplayerType)
    local card = Card:newPengOrGangCard(playerType, {m_value = 1})
	local size = plane:getSize()
	local cardHeight = card:getSize().height
	local cardWidth = card:getSize().width
	local scale = 1
	cardHeight = cardHeight * scale
	cardWidth = cardWidth * scale
	local oriX = size.width / 2
    local oriY = size.height - cardHeight / 2

    local tempChild = plane:getChildren()
    local chlds = {}

    for k,v in pairs(tempChild) do
        if v then
            if v:getName() ~= "jiantou" then
                table.insert(chlds,v)
            end
        end
    end

    --local chlds = plane:getChildren()

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
        local rotatePos = cc.p(0,0)
        for idxx,cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
			local x = oriX + ( idx - 1 ) * (cardWidth - 7)
            local y = oriY
            if idxx == 3 and not isPeng and not isChi then
                x = oriX + ( idx - 2 ) * (cardWidth - 7)
                y = oriY + 20
            else
                idx = idx + 1
                if isAnGang then
                    card:setAnGangCard()
                end
            end

            ------记录箭头的位置
            if idxx == 2 then
                rotatePos = cc.p(x,size.height + 20)
            end
            -------

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

        local rotateImg = ccui.ImageView:create(TpackageName.."/res/GameScene/rotateImg.png", 0)
        rotateImg:setScale(0.5)
        rotateImg:addTo(plane)
        rotateImg:setPosition(rotatePos)
        rotateImg:setName("jiantou")


        if fromplayerType == 1 then
            rotateImg:setRotation(-90)
        elseif fromplayerType == 2 then  --left
            rotateImg:setRotation(0)
        elseif fromplayerType == 3 then --right
            rotateImg:setRotation(180)
        elseif fromplayerType == 4 then  --top
            rotateImg:setRotation(90)
        end

    elseif playerType == CARD_PLAYERTYPE_LEFT then
        local rotatePos = cc.p(0,0)
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


             ------记录箭头的位置
            if idxx == 2 then
                rotatePos = cc.p(x+40, y)
            end

            if idxx == 3 and not isPeng and not isChi then 
                rotatePos = cc.p(x+45, y)
            end 
            -------



			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
            card:show()

            if isAnGang then
                card:setAnGangCard()
            end
                
            --暗杆其他人也展示一张牌
            --[[if idxx == 3 and not isPeng and not isChi then

            else
                if isAnGang then
                    card:setAnGangCard()
                end
            end--]]
            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end

        local rotateImg = ccui.ImageView:create(TpackageName.."/res/GameScene/rotateImg.png", 0)
        rotateImg:setScale(0.5)
        rotateImg:addTo(plane)
        rotateImg:setPosition(rotatePos)
        rotateImg:setName("jiantou")

        if fromplayerType == 1 then
            rotateImg:setRotation(-90)
        elseif fromplayerType == 2 then  --left
            rotateImg:setRotation(0)
        elseif fromplayerType == 3 then --right
            rotateImg:setRotation(180)
        elseif fromplayerType == 4 then  --top
            rotateImg:setRotation(90)
        end
		
    elseif playerType == CARD_PLAYERTYPE_RIGHT then
        local rotatePos = cc.p(0,0)
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


            ------记录箭头的位置
            if idxx == 2 then
                rotatePos = cc.p(x-40, y)
            end

            if idxx == 3 and not isPeng and not isChi then 
                rotatePos = cc.p(x-45, y)
            end 
            -------

           
			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
            card:show()
            if isAnGang then
               card:setAnGangCard()
            end
            --暗杆其他人也展示一张牌
            --[[if idxx == 3 and not isPeng and not isChi then

            else
                if isAnGang then
                    card:setAnGangCard()
                end
            end--]]
            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end

        local rotateImg = ccui.ImageView:create(TpackageName.."/res/GameScene/rotateImg.png", 0)
        rotateImg:setScale(0.5)
        rotateImg:addTo(plane)
        rotateImg:setPosition(rotatePos)
        rotateImg:setName("jiantou")

        if fromplayerType == 1 then
            rotateImg:setRotation(-90)
        elseif fromplayerType == 2 then  --left
            rotateImg:setRotation(0)
        elseif fromplayerType == 3 then --right
            rotateImg:setRotation(180)
        elseif fromplayerType == 4 then  --top
            rotateImg:setRotation(90)
        end

    elseif playerType == CARD_PLAYERTYPE_TOP then
        local rotatePos = cc.p(0,0)
        for idxx,cardData in ipairs(cardDatas) do
            local card = Card:newPengOrGangCard(playerType, cardData)
			local x = oriX - ( idx - 1 ) * 40
            local y = oriY
            if idxx == 3 and not isPeng and not isChi then
                x = oriX - ( idx - 2 ) * 40
                y = oriY + 12
            else
				idx = idx + 1
            end

            ------记录箭头的位置
            if idxx == 2 then
                rotatePos = cc.p(x, y-30)
            end
            -------


			card:setScale(scale)
			card:setPosition(cc.p(x, y))
			plane:addChild(card)
            card:show()

            if isAnGang then
               card:setAnGangCard()
            end

            --暗杆其他人也展示一张牌
           --[[ if idxx == 3 and not isPeng then

            else
                -- if isAnGang then
                --     card:setAnGangCard()
                -- end
            end--]]

            if isPeng and idxx == 2 then
                card:setName(cardData.m_value .. GANGCARD)
            end
            if idxx == 3 and isPeng then
                break
            end
        end

        local rotateImg = ccui.ImageView:create(TpackageName.."/res/GameScene/rotateImg.png", 0)
        rotateImg:setScale(0.5)
        rotateImg:addTo(plane)
        rotateImg:setPosition(rotatePos)
        rotateImg:setName("jiantou")

        if fromplayerType == 1 then
            rotateImg:setRotation(-90)
        elseif fromplayerType == 2 then  --left
            rotateImg:setRotation(0)
        elseif fromplayerType == 3 then --right
            rotateImg:setRotation(180)
        elseif fromplayerType == 4 then  --top
            rotateImg:setRotation(90)
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