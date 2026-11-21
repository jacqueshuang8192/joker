local CardPlaneOperator = class('CardPlaneOperator')
local Card = require(TpackageName .. '.PokerCard')
local cardLogic = require(TpackageName .. '.cardLogic')
local pai_path = TpackageName .. '/csb/PokerCard/'

local All_Card_Nodes = {}

local MyCardScale = 1
local MyOutCardScale = MyCardScale
-- local OtherCardScale = 0.44444444444444
local OtherCardScale = 1

local MyCardY = 0 --手牌的高度

local MyOutCardY = 150 --出牌的高度

local OtherCardY = 0 --手牌的高度
local OtherOutCardY = 0 --其他人出牌的高度

local MyHandCardInterval
local MyOutCardInterval
local OtherCardInterval
local MyOutCardOffsetY

local SendCardTime = 0.015
local SendCardMoveToTime = 0.2

-- 1表示左侧对齐， 2表示中间对齐， 3表示右对齐
local PlayersLocationTable = {}
----------------------------------------------------------------------
function CardPlaneOperator:setTextureSize(node, maxWidth, maxHeight, isMin)
    local size = {}
    if node and node.font_pai_ and node.font_pai_.big_card_kong_1 then
        size = node.font_pai_.big_card_kong_1:getContentSize()
    elseif node and node.backBg_ then
        size = node.backBg_:getContentSize()
    else
        return
    end
    local scaleX = 1
    local scaleY = 1
    local scale = 1
    if maxWidth and (size.width > maxWidth or isMin) then
        scaleX = maxWidth / size.width
    end
    if maxHeight and (size.height > maxHeight or isMin) then
        scaleY = maxHeight / size.height
    end
    if scaleX < scaleY then
        scale = scaleX
    else
        scale = scaleY
    end
end

function CardPlaneOperator:init(playerType, plane)
    if TOTAL_PLAYERNUM == 6 then
        OtherCardScale = 0.8
    elseif TOTAL_PLAYERNUM == 8 then
        OtherCardScale = 0.8
    else
        OtherCardScale = 0.8
    end

    local CARD_HEIGHT = 315
    OtherCardScale = plane:getContentSize().height / CARD_HEIGHT
    MyHandCardInterval = 155 * MyCardScale
    MyOutCardInterval = 155 * MyOutCardScale
    OtherCardInterval = 100 * OtherCardScale
    MyOutCardOffsetY = 100 * MyCardScale

    PlayersLocationTable = {
        [CARD_PLAYERTYPE_MY] = 2,
        [CARD_PLAYERTYPE_LEFT1] = 1,
        [CARD_PLAYERTYPE_LEFT2] = 1,
        [CARD_PLAYERTYPE_LEFT3] = 1,
        [CARD_PLAYERTYPE_TOP1] = 1,
        [CARD_PLAYERTYPE_TOP2] = 2,
        [CARD_PLAYERTYPE_TOP3] = 3,
        [CARD_PLAYERTYPE_RIGHT1] = 3,
        [CARD_PLAYERTYPE_RIGHT2] = 3,
        [CARD_PLAYERTYPE_RIGHT3] = 3
    }

    plane:setVisible(true)
    plane:removeAllChildren()
    All_Card_Nodes[playerType] = {}
    self.niuniu_tip = NIUNIU_GAME_SCENE:getChildByName('niuniu_tip')
end

function CardPlaneOperator:clearGameDatas(playerType, plane, stage)
    if stage == 1 then
        require(TpackageName .. '.LayerShuffling'):removeScene()
    elseif stage == 2 or stage == nil then
        plane:stopAllActions()
        plane:removeAllChildren()
        All_Card_Nodes[playerType] = {}
    end
end

-- function CardPlaneOperator:dealFirstCards(playerType,plane,cards,isRelogin)
-- end

-- function CardPlaneOperator:dealSecondCards(playerType,plane,cards,isRelogin)
-- end

--给自己发牌
function CardPlaneOperator:showCards(playerType, plane, cards, firstsendcard, isRelogin)
    local IntermediatePointX = plane:getContentSize().width / 2
    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 100))
    local actionCount = 0

    if firstsendcard == true then --首次发牌或者手牌为空 or next(All_Card_Nodes[playerType]) == nil
        All_Card_Nodes[playerType] = {}
        plane:removeAllChildren()

        if isRelogin == true then
            for index, value in ipairs(cards) do
                if GAME_TYPE == 5 or value ~= 0 then
                    local oldValue = value
                    if GAME_TYPE == 5 and value == 0 then
                        value = 1
                    end
                    local target_point_x = IntermediatePointX + (index - 3) * MyHandCardInterval
                    local target_point_y = MyCardY

                    local card = Card.new()
                    card:setScale(MyCardScale)
                    card:addTo(plane)
                    card:setPosition(cc.p(target_point_x, target_point_y))
                    card:setCard(value)
                    table.insert(All_Card_Nodes[playerType], card)
                    self:setTextureSize(card, nil, plane:getContentSize().height, true)
                end
            end
        else
            for index, value in ipairs(cards) do
                -- if GAME_TYPE == 5 then

                -- end
                local oldValue = value
                if GAME_TYPE == 5 or value ~= 0 then
                    actionCount = actionCount + 1
                    if GAME_TYPE == 5 and value == 0 then
                        value = 1
                    end
                    -- plane:performWithDelay(function()

                    local card = Card.new()
                    card:setScale(OtherCardScale)
                    card:addTo(plane)
                    card:setPosition(WorldMiddlePosition)

                    card:setCard(value)
                    card:showBack()
                    self:setTextureSize(card, nil, plane:getContentSize().height, true)

                    local target_point_x = IntermediatePointX + (index - 3) * MyHandCardInterval
                    local target_point_y = MyCardY

                    local moveAction = cc.MoveTo:create(SendCardMoveToTime, cc.p(target_point_x, target_point_y))
                    local scaleAction = cc.ScaleTo:create(0.1, MyCardScale)

                    local endCallFunc =
                        cc.CallFunc:create(
                        function()
                            -- card:flipCard()
                            card:showFront()
                        end
                    )

                    if GAME_TYPE == 5 and oldValue == 0 then
                        endCallFunc =
                            cc.CallFunc:create(
                            function()
                            end
                        )
                    end

                    local moveAndScaleAction = cc.Spawn:create(moveAction, scaleAction)
                    local delay = cc.DelayTime:create(actionCount * SendCardTime)
                    local se = cc.Sequence:create(delay, moveAndScaleAction, endCallFunc)
                    card:runAction(se)

                    table.insert(All_Card_Nodes[playerType], card)
                end
            end
        end
    elseif firstsendcard == false then
        local liangcardnum = #All_Card_Nodes[playerType]
        if GAME_TYPE == 5 then
            for i, v in ipairs(All_Card_Nodes[playerType]) do
                if v.isBack_ and i < 5 then
                    v:setCard(cards[i])
                    v:flipCard()
                elseif v.isBack_ and i == 5 then
                    v:setCard(cards[i])
                    v:showBack()
                    -- self:showCuoPai(nil, true)
                end
            end
        else
            for index, value in ipairs(cards) do
                if index > liangcardnum then
                    actionCount = actionCount + 1

                    local card = Card.new()
                    card:setScale(OtherCardScale)
                    card:addTo(plane)
                    card:setPosition(WorldMiddlePosition)
                    card:setCard(value)
                    card:showBack()
                    -- card:setFilpEvent(value,All_Card_Nodes[playerType])
                    table.insert(All_Card_Nodes[playerType], card)
                    self:setTextureSize(card, nil, plane:getContentSize().height, true)

                    local target_point_x = IntermediatePointX + (index - 3) * MyHandCardInterval
                    local target_point_y = MyCardY

                    local moveAction = cc.MoveTo:create(SendCardMoveToTime, cc.p(target_point_x, target_point_y))
                    local scaleAction = cc.ScaleTo:create(0.1, MyCardScale)

                    local moveAndScaleAction = cc.Spawn:create(moveAction, scaleAction)
                    local delay = cc.DelayTime:create(actionCount * SendCardTime)
                    local se = cc.Sequence:create(delay, moveAndScaleAction)

                    card:runAction(se)
                end
            end
        end
    end
end

--其他玩家发牌动画  在其他玩家前面发5张牌。有动画效果
function CardPlaneOperator:showDealCardsAnimation(playerType, plane, cards, cardEndIndex, isRelogin, cardState)
    --牛牛发牌特效
    All_Card_Nodes[playerType] = All_Card_Nodes[playerType] or {}

    local cardBeginIndex = #All_Card_Nodes[playerType] + 1

    if cardBeginIndex == 1 then
        SoundUtils:playEffect('dealCards')
    else
        SoundUtils:playEffect('dealCards_short')
    end

    local planeWidth = plane:getContentSize().width

    local cardScale = OtherCardScale
    local cardInterval = OtherCardInterval

    if playerType == CARD_PLAYERTYPE_MY then
        cardScale = MyOutCardScale
        cardInterval = MyOutCardInterval
    end

    local playerLocation = 2 --PlayersLocationTable[playerType] or 2
    local WorldMiddlePosition = plane:convertToNodeSpace(cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 100))
    local center_point_x = WorldMiddlePosition.x
    local center_point_y = WorldMiddlePosition.y

    local actionCount = 0

    if cards then
        cardBeginIndex = 1
        plane:removeAllChildren()
        All_Card_Nodes[playerType] = {}
    end

    if isRelogin == true then
        cardBeginIndex = 1
        cardEndIndex = cardEndIndex
        plane:removeAllChildren()
        All_Card_Nodes[playerType] = {}

        --dump(cardEndIndex, '重连状态下发牌')

        for i = cardBeginIndex, cardEndIndex do
            local card = Card.new():addTo(plane, i)

            if cards and cards[i] then
                card:setCard(cards[i])
                if cardState == 'cover' then
                    card:showBack()
                else
                    card:showFront()
                end
            else
                card:showBack()
            end

            if playerLocation == 3 then
                target_point_x = planeWidth - (6 - i) * cardInterval
            elseif playerLocation == 1 then
                target_point_x = i * OtherCardInterval
            end

            local target_point_x = planeWidth / 2 - (3 - i) * cardInterval
            local target_point_y = OtherCardY

            card:setScale(cardScale)
            card:setPosition(cc.p(target_point_x, target_point_y))
            self:setTextureSize(card, nil, plane:getContentSize().height, true)

            table.insert(All_Card_Nodes[playerType], card)
        end
    else
        for i = cardBeginIndex, cardEndIndex do
            actionCount = actionCount + 1

            local card = Card.new():addTo(plane, i)

            if cards and cards[i] then
                card:setCard(cards[i])
                if cardState == 'cover' then
                    card:showBack()
                else
                    card:showFront()
                end
            else
                card:showBack()
            end

            card:setScale(cardScale)
            card:setPosition(cc.p(center_point_x, center_point_y))
            self:setTextureSize(card, nil, plane:getContentSize().height)

            local target_point_x = planeWidth / 2 - (3 - i) * cardInterval
            local target_point_y = OtherCardY

            if playerLocation == 3 then
                target_point_x = planeWidth - (6 - i) * cardInterval
            elseif playerLocation == 1 then
                target_point_x = i * OtherCardInterval
            end

            local move = cc.MoveTo:create(SendCardMoveToTime, cc.p(target_point_x, target_point_y))
            local delay = cc.DelayTime:create(actionCount * SendCardTime)
            local se = cc.Sequence:create(delay, move)
            card:runAction(se)
            table.insert(All_Card_Nodes[playerType], card)
        end
    end
end

function CardPlaneOperator:openCards(playerType, plane)
    for _, cardNode in ipairs(All_Card_Nodes[playerType]) do
        if cardNode and cardNode:hasValue() == true then
            cardNode:showFront()
        end
    end
end

--显示牛牛牌型
function CardPlaneOperator:showCardKind(playerType, plane, cardKind)
    if cardKind < 1 then
        return
    end

    local cardKind_imgPath = CARDTYPE_IMAGE_PATH[cardKind] ---牛的类型,比如：牛一，牛二......

    local old_niu_tips = plane:getChildByName('niuniu_tip')
    if old_niu_tips then
        old_niu_tips:removeFromParent()
    end

    local cardKindScale = OtherCardScale / MyCardScale
    -- local cardKindScale = 0.8

    local x = plane:getContentSize().width / 2
    local y = 40 * cardKindScale --MyOutCardOffsetY

    if playerType == CARD_PLAYERTYPE_MY then
        y = MyOutCardOffsetY
        cardKindScale = 1
    end
    local height = plane:getContentSize().height
    local niuniu_tip = cc.CSLoader:createNode(TpackageName .. '/csb/CardType/CardType.csb'):addTo(plane, 100) -- self.niuniu_tip:clone()
    -- niuniu_tip:setAnchorPoint(cc.p(0.5, 0))
    niuniu_tip:setPosition(cc.p(x, height * 0.4))
    niuniu_tip:setName('niuniu_tip')

    local niuniu_txt = niuniu_tip:getChildByName('niuniu_txt')
    niuniu_txt:setPositionX(0):ignoreContentAdaptWithSize(true)
    niuniu_txt:loadTexture(cardKind_imgPath, 1)

    local card_type_times_txt = niuniu_tip:getChildByName('card_type_times_txt')
    card_type_times_txt:setVisible(false)

    local scaleAcTime = 0.2

    -- for i = 1,6 do
    --     local star = niuniu_tip:getChildByName("star_"..i)
    --     star:setOpacity(0)
    -- end

    local niuniu_txt_pos = -24
    if cardKind == 1 then
        -- niuniu_tip:setScale(cardKindScale)
    elseif cardKind > 1 and NIUNIU_CARDTYPE_TABLE[cardKind] ~= nil then
        -- niuniu_tip:setScale(0.1)
        local cardTypeTimes = NIUNIU_CARDTYPE_TABLE[cardKind]

        --     -- local ps = cc.ParticleExplosion:createWithTotalParticles(10)    --设置粒子数
        --     local ps = cc.ParticleExplosion:create()    --爆炸效果
        --     ps:setAutoRemoveOnFinish(true)              --设置播放完毕之后自动释放内存
        --     ps:setPosition(cc.p(300,500))

        --     niuniu_tip:addChild(ps, 102)
        --     ps:setDuration(0.02)

        --         local particleSystem = cc.ParticleFlower:create();
        --         particleSystem:setPosition(cc.p(0,0))
        --         niuniu_tip:addChild(particleSystem);

        -- local emitter1 = cc.ParticleSystemQuad:create(TpackageName .. "/images/Desktop.plist")
        -- emitter1:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存
        --    emitter1:setColor(cc.c4b(128, 128, 128, 255))
        -- emitter1:setPosition(cc.p(0, 0)):addTo(niuniu_tip)

        if cardTypeTimes > 1 then
            niuniu_txt:setPositionX(niuniu_txt_pos)
            local isSkip = string.find(g_mainScene.gameConfigTable.gaoji or '', '7')
            card_type_times_txt:setVisible(not isSkip)
            card_type_times_txt:setPositionX(niuniu_txt_pos + niuniu_txt:getContentSize().width / 2)
            card_type_times_txt:setString('x' .. cardTypeTimes)
            if cardKind >= 11 then
                card_type_times_txt:setFntFile(TpackageName .. '/font/cardType_red.fnt')
                --    card_type_times_txt:setScale(1.4)
                if cardKind == 11 then
                    card_type_times_txt:setPositionX(niuniu_txt_pos + niuniu_txt:getContentSize().width / 2 - 40)
                end
            end
        end

        niuniu_tip:runAction(
            cc.Sequence:create(
                cc.EaseSineOut:create(cc.ScaleTo:create(0.15, cardKindScale + 0.7)),
                cc.ScaleTo:create(0.05, cardKindScale - 0.2),
                cc.ScaleTo:create(0.05, cardKindScale)
            )
        )

        NIUNIU_SCENE:performWithDelay(
            function()
                if tolua.isnull(niuniu_tip) then
                    return
                end

                local stars = {}
                -- for i = 1,6 do
                --     local star = niuniu_tip:getChildByName("star_"..i)
                --     stars[i] = star
                --     star:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.2,180)))
                -- end

                local fadeTime = 0.8

                local callFunc1 =
                    cc.CallFunc:create(
                    function()
                        plane:stopAllActions()
                        -- for i = 1,6 do
                        --     if tolua.isnull(stars[i]) == false then
                        --         if i < 4 then
                        --             stars[i]:fadeIn(fadeTime)
                        --         else
                        --             stars[i]:fadeOut(fadeTime)
                        --         end
                        --     else
                        --         plane:stopAllActions()
                        --     end
                        -- end
                    end
                )

                local callFunc2 =
                    cc.CallFunc:create(
                    function()
                        plane:stopAllActions()
                        -- for i = 1,6 do
                        --         if tolua.isnull(stars[i]) == false then
                        --             if  i < 4 then
                        --                 stars[i]:fadeOut(fadeTime)
                        --             else
                        --                 stars[i]:fadeIn(fadeTime)
                        --             end
                        --         else
                        --             plane:stopAllActions()
                        --         end
                        --     end
                    end
                )

                plane:runAction(
                    cc.RepeatForever:create(
                        cc.Sequence:create(
                            callFunc1,
                            cc.DelayTime:create(fadeTime),
                            callFunc2,
                            cc.DelayTime:create(fadeTime)
                        )
                    )
                )
            end,
            scaleAcTime
        )
    else
        -- niuniu_tip:setScale(cardKindScale*1.5)
    end
    niuniu_tip:setScale(cardKindScale * 2)
    -- dump(cardKindScale)
end

function CardPlaneOperator:foldCard(playerType, plane, cards)
    if playerType ~= CARD_PLAYERTYPE_MY then
        for key, value in pairs(cards) do
            if All_Card_Nodes[playerType][key] then
                local cardNode = All_Card_Nodes[playerType][key]

                if cardNode.setCard and cardNode.isBack_ then --setCard方法存在且牌为背面
                    cardNode:setCard(value)
                    cardNode:showBack()
                end
            end
        end
    else
        local planeWidth = plane:getContentSize().width
        local target_point_y = MyOutCardY

        for i, cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
            local target_point_x = planeWidth / 2 - (3 - i) * MyOutCardInterval
            local value = cards[i]
            self:setTextureSize(cardNode, nil, plane:getContentSize().height, true)
            cardNode:setCard(value)
            cardNode:setTouchEnabled(false)
            cardNode:stopAllActions()
            cardNode:setScale(MyOutCardScale)
            cardNode:showFront()
            -- cardNode:setPosition(cc.p(target_point_x,target_point_y))
        end
    end
end

function CardPlaneOperator:outCard(playerType, plane, cards, cardValue)
    local planeWidth = plane:getContentSize().width
    local cardInterval
    local y = 0

    local scale = OtherCardScale
    if playerType == CARD_PLAYERTYPE_MY then
        cardInterval = MyOutCardInterval
        scale = MyOutCardScale
    else
        cardInterval = OtherCardInterval
    end

    if cards then
        for i, value in ipairs(cards) do
            if All_Card_Nodes[playerType] then
                local cardNode = All_Card_Nodes[playerType][i]

                if cardNode then
                    cardNode:stopAllActions()
                    cardNode:setScale(scale)
                else
                    cardNode = Card.new():addTo(plane, key)
                end

                cardNode:setCard(value)
            end
        end

        local outcards, fan = cardLogic:getallfans(cards)
        local bestOutCard = {}

        for i, v in ipairs(outcards) do
            bestOutCard[v] = true
        end

        for i, card in ipairs(All_Card_Nodes[playerType] or {}) do
            local x = planeWidth / 2 - (3 - i) * cardInterval

            card:stopAllActions()
            card:setScale(scale)
            card:setPosition(cc.p(x, y)) --牌恢复原位
            local flagView = false
            if cardValue == card.cardUint_ then
                card:setPositionY(card:getPositionY() + 15)
                flagView = true
            end
            card:showFront(flagView)
            if fan > 1 and fan < 11 then
                if bestOutCard[card.cardUint_] then
                --card:set_font_pai_color(cc.c3b(100,100,100))  --将牌的牌面设为灰色
                end
            elseif fan == 1 then
                --card:set_font_pai_color(cc.c3b(100,100,100))  --将牌的牌面设为灰色
            elseif fan >= 11 then
            --card:set_font_pai_color(cc.c3b(255,255,255))  --将牌的牌面设为灰色
            end

        end
    else
        local cards = {}
        for i, cardNode in ipairs[playerType] do
            table.insert(cards, cardNode.cardUint_)
        end

        local outcards, fan = cardLogic:getallfans(cards)
        local bestOutCard = {}

        for i, v in ipairs(outcards) do
            bestOutCard[v] = true
        end

        for i, card in ipairs(All_Card_Nodes[playerType]) do
            local x = planeWidth / 2 - (3 - i) * cardInterval

            card:stopAllActions()
            card:setScale(scale)
            card:setPosition(cc.p(x, y)) --牌恢复原位
            local flagView = false
            if cardValue == card.cardUint_ then
                card:setPositionY(card:getPositionY() + 15)
                flagView = true
            end
            card:showFront(flagView)

            if fan > 1 and fan < 11 then
                if bestOutCard[card.cardUint_] then
                    card:set_font_pai_color(cc.c3b(100, 100, 100)) --将牌的牌面设为灰色
                end
            elseif fan == 1 then
                card:set_font_pai_color(cc.c3b(100, 100, 100))
            elseif fan >= 11 then
                card:set_font_pai_color(cc.c3b(255, 255, 255))
            end
        end
    end
end

function CardPlaneOperator:turnCards(plane)
    for _, cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
        if cardNode:isBack() then
            cardNode:flipCard()
        end
    end
end

function CardPlaneOperator:countFanAndShow(plane)
    -- GamePlaneOperator:showNumCount()

    -- for _,cardNode in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
    --     cardNode:showFront()
    --     cardNode:setTouchEvent(All_Card_Nodes[CARD_PLAYERTYPE_MY])
    -- end

    -- GamePlaneOperator:hideCardKindTipButton()

    HAS_OPEN_CARD_UIDS[USER_INFO['uid']] = true
    --------------自动算牌
    local outcards, fan = cardLogic:getallfans(MY_CARDS)
    local bestOutCard = {}

    for i, v in ipairs(outcards) do
        bestOutCard[v] = true
    end

    if next(All_Card_Nodes[CARD_PLAYERTYPE_MY]) == nil or GAME_STATE == GAME_STATUS_STOP then
        return
    end

    GamePlaneOperator:showCardKind(CARD_PLAYERTYPE_MY, fan)
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
    local cardUpheight = OtherCardY + 60 * (SCREEN_WIDTH / DESIGN_SCREEN_WIDTH)

    for _, card in ipairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
        if fan > 1 and fan < 12 and bestOutCard[card.cardUint_] then --牛一到牛牛
            card:setPositionY(cardUpheight) --之前的位置是25
        elseif fan >= 12 and bestOutCard[card.cardUint_] then --炸弹，五小牛，五花牛特殊牌型
            card:setPositionY(cardUpheight)
        elseif fan == 1 then
            card:set_font_pai_color(cc.c3b(100, 100, 100))
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

function CardPlaneOperator:exchangeCardPosition(sprite1, sprite2)
    if tolua.type(sprite1) ~= 'cc.Node' or tolua.type(sprite2) ~= 'cc.Node' then
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
    local runTime = (position2.x - position1.x) / 290 * 0.2

    local action2 =
        cc.Sequence:create(
        cc.MoveTo:create(0.2, cc.p(position2.x, position2.y + height)),
        cc.MoveTo:create(runTime, cc.p(position1.x, position1.y + height)),
        cc.MoveTo:create(0.15, cc.p(position1.x, position1.y))
    )
    sprite1:runAction(action1)
    sprite2:runAction(action2)
end

--@zc 20170727 搓牌场景的加载
function CardPlaneOperator:showCuoPai(cards, flag)

    if flag == false then
        local cuoPaiScene = NIUNIU_SCENE:getChildByName('cuopai')
        if cuoPaiScene then
            cuoPaiScene:removeFromParent()
        end

        return
    end

    local backCardNum = 0
    local backCardsIndexs = {}
    if All_Card_Nodes[CARD_PLAYERTYPE_MY] and next(All_Card_Nodes[CARD_PLAYERTYPE_MY]) then
        for index, card in pairs(All_Card_Nodes[CARD_PLAYERTYPE_MY]) do
            if card:isBack() then
                table.insert(backCardsIndexs, index)
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
        require(TpackageName .. '.LayerShuffling').new(cardUint)
        return
    end
    -- if true then
    --     return
    -- end
    local cuoPaiScene = cc.CSLoader:createNode(TpackageName .. '/csb/CuopaiScene.csb'):addTo(NIUNIU_SCENE)
    cuoPaiScene:setName('cuopai')
    cuoPaiScene:setScale(SCREEN_WIDTH / DESIGN_SCREEN_WIDTH)

    cuoPaiScene:setVisible(true)

    local endTime = 7
    --@zC 7秒之后自动释放
    --@zc动画结束位置
    local endPosX = DESIGN_SCREEN_WIDTH / 4
    local enPosY = -80 ---161

    local cuopai_plane = cuoPaiScene:getChildByName('cuopai_plane')
    cuopai_plane:setPosition(cc.p(DESIGN_SCREEN_WIDTH / 2, DESIGN_SCREEN_HEIGHT / 2))

    local card_1 = cuopai_plane:getChildByName('card_1')
    local card_2 = cuopai_plane:getChildByName('card_2')
    local card_3 = cuopai_plane:getChildByName('card_3')
    local card_4 = cuopai_plane:getChildByName('card_4')
    local card_5 = cuopai_plane:getChildByName('card_5')

    -- card_1:setPosition(cc.p(endPosX, enPosY))
    -- card_2:setPosition(cc.p(endPosX, enPosY))
    -- card_3:setPosition(cc.p(endPosX, enPosY))
    -- card_4:setPosition(cc.p(endPosX, enPosY))
    -- card_5:setPosition(cc.p(endPosX, enPosY))

    local cuoPaiSceneHasRemoved = false
    local CloseEvent = function(sender, event)
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

            card_1:rotateTo(0.1, -9)
            card_2:rotateTo(0.1, -9)
            card_4:rotateTo(0.1, -9)
            card_5:rotateTo(0.1, -9)
            -- --1执行完毕之后，播放场景退出动画

            local delay1 = cc.DelayTime:create(0.2)
            local callfuncMove =
                cc.CallFunc:create(
                function()
                    cuopai_plane:moveTo(0.4, 0, -DESIGN_SCREEN_HEIGHT / 2)
                end
            )
            --         --2执行完毕之后，把场景移除

            local delay2 = cc.DelayTime:create(0.5)
            local callfuncEnd =
                cc.CallFunc:create(
                function()
                    self:turnCards()
                    cuoPaiScene:removeFromParent()
                end
            )

            NIUNIU_SCENE:runAction(cc.Sequence:create(delay1, callfuncMove, delay2, callfuncEnd))
        end
    end

    local CardRotateAngle = 4
    NIUNIU_SCENE:performWithDelay(
        function()
            if not tolua.isnull(card_1) then
                card_1:rotateTo(0.2, -9 - 2 * CardRotateAngle)
                card_2:rotateTo(0.2, -9 - CardRotateAngle)
                card_4:rotateTo(0.2, -9 + CardRotateAngle)
                card_5:rotateTo(0.2, -9 + 2 * CardRotateAngle)
            end
        end,
        1
    )

    NIUNIU_SCENE:performWithDelay(
        function()
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
            local callfuncMove =
                cc.CallFunc:create(
                function()
                    cuopai_plane:moveTo(0.4, 0, -DESIGN_SCREEN_HEIGHT / 2)
                end
            )

            local delay2 = cc.DelayTime:create(0.8)
            local callfuncEnd =
                cc.CallFunc:create(
                function()
                    self:turnCards()
                    cuoPaiScene:removeFromParent()
                end
            )

            NIUNIU_SCENE:runAction(cc.Sequence:create(delay1, callfuncMove, delay2, callfuncEnd))
        end,
        endTime
    )

    --倒序放牌
    if backCardNum == 5 then --经典牛牛，五张全暗的情况下
        for i = 1, backCardNum do
            local a = cuopai_plane:getChildByName('card_' .. i)

            local cardUint = cards[6 - i]

            Card:setCuoCard(a, cardUint)

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
    else --明牌牛牛，先发牌的情况下
        for i = 1, backCardNum + 1 do
            local a = cuopai_plane:getChildByName('card_' .. i)

            a:setScale(1.5)

            if i ~= backCardNum + 1 then
                local cardUint = cards[backCardsIndexs[i]]

                Card:setCuoCard(a, cardUint)
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

                Card:setCuoCard(a, _, true)
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
function CardPlaneOperator:add_eventlistener(card_image)
    local a = card_image:getPosition()
    local touchBeginPoint = nil

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget() --获取事件绑定的目标
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height) --设置点击的区域
        if cc.rectContainsPoint(rect, locationInNode) then
            target:setOpacity(255) --设置点击区域下的透明度大小0-255之间
            local location = touch:getLocation()
            touchBeginPoint = {x = location.x, y = location.y}
            return true
        end
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        if touchBeginPoint then
            local cx = card_image:getPosition().x
            local cy = card_image:getPosition().y
            card_image:setPosition(cc.p(cx + location.x - touchBeginPoint.x, cy + location.y - touchBeginPoint.y))
            touchBeginPoint = {x = location.x, y = location.y}
        end
    end

    local function onTouchEnded(touch, event)
    end

    local listener = cc.EventListenerTouchOneByOne:create() --依次一个一个的执行
    listener:setSwallowTouches(true) --当两个碰撞体重叠的时候，只检测到最上层的那一个
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = card_image:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, card_image)
end

return CardPlaneOperator
