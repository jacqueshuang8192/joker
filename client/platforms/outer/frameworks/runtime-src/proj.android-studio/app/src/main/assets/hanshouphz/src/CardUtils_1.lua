local scheduler = require(cc.PACKAGE_NAME..".scheduler")
local CardUtils = class("CardUtils")

function CardUtils:ctor()
end


function CardUtils:GetWeaveHuXi(WeaveItem, isSelf)
    local huxiCount = 0
    local cardColor = math.floor(WeaveItem.cbCardList[1] / 16)
    local cbValue = WeaveItem.cbCardList[1] % 16
    local isBack = true
    for i,v in ipairs(WeaveItem.cbCardList) do
        if v ~= 0 then
            isBack = false
        end
    end
    if isBack then
        return 0
    end
    if WeaveItem.cardType == g_501.t_ti then
        print("垅")
        if cardColor == 1 then
            huxiCount = 12
        elseif cardColor == 0 then
            huxiCount = 9
        end
    elseif WeaveItem.cardType == g_501.t_pao then
        print("g_501.t_pao")
        if g_501.isHongPeng and (cbValue == 2 or cbValue == 7 or cbValue == 10) then
            if cardColor == 1 then
                huxiCount = 12
            elseif cardColor == 0 then
                huxiCount = 9
            end
        else
            if cardColor == 1 then
                huxiCount = 9
            elseif cardColor == 0 then
                huxiCount = 6
            end
        end
    elseif WeaveItem.cardType == g_501.t_wei then
        print("g_501.t_wei")
        local anWei = true
        for i,v in ipairs(WeaveItem.weaveCard or {}) do
            if v ~= 0x00 then
                anWei = false
                break
            end
        end
        if cardColor == 1 then
            huxiCount = 6
        elseif cardColor == 0 then
            huxiCount = 3
        end
        if anWei and isSelf then
            huxiCount = 0
        end
    elseif WeaveItem.cardType == g_501.t_sao_bad then
        print("g_501.t_sao_bad")
        if cardColor == 1 then
            huxiCount = 6
        elseif cardColor == 0 then
            huxiCount = 3
        end
    elseif WeaveItem.cardType == g_501.t_kan then
        print("坎")
        if cardColor == 1 then
            huxiCount = 6
        elseif cardColor == 0 then
            huxiCount = 3
        end
    elseif WeaveItem.cardType == g_501.t_peng then
        print("碰")
        if g_501.isHongPeng and (cbValue == 2 or cbValue == 7 or cbValue == 10) then
            if cardColor == 1 then
                huxiCount = 6
            elseif cardColor == 0 then
                huxiCount = 3
            end
        else
            if cardColor == 1 then
                huxiCount = 3
            elseif cardColor == 0 then
                huxiCount = 1
            end
        end
        -- end
    elseif WeaveItem.cardType == g_501.t_chi then
        print("吃")
        local cbValue = {}
        for i=1,3 do
            cbValue[i] = WeaveItem.cbCardList[i] % 16
        end
        table.sort(cbValue)
        --一二三 吃
        if cbValue[1]==1 and cbValue[2]==2 and cbValue[3]==3 then
            if cardColor == 1 then
                huxiCount = 6
            elseif cardColor == 0 then
                huxiCount = 3
            end
        end
        --二七十 吃
        if cbValue[1]==2  and cbValue[2]==7 and cbValue[3]==10 then
            if cardColor == 1 then
                huxiCount = 6
            elseif cardColor == 0 then
                huxiCount = 3
            end
        end
       --一五十 吃
        -- if cbValue[1]==1  and cbValue[2]==5 and cbValue[3]==10 and g_mainScene.bRoomTypeYWS == 1 then
        --     if cardColor == 1 then
        --         huxiCount = 6
        --     elseif cardColor == 0 then
        --         huxiCount = 3
        --     end
        -- end
    end
    -- print("huxiCount =",huxiCount)
    return huxiCount
end

function CardUtils:getPokerCard( pokerCards, ziPaiCard )
    local isRed_2 = false
    if ziPaiCard > 0x10 then--方块 红 大字
        isRed_2 = true
    else
        isRed_2 = false
    end
    for idx, card in ipairs(pokerCards) do
        local color_1 = bit.band(card, 0xf0)
        local isRed_1 = false
        if color_1 == 0x00 then--方块 红 大字
            isRed_1 = true
        elseif color_1 == 0x10 then--梅花 黑 小字
            isRed_1 = false
        elseif color_1 == 0x20 then--红桃 红 大字
            isRed_1 = true
        elseif color_1 == 0x30 then--黑桃 黑 小字
            isRed_1 = false
        end
        if isRed_1 == isRed_2 then
            if card % 16 == ziPaiCard % 16 then
                table.remove(pokerCards, idx)
                return card
            end
        end
    end
    assert(false, "error: not ziPaiCard")
end

function CardUtils:getPokerCardByZiPaiCard( ziPaiCard )
    local color_1 = bit.band(ziPaiCard, 0xf0)
    if color_1 == 0x00 then--小字转黑桃
        return ziPaiCard % 16 + 48
    elseif color_1 == 0x10 then--大字转红桃
        return ziPaiCard % 16 + 32
    end
end
--[[
    @desc: 
    author:{author}
    time:2020-10-23 12:03:39
    --@pokerCards: 
    @return:
]]-------------------------------------------------
function CardUtils:getClientCards( pokerCards )
    local newCards = {
        [1] = {},
        [2] = {},
    }
    for i,poker in ipairs(pokerCards) do
        local card, color = self:getClientCard( poker )
        if not newCards[color][card] then
            newCards[color][card] = {}
        end
        table.insert(newCards[color][card], poker)
        -- if #newCards[color][card] >= 1
    end

    for card, pokers in pairs(newCards[1]) do
        if #pokers >= 3 then
            newCards[1][card] = nil
        end
    end
    for card, pokers in pairs(newCards[2]) do
        if #pokers >= 3 then
            newCards[2][card] = nil
        end
    end
    return newCards
end

function CardUtils:getClientCard( poker )
    local color_1 = bit.band(poker, 0xf0)
    local color = 1
    if color_1 == 0x00 then--方块 红 大字
        color = 2
    elseif color_1 == 0x10 then--梅花 黑 小字
        color = 1
    elseif color_1 == 0x20 then--红桃 红 大字
        color = 2
    elseif color_1 == 0x30 then--黑桃 黑 小字
        color = 1
    end
    local card = poker % 16
    return card, color
end

function CardUtils:getChiData( pokerCards, pokerChi )
    
    local card, color = self:getClientCard( pokerChi )
    local cardChi = {
        card = card,
        poker = pokerChi,
        color = color,
    }
    local ClientCards = self:getClientCards( pokerCards )
    
    local result = {}
    local clientCards = ClientCards[cardChi.color]
    local result2710 = self:_find2710(clientCards, cardChi)
    for i,v in ipairs(result2710) do
        
        local key = table.concat(v)
        result[key] = v
    end
    
    local clientCards = ClientCards[cardChi.color]
    local resultShunZi = self:_findShunZi(clientCards, cardChi)
    for i,v in ipairs(resultShunZi) do
        local key = table.concat(v)
        result[key] = v
    end

    local resultDaXiaoChi = self:_findDaXiaoChi(ClientCards, cardChi)
    for i,v in ipairs(resultDaXiaoChi) do
        local key = table.concat(v)
        result[key] = v
    end

    
    local newResult = {}
    for k,v in pairs(result) do
        table.insert(newResult, v)
    end
    self:checkBiPai(newResult, pokerCards, pokerChi )
    for idx,v in ipairs(newResult) do
        table.insert(newResult[idx], 1, pokerChi)
    end
    return newResult
end

--检查是否有比的牌 但是组不成比牌条件比如 {1，2，3，1，17}这手牌只能吃1，17，吃了123会剩下 1 这张比牌不合规矩
function CardUtils:checkBiPai(newResult, orlPokerCards, pokerChi )
    for index, cards in ipairs(newResult) do
        local pokerCards = clone(orlPokerCards)
        for _,poker1 in ipairs(cards) do--从手牌删除吃牌 比牌数据 再寻找比牌数据
            for idx, poker in ipairs(pokerCards) do
                if poker == poker1 then
                    table.remove(pokerCards, idx)
                    break
                end
            end
        end
        local curOutCard--从手牌删除可以吃牌那一张 在寻找比牌数据 如果没有说明构不成比牌条件
        for idx, poker in ipairs(pokerCards) do
            if poker == pokerChi then
                table.remove(pokerCards, idx)
                curOutCard = poker
                break
            end
        end
        if curOutCard then
            local biResult = self:getChiData( pokerCards, curOutCard )
            if #biResult < 1 then
                table.remove(newResult, index)
                self:checkBiPai(newResult, orlPokerCards, pokerChi )
                break
            end
        end
    end
end

function CardUtils:_findDaXiaoChi( ClientCards, cardChi )
    local card = cardChi.card
    local result = {}

    local color = cardChi.color
    local colorTab = {
        1,2
    }
    for i,v in ipairs(colorTab) do
        if v == color then
            table.remove(colorTab, i)
        end
    end
    local remainColor = colorTab[1]--找到可以大小吃的花色

    if ClientCards[1][card] and ClientCards[2][card] then
        for i,v1 in ipairs(ClientCards[1][card]) do
            for i,v2 in ipairs(ClientCards[2][card]) do
                table.insert(result, {v1, v2})
            end
        end
        if #ClientCards[remainColor][card] == 2 then
            table.insert(result, table.slice(ClientCards[remainColor][card], 1, 2))
        end
    else
        if ClientCards[remainColor][card] and #ClientCards[remainColor][card] == 2 then
            table.insert(result, table.slice(ClientCards[remainColor][card], 1, 2))
        end
    end
    return result
end

function CardUtils:_find2710(clientCards, cardChi)
    local result = {}
    local tabl = {
        2,
        7,
        10,
    }
    for i,v in ipairs(tabl) do
        if v == cardChi.card then
            table.remove(tabl, i)
        end
    end
    if #tabl == 2 then
        while true do
            local newResult = {}
            for idx, card in ipairs(tabl) do
                if clientCards[card] then
                    table.insert(newResult, clientCards[card][1])
                end
            end
            if #newResult == 2 then--从手牌中删除找到的2-7-10
                for idx, card in ipairs(tabl) do
                    table.remove(clientCards[card], 1)
                    if #clientCards[card] == 0 then
                        clientCards[card] = nil
                    end
                end
                table.insert(result, newResult)
            else
                break
            end
        end
    end
    return result
end

function CardUtils:_findShunZi( clientCards, cardChi )
    local card = cardChi.card
    local result = {}
    local startIdx = card - 2
    local endIdx = card + 2 - 1
    local orlPokers = clientCards[card]
    clientCards[card] = nil
    --card == 5
    --3   4   5
    --    4   5   6
    --        5   6   7
    for idx = startIdx, endIdx do
        local sum = 1
        if idx+1 == card then
            sum = 2
        end
        if clientCards[idx] and clientCards[idx + sum] then
            for _, poker_1 in ipairs(clientCards[idx]) do
                for _, poker_2 in ipairs(clientCards[idx + sum]) do
                    local newResult = {}
                    table.insert(newResult, poker_1)
                    table.insert(newResult, poker_2)
                    table.insert(result, newResult)
                end
            end
        end
    end
    clientCards[card] = orlPokers
    return result
end
-----------------------------------------------------

function CardUtils:findRemain( ClientCards, result )
    local remainResult = {}
    for card, pokers in pairs(ClientCards[1]) do
        table.insert(remainResult, pokers[1])
        -- if #remainResult == 4 then
        --     table.insert(result, remainResult)
        --     remainResult = {}
        -- end
    end
    -- if #remainResult == 4 then
    --     table.insert(result, remainResult)
    -- end

    -- local remainResult = {}
    for card, pokers in pairs(ClientCards[2]) do
        table.insert(remainResult, pokers[1])
        -- if #remainResult == 4 then
        --     table.insert(result, remainResult)
        --     remainResult = {}
        -- end
    end
    table.sort(remainResult)
    while true do
        local tab = table.splice(remainResult, 1 , 3)
        if #tab >= 1 then
            table.insert(result, tab)
        else
            break
        end
    end
    -- if #remainResult > 0 then
    --     table.insert(result, remainResult)
    -- end
end

function CardUtils:findResultByCount( ClientCards, maxCount, result )
    for card, pokers in pairs(ClientCards[1]) do
        if #pokers == maxCount then
            if maxCount >= 3 then
                pokers._type = g_501.t_wei
            end
            table.insert(result, pokers)
            ClientCards[1][card] = nil
        end
    end
    for card, pokers in pairs(ClientCards[2]) do
        if #pokers == maxCount then
            if maxCount >= 3 then
                pokers._type = g_501.t_wei
            end
            table.insert(result, pokers)
            ClientCards[2][card] = nil
        end
    end
end

function CardUtils:find2710(ClientCards, color, result, count)
    local clientCards = ClientCards[color]
    local newresult = {}
    local tabl = {2,7,10}
    for idx, card in ipairs(tabl) do
        if clientCards[card] then
            table.insert(newresult, clientCards[card][1])
        end
    end
    if #newresult == count then--从手牌中删除找到的2-7-10
        for idx, card in ipairs(tabl) do
            if ClientCards[color][card] then
                table.remove(ClientCards[color][card], 1)
                if #ClientCards[color][card] == 0 then
                    ClientCards[color][card] = nil
                end
            end
        end
        table.insert(result, newresult)
    end
    -------------------------------------
    local clientCards = ClientCards[color]
    local newresult = {}
    local tabl = {1,2,3}
    for idx, card in ipairs(tabl) do
        if clientCards[card] then
            table.insert(newresult, clientCards[card][1])
        end
    end
    if #newresult == count then--从手牌中删除找到的2-7-10
        for idx, card in ipairs(tabl) do
            if ClientCards[color][card] then
                table.remove(ClientCards[color][card], 1)
                if #ClientCards[color][card] == 0 then
                    ClientCards[color][card] = nil
                end
            end
        end
        table.insert(result, newresult)
    end
end

function CardUtils:findDaXiao(ClientCards, maxCount, result)
    for card, pokers in pairs(ClientCards[1]) do
        if ClientCards[2][card] and #ClientCards[2][card] + #ClientCards[1][card] == maxCount then
            local newresult = tableConcat(ClientCards[1][card], ClientCards[2][card])
            ClientCards[1][card] = nil
            ClientCards[2][card] = nil
            table.insert(result, newresult)
        end
    end
end

function CardUtils:findShunZi( ClientCards, color, result )
    local clientCards = ClientCards[color]
    for card, pokers in pairs(clientCards) do
        if clientCards[card] and clientCards[card + 1] and clientCards[card + 2] then
            local newresult = {}
            table.insert(newresult, clientCards[card][1])
            table.insert(newresult, clientCards[card + 1][1])
            table.insert(newresult, clientCards[card + 2][1])
            table.remove(ClientCards[color][card], 1)
            table.remove(ClientCards[color][card + 1], 1)
            table.remove(ClientCards[color][card + 2], 1)
            if #ClientCards[color][card] == 0 then
                ClientCards[color][card] = nil
            end
            if #ClientCards[color][card + 1] == 0 then
                ClientCards[color][card + 1] = nil
            end
            if #ClientCards[color][card + 2] == 0 then
                ClientCards[color][card + 2] = nil
            end
            table.insert(result, newresult)
        end
    end
end

function CardUtils:findShunZiLuan( ClientCards, color, result )
    local clientCards = ClientCards[color]
    for card, pokers in pairs(clientCards) do
        local shunZi1 = clientCards[card] or {}
        local shunZi2 = clientCards[card + 1] or {}
        local shunZi3 = clientCards[card + 2] or {}
        if #shunZi1 + #shunZi2 + #shunZi3 >= 2 then
            local newresult = {}
            if shunZi1[1] then
                table.insert(newresult, clientCards[card][1])
                table.remove(ClientCards[color][card], 1)
                if #ClientCards[color][card] == 0 then
                    ClientCards[color][card] = nil
                end
            end
            if shunZi2[1] then
                table.insert(newresult, clientCards[card + 1][1])
                table.remove(ClientCards[color][card + 1], 1)
                if #ClientCards[color][card + 1] == 0 then
                    ClientCards[color][card + 1] = nil
                end
            end
            if shunZi3[1] then
                table.insert(newresult, clientCards[card + 2][1])
                table.remove(ClientCards[color][card + 2], 1)
                if #ClientCards[color][card + 2] == 0 then
                    ClientCards[color][card + 2] = nil
                end
            end
            table.insert(result, newresult)
        end
    end
end


function CardUtils:shuffle( cards )
    -- for (local j, x, i = v.length; i; j =, x = v[i=1-1], v[i] = v[j], v[j] = x)
    for i, v in ipairs(cards) do
        local j = math.random(i, #cards)
        local tmp = cards[j]
        cards[j] = cards[i]
        cards[i] = tmp
    end
    cards = table.slice(cards,1,21)
    return cards
end

function CardUtils:getCurhandCard( pokerCards )
    local result = {}
    local ClientCards = {
        [1] = {},
        [2] = {},
    }
    for i,poker in ipairs(pokerCards) do
        local card, color = self:getClientCard( poker )
        if not ClientCards[color][card] then
            ClientCards[color][card] = {}
        end
        table.insert(ClientCards[color][card], poker)
    end

    
    -- self:findResultByCount(ClientCards, 4, result)
    -- self:findResultByCount(ClientCards, 3, result)
    -- -- self:findDaXiao(ClientCards, 4, result)

    -- self:find2710(ClientCards, 1, result, 3)
    -- self:find2710(ClientCards, 1, result, 3)
    -- self:find2710(ClientCards, 2, result, 3)
    -- self:find2710(ClientCards, 2, result, 3)

    -- self:findDaXiao(ClientCards, 3, result)
    -- self:findShunZi(ClientCards, 1, result)
    -- self:findShunZi(ClientCards, 2, result)

    -- self:find2710(ClientCards, 1, result, 2)
    -- self:find2710(ClientCards, 1, result, 2)
    -- self:find2710(ClientCards, 2, result, 2)
    -- self:find2710(ClientCards, 2, result, 2)
    
    -- self:findResultByCount(ClientCards, 2, result)
    -- self:findDaXiao(ClientCards, 2, result)
    -- self:findShunZiLuan(ClientCards, 1, result)
    -- self:findShunZiLuan(ClientCards, 2, result)
    -- self:findRemain( ClientCards, result )
    self:findResultByCount(ClientCards, 4, result)
    self:findResultByCount(ClientCards, 3, result)
    self:findDaXiao(ClientCards, 4, result)
    self:findDaXiao(ClientCards, 3, result)
    self:findResultByCount(ClientCards, 2, result)
    self:findDaXiao(ClientCards, 2, result)
    self:findResultByCount(ClientCards, 1, result)
    self:findRemain( ClientCards, result )
    table.sort(result, function(a, b)
        return a[1] % 16 < b[1] % 16
    end)
    local newPokers = {}
    for i,pokers in ipairs(result) do
        for i,poker in ipairs(pokers) do
            table.insert(newPokers, poker)
        end
    end
    table.sort(newPokers)
    table.sort(pokerCards)
    for i,v in ipairs(pokerCards) do
        if pokerCards[i] ~= newPokers[i] then
            -- assert(false, "pokerCards[i] ~= newPokers[i]")
        end
    end
    if #result > 10 then
        dump(pokerCards)
        -- assert(false, "#result > 10")
    end
    return result
end

local cards = {
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,--方块
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,--梅花
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,--红桃
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,--黑桃
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,--方块
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,--梅花
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,--红桃
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,--黑桃
}

-- for i=1,1000 do
--     print(i)
--     cards = CardUtils:shuffle(cards)
--     CardUtils:getCurhandCard(cards, 9, 5)
-- end
return CardUtils