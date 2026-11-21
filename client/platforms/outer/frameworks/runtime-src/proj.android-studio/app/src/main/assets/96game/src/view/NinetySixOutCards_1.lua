--
local NinetySixOutCards = class("NinetySixOutCards")
local NinetySixPokerCard = require("96game.src.view.NinetySixPokerCard")
local NinetySixDefine = require("96game.src.ctrl.NinetySixDefine")

function NinetySixOutCards:ctor(scene, parent, viewId)
    self.scene = scene
    self.viewId = viewId
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    self.card_scale = 0.35

    self.node = parent:getChildByName("PlayerOut" .. viewId)

    self:initData()
    self:initUI()
    self:cleanAllCards()
    -- self:doTest()
end

function NinetySixOutCards:initUI()
    self.OutCard = self.node:getChildByName("OutCard")
    self.GroupCard = self.node:getChildByName("GroupCard")
    self.CardZhua = self.node:getChildByName("CardZhua")
    self.PanelSpine = self.scene.Panel_effect:getChildByName("PanelSpine" .. self.viewId)
    self.Panel_arrow = self.scene.Panel_arrow:getChildByName("Panel_arrow" .. self.viewId)
    self.Image_arrow = self.Panel_arrow:getChildByName("Image_arrow")
    self:arrowAction()
    self.Panel_arrow:setVisible(false)

    self.startZhuaPos = self.node:convertToNodeSpace(self.scene.game_info.wPosCardMound)
    self.endZhuaPos = self.CardZhua:getPosition()
    self.CardZhua:setVisible(false)
    self.groupSize = self.GroupCard:getContentSize()

    --self.HeadMoveNode = cc.CSLoader:createNode("96game/res/csb/96HeadMove.csb"):addTo(self)
    --self.HeadMoveNode:setName("headLayer")
    --self.HeadMoveNode:setLocalZOrder(15)
    --self.HeadMoveNode:setPosition(cc.p(1050,300))
    --self.HeadMoveNode:setVisible(false)
    --local  action = cc.CSLoader:createTimeline("96game/res/csb/96HeadMove.csb")
    --self.HeadMoveNode:runAction(action)
    --action:gotoFrameAndPlay(0,true)
end

function NinetySixOutCards:onEnter()
    self.tEvents = {
        GameEvent:addListen("NinetySixLoginRoomInfo", handler(self, self.cleanAllCards)),
        GameEvent:addListen("NinetySixReconnection", handler(self, self.cleanAllCards)),
        GameEvent:addListen("NinetySixPlayerInitAllOutCard", handler(self, self.initAllOutCard)),
        GameEvent:addListen("NinetySixPlayerOutCard", handler(self, self.onOutCard)),
        GameEvent:addListen('NinetySixThePlayerOutCard', handler(self, self.onOutCard)),
        GameEvent:addListen("NinetySixPlayerGroupCard", handler(self, self.onGroupCard)),
        GameEvent:addListen('NinetySixThePlayerGroupCard', handler(self, self.onGroupCard)),
        GameEvent:addListen("NinetySixPlayerZhuaCard", handler(self, self.onZhuaCard)),
        GameEvent:addListen("NinetySixPlayerNoUserOpt", handler(self, self.onNoUserOpt)),
        GameEvent:addListen("NinetySixCurOptViewIdChange", handler(self, self.optPlayerChange)),
        GameEvent:addListen("NinetySixOutCardTest", handler(self, self.onOutCard)),
        GameEvent:addListen("NinetySixNextRoundClean", handler(self, self.cleanAllCards)),


    }
end

function NinetySixOutCards:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end

function NinetySixOutCards:initData()
    self.cardsCount = 0
    self.tGroupList = {}
end

function NinetySixOutCards:cleanAllCards()
    self.cardsCount = 0
    self.tGroupList = {}
    self:removePokerZhua()
    self.OutCard:removeAllChildren()
    self.GroupCard:removeAllChildren()
    self.PanelSpine:removeAllChildren()
    self.Panel_arrow:setVisible(false)
end

function NinetySixOutCards:initAllOutCard(viewId, player)
    if viewId ~= self.viewId then
        return
    end

    for i, v in ipairs(player.tOutCards) do
        self:onOutCard(self.viewId, v.cardId, false)
    end

    for i, v in ipairs(player.m_byTableCardData) do
        self:onGroupCard(self.viewId, v.cbCardData, v.cbActiveType, false,false,v.m_isZiMo) --viewId, tCards, cardType
    end
end

function NinetySixOutCards:doTest()
    self.testCards = {}
    for i = 1, 40 do
        local idx = math.random(1, #self.logic.card_config)
        table.insert(self.testCards, self.logic.card_config[idx])
    end

    for i, v in ipairs(self.testCards) do
        self:onOutCard(self.viewId, v, false)
    end

    self.testGroup = {}
    for i = 1, 10 do
        table.insert(self.testGroup, {})
        for ii = 1, math.random(1, 5) do
            local idx = math.random(1, #self.logic.card_config)
            table.insert(self.testGroup[i], self.logic.card_config[idx])
        end
    end

    for i, v in ipairs(self.testGroup) do
        self:onGroupCard(self.viewId, v)
    end
end
function NinetySixOutCards:arrowActionMove()

end
function NinetySixOutCards:arrowAction()
    local sec = 0.5
    local action1 = cc.MoveTo:create(sec, cc.p(50, 30))
    local action2 = cc.MoveTo:create(sec, cc.p(50, 50))
    local action3 = cc.ScaleTo:create(sec, 1)
    local action4 = cc.ScaleTo:create(sec, 1)
    local action5 = cc.Spawn:create(action1, action3)
    local action6 = cc.Spawn:create(action2, action4)
    local action7 = cc.RepeatForever:create(cc.Sequence:create(action5, action6))
    self.Image_arrow:runAction(action7)
end

function NinetySixOutCards:optPlayerChange(viewId)
    self.Panel_arrow:setVisible(viewId == self.viewId)
end

function NinetySixOutCards:onOutCard(viewId, cardId, voice,isOut)
    if viewId ~= self.viewId then
        return
    end

    self.cardsCount = self.cardsCount + 1
    local poker = NinetySixPokerCard.new(self, self.OutCard, self.card_scale) --138, 188
    poker:setCardId(cardId)
    poker:setState(2)

    if voice then
        self.ctrl.utils:playMiscVoice("out_card")
        local p = self.scene.tPlayers[self.viewId]
        if isOut then
            self.ctrl.utils:playCardVoice(poker:getCardColor(), poker:getCardValue(), p.data.sex)
        end
        --
    end

    local lineMax = 20
    if self.viewId == 2 or self.viewId == 4 then
        lineMax = 10
    elseif self.viewId == 3 then
        lineMax = 12
    end

    local x = 25 + ((self.cardsCount - 1) % lineMax) * 25
    local y = 68 - math.floor((self.cardsCount - 1) / lineMax) * 40
    poker:setPosition(x, y)
    poker:setLocalZOrder(x - y)

    if self.pokerZhua and self.pokerZhua:getCardId() == cardId then
        local wpos = self.OutCard:convertToWorldSpace(cc.p(x, y))
        local npos = self.node:convertToNodeSpace(wpos)
        local function end_action()
            self:removePokerZhua()
        end

        local action1 = cc.MoveTo:create(0.2, npos)
        local action2 = cc.ScaleTo:create(0.2, self.card_scale)
        local action3 = cc.Spawn:create(action1, action2)
        local cbAction = cc.CallFunc:create(end_action)
        self.pokerZhua:stopAllActions()
        self.pokerZhua:runAction(cc.Sequence:create(action3, cbAction))

        local a1 = cc.DelayTime:create(0.2)
        local a2 = cc.FadeIn:create(0.05)
        poker:setOpacity(0)
        poker:runAction(cc.Sequence:create(a1, a2))
    else
        self:removePokerZhua()
    end
end
function NinetySixOutCards:onOutCardTest(viewId, cardId, voice,isOut)
    if viewId ~= self.viewId then
        return
    end

    self.cardsCount = self.cardsCount + 1
    local poker = NinetySixPokerCard.new(self, self.OutCard, self.card_scale) --138, 188
    poker:setCardId(cardId)
    poker:setState(2)

    if voice then
        self.ctrl.utils:playMiscVoice("out_card")
        local p = self.scene.tPlayers[self.viewId]
        if isOut then
            self.ctrl.utils:playCardVoice(poker:getCardColor(), poker:getCardValue(), p.data.sex)
        end
        --
    end

    local lineMax = 20
    if self.viewId == 2 or self.viewId == 4 then
        lineMax = 10
    elseif self.viewId == 3 then
        lineMax = 12
    end

    local x = 25 + ((self.cardsCount - 1) % lineMax) * 25
    local y = 68 - math.floor((self.cardsCount - 1) / lineMax) * 40
    poker:setPosition(x, y)
    poker:setLocalZOrder(x - y)

    if self.pokerZhua and self.pokerZhua:getCardId() == cardId then
        local wpos = self.OutCard:convertToWorldSpace(cc.p(x, y))
        local npos = self.node:convertToNodeSpace(wpos)
        local function end_action()
            self:removePokerZhua()
        end

        local action1 = cc.MoveTo:create(0.2, npos)
        local action2 = cc.ScaleTo:create(0.2, self.card_scale)
        local action3 = cc.Spawn:create(action1, action2)
        local cbAction = cc.CallFunc:create(end_action)
        self.pokerZhua:stopAllActions()
        self.pokerZhua:runAction(cc.Sequence:create(action3, cbAction))

        local a1 = cc.DelayTime:create(0.2)
        local a2 = cc.FadeIn:create(0.05)
        poker:setOpacity(0)
        poker:runAction(cc.Sequence:create(a1, a2))
    else
        self:removePokerZhua()
    end
end

function NinetySixOutCards:onGroupCard(viewId, tCardsList, cardType, voice, pack, m_isZiMo,isSLXZ)
    self:removePokerZhua()
    print("m_isZiMo====",m_isZiMo)
    dump(pack,"pack-------------------")
    if viewId ~= self.viewId then
        return
    end
    if cardType == NinetySixDefine.BAN_ZHAO_MAN_ZHAO then
        cardType = NinetySixDefine.MAN_ZHAO
    end

    local tCards = clone(tCardsList)
    local last_card = tCards[#tCards]
    local function comp(a, b)
        local va = bit.band(a, 0x0f)
        local vb = bit.band(b, 0x0f)
        return va < vb
    end
    table.sort(tCards, comp)
    if #tCards == 5 then
        cardType = NinetySixDefine.BAN_ZHAO
    elseif #tCards == 6 then
        cardType = NinetySixDefine.MAN_ZHAO
    end
    dump(cardType,"NinetySixOutCards")
    local max_count_val = 0
    local max_count_color = 1
    if #tCards >= 4 then
        local tVal = {}
        local temp_val = 0
        local max_count = 0
        for k, v in ipairs(tCards) do
            temp_val = NinetySixPokerCard:calcValue(v)
            tVal[temp_val] = tVal[temp_val] or {}
            table.insert(tVal[temp_val], v)
            if #tVal[temp_val] > max_count then
                max_count = #tVal[temp_val]
                max_count_val = temp_val
                local huaSe = NinetySixPokerCard:calcHuaSe(v)
                max_count_color = 1
                if huaSe == 0 or huaSe == 2 then
                    max_count_color = 2
                end
            end
        end

        while NinetySixPokerCard:calcValue(tCards[1]) ~= max_count_val do
            table.insert(tCards, table.remove(tCards, 1))
        end
    end

    if cardType == NinetySixDefine.CHI and pack and pack.card_type == 2 then --由贴变吃 直接在原来的牌上加牌
        for _, group in ipairs(self.tGroupList) do
            if group.cardType == NinetySixDefine.TIE then
                local is_find = false
                for _, poker in ipairs(group.tPokerCards) do
                    is_find = false
                    for _, val in ipairs(tCards) do
                        if val == poker:getCardId() then
                            is_find = true
                        end
                    end
                    if not is_find then
                        break
                    end
                end

                if is_find then
                    group.cardType = cardType
                    local x, y, zorder
                    if self.viewId == 2 then
                        x = self.groupSize.width - 25 - ((group.index - 1) % 10) * 25
                    else
                        x = 25 + ((group.index - 1) % 10) * 25
                    end

                    for k, v in ipairs(tCards) do
                        local poker = group.tPokerCards[k]
                        if poker == nil then
                            poker = NinetySixPokerCard.new(self, self.GroupCard, self.card_scale) --138, 188
                            if self.viewId == 3 then
                                y = self.groupSize.height - 30 - (k - 1) * 37
                                zorder = x + k
                            else
                                y = 30 + (k - 1) * 37
                                zorder = x - k
                            end
                            poker:setPosition(x, y)
                            poker:setLocalZOrder(zorder)
                            table.insert(group.tPokerCards, poker)
                        end

                        poker:setCardId(v)
                        poker:setState(2)

                        if v == last_card then
                            poker:setPokerColor(cc.c3b(170, 170, 170))
                        else
                            poker:setPokerColor(cc.c3b(255, 255, 255))
                        end
                    end

                    if voice then
                        self:doOptionAniAndVoice(cardType)
                    end
                    print("由贴变吃===============>")
                    return
                end
            end
        end
    end

    --由勺变走,满招,半招  可能由贴直接变满招？
    if NinetySixDefine.ZOU == cardType or NinetySixDefine.BAN_ZHAO == cardType or NinetySixDefine.MAN_ZHAO == cardType then
        dump(cardType,"ok cardType")
        for _, group in ipairs(self.tGroupList) do
            dump(group.cardType,"group.cardType  tie")
            local isOK = false
            local isTieManzhao = false
            if cardType == NinetySixDefine.ZOU then --由勺变走
                isOK = group.cardType == NinetySixDefine.SHAO and group.tPokerCards[1]:getCardValue() == max_count_val
            elseif cardType == NinetySixDefine.BAN_ZHAO then --由勺、走变半招
                isOK = (group.cardType == NinetySixDefine.SHAO
                    or group.cardType == NinetySixDefine.ZOU)
                    and group.tPokerCards[1]:getCardValue() == max_count_val
            elseif cardType == NinetySixDefine.MAN_ZHAO then --由勺、走、半招变满招
                isOK = (group.cardType == NinetySixDefine.SHAO
                    or group.cardType == NinetySixDefine.ZOU
                    or group.cardType == NinetySixDefine.BAN_ZHAO)
                    and group.tPokerCards[1]:getCardValue() == max_count_val

                if group.cardType == NinetySixDefine.TIE then --检查贴
                    local same_num = 0
                    for _, poker in pairs(group.tPokerCards) do
                        for _, id in pairs(tCards) do
                            local temp_val = NinetySixPokerCard:calcValue(id)
                            local huaSe = NinetySixPokerCard:calcHuaSe(id)
                            local color = 1
                            if huaSe == 0 or huaSe == 2 then
                                color = 2
                            end
                            if temp_val == poker:getCardValue() and color == poker:getCardColor() then
                                same_num = same_num + 1
                                break
                            end
                        end
                    end
                    isTieManzhao = same_num == #group.tPokerCards
                    print("tie ===> manzhao1",isTieManzhao)
                end
            end

            isOK = isOK and max_count_color == group.tPokerCards[1]:getCardColor()
            if isOK or isTieManzhao then
                group.cardType = cardType
                local x, y, zorder
                if self.viewId == 2 then
                    x = self.groupSize.width - 25 - ((group.index - 1) % 10) * 25
                else
                    x = 25 + ((group.index - 1) % 10) * 25
                end

                for k, v in ipairs(tCards) do
                    local poker = group.tPokerCards[k]
                    if poker == nil then
                        poker = NinetySixPokerCard.new(self, self.GroupCard, self.card_scale) --138, 188
                        if self.viewId == 3 then
                            y = self.groupSize.height - 30 - (k - 1) * 37
                            zorder = x + k
                        else
                            y = 30 + (k - 1) * 37
                            zorder = x - k
                        end
                        poker:setPosition(x, y)
                        poker:setLocalZOrder(zorder)
                        table.insert(group.tPokerCards, poker)
                    end

                    poker:setCardId(v)
                    poker:setPokerColor(cc.c3b(255, 255, 255))
                    if (k == 1 or k == 2 or k == 3) and m_isZiMo ==1 then
                        poker:setState(1)
                    else
                        poker:setState(2)
                    end
                end

                if voice then
                    self:doOptionAniAndVoice(cardType,isSLXZ)
                end
                print("由勺变走===============>")
                for k, group in ipairs(self.tGroupList) do --单独检测贴
                    if cardType == NinetySixDefine.MAN_ZHAO then --由勺、走、半招变满招
                        if group.cardType == NinetySixDefine.TIE then --检查贴
                            local same_num = 0
                            for _, poker in pairs(group.tPokerCards) do
                                for _, id in pairs(tCards) do
                                    local temp_val = NinetySixPokerCard:calcValue(id)
                                    local huaSe = NinetySixPokerCard:calcHuaSe(id)
                                    local color = 1
                                    if huaSe == 0 or huaSe == 2 then
                                        color = 2
                                    end
                                    if tolua.isnull(poker) == false and  temp_val == poker:getCardValue() and color == poker:getCardColor() then
                                        poker:removeFromParent()
                                        same_num = same_num + 1
                                        break
                                    end
                                end
                            end
                            isTieManzhao = same_num == #group.tPokerCards
                            print("tie ===> manzhao1 tire ==",isTieManzhao)
                            if isTieManzhao then
                                table.remove(self.tGroupList,k)
                                break
                            end

                        end
                    end
                end
                return
            end
        end


    end

    local groupCount = #self.tGroupList + 1
    local x, y, zorder
    if self.viewId == 2 then
        x = self.groupSize.width - 25 - ((groupCount - 1) % 10) * 25
    else
        x = 25 + ((groupCount - 1) % 10) * 25
    end

    local is_zou_up = NinetySixDefine.ZOU == cardType or NinetySixDefine.BAN_ZHAO == cardType or NinetySixDefine.MAN_ZHAO == cardType
    local new_group = {index = groupCount, tPokerCards = {}, cardType = cardType, last_card = last_card}
    for k, v in ipairs(tCards) do
        local poker = NinetySixPokerCard.new(self, self.GroupCard, self.card_scale) --138, 188
        poker:setCardId(v)
        local show_back = cardType == NinetySixDefine.SHAO and (k == 1 or k == 2)
        if show_back then
            poker:setState(1)
        else
            poker:setState(2)
        end
        local zou_show = (k == 1 or k == 2 or k == 3)
        --show_back = show_back or (is_zou_up and (k == 1 or k == 2 or k == 3))
        if is_zou_up  then
            if zou_show and m_isZiMo == 1 then
                poker:setState(1)
            else
                poker:setState(2)
            end
        end
        if self.viewId == 3 then
            y = self.groupSize.height - 30 - (k - 1) * 37
            zorder = x + k
        else
            y = 30 + (k - 1) * 37
            zorder = x - k
        end
        poker:setPosition(x, y)
        poker:setLocalZOrder(zorder)
        table.insert(new_group.tPokerCards, poker)
        
        if v == last_card and (NinetySixDefine.CHI == cardType or NinetySixDefine.TIE == cardType) then
            poker:setPokerColor(cc.c3b(170, 170, 170))
        end
    end
    table.insert(self.tGroupList, new_group)

    if voice then
        self:doOptionAniAndVoice(cardType,isSLXZ)
    end
end

function NinetySixOutCards:doOptionAniAndVoice(opt,isSLXZ)
    local p = self.scene.tPlayers[self.viewId]
    if isSLXZ and isSLXZ >0 then
        self.ctrl.utils:playOptionAni( NinetySixDefine.SHUANGLONGXIZHU, self.PanelSpine)
    else
        self.ctrl.utils:playOptionVoice(opt, p.data.sex)
        self.ctrl.utils:playOptionAni(opt, self.PanelSpine)
    end

end

function NinetySixOutCards:onZhuaCard(viewId, cardId, isAni)
    if viewId ~= self.viewId then
        if self.pokerZhua then
            self:onOutCard(self.viewId, self.pokerZhua:getCardId(), true,false)
        end
        return
    end

    self:removePokerZhua()
    self.pokerZhua = NinetySixPokerCard.new(self, self.node, 1) --138, 188
    self.pokerZhua:setCardId(cardId)
    self.pokerZhua:setState(2)
    self.pokerZhua:showLight(1)
    
    if isAni then
        self.ctrl.utils:playMiscVoice("take_card")
        self.pokerZhua:setPosition(self.startZhuaPos)
        self.pokerZhua:setScale(0.1)
        local action1 = cc.MoveTo:create(0.2, self.endZhuaPos)
        local action2 = cc.ScaleTo:create(0.2, 1)
        local action3 = cc.Spawn:create(action1, action2)
        self.pokerZhua:runAction(action3)

        local p = self.scene.tPlayers[self.viewId]
        self.ctrl.utils:playCardVoice(self.pokerZhua:getCardColor(), self.pokerZhua:getCardValue(), p.data.sex)
    else
        self.pokerZhua:setPosition(self.endZhuaPos)
    end
end

function NinetySixOutCards:moveToCard()
    if tolua.isnull(self.pokerZhua) == false  then
        self.pokerZhua:performWithDelay(function ()
            local action1 = cc.MoveTo:create(0.2, cc.p(837.01,397.06))
            local action2 = cc.ScaleTo:create(0.2, 1)
            local action3 = cc.Spawn:create(action1, action2)
            self.pokerZhua:runAction(action3)
        end , 1)
    end
end

function NinetySixOutCards:onNoUserOpt(viewId, cardId)
    
end

function NinetySixOutCards:removePokerZhua()
    if self.pokerZhua then
        self.pokerZhua:removeFromParent()
        self.pokerZhua = nil
    end
end

return NinetySixOutCards
