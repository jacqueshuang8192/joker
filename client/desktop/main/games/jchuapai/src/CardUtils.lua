-- --扑克数据
-- const BYTE CGameLogic::m_bCardListData[CARD_COUNT] =
-- {
--  0x01,0x01,0x01,0x11,0x11,0x02,0x02,0x02,0x02,0x02, --一、二
--  0x03,0x03,0x03,0x13,0x13,0x04,0x04,0x04,0x04,0x04, --三、四
--  0x05,0x05,0x05,0x15,0x15,0x06,0x06,0x06,0x06,0x06, --五、六
--  0x07,0x07,0x07,0x17,0x17,0x08,0x08,0x08,0x08,0x08, --七、八
--  0x09,0x09,0x09,0x19,0x19,0x0a,0x0a,0x0a,0x0a,0x0a, --九、十

--  0x21,0x21,0x21,0x21,0x21,0x22,0x22,0x22,0x22,0x22, --孔、已
--  0x23,0x23,0x23,0x23,0x23,0x24,0x24,0x24,0x24,0x24, --话、千
--  0x25,0x25,0x25,0x25,0x25,0x26,0x26,0x26,0x26,0x26, --土、子

--  0x27,0x27,0x27,0x27,0x27,0x28,0x28,0x28,0x28,0x28, --上、大
--  0x29,0x29,0x29,0x29,0x29,0x2a,0x2a,0x2a,0x2a,0x2a, --人、可
--  0x2b,0x2b,0x2b,0x2b,0x2b,0x2c,0x2c,0x2c,0x2c,0x2c, --知、礼

--  0x2d,0x2d --别杠(赖子)
-- };
local CardUtils = class("CardUtils")
local Magic_Card = 0x2d

--根据点数统计牌
function CardUtils:getSameCard(cards)
    local newCards = {}
    for _, card in pairs(cards) do
        if newCards[card] then
            newCards[card] = newCards[card] + 1
        else
            newCards[card] = 1
        end
    end

    -- local newCards = {}
    -- for _, card in pairs(cards) do
    --     local key = card
    --     if key <= 25 then
    --         key = key & 16
    --     end
    --     if newCards[key] then
    --         newCards[key] = {}
    --     end
    --     table.insert(newCards[key], card)
    -- end

    local newCards1 = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
    }
    for card, count in pairs(newCards) do
        table.insert(newCards1[count], card)
    end
    return newCards1
end

function CardUtils:GetCardLogicValue( cbCardData )
	if (Magic_Card == cbCardData) then
		return 23
	end
	if not cbCardData then
		return 0	
	end
	local cbCardValue = bit.band(cbCardData, 0x0F)
	local cbCardColor = bit.band(cbCardData, 0xF0)
	if (cbCardColor == 0x00 or cbCardColor == 0x10) then
		return cbCardValue
	elseif (cbCardColor == 0x20) then
		return cbCardValue + 10
	end
	return 0	
end

--孔乙己
function CardUtils:_findKongYiJi(yiJvHua, oneAndTwoCards)
    local result = {}
    local count1 = oneAndTwoCards[0x01] or 0
    local count4 = oneAndTwoCards[0x11] or 0
    local count2 = oneAndTwoCards[0x21] or 0
    local count3 = oneAndTwoCards[0x22] or 0
    if count1 + count2 + count3 + count4 >= 3 then
        self:setRetult( result, count3, 0x22, oneAndTwoCards )
        self:setRetult( result, count1, 0x01, oneAndTwoCards )
        self:setRetult( result, count4, 0x11, oneAndTwoCards )
        self:setRetult( result, count2, 0x21, oneAndTwoCards )
        table.insert(yiJvHua, result)
    end
    return result
end

--化三千
function CardUtils:_findHuaSanQian(yiJvHua, oneAndTwoCards)
    local result = {}
    local count1 = oneAndTwoCards[0x03] or 0
    local count4 = oneAndTwoCards[0x13] or 0
    local count2 = oneAndTwoCards[0x23] or 0
    local count3 = oneAndTwoCards[0x24] or 0
    if count1 + count2 + count3 + count4 >= 3 then
        self:setRetult( result, count3, 0x24, oneAndTwoCards )
        self:setRetult( result, count1, 0x03, oneAndTwoCards )
        self:setRetult( result, count4, 0x13, oneAndTwoCards )
        self:setRetult( result, count2, 0x23, oneAndTwoCards )
        table.insert(yiJvHua, result)
    end
    return result
end

--十七土
function CardUtils:_findShiQiTu(yiJvHua, oneAndTwoCards)
    local result = {}
    local count1 = oneAndTwoCards[0x07] or 0
    local count4 = oneAndTwoCards[0x17] or 0
    local count2 = oneAndTwoCards[0x0a] or 0
    local count3 = oneAndTwoCards[0x25] or 0
    if count1 + count2 + count3 + count4 >= 3 then
        self:setRetult( result, count3, 0x25, oneAndTwoCards )
        self:setRetult( result, count1, 0x07, oneAndTwoCards )
        self:setRetult( result, count4, 0x17, oneAndTwoCards )
        self:setRetult( result, count2, 0x0a, oneAndTwoCards )
        table.insert(yiJvHua, result)
    end
    return result
end

--八九子
function CardUtils:_find89Zi(yiJvHua, oneAndTwoCards)
    local result = {}
    local count1 = oneAndTwoCards[0x09] or 0
    local count4 = oneAndTwoCards[0x19] or 0
    local count2 = oneAndTwoCards[0x08] or 0
    local count3 = oneAndTwoCards[0x26] or 0
    if count1 + count2 + count3 + count4 >= 3 then
        self:setRetult( result, count3, 0x26, oneAndTwoCards )
        self:setRetult( result, count1, 0x09, oneAndTwoCards )
        self:setRetult( result, count4, 0x19, oneAndTwoCards )
        self:setRetult( result, count2, 0x08, oneAndTwoCards )
        table.insert(yiJvHua, result)
    end
    return result
end

--可知礼
function CardUtils:_findKeZhiLi(yiJvHua, oneAndTwoCards)
    local result = {}
    local count1 = oneAndTwoCards[0x2a] or 0
    local count2 = oneAndTwoCards[0x2b] or 0
    local count3 = oneAndTwoCards[0x2c] or 0
    if count1 + count2 + count3 >= 3 then
        self:setRetult( result, count3, 0x2c, oneAndTwoCards )
        self:setRetult( result, count2, 0x2b, oneAndTwoCards )
        self:setRetult( result, count1, 0x2a, oneAndTwoCards )
        table.insert(yiJvHua, result)
    end
    return result
end

--上大人
function CardUtils:_findShangDaRen(yiJvHua, oneAndTwoCards)
    local result = {}
    local count1 = oneAndTwoCards[0x27] or 0
    local count2 = oneAndTwoCards[0x28] or 0
    local count3 = oneAndTwoCards[0x29] or 0
    if count1 + count2 + count3 >= 3 then
        self:setRetult( result, count3, 0x29, oneAndTwoCards )
        self:setRetult( result, count2, 0x28, oneAndTwoCards )
        self:setRetult( result, count1, 0x27, oneAndTwoCards )
        table.insert(yiJvHua, result)
    end
    return result
end

function CardUtils:setRetult( result, count, card, oneAndTwoCards )
    count = count or 0
    for i=1,count do
        table.insert(result, card)
    end 
    oneAndTwoCards[card] = nil
end

--     --找出顺子*/
function CardUtils:_findShunZi(shunZiYiJvHua, oneAndTwoCards, shunZiYiJvHua_luan)
    local result = {}
    local clientCards = {}
    
    local array = {}
    for card = 1, 25 do
        local count = oneAndTwoCards[card]
        if count then
            local cardClient = card % 16
            if not array[cardClient] then
                array[cardClient] = {}
                array[cardClient].cardClient = cardClient
            end
            local newCard = {card = card, count = count}
            table.insert(array[cardClient], newCard)
        end
    end
    for k,value in pairs(array) do
        table.insert(clientCards, value)
    end
    table.sort(clientCards, function ( a, b )
        return a.cardClient > b.cardClient
    end)

    local num = 3
    for start = 1, #clientCards - num + 1 do
        local newClientCards = table.slice(clientCards, start, num)
        local bool = self:_isShunZi(newClientCards, num-1)
        if bool then
            table.insert(result, newClientCards)
            clientCards[start] = 0
            clientCards[start+1] = 0
            clientCards[start+2] = 0
        end
    end
    
    --一句话 一组最大9张
    for idx, clientCards in ipairs(result) do
        local tab = {}
        for idx, value in ipairs(clientCards) do
            for i,clientCard in ipairs(value) do
                self:setRetult( tab, clientCard.count, clientCard.card, oneAndTwoCards )
            end
        end
        table.insert(shunZiYiJvHua, tab)
    end

    -- --剩余的牌凑不成一句话 一组最大9张

    local count = 0

    for idx, value in ipairs(clientCards) do
        if value ~= 0 then
            for i,clientCard in ipairs(value) do
                count = count + clientCard.count
            end
        end
    end

   
    if count >= 5 then
        local newCards = {}
        for idx, value in ipairs(clientCards) do
            if value ~= 0 then
                for i,clientCard in ipairs(value) do
                    self:setRetult( newCards, clientCard.count, clientCard.card, oneAndTwoCards )
                end
            end
        end
        if #newCards >= 0 then
            table.insert(shunZiYiJvHua_luan, newCards)
            newCards = {}
        end
    end
    return result
end

function CardUtils:_isShunZi(clientCards, length)
    if type(clientCards[1]) == "table" and type(clientCards[#clientCards]) == "table" then
        return clientCards[1].cardClient - clientCards[#clientCards].cardClient == length
    end
    return false
end

function CardUtils:setKan( SameCards, oneAndTwoCards )
    local result = {}
    for i,card in ipairs(SameCards[3]) do
        if card ~= 0 then
            local tab = {}
            table.insert(tab, card)
            table.insert(tab, card)
            table.insert(tab, card)
            table.insert(result, tab)
        end
    end

    for card, count in pairs(oneAndTwoCards) do
        if self:isHuaPai(card) then
            local huaPaiCard = card + 16
            if oneAndTwoCards[huaPaiCard] and oneAndTwoCards[huaPaiCard] + count == 3 then
                local tab = {}
                for i=1,count do
                    table.insert(tab, card)
                end
                for i = 1, 3 - count do
                    table.insert(tab, huaPaiCard)
                end
                table.insert(result, tab)
                oneAndTwoCards[card] = nil
                oneAndTwoCards[huaPaiCard] = nil
            end
        end
    end
    return result
end

function CardUtils:setTongShangDing( SameCards, oneAndTwoCards )
    local result = {}
    for i,card in ipairs(SameCards[5]) do
        local tab = {}
        table.insert(tab, card)
        table.insert(tab, card)
        table.insert(tab, card)
        table.insert(tab, card)
        table.insert(tab, card)
        table.insert(result, tab)
    end

    local three = {}
    for idx, card in ipairs(SameCards[3]) do
        if self:isHuaPai(card) then
            local huaPaiCard = card + 16
            if oneAndTwoCards[huaPaiCard] == 2 then
                local tab = {}
                table.insert(tab, card)
                table.insert(tab, card)
                table.insert(tab, card)
                table.insert(tab, huaPaiCard)
                table.insert(tab, huaPaiCard)
                table.insert(result, tab)
                oneAndTwoCards[huaPaiCard] = nil
                SameCards[3][idx] = 0
            end
        end
    end

    return result
end

function CardUtils:setTong(SameCards, oneAndTwoCards )
    local result = {}
    for i,card in ipairs(SameCards[4]) do
        local tab = {}
        table.insert(tab, card)
        table.insert(tab, card)
        table.insert(tab, card)
        table.insert(tab, card)
        table.insert(result, tab)
    end

    for idx,card in ipairs(SameCards[3]) do
        if self:isHuaPai(card) then
            local huaPaiCard = card + 16
            if oneAndTwoCards[huaPaiCard] == 1 then
                local tab = {}
                table.insert(tab, card)
                table.insert(tab, card)
                table.insert(tab, card)
                table.insert(tab, huaPaiCard)
                table.insert(result, tab)
                oneAndTwoCards[huaPaiCard] = nil
                SameCards[3][idx] = 0
            end
        end
    end

    for card, count in pairs(oneAndTwoCards) do
        if card <= 25 and card % 16 % 2 == 1 then -- 是1-10并且是单数
            local huaPaiCard = card + 16
            if card > 10 then
                huaPaiCard = card - 16
            end
            if oneAndTwoCards[huaPaiCard] and oneAndTwoCards[huaPaiCard] + count == 4 then
                local tab = {}
                for i=1, oneAndTwoCards[huaPaiCard] do
                    table.insert(tab, huaPaiCard)
                end
                for i=1, count do
                    table.insert(tab, card)
                end
                table.insert(result, tab)
                oneAndTwoCards[card] = nil
                oneAndTwoCards[huaPaiCard] = nil
            end
        end
    end
    return result
end

function CardUtils:isHuaPai( card )
    local is = card == 0x01 or card == 0x03 or card == 0x05 or card == 0x07 or card == 0x09
    return is
end

--最多8行  一行最多9个 多出的挤在一起
function CardUtils:handlerResult( tongShangDing, tong, kan, yiJvHua, shunZiYiJvHua, shunZiYiJvHua_luan, twoResult, oneResult, maxSize, maxCardsSize )
    local size =  #tongShangDing + #tong + #kan + #yiJvHua + #shunZiYiJvHua + #shunZiYiJvHua_luan + #twoResult + #oneResult
    if size > maxSize then
        local fun = function( tabl )
            if #tabl <= 0 then
                return false
            end
            local tmpIdx = 100
            for idx, tab in ipairs(tabl) do
                if tmpIdx == 100 then
                    tmpIdx = idx
                end
                if #tab < #tabl[tmpIdx] then
                    tmpIdx = idx
                end 
            end
            
            if tmpIdx ~= 100 then
                for idx, tab in ipairs(tabl) do
                    if #tab > maxCardsSize then
                        while #tab > maxCardsSize do
                            local newTab = table.splice(tab, 1, maxCardsSize)
                            table.insert(tabl, newTab)
                        end
                    elseif tmpIdx ~= idx and #tabl[tmpIdx] + #tab <= maxCardsSize then
                        for _,card in ipairs(tabl[tmpIdx]) do
                            table.insert(tabl[idx], card)
                        end
                        table.remove(tabl, tmpIdx)
                        return self:handlerResult( tongShangDing, tong, kan, yiJvHua, shunZiYiJvHua, shunZiYiJvHua_luan, twoResult, oneResult, maxSize, maxCardsSize )
                    end

                end
            end
            return false
        end
        local is = fun(oneResult)
        if is == false then
            is = fun(twoResult)
        end
        if is == false then
            is = fun(shunZiYiJvHua_luan)
        end
        if is == false then
            is = fun(shunZiYiJvHua)
        end
        if is == false then
            is = fun(yiJvHua)
        end
        if is == false then
            is = fun(kan)
        end
        if is == false then
            is = fun(tong)
        end
    else
        return true
    end
end

--maxNum最大有几行
--maxCardsSize一列最多只能有几张牌
function CardUtils:_findHandCards(cards, maxSize, maxCardsSize)
    if not maxSize then
        maxSize = 9    
    end
    if not maxCardsSize then
        maxCardsSize = 9    
    end
    local SameCards = self:getSameCard(cards)
    local oneAndTwoCards = {}
    for idx, card in ipairs(SameCards[1]) do
        oneAndTwoCards[card] = 1
    end
    for idx, card in ipairs(SameCards[2]) do
        oneAndTwoCards[card] = 2
    end
    local tongShangDing = self:setTongShangDing( SameCards, oneAndTwoCards )
    local tong = self:setTong( SameCards, oneAndTwoCards )
    local kan = self:setKan( SameCards, oneAndTwoCards )

    local yiJvHua = {}
    local shunZiYiJvHua = {}
    local shunZiYiJvHua_luan = {}

    self:_findKongYiJi(yiJvHua, oneAndTwoCards)
    self:_findHuaSanQian(yiJvHua, oneAndTwoCards)
    self:_findShiQiTu(yiJvHua, oneAndTwoCards)
    self:_find89Zi(yiJvHua, oneAndTwoCards)
    self:_findKeZhiLi(yiJvHua, oneAndTwoCards)
    self:_findShangDaRen(yiJvHua, oneAndTwoCards)
    self:_findShunZi(shunZiYiJvHua, oneAndTwoCards, shunZiYiJvHua_luan)
    local oneResult = {}
    oneResult[1] = {}
    local remainCards = {}
    local twoResult = {}

    local clientCards = {}
    for card = 1, 25 do
        local count = oneAndTwoCards[card]
        if count then
            if not clientCards[card % 16] then
                clientCards[card % 16] = {}
            end
            table.insert(clientCards[card % 16], card)
            if count == 2 then
                table.insert(clientCards[card % 16], card)
            end
            oneAndTwoCards[card] = nil
        end
    end
    for clientCard, arr in pairs(clientCards) do
        if #arr == 2 then
            table.insert(twoResult, arr)
        else
            table.insert(oneResult[1], arr[1])
        end
    end
    for card, count in pairs(oneAndTwoCards) do
        if count == 2 then
            table.insert(twoResult, {card, card})
        else
            table.insert(oneResult[1], card)
        end
    end
    table.sort(oneResult[1], function( a,b )
        local acard = a <= 25 and a % 16 or a
        local bcard = b <= 25 and b % 16 or b
        return bcard < acard
    end)
    table.sort(twoResult, function( a,b )
        return #a < #b
    end)
    self:handlerResult( tongShangDing, tong, kan, yiJvHua, shunZiYiJvHua, shunZiYiJvHua_luan, twoResult, oneResult, maxSize, maxCardsSize )
    local result = {}
    for _,value in ipairs({tongShangDing, tong, kan, yiJvHua, shunZiYiJvHua, shunZiYiJvHua_luan, twoResult, oneResult}) do
        for _,value_1 in ipairs(value) do
            if #value_1 > 0 then
                table.insert(result, value_1)
            end
        end
    end
   
    while #result > maxSize do
        local cards_2 = table.splice(result, #result, 1)[1]
        for idx = #result, 1, -1 do
            while #result[idx] < maxCardsSize and table.slice(cards_2, 1, 1)[1] do
                local card = table.remove(cards_2, 1)
                table.insert(result[idx], card)
            end
        end
    end

    local newCards = {}
    for _,cards in ipairs(result) do
        for i,card in ipairs(cards) do
            table.insert(newCards, card)
        end
    end
    
    if #newCards ~= #cards then
        dump(cards)
        assert(false, "#newCards ~= #cards")
    end
    table.sort(newCards, function( a,b )
        return a > b
    end)
    table.sort(cards, function( a,b )
        return a > b
    end)
    for i,card in ipairs(cards) do
        if cards[i] ~= newCards[i] then
            assert(false, "cards[i] ~= newCards[i]")
        end
    end
    return result
end

function CardUtils:shuffle( cards )
    -- for (local j, x, i = v.length; i; j =, x = v[i=1-1], v[i] = v[j], v[j] = x)
    for i, v in ipairs(cards) do
        local j = math.random(i, #cards)
        local tmp = cards[j]
        cards[j] = cards[i]
        cards[i] = tmp
    end
    cards = table.slice(cards,1,45)
    return cards
end
local cards = {
    0x01,0x01,0x01,0x11,0x11,0x02,0x02,0x02,0x02,0x02, --一、二
    0x03,0x03,0x03,0x13,0x13,0x04,0x04,0x04,0x04,0x04, --三、四
    0x05,0x05,0x05,0x15,0x15,0x06,0x06,0x06,0x06,0x06, --五、六
    0x07,0x07,0x07,0x17,0x17,0x08,0x08,0x08,0x08,0x08, --七、八
    0x09,0x09,0x09,0x19,0x19,0x0a,0x0a,0x0a,0x0a,0x0a, --九、十
    
    0x21,0x21,0x21,0x21,0x21,0x22,0x22,0x22,0x22,0x22, --孔、已
    0x23,0x23,0x23,0x23,0x23,0x24,0x24,0x24,0x24,0x24, --话、千
    0x25,0x25,0x25,0x25,0x25,0x26,0x26,0x26,0x26,0x26, --土、子
    
    0x27,0x27,0x27,0x27,0x27,0x28,0x28,0x28,0x28,0x28, --上、大
    0x29,0x29,0x29,0x29,0x29,0x2a,0x2a,0x2a,0x2a,0x2a, --人、可
    0x2b,0x2b,0x2b,0x2b,0x2b,0x2c,0x2c,0x2c,0x2c,0x2c, --知、礼
    }
-- for i=1,1000 do
--     cards = CardUtils:shuffle(cards)
--     CardUtils:_findHandCards(cards, 9, 5)
-- end

return CardUtils
