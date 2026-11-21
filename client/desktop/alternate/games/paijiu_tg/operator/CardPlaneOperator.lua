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

local HANDCARD_SPACE_X = 10
local HANDCARD_SPACE_Y = 10

local enableTouchCard = false

local COL_COUNT = 8

---------------------------------------------------------------------
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

function CardPlaneOperator:swtichCardBackImg(typeIndex)
    CURRENTCARDBACKINDEX = typeIndex
end

--给自己发牌
function CardPlaneOperator:showCardsOld(playerType, panel, cards)
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

    dump(PJ_AVAI_CARD_GROUPS,"<<----打印!!PJ_AVAI_CARD_GROUPS---->>>")

    local card = Card:new(0)

    local cardHeight = panel:getSize().height - 10
    local scale = cardHeight / card:getSize().height

    local cardHeight2=PAIJIU_GAME_SCENE:getChildByName("player_panel_2"):getChildByName("inhand_panel"):getSize().height - 10
    local scale2 = cardHeight2 / card:getSize().height

    local cardWidth = card:getSize().width * scale

    local y = panel:getSize().height / 2
    local oriX = (panel:getSize().width - cardWidth * count - (count - 1) * HANDCARD_SPACE_X) / 2

    local dtime
    if BANKER_MSG then
        dtime=playerType-BANKER_MSG
    else
        dtime=1
    end
    if dtime==-1 then
        carddelay=4
    elseif dtime==-2 then
        carddelay=3
    elseif dtime==-3 then
        carddelay=2
    else
        carddelay=dtime+1
    end
    
    if count == 4 then
        for i,v in ipairs(cards) do
            local card

            local x = oriX + (cardWidth + HANDCARD_SPACE_X) * (i - 1) + cardWidth / 2

            if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
                --todo
                card = Card:new(0)
                card:setTouchEnabled(false)
                card:setScale(scale2)
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))                  
                --card:setTag(i)
                panel:addChild(card)

                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x,y))--cc.RemoveSelf:create()
                local scaleaction = cc.ScaleTo:create(0.3,scale)
                local moveAndScaleAction = cc.Spawn:create(moveaction,scaleaction)
                local seq = cc.Sequence:create(delayaction,moveAndScaleAction,cc.CallFunc:create(
                    function()
                        if USERS_READY_STATE[USER_INFO["uid"]]==1 then 
                            local ourcard = Card:new(v)
                            enableTouchCard = true
                            ourcard:addTouchEventListener(PJ_CARD_TOUCH_FUNC)
                            ourcard:setScale(scale)
                            ourcard:setPosition(cc.p(x,y))                  
                            ourcard:setTag(i)
                            panel:addChild(ourcard)
                            ourcard:setVisible(false)
    
                            local aniTime = 0.3
                            local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0));
                            ourcard:runAction(to_p1)  
                    
                            local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
                            card:runAction(to_B);
                            card:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100),cc.RemoveSelf:create(),cc.CallFunc:create(
                                function() 
                                    ourcard:setVisible(true) 
                                end)))
                    
                            local de = cc.DelayTime:create(aniTime);
                            local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0));
                            local seqP2 = cc.Sequence:create(de,to_p2,cc.CallFunc:create(
                                function()
                                    -- 显示开牌相关按钮
                                    GamePlaneOperator:showOutCardButtons(true)
                                end
                            ));
                            ourcard:runAction(seqP2);
                        end
                    end
                ))
                card:runAction(seq)
            else
                card=Card:new(v)
                card:setTouchEnabled(false)
                card:setScale(scale) 
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))                                
                card:setTag(i)
                panel:addChild(card)
                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x,y))
                local seq = cc.Sequence:create(delayaction,moveaction)
                card:runAction(seq)
            end
        end
    elseif count == 2 then
        --dump(cards, "-------cards ------------")
        local smallWidthOffset = cardWidth * 0.4
        local smallMyOriX = panel:getSize().width / 2 - smallWidthOffset
        for i,v in ipairs(cards) do
            local card
            local x
            if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
                x = smallMyOriX + smallWidthOffset * (i-1) + cardWidth / 2

                card = Card:new(0)
                card:setTouchEnabled(false)
                card:setScale(scale2)
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))                  
                --card:setTag(i)
                panel:addChild(card)

                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x,y))
                local scaleaction = cc.ScaleTo:create(0.3,scale)
                local moveAndScaleAction = cc.Spawn:create(moveaction,scaleaction)
                local seq = cc.Sequence:create(delayaction,moveAndScaleAction,cc.CallFunc:create(
                    function()
                        local ourcard = Card:new(v)
                        ourcard:setTouchEnabled(false)
                        ourcard:setScale(scale)
                        ourcard:setPosition(cc.p(x,y))                  
                        ourcard:setTag(i)
                        panel:addChild(ourcard)
                        ourcard:setVisible(false)

                        local aniTime = 0.3
                        local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0));
                        ourcard:runAction(to_p1)  
                
                        local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
                        card:runAction(to_B);
                        card:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100),cc.RemoveSelf:create(),cc.CallFunc:create(
                            function() 
                                ourcard:setVisible(true) 
                            end)))
                
                        local de = cc.DelayTime:create(aniTime);
                        local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0));
                        local seqP2 = cc.Sequence:create(de,to_p2,cc.CallFunc:create(
                            function()
                                -- 显示开牌相关按钮
                                GamePlaneOperator:showOutCardButtons(true)
                            end
                        ));
                        ourcard:runAction(seqP2);
                    end
                ))
                card:runAction(seq)
            else
                x = oriX + (cardWidth + HANDCARD_SPACE_X) * (i - 1) + cardWidth / 2

                card = Card:new(v)
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))           
                card:setTouchEnabled(false)
                card:setScale(scale)
                card:setTag(i)
                panel:addChild(card)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x,y))
                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local seq = cc.Sequence:create(delayaction,moveaction)
                card:runAction(seq)
            end
        end
    end
end

--给自己发牌
function CardPlaneOperator:showCards(playerType, panel, cards,isOpenPai)
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

    dump(PJ_AVAI_CARD_GROUPS,"<<----打印!!PJ_AVAI_CARD_GROUPS---->>>")

    local card = Card:new(0)
    local cardHeight = panel:getSize().height - 10
    local scale = cardHeight / card:getSize().height

    local cardHeight2=PAIJIU_GAME_SCENE:getChildByName("player_panel_2"):getChildByName("inhand_panel"):getSize().height - 10
    local scale2 = cardHeight2 / card:getSize().height

    local cardWidth = card:getSize().width * scale

    local y = panel:getSize().height / 2
    local oriX = (panel:getSize().width - cardWidth * count - (count - 1) * HANDCARD_SPACE_X) / 2

    local dtime
    if BANKER_MSG then
        dtime=playerType-BANKER_MSG
    else
        dtime=1
    end
    if dtime==-1 then
        carddelay=4
    elseif dtime==-2 then
        carddelay=3
    elseif dtime==-3 then
        carddelay=2
    else
        carddelay=dtime+1
    end

    if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then --只有前端为1的位置才做搓牌的操作
        self.myHandCards = {}--保留手牌
        self.myHandCardsPos = {}
        self.myHandCardsCuoPaiPos = {}
        if self.panelCardTouch ~= nil and not tolua.isnull(self.panelCardTouch) then
            self.panelCardTouch:removeFromParent()
            self.panelCardTouch = nil
        end
    end

    if count == 4 then
        for i,v in ipairs(cards) do
            local card
            local x = oriX + (cardWidth + HANDCARD_SPACE_X) * (i-1) + cardWidth / 2

            --分成2排的位置
            local t =  (i == 1 or i == 3)  and 2 or 3
            local xPos = (i == 3 or i == 4)  and 15 or 0

            local x1  = 0
            local y1  = 0
            if not isOpenPai then
                x1 = oriX + (cardWidth + HANDCARD_SPACE_X) * (t - 1) + cardWidth / 2 - xPos
                y1 = (i == 3 or i == 4)  and (y-10) or y
            else
                x1 = x
                y1 = y
            end

            if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
                card = Card:new(0)
                card:setTouchEnabled(false)
                card:setScale(scale2)
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))                  
                panel:addChild(card)
                card:setTag(i)
                table.insert(self.myHandCardsPos,cc.p(x,y))

                if USERS_READY_STATE[USER_INFO["uid"]]==1 then 
                    local ourcard = Card:new(v)
                    enableTouchCard = true
                    ourcard:addTouchEventListener(PJ_CARD_TOUCH_FUNC)
                    ourcard:setScale(scale)
                    ourcard:setPosition(cc.p(x1,y1))                  
                    ourcard:setTag(i)
                    panel:addChild(ourcard)
                    ourcard:setVisible(false)
                    table.insert(self.myHandCards,ourcard)
                    table.insert(self.myHandCardsCuoPaiPos,ourcard:getPosition())
                end

                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x1,y1))
                local scaleaction = cc.ScaleTo:create(0.3,scale)
                local moveAndScaleAction = cc.Spawn:create(moveaction,scaleaction)
                local seq = cc.Sequence:create(delayaction,moveAndScaleAction,cc.CallFunc:create(
                    function()
                        if USERS_READY_STATE[USER_INFO["uid"]]==1 then
                            self.myHandCards[i]:setVisible(true)
                            card:removeSelf()
                            if i == 4 then
                               GamePlaneOperator:showOutCardButtons(true)   
                            end

                            --牌发下来的翻牌效果 客户取消。
                            -- local aniTime = 0.3
                            -- local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0))
                            -- self.myHandCards[i]:runAction(to_p1)  
                    
                            -- local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
                            -- card:runAction(to_B);
                            -- card:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100),cc.RemoveSelf:create(),cc.CallFunc:create(
                            --     function() 
                            --         self.myHandCards[i]:setVisible(true) 
                            --     end)))
                    
                            -- local de = cc.DelayTime:create(aniTime);
                            -- local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
                            -- local seqP2 = cc.Sequence:create(de,to_p2,cc.CallFunc:create(
                            --     function()
                            --         -- 显示开牌相关按钮
                            --         GamePlaneOperator:showOutCardButtons(true)
                            --     end
                            -- ));
                            -- self.myHandCards[i]:runAction(seqP2);
                        end
                    end
                ))
                card:runAction(seq)
            else
                card=Card:new(v)
                card:setTouchEnabled(false)
                card:setScale(scale) 
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))                                
                card:setTag(i)
                panel:addChild(card)
                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x,y))
                local seq = cc.Sequence:create(delayaction,moveaction)
                card:runAction(seq)
            end
        end
    elseif count == 2 then
        local smallWidthOffset = -cardWidth * 0.2

        local smallMyOriX = panel:getSize().width / 2 - 0.5*cardWidth
        for i,v in ipairs(cards) do
            local card
            local x

            if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] then
                x = smallMyOriX + smallWidthOffset * (i-1) + cardWidth / 2
                card = Card:new(0)
                card:setTouchEnabled(false)
                card:setScale(scale2)
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))                  
                panel:addChild(card)
                local tempx = panel:getSize().width / 2 - 0.5*cardWidth + (i-1)*(cardWidth+20)
                table.insert(self.myHandCardsPos,cc.p(tempx,y))


                if USERS_READY_STATE[USER_INFO["uid"]]==1 then 
                    local ourcard = Card:new(v)
                    ourcard:setTouchEnabled(false)
                    ourcard:setScale(scale)
                    ourcard:setPosition(cc.p(x,y+(i==2 and -15 or 0)))                  
                    ourcard:setTag(i)
                    panel:addChild(ourcard)
                    ourcard:setVisible(false)
                    table.insert(self.myHandCards,ourcard)
                    table.insert(self.myHandCardsCuoPaiPos,ourcard:getPosition())
                end

                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x,y))
                local scaleaction = cc.ScaleTo:create(0.3,scale)
                local moveAndScaleAction = cc.Spawn:create(moveaction,scaleaction)
                local seq = cc.Sequence:create(delayaction,moveAndScaleAction,cc.CallFunc:create(
                    function()
                        if USERS_READY_STATE[USER_INFO["uid"]]==1 then
                            self.myHandCards[i]:setVisible(true)
                            card:removeSelf()
                            if i == 2 then
                               GamePlaneOperator:showOutCardButtons(true)   
                            end
                        end
                       
                        -- local aniTime = 0.3
                        -- local to_p1 = cc.RotateBy:create(0,cc.vec3(0,90,0));
                        -- self.myHandCards[i]:runAction(to_p1)  
                
                        -- local to_B = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0))
                        -- card:runAction(to_B);
                        -- card:runAction(cc.Sequence:create(cc.DelayTime:create(aniTime-aniTime/100),cc.RemoveSelf:create(),cc.CallFunc:create(
                        --     function() 
                        --         self.myHandCards[i]:setVisible(true) 
                        --     end)))
                
                        -- local de = cc.DelayTime:create(aniTime);
                        -- local to_p2 = cc.RotateBy:create(aniTime,cc.vec3(0,-90,0));
                        -- local seqP2 = cc.Sequence:create(de,to_p2,cc.CallFunc:create(
                        --     function()
                        --         -- 显示开牌相关按钮
                        --         GamePlaneOperator:showOutCardButtons(true)
                        --     end
                        -- ));
                        -- self.myHandCards[i]:runAction(seqP2);
                    end
                ))
                card:runAction(seq)
            else
                x = oriX + (cardWidth + HANDCARD_SPACE_X) * (i - 1) + cardWidth / 2

                card = Card:new(v)
                card:setPosition(panel:convertToNodeSpace(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2)))           
                card:setTouchEnabled(false)
                card:setScale(scale)
                card:setTag(i)
                panel:addChild(card)
                local moveaction=cc.MoveTo:create(0.3,cc.p(x,y))
                local delayaction = cc.DelayTime:create(0.2*carddelay)
                local seq = cc.Sequence:create(delayaction,moveaction)
                card:runAction(seq)
            end
        end
    end

    --牌上添加触摸面板  
    if playerType == PAIJIU_PLAYERTYPE_TABLE[USER_INFO["uid"]] and USERS_READY_STATE[USER_INFO["uid"]]==1 and not isOpenPai then
            dump("-------panelCardTouch--------------")
            self.panelCardTouch = panel:clone()
            self.panelCardTouch:removeAllChildren()
            self.panelCardTouch:setSize(2*(cardWidth+HANDCARD_SPACE_X),cardHeight+50)
            self.panelCardTouch:setTouchEnabled(true)
            self.panelCardTouch:addTo(panel:getParent())
            self.panelCardTouch:setPosition(panel:getPosition())
            self.panelCardTouch:setSwallowTouches(true)
            self.panelCardTouch:setVisible(true)
            self.panelCardTouch:addTouchEventListener(function(sender, event)
                if event == TOUCH_EVENT_BEGAN then

                elseif event == TOUCH_EVENT_ENDED then
                    self:setCardToOriginalPos()
                elseif event == TOUCH_EVENT_MOVED then
                    local touch1 = sender:getTouchBeganPosition()
                    local touch3 = sender:getTouchMovePosition()

                    local difx = touch3.x-touch1.x
                    local dify = touch3.y-touch1.y

                    if count == 4 then 
                        self.myHandCards[3]:setPosition(self.myHandCardsCuoPaiPos[3].x+difx,self.myHandCardsCuoPaiPos[3].y+dify)
                        self.myHandCards[4]:setPosition(self.myHandCardsCuoPaiPos[4].x+difx,self.myHandCardsCuoPaiPos[4].y+dify)
                    else
                        self.myHandCards[2]:setPosition(self.myHandCardsCuoPaiPos[2].x+difx,self.myHandCardsCuoPaiPos[2].y+dify)
                    end

                else
                    self:setCardToOriginalPos()
                end

            end)
    end

end
function CardPlaneOperator:setCardToOriginalPos()
    if self.myHandCards and #self.myHandCards >0 then
        for i,v in ipairs(self.myHandCards) do
            self.myHandCards[i]:setPosition(self.myHandCardsPos[i])
        end
        if self.panelCardTouch then
             self.panelCardTouch:removeFromParent()
            self.panelCardTouch= nil
        end
    end
end

function CardPlaneOperator:openCards(playerType, panel, cardGroups)
    local count = #cardGroups
    if count == 0 then
        --todo
        return
    end

    UserInfoPlaneOperator:showkaipai(panel:getParent(),true)
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

                oriY = oriY + cardWidth + HANDCARD_SPACE_Y
            end
        else
            for i=1, 2 do
                card = Card:new(0)
                card:setScale(scale)
                local x = oriX + cardWidth / 2
                card:setPosition(cc.p(x, height / 2))
                card:setTag(i)
                panel:addChild(card)

                oriX = oriX + cardWidth + HANDCARD_SPACE_X
            end

            local x = oriX + cardHeight / 2
            for i = 3, 4  do
                card = Card:new(0)
                card:setScale(scale)
                card:setRotation(90)
                card:setPosition(cc.p(x, oriY + cardWidth / 2))
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
        dump(#self.myHandCards,"openMyCards4Ani-->>i-->>")
        local card = self.myHandCards[i]
        --panel:getChildByTag(i)

        if not card then
            return
        end

        dump("-----hhhhhhhh------")
        local index = 0

        local isExist = false

        local group = cardGroups[2]
        for _,v in ipairs(group.cards) do
            index = index + 1

            if not m[index] and v == card.m_value then
                --todo
                m[index] = true

                if index < 1 or index > 4 then
                    --todo
                    return
                end

                local position

                if index < 3 then
                    --todo
                    position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * (index - 1) + cardWidth / 2, height / 2)
                else
                    position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * 2 + cardHeight / 2, oriY + (cardWidth + HANDCARD_SPACE_X) * (index - 3) + cardWidth / 2)
                end

                if position then
                    --todo
                    if index < 3 then
                        --todo
                        card:runAction(cc.MoveTo:create(0.2, position))
                    else
                        local ac1 = cc.MoveTo:create(0.2, position)local ac2 
                        if card:getRotation()>0 then
                            ac2= cc.RotateBy:create(0.1, 0)
                        else
                            ac2= cc.RotateBy:create(0.1, 90)
                        end
                        card:runAction(cc.Spawn:create(ac1, ac2))
                    end
                end

                isExist = true

                break
            end
        end

        if not isExist then
            --todo
            group = cardGroups[1]
            for _,v in ipairs(group.cards) do
                index = index + 1

                if not m[index] and v == card.m_value then
                    --todo
                    m[index] = true

                    if index < 1 or index > 4 then
                        --todo
                        return
                    end

                    local position

                    if index < 3 then
                        --todo
                        position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * (index - 1) + cardWidth / 2, height / 2)
                    else
                        position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X) * 2 + cardHeight / 2, oriY + (cardWidth + HANDCARD_SPACE_X) * (index - 3) + cardWidth / 2)
                    end

                    if position then
                        --todo
                        if index < 3 then
                            --todo
                            card:runAction(cc.MoveTo:create(0.2, position))
                        else
                            local ac1 = cc.MoveTo:create(0.2, position)local ac2 
                            if card:getRotation()>0 then
                                ac2= cc.RotateBy:create(0.1, 0)
                            else
                                ac2= cc.RotateBy:create(0.1, 90)
                            end
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
            local ac2 
            if card:getRotation()>0 then
                ac2= cc.RotateBy:create(0.1, 0)
            else
                ac2= cc.RotateBy:create(0.1, 90)
            end
            card:runAction(cc.Spawn:create(ac1, ac2))
        end
    end
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
    dump(count,"count---------->>>")
    local nodeCount = inhandPanel:getChildrenCount()
    dump(nodeCount,"nodeCount---------->>>")
    if nodeCount >= 4 then
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
    -- for i=1, 2 do
    --     local card  = panel:getChildByTag(i)
    --     local position = cc.p(oriX + (cardWidth + HANDCARD_SPACE_X)*(i - 1) + cardWidth / 2, oriY)
    --     local ac = cc.MoveTo:create(0.2, position)
    --     card:runAction(ac)
    -- end
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

function CardPlaneOperator:joinCards(panel,flag)
    if not panel then
        return
    end

    if flag then
        UserInfoPlaneOperator:showkaipai(panel:getParent(),true)
    end

    panel:removeAllChildren()

    local count = CARDCOUNT * 2

    local card = Card:new(0)

    local cardHeight = panel:getSize().height - 10
    local scale = cardHeight / card:getSize().height

    local cardWidth = card:getSize().width * scale
    local height = panel:getSize().height
    local width = panel:getSize().width

    local y = panel:getSize().height / 2
    local oriX = (width - cardWidth * count - (count - 1) * HANDCARD_SPACE_X) / 2
    local oriY = (height - HANDCARD_SPACE_Y - 2 * cardWidth) / 2

    if count == 4 then
        for i=1,count do
            local x = oriX + (cardWidth + HANDCARD_SPACE_X) * (i - 1) + cardWidth / 2

            local card=Card:new(0)
            card:setTouchEnabled(false)
            card:setScale(scale)
            if i>=3 and flag then
                card:setRotation(90)
                x=(cardWidth+HANDCARD_SPACE_X)*3+cardWidth / 2
                card:setPosition(cc.p(x, oriY + cardWidth / 2))
                oriY = oriY + cardWidth + HANDCARD_SPACE_Y
            else
                card:setPosition(cc.p(x,y))  
            end                              
            card:setTag(i)
            panel:addChild(card)
        end
    elseif count == 2 then
        for i=1,count do
            local x= oriX + (cardWidth + HANDCARD_SPACE_X) * (i - 1) + cardWidth / 2

            local card = Card:new(0)
            card:setPosition(cc.p(x,y))
            card:setTouchEnabled(false)
            card:setScale(scale)
            card:setTag(i)
            panel:addChild(card)
        end
    end
end

function CardPlaneOperator:setCardRecover()
    if self.panelCardTouch ~= nil then
        for i,v in ipairs(self.myHandCards) do
            self.myHandCards[i]:setPosition(self.myHandCardsPos[i])
        end
        self.panelCardTouch:removeFromParent()
        self.panelCardTouch= nil
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