local CardPlaneOperator = class("CardPlaneOperator")
local Card = require(TpackageName .. ".PokerCard")
local cardLogic = require(TpackageName .. ".cardLogic")

local cardHeight = 315
local cardWidth = 233
local MyCardScale = 1
local MyOutCardScale = MyCardScale
local OtherCardScale = 1

local MyCardY = 0  --手牌的高度

local MyOutCardY = 150  --出牌的高度

local OtherCardY = 0  --手牌的高度
local OtherOutCardY = 0  --其他人出牌的高度

local MyHandCardInterval
local MyOutCardInterval
local OtherCardInterval
local cardInterval = 109.05
local MyOutCardOffsetY
local actionCount = 0
local SendCardTime = 0.1

local touch_count = 1

-- 1表示左侧对齐， 2表示中间对齐， 3表示右对齐
local PlayersLocationTable  = {}

local Cardtype_Image_Path = {}
local original_pos = {}
local card_panel_position = {}
local card_panel = {}
local card_bg = nil
local localZOrder = 10

----------------------------------------------------------------------

function CardPlaneOperator:init(playerType,plane)
    MyCardScale = SanGongPanel.game_plane.player_plane_1.inhand_plane:getContentSize().height / cardHeight
    OtherCardScale = SanGongPanel.game_plane.player_plane_2.inhand_plane:getContentSize().height / cardHeight

    cardInterval = 109.05
    MyHandCardInterval = 240 *  MyCardScale
    MyOutCardInterval =  240 * MyOutCardScale
    OtherCardInterval =  cardWidth * OtherCardScale
    MyOutCardOffsetY = 100 * MyCardScale
   
    plane:setVisible(true)
    plane:removeAllChildren()
    plane:setVisible(false)
    All_Card_Nodes = {}
    All_Card_Nodes[playerType] = {}

    actionCount = 0

end 

function CardPlaneOperator:clearGameDatas(playerType,plane,stage)
    dump("清除card数据----------------------")
    require(TpackageName .. ".LayerShuffling"):removeScene()
    if All_Card_Nodes and All_Card_Nodes[playerType] then
        for k,node in pairs(All_Card_Nodes[playerType]) do
            if tolua.type(node) then
                node:removeFromParent()
            end
        end
    end
    All_Card_Nodes[playerType] = {}

    plane:stopAllActions()
    plane:removeAllChildren()
    self:hideCardKind(plane:getParent())
    plane:setVisible(false)
    actionCount = 0
end

function CardPlaneOperator:swtichCardBackImg(typeIndex)
    CURRENTCARDBACKINDEX = typeIndex
end

function CardPlaneOperator:showCards(playerType, plane, cards, firstsendcard, isRelogin)

    plane:setVisible(true)
    local IntermediatePointX = plane:getContentSize().width/2
    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2 - 100))
    local actionCount = 0
    if  firstsendcard == true or playerType == 1 then  --首次发牌或者手牌为空 or next(All_Card_Nodes[playerType]) == nil
        All_Card_Nodes[playerType] = {}
        plane:removeAllChildren()
        if isRelogin == true then
            for index,value in ipairs(cards) do
                local target_point_x = IntermediatePointX + (index-(#cards-1))*MyHandCardInterval
                local target_point_y = MyCardY
                local card = Card.new()
                card:setScale(MyCardScale)
                card:addTo(plane)
                card:setPosition(cc.p(target_point_x,target_point_y))
                if  value ~= 0 then
                    card:setCard(value)
                end
                card:showFront()
                table.insert(All_Card_Nodes[playerType],card)
                if g_360.anCard == 1 then
                    if index == 3 then
                        card:showBack()
                    end
                elseif g_360.anCard == 2 then
                    if index ~= 1 then
                        card:showBack()
                    end
                elseif g_360.anCard == 3 then
                    card:showBack()
                end
            end
        else
            dump(All_Card_Nodes[playerType],"All_Card_Nodes[playerType]")
            dump(playerType,"All_Card_Nodes[playerType]==")
            if All_Card_Nodes[playerType] then
                for index,value in ipairs(cards) do
                    actionCount = actionCount + 1
                    plane:performWithDelay(function()
                        local card = Card.new()
                        card:setScale(MyCardScale)
                        card:addTo(plane)
                        card:setPosition(WorldMiddlePosition)
                        if  value ~= 0 then
                            card:setCard(value)
                        end
                        card:showBack()
                        local target_point_x = IntermediatePointX + (index-(#cards-1))*MyHandCardInterval
                        local target_point_y = MyCardY
                        local moveAction = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))
                        local scaleAction = cc.ScaleTo:create(0.15,MyCardScale)
                        local endCallFunc = cc.CallFunc:create(function()
                            local gameConfigTable = json.decode(g_sangongMainScene.gameConfig)
                            -- if  value ~= 0 then
                            --     card:flipCard()
                            -- end
                            if g_360.anCard == 1 then
                                if index == 3 then
                                    card:showBack()
                                else
                                    card:flipCard()
                                end
                            elseif g_360.anCard == 2 then
                                if index ~= 1 then
                                    card:showBack()
                                else
                                    card:flipCard()
                                end
                            elseif g_360.anCard == 3 then
                                card:showBack()
                            end
                            --if gameConfigTable.anSize == 1 then
                            --    if #cards ~= index then
                            --        card:flipCard()
                            --    else
                            --        if g_isWatch ~= 0 then
                            --            self:showCuoPai(nil, true)
                            --        end
                            --    end
                            --end
                        end)
                        local moveAndScaleAction = cc.Spawn:create(moveAction,scaleAction)
                        local delay= cc.DelayTime:create(actionCount * SendCardTime)
                        local se  = cc.Sequence:create(delay,moveAndScaleAction,endCallFunc)
                        card:runAction(se)
                        if All_Card_Nodes[playerType] then
                            table.insert(All_Card_Nodes[playerType],card)
                        end
                    end,actionCount * SendCardTime)
                end
            end
        end
    elseif  firstsendcard == false then
        local liangcardnum = #All_Card_Nodes[playerType]
        for index,value in ipairs(cards) do
            if  index > liangcardnum then
                actionCount = actionCount + 1
                local card = Card.new()
                card:setScale(MyCardScale)
                card:addTo(plane)
                card:setPosition(WorldMiddlePosition)
                if value and value >0 then
                    card:setCard(value)
                end
                card:showBack()
                table.insert(All_Card_Nodes[playerType],card)
                local target_point_x = IntermediatePointX + (index-(#cards-1))*OtherCardInterval
                local target_point_y = MyCardY
                local moveAction = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))
                local scaleAction = cc.ScaleTo:create(0.2,OtherCardScale)
                local moveAndScaleAction = cc.Spawn:create(moveAction,scaleAction)
                local delay= cc.DelayTime:create(actionCount* SendCardTime)
                local se  = cc.Sequence:create(delay,moveAndScaleAction)
                card:runAction(se)
            end
        end
    end
end


function CardPlaneOperator:showCardsBack(plane,callback)

    if SHAICARD then
        plane:setVisible(true)
        local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
        local center_point_x =  WorldMiddlePosition.x
        local center_point_y =  WorldMiddlePosition.y
        local card = Card.new(1):addTo(plane,999999)
        card:setCard(SHAICARD)
      --  card:showBack()

        dump(SHAICARD,"showCardsBack")
        card:setScale(OtherCardScale)
        card:setPosition(cc.p(center_point_x,center_point_y))
        card:flipCard()
        card:retain()
        if CHECK_SCHEDULER_GLOBAL then
            SCHEDULER.unscheduleGlobal(CHECK_SCHEDULER_GLOBAL)
        end
        CHECK_SCHEDULER_GLOBAL =SCHEDULER.performWithDelayGlobal(function ()
            callback()
            if tolua.isnull(card) then
                return
            end
            card:removeSelf()

        end, 1)
    end
end


--其他玩家发牌动画  在其他玩家前面发5张牌。有动画效果
function CardPlaneOperator:showDealCardsAnimation(playerType,plane,cards,cardEndIndex)

    local planeWidth = plane:getContentSize().width
    plane:setVisible(true)
    localZOrder = localZOrder + 10
    plane:setLocalZOrder(88+localZOrder)
    self.isMove = false
    self.index_order = 1
    local playerLocation = 1
    --PlayersLocationTable[playerType] or 2
    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
    local center_point_x =  WorldMiddlePosition.x
    local center_point_y =  WorldMiddlePosition.y


    actionCount = actionCount + 1
    local card = Card.new(1):addTo(plane,cardEndIndex)
    if cards == nil then
        return
    end
    dump(cards[cardEndIndex] ,"cards[cardEndIndex] ")
    if  cards and cards[cardEndIndex] then
        card:setCard(cards[cardEndIndex])
        card:showBack()

    else
        card:showBack()
    end
    local OtherCardScale = plane:getContentSize().height / cardHeight
    local OtherCardInterval =  cardWidth * OtherCardScale
    -- cardWidth * OtherCardScale
    card:setScale(OtherCardScale)
    card:setPosition(cc.p(center_point_x,center_point_y))
    --local target_point_x = planeWidth/2 - (3 - cardEndIndex) * OtherCardInterval +50\

    local target_point_x = planeWidth/2 - (3 - cardEndIndex) * OtherCardInterval +50
    local target_point_y = OtherCardY

    -- local target_point_x = IntermediatePointX + (index-(#cards-1))*MyHandCardInterval
    --if  playerLocation == 3  then
    --    target_point_x = planeWidth - (6 - cardEndIndex) * OtherCardInterval
    --elseif  playerLocation == 1  then
    --    target_point_x = cardEndIndex * cardInterval
    --end
    self.isTouch = true
    touch_count = 1

    --plane:addTouchEventListener(function(sender,event)
    --    if event == TOUCH_EVENT_BEGAN then
    --        self.touc = false
    --    end
    --
    --    --触摸取消
    --    if event == TOUCH_EVENT_CANCELED then
    --        self.touc = true
    --    end
    --    if event == EVENT_TOUCH_MOVED then
    --        self.touc = true
    --    end
    --    print("addTouchEventListeneraddTouchEventListener",self.isMove)
    --    print("addTouchEventListeneraddTouchEventListener",self.touc)
    --
    --    if event == EVENT_TOUCH_ENDED  then
    --        if self.isTouch == false and self.touc == false then
    --            if self.isMove == false  then
    --                print("addTouchEventListeneraddTouchEventListener")
    --                self:restartMoveCard()
    --            end
    --        end
    --
    --    end
    --end)
    local move = cc.MoveTo:create(0.2,cc.p(target_point_x,target_point_y))
    dump(target_point_x,"target_point_x"..cardEndIndex)
    local delay= cc.DelayTime:create(actionCount* SendCardTime)
    local se  = cc.Sequence:create(delay,move,cc.CallFunc:create(function ()
        --plane:performWithDelay(function()
        SoundUtils:playEffect("sendCard",nil)
        if cardEndIndex <3 then
            card:flipCard()
        else
            All_Card_Nodes[playerType] = card
            -- card:showFrontRub()
            -- card.back_v:setVisible(true)
            original_pos[playerType] = card.backBg_:getPosition()
            self.touchLock = true
            self.offset = 1     --[[允许便宜量]]
            plane.playerType = playerType
            card_panel = plane
            card_panel_position[playerType] = plane:getPosition()
            self.touchX = 0
            self.touchY = 0
            self:registerMoved(card.backBg_, playerType)
        end
        --end,actionCount * 0.1)
    end))
    card:runAction(se)

end


function CardPlaneOperator:showAllCards(playerType,plane,cards,cardEndIndex,flag,cardType)
    local planeWidth = plane:getContentSize().width
    plane:setVisible(true)
    self.isMove = false
    self.index_order = 1


    actionCount = actionCount + 1
    local card = Card.new(1):addTo(plane,cardEndIndex)
    dump(cards[cardEndIndex] ,"cards[cardEndIndex] ")
    if  cards and cards[cardEndIndex] then
        -- card:setCard(cards[cardEndIndex])
        card:showBack()

    else
        card:showBack()
    end

    card:setScale(OtherCardScale)

    local target_point_x = planeWidth/2 - (3 - cardEndIndex) * OtherCardInterval +50
    local target_point_y = OtherCardY

    --plane:addTouchEventListener(function(sender,event)
    --    if event == EVENT_TOUCH_BEGAN then
    --        self.touc = false
    --    end
    --    if event == EVENT_TOUCH_MOVED then
    --        self.touc = true
    --    end
    --    if event == TOUCH_EVENT_ENDED then
    --        print("addTouchEventListeneraddTouchEventListener",self.isMove)
    --        print("addTouchEventListeneraddTouchEventListener",self.touc)
    --        if self.isMove == false and self.touc == false then
    --            print("addTouchEventListeneraddTouchEventListener")
    --            self:restartMoveCard()
    --        end
    --    end
    --end)
    self.isTouch = true
    card:setPosition(cc.p(target_point_x,target_point_y))
    if cardEndIndex <3 then
        card:flipCard()
    else
        if flag == false or flag == nil then
            All_Card_Nodes[playerType] = card
            -- card:showFrontRub()
            -- card.back_v:setVisible(true)
            original_pos[playerType] = card.backBg_:getPosition()
            self.touchLock = true
            self.offset = 1     --[[允许便宜量]]
            plane.playerType = playerType
            card_panel = plane
            card_panel_position[playerType] = plane:getPosition()
            self.touchX = 0
            self.touchY = 0
            self:registerMoved(card.backBg_, playerType)
        else
            card:flipCard()
            --if cardType.print then
            --    self:showCardKind(playerType,plane,cardType.point,cardType.type,true)
            --end
        end
    end

end

function CardPlaneOperator:restartMoveCard()
    if self.isTouch == false then
        if self.isMove == false then
            local parent =  card_panel:getParent()
            local WorldMiddlePosition = card_panel:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
            local center_point_x =  WorldMiddlePosition.x
            local center_point_y =  WorldMiddlePosition.y
            local move = cc.MoveTo:create(0.4,cc.p(card_panel_position[card_panel.playerType].x, card_panel_position[card_panel.playerType].y))
            local callback = cc.CallFunc:create(function()
                self.isTouch = true
            end)
            card_panel:setScale(1)
            local se  = cc.Sequence:create(move,callback)
            card_panel:runAction(se)
            local zhezhao = parent:getChildByName("zhezhao")
            if zhezhao then
                zhezhao:removeSelf()
            end
            card_bg:setPosition(cc.p(original_pos[card_panel.playerType].x, original_pos[card_panel.playerType].y))
        else
            if CHECK_SCHEDULER_GLOBAL then
                SCHEDULER.unscheduleGlobal(CHECK_SCHEDULER_GLOBAL)
            end
            CHECK_SCHEDULER_GLOBAL = SCHEDULER.performWithDelayGlobal(function ()
                local parent =  card_panel:getParent()
                card_panel:setScale(1)
                local WorldMiddlePosition = card_panel:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
                local center_point_x =  WorldMiddlePosition.x
                local center_point_y =  WorldMiddlePosition.y
                local move = cc.MoveTo:create(0.4,cc.p(card_panel_position[card_panel.playerType].x, card_panel_position[card_panel.playerType].y))
                local callback = cc.CallFunc:create(function()
                    self.isTouch = true
                end)
                local se  = cc.Sequence:create(move,callback)
                card_panel:runAction(se)
                local zhezhao = parent:getChildByName("zhezhao")
                if zhezhao then
                    zhezhao:removeSelf()
                end
                card_bg:setPosition(cc.p(original_pos[card_panel.playerType].x, original_pos[card_panel.playerType].y))
            end,0.4)
        end

    end
end


function CardPlaneOperator:clearCardPlane(playerType,plane)
    plane:removeAllChildren()
    All_Card_Nodes = {}
    All_Card_Nodes[playerType] = {}
    self:hideCardKind(plane:getParent())

end
--三公牌型
function CardPlaneOperator:hideCardKind(plane)
    plane.state:hide()
end
--显示三公牌型
function CardPlaneOperator:showCardKind(playerType,plane,cardKind,type,isSound)
    -- SCT_NONE = 0, @type
    -- SCT_SHUANG_GONG,//双公
    -- SCT_SAN_GONG,//三公
    -- SCT_BAO_ZI,//豹子
   
   
    if isSound == nil then
        SoundUtils:playCardKindEffect(cardKind,USER_INFO["sex"],type)
    end
    if type == 1 then
        cardKind = "1_"..cardKind
    elseif type == 2 then
        cardKind = 10
    elseif type == 3 then
        cardKind = 11
    end
    plane.state:show()
    plane.state.card_type:loadTexture("sangong/csb/player_plane/type/type_"..cardKind..".png")
    ViewBase:setTextureSize(plane.state.card_type)

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
    local cardNodes = All_Card_Nodes[playerType]
    if cardNodes and cards then    --setCard方法存在且牌为背面
        for i,value in ipairs(cards) do

            local cardNode = All_Card_Nodes[playerType][i]

            if cardNode then
                -- cardNode:stopAllActions()
            else
                cardNode = Card.new():addTo(plane)
            end
            if cardNode:isBack() then
                cardNode:setCard(value)
                cardNode:flipCard()
            end
            
        end
    end

end

function CardPlaneOperator:turnCards(plane)
    dump(MY_CARDS)
    if All_Card_Nodes and All_Card_Nodes[CARD_PLAYERTYPE_MY] then
        for i,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
            if  cardNode:isBack() then
                cardNode:setCard(MY_CARDS[i])
                cardNode:flipCard()
            end
        end
    end
    
end

function CardPlaneOperator:countFanAndShow(plane)
    
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

    GamePlaneOperator:showCardKind(CARD_PLAYERTYPE_MY,fan)
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

    dump(backCardNum,"showCuoPai-backCardNum")
    local cards = MY_CARDS
    if backCardNum == 1 then
        local cardUint = cards[backCardsIndexs[1]]
        local cuopaiType = cc.UserDefault:getInstance():getIntegerForKey("cuopaiType_"..USER_INFO.level)
        dump(cuopaiType,"cuopaiType")
        if cuopaiType==0 then
            require(TpackageName .. '.LayerShuffling').new(cardUint)
        else
            require(TpackageName .. '.LayerShuffling'..cuopaiType).new(cardUint)
        end
        return
    end

    if true then
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
function CardPlaneOperator:registerMoved(backBg,playerType)
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()  --获取事件绑定的目标
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        --if self.isTouch == false then
        --    self.touchLock = true
        --end
        if cc.rectContainsPoint(rect, locationInNode) then
            print("WorldMiddlePosition  onTouchBegan")
            self.touchLock = true
            self.touchX = 0
            self.touchY = 0
            card_bg = target
            card_panel = target:getParent():getParent()
            return true
        end
        return false
    end
    local function onTouchMoved (touch,event)
        --self.touchLock = false
        local target = event:getCurrentTarget()  --获取事件绑定的目标
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0,0, s.width, s.height) --设置点击的区域
        print("touch:getDelta()",touch:getDelta())
        local prevX = target:getPositionX()+touch:getDelta().x
        local prevY = target:getPositionY()+touch:getDelta().y

        self.touchX = self.touchX +touch:getDelta().x
        self.touchY = self.touchY +touch:getDelta().y
        if self.touchX ~= 0 or self.touchY ~= 0 then
            self.touchLock = false
        else
            self.touchLock = true
        end

        if  self.isTouch == false then
            target:setPosition(cc.p(prevX,prevY));
        end
        return true
    end

    local function onTouchEnded(touch, event)
        --print("WorldMiddlePosition  onTouchEnded")
        --print("WorldMiddlePosition  onTouchEnded touchLock",self.touchLock)
        --print("WorldMiddlePosition  onTouchEnded GAME_STATE",GAME_STATE)
        --print("WorldMiddlePosition  onTouchEnded isMove",self.isMove )
        if self.touchLock == true and GAME_STATE == GAME_STATUS_OUT_CARD  and self.isMove == false then
            self.isMove = true  --[[移动时是否触发点击事件]]
            local target = event:getCurrentTarget()  --获取事件绑定的目标
            local panel = target:getParent():getParent()
            local parent =  panel:getParent()
            self.index_order = self.index_order +10
            local zhezhao = parent:getChildByName("zhezhao")
            parent:setLocalZOrder(88 + self.index_order)
            self.isTouch = true
            --- target:setPosition(cc.p(original_pos[playerType].x, original_pos[playerType].y))
            panel:setScale(1)
            if zhezhao then

                local WorldMiddlePosition2 = target:getParent():getParent():convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
                local center_point_x2 =  WorldMiddlePosition2.x
                local center_point_y2 =  WorldMiddlePosition2.y

                local move = cc.MoveTo:create(0.4,cc.p(card_panel_position[card_panel.playerType].x, card_panel_position[card_panel.playerType].y))
                local callback = cc.CallFunc:create(function()
                    self.isMove = false
                end)
                local se  = cc.Sequence:create(move,callback)
                panel:runAction(se)

                if zhezhao then
                    zhezhao:removeSelf()
                end
               card_bg:setPosition(cc.p(original_pos[card_panel.playerType].x, original_pos[card_panel.playerType].y))
            else
                self.isTouch = false
                local node = ccui.Layout:create()
                -- cc.Layer:create()
                node:setName("zhezhao")
                node:addTo(parent,0)
                node:setAnchorPoint(0.5,0.5)
                node:setBackGroundColorType(LAYOUT_COLOR_NONE);
                node:setBackGroundColor(cc.c4b(0,0,0,110));
                local WorldMiddlePosition = parent:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
                local center_point_x =  WorldMiddlePosition.x
                local center_point_y =  WorldMiddlePosition.y
                node:setContentSize(1920,1280)
                node:setPosition(cc.p(center_point_x,center_point_y))
                node:setTouchEnabled(true)
                dump(WorldMiddlePosition,"WorldMiddlePosition")
                --WorldMiddlePosition = node:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
                --center_point_x =  WorldMiddlePosition.x
                --center_point_y =  WorldMiddlePosition.y
                local layer = cc.LayerColor:create(cc.c4b(0,0,0,110))
                layer:setPosition(cc.p(0, 0))
                layer:setContentSize(1920,1280)
                layer:addTo(node)
                local WorldMiddlePosition2 = target:getParent():getParent():convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
                local center_point_x2 =  WorldMiddlePosition2.x
                local center_point_y2 =  WorldMiddlePosition2.y
                self.isMove = true
                local move = cc.MoveTo:create(0.4,cc.p(center_point_x2, center_point_y2))
                local callback = cc.CallFunc:create(function()
                    panel:setScale(4)
                    self.isMove = false
                end)
                local se  = cc.Sequence:create(move,callback)
                panel:runAction(se)

            end
            return true
        else
            return false
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()  --依次一个一个的执行
    --local listener = cc.EventListenerTouchAllAtOnce:create()  --依次一个一个的执行
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,backBg);

end
function CardPlaneOperator:showRubCard(card_rub,playerType, panel)
    dump(playerType, "showRubCard")
    local function onTouchBegan(touch, event)
        self.touchLock = true
        local target = event:getCurrentTarget()  --获取事件绑定的目标
        dump(target:getPosition(),"onTouchBegan")
        dump(touch:getDelta(),"onTouchBegan2")
        return true
    end
    local function onTouchMoved (sender,event)
        dump(sender:getStartLocation().x,"getStartLocation")
        dump(sender:getLocation().x,"getLocation")
        self.touchLock = false
        local target = event:getCurrentTarget()  --获取事件绑定的目标
        local locationInNode = target:convertToNodeSpace(sender:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0,0, s.width, s.height) --设置点击的区域
        dump(target:getPosition(),"移动")
        dump(sender:getDelta(),"移动2")
        local posX = card_rub:getPositionX()
        local posY = card_rub:getPositionY()
        local delta = sender:getDelta()
        dump(target.playerType,"sender.playerType")
       -- card_rub:setPosition(cc.p(posX + delta.x, posY + delta.y))
        if target.playerType == playerType then
            card_rub:setPosition(cc.p(target:getPositionX()+sender:getDelta().x,target:getPositionY()+sender:getDelta().y));
           -- return true
        else
           -- return false
        end
        return true
    end

    local function onTouchEnded(touch, event)
        dump(111,"onTouchEnded")
        dump(self.touchLock,"onTouchEndedtttt")
        --if self.touchLock then
        --    local target = event:getCurrentTarget()  --获取事件绑定的目标
        --    local locationInNode = target:convertToNodeSpace(touch:getLocation())
        --    local s = target:getContentSize()
        --    local rect = cc.rect(0,0, s.width, s.height) --设置点击的区域
        --    if cc.rectContainsPoint(rect, locationInNode) then
        --        dump("ggdsgdfgdfgdfgdfgdfgd")
        --        original_pos = panel:getPosition()
        --        local WorldMiddlePosition = panel:convertToNodeSpace(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
        --        local center_point_x =  WorldMiddlePosition.x
        --        local center_point_y =  WorldMiddlePosition.y
        --        local move = cc.MoveTo:create(0.4,cc.p(center_point_x, center_point_y))
        --        panel:runAction(move)
        --    end
        --end
        return true
    end
    --card_rub:removeAllEventListeners();
    local listener = cc.EventListenerTouchOneByOne:create()  --依次一个一个的执行
    --local listener = cc.EventListenerTouchAllAtOnce:create()  --依次一个一个的执行
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
    --eventDispatcher:removeAllEventListeners()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,card_rub);

end
function CardPlaneOperator:onTouchMovedRub(touch,event)

end
function CardPlaneOperator:addRubCard(playerType, panel)

end

--重连回来直接开牌
function CardPlaneOperator:showOpenCards(inhand_plane)
   local chis = inhand_plane:getChildren()
   for idx,node in ipairs(chis) do
       node:showFront()
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