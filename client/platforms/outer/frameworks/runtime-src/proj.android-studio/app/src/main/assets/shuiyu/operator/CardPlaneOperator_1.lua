local CardPlaneOperator = class("CardPlaneOperator")
local Card = require(TpackageName .. ".PokerCard")
local cardLogic = require(TpackageName .. ".cardLogic")

local All_Card_Nodes = {}

local MyCardScale = 0.75
local MyOutCardScale = MyCardScale
local OtherCardScale = 0.355

local MyCardY = 0  --手牌的高度

local MyOutCardY = 150  --出牌的高度

local OtherCardY = 0  --手牌的高度
local OtherOutCardY = 0  --其他人出牌的高度

local MyHandCardInterval
local MyOutCardInterval
local OtherCardInterval
local MyOutCardOffsetY

local SendCardTime = 0.05

-- 1表示左侧对齐， 2表示中间对齐， 3表示右对齐
local PlayersLocationTable  = {}
----------------------------------------------------------------------

function CardPlaneOperator:init(playerType,plane)

    if  TOTAL_PLAYERNUM == 6 then
        OtherCardScale = 0.6 
    elseif  TOTAL_PLAYERNUM == 8 then
        OtherCardScale = 0.455
    else
        OtherCardScale = 0.4
    end

    MyHandCardInterval = 240 *  MyCardScale
    MyOutCardInterval =  240 * MyOutCardScale
    OtherCardInterval =  90 * OtherCardScale
    MyOutCardOffsetY = 100 * MyCardScale

    PlayersLocationTable  ={    [CARD_PLAYERTYPE_MY]     = 2,

                                [CARD_PLAYERTYPE_LEFT1]  = 1,
                                [CARD_PLAYERTYPE_LEFT2]  = 1,
                                [CARD_PLAYERTYPE_LEFT3]  = 1,

                                [CARD_PLAYERTYPE_TOP1]   = 1,
                                [CARD_PLAYERTYPE_TOP2]   = 2,
                                [CARD_PLAYERTYPE_TOP3]   = 3,

                                [CARD_PLAYERTYPE_RIGHT1] = 3,
                                [CARD_PLAYERTYPE_RIGHT2] = 3,
                                [CARD_PLAYERTYPE_RIGHT3] = 3}

    plane:setVisible(true)
    plane:removeAllChildren()
    All_Card_Nodes[playerType] = {}
    self.niuniu_tip = NIUNIU_GAME_SCENE:getChildByName("niuniu_tip") 
end

function CardPlaneOperator:clearGameDatas(playerType,plane,stage)
    
    if  stage == 1 then
        require(TpackageName .. ".LayerShuffling"):removeScene()
    elseif stage == 2 or stage == nil then
        plane:stopAllActions()
        plane:removeAllChildren()
        All_Card_Nodes[playerType] = {}
    end
    
end

function CardPlaneOperator:swtichCardBackImg(typeIndex)
    CURRENTCARDBACKINDEX = typeIndex
end


-- function CardPlaneOperator:dealFirstCards(playerType,plane,cards,isRelogin)
-- end

-- function CardPlaneOperator:dealSecondCards(playerType,plane,cards,isRelogin)
-- end

--给自己发牌
function CardPlaneOperator:showCards(playerType,plane,cards,firstsendcard,isRelogin , status , card_state)
    dump("==========kkkkkkkkkkkkkkkkkk=========")
    dump("==========kkkkkkkkkkkkkkkkkk=========")
    dump("==========kkkkkkkkkkkkkkkkkk=========")
    dump("==========kkkkkkkkkkkkkkkkkk=========")
    dump("==========kkkkkkkkkkkkkkkkkk=========")
    dump("==========kkkkkkkkkkkkkkkkkk=========")
    local IntermediatePointX = plane:getContentSize().width/2

    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2 - 100))
    
    local actionCount = 0

    if  firstsendcard == true then  --首次发牌或者手牌为空 or next(All_Card_Nodes[playerType]) == nil

        All_Card_Nodes[playerType] = {}
        plane:removeAllChildren()

        -- --add by zzy begain
        -- GAME_CURRENT_QIPAI_INDEX = 0
        -- --add by zzy end

        if isRelogin == true then

            for index,value in ipairs(cards) do

                if  value ~= 0 then

                    local target_point_x = IntermediatePointX + (index-3)*MyHandCardInterval
                    local target_point_y = MyCardY

                    local card = Card.new()
                          card:setScale(MyCardScale)
                          card:addTo(plane)
                          card:setPosition(cc.p(target_point_x,target_point_y))
                          card:setCard(value)
                          card:showFront() 
                          table.insert(All_Card_Nodes[playerType],card)
                else
                    -- local target_point_x = IntermediatePointX + (index-3)*MyHandCardInterval
                    -- local target_point_y = MyCardY

                    -- local card = Card.new()
                    --       card:setScale(MyCardScale)
                    --       card:addTo(plane)
                    --       card:setPosition(cc.p(target_point_x,target_point_y))
                    --       card:setCard(value)
                    --       card:showBack() 
                    --       table.insert(All_Card_Nodes[playerType],card)
                end

            end

        else
            
            for index,value in ipairs(cards) do

                if  value ~= 0 then

                    actionCount = actionCount + 1

                    -- plane:performWithDelay(function()    




                    local card = Card.new()
                          card:setScale(OtherCardScale)
                          card:addTo(plane)
                          card:setPosition(WorldMiddlePosition)

                          card:setCard(value)
                          card:showBack() 

                    if status then 

                        local target_point_x = IntermediatePointX + (index-3)*MyHandCardInterval
                        local target_point_y = MyCardY

                        if index == 3 or index == 4 then 
                            target_point_x = target_point_x + 50
                        end
                    
                        card:setScale(MyCardScale)
                        card:setPosition(cc.p(target_point_x,target_point_y))

                        card:showFront()
                        -- if 1 == index or 2 == index then 
                        --     card.font_pai_:setOpacity(100)
                        -- end

                    else


                        local target_point_x = IntermediatePointX + (index-3)*MyHandCardInterval
                        local target_point_y = MyCardY

                        local moveAction = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))
                        local scaleAction = cc.ScaleTo:create(0.2,MyCardScale)

                        local endCallFunc = cc.CallFunc:create(function() 
                                    card:flipCard()
                                end)
                    
                        local moveAndScaleAction = cc.Spawn:create(moveAction,scaleAction)
                        -- local delay= cc.DelayTime:create(actionCount * SendCardTime)
                        local delay= cc.DelayTime:create(0.2)
                        local se  = cc.Sequence:create(delay,moveAndScaleAction,endCallFunc)
                              card:runAction(se)
                    end
     
                          table.insert(All_Card_Nodes[playerType],card)

                    -- end,actionCount * SendCardTime)

                end

            end

        end


    elseif  firstsendcard == false then

        -- dump(LIANGCARDNUM,"LIANGCARDNUM")

        local liangcardnum = #All_Card_Nodes[playerType]

        for index,value in ipairs(cards) do
           
            if  index > liangcardnum then
             
                actionCount = actionCount + 1

                local card = Card.new()
                      card:setScale(OtherCardScale)
                      card:addTo(plane)
                      card:setPosition(WorldMiddlePosition)
                      card:setCard(value)
                      if index == 4 then
                        card:showBack()
                      else
                        card:showFront()
                      end
                      card:showBack()
                      if card_state then 
                        card:showFront()
                    end

                      table.insert(All_Card_Nodes[playerType],card)
              
                local target_point_x = IntermediatePointX + (index-3)*MyHandCardInterval
                local target_point_y = MyCardY

                local moveAction = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))
                local scaleAction = cc.ScaleTo:create(0.2,MyCardScale)

                local moveAndScaleAction = cc.Spawn:create(moveAction,scaleAction)
                local delay= cc.DelayTime:create(actionCount* SendCardTime)
                -- local delay= cc.DelayTime:create(0.2)
                local se  = cc.Sequence:create(delay,moveAndScaleAction)

                      card:runAction(se)

            end

        end

    end

end


--其他玩家发牌动画  在其他玩家前面发5张牌。有动画效果(cardIndex:其他玩家结算，升牌的那张牌)
function CardPlaneOperator:showDealCardsAnimation(playerType,plane,cards,cardEndIndex,isRelogin, cardState,cardIndex , status)
    print("CardPlaneOperator:showDealCardsAnimation")
    print("CardPlaneOperator:showDealCardsAnimation")
    print("CardPlaneOperator:showDealCardsAnimation")
    print("CardPlaneOperator:showDealCardsAnimation")
    -- dump(USER_INFO)
    -- dump(plane)
    print(plane:isVisible())
    --牛牛发牌特效
    All_Card_Nodes[playerType] = All_Card_Nodes[playerType] or {}
    -- dump(All_Card_Nodes)
    local cardBeginIndex = #All_Card_Nodes[playerType] + 1
    
    if  cardBeginIndex == 1 then
        SoundUtils:playEffect("dealCards")
    else
        SoundUtils:playEffect("dealCards_short")
    end

    local planeWidth = plane:getContentSize().width 
    
    local cardScale = OtherCardScale
    local cardInterval = OtherCardInterval

    if  playerType == CARD_PLAYERTYPE_MY then
        cardScale = MyOutCardScale
        cardInterval = MyOutCardInterval
    end

    local playerLocation = 2 --PlayersLocationTable[playerType] or 2
    -- dump(PlayersLocationTable,"showDealCardsAnimation_PlayersLocationTable")
    -- dump(playerLocation,"showDealCardsAnimation_playerLocation")

    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2 - 100))

    local center_point_x =  WorldMiddlePosition.x
    local center_point_y =  WorldMiddlePosition.y
    
    local actionCount = 0

    if  cards then
        cardBeginIndex = 1
        plane:removeAllChildren()
        All_Card_Nodes[playerType] = {}
    end

    if  isRelogin == true then
        print("=====7777777777777=====")
        print("=====7777777777777=====")
        print("=====7777777777777=====")
        print("=====7777777777777=====")
        cardBeginIndex = 1
        cardEndIndex = cardEndIndex
        plane:removeAllChildren()
        All_Card_Nodes[playerType] = {}

        -- dump(cardEndIndex,"重连状态下发牌")
        
        for i = cardBeginIndex, cardEndIndex do
            
            local card = Card.new():addTo(plane,i)  
            print("get a card!!!!==cards[i]==",cards[i])
            if  cards and cards[i] ~= 0 then
                print("=======cards and cards[i] ~= 0=======")
                card:setCard(cards[i])
                if  cardState == "cover" then
                    card:showBack()
                else
                    card:showFront()
                end
            else
                card:showBack()
            end
            
            --撒扑庄家能看到闲家的牌.
            if status then 
                -- if 1 == i or 2 == i then 
                --     card.font_pai_:setOpacity(100)
                -- end
            end

            -- print("===i===cards[i]===",i,cards[i],playerType,NIUNIU_PLAYERTYPE_TABLE[USER_INFO.uid])
            -- if 4 == i and USER_INFO.is_qipai == 0 and playerType == NIUNIU_PLAYERTYPE_TABLE[USER_INFO.uid] then
            --     print("将牌设置为背面")
            --     card:showBack()
            --     card:setVisible(false)
            -- end

            card:setScale(cardScale)
            card:setPosition(cc.p(center_point_x,center_point_y))
             
            -- local target_point_x = planeWidth/2 - (3 - i) * cardInterval
            -- local target_point_y = OtherCardY 

            -- if  playerLocation == 3  then
            --     target_point_x = planeWidth - (6 - i) * cardInterval
            -- elseif  playerLocation == 1  then
            --     target_point_x = i * OtherCardInterval
            -- end

            -- local move = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))

            -- local delay= cc.DelayTime:create(actionCount* SendCardTime)
            -- local se  = cc.Sequence:create(delay,move)

            -- card:runAction(se)
            
            -- table.insert(All_Card_Nodes[playerType],card) 


            if  playerLocation == 3  then
                target_point_x = planeWidth - (6 - i) * cardInterval
            elseif  playerLocation == 1  then
                target_point_x = i * OtherCardInterval
            end

            local target_point_x = planeWidth/2 - (3 - i) * cardInterval
            local target_point_y = OtherCardY 

            card:setScale(cardScale)

            if i == 3 or i == 4 then 
                target_point_x = target_point_x + 50
            end
            
            card:setPosition(cc.p(target_point_x,target_point_y))   
            print("pos  pos pos ",target_point_x,target_point_y)
            table.insert(All_Card_Nodes[playerType],card) 

        end

    else 

        for i = cardBeginIndex, cardEndIndex do
            actionCount = actionCount + 1
            print (i , "-----i状态-----")
            local card = Card.new():addTo(plane,i)  
            -- dump (cards[i]  , "-----card玩家牌----")
            if  cards and cards[i] ~= 0 then
                card:setCard(cards[i])
                if  cardState == "cover" then
                    card:showBack()
                else
                    card:showFront()
                end
            else
                card:showBack()
            end
            -- if 4 == i then 
            card:showBack()
            -- end 

            card:setScale(cardScale)
            card:setPosition(cc.p(center_point_x,center_point_y))
             
            local target_point_x = planeWidth/2 - (3 - i) * cardInterval
            local target_point_y = OtherCardY 

            if cardIndex and cardIndex ~= 0 and i == cardIndex then
                target_point_y = target_point_y + 30
            end

            if  playerLocation == 3  then
                target_point_x = planeWidth - (6 - i) * cardInterval
            elseif  playerLocation == 1  then
                target_point_x = i * OtherCardInterval
            end

            local move = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))

            local delay= cc.DelayTime:create(actionCount* SendCardTime)
            -- local delay= cc.DelayTime:create(0.2)
            local se  = cc.Sequence:create(delay,move)

            card:runAction(se)
            
            table.insert(All_Card_Nodes[playerType],card) 

        end

    end

end

function CardPlaneOperator:SetAllNode(playerType , card)
    All_Card_Nodes[playerType] = card
end 

function CardPlaneOperator:GetAllNode(playerType)
    return All_Card_Nodes[playerType]
end

function CardPlaneOperator:openCards(playerType,plane)

    for _,cardNode in ipairs(All_Card_Nodes[playerType]) do
        if  cardNode and cardNode:hasValue() == true then
            cardNode:showFront()
        end
    end

end

--显示牛牛牌型
function CardPlaneOperator:showCardKind(playerType,plane,cardKind1,cardKind2)
    print("=======CardPlaneOperator:showCardKind====cardKind===",cardKind1)
    print("=======CardPlaneOperator:showCardKind====cardKind===",cardKind2)


    local cardKindScale = OtherCardScale/MyCardScale

    local x = plane:getContentSize().width/4 
    local y = 40 * cardKindScale   --MyOutCardOffsetY

    if playerType == 1 then
       x = x * 0.6
    else
       x = x * 1.4
    end 

    if  playerType == CARD_PLAYERTYPE_MY then
        y = MyOutCardOffsetY
        cardKindScale = 1
    end

    if tolua.isnull(self["niuniu_tip" .. playerType])  then 
        self["niuniu_tip" .. playerType] = nil
    end

    if tolua.isnull(self["niuniu_tip" .. playerType]) then 
        if self["niuniu_tip" .. playerType] then 
            self["niuniu_tip" .. playerType]:removeFromParent()
            self["niuniu_tip" .. playerType] = nil
        end
    end


    self["niuniu_tip" .. playerType] = self["niuniu_tip" .. playerType] or cc.CSLoader:createNode(TpackageName.."/csb/CardType.csb"):addTo(plane,100) -- self.niuniu_tip:clone()
    self["niuniu_tip" .. playerType]:setPosition(cc.p(x,y))
 
          
    local niuniu_txt = self["niuniu_tip" .. playerType]:getChildByName("niuniu_txt"):setVisible(false)


    local niuniu_txt1 = self["niuniu_tip" .. playerType]:getChildByName("niuniu_txt1"):setVisible(false)

    if playerType == 1 then 
        niuniu_txt:setPositionX(-46)
        niuniu_txt1:setPositionX(71)
        niuniu_txt:setPositionX(niuniu_txt:getPositionX() - 70)
        niuniu_txt1:setPositionX(niuniu_txt1:getPositionX() + 150)
    end

    if cardKind1 then 
        niuniu_txt:setVisible(true)
    end

    if cardKind2 then 
        niuniu_txt1:setVisible(true)
    end

    if "庄杀" == cardKind1 then 

        niuniu_txt:loadTexture(TpackageName .. "/images/zhuangsha.png")
    end

    if "庄走" == cardKind1 then 


        niuniu_txt:loadTexture(TpackageName .. "/images/zhuangzou.png")
    end
    
    if "闲信" == cardKind2 then 

        niuniu_txt1:loadTexture(TpackageName .. "/images/xianxin.png")
    end

    if "闲反" == cardKind2 then 

        niuniu_txt1:loadTexture(TpackageName .. "/images/xianfan.png")
    end

    if "密牌" == cardKind1 then 

        niuniu_txt:loadTexture(TpackageName .. "/images/menpai.png")

    end

    if "庄开" == cardKind2 then 
        niuniu_txt1:loadTexture(TpackageName .. "/images/zhuangkai.png")
    end

    if "庄认" == cardKind2 then 
        niuniu_txt1:loadTexture(TpackageName .. "/images/zhuangren.png")
    end        

    if "强攻" == cardKind1 then 
        niuniu_txt:loadTexture(TpackageName .. "/images/qianggong.png")
    end

    if "密陪" == cardKind1 then 
        niuniu_txt:loadTexture(TpackageName .. "/images/menpei.png")
    end

    if "水鱼天下" == cardKind1 then 
        niuniu_txt:loadTexture(TpackageName .. "/images/shuiyutianxia.png")
    end

    if "水鱼" == cardKind1 then 
        niuniu_txt:loadTexture(TpackageName .. "/images/shuiyu.png")
    end

    if playerType == 1 then 
        niuniu_txt:setScale(2)
        niuniu_txt1:setScale(2)
    end

end


function CardPlaneOperator:foldCard(playerType,plane,cards)

    if  playerType ~= CARD_PLAYERTYPE_MY then

        for key,value in pairs(cards) do

            if All_Card_Nodes[playerType][key] then

                local cardNode = All_Card_Nodes[playerType][key]

                if cardNode.setCard and cardNode.isBack_ then    --setCard方法存在且牌为背面
                    cardNode:setCard(value)
                    cardNode:showBack()
                end

            end
        end

    else   
     
        local planeWidth = plane:getContentSize().width   
        local target_point_y = MyOutCardY 

        for i,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
            local target_point_x = planeWidth/2 - (3 - i) * MyOutCardInterval
            local value = cards[i]
            cardNode:setScale(MyOutCardScale)
            cardNode:setCard(value)
            cardNode:setTouchEnabled(false)
            cardNode:stopAllActions()
            cardNode:showFront()
            -- cardNode:setPosition(cc.p(target_point_x,target_point_y))
        end

    end
end


function CardPlaneOperator:outCard(playerType,plane,cards)
    
    local planeWidth = plane:getContentSize().width
    local cardInterval
    local y = 0  

    if  playerType == CARD_PLAYERTYPE_MY then
        cardInterval = MyOutCardInterval
    else
        cardInterval = OtherCardInterval
    end

    if  cards then

        for i,value in ipairs(cards) do

            local cardNode = All_Card_Nodes[playerType][i]

            if  cardNode then
                cardNode:stopAllActions()
            else
                cardNode = Card.new():addTo(plane,key)
            end

            cardNode:setCard(value)
        end

        local outcards,fan = cardLogic:getallfans(cards)
        local bestOutCard = {}

        for i,v in ipairs(outcards) do
            bestOutCard[v] = true
        end

        for i,card in ipairs(All_Card_Nodes[playerType]) do

            local x = planeWidth/2 - (3 - i) * cardInterval

            card:stopAllActions()
            card:setPosition(cc.p(x,y))  --牌恢复原位
            card:showFront()

            if  fan > 1 and fan < 11 then
                if  bestOutCard[card.cardUint_] then
                    card.font_pai_:setColor(cc.c3b(100,100,100))  --将牌的牌面设为灰色
                end
            elseif  fan == 1 then
                card.font_pai_:setColor(cc.c3b(100,100,100))
            elseif  fan >= 11 then
                card.font_pai_:setColor(cc.c3b(255,255,255))
            end

        end

    else

        local   cards = {}
        for i,cardNode in ipairs(All_Card_Nodes[playerType]) do
            table.insert(cards,cardNode.cardUint_)
        end 

        local   outcards,fan = cardLogic:getallfans(cards)
        local   bestOutCard = {}

        for i,v in ipairs(outcards) do
            bestOutCard[v] = true
        end

        for i,card in ipairs(All_Card_Nodes[playerType]) do

            local x = planeWidth/2 - (3 - i) * cardInterval

            card:stopAllActions()
            card:setPosition(cc.p(x,y))  --牌恢复原位
            card:showFront()

            if  fan > 1 and fan < 11 then
                if  bestOutCard[card.cardUint_] then
                    card.font_pai_:setColor(cc.c3b(100,100,100))  --将牌的牌面设为灰色
                end
            elseif  fan == 1 then
                card.font_pai_:setColor(cc.c3b(100,100,100))
            elseif  fan >= 11 then
                card.font_pai_:setColor(cc.c3b(255,255,255))
            end

        end

    end
end

function CardPlaneOperator:turnCards(plane)
    for _,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
        if  cardNode:isBack() then
            cardNode:flipCard()
        end
    end
end

function CardPlaneOperator:countFanAndShow(plane)
    print("======CardPlaneOperator:countFanAndShow=====")
    print("======CardPlaneOperator:countFanAndShow=====")
    print("======CardPlaneOperator:countFanAndShow=====")
    print("======CardPlaneOperator:countFanAndShow=====")
    print("======CardPlaneOperator:countFanAndShow=====")
    print("======CardPlaneOperator:countFanAndShow=====")
    print("======CardPlaneOperator:countFanAndShow=====")
    -- GamePlaneOperator:showNumCount()

    -- for _,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
    --     cardNode:showFront()
    --     cardNode:setTouchEvent(All_Card_Nodes[CARD_PLAYERTYPE_MY])
    -- end
    
    -- GamePlaneOperator:hideCardKindTipButton()

    HAS_OPEN_CARD_UIDS[USER_INFO["uid"]] = true
    --------------自动算牌
    local outcards,fan = cardLogic:getallfans(MY_CARDS)
    local bestOutCard = {}

    dump(outcards,"countFanAndShow")
    for i,v in ipairs(outcards) do
        bestOutCard[v] = true
    end
    
    if  next(All_Card_Nodes[CARD_PLAYERTYPE_MY]) == nil or GAME_STATE == GAME_STATUS_STOP then
        return
    end

    -- GamePlaneOperator:showCardKind(CARD_PLAYERTYPE_MY,fan)
    --播放牛牛结果牌的声音
    SoundUtils:playCardKindEffect(fan)

    -- if  fan> 1 and fan<12 then  --牛一到牛牛

    --     local tenCardCount = 0

    --     local niuCardNums = {}
       
    --     --cardUint是唯一的，除非有两副牌
    --     for i,cardUint in pairs(MY_CARDS) do

    --         if  bestOutCard[cardUint] == true and  tenCardCount < 3 then      --凑10 的牌
    --             if  tenCardCount == 0 then
    --                 niuCardNums.left_num = cardLogic:GetCardLogicValue(cardUint)
    --             elseif tenCardCount == 1 then
    --                 niuCardNums.middle_num = cardLogic:GetCardLogicValue(cardUint)
    --             elseif tenCardCount == 2 then
    --                 niuCardNums.right_num = cardLogic:GetCardLogicValue(cardUint)
    --             end

    --             tenCardCount = tenCardCount + 1
    --         end
    --     end

    --     GamePlaneOperator:showCardNumCountEffect(niuCardNums)
    -- end 

    --手牌根据番数自动排序，有动画
    --[[local has_change_4 = false
    local has_change_5 = false]]
    local  cardUpheight = OtherCardY + 60 * (SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    
    for _,card in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
        
        if fan> 1 and fan<12 and bestOutCard[card.cardUint_] then  --牛一到牛牛
            card:setPositionY(cardUpheight)   --之前的位置是25
        elseif fan>= 12 and bestOutCard[card.cardUint_] then  --炸弹，五小牛，五花牛特殊牌型
            card:setPositionY(cardUpheight)
        elseif  fan == 1 then
            card.font_pai_:setColor(cc.c3b(100,100,100))
        end

        --手牌根据番数自动排序，然后进行插牌
        --[[if  key<= 3 and fan> 1 and not bestOutCard[card.cardUint_] then
            if  bestOutCard[bm.User.Cards[4].cardUint_] and not has_change_4 then
                self:exchangeCardPosition(card,bm.User.Cards[4])
                has_change_4 = true
            elseif  bestOutCard[bm.User.Cards[5].cardUint_] and not has_change_5 then
                self:exchangeCardPosition(card,bm.User.Cards[5])
                has_change_5 = true
            end
        end]]

        card:showFront()
        card:setTouchEnabled(false)
    end

end

function CardPlaneOperator:exchangeCardPosition(sprite1,sprite2)
    
    if tolua.type(sprite1)~="cc.Node" or tolua.type(sprite2)~="cc.Node" then
       return
    end

    local position1 = sprite1:getPosition()
    local position2 = sprite2:getPosition()
    
    local action1 = cc.MoveTo:create(0.5, position2)
    
    -----贝塞尔曲线
    --[[local radian = math.random(80,100)*3.14159/180
    local height = math.random(130,160)

    local q1x = position2.x + (position1.x - position2.x)/4
    local q1 = cc.p(q1x,height + position1.x + math.cos(radian) * q1x)

    local q2x = position2.x + (position1.x - position2.x)/1.6
    local q2 = cc.p(q2x,height + position1.x + math.cos(radian) * q2x)
    local ActionBezier = cc.BezierTo:create(0.6,{q1, q2,position1})]]
     
    ---跳跃
    -- local action2 = cc.JumpTo:create(0.6, position1, 150, 1)
     
    --直线移动
    -- local action2 = cc.MoveTo:create(0.5, position1)

    --插入动画
    local height = 130 
    local runTime = (position2.x - position1.x)/290*0.2

    local action2 = cc.Sequence:create( cc.MoveTo:create(0.2, cc.p(position2.x,position2.y+height)),
                                        cc.MoveTo:create(runTime, cc.p(position1.x,position1.y+height)),
                                        cc.MoveTo:create(0.15, cc.p(position1.x,position1.y))
                                       )
    sprite1:runAction(action1)
    sprite2:runAction(action2)

end

--@zc 20170727 搓牌场景的加载
function CardPlaneOperator:showCuoPai(cards,flag)  
     
    if flag == false then    
        local cuoPaiScene = SCENENOW["scene"]:getChildByName("cuopai")
        if cuoPaiScene then
            cuoPaiScene:removeFromParent()
        end 

        return
    end
     
    dump(cards,"搓牌牌值")

    local backCardNum = 0
    local backCardsIndexs = {}
    if All_Card_Nodes[CARD_PLAYERTYPE_MY] and next(All_Card_Nodes[CARD_PLAYERTYPE_MY]) then
        for index,card in pairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
           if  card:isBack() then
               table.insert(backCardsIndexs,index)
               backCardNum = backCardNum + 1
           end
        end
    end

    -- local cards = MY_CARDS
    -- -- 获得牌值
    -- local function getValue(card)
        
    --     local value = bit.band(card, 0x0F)
    --     if value == 1 then
    --         value = 14
    --     end
    --     return value
    -- end
    
    -- local cardValue_      --牌值
    -- local cardVariety_    --花色

    if backCardNum == 1 then
        local cardUint = cards[backCardsIndexs[1]]
        require(TpackageName .. ".LayerShuffling").new(cardUint)
        return
    end

    local cuoPaiScene =   cc.CSLoader:createNode(TpackageName .. "/csb/CuopaiScene.csb"):addTo(SCENENOW["scene"])
    cuoPaiScene:setName("cuopai")
    cuoPaiScene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    
    cuoPaiScene:setVisible(true)

    local endTime = 7
    --@zC 7秒之后自动释放
    --@zc动画结束位置
    local endPosX= DESIGN_SCREEN_WIDTH/4 
    local enPosY= -80  ---161
    
    local cuopai_plane = cuoPaiScene:getChildByName("cuopai_plane")
    cuopai_plane:setPosition(cc.p(DESIGN_SCREEN_WIDTH/2,DESIGN_SCREEN_HEIGHT/2))

    local card_1= cuopai_plane:getChildByName("card_1")
    local card_2= cuopai_plane:getChildByName("card_2")
    local card_3= cuopai_plane:getChildByName("card_3")
    local card_4= cuopai_plane:getChildByName("card_4")
    local card_5= cuopai_plane:getChildByName("card_5")

    card_1:setPosition(cc.p(endPosX, enPosY)) 
    card_2:setPosition(cc.p(endPosX, enPosY)) 
    card_3:setPosition(cc.p(endPosX, enPosY)) 
    card_4:setPosition(cc.p(endPosX, enPosY)) 
    card_5:setPosition(cc.p(endPosX, enPosY))
    
    local cuoPaiSceneHasRemoved = false
    local CloseEvent  = function(sender,event)
            if event == TOUCH_EVENT_ENDED then
               
                if cuoPaiSceneHasRemoved == true then
                    return
                end

                cuoPaiSceneHasRemoved = true
                --1.所有打开的牌全部，以动画的形式从当前的位置，回归到一开的位置

                card_1:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
                card_2:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
                card_3:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
                card_4:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
                card_5:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)

                card_1:rotateTo(0.1,-9) 
                card_2:rotateTo(0.1,-9)
                card_4:rotateTo(0.1,-9)
                card_5:rotateTo(0.1,-9)
                -- --1执行完毕之后，播放场景退出动画
                 
                local delay1 = cc.DelayTime:create(0.2)
                local callfuncMove = cc.CallFunc:create(function() 
                        cuopai_plane:moveTo(0.4, 0, -DESIGN_SCREEN_HEIGHT/2)
                    end)
                --         --2执行完毕之后，把场景移除
                
                local delay2 = cc.DelayTime:create(0.5)
                local callfuncEnd = cc.CallFunc:create(function() 
                        self:turnCards() 
                        cuoPaiScene:removeFromParent()                   
                    end)

                SCENENOW["scene"]:runAction(cc.Sequence:create(delay1,callfuncMove,delay2,callfuncEnd))

            end

        end

    local  CardRotateAngle = 4
    SCENENOW["scene"]:performWithDelay(function()
        if  not tolua.isnull(card_1) then
            card_1:rotateTo(0.2,-9 - 2* CardRotateAngle)    
            card_2:rotateTo(0.2,-9 -    CardRotateAngle)
            card_4:rotateTo(0.2,-9 +    CardRotateAngle)
            card_5:rotateTo(0.2,-9 + 2* CardRotateAngle)
        end
    end,1)

    SCENENOW["scene"]:performWithDelay(function()

        if cuoPaiSceneHasRemoved == true then
            return
        end

        cuoPaiSceneHasRemoved = true

        card_1:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
        card_2:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
        card_3:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
        card_4:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)
        card_5:setPosition(cc.p(endPosX, enPosY)) --moveTo(0.2, endPosX, enPosY)

        card_1:rotateTo(0.2, -9)
        card_2:rotateTo(0.2, -9)
        card_3:rotateTo(0.2, -9)
        card_4:rotateTo(0.2, -9)
        card_5:rotateTo(0.2, -9)

        local delay1 = cc.DelayTime:create(0.3)
        local callfuncMove = cc.CallFunc:create(function() 
                cuopai_plane:moveTo(0.4, 0, -DESIGN_SCREEN_HEIGHT/2)
            end)
        
        local delay2 = cc.DelayTime:create(0.8)
        local callfuncEnd = cc.CallFunc:create(function() 
                self:turnCards()
                cuoPaiScene:removeFromParent()                   
            end)

        SCENENOW["scene"]:runAction(cc.Sequence:create(delay1,callfuncMove,delay2,callfuncEnd))

    end,endTime)


    --倒序放牌
    if  backCardNum == 5 then  --经典牛牛，五张全暗的情况下

        for i=1,backCardNum do

            local a =cuopai_plane:getChildByName("card_"..i)

            -- a:setScale(1.3)
            
            local cardUint = cards[6-i]
                   
            Card:setCuoCard(a,cardUint)

            -- cardValue_ =  getValue(cardUint)
            -- cardVariety_ =  bit.band(cardUint, 0xF0)

            -- if cardValue_ ==65 then
            --     a:setTexture(Cuo_Card_Path .."big_king.png")
            -- elseif cardValue_ ==66 then
            --     a:setTexture(Cuo_Card_Path .."small_king.png")
            -- else     
            --     a:setTexture(Cuo_Card_Path .. Card_Variety_Transform_Path[cardVariety_] .. Card_Value_Transform_Path[cardValue_])
            -- end

            self:add_eventlistener(a.font_pai_) --@zc 20170728 判断当前鼠标点击下的是哪一张那个牌，点击哪一张把那一张那个传过去   
        end

    else   --明牌牛牛，先发牌的情况下

        for i=1,backCardNum + 1 do
            
            local a = cuopai_plane:getChildByName("card_"..i)

            a:setScale(1.5)
            
            if  i ~= backCardNum + 1 then
                 
                local cardUint = cards[backCardsIndexs[i]]
                
                Card:setCuoCard(a,cardUint)
                -- if cardUint == 65 then  --大王
                --     cardValue_ = 65 
                -- elseif  cardUint ==66 then  --小王
                --     cardValue_ = 66
                -- else
                --     cardValue_ =  getValue(cardUint)
                --     cardVariety_ =  bit.band(cardUint, 0xF0)
                -- end

                -- if cardUint ==65 then
                --     a:setTexture(Cuo_Card_Path .."big_king.png")
                -- elseif cardUint ==66 then
                --     a:setTexture(Cuo_Card_Path .."small_king.png")
                -- else     
                --     a:setTexture(Cuo_Card_Path .. Card_Variety_Transform_Path[cardVariety_] .. Card_Value_Transform_Path[cardValue_])
                -- end
                self:add_eventlistener(a.font_pai_) --@zc 20170728 判断当前鼠标点击下的是哪一张那个牌，点击哪一张把那一张那个传过去   

            else
                 
                dump("设置搓牌牌背")
                Card:setCuoCard(a,_,true)
                -- a:setTexture(Cuo_Card_Path .."card_back.png")
                -- a:setScaleY(520/143)
                -- a:setScaleX(3.3)   
                self:add_eventlistener(a.backBg_) --@zc 20170728 判断当前鼠标点击下的是哪一张那个牌，点击哪一张把那一张那个传过去   
            end


        end

    end

    cuopai_plane:addTouchEventListener(CloseEvent)
    
end

--@zc20170728 搓牌的具体实现提示
function CardPlaneOperator:add_eventlistener( card_image )
        print("=========add_eventlistener========",GAME_STATE)
        print("=========add_eventlistener========",GAME_STATE)
        print("=========add_eventlistener========",GAME_STATE)
        --add by zzy 2019-5-25 begain
        if GAME_STATE ~= GAME_STATUS_OUTCARD then
            return 
        end
        if GAME_STATE == GAME_STATUS_STOP then
            return 
        end
        --add by zzy 2019-5-25 begain

        local a=card_image:getPosition()
        local touchBeginPoint = nil  

        local function onTouchBegan(touch, event)  
            local target = event:getCurrentTarget()  --获取事件绑定的目标
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0,0, s.width, s.height) --设置点击的区域
            if cc.rectContainsPoint(rect, locationInNode) then
                target:setOpacity(255)  --设置点击区域下的透明度大小0-255之间
                local location = touch:getLocation()  
                touchBeginPoint = {x = location.x, y = location.y}  
                return true  
            end  
        end  
  
        local function onTouchMoved(touch, event)  
            --changed by zzy 2019-5-25 begain  
            --注释掉

            -- local location = touch:getLocation()  
            -- if touchBeginPoint then  
            --     local cx =card_image:getPosition().x
            --     local cy=card_image:getPosition().y                
            --     card_image:setPosition(cc.p(cx + location.x - touchBeginPoint.x,  
            --                            cy + location.y - touchBeginPoint.y))
            --     touchBeginPoint = {x = location.x, y = location.y}  
            -- end   

            --changed by zzy 2019-5-25 end
        end  
  
        local function onTouchEnded(touch, event)  
            --changed by zzy 2019-5-25 begain  此处仅仅只是将所选择的图片往上罢了，如果再此之前选择过其他的弃牌，则其他弃牌位置复原
            print("=======888888888888888888888888=========")
            if GAME_STATE == GAME_STATUS_STOP then
                return 
            end
            if GAME_STATE ~= GAME_STATUS_OUTCARD then
                return 
            end
            dump(All_Card_Nodes[USER_INFO[uid]])
            for k,v in pairs(All_Card_Nodes[USER_INFO[uid]]) do
                local target_point_x = IntermediatePointX + (k-3)*MyHandCardInterval
                local target_point_y = MyCardY
                v:setPosition(cc.p(target_point_x,target_point_y))
            end

            local cx =card_image:getPosition().x
            local cy=card_image:getPosition().y  
            card_image:setPosition(cc.p(cx,cy + 30))
            --changed by zzy 2019-5-25 end
        end  
  
        local listener = cc.EventListenerTouchOneByOne:create()  --依次一个一个的执行
        listener:setSwallowTouches(true)  --当两个碰撞体重叠的时候，只检测到最上层的那一个
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )  
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )  
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )  
        local eventDispatcher = card_image:getEventDispatcher()  
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, card_image)

end


return CardPlaneOperator


--------------------------------------------------------------------------
-- local Cuo_Card_Path = TpackageName .. "/images/newcard/"

-- local Card_Variety_Transform_Path = 
-- {
--     [VARIETY_DIAMOND] = "diamonds_",
--     [VARIETY_CLUB] = "clubs_",
--     [VARIETY_HEART] = "hearts_",
--     [VARIETY_SPADE] = "spades_",
-- }

-- local Card_Value_Transform_Path = 
-- {
--     [0] = "",
--     [1] = "01.png",
--     [2] = "02.png",
--     [3] = "03.png",
--     [4] = "04.png",
--     [5] = "05.png",
--     [6] = "06.png",
--     [7] = "07.png",
--     [8] = "08.png",
--     [9] = "09.png",
--     [10] = "10.png",
--     [11] = "j.png",
--     [12] = "q.png",
--     [13] = "k.png",
--     [14] = "14.png",--五小牛
-- }