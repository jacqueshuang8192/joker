local SendHandle = import("hcphz.src.handle.SendHandle")
local CardUtils = require("hcphz.src.CardUtils").new()
local Card = require("hcphz.src.Card")
local HandCardView = class("HandCardView")

local outCardLingPosY = 373--滑动出线的标准

function HandCardView:ctor(GameSceneView)
    self.GameSceneView = GameSceneView
    self.TingView = GameSceneView.TingView
    self.hand_vw = GameSceneView.players.hand_vw
    self.hand_vw:removeAllChildren()
    self.tingData = {}      --听牌数据
end

function HandCardView:clearData( )
    self.hand_vw:removeAllChildren()
    self:clearTingData( )
end

function HandCardView:clearTingData( )
    self.tingData = {}
    self.tingHuCards = {}
    self.TingView:clearTingData()
end

function HandCardView:addHandCard( _pokerCard )
    local childs = self.hand_vw:getChildren()
    local pokerCards = {_pokerCard}
    for i,node in ipairs(childs) do
        table.insert(pokerCards, node._pokerCard)
    end
    self:setCurHandCards(pokerCards)
end

function HandCardView:getCurHandPokersAndZiPaiCards( )
    local childs = self.hand_vw:getChildren()
    local pokerCards = {}
    for i,node in ipairs(childs) do
        table.insert(pokerCards, node._pokerCard)
    end
    return pokerCards
end

function HandCardView:setCurHandCards(pokerCards)
    -- pokerCards = {
    --     8 + 16*1, 9 + 16*1, 10 + 16*1,
    --     8 + 16*0, 4 + 16*1,
    -- }
    -- pokerCards = {
    --     8 + 16*1, 9 + 16*1, 10 + 16*1,
    --     7 + 16*1, 6 + 16*1,
    --     8 + 16*1, 9 + 16*1, 10 + 16*1,
    -- }
    -- pokerCards = {
    --     8 + 16*1, 9 + 16*1, 10 + 16*1,
    --     6 + 16*1, 7 + 16*1,
    -- }
    -- g_396.curOutCard = 8 + 16*1
    self.pokerCards = clone(pokerCards)
    local scale = 1
    local size = Card:getShortCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale
    self.hand_vw:removeAllChildren()
    local result = CardUtils:getCurhandCard(pokerCards)
    local interY = cardHeight - 25
    local count = 0
    local initY = cardHeight / 2
    local userCount = #result - 1
    local size = self.hand_vw:getSize()
    local initX = (size.width - cardWidth * userCount ) / 2 
    for idx, cards in ipairs(result) do
        local posX = initX + (idx - 1) * cardWidth
        local zOrder = 5

        for index, pokerCard in ipairs(cards) do
            local cardNode = Card.new(pokerCard, "short")
            local y = initY + (index - 1) * interY
            cardNode:setZOrder(zOrder)
            cardNode:setPosition(math.ceil(posX), y)
            cardNode:addTo(self.hand_vw)
            cardNode._cardType = cards._type
            zOrder = zOrder - 1
            if cardNode._cardType == g_396.t_wei then
                cardNode:setColor(cc.c3b(127,127,127))
            end
            cardNode:onTouch(handler(self, self.onClickHandCard))
        end
    end
end

--cardNode有值的话就往最后加一列 没有的话就刷新位置
function HandCardView:setCurHandCardsPos(cardNode, isBegin)
    local posArr = {}
    local childs = self.hand_vw:getChildren()
    local colCount = 0
    for i,node in ipairs(childs) do
        if cardNode ~= node then
            local pos = node:getPosition()
            pos.x = math.ceil(pos.x)
            if not posArr[pos.x] then
                posArr[pos.x] = {}
                colCount = colCount + 1
            end
            table.insert(posArr[pos.x], node)
        end
    end
    local resultNode = {}
    for posX, nodes in pairs(posArr) do
        table.sort(nodes, function( a, b )
            local posa = a:getPosition()
            local posb = b:getPosition()
            return posa.y < posb.y
        end)
        nodes.posX = posX
        table.insert(resultNode, nodes)
    end
    table.sort(resultNode, function( a, b )
        return a.posX < b.posX
    end)
    if cardNode then
        if isBegin then
            table.insert(resultNode, 1, {cardNode})
        else
            table.insert(resultNode, {cardNode})
        end
        colCount = colCount + 1
    end
    local scale = 1
    local size = Card:getShortCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale
    local interY = cardHeight - 25
    local initY = cardHeight / 2
    local userCount = colCount - 1
    local size = self.hand_vw:getSize()
    local initX = (size.width - cardWidth * userCount ) / 2 
    for idx, nodes in pairs(resultNode) do
        local posX = initX + (idx - 1) * cardWidth
        local zOrder = 5
        for index, cardNode in ipairs(nodes) do
            local y = initY + (index - 1) * interY
            cardNode:setPosition(math.ceil(posX), y)
            zOrder = zOrder - 1
        end
    end
end

function HandCardView:removeCardNode(node)
    node:removeSelf()
    g_396.curClickCardNode = nil
    self:setCurHandCardsPos()
end

function HandCardView:removeHandCards( cards, curOutCard )
    local count = 0
    for idx, card in ipairs(cards) do
        if curOutCard == card then
            table.remove(cards, idx)
            break
        end
    end

    local childs = self.hand_vw:getChildren()
    for i,card in ipairs(cards) do
        for idx,node in ipairs(childs) do
            if node._pokerCard == card then
                table.remove(childs, idx)
                node:removeSelf()
                count = count + 1
                break        
            end
        end
    end
    
    self:setCurHandCardsPos()
    return count
end

function HandCardView:setTouchEnabledNodes( isEnabled, clickNode )
    local childs = self.hand_vw:getChildren()
    for i, cardNode in ipairs(childs) do
        if cardNode ~= clickNode then
            cardNode:setTouchEnabled(isEnabled)
        end
    end
end

function HandCardView:onClickHandCard(event)
	local target = event.target
    if event.name == "began" then
        self:setTouchEnabledNodes( false, target )
        local x, y = event.x, event.y
        target.orlPos = target:getPosition()
        target.orlZOrder = target:getZOrder()
        target.beganPos = cc.p(x,y)
        Card:changeImg(target, target._pokerCard, "short")
        
        local cardId = target._pokerCard
       
        self:setTingIcon( target )
    elseif event.name == "moved" then
        if target._type == "short" then
            target:setZOrder(6)
            Card:changeImg(target, target._pokerCard, "long")
            self:setTingIcon( target )
        end
        local beganPos = target.beganPos
        local orlPos = target.orlPos
        local x, y = event.x, event.y
        x = x - beganPos.x
        y = y - beganPos.y
        x = x + orlPos.x
        y = y + orlPos.y
        target:setPosition(x, y)
    elseif event.name == "ended" or event.name == "cancelled" then
        self:setTouchEnabledNodes( true )
        target:setZOrder(target.orlZOrder)
        local pos = target:getPosition()
        if g_396.isCanChuCard and pos.y > outCardLingPosY and target._cardType ~= g_396.t_wei then
            local _pokerCard = target._pokerCard
            -- target:removeSelf()
            g_396.curClickCardNode = target

            -- self:setCurHandCardsPos()
            dump("出牌", _pokerCard)
            SendHandle:CLI_PLAYER_OUT_CARD(_pokerCard)
            self.GameSceneView:isShowChuPai(false)
            self.GameSceneView:hideAllPlayerLight()
        else
            Card:changeImg(target, target._pokerCard, "short")
            self:setTingIcon( target )
            self:moveCardsPos(target)
        end
        self.TingView:unClickTing1()
	end
end

function HandCardView:setTingIcon( target )
    local cardId = target._pokerCard
    local cards = self.tingData[cardId]
    if cards then
        self.TingView:setTing1(cards)
        target:setTing()
    end    
end

function HandCardView:moveCardsPos(cardNode)
    local orlPos = cardNode.orlPos
    local cardPosX = cardNode:getPosition().x
    local posArr = {}
    local childs = self.hand_vw:getChildren()
    local colCount = 0
    for i,node in ipairs(childs) do
        if cardNode ~= node then
            local pos = node:getPosition()
            pos.x = math.ceil(pos.x)
            if not posArr[pos.x] then
                posArr[pos.x] = {}
                colCount = colCount + 1
            end
            table.insert(posArr[pos.x], node)
        end
    end
    local scale = 1
    local size = Card:getShortCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale
    
    local minNum = cardWidth
    local sum = 0
    local index --找到点击的牌是属于哪一列
    for posX, nodes in pairs(posArr) do
        local abs = math.abs(posX - cardPosX)
        if abs < minNum then
            minNum = abs
            index = posX
        end
    end
    if index == orlPos.x or cardPosX == orlPos.x then
        cardNode:setPosition(orlPos)
    elseif index then
        local nodes = posArr[index]
        if nodes and #nodes >= 4 then
            cardNode:setPosition(orlPos)
            return
        end
        table.sort(nodes, function( a, b )
            local posa = a:getPosition()
            local posb = b:getPosition()
            return posa.y < posb.y
        end)
        table.insert(nodes, cardNode)
        self:sortNodes( index, nodes)
        self:setCurHandCardsPos()
    elseif colCount < 10  then--小于10列
        self:setCurHandCardsPos(cardNode, cardPosX < orlPos.x)
    else
        cardNode:setPosition(orlPos)
    end
end

function HandCardView:sortNodes( posX, cardsNodes)
    cardsNodes = cardsNodes or {}
    local scale = 1
    local size = Card:getShortCardSize( )
    local cardWidth = size.width * scale
    local cardHeight = size.height * scale
    local zOrder = 5
    local interY = cardHeight - 25
    local initY = cardHeight / 2
    for index, cardNode in ipairs(cardsNodes) do
        cardNode:setPosition(math.ceil(posX), initY + (index - 1) * interY)
        cardNode:setZOrder(zOrder)
        zOrder = zOrder - 1
        cardNode.orlPos = cardNode:getPosition()
    end
end

function HandCardView:setTings(data)
    self:clearTingData()
    for idx,datai in ipairs(data) do
        self.tingData[datai.card] = datai.tingHuCards
    end
    local childs = self.hand_vw:getChildren()
    for idx,cardNode in ipairs(childs) do
        local _pokerCard = cardNode._pokerCard
        if self.tingData[_pokerCard] then
            cardNode:setTing()
        else
            cardNode:hideTing()
        end
    end
end

function HandCardView:setTingHuBtn( cardId )
    local cards = self.tingData[cardId]
    self:clearTingData()
    if cards then
        self.tingData = {}      --听牌数据
        self.tingHuCards = cards      --听牌胡数据
        self.TingView:setTing2(self.tingHuCards)
    end
    local childs = self.hand_vw:getChildren()
    for k,node in ipairs(childs) do
        node:hideTing()
    end
end


function HandCardView:setTingHuData( cards )
    self:clearTingData()
    if cards then
        self.tingData = {}      --听牌数据
        self.tingHuCards = cards      --听牌胡数据
        self.TingView:setTing2(self.tingHuCards)
    end
    local childs = self.hand_vw:getChildren()
    for k,node in ipairs(childs) do
        node:hideTing()
    end
end

return HandCardView