
--扑克类型
local CT_INVALID                  = 0        --错误类型
local CT_SINGLE                   = 1        --单牌类型
local CT_DOUBLE                   = 2        --对牌类型
local CT_THREE                    = 3        --三条类型
local CT_ONE_LINE                 = 4        --单连类型
local CT_DOUBLE_LINE              = 5        --对连类型
local CT_PANEL                    = 6        --飞机类型

local CT_BOMB_BASE                = 10       --基础炸弹
local CT_BOMB_4                   = 14       --4炸类型
local CT_BOMB_5                   = 15       --5弹类型                           
local CT_BOMB_6                   = 16       --6炸类型                           
local CT_BOMB_7                   = 17       --7炸类型                           
local CT_BOMB_8                   = 18       --8炸类型                           



--下面是无效的
--local CT_THREE_TAKE_ONE           = 6        --三带一单
--local CT_THREE_TAKE_TOW           = 5        --三带二
--local CT_PANEL                    = 7        --飞机
--local CT_PANEL_LACK               = 8        --飞机
--local CT_BOMB_CARD                = 12       --炸弹类型
--local CT_3A_BOMB                  = 12       --3个A算特殊炸弹
--local CT_BOMB_TAKE                = 9      --四带3
--local CT_FOUR_TAKE_TWO = 10 --四带二
--local CT_FOUR_TAKE_ONE = 11 --四带一





local MIN_LEN_SHUNZI = 5  -- 顺子的最小长度 
local MIN_LEN_LIANDUI = 2 -- 连对的最小长度 

local CardsAnalysis = class("CardsAnalysis")

-- 参数：cards的格式 {{[1] = 牌值，[2] = 花色},...}
function CardsAnalysis:sortCards(cards)
    if cards == nil or #cards == 0 then
        return {}
    end

    table.sort(cards,function(a,b) 
        if a[1] == b[1] then
            return a[2] > b[2]
        else
            return a[1]>b[1]
        end

    end )

    return cards
end

--参数: prevType前面一手牌的类型
--参数: prevCards前面一手的牌
function CardsAnalysis:getSuitCardFromHandlerCards(prevType, prevCards)

    --print("getSuitCardFromHandlerCards ---------------", prevType)
    dump(prevType,"CardsAnalysis:getSuitCardFromHandlerCards_1")
    local result = {}
    --if prevType == CT_3A_BOMB then return result end
    if prevType == nil or prevType == CT_INVALID or #(prevCards or {}) == 0 then
        if #g_mainScene.myHandlerCards ~= 0 then
            table.insert(result, g_mainScene.myHandlerCards[#g_mainScene.myHandlerCards])
        end
    end

    if prevType == CT_SINGLE then
        result = self:getGreaterSingleCards(prevCards)
    elseif prevType == CT_DOUBLE then
        result = self:getGreaterDoubleCards(prevCards)
    elseif prevType == CT_ONE_LINE then   --没有顺子类型了
       result = self:getGreaterLineCards(prevCards, 1)
    elseif prevType == CT_DOUBLE_LINE then
        result = self:getGreaterLineCards(prevCards, 2)
    elseif prevType == CT_THREE then  --原先是3带2
        result = self:getGreaterThreeTakeTwoCards(prevCards)
    elseif prevType == CT_PANEL then
        result = self:getGreaterPanelCards(prevCards, 3, 2) -- 3带0试试
    elseif prevType >= CT_BOMB_4 and prevType <= CT_BOMB_8  then --4炸弹~8炸弹
        result = self:getGreaterBombCards(prevType,prevCards)
    end
        
    --print("getSuitCardFromHandlerCards ---------------------- end")
    dump(result,"getSuitCardFromHandlerCards")

    return result
end

function CardsAnalysis:getGreaterSingleCards(prevCards)
    local result = {} 
    local prevCardLogicValve = (prevCards or {})[1][1] or 0
    local last_result = {}
    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)

    dump(cardLst,"CardsAnalysis:getGreaterSingleCards")

    for k, v in pairs( cardLst ) do
        if k > prevCardLogicValve and #v <= 1 then
            local tmp = {}
            table.insert(tmp, v[1])
            table.insert(result, tmp)
        end
        --两个对牌的拉出来
        if k > prevCardLogicValve and #v >= 2 then 
            local tmp = {}
            table.insert(tmp, v[1])
            table.insert(last_result, tmp)
        end
    end
    if next(result) then
        table.sort(result , function( table1 , table2 )
            return table1[1][1] < table2[1][1]
        end)
    end

    if not next(result) then 
        result = last_result
    end
    result = self:insertBomb(result, cardLst)
    return result
end

function CardsAnalysis:getGreaterDoubleCards(prevCards)
    local result = {} 
    local last_result = {}
    local prevCardLogicValve = (prevCards or {})[1][1] or 0
    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
    for k, v in pairs( cardLst ) do
        if k > prevCardLogicValve and #v == 2 then
            local tmp = {}
            for i = 1, 2 do
                table.insert(tmp, v[i])
            end
            table.insert(result, tmp)
        end
        --三个牌的拉出来
        if k > prevCardLogicValve and #v >= 3 then 
            local tmp = {}
            for i = 1, 2 do
                table.insert(tmp, v[i])
            end
            table.insert(last_result, tmp)
        end
    end

    if not next(result) then 
        result = last_result
    end

    result = self:insertBomb(result, cardLst)

    return result
end

-- 参数:size 1、表示顺子；2、表示连对
function CardsAnalysis:getGreaterLineCards(prevCards, size)
    local prevCards = self:sortCards(prevCards)
    dump(prevCards,"=====prevCards = self:sortCards(prevCards)=====")
    local prevCardMinLogicValve = (prevCards or {})[#prevCards][1] or 0
    print("==prevCardMinLogicValve==",prevCardMinLogicValve)
    local result = self:getLineGroup(prevCardMinLogicValve, #prevCards/size, size)
    dump(result,"==result==")
    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
    dump(cardLst,"cardLst")
    result = self:insertBomb(result, cardLst)

    return result
end

--获得连牌组合
--参数: minLogicValue 前面牌最小里最小的牌值
--参数: lenght 连牌的长度
--参数: size 连牌里同值的个数
function CardsAnalysis:getLineGroup(minLogicValue, lenght, size)
    local result = {} 
    local prevCards = self:sortCards(prevCards)
    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
    local tmpLst = {}
    for k, v in pairs( cardLst ) do
        if k ~= 15 and k > minLogicValue and #v >= size then
            table.insert(tmpLst, k)
        end
    end
    if #tmpLst >= lenght then
        table.sort(tmpLst, function ( p, n )
            return p < n
        end)
        local count = 1 
        local lineLenght = #prevCards/size
        for i, v in ipairs( tmpLst or {} ) do
            if i > 1 and tmpLst[i-1] and tmpLst[i] - tmpLst[i-1] == 1 then
                count = count + 1
            else
                for j = 1, count - lenght + 1 do -- 取多组顺子
                    local tmp = {} 
                    for n = 1, lenght do --取到等长的这段
                        local idx =  (i - 1 - count) + (j-1) + n

                        for m = 1, size do
                            table.insert(tmp, cardLst[tmpLst[idx]][m])
                        end
                    end
                    table.insert(result, tmp)
                end
                count = 1
            end
            if i == #tmpLst and count >= lenght then -- 表示找到比前面大的顺子

                for j = 1, count - lenght + 1 do -- 取多组顺子
                    local tmp = {} 
                    for n = 1, lenght do --取到等长的这段
                        local idx = (i - count) + (j-1) + n

                        for m = 1, size do
                            table.insert(tmp, cardLst[tmpLst[idx]][m])
                        end
                    end
                    table.insert(result, tmp)
                end
            end
        end
    end

    return result
end

function CardsAnalysis:getGreaterThreeTakeTwoCards(prevCards)

    local prevCardsSize = #prevCards


    local result = {}
    local prevLogicTable = self:createTableByCardLogic(prevCards)
    local prevLogicValue = 0
    for k, v in pairs( prevLogicTable ) do
        if #v >= 3 then
            prevLogicValue = k
        end
    end 

    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
    local single = {} 
    for k, v in pairs( cardLst ) do

        --把自己手上牌单张收集起来
        if #v == 1 then
            table.insert(single, v[1])
        end
    end

    local double = {}
    for k,v in pairs( cardLst) do

        --把自己手上牌2张的收集起来
        if #v == 2 then
            table.insert(double, v)
        end
    end

    local carry = {}
    table.insert(carry,single)
    table.insert(carry,double)

    dump(cardLst,"getGreaterThreeTakeTwoCards_0")
    dump(single,"getGreaterThreeTakeTwoCards_1")
    dump(double,"getGreaterThreeTakeTwoCards_2")

    --if #g_mainScene.myHandlerCards >= #prevCards then
        for k, v in pairs( cardLst ) do
            --if #v >= 3 and k > prevLogicValue then  --改成=3 这个可以过滤炸弹
            if #v == 3 and k > prevLogicValue then  
                local tmp = {} 
                for i = 1, 3 do
                    table.insert(tmp, v[i])
                end
                -- 选出要带的牌
                dump({tmp[1][1]},"getGreaterThreeTakeTwoCards_3")

                for k1, v1 in pairs(single) do
                    if #tmp < prevCardsSize then
                        table.insert(tmp, v1)
                    end
                end
                table.insert(result, tmp)


                --[[
                for i = #carry, 1, -1 do

                    local info = carry[i]
                    for j = 1, j < #info do
                        table.insert(tmp,info[j])
                    end

                    if 
                end
                ]]

                -- 带2张 或者带1张   
                if #tmp == 0 then
        
                    for i = 2, 1, -1 do
                        local takeCards = self:getSingleTakeCards(g_mainScene.myHandlerCards, {tmp[1][1]}, i)
                            for i, v in ipairs( takeCards or {} ) do
                                if #tmp < prevCardsSize then
                                    table.insert(tmp, v)
                                end
                            end
                            table.insert(result, tmp)
                            break
                        end
                    end
                end
        end
    --end

    result = self:insertBomb(result, cardLst)

    return result
end

--获得能合适带的牌
--参数：cards 全部的牌
--参数：mainValue 3、4个的牌的值 --{5,6} 为不定长数组机构
--参数：size 要带几个
function CardsAnalysis:getSingleTakeCards(cards, mainValue, size)
    local tmpCards = {}
    for i, v in ipairs( cards ) do
        if v[1] ~= mainValue[1] and (mainValue[2] or 0) ~= v[1] and (mainValue[3] or 0) ~= v[1]then
            table.insert(tmpCards, v)
        end
    end

    local cardLst = self:createTableByCardLogic(tmpCards)
    local single = {} 
    local double = {}
    local three  = {} 
    local four   = {} 
    local all    = {}
    for k, v in pairs( cardLst or {} ) do
        if #v == 1 then
            table.insert(single, k)
        elseif #v == 2 then
            table.insert(double, k)
        elseif #v == 3 then
            table.insert(three, k)
        elseif #v == 4 then
            table.insert(four, k)
        end
        table.insert(all, k)
    end
    local result = {} 
    if #single >= size then
        table.sort(single, function (a, b)
                        return a < b
                    end)
        for i = 1, size do
            table.insert(result, cardLst[single[i]][1])
        end
    else
        table.sort(all, function (a, b)
                        return a < b
                    end)
        for i, v in ipairs( all or {} ) do
            for j = 1, #(cardLst[v]) do
                if #result == size then break end
                table.insert(result, cardLst[all[i]][j])
            end
        end
    -- elseif (#double*2 + #single) >= size then

    -- elseif ((#three)*3 + #double*2 + #single) >= size then

    -- elseif (#four*4 + (#three)*3 + #double*2 + #single) >= size then

    end
    return result
end

--获得连着的 3带2 或 4带3的牌
--参数：cardSize 3、表示出的3个的连牌; 4、表示出的4个的连牌
--参数：takeSize 带的牌的数量
function CardsAnalysis:getGreaterPanelCards(prevCards, cardSize, takeSize)

    dump(prevCards,"CardsAnalysis:getGreaterPanelCards")

    local prevCardLst = self:createTableByCardLogic(prevCards)
    local tmpLst = {}
    local minLogicValue = 0 -- 飞机里最大的3个的牌值
    for k, v in pairs( prevCardLst ) do
        if k ~= 15 and #v >= cardSize then
            table.insert(tmpLst, k)
        end
    end
    table.sort(tmpLst, function ( p, n )
            return p > n
        end)
    if tmpLst[1] - (tmpLst[2] or 0) == 1 then
        minLogicValue = tmpLst[2]
    else
        minLogicValue = tmpLst[3]
    end
    local lineSize = #prevCards/(cardSize+takeSize)
    local result = self:getLineGroup(minLogicValue, lineSize, cardSize)
    for i, v in ipairs( result ) do
        local tmp = {}
        for j = 1, lineSize do
            table.insert(tmp, v[(j-1)*cardSize+1][1])
        end
        local takeCard = self:getSingleTakeCards(g_mainScene.myHandlerCards, tmp, lineSize*takeSize) 
        dump(takeCard,"takeCard_1")
        for _, v2 in ipairs( takeCard ) do
            table.insert(v, v2)
        end
    end

    dump(result,"getGreaterPanelCards_2")

    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
    --dump(cardLst,"CardsAnalysis:getGreaterPanelCards")

    result = self:insertBomb(result, cardLst)

    dump(result,"getGreaterPanelCards_3")

    return result
end

--单个4带3的牌
--index1 代表几个相同的牌
--index2 代表带的几个牌
function CardsAnalysis:getGreaterBombTakeCards(prevCards , sum , index1 , index2)
    local result = {} 
    if #(prevCards or {}) ~= sum then return result end

    local prevCardLst = self:createTableByCardLogic(prevCards)
    local tmpLst = {}
    for k, v in pairs( prevCardLst ) do
        if k ~= 15 and #v >= index1 then
            table.insert(tmpLst, k)
        end
    end
    if #g_mainScene.myHandlerCards < sum then return result end

    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
    for k, v in pairs( cardLst or {} ) do
        if #v == index1 and k > tmpLst[1] then
            local tmp = {}
            for it = 1, index1 do
                table.insert(tmp, cardLst[k][it])
            end
            -- 选出要带的牌
            local takeCards = self:getSingleTakeCards(g_mainScene.myHandlerCards, {tmp[1][1]}, index2)
            for i, v in ipairs( takeCards or {} ) do
                table.insert(tmp, v)
            end
            table.insert(result, tmp)
        end
    end

    result = self:insertBomb(result, cardLst)

    return result
end

function CardsAnalysis:insertBomb(result, cardLst)

    --找个最小的炸弹
     for k, v in pairs( cardLst ) do
        local tmp = {} 

        if #v >= 4 and #v <= 8 then
            for i = 1, #v do
                table.insert(tmp,v[i])
            end
        end

        dump(tmp,"CardsAnalysis:insertBomb")

        table.insert(result, tmp)

        --[[
        if #v == 4 then
            table.insert(tmp, v[1])
            table.insert(tmp, v[2])
            table.insert(tmp, v[3])
            table.insert(tmp, v[4])
        end
        ]]
        --找到一个就退出吧
        --[[if #tmp > 0 then
            table.insert(result, tmp)
            break
        end]]
    end

    return result
end


--得到炸弹推荐牌型 新版 支持多炸弹
function CardsAnalysis:getGreaterBombCards(prevType,prevCards)

    local result = {}

    if #g_mainScene.myHandlerCards < #prevCards then
        return result
    end

    local prevLogicTable = self:createTableByCardLogic(prevCards)
    --之前炸弹牌的逻辑值
    local prevLogicValue = prevCards[1][1]

    local begin = 4 + (prevType - CT_BOMB_4)
    local bombCount = #prevCards

    --dump(begin,"getGreaterBombCards_1")
    --dump(cardLst,"getGreaterBombCards_2")
    --dump(bombCount,"getGreaterBombCards_3")

    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)

    --4个开始
    for i = begin , 8 do
        
        for k, v in pairs( cardLst ) do
            if (#v == bombCount and k > prevLogicValue) or #v > bombCount then 
                local tmp = {} 
                for i = 1, #v do
                    table.insert(tmp, v[i])
                end
                table.insert(result, tmp)
            end
        end

    end

    return result

end


--[[
--得到炸弹推荐牌型 新版 支持多炸弹
function CardsAnalysis:getGreaterBombCards(prevCards, bombCount)
    local result = {}
    local prevLogicTable = self:createTableByCardLogic(prevCards)

    --之前炸弹牌的逻辑值
    local prevLogicValue = prevCards[1][1]

    --当前手牌数量大于等于之前的

    --炸弹要把小的炸弹优先排前面
    if #g_mainScene.myHandlerCards >= #prevCards then
        local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
        for k, v in pairs( cardLst ) do
            if #v == bombCount and k > prevLogicValue then 
                local tmp = {} 
                for i = 1, bombCount do
                    table.insert(tmp, v[i])
                end
                table.insert(result, tmp)
                break
            end
        end
    end

    return result
end

]]

--[[
function CardsAnalysis:getGreaterBombCards(prevCards)
    local result = {}
    local prevLogicTable = self:createTableByCardLogic(prevCards)

    --之前炸弹牌的逻辑值
    local prevLogicValue = prevCards[1][1]

    if #g_mainScene.myHandlerCards >= #prevCards then
        local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
        for k, v in pairs( cardLst ) do
            if #v == 4 and k > prevLogicValue then 
                local tmp = {} 
                for i = 1, 4 do
                    table.insert(tmp, v[i])
                end
                table.insert(result, tmp)
            end
        end
    end

    return result
end
]]

function CardsAnalysis:getType(cards)
    dump(cards, "getType ------------")
    cards = self:sortCards(cards)

    if self:isSingle(cards) then
        return CT_SINGLE
    elseif self:isDouble(cards) then
        return CT_DOUBLE
    elseif self:isThree(cards) then
        return CT_THREE
    elseif self:isShunzi(cards) then
        return CT_ONE_LINE
    elseif self:isLiandui(cards) then
        return CT_DOUBLE_LINE
    elseif self:isThreeTakeOne(cards) then
        return CT_THREE_TAKE_ONE
    elseif self:isThreeTakeTwo(cards) then
        return CT_THREE_TAKE_TOW
    elseif self:isFeiji(cards) then
        return CT_PANEL
    elseif self:isBombTake(cards) then
        return CT_BOMB_TAKE
    elseif self:isBomb(cards) then
        return CT_BOMB_CARD
    elseif self:isThreeABomb(cards) then
        return CT_3A_BOMB
    else
        return CT_INVALID
    end
end

function CardsAnalysis:isSingle(cards)
    if cards == nil or #cards ~= 1 then
        return false
    end

    return true
end

function CardsAnalysis:isDouble(cards)
    if cards == nil or #cards ~= 2 and cards[1][1] ~= cards[2][1] then
        return false
    end

    return true
end

function CardsAnalysis:isThree(cards)
    if g_mainScene.roomConfigure.mustTakeForEnd then return false end
    if cards == nil then
        return false
    end
    if #cards == 3 and cards[1][1] == cards[2][1] and cards[2][1] == cards[3][1] then
        return true
    end
    return false
end

function CardsAnalysis:isShunzi(cards)
    if cards == nil or #cards < MIN_LEN_SHUNZI or cards[1][1] == 15 then --顺子不能连到2
        return false
    end

    for i, v in ipairs( cards ) do
        if i > 1  then
            if cards[i-1][1] - cards[i][1] ~= 1 then
                return false
            end
        end
    end

    return true
end

function CardsAnalysis:isLiandui(cards)
    local cardSize = #(cards or {})
    if cards == nil or cardSize < MIN_LEN_LIANDUI*2 or math.mod(cardSize, 2) ~= 0 or cards[1][1] == 15 then --连对不能连到2
        return false
    end

    for i = 1, cardSize, 2 do
        if i > 1  then
            if cards[i-2][1] - cards[i][1] ~= 1 then
                return false
            end
        end
    end

    return true
end

function CardsAnalysis:isThreeTakeOne(cards)
    if g_mainScene.roomConfigure.mustTakeForEnd then return false end

    local cardSize = #(cards or {})
    if cards == nil or cardSize ~= 4 then
        return false
    end

    if cards[1][1] ~= cards[2][1] then
        if cards[2][1] == cards[3][1] and cards[3][1] == cards[4][1] then
            return true
        end
    else
        if cards[1][1] == cards[2][1] and cards[2][1] == cards[3][1] and cards[3][1] ~= cards[4][1] then
            return true
        end
    end

    return false
end

function CardsAnalysis:isThreeTakeTwo(cards)
    local cardSize = #(cards or {})
    if cards == nil or cardSize ~= 5 then
        return false
    end

    local cardLst = self:createTableByCardLogic(cards)

    for k, v in pairs( cardLst ) do
        if #v >= 3 then
            return true
        end
    end

    return false
end

function CardsAnalysis:isFeiji(cards)
    local cardSize = #(cards or {})
    if g_mainScene.roomConfigure.mustTakeForEnd and math.mod(cardSize, 5) ~= 0 then
        return false
    end
    if cards == nil or cardSize < 5 then
        return false
    end

    local cardLst = self:createTableByCardLogic(cards)

    for k, v in pairs( cardLst ) do
        if #v >= 3 and #(cardLst[k-1] or {}) >= 3 and cardSize <= 10 then --表示是2连的飞机
            return true
        elseif #v >= 3 and #(cardLst[k-1] or {}) >= 3 and #(cardLst[k-2] or {}) >= 3 and cardSize <= 15 then --表示是3连的飞机
            return true
        elseif #v >= 3 and #(cardLst[k-1] or {}) >= 3 and #(cardLst[k-2] or {}) >= 3 and #(cardLst[k-4] or {}) >= 3 then --表示是4连的飞机
            return true
        end
    end

    return false
end

function CardsAnalysis:isBombTake(cards)
    if not g_mainScene.roomConfigure.canBombTake then return false end
    local cardSize = #(cards or {})
    if g_mainScene.roomConfigure.mustTakeForEnd and math.mod(cardSize, 7) ~= 0 then
        return false
    end
    if cards == nil or cardSize < 7 then
        return false
    end

    local cardLst = self:createTableByCardLogic(cards)

    for k, v in pairs( cardLst ) do
        if #v >= 4 and cardSize > 4 and cardSize <= 7 then
            return true
        elseif #v >= 4 and #(cardLst[k-1] or {}) >= 4 and cardSize <= 14 then --表示是2连的4带3
            return true
        elseif #v >= 4 and #(cardLst[k-1] or {}) >= 4 and #(cardLst[k-2] or {}) >= 4 and cardSize <= 16 then --表示是3连的4带3
            return true
        end
    end

    return false
end

function CardsAnalysis:isBomb(cards)
    local cardSize = #(cards or {})
    if cards == nil or cardSize ~= 4 then
        return false
    end
    if #cards == 4 and cards[1][1] == cards[2][1] and cards[2][1] == cards[3][1] and cards[3][1] == cards[4][1]then
        return true
    end
    return false
end

function CardsAnalysis:isThreeABomb(cards)
    if not g_mainScene.roomConfigure.threeAIsBomb then return false end
    local cardSize = #(cards or {})
    if cards == nil or cardSize ~= 3 then
        return false
    end
    if #cards == 3 and cards[1][1] == cards[2][1] and cards[2][1] == cards[3][1] and cards[3][1] == 14 then
        return true
    end
    return false
end

-- 返回值 result 结构 {[15] = {{[1] = 牌值，[2] = 花色},...},...}
function CardsAnalysis:createTableByCardLogic(cards)
    local result = {} 
    for i, v in ipairs( cards or {} ) do
        if result[v[1]] then
            table.insert(result[v[1]], v)
        else
            result[v[1]] = {}
            table.insert(result[v[1]], v)
        end
    end

    return result
end

function CardsAnalysis:getSelectCardsForSingleShunzi(cards, valueCards)
    if #(cards or {}) < 5 then return {} end
    local result = {} 
    local logicCards = self:createTableByCardLogic(valueCards)
    local prevKey = 0
    local groupKeys = {} 
    for k, v in pairs( logicCards ) do
        if #v >= 1 then
            if prevKey == 0 then
                prevKey = k
                groupKeys[k] = 1
                -- table.insert(groupKeys, k)
            else
                if k - prevKey == 1 then
                    prevKey = k
                    groupKeys[k] = 1
                    -- table.insert(groupKeys, k)
                else
                    return {}
                end
            end
        else
            return {}
        end
    end
    for i, v in ipairs( cards ) do
        if groupKeys[v.value[1]] == 1 then
            table.insert(result, v)
            groupKeys[v.value[1]] = nil
        end
    end
    
    if #result < 5 then return {} end
    return result
end

function CardsAnalysis:getSelectCardsForDoubleShunzi(cards, valueCards)
    if #(cards or {}) < 6 then return {} end
    local result = {} 
    
    local logicCards = self:createTableByCardLogic(valueCards)
    dump(logicCards, "logicCards")
    local prevKey = 0
    local groupKeys = {} 
    for k, v in pairs( logicCards ) do
        if #v >= 2 then
            if prevKey == 0 then
                prevKey = k
                groupKeys[k] = 1
                -- table.insert(groupKeys, k)
            else
                if k - prevKey == 1 then
                    prevKey = k
                    groupKeys[k] = 1
                    -- table.insert(groupKeys, k)
                else
                    return {}
                end
            end
        else
            return {}
        end
    end

    dump(groupKeys, "getSelectCardsForDoubleShunzi")

    for i, v in ipairs( cards ) do
        if groupKeys[v.value[1]] == 1 then
            table.insert(result, v)
            if cards[i+1] then
                table.insert(result, cards[i+1])
            else
                return {}
            end
            groupKeys[v.value[1]] = nil
        end
    end
    
    if #result < 6 then return {} end
    return result
end


--从滑动选择的牌里选择合适能出的牌
function CardsAnalysis:getSuitCardsForSelectCards(cards)
    local result = {} 
    local valueCards = {}
    for i, v in ipairs( cards ) do
        table.insert(valueCards, v.value)
    end
    if self:isFeiji(valueCards) then return result end
    --先找是否有连对
    result = self:getSelectCardsForDoubleShunzi(cards, valueCards)
    if #result == 0 then
        result = self:getSelectCardsForSingleShunzi(cards, valueCards)
    end

    return result

end

function CardsAnalysis:asdf(cards, keyLst)
    if #keyLst == 2 then
        if #cards[keyLst[1]] >= 3 and #cards[keyLst[2]] >= 3 then
        end
    elseif #keyLst == 3 then
    elseif #keyLst == 4 then
    elseif #keyLst >= 5 then
    end
end

return CardsAnalysis