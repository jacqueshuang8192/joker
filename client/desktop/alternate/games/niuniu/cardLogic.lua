--
-- Author: 张鸿鹏
-- Date: 2017-08-02 16:11:08
--
local cardLogic = class('cardLogic')

function cardLogic:GetCardLogicValue(card)
    local card = self:getValue(card)
    if card == 14 then
        return 1
    elseif card > 10 then
        return 10
    end

    return card
end

function cardLogic:getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
function cardLogic:getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 1 then
        value = 14
    end

    return value
end

function cardLogic:getallfans(handcards)
    local outcard = {}
    local fan = 1

    local fan, cards = self:countSpecialFan(handcards)

    if fan then
        return cards, fan
    end

    local handCardCount = #handcards
    for i = 1, handCardCount do
        for j = i + 1, handCardCount do
            for k = j + 1, handCardCount do
                outcard = {}
                do
                    table.insert(outcard, handcards[i])
                    table.insert(outcard, handcards[j])
                    table.insert(outcard, handcards[k])

                    if (self:logic_cardsum(outcard)) % 10 ~= 0 and GAME_CONFIG['无花牛牛'] ~= true then
                        goto continue
                    end

                    if
                        (self:logic_cardsum(outcard)) % 10 ~= 0 and
                            (self:GetCardLogicValue(handcards[i]) ~= self:GetCardLogicValue(handcards[j]) or
                                self:GetCardLogicValue(handcards[i]) ~= self:GetCardLogicValue(handcards[k])) and
                            GAME_CONFIG['无花牛牛'] == true
                     then
                        goto continue
                    end

                    local fan, cards = self:countFan(handcards, outcard)
                    outcard = cards or outcard
                    return outcard, fan
                    -- goto _return
                end

                ::continue::
            end
        end
    end

    -- ::_return::
    return outcard, fan or 1
end

function cardLogic:countSpecialFan(handcards)
    if self:has_sishida(handcards) and GAME_CONFIG and GAME_CONFIG['四十大'] then
        return CARDKIND_SISHIDA, handcards
    elseif self:has_wuxiaoniu(handcards) and GAME_CONFIG and GAME_CONFIG['五小牛'] then
        return CARDKIND_WUXIAONIU, handcards
    elseif self:has_sizha(handcards) and GAME_CONFIG and GAME_CONFIG['四炸'] then
        local _, boomCards = self:has_sizha(handcards)

        return CARDKIND_SIZHA, boomCards
    elseif self:has_huluniu(handcards) and GAME_CONFIG and GAME_CONFIG['葫芦牛'] then
        return CARDKIND_HULUNIU, handcards
    elseif self:has_tonghuaniu(handcards) and GAME_CONFIG and GAME_CONFIG['同花牛'] then
        return CARDKIND_TONGHUANIU, handcards
    elseif self:has_wuhuaniu(handcards) and GAME_CONFIG and GAME_CONFIG['五花牛'] then
        return CARDKIND_WUHUA, handcards
    elseif self:has_shunziniu(handcards) and GAME_CONFIG and GAME_CONFIG['顺子牛'] then
        return CARDKIND_SHUNZI, handcards
    end
end

function cardLogic:countFan(handcards, outcards)
    local goldniu_card_type = 0

    if GAME_CONFIG['无花牛牛'] == true then
        local card_count_btl = {}
        local goldniu_card = 0
        local resetcardLogicSum = 0

        for _, value in ipairs(handcards) do
            local card = self:GetCardLogicValue(value)
            card_count_btl[card] = (card_count_btl[card] or 0) + 1
        end

        for card, cardnum in pairs(card_count_btl) do
            if cardnum == 3 then
                goldniu_card = card
            else
                resetcardLogicSum = resetcardLogicSum + card * cardnum
            end
        end

        if goldniu_card > 0 then
            goldniu_card_type = resetcardLogicSum % 10 + 1
        end

        if resetcardLogicSum == 10 then
            goldniu_card_type = 11
        end
    end

    if goldniu_card_type == 0 then
        if self:logic_cardsum(outcards) % 10 ~= 0 then --手牌凑不成整数
            return 1
        elseif self:logic_cardsum(handcards) % 10 == 0 then
            return 11
        else
            return self:logic_cardsum(handcards) % 10 + 1
        end
    else
        local normal_card_type = 0 ---self:logic_cardsum(handcards)%10 + 1

        if self:logic_cardsum(outcards) % 10 ~= 0 then --手牌凑不成整数
            normal_card_type = 0
        elseif self:logic_cardsum(handcards) % 10 == 0 then
            normal_card_type = 11
        else
            normal_card_type = self:logic_cardsum(handcards) % 10 + 1
        end

        --正常算法有牛的情况下
        if self:logic_cardsum(outcards) % 10 == 0 then
            return normal_card_type > goldniu_card_type and normal_card_type or goldniu_card_type
        end

        return goldniu_card_type
    end
end

function cardLogic:logic_cardsum(outcard)
    local cardLogicSum = 0

    for _, value in ipairs(outcard) do
        cardLogicSum = self:GetCardLogicValue(value) + cardLogicSum
    end

    return cardLogicSum
end

--判断是否有五小牛
function cardLogic:has_wuxiaoniu(handcards)
    local cardLogicSum = 0
    for i, v in ipairs(handcards) do
        cardLogicSum = cardLogicSum + self:GetCardLogicValue(v)
    end

    if cardLogicSum >= 10 then
        return false
    end

    return true
end

--判断是否有五小牛
function cardLogic:has_sishida(handcards)
    local cardLogicSum = 0
    for i, v in ipairs(handcards) do
        cardLogicSum = cardLogicSum + self:GetCardLogicValue(v)
    end

    if cardLogicSum >= 40 then
        return true
    end

    return false
end

--判断是否有五花牛
function cardLogic:has_wuhuaniu(handcards)
    for i, v in ipairs(handcards) do
        if self:getValue(v) <= 10 or self:getValue(v) == 14 then
            return false
        end
    end

    return true
end

--判断是否有四炸
function cardLogic:has_sizha(handcards)
    local sameCardCount
    local sameCardBox = {}

    for _, v in ipairs(handcards) do
        sameCardBox[self:getValue(v)] = (sameCardBox[self:getValue(v)] or 0) + 1
    end

    for card, cardnum in pairs(sameCardBox) do
        if cardnum == 4 then
            local boomCards = {}
            for _, v in ipairs(handcards) do
                if self:getValue(v) == card then
                    table.insert(boomCards, v)
                end
            end

            return true, boomCards
        end
    end

    return false
end

--判断是否有顺子牛
function cardLogic:has_shunziniu(cards)
    --此方法为判断一个数组中是否有一段连续次数为5的数字，只能用于判断单个元素的连续性如23456，112233则无法判断

    local m = {}

    for _, v in ipairs(cards) do
        local cardValue = self:getValue(v)
        if cardValue == 14 then
            table.insert(m, 1)
        end

        table.insert(m, cardValue)
    end

    local previousValue = -1
    local seriesTimes = 1
    table.sort(m)

    for i, value in ipairs(m) do
        if value == previousValue + 1 then
            seriesTimes = seriesTimes + 1 --遇到连续的就加连续次数
        else
            seriesTimes = 1 --遇到不连续的就重置连续次数
        end

        previousValue = value
    end

    if seriesTimes == 5 then
        return true
    end

    -- for i = 0,19 do

    --     if  m[i] and m[i] > 1 then
    --         return false;
    --     end

    --     if isBegin then
    --         if m[i] == 1 then
    --             c = c + 1
    --             if c == 5 then
    --                 return true
    --             end

    --         else
    --             return false;
    --         end

    --     else
    --         if m[i] == 1 then
    --             isBegin = true
    --             c = c + 1
    --         end
    --     end

    -- end

    return false
end

--判断是否有同花牛
function cardLogic:has_tonghuaniu(cards)
    local hua = -1

    for _, v in pairs(cards) do
        local huaTemp = self:getVariety(v)

        if hua > -1 and hua ~= huaTemp then
            return false
        end

        hua = huaTemp
    end

    return true
end

--判断是否有葫芦牛
function cardLogic:has_huluniu(cards)
    local m_v1 = {}

    for _, v in pairs(cards) do
        local cardValue = self:getValue(v)
        m_v1[cardValue] = (m_v1[cardValue] or 0) + 1
    end

    local m_v1Size = table.nums(m_v1)
    for cardValue, cardNum in pairs(m_v1) do
        if cardNum == 3 and m_v1Size == 2 then
            return true
        end
    end

    return false
end

return cardLogic
