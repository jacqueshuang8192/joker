local GameLogic = require(g_342.path..".util.GameLogic")
local CardConfig = require(g_342.path..".util.CardConfig")
local CardSprite = require(g_342.path..".util.CardSprite")
local scheduler = require("framework.scheduler")
local CardLayer1 = class("CardLayer1", function()
    return display.newLayer()
end)

function CardLayer1:ctor(PHZMainLayer, level)
    self.m_GameLogic = GameLogic:new()
    self.m_CardConfig = CardConfig:new()
    self.PHZMainLayer = PHZMainLayer
    self.level = level
    self:init()
end

function CardLayer1:init()
    local m_mainLayer = self.PHZMainLayer.m_mainLayer
    self.m_mainLayer = m_mainLayer
    self.hand_vws = {}
    self.hand_cards = {}
    self.m_JinBg = {}           --放置要的牌
    self.m_QiBg = {}            --放置不要的牌
    self.m_OutSprite = {}            -- --出牌字牌
    self.m_DCardData = {}      --弃牌数据
    self.m_WeaveItem = {}      --进牌数据
    for idx=1, g_342.maxSeat do
		local player = m_mainLayer["player_"..idx]
        self.m_OutSprite[idx] = player:getChildByName("deal_card")
        self.hand_vws[idx] = player:getChildByName("hand_vw")
        if not self.m_OutSprite[idx] then
            dump("noPlayData")
        end
        self.m_OutSprite[idx]:setVisible(false)
        self.m_OutSprite[idx]:setScale(0.6)
        self.m_OutSprite[idx].bg:setLocalZOrder(-1)
        self.m_QiBg[idx] = player:getChildByName("qi_vw")
        self.m_JinBg[idx] = player:getChildByName("pengAndGang_vw")
        self.m_DCardData[idx] = {}  
        self.m_WeaveItem[idx] = {}  
    end
end

--隐藏出牌字牌
function CardLayer1:hideDealCard()
    for i=1,g_342.maxSeat do
		self.m_OutSprite[i]:setVisible(false)
	end
end

--设置自己当前牌
function CardLayer1:setCurHandCard(cards, viewId)
    local hand_vw = self.hand_vws[viewId]
    self.hand_cards[viewId] = cards
    hand_vw:removeAllChildren()
    local WeaveArray,ArrayCount = self.m_GameLogic:getCurhandCard(cards)
    self:drawCenterCard(WeaveArray, ArrayCount, viewId)
end

--绘画手牌
function CardLayer1:drawCenterCard( WeaveArray, arrCount, viewId )
    local scale = 1
    if viewId == g_342.myViewId then
        scale = g_342.myScele
    else
        scale = g_342.otherScele
    end
    local hand_vw = self.hand_vws[viewId]
    local weaveCount = #WeaveArray
    for key, value in ipairs(WeaveArray) do
        local cardCount = #value
        local isDark = false
        if cardCount >= 3 and value[1] == value[2] and value[1] == value[3] then
            isDark = true
        end
        for i, j in ipairs(value) do
            local cardInfo = self.m_CardConfig:getCardInfoByid(j)
            if cardInfo then
                local cardObj = CardSprite.new(j,i,key)
                cardObj:setScale(scale)
                hand_vw:addChild(cardObj,4-i)
                local pos = self:positionOfItem( i, key, viewId, weaveCount )
                local move2 = cc.MoveTo:create(0.1, pos)
                cardObj:runAction(cc.Sequence:create(move2))
                if isDark then
                    cardObj:setCardCovered(true)
                end
            end
        end
    end
end

function CardLayer1:fillVacancies(viewId)
    local hand_vw = self.hand_vws[viewId]:getChildren()
    local colCount = 0
    local cols = {}
    for idx, node in ipairs(hand_vw) do
        local pos = node:getPosition()
        local x = math.ceil( pos.x )
        local y = math.ceil( pos.y )
        local pos = {}
        pos.x = x
        pos.y = y
        pos.nodeIdx = idx
        if not cols[x] then
            cols[x] = {}
        end
        table.insert(cols[x], pos)
    end
    local tem = {}
    for idx,tal in pairs(cols) do
        colCount = colCount + 1
        table.sort(tal, function( posa,posb )
            return posa.y < posb.y
        end)
        table.insert(tem, tal)
    end
    cols = tem
    table.sort(cols, function( taba, tabb )
        return taba[1].x < tabb[1].x
    end)
    dump(cols)
    for idx, tab in ipairs(cols) do
        for idxx, pos in ipairs(tab) do
            local node = hand_vw[pos.nodeIdx]
            local pos = self:positionOfItem( idxx, idx, viewId, colCount )
            node:setPosition(pos)
        end
    end
end

function CardLayer1:getNoodeByPos( node, cols )
    
end

--根据行列号获取位置
function CardLayer1:positionOfItem( row, col, viewId, colCount )
    local scale = 1
    if viewId == g_342.myViewId then
        scale = g_342.myScele
    else
        scale = g_342.otherScele
    end
    local cardW = g_342.cardW * scale
    local cardH = g_342.cardH * scale
    local initNum = (g_342.MaxCol - colCount) / 2
    local px = (initNum * cardW) + cardW / 2 + (col-1)*cardW
    local py = cardH/2 + (row-1)*cardH
    return cc.p(px,py)
end
----------------
--出牌
function CardLayer1:playerOutCard(viewId, card)
    local cardInfo = self.m_CardConfig:getCardInfoByid(card)
    self:removeCardByWeave({card}, viewId)
    if cardInfo then
        local imgPath = string.format("%s.png",cardInfo.CardIconC)
        local frame = display.newSpriteFrame(imgPath)
        self.m_OutSprite[viewId]:setSpriteFrame(frame)
        self.m_OutSprite[viewId]:setVisible(true)
    end
end

function CardLayer1:supplyCard(viewId, cbBuCard,cardFrom)
    local cardInfo = self.m_CardConfig:getCardInfoByid(cbBuCard)
    local daelCardNode = self.m_OutSprite[viewId]
    if cardInfo and daelCardNode then
        daelCardNode:hide()
        local SendCardPos = self.PHZMainLayer:getSendCardPos()
        local imgPath = string.format("#%s.png",cardInfo.CardIconC)
        local tempCard = display.newSprite(imgPath)
        tempCard:setPosition(SendCardPos)
        tempCard:setScale(0.6)
        self:addChild(tempCard,20)
        --动作：从底牌位置移动到出牌区，显示出牌
        local worldpoint = (daelCardNode:getParent()):convertToWorldSpace(daelCardNode:getPosition()) --这样写是为了贴近函数的原始用法
        local move = cc.MoveTo:create(0.2,cc.p(worldpoint))
        local func = cc.CallFunc:create(function( fc )
            local framePath = string.format("%s.png",cardInfo.CardIconC)
            local frame = display.newSpriteFrame(framePath)
            tempCard:removeFromParent()
            table.insert(self.hand_cards[viewId], cbBuCard)
            self:setCurHandCard(self.hand_cards[viewId], viewId)
        end)
        tempCard:runAction(cc.Sequence:create(move,func))
    end
end

--玩家弃牌
function CardLayer1:onDiscardCard( viewId, curCard )
    self.m_OutSprite[viewId]:setVisible(false)
    local cardInfo = self.m_CardConfig:getCardInfoByid(curCard)
    if cardInfo then
        self:drawQiCard(viewId,curCard)
    end
end

--绘画弃牌
function CardLayer1:drawQiCard( viewId, cardData )
    if not self.m_DCardData[viewId] then
        self.m_DCardData[viewId] = {}
    end
    local cardInfo = self.m_CardConfig:getCardInfoByid(cardData)
    if cardInfo then
        local imgPath = string.format("%s.png",cardInfo.CardIconA)
        local cardObj = display.newSprite()
        local frame = display.newSpriteFrame(imgPath)
        cardObj:setSpriteFrame(frame)
        local size = cardObj:getContentSize()
        local cardW = size.width
        local cardH = size.height
        local tnumber = #self.m_DCardData[viewId]
        local row = 5
        -- if viewId == g_342.downViewId then
        --     row = 2
        -- end
        local idx = tnumber+1
        local rowIdx = idx % row
        rowIdx = rowIdx == 0 and row or rowIdx
        local colIdx = math.ceil(idx / row)
        local x = cardW/2 + (rowIdx - 1) * cardW
        local y = cardH/2 - (colIdx - 1) * cardH
        y = cardH/2 + (colIdx - 1) * cardH
        if viewId == g_342.myViewId or viewId == g_342.downViewId then
        end
        if viewId == g_342.leftViewId or viewId == g_342.myViewId then
        end
        cardObj:setPosition(x,y)
        self.m_QiBg[viewId]:addChild(cardObj)
        table.insert(self.m_DCardData[viewId],cardData)
    end

end

--派发单牌
function CardLayer1:sendCard(viewId, cardData, bshow)
    local cardInfo = self.m_CardConfig:getCardInfoByid(cardData)
    local daelCardNode = self.m_OutSprite[viewId]
    if cardInfo and daelCardNode then
        daelCardNode:hide()
        local SendCardPos = self.PHZMainLayer:getSendCardPos()
        local imgPath = string.format("#%s.png",cardInfo.CardIconC)
        if bshow == 0 then
            imgPath = "#hc_card_back_C.png"
        end
        local tempCard = display.newSprite(imgPath)
        tempCard:setPosition(SendCardPos)
        tempCard:setScale(0.6)
        self:addChild(tempCard,20)
        --动作：从底牌位置移动到出牌区，显示出牌
        local worldpoint = (daelCardNode:getParent()):convertToWorldSpace(daelCardNode:getPosition()) --这样写是为了贴近函数的原始用法
        local move = cc.MoveTo:create(0.2,cc.p(worldpoint))
        local func = cc.CallFunc:create(function( fc )
            local framePath = string.format("%s.png",cardInfo.CardIconC)
            if bshow == 0 then
                framePath = "hc_card_back_C.png"
            end
            local frame = display.newSpriteFrame(framePath)
            daelCardNode:setSpriteFrame(frame)
            daelCardNode:setVisible(true)
            tempCard:removeFromParent()
        end)
        tempCard:runAction(cc.Sequence:create(move,func))
    end
end

function CardLayer1:onChiCard(viewId,cardData)
    local chiWeaveItem  = {}
    chiWeaveItem.cbWeaveKind  = g_342.t_chi
    chiWeaveItem.cbCardCount  = 3
    chiWeaveItem.cbCenterCard = cardData[1]
    chiWeaveItem.cbCardList   = {cardData[3],cardData[2],cardData[1]}
    chiWeaveItem.weaveCard    = {cardData[3],cardData[2],cardData[1]}
    --增加吃的牌做阴影
    chiWeaveItem.showChi      = true

    --删除手牌数据
    local removeWeave = {cardData[2],cardData[3]}
    self:showWeaveCard(viewId, chiWeaveItem, removeWeave)
end

--组合扑克（达成组合并展示出来的牌） weaveItem.weaveCard
function CardLayer1:showWeaveCard( viewId, weaveItem, removeWeave )
    local tempCbCenterCard = weaveItem.cbCenterCard
    local tempCbWeaveKind = weaveItem.cbWeaveKind
    local tempCbCount = weaveItem.cbCardCount
    local addIndex = #self.m_WeaveItem[viewId] + 1
    local isWeiChanged = false
    for k,v in pairs(self.m_WeaveItem[viewId]) do
        if tempCbCount == 4 and tempCbCenterCard == v.cbCenterCard and  (tempCbWeaveKind == g_342.t_piao or tempCbWeaveKind == g_342.t_sao_ex) then
            table.remove(self.m_WeaveItem[viewId],k)
            isWeiChanged = true
            addIndex = k
            break
        end  
    end

    -- --插入新数据，删除旧字牌
    table.insert(self.m_WeaveItem[viewId],addIndex,weaveItem)
    self.m_JinBg[viewId]:removeAllChildren()

    for k,v in pairs(self.m_WeaveItem[viewId]) do
        for k1,v1 in pairs(v.weaveCard) do
          
            local imgPath = g_342.path1.."res/CardLitter/Card_miniature_000.png"
            local cardInfo = self.m_CardConfig:getCardInfoByid(v1)
            if cardInfo then
                imgPath = string.format("%s.png",cardInfo.CardIconA)
            end
            local cardObj = display.newSprite()
            local frame = display.newSpriteFrame(imgPath)
            cardObj:setSpriteFrame(frame)
            local size = cardObj:getContentSize()
            local cardW = size.width
            local cardH = size.height
            local x = cardW/2 + (k-1)*cardW
            -- if viewId == g_342.leftViewId then  --当为右边的玩家时，位置微调
                -- local tempSize = self.m_JinBg[viewId]:getContentSize().width
                -- x = tempSize - cardW/2 - (k-1)*cardW
            -- end
            local y = cardW/2 + (k1-1)*cardW
            cardObj:setPosition(x,y)
            self.m_JinBg[viewId]:addChild(cardObj,10-k1)
        end
    end
    dump(viewId,"wViewId删除手牌")
    if viewId == g_342.myViewId then
        print("删除手牌")
        
    end
    self:removeCardByWeave(removeWeave, viewId)
    print("组合出的牌")
    
    self:updateHuXiCount(viewId)
end

--更新胡息
function CardLayer1:updateHuXiCount(viewId)
    -- print("更新胡息",viewId)
    local huXiCount = 0
    for k,v in pairs(self.m_WeaveItem[viewId]) do
        local huxi = self.m_GameLogic:GetWeaveHuXi(v)
        huXiCount = huXiCount + huxi
    end
    self.PHZMainLayer.players[viewId]:setHuXi(huXiCount)
end

function CardLayer1:removeCardByWeave(removeWeave, viewId)
    local hand_vw = self.hand_vws[viewId]:getChildren()
	
    for _,card in ipairs(removeWeave) do
        for idx,node in ipairs(hand_vw) do
            if node:getCardId() == card then
                table.remove(hand_vw, idx)
                node:removeSelf()
                break
            end
        end

        for idx,card_1 in ipairs(self.hand_cards[viewId]) do
            if card_1 == card then
                table.remove(self.hand_cards[viewId], idx)
                break
            end
        end
    end
    self:fillVacancies(viewId)
end

--移除字牌
function CardLayer1:removeHandCardById( card )
    
end
--移除字牌
function CardLayer1:popCurCardList( target )
  
end

function CardLayer1:onBiCard(viewId,cardData,biCardValue)

    local arrNum = #cardData/3

    for i=1,arrNum do
        local tempIndex = (i-1)*3
        local chiWeaveItem  = {}
        chiWeaveItem.cbWeaveKind  = g_342.t_chi
        chiWeaveItem.cbCardCount  = 3
        chiWeaveItem.cbCenterCard = cardData[1+tempIndex]
        chiWeaveItem.cbCardList   = {cardData[1+tempIndex],cardData[2+tempIndex],cardData[3+tempIndex]}
        chiWeaveItem.weaveCard    = {cardData[1+tempIndex],cardData[2+tempIndex],cardData[3+tempIndex]}

        chiWeaveItem.cbCardList = self:sortBiCardList(chiWeaveItem.cbCardList,biCardValue)
        chiWeaveItem.weaveCard = self:sortBiCardList(chiWeaveItem.cbCardList,biCardValue)

        chiWeaveItem.isBi = true
        chiWeaveItem.biCardNumber = self:getBiCardValueNumber(chiWeaveItem.cbCardList,biCardValue)

        --删除手牌数据
        local removeWeave = {cardData[1+tempIndex],cardData[2+tempIndex],cardData[3+tempIndex]}
        self:showWeaveCard(viewId, chiWeaveItem, removeWeave)
    end
end

--得到一个数组中比牌相同的个数
function CardLayer1:getBiCardValueNumber(arr,biCardValue)
    local tempBiCount = 0
    for k,v in pairs(arr) do
        if v == biCardValue then
            tempBiCount = tempBiCount + 1
        end
    end
    return tempBiCount
end

function CardLayer1:sortBiCardList(arr,biCardValue)
    local tempArr = {}
    for k,v in pairs(arr) do
        if v ~= biCardValue then
            table.insert(tempArr,v)
        end
    end
    for k,v in pairs(arr) do
        if v == biCardValue then
            table.insert(tempArr,biCardValue)
        end
    end
    return tempArr
end

function CardLayer1:onFirstSaoCard( viewId, cbCurCard )
    print("CardLayer1:onFirstSaoCard()",viewId, cbCurCard)
    --扫牌数据
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = g_342.t_wai
    weaveItem.cbCardCount  = 3
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard}
    weaveItem.weaveCard = {cbCurCard,0x00,0x00}
  
    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard,cbCurCard}
    local eventType = g_342.t_wai
    self:showWeaveCard(viewId, weaveItem, removeWeave)
end

--碰牌 wChairId操作玩家, cbCurCard操作的牌
function CardLayer1:onPengCard( viewId, cbCurCard )
    print("CardLayer1:onPengCard()",viewId, cbCurCard)
    --碰牌数据
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = g_342.t_peng
    weaveItem.cbCardCount  = 3
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard}
    weaveItem.weaveCard    = {cbCurCard,cbCurCard,cbCurCard}
    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard}
    self:showWeaveCard(viewId, weaveItem, removeWeave)
    -- g_EventLayer:showEventTips(viewId, g_342.t_peng)
end

--飘 wChairId操作玩家, cbCurCard操作的牌
function CardLayer1:onPiaoCard( wViewId, cbCurCard )
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = g_342.t_piao
    weaveItem.cbCardCount  = 4
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    weaveItem.weaveCard    = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    local removeWeave = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    self:showWeaveCard(wViewId, weaveItem, removeWeave)
end


-- 溜牌 wChairId操作玩家, cbCurCard操作的牌
function CardLayer1:onLiuCard( wViewId, cbCurCard )
    local item  = {}
    item.cbWeaveKind  = g_342.t_liu
    item.cbCardCount  = 4
    item.cbCenterCard = cbCurCard
    item.cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    item.weaveCard   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    self:showWeaveCard(wViewId, item, removeWeave)
end


--跑四张全部盖底（） wChairId操作玩家, cbCurCard操作的牌
function CardLayer1:onSaoExCard( viewId, cbCurCard, removeCount, isPao)
    print("CardLayer1:onSaoExCard()",viewId, cbCurCard,removeCount)
    --扫穿数据
    local weaveItem = {}
    weaveItem.cbWeaveKind  = g_342.t_sao_ex
    if isPao then
       weaveItem.cbWeaveKind  = g_342.t_piao 
    end
    weaveItem.cbCardCount  = 4
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
  
    weaveItem.weaveCard = {cbCurCard,0x00,0x00,0x00}
   
    if isPao then
         weaveItem.weaveCard = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    end

    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    if removeCount==0 then
        weaveItem = {}
        removeWeave = {}
        for i=1, #self.m_WeaveItem[viewId] do
            local cbWeaveKind = self.m_WeaveItem[viewId][i].cbWeaveKind
            local cbListCard = self.m_WeaveItem[viewId][i].cbCardList[1]
            if cbListCard==cbCurCard and (cbWeaveKind==g_342.t_wai or cbWeaveKind==g_342.t_peng) then
                self.m_WeaveItem[viewId][i].cbWeaveKind  = g_342.t_sao_ex
                self.m_WeaveItem[viewId][i].cbCardCount  = 4
                self.m_WeaveItem[viewId][i].cbCenterCard = cbCurCard
                self.m_WeaveItem[viewId][i].cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
                if isPao then
                    self.m_WeaveItem[viewId][i].weaveCard = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
                else
                    self.m_WeaveItem[viewId][i].weaveCard = {cbCurCard,0x00,0x00,0x00}
                end
            end
        end
    end
    self:showWeaveCard(viewId, weaveItem, removeWeave)
end

--操作出牌 wChairId操作玩家, cbOutUser出牌玩家
function CardLayer1:onEventCard( viewId, wResViewId )
    print("CardLayer1:onEventCard()",viewId, wResViewId)
    if not self.m_OutSprite[wResViewId]:isVisible() then return end
    local epos = self.m_JinBg[viewId]:getPosition()
end

--畏 wChairId操作玩家, cbCurCard操作的牌
function CardLayer1:onSaoCard( viewId, cbCurCard, saoType )
    print("CardLayer1:onSaoCard()",viewId, cbCurCard, saoType)
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = g_342.t_wai
    weaveItem.cbCardCount  = 3
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard}
    if self.level == 379 then--沅江鬼胡子
        weaveItem.weaveCard   = {cbCurCard,cbCurCard,cbCurCard}
    else
        weaveItem.weaveCard = {cbCurCard,0x00,0x00}
    end
    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard}
    local eventType = g_342.t_wai
    self:showWeaveCard(viewId, weaveItem, removeWeave)
end


return CardLayer1