-- CardLayer.lua
-- Author: zzy
-- Date: 2019-01-09 16:00:46
-- 各种牌的界面（玩家手牌、组合牌、已经打出去的牌、胡牌时摆下的牌）
local phzServer = import("chenzhouzp.handle.PHZSendHandle")
local GameLogic = require("chenzhouzp.logic.GameLogic")
local CardConfig = require("chenzhouzp.logic.CardConfig")
local CardSprite = require("chenzhouzp.models.CardSprite")

local scheduler = require("framework.scheduler")

local CardLayer = class("CardLayer", function()
    return display.newLayer()
end)

----------------------------
-----------固定值-----------
----------------------------

----------位置----------
--手牌标准位置   = cc.p(430,100)
local HCardX   = 220
local HCardY   = 100
------------------------

--------大小距离--------
--小字牌横间距   = 38  32
--小字牌竖间距   = 38
--手牌字牌横间距 = 72  97
--手牌字牌竖间距 = 68  90
--弃牌背景框长度 = 226
--进牌框摆牌高度 = 158
local MCardWid = 32
local MCardHei = 38
local HCardWid = 97
local HCardHei = 80
local QiBgWid  = 500
local JinBgHei = 158
------------------------

----------数量----------
local MaxCol = 10
local MaxRow = 4
------------------------

local winSize = cc.Director:getInstance():getWinSize()

function CardLayer:ctor()
    --print("------------CardLayer:ctor()------------")

    self:setContentSize(winSize.width,winSize.height)    --天杀的，这个游戏的框架，鬼知道自己创建的层为啥还有大小限制！！！

    self:initData()
    
    self.m_GameLogic = GameLogic:new()
    self.m_CardConfig = CardConfig:new()

    self:init()

    g_PHZMainScene:setRootSize(self)
end

function CardLayer:initData()
    --字牌数据
    self.m_DCardData = {}      --弃牌数据
    self.m_WeaveItem = {}      --进牌数据

    self.m_CardIndex = {}      --手牌数据
    self.m_colCount  = 0       --手牌列数
    self.m_firstColX = 0       --首列x坐标
    
    self.m_HCSprite = {}       --手牌字牌
    self.m_OutSprite = {}      --出牌字牌
    self.m_LiangTips = {}      --胡量计数

    self.m_LiangCard = nil     --亮张牌
    self.m_takeCard = nil      --拿起的牌
    self.m_selectedCard = nil  --选定打出去的牌

    self.m_CardNum = 0         --手牌数量

    self.m_myChairHuXi = 0          --自己桌面上的胡息
end

--还原手牌所有的数值
function CardLayer:getMyHandCardData()
    local tempArr = {}
    for k,v in pairs(self.m_CardIndex) do
        local cardValue = self.m_GameLogic:SwitchToCardData(k)
        for i=1,v do
            table.insert(tempArr,cardValue)
        end
    end
    return tempArr
end

--拍层清理数据
function CardLayer:clearData()
    self:removeAllChildren()
    self:initData()
    self:init()
end

function CardLayer:init()
    local CardNode = cc.CSLoader:createNode("chenzhouzp/res/PHZPlaceCardLayer.csb")
    self.CardNode = CardNode
    self:addChild(CardNode)

    self.m_JinBg = {}           --放置要的牌
    self.m_QiBg = {}            --放置不要的牌

    for i=0, GAME_PLAYER -1 do
        self.m_OutSprite[i] = CardNode:getChildByName("Card_"..i)
        self.m_OutSprite[i]:setVisible(false)
        self.m_OutSprite[i]:setScale(0.6)

        self.m_QiBg[i] = CardNode:getChildByName("qi_"..i)
        self.m_JinBg[i] = CardNode:getChildByName("Panel_"..i)

        self.m_LiangTips[i] = g_PHZMainLayer.m_txtHuxi[i+1]
        --self.m_LiangTips[i]:setString("胡息：0")
        self.m_DCardData[i] = {}  
        self.m_WeaveItem[i] = {}  
    end
end


function CardLayer:onEnter()
    --print("-------CardLayer:onEnter()------")
end

function CardLayer:onExit()
    --print("-------CardLayer:onExit()------")
    self:removeAllChildren()
end

--绘画弃牌
function CardLayer:drawQiCard( wViewId, cardData )
    --print("----CardLayer:drawQiCard()-----",wViewId, cardData)
    if not self.m_DCardData[wViewId] then
        self.m_DCardData[wViewId] = {}
    end
    local cardInfo = self.m_CardConfig:getCardInfoByid(cardData)
    if cardInfo then
        local x = MCardWid/2 + #self.m_DCardData[wViewId] * MCardWid
        local y = MCardWid/2
		
		--显示两排
		if #self.m_DCardData[wViewId] >= 10 then
			y = MCardWid/2 + MCardWid + 6
			x = MCardWid/2 + (#self.m_DCardData[wViewId]-10) * MCardWid
		end
		
        --if wViewId == 2 or wViewId == 0 then
		if wViewId == 0 or wViewId == 1 then
			x = QiBgWid - x
        end
        local imgPath = string.format("%s.png",cardInfo.CardIconA)
        local cardObj = display.newSprite()
        local frame = display.newSpriteFrame(imgPath)
        cardObj:setSpriteFrame(frame)
        cardObj:setPosition(x,y)
        self.m_QiBg[wViewId]:addChild(cardObj)
        table.insert(self.m_DCardData[wViewId],cardData)
    end
end

---------------------------------------------------------------------------------
----------------------------------数据处理函数-----------------------------------
---------------------------------------------------------------------------------
--获取补牌摆放位置
function CardLayer:getHandCardPutPos(wViewId)
    print("----------CardLayer:getHandCardPutPos()-------------")
    local x, y
    if wViewId == 0 then
        local row = self:getRowCountByCol(self.m_colCount)+1
        x, y = self:positionOfItem(row,self.m_colCount)
    else
        x, y = g_PHZMainLayer:getHeadPosByID(wViewId)
    end
    return x, y
end
--存放字牌
function CardLayer:pushCurCardList( target )
    table.insert( self.m_HCSprite,target )
end

--获取全部字牌
function CardLayer:getCurCardList()
    return self.m_HCSprite
end

--移除字牌
function CardLayer:popCurCardList( target )
    if target == self.m_takeCard then
        g_CardScene:setTakeUpCard()
    end
    for k,v in pairs(self.m_HCSprite) do
        if v == target then
            local row = v:getRow()
            local col = v:getCol()
            local index = v:getCardIndex()

            table.remove(self.m_HCSprite,k)
            local count = self:getColCardCount(col)
            if count == 0 then
                self.m_colCount = self.m_colCount - 1
                print("剩余手牌列数",self.m_colCount)
                self:reforCardColAfterRemove(col)
            end
            self:removeChild(target,true)
            self.m_CardIndex[index] = self.m_CardIndex[index] - 1
            break
        end
    end
end

--根据坐标获取字牌
function CardLayer:getCurCard( row, col )
    for k,v in pairs(self.m_HCSprite) do
        if v:getRow() == row and v:getCol() == col then
            return v
        end
    end
    return nil
end

--根据牌面获取字牌
function CardLayer:getCurCardByCardId( card )
    for k,v in pairs(self.m_HCSprite) do
        if v:getCardId() == card then
            return v
        end
    end
    return nil
end

--一列字牌数量
function CardLayer:getColCardCount( col )
    local count = 0
    for k,v in pairs(self.m_HCSprite) do
        if v:getCol() == col then
            count = count + 1
        end
    end
    return count
end

--更新胡量数标签
function CardLayer:setLiangTips( wViewId, count )
	--dump(self.m_LiangTips)
	print('setLiangTips ', count, wViewId)
    if count <= 0 then
        self.m_LiangTips[wViewId]:setString("胡息：0")
    else
        self.m_LiangTips[wViewId]:setString("胡息："..count)
    end

    if wViewId == 0 then
        self:setMyChairHuXi(count)
    end

end


function CardLayer:setMyChairHuXi(count)
   self.m_myChairHuXi = count or 0
end

function CardLayer:getMyChairHuXi()
    return  self.m_myChairHuXi
end

--显示出牌
function CardLayer:showOutCard(wViewId, cardData)
    for i=0,GAME_PLAYER-1 do
        self.m_OutSprite[i]:setVisible(false)  
    end
    local cardInfo = self.m_CardConfig:getCardInfoByid(cardData)
    if cardInfo then
        local imgPath = string.format("%s.png",cardInfo.CardIconC)
        local frame = display.newSpriteFrame(imgPath)
        self.m_OutSprite[wViewId]:setSpriteFrame(frame)
        self.m_OutSprite[wViewId]:setVisible(true)
    end
end

--更新胡量数
function CardLayer:hideOutCard( wViewId )
    self.m_OutSprite[wViewId]:setVisible(false)
end
---------------------------------------------------------------------------------
----------------------------------逻辑功能函数-----------------------------------
---------------------------------------------------------------------------------
--收起亮张牌
function CardLayer:putAwayLiangCard(wViewId, cbCard)
    print("----------CardLayer:putAwayLiangCard()-------------")
    self.m_OutSprite[wViewId]:setVisible(false)

    local x, y = self.m_OutSprite[wViewId]:getPosition()
    local ex, ey = self:getHandCardPutPos(wViewId)
    if wViewId ~= 0 then
        ex, ey = g_MainLayer:getHeadPosByID(wViewId)
    end
    local frame = self.m_OutSprite[wViewId]:getSpriteFrame()

    local tempCard = display.newSprite(frame, x, y)
    self:addChild(tempCard,20)

    local move = cc.MoveTo:create(0.2,cc.p(ex,ey))
    local func = cc.CallFunc:create(function( fc )
        fc:removeFromParent()
        self:showTips("庄家收起亮张牌")
        if wViewId == 0 then
            local liangIndex = self.m_GameLogic:SwitchToCardIndex(cbCard)
            --print(cbCard,"cbCard")
            --print(liangIndex,"liangIndex")
            -- dump(g_CardScene.m_WeaveItem[g_mainScene.m_wBankerUser])
            local tb = g_CardScene.m_WeaveItem[g_mainScene.m_wBankerUser]
            local needGetcard = true
            for k,v in pairs(tb) do
                if v.cbWeaveKind == 1 then
                    if v.cbCenterCard == cbCard then
                        needGetcard = false
                    end
                end
            end
            if needGetcard then
                self.m_CardIndex[liangIndex] = self.m_CardIndex[liangIndex]+1
                self:refreshCard()
            end
        end
    end)
    tempCard:runAction(cc.Sequence:create(move,func))
end

----------------------------------------------------------------------
----------------------------------------------------------------------
------------------------操作当前玩家的手牌----------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
function CardLayer:getCardNum()
    return self.m_CardNum
end


--设置自己当前牌
function CardLayer:setCurHandCard(cardData)
    g_CardScene.m_CardNum = #cardData
    print("---------CardLayer:setCurHandCard()----------")
    for k, v in pairs(self.m_HCSprite) do
        v:removeFromParent()
    end
    self.m_HCSprite = {}
    self.m_CardIndex = {}
    --相当于0-19 这20个位置来记录每一种牌的数量
    self.m_CardIndex = self.m_GameLogic:SwitchToCardIndexList(cardData)

    local WeaveArray,ArrayCount = self.m_GameLogic:getCurhandCard(cardData)
    self:drawCenterCard(WeaveArray,ArrayCount)
end

--绘画手牌
function CardLayer:drawCenterCard( WeaveArray, arrCount, darkCount )
    print("--------CardLayer:drawCenterCard()---------")
    local weaveCount = #WeaveArray
    for k, v in pairs(WeaveArray) do
        local cardCount = #v
        local isDark = false
        if cardCount >= 3 and v[1] == v[2] and v[1] == v[3] then
            isDark = true
        end
        for i, j in pairs(v) do
            local cardInfo = self.m_CardConfig:getCardInfoByid(j)
            if cardInfo then
                local cardObj = CardSprite.new(j,i,k)
                cardObj:setPosition(HCardX,HCardY)
                self:addChild(cardObj,4-i)
                -- local move1 = cc.MoveTo:create(0.02*(k-1),cc.p((k-1)*HCardWid+HCardX,HCardY))
                -- local move2 = cc.MoveTo:create(0.1*(i-1),cc.p((k-1)*HCardWid+HCardX,(i-1)*HCardHei+HCardY))
                local move1 = cc.MoveTo:create(0.1,cc.p((k-1)*HCardWid+HCardX,HCardY))
                local move2 = cc.MoveTo:create(0.1,cc.p((k-1)*HCardWid+HCardX,(i-1)*HCardHei+HCardY))
                if k == weaveCount and i == cardCount then
                    --到最后一张牌时，整理一次位置
                    local func = cc.CallFunc:create(function( fc )
                        self:fillVacancies()
                        --self:showTingCards()
                    end)
                    cardObj:runAction(cc.Sequence:create(move1,move2,func))
                else
                    cardObj:runAction(cc.Sequence:create(move1,move2))
                end
                if isDark then
                    cardObj:setCardCovered(true)
                end
                g_CardScene:pushCurCardList(cardObj)
            end
        end
    end

    self.m_colCount = arrCount
end

function CardLayer:removeCardByWeave(removeWeave)
    for k,v in pairs(removeWeave) do
        self:removeHandCardById(v)
    end
end

--移除字牌
function CardLayer:removeHandCardById( card )

    local index = self.m_GameLogic:SwitchToCardIndex(card)
    --print("--------CardLayer:removeHandCardById()---------",card,index)
    if self.m_CardIndex[index] > 0 then
        for k,v in pairs(self.m_HCSprite) do
            --dump(v:getCardId(),"removeHandCardByIdttt")
            if v:getCardId() == card then
                --dump(card,"removeHandCardById")
                g_CardScene:popCurCardList(v)
                break
            end
        end
    end
end

--移除字牌
function CardLayer:removeHandCardByCol( col )
    print("--------CardLayer:removeHandCardByRow()---------")
    for k,v in pairs(self,m_HCSprite) do
        if v:getCol() == col then
            g_CardScene:popCurCardList(v)
        end
    end
end

--删除某列后重整字牌列号
function CardLayer:reforCardColAfterRemove( removeCol )
    print("--------CardLayer:reforCardColAfterRemove()---------")
    for k,v in pairs(self.m_HCSprite) do
        local col = v:getCol()
        if col > removeCol then
            v:setCol(col-1)
        end
    end
end

--插入新列后重整字牌列号
function CardLayer:reforCardColAfterInsert( insertCol )
    --print("--------CardLayer:reforCardColAfterInsert()---------")
    for k,v in pairs(self.m_HCSprite) do
        local col = v:getCol()
        if col >= insertCol then
            v:setCol(col+1)
        end
    end
end

--对齐手牌位置
function CardLayer:fillVacancies()
    print("--------CardLayer:fillVacancies()---------")
    --悬空掉落
    for col = 1, self.m_colCount do
        local sprite = nil
        local emptyRow = 0
        for row = 1, MaxRow do
            sprite = self:getCurCard(row,col)
            if sprite == nil then
                emptyRow = emptyRow + 1
            else
                if emptyRow > 0 then
                    local newRow = row - emptyRow
                    sprite:setRow(newRow)
                end
            end
        end
    end
    --纵列对齐
    local exisCol = {}
    local reCol = {}
    for i=1,self.m_colCount do
        exisCol[i] = 0
    end
    for k,v in pairs(self.m_HCSprite) do
        local col = v:getCol()
        exisCol[col] = exisCol[col] + 1
    end
    for i=1,self.m_colCount do
        if exisCol[i] == 0 then
            table.insert(reCol,i)
        end
    end
    for k1,v1 in pairs(reCol) do
        self.m_colCount = self.m_colCount - 1
        for k2,v2 in pairs(self.m_HCSprite) do
            local col = v2:getCol()
            if col > v1 then
                v2:setCol(col-1)
            end
        end 
    end
    --位置对齐
    for k, v in pairs(self.m_HCSprite) do
        if v:getNumberOfRunningActions() > 0 then
            v:stopAllActions()
        end
        local row = v:getRow()
        local col = v:getCol()
        local x, y = self:positionOfItem(row,col)
        if x < 0 then
            --print("检查字牌坐标出错, x, y, row, col =",x, y, row, col)
        end
        v:runAction(cc.MoveTo:create(0.1,cc.p(x,y)))
    end
    --记录基准点X坐标
    local firX, firY = self:positionOfItem(1,1)
    self.m_firstColX = firX
end

--根据行列号获取位置
function CardLayer:positionOfItem( row, col )
    local px = HCardX + (MaxCol-self.m_colCount)*(HCardWid/2) + (col-1)*HCardWid
    local py = HCardY + (row-1)*HCardHei
    return px,py
end

--设置被拿起的牌
function CardLayer:setTakeUpCard(sprite)
    print("--------CardLayer:setTakeUpCard()---------")
    if sprite then
        print("setTakeUpCard() 拿起纸牌 : ",sprite:getCardId())
        for k,v in pairs(self.m_HCSprite) do
            -- 牌还没有整理好时不能拿起
            if v:getNumberOfRunningActions() > 0 then  --//获取当前精灵执行多少个动作
                print("牌还没有整理好时不能拿起")
                return
            end
        end
    end
    self.m_takeCard = sprite
end

--获取被拿起的牌
function CardLayer:getTakeUpCard()
    -- print("--------CardLayer:getTakeUpCard()---------")
    return self.m_takeCard
end

--设置刚刚打出去牌
function CardLayer:setSelectedCard( sprite )
    -- print("--------CardLayer:setSelectedCard()---------")
    self.m_selectedCard = sprite
end

--获取刚刚打出去牌
function CardLayer:getSelectedCard()
    return self.m_selectedCard
end

function CardLayer:moveBeginCard()
    if self.m_takeCard then
    end
end

--移动牌
function CardLayer:movingCard(x,y)
    if tolua.isnull(self.m_takeCard) == false then
        self.m_takeCard:setSpriteFrameBOrC("C")
        self.m_takeCard:setPosition(x,y)
        self.m_takeCard:setTingCardSize()
        if self.m_takeCard:getReorder() < 100 then
            self.m_takeCard:setMovingReorder()
        end
    else
        print("===不存在！！！===")
    end
end

function CardLayer:outCardYes()
    if tolua.isnull(self.m_takeCard) == false then
        local pos = self.m_takeCard:getPosition()
        local x,y = pos.x,pos.y
        self.m_takeCard:setTingCardSize()
        local card = self.m_takeCard:getCardId()
        g_PHZMainScene:onOutCard(card)
        self:popCurCardList(self.m_takeCard)
        local cardObj = CardSprite.new(card,0,0)
        cardObj:setPosition(x,y)
        self:addChild(cardObj,20)
        g_CardScene:setSelectedCard(cardObj)
        --出牌
        -- self:playerOutCard(1,6)
        g_PHZMainScene.m_bOutCard = false
        phzServer:CLI_PLAYER_OUT_CARD(card)
    end
    if tolua.isnull(self.m_takeCard) == false then
        self.m_takeCard:setTingCardSize()
    end
    self.m_takeCard = nil
    self:fillVacancies()
end
function CardLayer:backOutCard()
    if tolua.isnull(self.m_takeCard) == false then
        local pos = self.m_takeCard:getPosition()
        local x,y = pos.x,pos.y
        self.m_takeCard:setTingCardSize()
        self.m_takeCard:setSpriteFrameBOrC("B")
        local ret = self:checkRowAndColWithPosition(x,y)
        if ret.newCol and self.m_colCount >= MaxCol then
            local str = "最多只能排放"..MaxCol.."组字牌！"
            self:showTips(str)
        end
        if ret.newCol and self.m_colCount < MaxCol then
            --新增加列
            self.m_colCount = self.m_colCount + 1

            for k,v in pairs(self.m_HCSprite) do
                if v:getCol() >= ret.newCol then
                    v:setCol(v:getCol()+1)
                end
            end
            self.m_takeCard:setRow(1)
            self.m_takeCard:setCol(ret.newCol)

        elseif ret.col then
            --字牌换到已存在列
            if ret.row <= MaxRow then
                self.m_takeCard:setRow(ret.row)
                self.m_takeCard:setCol(ret.col)
            else
                --同一列的不需
                if oldCol ~= ret.col then
                    local str = "每列最多只能叠放"..MaxRow.."张字牌！"
                    self:showTips(str)
                end
            end
        end
        self.m_takeCard:registerReorder()
    end
    if tolua.isnull(self.m_takeCard) == false then
        self.m_takeCard:setTingCardSize()
    end
    self.m_takeCard = nil
    self:fillVacancies()
end
--移动结束
function CardLayer:moveCardEnd()
    print("--------CardLayer:moveCardEnd()---------")
    if tolua.isnull(self.m_takeCard) == false then
        local pos = self.m_takeCard:getPosition()
        local x,y = pos.x,pos.y
        --print("===g_PHZMainScene.m_bOutCard==",g_PHZMainScene.m_bOutCard)
        if g_PHZMainScene:ableOutCard() and self:isTopOutCardLine(x,y) then
            local card = self.m_takeCard:getCardId()

            phzServer:CLI_CHECK_WEI(card)
        else
            self:backOutCard();
        end

    end
end

--根据坐标检查可使用行列号
function CardLayer:checkRowAndColWithPosition( x, y )
    print("--------CardLayer:checkRowAndColWithPosition()---------")
    local ret = {}
    --判断col, 新行row为1
    local col = math.floor((x-self.m_firstColX+25) / HCardWid) + 1
    local range = (x-self.m_firstColX+25) % HCardWid
    if range > 50 then
        col = col + 1
    end

    --print("col = "..col)
    --print("range = "..range)

    if x < self.m_firstColX-25 then
        print("左边新加一列")
        ret["newCol"] = 1
        ret["row"] = 1

    elseif x > self.m_firstColX+(self.m_colCount-1)*HCardWid+25 then
        print("右边新加一列")
        ret["newCol"] = self.m_colCount + 1
        ret["row"] = 1

    elseif range > 50 then
        print("中间插入一列")
        ret["newCol"] = col
        ret["row"] = 1
    else
        print("叠在已有列最上")
        ret["col"] = col
        ret["row"] = self:getRowCountByCol(col) + 1
    end
    return ret
end

--获取某一列字牌的个数
function CardLayer:getRowCountByCol( col )
    local count = 0
    for k,v in pairs(self.m_HCSprite) do
        if v:getCol() == col then
            count = count + 1
        end
    end
    return count
end

--判断点是否在出牌区
function CardLayer:isTopOutCardLine( x, y )
    if y >= OUT_CARD_LINE then
        return true
    end
    return false
end

function CardLayer:setChiCardWeave()
    local curCard = g_PHZMainScene:getCurrentCard()
    if curCard and curCard ~= 0 then
        local tempIndex = clone(self.m_CardIndex)
        g_PHZMainScene:showChiCardLayer(tempIndex,curCard)
    end
end

function CardLayer:openLockCard()
    --print("CardLayer:openLockCard()")
    for k, v in pairs(self.m_HCSprite) do
        v:setCardLock(false)
    end
end

--获取当前手牌
function CardLayer:getSelfHandCard()
    dump(self.m_CardIndex)
    --print("curCard count =",#self.m_HCSprite)
    --for k, v in pairs(self.m_HCSprite) do
        --print("cardid, row, col =",v:getCardId(),v:getRow(),v:getCol())
    --end
    return self.m_CardIndex
end

--更新胡息
function CardLayer:updateHuXiCount(wViewId)
    -- print("更新胡息",wViewId)
 
    
    local huXiCount = 0
    for k,v in pairs(self.m_WeaveItem[wViewId]) do
        dump(v)
        local huxi = self.m_GameLogic:GetWeaveHuXi(v)
        if wViewId == 0 then
            dump(v)
            --print("===huxi===",huxi)
        end
        
        if v.cbWeaveKind == AK_SAO and g_PHZMainScene.bRoomTypeYWS == 1 then
            huxi = 0
        end
        huXiCount = huXiCount + huxi
    end
    self:setLiangTips(wViewId,huXiCount)
end

----------------------------------------------------------------------
----------------------------------------------------------------------
------------------------操作全部玩家的字牌----------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
function CardLayer:getMoveToPosXDistance(wViewId)
    if wViewId < 0 then return 0 end
    local tempDistance = 0
    -- if wViewId ~= 2 then
        -- tempDistance = 200
    -- else
        -- tempDistance = -200
    -- end
	tempDistance = 200
    return tempDistance
end


--组合扑克（达成组合并展示出来的牌） weaveItem.weaveCard
function CardLayer:showWeaveCard( wViewId, weaveItem, removeWeave )
    print("CardLayer:showWeaveCard()", wViewId )
    dump(removeWeave,"---removeWeave")
    dump(weaveItem,"---weaveItem")
    local tempCbCenterCard = weaveItem.cbCenterCard
    local tempCbWeaveKind = weaveItem.cbWeaveKind
    local tempCbCount = weaveItem.cbCardCount

    ----AK_DUO == 4
    local addIndex = #self.m_WeaveItem[wViewId] + 1
    local isWeiChanged = false
    for k,v in pairs(self.m_WeaveItem[wViewId]) do
        if tempCbCount == 4 and tempCbCenterCard == v.cbCenterCard and  (tempCbWeaveKind == AK_DUO or tempCbWeaveKind == AK_SAO_EX) then
            table.remove(self.m_WeaveItem[wViewId],k)
            isWeiChanged = true
            addIndex = k
            break
        end  
    end

    -- dump(self.m_WeaveItem[wViewId])

    -- --插入新数据，删除旧字牌
    table.insert(self.m_WeaveItem[wViewId],addIndex,weaveItem)
    self.m_JinBg[wViewId]:removeAllChildren()

    for k,v in pairs(self.m_WeaveItem[wViewId]) do
        for k1,v1 in pairs(v.weaveCard) do
            local x = MCardWid/2 + (k-1)*MCardWid
           
		    if wViewId == 1 then  --当为右边的玩家时，位置微调
                local tempSize = self.m_JinBg[wViewId]:getContentSize().width
                x = tempSize - MCardWid/2 - (k-1)*MCardWid
            end
			
            local y = MCardWid/2 + (k1-1)*MCardWid

            local imgPath = "chenzhouzp/res/CardLitter/Card_miniature_000.png"
            local cardInfo = self.m_CardConfig:getCardInfoByid(v1)
            if cardInfo then
                imgPath = string.format("%s.png",cardInfo.CardIconA)
            end
            local cardObj = display.newSprite()
            local frame = display.newSpriteFrame(imgPath)
            cardObj:setSpriteFrame(frame)
            cardObj:setPosition(x,y)
			print('--showWeaveCard--setPosition--',wViewId,x,y,k,k1,isWeiChanged,addIndex)

            if v.showChi == true and k1 == 3 then
                cardObj:setColor(cc.c3b(175,175,175))
            end

            if v.isBi == true and k1 > (3 - v.biCardNumber) then
                cardObj:setColor(cc.c3b(175,175,175))
            end

            if k == addIndex then
                self:CardMove(cardObj,wViewId,isWeiChanged)
            end

            self.m_JinBg[wViewId]:addChild(cardObj,10-k1)
        end
    end
    dump(wViewId,"wViewId删除手牌")
    if wViewId == 0 then
        print("删除手牌")
        self:removeCardByWeave(removeWeave)
        self:fillVacancies()
    end
    print("组合出的牌")
    self:updateHuXiCount(wViewId)
end

function CardLayer:CardMove(node,wViewId,isWeiChanged)
    node:stopAllActions()
    local tempX = self:getMoveToPosXDistance(wViewId)
    local MOVE_BY_1 = cc.MoveBy:create(0.2,cc.p(tempX,0))
    local delay = cc.DelayTime:create(0.1)
    local MOVE_BY_2 = cc.MoveBy:create(0.2,cc.p(-tempX,0))
    if isWeiChanged then
        node:runAction(cc.Sequence:create(MOVE_BY_1,delay,MOVE_BY_2))
    else
        local posx = node:getPosition().x
        node:setPositionX(posx+tempX)
        node:runAction(cc.Sequence:create(delay,MOVE_BY_2))
    end    
end

--还原组合扑克
function CardLayer:restoreWeaveCard(wViewId)

    self.m_JinBg[wViewId]:removeAllChildren()

    for k,v in pairs(self.m_WeaveItem[wViewId]) do
        for k1,v1 in pairs(v.weaveCard) do
            local x = MCardWid/2 + (k-1)*MCardWid
            if wViewId == 1 then  --当为右边的玩家时，位置微调
                local tempSize = self.m_JinBg[wViewId]:getContentSize().width
                x = tempSize - MCardWid/2 - (k-1)*MCardWid
            end
            -- local y = JinBgHei - MCardWid/2 - (k1-1)*MCardWid
            local y = MCardWid/2 + (k1-1)*MCardWid
            local imgPath = "chenzhouzp/res/CardLitter/Card_miniature_000.png"
            local cardInfo = self.m_CardConfig:getCardInfoByid(v1)
            if cardInfo then
                imgPath = string.format("%s.png",cardInfo.CardIconA)
            end
            local cardObj = display.newSprite()
            local frame = display.newSpriteFrame(imgPath)
            cardObj:setSpriteFrame(frame)
            cardObj:setPosition(x,y)

            if v.showChi == true and k1 == 3 then
                cardObj:setColor(cc.c3b(175,175,175))
            end

             if v.isBi == true and k1 > (3-v.biCardNumber) then
                cardObj:setColor(cc.c3b(175,175,175))
            end

            self.m_JinBg[wViewId]:addChild(cardObj,10-k1)
        end
    end

    self:updateHuXiCount(wViewId)
end

--出牌
function CardLayer:playerOutCard(wViewId, cardData)
    local cardInfo = self.m_CardConfig:getCardInfoByid(cardData)
	print("---------CardLayer:playerOutCard()--------",wViewId, cardData,cardInfo)
    if cardInfo then
        local x,y = g_PHZMainLayer:getHeadPosByID(wViewId)
        if wViewId == 0 then
            x,y = self:getSelectedCardPos(cardData)
        end
        local ex,ey = self.m_OutSprite[wViewId]:getPosition().x,self.m_OutSprite[wViewId]:getPosition().y
        local imgPath1 = string.format("%s.png",cardInfo.CardIconC)
        local tempCard = display.newSprite()
        local frame = display.newSpriteFrame(imgPath1)
        tempCard:setSpriteFrame(frame)
        tempCard:setPosition(x,y)
        self:addChild(tempCard,20)
        --动作：从头像移动到出牌区，显示出牌
        -- tempCard:setPosition(cc.p(ex,ey))
        -- local imgPath = string.format("%s.png",cardInfo.CardIconC)
        -- local frame = display.newSpriteFrame(imgPath)
        -- self.m_OutSprite[wViewId]:setSpriteFrame(frame)
        -- print("======66666666666666666666=====")
        -- print("======66666666666666666666=====")
        -- print("======66666666666666666666=====")
        -- print("======66666666666666666666==cardData===")
        -- self.m_OutSprite[wViewId]:setVisible(true)
        -- self:fillVacancies()
        -- -- fc:removeFromParent()

        local move = cc.MoveTo:create(0.2,cc.p(ex,ey))
        local func = cc.CallFunc:create(function( fc )
            local imgPath = string.format("%s.png",cardInfo.CardIconC)
            local frame = display.newSpriteFrame(imgPath)
            self.m_OutSprite[wViewId]:setSpriteFrame(frame)
            print("==玩家出牌，显示牌的纹理==")
            self.m_OutSprite[wViewId]:setVisible(true)
            self:fillVacancies()
            fc:removeFromParent()
            -- self:showTingCards()
        end)
        tempCard:runAction(cc.Sequence:create(move,func))
    end
end

--获取选定出牌的位置
function CardLayer:getSelectedCardPos( cardData )
    --print("------CardLayer:getSelectedCardPos------")
    local x,y
    if self.m_selectedCard then
        self.m_selectedCard:setTag(999)
        x,y = self.m_selectedCard:getPosition().x,self.m_selectedCard:getPosition().y
        self:popCurCardList(self.m_selectedCard)
        local card = self:getChildByTag(999)
        if card then
            card:removeFromParent()
        end
        self.m_selectedCard = nil
    else
        local selectedCard = self:getCurCardByCardId(cardData)
        if selectedCard then
            x,y = selectedCard:getPosition().x,selectedCard:getPosition().y
            self:popCurCardList(selectedCard)
        end
    end
    if x==nil or y==nil then
        return g_PHZMainLayer:getHeadPosByID(1)
    end
    return x, y
end

--派发单牌
function CardLayer:sendCard(wViewId, cardData, bshow)
    --print("==发送新的单张==",cardData)
    --print("---------CardLayer:sendCard()--------",wViewId, cardData)
    local cardInfo = self.m_CardConfig:getCardInfoByid(cardData)
    if cardInfo and self.m_OutSprite[wViewId] then
        local x, y = g_PHZMainLayer:getSendCardPos()
        local ex,ey = self.m_OutSprite[wViewId]:getPosition()
        
        local imgPath = string.format("#%s.png",cardInfo.CardIconC)
        if bshow == 0 then
            imgPath = "#hc_card_back_C.png"
        end
        local tempCard = display.newSprite(imgPath)
        tempCard:setPosition(x,y)
        tempCard:setScale(0.6)
        self:addChild(tempCard,20)

        --动作：从底牌位置移动到出牌区，显示出牌
        local move = cc.MoveTo:create(0.2,cc.p(ex,ey))
        local func = cc.CallFunc:create(function( fc )
            local framePath = string.format("%s.png",cardInfo.CardIconC)
            if bshow == 0 then
                framePath = "hc_card_back_C.png"
            end
            local frame = display.newSpriteFrame(framePath)
            self.m_OutSprite[wViewId]:setSpriteFrame(frame)
            self.m_OutSprite[wViewId]:setVisible(true)
            tempCard:removeFromParent()
            -- self:showTingCards()
        end)
        tempCard:runAction(cc.Sequence:create(move,func))
    end
end

--补牌
function CardLayer:supplyCard(wViewId, cbBuCard,cardFrom)
    print("----------CardLayer:supplyCard()-------------",wViewId)
    local x, y = g_PHZMainLayer:getSendCardPos()
    local ex, ey = g_PHZMainLayer:getHeadPosByID(wViewId)
    local imgPath = "chenzhouzp/res/CardBig/Card_Big_000.png"
    local cardInfo = self.m_CardConfig:getCardInfoByid(cbBuCard)
    if cardInfo and cardFrom ~= 1 then
        imgPath = string.format("%s.png",cardInfo.CardIconC)
    end

    if wViewId == 0 then
        ex,ey = winSize.width/2,-50
    end
    if wViewId == 0 then
        local cbIndex = self.m_GameLogic:SwitchToCardIndex(cbBuCard)
        print("----------CardLayer:cbIndex()-------------",cbIndex)
        self.m_CardIndex[cbIndex] = self.m_CardIndex[cbIndex]+1
        self:refreshCard()
    end
    local tempPosX,tempPosY = self.m_OutSprite[wViewId]:getPosition()

    self.buCardNode = display.newSprite()
    local frame = display.newSpriteFrame(imgPath)
    self.buCardNode:setSpriteFrame(frame)
    self.buCardNode:setPosition(winSize.width/2,winSize.height)
    self:addChild(self.buCardNode,20) 
    self.buCardNode:setScale(0.8)
    self.buCardNode.cbBuCard = cbBuCard
    -- local move1 = cc.MoveTo:create(0.2,cc.p(x,y*0.8))
    local move1 = cc.MoveTo:create(0.3,cc.p(tempPosX,tempPosY))
    local delay = cc.DelayTime:create(0.5)
    local move = cc.MoveTo:create(0.5,cc.p(ex,ey))
    local scale = cc.ScaleTo:create(0.3,0.2)
    local sqawn = cc.Spawn:create(move,scale)
    local func = cc.CallFunc:create(function( fc )
        if wViewId == 0 then
            --local cbIndex = self.m_GameLogic:SwitchToCardIndex(cbBuCard)
            --self.m_CardIndex[cbIndex] = self.m_CardIndex[cbIndex]+1
            -- self:showTips("起手有多个扫牌，补字牌1张")

        end
        fc:removeFromParent()
        if fc == self.buCardNode then
            self.buCardNode = nil
        end
    end)
    self.buCardNode:runAction(cc.Sequence:create(move1,delay,sqawn,func))
end
function CardLayer:removeBuCardNode( ti_card )
    if self.buCardNode and self.buCardNode.cbBuCard == ti_card then
        self.buCardNode:stopAllActions()
        self.buCardNode:removeFromParent()
        self.buCardNode = nil
    end
end
--刷新字牌
function CardLayer:refreshCard()
    print("----------CardLayer:refreshCard()-------------")
    local cbCardData = self.m_GameLogic:SwitchToCardDataList(self.m_CardIndex)
    self:setCurHandCard(cbCardData)
end

--操作出牌 wChairId操作玩家, cbOutUser出牌玩家
function CardLayer:onEventCard( wViewId, wResViewId )
    print("CardLayer:onEventCard()",wViewId, wResViewId)

    if not self.m_OutSprite[wResViewId]:isVisible() then return end

    local x, y = self.m_OutSprite[wResViewId]:getPosition().x,self.m_OutSprite[wResViewId]:getPosition().y
    self.m_OutSprite[wResViewId]:setVisible(false)
    
    local ex, ey = self.m_JinBg[wViewId]:getPosition().x,self.m_JinBg[wViewId]:getPosition().y
    if wViewId == 2 then
        ey = ey - (MCardWid/2 + #self.m_WeaveItem[wViewId] * MCardWid)
    else
        ey = ey + (MCardWid/2 + #self.m_WeaveItem[wViewId] * MCardWid)
    end

    local cardInfo = self.m_CardConfig:getCardInfoByid(cbCurCard)
    if cardInfo then
        local frame = self.m_OutSprite[wResViewId]:getSpriteFrame()
        local tempCard = display.newSprite(frame)
        tempCard:setPosition(x,y)
        self:addChild(tempCard,20)
        
        local move = cc.MoveTo:create(0.2,cc.p(ex,ey))
        local func = cc.CallFunc:create(function( fc )
            fc:removeFromParent()
        end)
        tempCard:runAction(cc.Sequence:create(move,func))
    end
end
--m_WeaveItem
--跑四张全部盖底（） wChairId操作玩家, cbCurCard操作的牌
function CardLayer:onSaoExCard( wViewId, cbCurCard, removeCount,isPao)
    print("CardLayer:onSaoExCard()",wViewId, cbCurCard,removeCount)
    --扫穿数据
    local weaveItem = {}
    weaveItem.cbWeaveKind  = AK_SAO_EX
    if isPao then
       weaveItem.cbWeaveKind  = AK_DUO 
    end
    weaveItem.cbCardCount  = 4
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    -- if wViewId == 0 then
    --     weaveItem.weaveCard = {cbCurCard,0x00,0x00,0x00}
    -- else
    --     weaveItem.weaveCard = {0x00,0x00,0x00,0x00}
    -- end
    weaveItem.weaveCard = {cbCurCard,0x00,0x00,0x00}

    if isPao then
         weaveItem.weaveCard = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    end

    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    if removeCount==0 then
        weaveItem = {}
        removeWeave = {}
        for i=1, #self.m_WeaveItem[wViewId] do
            local cbWeaveKind = self.m_WeaveItem[wViewId][i].cbWeaveKind
            local cbListCard = self.m_WeaveItem[wViewId][i].cbCardList[1]
            if cbListCard==cbCurCard and (cbWeaveKind==AK_SAO or cbWeaveKind==AK_PENG) then
                self.m_WeaveItem[wViewId][i].cbWeaveKind  = AK_SAO_EX
                self.m_WeaveItem[wViewId][i].cbCardCount  = 4
                self.m_WeaveItem[wViewId][i].cbCenterCard = cbCurCard
                self.m_WeaveItem[wViewId][i].cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
                if isPao then
                    self.m_WeaveItem[wViewId][i].weaveCard = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
                else
                    self.m_WeaveItem[wViewId][i].weaveCard = {cbCurCard,0x00,0x00,0x00}
                end
            end
        end
    end

    self:showWeaveCard(wViewId, weaveItem, removeWeave)
    
end

--畏 wChairId操作玩家, cbCurCard操作的牌
function CardLayer:onSaoCard( wViewId, cbCurCard, saoType )
    print("CardLayer:onSaoCard()",wViewId, cbCurCard, saoType)

    --碰牌数据
    -- local weaveItem  = {}
    -- weaveItem.cbWeaveKind  = AK_PENG
    -- weaveItem.cbCardCount  = 3
    -- weaveItem.cbCenterCard = cbCurCard
    -- weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard}
    -- weaveItem.weaveCard    = {cbCurCard,cbCurCard,cbCurCard}

    -- --删除手牌数据
    -- local removeWeave = {cbCurCard,cbCurCard}

    -- self:showWeaveCard(wViewId, weaveItem, removeWeave)


    --扫牌数据
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = AK_SAO
    weaveItem.cbCardCount  = 3
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard}
    weaveItem.weaveCard = {cbCurCard,0x00,0x00}
    if wViewId == 0 then
        weaveItem.weaveCard = {cbCurCard,0x00,0x00}
    --else
    --    if saoType==1 then
    --        weaveItem.weaveCard = {0x00,0x00,0x00}
    --    end
    end

    --if saoType == 1 then
    --    g_PHZMainScene.m_diCardCount = g_PHZMainScene.m_diCardCount - 1
    --    g_PHZMainLayer.PHZUpNode:setDicardNum(g_PHZMainScene.m_diCardCount)
    --end
    

    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard}

    local eventType = AK_SAO
    -- if saoType==1 then eventType=AK_SAO_BAD end
    self:showWeaveCard(wViewId, weaveItem, removeWeave)
    -- g_EventLayer:showEventTips(wViewId, eventType)
end

--开舵 wChairId操作玩家, cbCurCard操作的牌
function CardLayer:onKaiDuo( wViewId, cbCurCard, removeCount )
    print("CardLayer:onKaiDuo()",wViewId, cbCurCard, removeCount)
    --开舵数据
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = AK_DUO
    weaveItem.cbCardCount  = 4
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
    weaveItem.weaveCard    = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}

    --删除手牌数据
    local removeWeave = {}
    if removeCount==3 then
        removeWeave = {cbCurCard,cbCurCard,cbCurCard}
    elseif removeCount==0 then
        weaveItem = nil
        for i=1, #self.m_WeaveItem[wViewId] do
            local cbWeaveKind = self.m_WeaveItem[wViewId][i].cbWeaveKind
            local cbListCard = self.m_WeaveItem[wViewId][i].cbCardList[1]
            if cbListCard==cbCurCard and (cbWeaveKind==AK_SAO or cbWeaveKind==AK_PENG) then
                self.m_WeaveItem[wViewId][i].cbWeaveKind  = AK_DUO
                self.m_WeaveItem[wViewId][i].cbCardCount  = 4
                self.m_WeaveItem[wViewId][i].cbCenterCard = cbCurCard
                self.m_WeaveItem[wViewId][i].cbCardList   = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
                self.m_WeaveItem[wViewId][i].weaveCard    = {cbCurCard,cbCurCard,cbCurCard,cbCurCard}
            end
        end
    end

    self:showWeaveCard(wViewId, weaveItem, removeWeave)
    -- g_EventLayer:showEventTips(wViewId, AK_DUO)
end

--碰牌 wChairId操作玩家, cbCurCard操作的牌
function CardLayer:onPengCard( wViewId, cbCurCard )
    print("CardLayer:onPengCard()",wViewId, cbCurCard)
    --碰牌数据
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = AK_PENG
    weaveItem.cbCardCount  = 3
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard,cbCurCard}
    weaveItem.weaveCard    = {cbCurCard,cbCurCard,cbCurCard}

    --删除手牌数据
    local removeWeave = {cbCurCard,cbCurCard}

    self:showWeaveCard(wViewId, weaveItem, removeWeave)
    -- g_EventLayer:showEventTips(wViewId, AK_PENG)
end

--对牌
function CardLayer:onDuiCard( wViewId, cbCurCard )
    print("CardLayer:onPengCard()",wViewId, cbCurCard)
    --碰牌数据
    local weaveItem  = {}
    weaveItem.cbWeaveKind  = AK_NULL
    weaveItem.cbCardCount  = 2
    weaveItem.cbCenterCard = cbCurCard
    weaveItem.cbCardList   = {cbCurCard,cbCurCard}
    weaveItem.weaveCard    = {cbCurCard,cbCurCard}

    --删除手牌数据
    local removeWeave = {cbCurCard}

    self:showWeaveCard(wViewId, weaveItem, removeWeave)
    -- g_EventLayer:showEventTips(wViewId, AK_PENG)
end

function CardLayer:onChiCard(wViewId,cardData)
    local chiWeaveItem  = {}
    chiWeaveItem.cbWeaveKind  = AK_CHI
    chiWeaveItem.cbCardCount  = 3
    chiWeaveItem.cbCenterCard = cardData[1]
    chiWeaveItem.cbCardList   = {cardData[3],cardData[2],cardData[1]}
    chiWeaveItem.weaveCard    = {cardData[3],cardData[2],cardData[1]}
    --增加吃的牌做阴影
    chiWeaveItem.showChi      = true

    --删除手牌数据
    local removeWeave = {cardData[2],cardData[3]}
    self:showWeaveCard(wViewId, chiWeaveItem, removeWeave)

end

function CardLayer:onBiCard(wViewId,cardData,biCardValue)

    local arrNum = #cardData/3

    for i=1,arrNum do
        local tempIndex = (i-1)*3
        local chiWeaveItem  = {}
        chiWeaveItem.cbWeaveKind  = AK_CHI
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
        self:showWeaveCard(wViewId, chiWeaveItem, removeWeave)
    end
end

--得到一个数组中比牌相同的个数
function CardLayer:getBiCardValueNumber(arr,biCardValue)
    local tempBiCount = 0

    for k,v in pairs(arr) do
        if v == biCardValue then
            tempBiCount = tempBiCount + 1
        end
    end

    return tempBiCount
end

function CardLayer:sortBiCardList(arr,biCardValue)
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

--吃牌 wChairId操作玩家, curCard操作的牌, cardData吃牌组合 count组合数
function CardLayer:onChiCard2( wViewId, curCard, cardData, count )
    print("------CardLayer:onChiCard()-------")
    --操作扑克
    local chiWeave = cardData[1]
    local biWeave = cardData[2]

    local chiWeaveItem  = {}
    chiWeaveItem.cbWeaveKind  = AK_CHI
    chiWeaveItem.cbCardCount  = 3
    chiWeaveItem.cbCenterCard = cbCurCard
    chiWeaveItem.cbCardList   = {chiWeave[1],chiWeave[2],chiWeave[3]}
    chiWeaveItem.weaveCard    = {chiWeave[1],chiWeave[2],chiWeave[3]}

    local chiRemove = {}
    local isRemove = false
    for k,v in pairs(chiWeave) do
        if v == curCard and isRemove == false then
            isRemove = true
        else
            table.insert(chiRemove,v)
        end
    end
    local biRemove = clone(biWeave)

    self:showWeaveCard(wViewId, chiWeaveItem, chiRemove)
    if count > 1 then
        local biWeaveItem  = {}
        biWeaveItem.cbWeaveKind  = AK_CHI
        biWeaveItem.cbCardCount  = 3
        biWeaveItem.cbCenterCard = cbCurCard
        biWeaveItem.cbCardList   = {biWeave[1],biWeave[2],biWeave[3]}
        biWeaveItem.weaveCard    = {biWeave[1],biWeave[2],biWeave[3]}
        self:showWeaveCard(wViewId, biWeaveItem, biRemove)
    end
    -- g_EventLayer:showEventTips(wViewId, AK_CHI)
end

--玩家弃牌
function CardLayer:onDiscardCard( wViewId, curCard )
    print("===玩家弃牌  666666666666===",wViewId)

    local x, y = self.m_OutSprite[wViewId]:getPosition().x,self.m_OutSprite[wViewId]:getPosition().y
    local ex, ey = self.m_QiBg[wViewId]:getPosition().x,self.m_QiBg[wViewId]:getPosition().y
    -- if wViewId == 0 or wViewId == 1 then
        -- -- ey = ey - (MCardWid/2 + #self.m_DCardData[wViewId] * MCardWid)
        -- local tempSize = self.m_QiBg[wViewId]:getContentSize()
        -- ex = ex + tempSize.width - 
        -- ey = ey
    -- else
        -- ey = ey + (MCardWid/2 + #self.m_DCardData[wViewId] * MCardWid)
    -- end
	
	--得到出牌的位置
	local cardx = MCardWid/2 + #self.m_DCardData[wViewId] * MCardWid
    local cardy = MCardWid/2
	--显示两排
	if #self.m_DCardData[wViewId] >= 10 then
		cardy = MCardWid/2 + MCardWid + 6
		cardx = MCardWid/2 + (#self.m_DCardData[wViewId]-10) * MCardWid
	end
	if wViewId == 0 or wViewId == 1 then
		cardx = QiBgWid - cardx
    end
	ex = ex + cardx
	ey = ey + cardy
		

    -- if wViewId == 0 then
        -- ex,ey = 1280,40
    -- elseif wViewId == 1 then
        -- ex,ey = 50,350
    -- elseif wViewId == 2 then
        -- ex,ey = 1280,350
    -- end
	

    self.m_OutSprite[wViewId]:setVisible(false)

    local cardInfo = self.m_CardConfig:getCardInfoByid(curCard)
    if cardInfo then
        local imgPath = string.format("%s.png",cardInfo.CardIconC)
        local tempCard = display.newSprite()
        local frame = display.newSpriteFrame(imgPath)
        tempCard:setSpriteFrame(frame)
        tempCard:setPosition(x,y)
        self:addChild(tempCard,20)
        local move = cc.MoveTo:create(0.2,cc.p(ex,ey))
        local scale = cc.ScaleTo:create(0.2,0.1)
        local Spawn = cc.Spawn:create(move,scale)
        local func = cc.CallFunc:create(function( fc )
            self:drawQiCard(wViewId,curCard)
            tempCard:removeFromParent()
        end)
        tempCard:runAction(cc.Sequence:create(Spawn,func))
    end
end

----------------------------------------------------------------------
------------------------------辅助函数--------------------------------2218208826
----------------------------------------------------------------------
--字牌操作提示
function CardLayer:showTips( str )
    -- print("--------CardLayer:showTips()---------")
    print(str)
    local tipBg = display.newScale9Sprite("phz_bg2.png")
    tipBg:setContentSize(display.size.width,30)
    tipBg:setPosition(winSize.width/2,winSize.height*0.75)
    self:addChild(tipBg,1000)

    local tipslabel = display.newTTFLabel({
        text = str,
        font = "fonts/FZY3JW.ttf",
        size = 40,
        color = cc.c3b(220, 255, 0),
        align = cc.TEXT_ALIGNMENT_CENTER
    })
    tipslabel:setPosition(tipBg:getContentSize().width/2, tipBg:getContentSize().height/2)
    tipBg:addChild(tipslabel)

    local onRemove = cc.CallFunc:create(function ( fc ) fc:removeFromParent() end)
    local seq = cc.Sequence:create(cc.DelayTime:create(2),onRemove)
    tipBg:runAction(seq)

    tipBg:runAction(cc.MoveTo:create(1.5,cc.p(winSize.width/2,winSize.height*0.75+50)))
end


function CardLayer:setOtherHandCard(WeaveItemArray)
    dump(WeaveItemArray)
    for i=0,GAME_PLAYER-1 do
        local index = g_PHZMainScene:getViewChairId(i)
        print("ChairId:"..i)
        print("wViewId:"..index)
        if index ~= 0 then
            self.m_OutSprite[index]:setVisible(false)
            local arrBegan, arrEnd = i*MAX_WEAVE+1, (i+1)*MAX_WEAVE
            local handPnl = self.CardNode:getChildByName("hand_"..index)
            handPnl:removeAllChildren()
            local handCards = {}
            for i=arrBegan, arrEnd do
                local cardList = WeaveItemArray[i]
                if cardList.cbWeaveType == 1 then
                    table.insert(handCards, cardList)
                end
            end
            for k,v in pairs(handCards) do
                for k1,v1 in pairs(v.cbCardList) do
                    if v1 ~= 0 then
                        local cardInfo = CardInfos.getCardInfoByid(v1)      
                        local imgPath = string.format("#%s.png",cardInfo.CardIconA)
                        local cardObj = display.newSprite(imgPath)
                        cardObj:setPosition(k*40 ,(5-k1)*38)
                        handPnl:addChild(cardObj)
                    end
                end
            end
        end
    end  
end

function CardLayer:removeOtherHandCard()
    local handPnl = self.CardNode:getChildByName("hand_1")
    handPnl:removeAllChildren()
    handPnl = self.CardNode:getChildByName("hand_2")
    handPnl:removeAllChildren() 
end

return CardLayer
