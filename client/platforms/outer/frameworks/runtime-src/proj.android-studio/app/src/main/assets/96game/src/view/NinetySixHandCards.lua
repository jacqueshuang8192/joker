--玩家手牌
local NinetySixHandCards = class('NinetySixHandCards')
local NinetySixPokerCard = require('96game.src.view.NinetySixPokerCard')
local NinetySixDefine = require("96game.src.ctrl.NinetySixDefine")

function NinetySixHandCards:ctor(scene, node)
    self.scene = scene
    self.ctrl = scene.ctrl
    self.logic = self.ctrl.logic

    self.card_scale = 1
    self.tPokerCards = {}
    self.curOutwPos = nil
    self.curOutPoker = nil

    self.panel = node:getChildByName('MyHandsCardsPanel')
    self.panel_size = self.panel:getContentSize()
    self.panel_pos = self.panel:getPosition()
    self.midWidth = self.panel_size.width / 2
    self.winSize = cc.Director:getInstance():getWinSize()
    self.wincy = self.winSize.height / 2

    self.startDealPos = self.panel:convertToNodeSpace(self.scene.game_info.wPosCardMound)

    self:initPokerPos()
    -- self:doTest()
end

function NinetySixHandCards:onEnter()
    self.tEvents = {
        GameEvent:addListen('NinetySixLoginRoomInfo', handler(self, self.cleanAllCards)),
        GameEvent:addListen('NinetySixReconnection', handler(self, self.cleanAllCards)),
        GameEvent:addListen('NinetySixDealCards', handler(self, self.onDealCards)),
        GameEvent:addListen('NinetySixPlayerOutCard', handler(self, self.onOutCard)),
        GameEvent:addListen('NinetySixCurErrorOpt', handler(self, self.errorOpt)),
        GameEvent:addListen('NinetySixPlayerGroupCard', handler(self, self.onGroupCard)),
        GameEvent:addListen('NinetySixNextRoundClean', handler(self, self.cleanAllCards)),
        GameEvent:addListen('NinetySixTingCardsUpdate', handler(self, self.onTingCards)),
        GameEvent:addListen('NinetySixOutCardTest', handler(self, self.outCardTest)),
    }
end

function NinetySixHandCards:onExit()
    for k, e in pairs(self.tEvents) do
        GameEvent:delListen(e)
    end
end

function NinetySixHandCards:cleanAllCards()
    self.tPokerCards = {}
    self.curOutwPos = nil
    self.curOutPoker = nil
    self.panel:removeAllChildren()
    self.panel:setPosition(self.panel_pos)
end

function NinetySixHandCards:onOutCard(viewId, cardId)
    if viewId ~= 1 then
        return
    end

    local btn_opt = SCENENOW["scene"].btn_opt
    dump(btn_opt.istuoguan,"btn_optbtn_optbtn_optbtn_optbtn_optbtn_opt")
    if self.curOutPoker and self.curOutPoker:getCardId() == cardId then
        self.curOutPoker:removeFromParent()
        self.curOutPoker = nil
        self.curOutwPos = nil

        self:initPokerCardsTbl()
        self:trimEmptyCol()
        self:updatePosIdx()
    elseif btn_opt.istuoguan then
        local tList = self.panel:getChildren()
        for idx, card in ipairs(tList) do
            if cardId == card:getCardId() then
                card:removeFromParent()
                self.curOutPoker = nil
                self.curOutwPos = nil
                self:initPokerCardsTbl()
                self:trimEmptyCol()
                self:updatePosIdx()
                break
            end
        end

    end

    self:cleanTingCards()
end

function NinetySixHandCards:bindPokerTouch()
    local children = self.panel:getChildren()
    for k, child in ipairs(children) do
        child:bindTouch()
        child:setState(2)
    end
end

function NinetySixHandCards:initPokerCardsTbl()
    local children = self.panel:getChildren()
    self.tPokerCards = {}
    for k, child in ipairs(children) do
        self.tPokerCards[child.pos_idx] = {poker = child, pos_idx = child.pos_idx}
    end
end

function NinetySixHandCards:updatePosIdx()
    for k, v in pairs(self.tPokerCards) do
        v.poker:setPosIdx(v.pos_idx, true)
    end

    self:updatePokerMap()
    self:centerAlign()
end

function NinetySixHandCards:updatePokerMap()
    local tTemp = {}
    for k, v in pairs(self.tPokerCards) do
        tTemp[v.pos_idx] = {poker = v.poker, pos_idx = v.pos_idx}
    end
    self.tPokerCards = tTemp
end

function NinetySixHandCards:checkOutCard(poker, endPos)
    if self.logic.curOptSeatId == self.logic.mySeatId and self.curOutPoker == nil then
        local wPos = self.panel:convertToWorldSpace(endPos)
        if wPos.y > self.wincy then
            self.curOutPoker = poker
            self.curOutwPos = wPos
            self.ctrl.send:outCard(poker:getCardId())
            return true
        end
    end
    return false
end

function NinetySixHandCards:onDealCards(tCards, isReconnection)
    self.tPokerCards = {}
    self.panel:removeAllChildren()
    self.panel:setPosition(self.panel_pos)
    self.panel:stopAllActions()
    self.scene:stopAllActions()
    if isReconnection then
        for k, v in pairs(tCards) do
            if k <= self.maxPoker then
                local poker = NinetySixPokerCard.new(self, self.panel, self.card_scale)
                poker:setCardId(v)
                poker:setState(2)
                poker:bindTouch()
            end
        end
        self:arrangeCards(false)
    else
        -- self.ctrl.utils:playMiscVoice('deal_cards')
        for k, v in pairs(tCards) do
            if k <= self.maxPoker then
                local poker = NinetySixPokerCard.new(self, self.panel, self.card_scale)
                poker:setCardId(v)
                poker:setPosition(self.startDealPos)
                poker:setState(1)
                poker:setPosIdx(k, true, k * 0.1)
            end
        end
        local refreshTime = 0.1
        local timer_value = 0
        local function doAction1()
            refreshTime = 0
            self:arrangeCards(true)
        end

        local function doAction2()

            self.scene:stopAllActions()
            self:bindPokerTouch()
        end
        local a1 = cc.DelayTime:create(2.5)
        local a2 = cc.CallFunc:create(doAction1)
        local a3 = cc.DelayTime:create(0.2)
        local a4 = cc.CallFunc:create(doAction2)
        local showTimerAc = cc.CallFunc:create(function()

            --dump(timer_value,stage.."------------------------")
            if  refreshTime > 0 and timer_value < 1.6 then
                timer_value =timer_value+0.1
                require("hall.GameCommon"):play2d("96game/res/sound/misc/fapai.mp3")
            else
                self.scene:stopAllActions()
            end
        end)
        local seqAc = cc.Sequence:create(cc.DelayTime:create(refreshTime),showTimerAc)
        self.scene:runAction(cc.RepeatForever:create(seqAc))
        self.panel:runAction(cc.Sequence:create(a1, a2, a3, a4))
    end
end

function NinetySixHandCards:onGroupCard(viewId, tCards, cardType, voice, pack, m_isZiMo,isSLXZ,cardType_type)
    if viewId ~= 1 then
        return
    end
    dump(cardType_type, "---------------000cardType_type")
    if cardType == NinetySixDefine.CHI and pack and pack.card_type == 2 then --由贴变吃
        return
    end

    local tbl = clone(tCards)
    if cardType == NinetySixDefine.TIE then
        table.remove(tbl,2)
    end
    if cardType == NinetySixDefine.BAN_ZHAO_MAN_ZHAO then
        return
    end
    if #tbl == 6 then
        for _, group in ipairs(self.scene.tCardOuts[viewId].tGroupList) do
            if group.cardType == NinetySixDefine.TIE then --检查贴
                local same_num = 0
                local new_tbl = {}
                for _, poker in pairs(group.tPokerCards) do
                    for _, id in pairs(tbl) do
                        local temp_val = NinetySixPokerCard:calcValue(id)
                        local huaSe = NinetySixPokerCard:calcHuaSe(id)
                        local color = 1
                        if huaSe == 0 or huaSe == 2 then
                            color = 2
                        end

                        if temp_val == poker:getCardValue() and color == poker:getCardColor() then
                            same_num = same_num + 1
                            print("same_num====")
                            break
                        else
                            table.insert(new_tbl, id)
                        end
                    end
                end
                if same_num == #group.tPokerCards then
                    print("tie ===> manzhao2")
                    tbl = new_tbl
                    break
                end
            end
        end
        if cardType_type == 2 then
            local tableZou = {}
            for k, v in pairs(tbl) do
                if tableZou[v] == nil then
                    tableZou[v] = 1
                else
                    tableZou[v] = 1+tableZou[v]
                end
            end
            for k, v in pairs(tableZou) do
                if v == 1 then
                    for k2, v2 in pairs(tbl) do
                        if k == v2 then
                            table.remove(tbl,k2)
                            break
                        end
                    end
                end
            end
        end
    end

    if cardType == NinetySixDefine.CHI and pack and pack.card_type == 1 then --正常吃
        table.remove(tbl)
    end

    dump(tbl,"tbl======")
    self:removeCard(tbl)
    self:initPokerCardsTbl()
    self:trimEmptyCol()
    self:updatePosIdx()
end

function NinetySixHandCards:cleanTingCards()
    self.scene:hideTingCards()
    local tList = self.panel:getChildren()

    for k, p in ipairs(tList) do
        p:setTingCards(nil)
    end

    return tList
end

function NinetySixHandCards:onTingCards()
    local tList = self:cleanTingCards()
    if #tList == 0 then
        return
    end

    for k1, v in ipairs(self.logic.tingCards) do
        local huaSe = NinetySixPokerCard:calcHuaSe(v.card)
        local card_value = NinetySixPokerCard:calcValue(v.card)
        local card_color = 1
        if huaSe == 0 or huaSe == 2 then
            card_color = 2
        end

        for k2, p in ipairs(tList) do
            if p:getCardValue() == card_value and p:getCardColor() == card_color then
                p:setTingCards(v.cards)
            end
        end
    end
end

function NinetySixHandCards:removeCard(cardIds)
    local tList = self.panel:getChildren()
    if #tList == 0 then
        return
    end

    local poker
    for k, id in ipairs(cardIds) do
        for i = #tList, 1, -1 do
            if tList[i]:getCardId() == id then
                print("remove card---->", id)
                poker = table.remove(tList, i)
                poker:removeFromParent()
                break
            end
        end
    end
end
function NinetySixHandCards:removeCardTest(viewId,cardIds)
    local tList = self.panel:getChildren()
    if #tList == 0 then
        return
    end

    local poker
    for k, id in ipairs(cardIds) do
        for i = #tList, 1, -1 do
            if tList[i]:getCardId() == id then
                print("remove card---->", id)
                poker = table.remove(tList, i)
                --self:onOutCard(viewId,id)
                --poker:onOutCard()
                poker:removeFromParent()
                break
            end
        end
    end
end
function NinetySixHandCards:errorOpt()
    self.curOutwPos = nil
    self.curOutPoker = nil

    self:initPokerCardsTbl()
    self:updatePosIdx()
end

--手牌排序整理
function NinetySixHandCards:arrangeCards(tween)
    self.curOutwPos = nil
    self.curOutPoker = nil
    local tList = self.panel:getChildren()
    if #tList == 0 then
        return
    end

    local red_list = {}
    local black_list = {}
    for idx, card in ipairs(tList) do
        if 1 == card:getCardColor() then
            table.insert(black_list, card)
        else
            table.insert(red_list, card)
        end
    end

    local sortFun = function(a, b)
        return a:getCardValue() < b:getCardValue()
    end
    table.sort(red_list, sortFun)
    table.sort(black_list, sortFun)

    local function groupList(aList)
        local temp_list = {}
        local pre_max = 0
        for idx, card in ipairs(aList) do
            if card:getCardValue() > pre_max then
                table.insert(temp_list, {})
                pre_max = self:getShunziMaxVal(card:getCardValue(),card:getCardColor())
            end
            table.insert(temp_list[#temp_list], card)
        end

        local group
        for i = 1, 13 do
            group = temp_list[i]
            if group and #group > 3 then
                for aa = 1, #group do
                    local av1 = (group[aa] and group[aa]:getCardValue()) or -1
                    local av2 = (group[aa + 1] and group[aa + 1]:getCardValue()) or -1
                    local av3 = (group[aa + 2] and group[aa + 2]:getCardValue()) or -1
                    local is_three = av1 ~= -1 and av1 == av2 and av1 == av3
                    if is_three and #group > 3 then
                        local new_group = {table.remove(group, aa), table.remove(group, aa), table.remove(group, aa)}
                        table.insert(temp_list, i + 1, new_group)
                    end
                end
            end

            if group and #group > 3 then
                local av1, av2, av3
                local has_new_group = false
                for aa = 1, #group do
                    has_new_group = false
                    av1 = (group[aa] and group[aa]:getCardValue()) or -1
                    if av1 > 0 then
                        for bb = aa + 1, #group do
                            av2 = (group[bb] and group[bb]:getCardValue()) or -1
                            if av2 > 0 then
                                if av1 + 1 == av2 then
                                    for cc = bb + 1, #group do
                                        av3 = (group[cc] and group[cc]:getCardValue()) or -1
                                        if av1 + 2 == av3 and #group > 3 then
                                            local card3 = table.remove(group, cc)
                                            local card2 = table.remove(group, bb)
                                            local card1 = table.remove(group, aa)
                                            local new_group = {card1, card2, card3}
                                            table.insert(temp_list, i + 1, new_group)
                                            has_new_group = true
                                            break
                                        end
                                        if av3 == -1 then
                                            break
                                        end
                                    end
                                end
                            end

                            if av2 == -1 or has_new_group then
                                break
                            end
                        end
                    else
                        break
                    end
                end
            end

            if group and #group > 3 then
                for aa = 1, #group do
                    local av1 = (group[aa] and group[aa]:getCardValue()) or -1
                    local av2 = (group[aa + 1] and group[aa + 1]:getCardValue()) or -1
                    if av1 ~= -1 and av1 == av2 and #group > 3 then
                        local new_group = {table.remove(group, aa), table.remove(group, aa)}
                        table.insert(temp_list, i + 1, new_group)
                    end
                end
            end
        end

        return temp_list
    end

    local function updatePos(group_list)
        dump(group_list,"group_list")
        local pos_idx = 0
        for a, group in ipairs(group_list) do
            for b, card in ipairs(group) do
                pos_idx = (a - 1) * 3 + b
                card:setPosIdx(pos_idx, tween)
            end
        end
        self:initPokerCardsTbl()
        self:centerAlign()
    end

    local function mergeSingle(group_list, isStrict)
        local single = 2
        local tTag = {}
        local do_break = false
        while single > 1 do
            single = 0
            for i = 1, #group_list do
                do_break = false
                if #group_list[i] == 1 then
                    tTag[i] = true
                    single = single + 1
                    for a = 1, i - 1 do
                        if tTag[a] and #group_list[a] < 3 then
                            table.insert(group_list[a], group_list[i][1])
                            table.remove(group_list, i)
                            tTag[i] = nil
                            single = single - 1
                            do_break = true
                            break
                        end
                    end
                end

                if do_break then
                    single = 2
                    break
                end
            end

            if isStrict and single == 1 then
                for single_idx, b in pairs(tTag) do
                    if b then
                        for a = 1, #group_list do
                            if group_list[a] and #group_list[a] < 3 then
                                table.insert(group_list[a], group_list[single_idx][1])
                                table.remove(group_list, single_idx)
                                return
                            end
                        end
                    end
                end
            end
        end
    end
    --dump(red_list,"red_list")
    local red_group = groupList(red_list)
    local black_group = groupList(black_list)

    tList = {}
    if #red_group > 0 and #black_group > 0 then
        if #red_group + #black_group > 12 then
            mergeSingle(red_group, false)
            mergeSingle(black_group, false)
        end

        if #red_group + #black_group > 12 then
            mergeSingle(red_group, true)
            mergeSingle(black_group, true)
        end

        while #red_group > 0 and #black_group > 0 do
            if red_group[1][1]:getCardValue() >= black_group[1][1]:getCardValue() then
                table.insert(tList, table.remove(black_group, 1))
            else
                table.insert(tList, table.remove(red_group, 1))
            end
        end

        while #red_group > 0 do
            table.insert(tList, table.remove(red_group, 1))
        end

        while #black_group > 0 do
            table.insert(tList, table.remove(black_group, 1))
        end

        if #tList > 12 then --还有一个单的？ 极限情况 2*8 + 1
            mergeSingle(tList, true)
        end

        if #tList > 12 then
            print('==============error list1===================')
            self:printGoup(tList)
        end
        local count = 0;
        for i = #tList, 1, -1 do
            local card = tList[i][1]:getCardValue()

            local cardColor = tList[i][1]:getCardColor()
            local isFeng = ((card == 7 or card == 8 or card == 9) and cardColor == 1)
            count = count + 1
            local blockFeng = false
            for j = #tList - count, 1, -1 do
                local pake = tList[j]
                blockFeng = pake and (pake[1]:getCardValue() == 7 or pake[1]:getCardValue() == 8 or pake[1]:getCardValue() == 9) and pake[1]:getCardColor() == 2
                if isFeng and blockFeng then
                    local tempB = tList[i]
                    local tempR =pake
                    tList[i] = tempR
                    tList[j] = tempB
                    break
                end
            end
        end
        count = 0
        for i = #tList, 1, -1 do
            local card = tList[i][1]:getCardValue()
            if card < 9 then
                local card = tList[i][1]:getCardValue()
                local isFeng = card == 4 or card == 5 or card == 6
                local cardColor = tList[i][1]:getCardColor()
                count = count + 1
                for j = #tList - count, 1, -1 do
                    local pake = tList[j]
                    local blockColor = pake[1]:getCardColor()
                    local blockFeng = pake and (pake[1]:getCardValue() == 4 or pake[1]:getCardValue() == 5 or pake[1]:getCardValue() == 6) and blockColor == cardColor
                    if isFeng  and blockFeng then
                        local tempB = tList[i-1]
                        if tempB then
                            local tempR =pake
                            tList[i-1] = tempR
                            tList[j] = tempB
                        end
                        break
                    end
                end
            end
        end
        count = 0
        for i = #tList, 1, -1 do
            local card = tList[i][1]:getCardValue()
            if card < 4 then
                local isFeng = card == 1 or card == 2 or card == 3
                local cardColor = tList[i][1]:getCardColor()
                count = count + 1
                for j = #tList - count, 1, -1 do
                    local pake = tList[j]
                    local blockColor = pake[1]:getCardColor()
                    local blockFeng = pake and (pake[1]:getCardValue() == 1 or pake[1]:getCardValue() == 2 or pake[1]:getCardValue() == 3) and blockColor == cardColor
                    if isFeng  and blockFeng then
                        local tempB = tList[i-1]
                        if tempB then
                            local tempR =pake
                            tList[i-1] = tempR
                            tList[j] = tempB
                        end
                        break
                    end
                end
            end
        end
        updatePos(tList)
    elseif #red_group > 0 then
        if #red_group > 12 then
            mergeSingle(red_group, false)
        end

        if #red_group > 12 then
            mergeSingle(red_group, true)
        end

        if #red_group > 12 then
            print('==============error list2===================')
            self:printGoup(red_group)
        end
        updatePos(red_group)
    elseif #black_group > 0 then
        if #black_group > 12 then
            mergeSingle(black_group, false)
        end

        if #black_group > 12 then
            mergeSingle(black_group, true)
        end

        if #black_group > 12 then
            print('==============error list3===================')
            self:printGoup(black_group)
        end
        updatePos(black_group)
    end
end

function NinetySixHandCards:printGoup(group_list)
    for a, group in ipairs(group_list) do
        print('========col========', a)
        for b, card in ipairs(group) do
            card:printMe()
        end
    end
end

--high  30   27  24  21  18  15  12  9  6  3
--mid   29   26  23  20  17  14  11  8  5  2
--low   28   25  22  19  16  13  10  7  4  1

--123， 456， 789， 11 12 13 顺子最大值
function NinetySixHandCards:getShunziMaxVal(val,color)
    local ret
    --if val >=7 and  color == 2 then
    --    ret = 13
    --elseif val <= 9 then
    --    ret = (math.floor((val - 1) / 3) + 1) * 3
    --else
    --    ret = 13
    --end
    if val <= 9 then
        ret = (math.floor((val - 1) / 3) + 1) * 3
    else
        ret = 13
    end
    return ret
end

function NinetySixHandCards:doTest()
    self.testCards = {}
    for i = 1, 19 do
        local idx = math.random(1, #self.logic.card_config)
        table.insert(self.testCards, self.logic.card_config[idx])
    end

    self.tPokerCards = {}
    for i, v in ipairs(self.testCards) do
        if i <= self.maxPoker then
            local poker = NinetySixPokerCard.new(self, self.panel, self.card_scale)
            poker:setCardId(v)
            poker:setPosIdx(i, false)
            poker:setState(2)
            poker:bindTouch()
            self.tPokerCards[i] = {poker = poker, pos_idx = i}
        end
    end
end

function NinetySixHandCards:initPokerPos()
    local start_y = 5
    local gap_y = 100
    self.gap_x = 100
    local start_x = self.gap_x * 4 + self.midWidth + 30
    local pos_x, pos_y, ZOder
    self.tPosMap = {}
    self.maxPoker = 36
    for i = 1, self.maxPoker do
        pos_x = start_x - (math.floor((i - 1) / 3) * self.gap_x)
        pos_y = start_y + ((i - 1) % 3) * gap_y
        local map = {index = i, pos = cc.p(pos_x, pos_y), zoder = self.maxPoker - i}
        table.insert(self.tPosMap, map)
    end
end

function NinetySixHandCards:getPosByIdx(idx)
    if idx < 0 or idx > self.maxPoker then
        assert(false, 'getPosByIdx out range, idx:' .. tostring(idx))
        return
    end

    local map = self.tPosMap[idx]
    return map
end

function NinetySixHandCards:calcNearestPosIdx(pos)
    local max_idx = 0
    local children = self.panel:getChildren()
    self.tPokerCards = {}
    for k, child in ipairs(children) do
        self.tPokerCards[child.pos_idx] = {poker = child, pos_idx = child.pos_idx}
        if child.pos_idx > max_idx then
            max_idx = child.pos_idx
        end
    end

    local len = 999999999
    local tmp = 0
    local idx = 0
    for i, v in ipairs(self.tPosMap) do
        tmp = cc.pGetDistance(pos, v.pos)
        if tmp < len then
            len = tmp
            idx = i
        end
    end

    local low_idx = math.floor((idx - 1) / 3) * 3 + 1
    local high_idx = low_idx + 2
    local max_low_idx = math.floor((max_idx - 1) / 3) * 3 + 4

    local temp_poker
    for i = low_idx, high_idx do
        temp_poker = self.tPokerCards[i]
        if temp_poker == nil then
            idx = i
            break
        end
    end

    if idx > max_low_idx then
        idx = max_low_idx
    end

    return idx
end

--消除扑克移除后出现的空列
function NinetySixHandCards:trimEmptyCol()
    local temp_poker
    for i = 37, 1, -3 do
        if self.tPokerCards[i + 1] and self.tPokerCards[i] == nil then
            self.tPokerCards[i] = self.tPokerCards[i + 1]
            self.tPokerCards[i].pos_idx = i
            self.tPokerCards[i + 1] = nil
        end

        if self.tPokerCards[i + 2] then
            if self.tPokerCards[i] == nil then
                self.tPokerCards[i] = self.tPokerCards[i + 2]
                self.tPokerCards[i].pos_idx = i
                self.tPokerCards[i + 2] = nil
            elseif self.tPokerCards[i + 1] == nil then
                self.tPokerCards[i + 1] = self.tPokerCards[i + 2]
                self.tPokerCards[i + 1].pos_idx = i + 1
                self.tPokerCards[i + 2] = nil
            end
        end

        temp_poker = self.tPokerCards[i]
        if temp_poker == nil then
            for ii = 36, i + 3, -1 do
                temp_poker = self.tPokerCards[ii]
                if temp_poker then
                    temp_poker.pos_idx = temp_poker.pos_idx - 3
                end
            end
        end
    end
end

function NinetySixHandCards:centerAlign()
    local count = 0
    for i = 1, 34, 3 do
        if self.tPokerCards[i] then
            count = (i + 2) / 3
        end
    end

    local pix = (9 - count) * self.gap_x / 2 + 10
    print("pix",pix)
    print("self.panel_pos.x",self.panel_pos.x)
    self.panel:runAction(cc.MoveTo:create(0.1, cc.p(self.panel_pos.x - pix, self.panel_pos.y)))
end

--high  30   27  24  21  18  15  12  9  6  3
--mid   29   26  23  20  17  14  11  8  5  2
--low   28   25  22  19  16  13  10  7  4  1

--high  33 30   27  24  21  18  15  12  9  6  3
--mid  32  29   26  23  20  17  14  11  8  5  2
--low  31  28   25  22  19  16  13  10  7  4  1
--手牌拖动
function NinetySixHandCards:pokerMove(poker, endPos)
    local old_idx = poker.pos_idx
    local new_idx = self:calcNearestPosIdx(endPos)
    local low_idx1 = math.floor((old_idx - 1) / 3) * 3 + 1
    local high_idx1 = low_idx1 + 2
    local low_idx2 = math.floor((new_idx - 1) / 3) * 3 + 1
    local high_idx2 = low_idx2 + 2
    self.tPokerCards[old_idx] = nil
    local temp = self.tPokerCards[1]
    --原来的列扑克下移
    local temp_poker
    for i = old_idx + 1, high_idx1 do
        temp_poker = self.tPokerCards[i]
        if temp_poker then
            temp_poker.pos_idx = temp_poker.pos_idx - 1
        else
            break
        end
    end
    self:updatePokerMap()
    --dump(self.tPokerCards,"self.tPokerCards")
    --新位置的扑克上移
    local left_move = false

    for i = new_idx, high_idx2 do
        temp_poker = self.tPokerCards[i]
        if temp_poker then
            if temp_poker.pos_idx == high_idx2 then
                left_move = true
            end
            temp_poker.pos_idx = temp_poker.pos_idx + 1
        else
            break
        end
    end
    if temp ==nil or  ((new_idx ==1 or new_idx ==2 or new_idx ==3) and temp and temp.poker:getPosition().x < endPos.x) then
        for k,v in pairs(self.tPokerCards)   do
            v.pos_idx = v.pos_idx + 3
        end
    else
        local temp_low
        if left_move then --新位置后面的扑克需整体左移
            local is_one = self.tPokerCards[old_idx + 1] == nil and self.tPokerCards[old_idx + 2] == nil
            for i = low_idx2 + 3, self.maxPoker do
                temp_poker = self.tPokerCards[i]
                temp_low = math.floor((i - 1) / 3) * 3 + 1
                --要移动的位置已经空了，不需要再移动
                if i == temp_low and (temp_poker == nil or (i == old_idx and is_one)) then
                    break
                end
                if temp_poker and temp_poker.poker.pos_idx ~= old_idx then
                    temp_poker.pos_idx = temp_poker.pos_idx + 3
                end
            end
        end
    end


    self:updatePokerMap()
    self.tPokerCards[new_idx] = {poker = poker, pos_idx = new_idx}

    self:trimEmptyCol()
    self:updatePokerMap()

    --检查是否还有超出边界
    local is_out_range = false
    for k, v in pairs(self.tPokerCards) do
        if v.pos_idx > self.maxPoker then
            is_out_range = true
            break
        end
    end
    print("is_out_range",is_out_range)
    if is_out_range then
        self:arrangeCards(true)
        return
    end

    self:updatePosIdx()
end

--合并短列
function NinetySixHandCards:mergeCol()
    local single_idx = {}
    local two_idx = {}

    for ii = 33, 1, -3 do
        if self.tPokerCards[ii] and self.tPokerCards[ii + 1] == nil and self.tPokerCards[ii + 2] == nil then
            table.insert(single_idx, ii)
        end

        if self.tPokerCards[ii] and self.tPokerCards[ii + 1] and self.tPokerCards[ii + 2] == nil then
            table.insert(two_idx, ii)
        end
    end

    while #single_idx > 0 and #two_idx > 0 do
        local idx1 = table.remove(single_idx)
        local idx2 = table.remove(two_idx)
        local obj = self.tPokerCards[idx1]
        self.tPokerCards[idx2 + 2] = {poker = obj.poker, pos_idx = idx2 + 2}
        self.tPokerCards[idx1] = nil
    end

    self:trimEmptyCol()
    self:updatePokerMap()
end
function NinetySixHandCards:outCardTest(viewId,cardId)
    dump(viewId,"outCardTest"..cardId)
    if viewId ~= 1 then
        return
    end
    --for _, poker in pairs(self.tPokerCards) do
    --    local huaSe = NinetySixPokerCard:calcHuaSe(cardId)
    --    local color = 1
    --    if huaSe == 0 or huaSe == 2 then
    --        color = 2
    --    end
    --    dump(poker.poker:getCardId(),"chugggpai==="..poker.poker:getCardColor())
    --    if tolua.isnull(poker.poker) == false and  cardId == poker.poker:getCardId() and color == poker.poker:getCardColor() then
    --        dump("chugyurtutyuggpai===")
    --        self.curOutPoker = poker.poker
    --        self:onOutCard(viewId,cardId)
    --        --poker.poker:removeFromParent()
    --        break
    --    end
    --
    --end
    --self:initPokerCardsTbl()
    --self:trimEmptyCol()
    --self:updatePosIdx()
    local tbl ={}
    table.insert(tbl,cardId)
    dump(tbl,"tbl=yy=====")
    self:removeCard(tbl)
    self:initPokerCardsTbl()
    self:trimEmptyCol()
    self:updatePosIdx()
end
function NinetySixHandCards:pokerMoveTest(poker, endPos)
    local old_idx = poker.pos_idx
    local new_idx = self:calcNearestPosIdx(endPos)
    local low_idx1 = math.floor((old_idx - 1) / 3) * 3 + 1
    local high_idx1 = low_idx1 + 2
    local low_idx2 = math.floor((new_idx - 1) / 3) * 3 + 1
    local high_idx2 = low_idx2 + 2
    self.tPokerCards[old_idx] = nil
    local temp = self.tPokerCards[1]
    --原来的列扑克下移
    local temp_poker
    for i = old_idx + 1, high_idx1 do
        temp_poker = self.tPokerCards[i]
        if temp_poker then
            temp_poker.pos_idx = temp_poker.pos_idx - 1
        else
            break
        end
    end
    self:updatePokerMap()
    --dump(self.tPokerCards,"self.tPokerCards")
    --新位置的扑克上移
    local left_move = false

    for i = new_idx, high_idx2 do
        temp_poker = self.tPokerCards[i]
        if temp_poker then
            if temp_poker.pos_idx == high_idx2 then
                left_move = true
            end
            temp_poker.pos_idx = temp_poker.pos_idx + 1
        else
            break
        end
    end
    if temp ==nil or  ((new_idx ==1 or new_idx ==2 or new_idx ==3) and temp and temp.poker:getPosition().x < endPos.x) then
        for k,v in pairs(self.tPokerCards)   do
            v.pos_idx = v.pos_idx + 3
        end
    else
        local temp_low
        if left_move then --新位置后面的扑克需整体左移
            local is_one = self.tPokerCards[old_idx + 1] == nil and self.tPokerCards[old_idx + 2] == nil
            for i = low_idx2 + 3, self.maxPoker do
                temp_poker = self.tPokerCards[i]
                temp_low = math.floor((i - 1) / 3) * 3 + 1
                --要移动的位置已经空了，不需要再移动
                if i == temp_low and (temp_poker == nil or (i == old_idx and is_one)) then
                    break
                end
                if temp_poker and temp_poker.poker.pos_idx ~= old_idx then
                    temp_poker.pos_idx = temp_poker.pos_idx + 3
                end
            end
        end
    end


    self:updatePokerMap()
    self.tPokerCards[new_idx] = {poker = poker, pos_idx = new_idx}

    self:trimEmptyCol()
    self:updatePokerMap()

    --检查是否还有超出边界

    self:arrangeCards(true)
    self:updatePosIdx()
end
return NinetySixHandCards
