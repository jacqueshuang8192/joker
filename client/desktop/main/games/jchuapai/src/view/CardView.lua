local Card = require("jchuapai.src.Card")
local CardUtils = require("jchuapai.src.CardUtils").new()
local CardView = class("CardView")
local lineOutCardPosY = 147

function CardView:ctor(GameSceneView)
    self.GameSceneView = GameSceneView
    self.cards_vw = GameSceneView.cards_vw
    self.player_1 = GameSceneView.player_1
    self.backCardNodes = {}
    self.allBackAndHangCardNode = {}
    self.handCardNodes = {}
    self:initUI()
end

function CardView:setParam( OprorateBtn )
    self.OprorateBtn = OprorateBtn
end

function CardView:initUI()
    self.card_back = self.cards_vw.card_back:hide()
    self.img_count = self.cards_vw.img_count:hide()
    self.click_mask = self.cards_vw:getParent().click_mask:hide()
end

function CardView:clearData()
    for i, backCard in ipairs(self.allBackAndHangCardNode) do
        backCard:removeSelf()
    end
    self.backCardNodes = {}
    self.handCardNodes = {}
    self.img_count:hide()
    self.click_mask:hide()
end

function CardView:setCardsBack(count)
    self:clearData()
    local pos = self.card_back:getPosition() 
    local rot = self.card_back:getRotation() 
    for idx = 1, count do
        local backCard = Card.new("back")
        backCard:addTo(self.cards_vw)
        backCard:setPosition(pos.x, pos.y + idx * 0.1)       
        backCard:setRotation(rot)
        table.insert(self.backCardNodes, 1, backCard)
        table.insert(self.allBackAndHangCardNode, backCard)
    end
    local idx = self.img_count:getZOrder()
    self.img_count:setZOrder(idx + count)
end

function CardView:isShowBackNodeCount( isShow, count )
    self.img_count:setVisible(isShow)
    if count then
        self.img_count.txt_cardCount:setString(count)
        self.backCount = count
    end
end

function CardView:setCurHandCards(handCards)
    local result = CardUtils:_findHandCards(handCards)
    local time = 0.1
    local count = 0
    for idx, cards in ipairs(result) do
        local hand = self.cards_vw["hand"..idx]
        local pos = hand:getPosition()
        local posX = math.ceil(pos.x)
        local initY = -140
        local zOrder = 50
        local interY = 228 / (#cards -1)
        if interY > 60 then
            interY = 60
        end
        local cardsNodes = {}
        local isLast_1 = #result == idx
        for index, card in ipairs(cards) do
            local cardNode = table.remove( self.backCardNodes, 1 )
            table.insert(cardsNodes, cardNode)
            table.insert(self.handCardNodes, cardNode)
            zOrder = zOrder - 1
            local y = initY + (index - 1) * interY
            local isLast_2 = #cards == index
            -- local MoveTo = cc.MoveTo:create(time, cc.p(posX, y))
            -- local RotateTo = cc.RotateTo:create(time, 0)
            -- local DelayTime = cc.DelayTime:create(time*count)
            -- local Spawn = cc.Spawn:create(MoveTo, RotateTo)
            -- local CallFunc = cc.CallFunc:create(function(cardNode, args)
            --     cardNode:changeImg("long", args.card)
            --     cardNode:setZOrder(args.zOrder)
            --     cardNode:onTouch(handler(self, self.onClickHandCard))
            --     if args.isLast_2 then
            --         self:sortNodes( posX, args.cardsNodes)
            --     end
            --     if args.isLast_1 then
            --         self:isShowBackNodeCount(true, g_388.backCount - #handCards)
            --     end
            -- end, {
            --     zOrder = zOrder, 
            --     card = card, 
            --     cardsNodes = cardsNodes, 
            --     isLast_1 = isLast_1, 
            --     isLast_2 = isLast_2, 
            -- })
            -- local Sequence = cc.Sequence:create(DelayTime, Spawn, CallFunc)
            -- cardNode:runAction(Sequence)
            -- count = count + 1

            cardNode:setRotation(0)
            cardNode:changeImg("long", card)
            cardNode:setZOrder(zOrder)
            cardNode:onTouch(handler(self, self.onClickHandCard))
            self:setNodeEventEnabled(cardNode)
            if isLast_2 then
                self:sortNodes( posX, cardsNodes)
            end
            if isLast_1 then
                self:isShowBackNodeCount(true, g_388.backCount)
            end
        end
        -- self:sortNodes( pos.x, cardNodes)
    end
end

function CardView:addHandCard(card)
    local cards = {card}
    local time = 0
    local count = 0
    local hand, cardsNodes = self:getFreeHandNode()
    local pos = hand:getPosition()
    local posX = math.ceil(pos.x)
    local initY = -140
    local zOrder = 50
    local interY = 228 / (#cards -1)
    if interY > 60 then
        interY = 60
    end
    for index, card in ipairs(cards) do
        local cardNode = table.remove( self.backCardNodes, 1 )
        table.insert(cardsNodes, cardNode)
        table.insert(self.handCardNodes, cardNode)
        zOrder = zOrder - 1
        local y = initY + (index - 1) * interY
        -- local MoveTo = cc.MoveTo:create(time, cc.p(posX, y))
        -- local RotateTo = cc.RotateTo:create(time, 0)
        -- local DelayTime = cc.DelayTime:create(time*count)
        -- local Spawn = cc.Spawn:create(MoveTo, RotateTo)
        -- local CallFunc = cc.CallFunc:create(function(cardNode, args)
        --     cardNode:changeImg("long", args.card)
        --     cardNode:setZOrder(args.zOrder)
        --     self:sortNodes( posX, args.cardsNodes)
        --     self:isShowBackNodeCount(true, self.backCount - 1)
        --     cardNode:onTouch(handler(self, self.onClickHandCard))
        -- end, {
        --     zOrder = zOrder, 
        --     card = card, 
        --     cardsNodes = cardsNodes, 
        -- })
        -- local Sequence = cc.Sequence:create(DelayTime, Spawn, CallFunc)
        -- cardNode:runAction(Sequence)
        -- count = count + 1

        cardNode:setRotation(0)
        cardNode:changeImg("long", card)
        cardNode:setZOrder(zOrder)
        self:sortNodes( posX, cardsNodes)
        self:isShowBackNodeCount(true, self.backCount - 1)
        cardNode:onTouch(handler(self, self.onClickHandCard))
        self:setNodeEventEnabled(cardNode)
        self:isShowLight(cardNode)

    end
end

function CardView:setNodeEventEnabled( cardNode )
    local listener = function(event)
        local name = event.name
        if name == "enter" then
        elseif name == "exit" then
            self:onHandCardNodeExit(cardNode)
        elseif name == "enterTransitionFinish" then
        elseif name == "exitTransitionStart" then
        elseif name == "cleanup" then
        end
    end
    cardNode:setNodeEventEnabled(true, listener)
end

function CardView:getFreeHandNode()
    local handCardNodes = {}
    for i, node in ipairs(self.handCardNodes) do
        local pos = node.orlPos
        local x = math.ceil(pos.x)
        if not handCardNodes[x] then
            handCardNodes[x] = {}
        end
        table.insert(handCardNodes[x], node)
    end
    for idx = 9, 1 ,-1 do
        local hand = self.cards_vw["hand"..idx]
        local pos = hand:getPosition()
        local x = math.ceil(pos.x)
        local handCardNode = handCardNodes[x] or {}
        if #handCardNode < 9 then
            return hand, handCardNode
        end
    end
end

function CardView:removeHandCards( cards, curOutCard )
    for idx, card in ipairs(cards) do
        if curOutCard == card then
            table.remove(cards, idx)
            break
        end
    end
    for i,card in ipairs(cards) do
        for idx, node in ipairs(self.handCardNodes) do
            if node._card == card then
                local pos = node.orlPos
                local x = math.ceil(pos.x)
                table.remove(self.handCardNodes, idx)
                node:removeSelf()
                break        
            end
        end
    end

    local handCardNodes = {}
    for idx = 1, 9 do
        local hand = self.cards_vw["hand"..idx]
        local pos = hand:getPosition()
        local x = math.ceil(pos.x)
        handCardNodes[x] = {}
    end
    for i, node in ipairs(self.handCardNodes) do
        local pos = node.orlPos
        local x = math.ceil(pos.x)
        if handCardNodes[x] then
            table.insert(handCardNodes[x], node)
        else
            assert(false, "level 388 摆牌错误")
        end
    end
    for posX, cardNodes in pairs(handCardNodes) do
        self:sortNodes( posX, cardNodes)

    end
end

function CardView:moveCardsPos(cardNode)
    local posArr = {}
    local cardPosX = cardNode:getPosition().x
    local sum = 0
    local minNum = 100
    local index = 1
    for idx = 1, 9 do
        local hand = self.cards_vw["hand"..idx]
        local pos = hand:getPosition()
        local abs = math.abs(pos.x - cardPosX)
        if abs < minNum then
            minNum = abs
            index = idx
        end
    end
    local hand = self.cards_vw["hand"..index]
    local pos = hand:getPosition()
    local posX = math.ceil(pos.x)
    self:handMoveCardNodes( posX, cardNode )
end

--根据posX来排序
function CardView:handMoveCardNodes( posX, cardNode )
    local orlPos = cardNode.orlPos
    local handCardNodes = {}
    for idx = 1, 9 do
        local hand = self.cards_vw["hand"..idx]
        local pos = hand:getPosition()
        local x = math.ceil(pos.x)
        handCardNodes[x] = {}
    end
    for i, node in ipairs(self.handCardNodes) do
        local pos = node.orlPos
        local x = math.ceil(pos.x)
        if handCardNodes[x] then
            table.insert(handCardNodes[x], node)
        else
            assert(false, "level 388 摆牌错误")
        end
    end
    local handCards_a = handCardNodes[posX]
    if #handCards_a <= 8 then
        local handCards_b = handCardNodes[orlPos.x] or {}
        table.sort(handCards_a, function( a, b )
            local posa = a:getPosition()
            local posb = b:getPosition()
            return posa.y < posb.y
        end)
        if orlPos.x ~= posX then--不是同一列的
            table.insert(handCards_a, cardNode)

            for idx, node in ipairs(handCards_b) do
                if node == cardNode then
                    table.remove(handCards_b, idx)
                end
            end
        end
        
        self:_findKongYiJi(handCards_a)
        self:_findKongYiJi(handCards_b)
        self:sortNodes( posX, handCards_a)
        self:sortNodes( orlPos.x, handCards_b)
    else
        cardNode:setPosition(orlPos)
        viewMgr:showTip({text = "一列最多有9张牌"})
    end
end

function CardView:_findKongYiJi(nodes)
    -- 下标1~10表示一二...十，下标11~22表示孔已话千土子上大人可知礼，23表示赖子
    local oneAndTwoCards = {}
    for i,node in ipairs(nodes) do
        if not oneAndTwoCards[node._card] then
            oneAndTwoCards[node._card] = {}
        end
        table.insert(oneAndTwoCards[node._card], node)
    end
    local count1 = oneAndTwoCards[0x01] or {}
    local count4 = oneAndTwoCards[0x11] or {}
    local count2 = oneAndTwoCards[0x21] or {}
    local count3 = oneAndTwoCards[0x22] or {}
    if #count1 + #count2 + #count3 + #count4 == #nodes then--孔乙己
        local tab = {
            [1] = 2,
            [11] = 1,
            [12] = 3,
        }
        table.sort(nodes, function( a, b )
            local valeua = CardUtils:GetCardLogicValue(a._card)
            local valeub = CardUtils:GetCardLogicValue(b._card)
            return tab[valeua] > tab[valeub]
        end)
    else
        local count1 = oneAndTwoCards[0x03] or {}
        local count4 = oneAndTwoCards[0x13] or {}
        local count2 = oneAndTwoCards[0x23] or {}
        local count3 = oneAndTwoCards[0x24] or {}
        if #count1 + #count2 + #count3 + #count4 == #nodes then--化三千
            local tab = {
                [3] = 2,
                [13] = 1,
                [14] = 3,
            }
            table.sort(nodes, function( a, b )
                local valeua = CardUtils:GetCardLogicValue(a._card)
                local valeub = CardUtils:GetCardLogicValue(b._card)
                return tab[valeua] > tab[valeub]
            end)
        else
            table.sort(nodes, function( a, b )
                return CardUtils:GetCardLogicValue(a._card) > CardUtils:GetCardLogicValue(b._card)
            end)
        end
    end
end

function CardView:sortNodes( posX, cardsNodes)
    cardsNodes = cardsNodes or {}
    posX = math.ceil(posX)
    local initY = -140
    local zOrder = 50
    local interY = 228 / (#cardsNodes -1)
    if interY > 60 then
        interY = 60
    end
    self:_findKongYiJi(cardsNodes)
    for index, cardNode in ipairs(cardsNodes) do
        cardNode:setPosition(posX, initY + (index - 1) * interY)
        cardNode:setZOrder(zOrder)
        zOrder = zOrder - 1
        cardNode.orlPos = cardNode:getPosition()
    end
end

function CardView:sortNodesByPosX( posX )
    posX = math.ceil(posX)
    local handCardNodes = {}
    for idx = 1, 9 do
        local hand = self.cards_vw["hand"..idx]
        local pos = hand:getPosition()
        local x = math.ceil(pos.x)
        handCardNodes[x] = {}
    end
    for i, node in ipairs(self.handCardNodes) do
        local pos = node.orlPos
        local x = math.ceil(pos.x)
        if handCardNodes[x] then
            table.insert(handCardNodes[x], node)
        else
            assert(false, "level 388 摆牌错误")
        end
    end
    local handCardNodes = handCardNodes[posX]
    self:sortNodes( posX, handCardNodes)
end

function CardView:onClickHandCard(event)
    local target = event.target
    if event.name == "began" then

        if not target.click then
            target.click = 0
        end
        target.click  = target.click + 1
        if target.click >= 2 then
            if g_388.isCanChuCard then
                g_388.curClickCardNode = target
                self.OprorateBtn:onClick_chu()
                for i,v in ipairs(target:getParent():getChildren()) do
                    v.click = 0
                end
                return
            end
        end
        self:isShowMask( true )
        local x, y = event.x, event.y
        target.orlPos = target:getPosition()
        target.beganPos = cc.p(x,y)
        self:isShowLight(target)
        self.GameSceneView:isShowLine( true )
    elseif event.name == "moved" then
        local beganPos = target.beganPos
        local orlPos = target.orlPos
        local x, y = event.x, event.y
        x = x - beganPos.x
        y = y - beganPos.y
        x = x + orlPos.x
        y = y + orlPos.y
        target:setPosition(x, y)
        target.isMoved = true
    elseif event.name == "ended" or event.name == "cancelled" then
        self.GameSceneView:isShowLine( false )
        self:isShowMask( false )
        local y = target:getPosition().y
        if y >= lineOutCardPosY then
            if g_388.isCanChuCard then
                g_388.curClickCardNode = target
                self.OprorateBtn:onClick_chu()
                return
            end
        end
        if target.isMoved then
            self:moveCardsPos(target)
        else
            -- self:isShowLight(target)
        end
		dump(target._card)
        target.isMoved = false
	end
end

function CardView:isShowMask( isEnabled )
    self.click_mask:setVisible(isEnabled)
end

function CardView:isShowLight( cardNode )
    local isShow = not cardNode:getShowLight()
    if isShow then
        for i, cardNode in ipairs(self.handCardNodes) do
            local isShow = cardNode:getShowLight()
            if isShow then
                cardNode:isShowLight(false)
            end
        end
    else
        -- if g_388.isCanChuCard then
        --     g_388.curClickCardNode = cardNode
        --     self.OprorateBtn:onClick_chu()
        --     return
        -- end
    end
    g_388.curClickCardNode = isShow == true and cardNode or nil
    cardNode:isShowLight(isShow)
end

--当删除手牌时候回调用刷新position
function CardView:onHandCardNodeExit( cardNode )
    local orlPos = cardNode.orlPos
    for idx,node in ipairs(self.handCardNodes) do
        if cardNode == node then
            table.remove(self.handCardNodes, idx)
            break
        end
    end
    self:sortNodesByPosX( orlPos.x )
    g_388.cardsAllNode[cardNode] = nil
end

function CardView:removeCardNode( curClickCardNode )
    for idx, node in ipairs(self.handCardNodes) do
        if node == curClickCardNode then
            table.remove(self.handCardNodes, idx)
            break        
        end
    end
    curClickCardNode:onExit()
    curClickCardNode:removeFromParent(true)
    -- curClickCardNode:removeSelf()
end

function CardView:getHandCardsAndFanCards()
    local cards = {}
    for idx, node in ipairs(self.handCardNodes) do
        local card = node._card
        if card <= 25 then
            card = card % 16
        end
        if not cards[card] then
            cards[card] = 0
        end
        cards[card] = cards[card] + 1
        if cards[card] == 5 then--手牌中有5张的不算
            cards[card] = nil
        end
    end
    dump(cards, "handCardNodes")
    dump(self.player_1:getFanCards(), "self.player_1:getFanCards()")
    for card, count in pairs(self.player_1:getFanCards()) do
        if cards[card] then
            cards[card] = cards[card] + count
        end
    end
    dump(g_388.curOutCard, "g_388.curOutCard")
    if g_388.curOutCard then--手里有4张 加别人打可以泛
        local card = g_388.curOutCard
        if card <= 25 then
            card = card % 16
        end
        if cards[card] then
            cards[card] = cards[card] + 1
        end
    end
    local result = {}
    for card, count in pairs(cards) do
        if count == 5 then
            table.insert(result, card)
        end
    end
    return result
end

return CardView

