local CardPlaneOperator = class("CardPlaneOperator")
local Card = require(TpackageName .. ".DominoCard")

local cardLogic = require(TpackageName .. ".cardLogic")
local  UserInfoPlaneOperator = require(TpackageName .. ".operator.UserInfoPlaneOperator")

local All_Card_Nodes = {}

local MyCardScale = 0.75
local MyOutCardScale = 0.6
local OtherCardScale = 0.355

local OriCardPoolScale = 0.5

local CardPoolInterval = 10

local MyHandCardInterval
local MyOutCardInterval
local OtherCardInterval
local MyOutCardOffsetY

local SendCardTime = 0.15

-- 1表示左侧对齐， 2表示中间对齐， 3表示右对齐
local PlayersLocationTable  = {}

local Cardtype_Image_Path = {}

local HANDCARD_SPACE_X = 0
local HANDCARD_SPACE_Y = 10

local enableTouchCard = false
local COL_COUNT = 8
----------------------------------------------------------------------

function CardPlaneOperator:init(playerType, panel)
--[[    self.small_panel = panel:getChildByName("txt_left")]]


end

function CardPlaneOperator:clearGameDatas(playerType, panel, stage)
    
    if  stage == 1 then
        require(TpackageName .. ".LayerShuffling"):removeScene()
    elseif stage == 2 or stage == nil then
        panel:removeAllChildren()
    end
    
end

--给自己发牌
function CardPlaneOperator:showCards(playerType, panel, cards)
    panel:removeAllChildren()

    PJ_CARDS_SELECTED = {}

    local count = #cards

    if count <= 0 then
        --todo
        return
    end

    local PJ_CARD_TOUCH_FUNC = function (sender, event)
        -- 触摸结束
        if event == TOUCH_EVENT_ENDED then

            if not enableTouchCard then
                --todo
                return
            end

            local count = #PJ_CARDS_SELECTED

            local position = sender:getPosition()
            local heightOffset = sender:getSize().height * sender:getScale() * 0.2
            dump(count, "test 0131")
            if count < 2 then
                --todo
                if sender.m_isSelected then
                    --todo
                    sender.m_isSelected = false

                    for i,v in ipairs(PJ_CARDS_SELECTED) do
                        if v == sender.m_value then
                            --todo
                            table.remove(PJ_CARDS_SELECTED, i)
                            -- 添加牌取消的音效
                            SoundUtils:playEffect("取消牌")
                            break
                        end
                    end

                    position.y = position.y - heightOffset
                else
                    sender.m_isSelected = true

                    table.insert(PJ_CARDS_SELECTED, sender.m_value)
                    -- 添加牌选中音效
                    SoundUtils:playEffect("选中牌")
                    position.y = position.y + heightOffset
                end
            else
                if sender.m_isSelected then
                    --todo
                    sender.m_isSelected = false

                    for i,v in ipairs(PJ_CARDS_SELECTED) do
                        if v == sender.m_value then
                            --todo
                            table.remove(PJ_CARDS_SELECTED, i)
                            -- 添加牌取消选中的音效
                            SoundUtils:playEffect("取消牌")
                            break
                        end
                    end

                    position.y = position.y - heightOffset
                end
            end

            sender:setPosition(position)

            if #PJ_CARDS_SELECTED == 2 then
                --todo
                GamePlaneOperator:showCardGroups(true)
            else
                GamePlaneOperator:showCardGroups(false)
            end
        end
    end

    local card = Card:new(0)

    local cardHeight = panel:getSize().height - 10
    local scale = cardHeight / card:getSize().height

    local cardHeight2=PAIJIU_GAME_SCENE:getChildByName("player_panel_2"):getChildByName("inhand_panel"):getSize().height - 10
    local scale2 = cardHeight2 / card:getSize().height

    local cardWidth = card:getSize().width * scale

    local y = panel:getSize().height / 2
    local oriX = (panel:getSize().width - cardWidth * count - (count - 1) * HANDCARD_SPACE_X) / 2

  
    local card_pool_panel = PAIJIU_GAME_SCENE.card_pool_panel
    local children = card_pool_panel:getChildren()
    local cardNode 
    local maxX = -1000
    for i,node in ipairs(children) do
        local pos = node:getPosition()
        if pos.x > maxX then
            maxX = pos.x
            cardNode = node
        end
    end
    local wordPos
    if cardNode then
        local wp = (cardNode:getParent()):convertToWorldSpace(cardNode:getPosition())
        -- wp = (cardNode:getParent():getParent()):convertToWorldSpaceAR(wp)
        wordPos = panel:convertToNodeSpace(wp)
    else
        local size = cc.Director:getInstance():getWinSize()
        wordPos = panel:convertToNodeSpace(cc.p(size.width/2, size.height/2))
    end
    -- local panel = PAIJIU_GAME_SCENE.player_panel_1.inhand_panel
    -- panel:removeAllChildren()
    local DelayTime = 0.0
    local MoveToTime = 0.2
    if count == 4 then
        for i,v in ipairs(cards) do
            local children = card_pool_panel:getChildren()
            local nodeIdx = #children
            if children[nodeIdx] then children[nodeIdx]:removeFromParent() end
            dump(string.format("发牌 删除桌面的牌%d 桌面还有%d张牌", i, nodeIdx))
            local card
            local x = oriX + (cardWidth + HANDCARD_SPACE_X) * (i - 1) + cardWidth / 2
            if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
                --todo
                card = Card:new(0)
                local size = card:getSize()
                card:setTouchEnabled(false)
                card:setScale(scale2)
                card:setPosition(wordPos)
                
                wordPos.x = wordPos.x + (card:getSize().width * scale2 + HANDCARD_SPACE_X)

                card:setTag(i)
                panel:addChild(card)

                local delayaction = cc.DelayTime:create(DelayTime)
                local moveaction=cc.MoveTo:create(MoveToTime,cc.p(x,y))--cc.RemoveSelf:create()
                -- dump(x,y)
                -- print("--------------")
                local scaleaction = cc.ScaleTo:create(0.3,scale)
                local moveAndScaleAction = cc.Spawn:create(moveaction,scaleaction)
                local seq = cc.Sequence:create(delayaction,moveAndScaleAction,cc.CallFunc:create(
                    function()
                        -- local ourcard = Card:new(v)
                        -- enableTouchCard = true
                        -- ourcard:addTouchEventListener(PJ_CARD_TOUCH_FUNC)
                        -- ourcard:setScale(scale)
                        -- ourcard:setPosition(cc.p(x,y))      
                        -- ourcard:setTag(i)
                        -- panel:addChild(ourcard)
                        -- ourcard:setVisible(false)

                        -- local aniTime = 0.3
                        -- local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0));
                        -- ourcard:runAction(to_p1)  
                
                        -- local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
                        -- card:runAction(to_B);
                        -- card:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100), cc.RemoveSelf:create(), cc.CallFunc:create(
                        --     function() 
                        --         ourcard:setVisible(true) 
                        --     end)))
                
                        -- local de = cc.DelayTime:create(aniTime);
                        -- local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0));
                        -- local seqP2 = cc.Sequence:create(de,to_p2,cc.CallFunc:create(
                        --     function()
                        --         -- 显示开牌相关按钮
                        --         GamePlaneOperator:showOutCardButtons(true)
                        --     end
                        -- ));
                        -- ourcard:runAction(seqP2);
                        local cardValue = PJ_HANDCARDS[i]
                        if cardValue then
                            card:setCard(cardValue)
                        end
                        enableTouchCard = true
                        card:setTag(i)
                        card:addTouchEventListener(PJ_CARD_TOUCH_FUNC)
                        card:setTouchEnabled(true)
                        GamePlaneOperator:showOutCardButtons(true)
                    end
                ))
                card:runAction(seq)
            else
                card=Card:new(0)
                card:setTouchEnabled(false)
                card:setScale(scale) 
                card:setPosition(wordPos)    
                wordPos.x = wordPos.x + (cardWidth + HANDCARD_SPACE_X)

                card:setTag(i)
                panel:addChild(card)
                local delayaction = cc.DelayTime:create(DelayTime)
                local moveaction=cc.MoveTo:create(MoveToTime,cc.p(x,y))
                local seq = cc.Sequence:create(delayaction,moveaction)
                card:runAction(seq)
            end
        end
    elseif count == 2 then
        --dump(cards, "-------cards ------------")
        local smallWidthOffset = cardWidth * 0.4
        local smallMyOriX = panel:getSize().width / 2 - smallWidthOffset
        for i,v in ipairs(cards) do
            local children = card_pool_panel:getChildren()
            local nodeIdx = #children
            if children[nodeIdx] then children[nodeIdx]:removeFromParent() end

            local card
            local x
            if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
                x = smallMyOriX + smallWidthOffset * (i-1) + cardWidth / 2

                card = Card:new(0)
                card:setTouchEnabled(false)
                card:setScale(scale2)
                card:setPosition(wordPos)      
                wordPos.x = wordPos.x + (card:getSize().width * scale2 + HANDCARD_SPACE_X)
                card:setTag(i)
                panel:addChild(card)

                local delayaction = cc.DelayTime:create(DelayTime)
                local moveaction=cc.MoveTo:create(MoveToTime,cc.p(x,y))
                local scaleaction = cc.ScaleTo:create(0.3,scale)
                local moveAndScaleAction = cc.Spawn:create(moveaction,scaleaction)
                local seq = cc.Sequence:create(delayaction,moveAndScaleAction,cc.CallFunc:create(
                    function()
                        -- local ourcard = Card:new(v)
                        -- ourcard:setTouchEnabled(false)
                        -- ourcard:setScale(scale)
                        -- ourcard:setPosition(cc.p(x,y))                  
                        -- ourcard:setTag(i)
                        -- panel:addChild(ourcard)
                        -- ourcard:setVisible(false)

                        -- local aniTime = 0.3
                        -- local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0));
                        -- ourcard:runAction(to_p1)  
                
                        -- local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
                        -- card:runAction(to_B);
                        -- card:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100),cc.RemoveSelf:create(),cc.CallFunc:create(
                        --     function() 
                        --         ourcard:setVisible(true) 
                        --     end)))
                
                        -- local de = cc.DelayTime:create(aniTime);
                        -- local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0));
                        -- local seqP2 = cc.Sequence:create(de,to_p2,cc.CallFunc:create(
                        --     function()
                        --         -- 显示开牌相关按钮
                        --         GamePlaneOperator:showOutCardButtons(true)
                        --     end
                        -- ));
                        -- ourcard:runAction(seqP2);

                        local cardValue = PJ_HANDCARDS[i]
                        if cardValue then
                            card:setCard(cardValue)
                        end
                        enableTouchCard = true
                        card:addTouchEventListener(PJ_CARD_TOUCH_FUNC)
                        card:setTouchEnabled(true)
                        GamePlaneOperator:showOutCardButtons(true)
                    end
                ))
                card:runAction(seq)
            else
                x = oriX + (cardWidth + HANDCARD_SPACE_X) * (i - 1) + cardWidth / 2

                card = Card:new(0)
                card:setPosition(wordPos)   
                wordPos.x = wordPos.x + (cardWidth + HANDCARD_SPACE_X)

                card:setTouchEnabled(false)
                card:setScale(scale)
                card:setTag(i)
                panel:addChild(card)
                local moveaction=cc.MoveTo:create(MoveToTime,cc.p(x,y))
                local delayaction = cc.DelayTime:create(DelayTime)
                local seq = cc.Sequence:create(delayaction,moveaction)
                card:runAction(seq)
            end
        end
    end
end

function CardPlaneOperator:setCardsValue( playerType, panel, cards )
    local children = panel:getChildren()
    if #cards ~= #children then
        return
    end
    for idx,node in ipairs(children) do
        local value = cards[idx]
        node:setCard(value)
    end
end

function CardPlaneOperator:openCards(playerType, panel, cardGroups)
    local count = #cardGroups
    if count == 0 then
        --todo
        return
    end

    UserInfoPlaneOperator:showkaipai(panel,true)
    -- 我坐下，并已经开牌，
    -- 其他玩家开牌
    if count == 4 then
        panel:removeAllChildren()
        local card = Card:new(0)

        local cardHeight = panel:getSize().height - 10
        local scale = cardHeight / card:getSize().height
        local cardWidth = card:getSize().width * scale

        local width = panel:getSize().width
        local height = panel:getSize().height
        local oriX = (width - 2 * HANDCARD_SPACE_X - 2 * cardWidth - cardHeight) / 2
        local oriY = (height - HANDCARD_SPACE_Y - 2 * cardWidth) / 2
        if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
            local group = cardGroups[2]

            for i,v in ipairs(group.cards) do
                card = Card:new(v)

                card:setScale(scale)

                local x = oriX + cardWidth / 2
                card:setPosition(cc.p(x, height / 2))
                card:setTag(i)
                panel:addChild(card)
                card:setTouchEnabled(false)

                oriX = oriX + cardWidth + HANDCARD_SPACE_X
            end

            group = cardGroups[1]

            local x = oriX + cardHeight / 2
            for i,v in ipairs(group.cards) do
                card = Card:new(v)
                card:setScale(scale)
                card:setRotation(90)
                card:setPosition(cc.p(x, oriY + cardWidth / 2))
                card:setTag(i+2)
                panel:addChild(card)
                card:setTouchEnabled(false)
                
                oriY = oriY + cardWidth + HANDCARD_SPACE_Y
            end
        else
            for i=1, 2 do
                card = Card:new(0)
                card:setScale(scale)
                local x = oriX + cardWidth / 2
                card:setPosition(cc.p(x, height / 2))
                card:setTag(i)
                card:setTouchEnabled(false)
                panel:addChild(card)
                oriX = oriX + cardWidth + HANDCARD_SPACE_X
            end

            local x = oriX + cardHeight / 2
            for i = 3, 4  do
                card = Card:new(0)
                card:setScale(scale)
                card:setRotation(90)
                card:setPosition(cc.p(x, oriY + cardWidth / 2))
                card:setTouchEnabled(false)
                card:setTag(i)
                panel:addChild(card)
                oriY = oriY + cardWidth + HANDCARD_SPACE_Y
            end
        end
    end
end

function CardPlaneOperator:openMyCards4Ani(panel, cardGroups)
    local m = {}

    m[1] = false
    m[2] = false
    m[3] = false
    m[4] = false

    local card = Card:new(0)

    local cardHeight = panel:getSize().height - 10
    local scale = cardHeight / card:getSize().height
    local cardWidth = card:getSize().width * scale

    local width = panel:getSize().width
    local height = panel:getSize().height

    local oriX = (width - 2 * HANDCARD_SPACE_X - 2 * cardWidth - cardHeight) / 2
    local oriY = (height - HANDCARD_SPACE_Y - 2 * cardWidth) / 2

    for i=1,4 do
        local card = panel:getChildByTag(i)

        if not card then
            --todo
            return
        end

        local index = 0

        local isExist = false

        local group = cardGroups[2]
        for _,v in ipairs(group.cards) do
            index = index + 1
            if not m[index] and v == card.m_value then
                m[index] = true
                if index < 1 or index > 4 then
                    return
                end
                local position
                if index < 3 then
                    position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * (index - 1) + cardWidth / 2, height / 2)
                else
                    position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * 2 + cardHeight / 2, oriY + (cardWidth + HANDCARD_SPACE_X) * (index - 3) + cardWidth / 2)
                end
                if position then
                    if index < 3 then
                        card:runAction(cc.MoveTo:create(0.2, position))
                    else
                        local ac1 = cc.MoveTo:create(0.2, position)
                        local ac2 = cc.RotateBy:create(0.2, 90)
                        card:runAction(cc.Spawn:create(ac1, ac2))
                    end
                end
                isExist = true
                break
            end
        end

        if not isExist then
            group = cardGroups[1]
            for _,v in ipairs(group.cards) do
                index = index + 1
                if not m[index] and v == card.m_value then
                    m[index] = true
                    if index < 1 or index > 4 then
                        return
                    end
                    local position
                    if index < 3 then
                        position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * (index - 1) + cardWidth / 2, height / 2)
                    else
                        position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * 2 + cardHeight / 2, oriY + (cardWidth + HANDCARD_SPACE_X) * (index - 3) + cardWidth / 2)
                    end

                    if position then
                        if index < 3 then
                            card:runAction(cc.MoveTo:create(0.2, position))
                        else
                            local ac1 = cc.MoveTo:create(0.2, position)
                            local ac2 = cc.RotateBy:create(0.2, 90)
                            card:runAction(cc.Spawn:create(ac1, ac2))
                        end
                    end

                    isExist = true

                    break
                end
            end
        end

        card:setTouchEnabled(false)
    end
end

function CardPlaneOperator:openOtherCards4Ani(panel, cardsGroup)
    if #cardsGroup == 0 then
        local card = Card:new(0)

        local cardHeight = panel:getSize().height - 10
        local scale = cardHeight / card:getSize().height
        local cardWidth = card:getSize().width * scale

        local width = panel:getSize().width
        local height = panel:getSize().height

        --local oriX = width/2 + cardHeight/2 + HANDCARD_SPACE_X + cardHeight/2
        local oriX = (width - 2 * HANDCARD_SPACE_X - 2 * cardWidth - cardHeight) / 2 + (cardWidth+ HANDCARD_SPACE_X)*2 + cardHeight/2 +20
        local oriY = (height - HANDCARD_SPACE_Y - 2 * cardWidth) / 2

        for i=3, 4 do
            local card = panel:getChildByTag(i)
            local position
            position = cc.p(oriX, oriY + (i-3)*(cardWidth + HANDCARD_SPACE_Y) + cardWidth/2)
            local ac1 = cc.MoveTo:create(0.1, position)
            local ac2 = cc.RotateBy:create(0.1, 90)
            card:runAction(cc.Spawn:create(ac1, ac2))
        end
    end
end

function CardPlaneOperator:outCard(playerType,panel,cards)

    if  cards then

        if  playerType ~= CARD_PLAYERTYPE_MY then

            for key,value in ipairs(cards) do

                if All_Card_Nodes[playerType][key] then

                    local cardNode = All_Card_Nodes[playerType][key]

                    if cardNode.setCard and cardNode.isBack_ then    --setCard方法存在且牌为背面
                        cardNode:setCard(value)
                        cardNode:showFront()
                    end

                end
            end

        else

            local IntermediatePointX = panel:getContentSize().width/2
            local cardOutHeight = All_Card_Nodes[CARD_PLAYERTYPE_MY][1]:getPositionY() + MyOutCardOffsetY

            for i,card in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
                card:showFront()
                card:setPosition(cc.p(IntermediatePointX + (i-3)*MyOutCardInterval,cardOutHeight))
                card:setTouchEnabled(false)
            end

        end

    else

        -- if  playerType ~= CARD_PLAYERTYPE_MY then
        if  All_Card_Nodes[playerType] then

            local cards = {}
            for i,card in ipairs(All_Card_Nodes[playerType]) do
                table.insert(cards,card.cardUint_)
            end

            local   outcards,fan = cardLogic:getallfans(cards)
            local   bestOutCard = {}

            for i,v in ipairs(outcards) do
                bestOutCard[v] = true
            end

            local panelWidth = panel:getContentSize().width

            local niuCardInterval
            local cardInterval
            if  playerType == CARD_PLAYERTYPE_MY then
                cardInterval = MyOutCardInterval
                niuCardInterval = 30
            else
                cardInterval = OtherCardInterval
                niuCardInterval =  20
            end

            local playerLocation = PlayersLocationTable[playerType] or 2

            local outCardCount = 1
            local niuCardCount = 4

            if  fan > 1 and fan < 12 then

                dump("无翻牌动画")
                for i,card in ipairs(All_Card_Nodes[playerType]) do

                    if  card.isBack_ then
                        card:showFront() --flipCard()
                    end

                    if  bestOutCard[card.cardUint_] then
                        local x = panelWidth/2 - (3 - outCardCount) * cardInterval

                        if  playerLocation == 3  then
                            x = (panelWidth - niuCardInterval) - (6 - outCardCount) * cardInterval
                        elseif  playerLocation == 1  then
                            x = outCardCount * cardInterval
                        end

                        card:setPositionX(x)
                        card:setZOrder(outCardCount)
                        outCardCount = outCardCount + 1

                    else
                        local x = panelWidth/2 - (3 - niuCardCount) * cardInterval + niuCardInterval

                        if  playerLocation == 3  then
                            x = (panelWidth - niuCardInterval) - (6 - niuCardCount) * cardInterval + niuCardInterval
                        elseif  playerLocation == 1  then
                            x = niuCardCount * cardInterval + niuCardInterval
                        end

                        dump(tolua.type(card),"出牌时牌的属性")
                        card:setPositionX(x)
                        card:setZOrder(niuCardCount)
                        niuCardCount = niuCardCount + 1
                    end

                end

            else
                dump("翻牌动画")

                for i,card in ipairs(All_Card_Nodes[playerType]) do

                    if  card.isBack_  then
                        card:flipCard()
                    end
                end

            end

        end
        -- end

    end
end

function CardPlaneOperator:countFanAndShow(panel)

    GamePlaneOperator:showNumCount()

    for _,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
        cardNode:showFront()
        cardNode:setTouchEvent(All_Card_Nodes[CARD_PLAYERTYPE_MY])
    end

    GamePlaneOperator:hideCardKindTipButton()

    --------------自动算牌
    -- local   outcards,fan = cardLogic:getallfans(MY_CARDS)
    -- local   bestOutCard = {}

    -- for i,v in ipairs(outcards) do
    --     bestOutCard[v] = true
    -- end

    -- if  next(All_Card_Nodes[CARD_PLAYERTYPE_MY]) == nil or GAME_STATE == GAME_STATUS_STOP then
    --     return
    -- end

    -- GamePlaneOperator:showCardKind(CARD_PLAYERTYPE_MY,fan)

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

    -- --手牌根据番数自动排序，有动画
    -- --[[local has_change_4 = false
    -- local has_change_5 = false]]
    -- local  cardUpheight = 25 * (SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)

    -- for _,card in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do

    --     if fan> 1 and fan<12 and not bestOutCard[card.cardUint_] then  --牛一到牛牛
    --         card:setPositionY(card:getPositionY() + cardUpheight)   --之前的位置是25
    --     elseif fan>= 12 and bestOutCard[card.cardUint_] then  --炸弹，五小牛，五花牛特殊牌型
    --         card:setPositionY(card:getPositionY() + cardUpheight)
    --     end

    --     --手牌根据番数自动排序，然后进行插牌
    --     --[[if  key<= 3 and fan> 1 and not bestOutCard[card.cardUint_] then
    --         if  bestOutCard[bm.User.Cards[4].cardUint_] and not has_change_4 then
    --             self:exchangeCardPosition(card,bm.User.Cards[4])
    --             has_change_4 = true
    --         elseif  bestOutCard[bm.User.Cards[5].cardUint_] and not has_change_5 then
    --             self:exchangeCardPosition(card,bm.User.Cards[5])
    --             has_change_5 = true
    --         end
    --     end]]

    --     card:showFront()
    --     card:setTouchEnabled(false)
    -- end

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

    local cards = MY_CARDS

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

    local cuopai_panel = cuoPaiScene:getChildByName("cuopai_panel")
    cuopai_panel:setPosition(cc.p(DESIGN_SCREEN_WIDTH/2,DESIGN_SCREEN_HEIGHT/2))

    local card_1= cuopai_panel:getChildByName("card_1")
    local card_2= cuopai_panel:getChildByName("card_2")
    local card_3= cuopai_panel:getChildByName("card_3")
    local card_4= cuopai_panel:getChildByName("card_4")
    local card_5= cuopai_panel:getChildByName("card_5")

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
                cuopai_panel:moveTo(0.4, 0, -DESIGN_SCREEN_HEIGHT/2)
            end)
            --         --2执行完毕之后，把场景移除

            local delay2 = cc.DelayTime:create(0.5)
            local callfuncEnd = cc.CallFunc:create(function()
                self:countFanAndShow()
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
            cuopai_panel:moveTo(0.4, 0, -DESIGN_SCREEN_HEIGHT/2)
        end)

        local delay2 = cc.DelayTime:create(0.8)
        local callfuncEnd = cc.CallFunc:create(function()
            self:countFanAndShow()
            cuoPaiScene:removeFromParent()
        end)

        SCENENOW["scene"]:runAction(cc.Sequence:create(delay1,callfuncMove,delay2,callfuncEnd))

    end,endTime)


    --倒序放牌
    if  backCardNum == 5 then  --经典牛牛，五张全暗的情况下

        for i=1,backCardNum do

            local a =cuopai_panel:getChildByName("card_"..i)

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

            local a = cuopai_panel:getChildByName("card_"..i)

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
                self:add_eventlistener(a.backBg_) --@zc 20170728 判断当前鼠标点击下的是哪一张那个牌，点击哪一张把那一张那个传过去   
            end


        end

    end

    cuopai_panel:addTouchEventListener(CloseEvent)

end

--@zc20170728 搓牌的具体实现提示
function CardPlaneOperator:add_eventlistener( card_image )

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
        local location = touch:getLocation()
        if touchBeginPoint then
            local cx =card_image:getPosition().x
            local cy=card_image:getPosition().y
            card_image:setPosition(cc.p(cx + location.x - touchBeginPoint.x,
            cy + location.y - touchBeginPoint.y))
            touchBeginPoint = {x = location.x, y = location.y}
        end
    end

    local function onTouchEnded(touch, event)

    end

    local listener = cc.EventListenerTouchOneByOne:create()  --依次一个一个的执行
    listener:setSwallowTouches(true)  --当两个碰撞体重叠的时候，只检测到最上层的那一个
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = card_image:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, card_image)

end

function CardPlaneOperator:showCardsOnResultCsb(playerType, panel, cardGroups)
    local count = #cardGroups
    if count == 0 then
        --todo
        return
    end

    panel:removeAllChildren()

    local card = Card:new(0)

    local cardHeight = panel:getSize().height - 10
    local scale = cardHeight / card:getSize().height
    local cardWidth = card:getSize().width * scale

    local width = panel:getSize().width
    local height = panel:getSize().height

    if count == 1 then
        --todo
        local oriX = (width - HANDCARD_SPACE_X - 2 * cardWidth) / 2

        local group = cardGroups[1]

        for i,v in ipairs(group.cards) do
            card = Card:new(v)

            card:setScale(scale)

            local x = oriX + (i - 1) * (cardWidth + HANDCARD_SPACE_X) + cardWidth / 2
            card:setPosition(cc.p(x, height / 2))

            panel:addChild(card)
        end
    else
        local oriX = (width - 2 * HANDCARD_SPACE_X - 2 * cardWidth - cardHeight) / 2

        local group = cardGroups[2]

        for i,v in ipairs(group.cards) do
            card = Card:new(v)

            card:setScale(scale)

            local x = oriX + cardWidth / 2
            card:setPosition(cc.p(x, height / 2))

            panel:addChild(card)

            oriX = oriX + cardWidth + HANDCARD_SPACE_X
        end

        group = cardGroups[1]

        local oriY = (height - HANDCARD_SPACE_Y - 2 * cardWidth) / 2
        local x = oriX + cardHeight / 2
        for i,v in ipairs(group.cards) do
            card = Card:new(v)

            card:setScale(scale)

            card:setRotation(90)

            card:setPosition(cc.p(x, oriY + cardWidth / 2))

            panel:addChild(card)

            oriY = oriY + cardWidth + HANDCARD_SPACE_Y
        end
    end
end

function CardPlaneOperator:showAni4Big(playerType, panel, inhandPanel, cardsGroup)
    local count = #cardsGroup

    local nodeCount = inhandPanel:getChildrenCount()

    if nodeCount == 4 then
        --todo
        if count == 0 then
            UserInfoPlaneOperator:showkaipai(panel,true)
            dump("开牌4--------------------------------------------------------------------")
            -- 别人开牌
            return self:openOtherCards4Ani(inhandPanel, cardsGroup)
        elseif count == 2 then
            -- 清除牌类型的提示文本
            GamePlaneOperator:showCardGroups(false)
            -- 自己开牌动画
            return self:openMyCards4Ani(inhandPanel, cardsGroup)
        end
    elseif nodeCount == 2 then
        if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
            return self:smallOpenMyCards4Ani(inhandPanel)
        else
            UserInfoPlaneOperator:showkaipai(panel,true)
            dump("开牌2--------------------------------------------------------------------")
        end
    end
end

function CardPlaneOperator:showCardsInResult(cards, panel, tag)
    if tag == "left" or tag == "mid" then
        for i=1, 2 do
            dump(panel:getChildrenCount(), "------ CardPlaneOperator:showCardsInResult childrenCount:")
            local card = panel:getChildByTag(i)
            if card then
                card:setCard(cards[i])
            end
        end
    elseif tag == "right" then
        for i=3, 4 do
            local card = panel:getChildByTag(i)
            if card then
                card:setCard(cards[i-2])
            end
        end
    end
end

function CardPlaneOperator:showPromptCards(panel, cardsGroup)
    PJ_CARDS_SELECTED = {}
    GamePlaneOperator:showCardGroups(false)

    local card = Card:new(0)
    local cardHeight = card:getSize().height

    local m = {0, 0}
    for i=1, 4 do
        dump(i, "----- i ------")
        dump(m, "--------- m ---------")
        local card = panel:getChildByTag(i)
        local posY = card:getPositionY()
        local heightOffSet = cardHeight * card:getScale() * 0.2
        local is_select = false
        for k=1, 2 do
            if m[k] == 0 and card.m_value == cardsGroup[k] then
                is_select = true
                m[k] = 1
                break
            end
        end
        if is_select then
            if not card.m_isSelected then
                -- 添加牌选中音效
                SoundUtils:playEffect("选中牌")
                posY = posY + heightOffSet
            end
            card.m_isSelected = true
            table.insert(PJ_CARDS_SELECTED, card.m_value)
        else
            if card.m_isSelected then
                -- 添加牌取消的音效
                SoundUtils:playEffect("取消牌")
                card.m_isSelected = false
                posY = posY - heightOffSet
            end
        end
        card:setPositionY(posY)
    end
    --dump(PJ_CARDS_SELECTED, "-------- PJ_CARDS_SELECTED ---------")
    --dump(cardsGroup, "----------- cardsGroup --------------")
    -- 显示牌型提示
    GamePlaneOperator:showCardGroups(true)
end

function CardPlaneOperator:smallOpenMyCards4Ani(panel)
    local card = Card:new(0)

    local cardHeight = panel:getSize().height - 10
    local scale = cardHeight / card:getSize().height
    local cardWidth = card:getSize().width * scale
    local oriX = (panel:getSize().width - 2*cardWidth - HANDCARD_SPACE_X) / 2
    local oriY = panel:getSize().height / 2
    for i=1, 2 do
        local card  = panel:getChildByTag(i)
        local position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X)*(i - 1) + cardWidth / 2, oriY)
        local ac = cc.MoveTo:create(0.2, position)
        card:runAction(ac)
    end
end

function CardPlaneOperator:showTestCards(cards)
    dump(cards, "CardPlaneOperator:showTestCards")
    -- 加载csb
    local testCsb = cc.CSLoader:createNode(TpackageName .. "/csb/TestScene.csb"):addTo(SCENENOW["scene"])
    testCsb:setScale(1280/1920)
    testCsb:setName("testCards")
    --s:setLocalZOrder(9999)
    local action = cc.CSLoader:createTimeline(TpackageName .. "/csb/TestScene.csb")
    action:retain()
    testCsb:runAction(action)
    action:gotoFrameAndPlay(0,25,false)

    local SELECT_CARDS = {}

    local TEST_CARD_TOUCH_FUNC = function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender.m_isSelected then
                for k, v in pairs(SELECT_CARDS) do
                    if v == sender.m_value then
                        table.remove(SELECT_CARDS, k)
                    end
                end
                --sender:setColor(cc.c3b(255, 255, 255))
                sender:setOpacity(127)
                sender.m_isSelected = false
            else
                if #SELECT_CARDS == PJ_HANDCARD_COUNT then
                    return
                end
                sender.m_isSelected = true
                --sender:setColor(cc.c3b(255, 215, 0))
                sender:setOpacity(255)
                table.insert(SELECT_CARDS, 1, sender.m_value)
            end
        end
    end

    local Panel_1 = testCsb:getChildByName("Panel_1")
    Panel_1:addTouchEventListener(function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            testCsb:removeSelf()
        end
    end)

    local sure_button = Panel_1:getChildByName("sure_button")
    sure_button:addTouchEventListener(function (sender, event)
        if event == TOUCH_EVENT_ENDED then
            PaiJiuSendHandle:CLIENT_TEST_CARDS(SELECT_CARDS)
            testCsb:removeSelf()
        end
    end)

    local testCards = cards
    local cardsCount = #testCards

    local rowCount = math.ceil(cardsCount / COL_COUNT)

    local panel_select = Panel_1:getChildByName("panel_select")
    panel_select:removeAllChildren()

    local card = Card:new(0)
    local panelHeight = panel_select:getSize().height
    local panelWidth = panel_select:getSize().width
    local cardHeight = (panelHeight - (rowCount - 1)*10 -20) / rowCount
    local scaleY = cardHeight / card:getSize().height
    local cardWidth = (panelWidth - (COL_COUNT -1)*50 - 20) / COL_COUNT
    local scaleX = cardWidth / card:getSize().width
    local scale = scaleX
    if scaleX > scaleY then
        scale = scaleY
    end

    local cardWidthScale = card:getSize().width * scale
    local cardHeightScale = card:getSize().height * scale
    dump(scale, " --- 选牌控制缩放因子 ----")
    local oriX = (panelWidth - (COL_COUNT -1)*50 - (COL_COUNT*cardWidthScale)) / 2
    --local oriY = panelHeight - ((panelHeight - (rowCount - 1)*10 - (rowCount*cardHeightScale))/2)
    local oriY = (panelHeight - (rowCount - 1)*10 - (rowCount*cardHeightScale))/2
    dump(oriX, "----- oriX:")
    dump(oriY, "----- oriY")
    local i = 1
    local j = 1

    while #testCards > 0 do
        if i > COL_COUNT then
            i = 1
            j = j + 1
        end

        local value = testCards[1]
        local testCard = Card:new(value)
        testCard:setScale(scale)
        testCard:setOpacity(127)
        local x = oriX + (cardWidthScale + 50) * (i-1) + cardWidth/2
        --local y = oriY - (cardHeightScale + 10) * (j -1) - cardHeight/2
        local y = oriY + (cardHeightScale + 10) * (j -1) + cardHeight/2
        testCard:setPosition(cc.p(x, y))
        testCard:addTouchEventListener(TEST_CARD_TOUCH_FUNC)
        panel_select:addChild(testCard)
        table.remove(testCards, 1)
        i = i + 1
    end

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