

--扑克类型
local CT_INVALID = 0 -- 错误类型
local CT_SINGLE = 1 -- 单牌类型
local CT_DOUBLE = 2 -- 对子类型
local CT_DOUBLE_LINK = 3 -- 连对
local CT_STRAIGHT = 4 -- 顺子
local CT_THREE_FULL = 5 -- 三条带二
local CT_PLANE_FULL = 6 -- 飞机带满
local CT_THREE = 7 -- 三条

local CT_BOMB_4 = 10 -- 4炸
local CT_JOKER_BS = 11 -- 大小王
local CT_BOMB_5 = 12 -- 5炸
local CT_JOKER_SS = 13 -- 对小王
local CT_JOKER_BB = 14 -- 对大王
local CT_510k_3 = 15 -- 3付510k
local CT_BOMB_6 = 16 -- 6炸
local CT_JOKER_3 = 17 -- 3王
local CT_JOKER_3S = 18 -- 3小王
local CT_JOKER_3B = 19 -- 3大王
local CT_BOMB_7 = 20 -- 7炸
local CT_510k_4 = 21 -- 4付510k
local CT_JOKER_4 = 22 -- 4王
local CT_BOMB_8 = 23 -- 8炸
local CT_JOKER_4S = 24 -- 4小王
local CT_JOKER_4B = 25 -- 4大王
local CT_510k_5 = 26 -- 5付510k
local CT_BOMB_9 = 27 -- 9炸
local CT_JOKER_5 = 28 -- 5王
local CT_510k_6 = 29 -- 6付510k
local CT_BOMB_10 = 30 -- 10炸
local CT_JOKER_6 = 31 -- 6王
local CT_BOMB_11 = 32 -- 11炸
local CT_510k_7 = 33 -- 7付510k
local CT_JOKER_7 = 34 -- 7王
local CT_BOMB_12 = 35 -- 12炸
local CT_510k_8 = 36 -- 8付510k
local CT_JOKER_8 = 37 -- 8王
local CT_BOMB_13 = 38 -- 13炸
local CT_510k_9 = 39 -- 9付510k
local CT_BOMB_14 = 40 -- 14炸
local CT_510k_10 = 41 -- 10付510k
local CT_BOMB_15 = 42 -- 15炸
local CT_510k_11 = 43 -- 11付510k
local CT_BOMB_16 = 44 -- 16炸
local CT_510k_12 = 45 -- 12付510k
local CT_510k_13 = 46 -- 13付510k
local CT_510k_14 = 47 -- 14付510k
local CT_510k_15 = 48 -- 15付510k
local CT_510k_16 = 49 -- 16付510k
local Is510K=false
local isJokerBomb=false
local isNormalBomb=false
local isDouble=false
local isThree=false
local isShunzi=false
local isLiandui=false

local Card = require(TpackageName .. ".src.view.Card") 
local CardsAnalysis = class("CardsAnalysis")

-- 参数：cards的格式 {{[1] = 牌值，[2] = 花色},...}
function CardsAnalysis:sortCards(cards)

    if cards == nil or #cards == 0 then
        return {}
    end

    table.sort(cards,function(a,b)
        if a[2] == 5 then
            return true
        elseif b[2] == 5 then
            return false
        elseif a[2] == 4 or b[2] == 4 then
            if a[2] == b[2] then
                return a[1] > b[1]
            elseif a[2]==4 then
                return true
            else
                return false
            end
        elseif a[1] == b[1] then
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

    print("getSuitCardFromHandlerCards ---------------", prevType)
    dump(prevCards)
    local result = {}
    if prevType == CT_3A_BOMB then return result end
    if prevType == nil or prevType == CT_INVALID or #(prevCards or {}) == 0 then
        if #g_mainScene.myHandlerCards ~= 0 then
            table.insert(result, g_mainScene.myHandlerCards[#g_mainScene.myHandlerCards])
        end
    end

    if prevType == CT_SINGLE then
        result = self:getGreaterSingleCards(prevCards)
    elseif prevType == CT_DOUBLE then
        result = self:getGreaterDoubleCards(prevCards)
    elseif prevType == CT_ONE_LINE then
        result = self:getGreaterLineCards(prevCards, 1)
    elseif prevType == CT_DOUBLE_LINE then
        result = self:getGreaterLineCards(prevCards, 2)
    elseif prevType == CT_THREE_TAKE_TOW then
        result = self:getGreaterThreeTakeTwoCards(prevCards)
    elseif prevType == CT_PANEL then
        result = self:getGreaterPanelCards(prevCards, 3, 2)
    elseif prevType == CT_BOMB_TAKE then
        if #prevCards == 7 then
            result = self:getGreaterBombTakeCards(prevCards , 7 ,4 ,3)
        else
            result = self:getGreaterPanelCards(prevCards, 4, 3)
        end
    elseif prevType == CT_BOMB_CARD then
        result = self:getGreaterBombCards(prevCards)
    elseif prevType == CT_FOUR_TAKE_TWO then 
        result = self:getGreaterBombTakeCards(prevCards, 6 , 4 , 2)
    elseif prevType == CT_FOUR_TAKE_ONE then 
        result = self:getGreaterBombTakeCards(prevCards, 5 , 4, 1)
    end

    print("getSuitCardFromHandlerCards ---------------------- end")
    dump(result)

    
    return result
end




function CardsAnalysis:getGreaterSingleCards(prevCards)
    local result = {} 
    local prevCardLogicValve = (prevCards or {})[1][1] or 0
    local last_result = {}
    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)
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
        if #v == 1 then
            table.insert(single, k)
        end
    end

    if #g_mainScene.myHandlerCards >= #prevCards then
        for k, v in pairs( cardLst ) do
            if #v >= 3 and k > prevLogicValue then
                local tmp = {} 
                for i = 1, 3 do
                    table.insert(tmp, v[i])
                end
                -- 选出要带的牌
                local takeCards = self:getSingleTakeCards(g_mainScene.myHandlerCards, {tmp[1][1]}, 2)
                for i, v in ipairs( takeCards or {} ) do
                    table.insert(tmp, v)
                end
                table.insert(result, tmp)
            end
        end
    end

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
        for _, v2 in ipairs( takeCard ) do
            table.insert(v, v2)
        end
    end

    local cardLst = self:createTableByCardLogic(g_mainScene.myHandlerCards)

    result = self:insertBomb(result, cardLst)

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
     for k, v in pairs( cardLst ) do
        local tmp = {} 
        if #v == 4 then
            table.insert(tmp, v[1])
            table.insert(tmp, v[2])
            table.insert(tmp, v[3])
            table.insert(tmp, v[4])
        end
        if #tmp > 0 then
            table.insert(result, tmp)
        end
    end

    return result
end

function CardsAnalysis:getGreaterBombCards(prevCards)
    local result = {}
    local prevLogicTable = self:createTableByCardLogic(prevCards)
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

function CardsAnalysis:mergeSortCards(cards)
    local reCardsList = {}   -- value num
    local lastCardV = 0

    for index, value in ipairs(cards) do
        if #reCardsList > 0 and reCardsList[#reCardsList][1] == value[1] then
            reCardsList[#reCardsList][2] = reCardsList[#reCardsList][2] + 1 
        else
            table.insert(reCardsList, {value[1],1})
        end
    end

    -- table.sort(reCardsList,function(a,b)
    --     if a[2] == b[2] then
    --         return a[1] > b[1]
    --     end
    --     return a[2]>b[2]
    -- end )

    return reCardsList
end

function CardsAnalysis:getLogicValue(card)
    local value
    value=bit.band(15,card)
    if value==1 then
        value=14
    elseif value==2 then
        value=15
    elseif card==0x41 then
        value=17
    elseif card==0x42 then
        value=18
    elseif card==0x51 then
        value=16
    end
    return value
end
-- 分析最大牌值 cards原始牌组 huacards花牌组 type 牌型
function CardsAnalysis:analysisLastOutCards(cards,huacards,type)
    self.cardMax = 0
    dump(cards,"--------99----")
    if type == CT_BOMB_4 or type == CT_BOMB_5 or type == CT_BOMB_6 or type == CT_BOMB_7 or type == CT_BOMB_8 or
        type == CT_BOMB_9 or type == CT_BOMB_10 or type == CT_BOMB_11 or type == CT_BOMB_12 or type == CT_BOMB_13 or
        type == CT_BOMB_14 or type == CT_BOMB_15 or type == CT_BOMB_16 then
        for i = 1, #cards do
            if cards[i] ~= 0x51 then
                self.cardMax = bit.band(15,cards[i])
                break
            end
        end
        if self.cardMax == 1 then
            self.cardMax = 14
        elseif self.cardMax == 2 then
            self.cardMax = 15
        end
    elseif type == CT_SINGLE then
        if cards[1] == 0x51 then
            self.cardMax = 16
        elseif cards[1] == 0x41 then
            self.cardMax = 17
        elseif cards[1] == 0x42 then
            self.cardMax = 18
        else
            self.cardMax = bit.band(15,cards[1])
            if self.cardMax == 1 then
                self.cardMax = 14
            elseif self.cardMax == 2 then
                self.cardMax = 15
            end
        end
    elseif type == CT_DOUBLE then
        for i = 1, #cards do
            if cards[i] ~= 0x51 then
                self.cardMax = bit.band(15,cards[i])
                break
            end
        end
        if self.cardMax == 1 then
            self.cardMax = 14
        elseif self.cardMax == 2 then
            self.cardMax = 15
        end
    elseif type == CT_DOUBLE_LINK or type == CT_STRAIGHT then
        -- 找最小的牌
        self.cardMax = 15
        for i = 1, #cards do
            -- self.cardMax = self:getValue(cards[i])
            if cards[i] ~= 0x51 and self:getValue(cards[i]) < self.cardMax then
                self.cardMax = self:getValue(cards[i])
            end
        end
        for i = 1, #huacards do
            -- self.cardMax = self:getValue(cards[i])
            if huacards[i] < self.cardMax then
                self.cardMax = huacards[i]
                break
            end
        end

    elseif type == CT_THREE_FULL then
        local valueList = {}
        for i = 1, #cards do
            if cards[i] ~= 0x51 and cards[i] ~= 0x41 and cards[i] ~= 0x42 then
                table.insert(valueList, self:getValue(cards[i]))
            end
        end
        for i = 1, #huacards do
            table.insert(valueList, huacards[i])
        end

        table.sort(valueList,function(a,b)
            return a>b
        end )

        local reCardsList = {}   -- value num
        for index, value in ipairs(valueList) do
            if #reCardsList > 0 and reCardsList[#reCardsList][1] == value then
                reCardsList[#reCardsList][2] = reCardsList[#reCardsList][2] + 1 
            else
                table.insert(reCardsList, {value,1})
            end
        end

        table.sort(reCardsList,function(a,b)
            return a[2]>b[2]
        end )

        self.cardMax = reCardsList[1][1]
    end
end

function CardsAnalysis:getValue(card)
    local v = bit.band(15,card)
    if v == 1 then
        return 14
    elseif v == 2 then
        return 15
    else
        return v
    end
end

function CardsAnalysis:compareCard(cards)
    if #cards ==0 then
        return false
    end
    local last=false

    if #cards==#g_mainScene.myHandlerCards and g_zxddGameData.LastType==0 then
        last=true
    end
    self:getType(cards,last)
    if g_zxddGameData.LastType==CT_THREE and self.cardType~=CT_THREE then
        return true
    end
    if g_zxddGameData.LastType==0 and self.cardType>0 and self.cardType~=CT_THREE then
        return true
    elseif self.cardType==CT_THREE  and last then
        return true
    end
    if  self.cardType >=CT_BOMB_4 then
        dump(self.cardType,"---self.cardType--")
        dump(g_zxddGameData.LastType,"---g_zxddGameData.LastType--")
        if self.cardType> g_zxddGameData.LastType then
            return true
        end
        if self.cardType== g_zxddGameData.LastType then
            local EXCard={}
            for i,v in ipairs(cards) do
                table.insert(EXCard,Card:Encode(v[1]+16*v[2]))
            end

            self:analysisLastOutCards(EXCard,self.laiziList,self.cardType)
            local my=self.cardMax
            self:analysisLastOutCards(g_zxddGameData.LastCardData,g_zxddGameData.LastChangeCard,g_zxddGameData.LastType)
            local last=self.cardMax
            if my>last then
                dump(my,"---my--")
                dump(last,"---last--")
                if isNormalBomb then
                     return true
                end
            end
        end
    else
        if self.cardType== g_zxddGameData.LastType then
                 local EXCard={}
            for i,v in ipairs(cards) do
                table.insert(EXCard,Card:Encode(v[1]+16*v[2]))
            end
            self:analysisLastOutCards(EXCard,self.laiziList,self.cardType)
            local my=self.cardMax
            self:analysisLastOutCards(g_zxddGameData.LastCardData,g_zxddGameData.LastChangeCard,g_zxddGameData.LastType)
            local last=self.cardMax
            if my>last then
                if isDouble then
                    return true
                elseif isShunzi then
                    return true
                elseif isLiandui then
                    return true
                elseif isSingle then
                    return true
                elseif isThree then
                    return true
                end
            end
        end
    end
    return false
end


--[[local Is510K=false
local isJokerBomb=false
local isNormalBomb=false
local isDouble=false
local isThree=false
local isShunzi=false
local isLiandui=false--]]

function CardsAnalysis:getTipCards()
    local IndexTab={}
    local handcard=clone(g_mainScene.myHandlerCards)

    for i,v in ipairs(handcard) do              --这里可以不用把花牌 和大王也转换 下面就不用去做多余的判断了
        if v[1]==14 and v[2]==4 then
            v[1]=17
        elseif v[1]==15 and v[2]==4 then
            v[1]=18
        elseif v[1]==1 and v[2]==5 then
            v[1]=16
        end
    end

    for i,v in ipairs(handcard) do
        if IndexTab[v[1]]==nil then
            IndexTab[v[1]]={}
            if v[1]==16 then
                table.insert(IndexTab[v[1]],{1,5})
            elseif v[1]==17 then
                table.insert(IndexTab[v[1]],{14,4})
                  elseif v[1]==18 then
                table.insert(IndexTab[v[1]],{15,4})
            else
                table.insert(IndexTab[v[1]],v)
            end
            
        else
            if v[1]==16 then
                table.insert(IndexTab[v[1]],{1,5})
            elseif v[1]==17 then
                table.insert(IndexTab[v[1]],{14,4})
                  elseif v[1]==18 then
                table.insert(IndexTab[v[1]],{15,4})
            else
                table.insert(IndexTab[v[1]],v)
            end
        end
    end

    for i=3,18 do
        if IndexTab[i]==nil then
                IndexTab[i]={}
        end
    end
    local CountHua=#IndexTab[16]
    local TypeTab={}        --存储类型和牌组的数组
    --找炸弹
    for i=3,15 do
        if #IndexTab[i]>=4 then
            self:getType(IndexTab[i],false)
            dump(self.cardType,"self.cardType")
            dump(g_zxddGameData.LastType,"------g_zxddGameData.LastType")
            if self.cardType>g_zxddGameData.LastType then
                local tab_tip={}
                tab_tip[1]=self.cardType
                tab_tip[2]=IndexTab[i]
                table.insert(TypeTab,tab_tip) --TypeTab每个元素是一个列表 列表结构tab[1]=type  tab[2]=cards
            elseif self.cardType==g_zxddGameData.LastType  then
                    if #g_zxddGameData.LastChangeCard>0 then
                        if i>self:getLogicValue(g_zxddGameData.LastChangeCard[1]) then
                                            local tab_tip={}
                tab_tip[1]=self.cardType
                tab_tip[2]=IndexTab[i]
                            table.insert(TypeTab,tab_tip)
                        end
                    else
                        if i>self:getLogicValue(g_zxddGameData.LastCardData[1]) then
                                            local tab_tip={}
                tab_tip[1]=self.cardType
                tab_tip[2]=IndexTab[i]
                            table.insert(TypeTab,tab_tip)
                        end
                    end

            end
        end
    end
    --判断加赖子的情况
    local tab_LaiBomb={}
    if CountHua>0 then
        for j=1,CountHua do
            for i=3,15 do
                if #IndexTab[i]>=3 then
                    local tab=clone(IndexTab[i])
                    local tab2=clone(IndexTab[i])
                    for k=1,j do
                        table.insert(tab,{i,1})
                        table.insert(tab2,{1,5})
                    end
                    self:getType(tab,false)
            if self.cardType>g_zxddGameData.LastType then
                local tab_tip={}
                tab_tip[1]=self.cardType
                tab_tip[2]=tab2
                table.insert(tab_LaiBomb,tab_tip) --TypeTab每个元素是一个列表 列表结构tab[1]=type  tab[2]=cards
            elseif self.cardType==g_zxddGameData.LastType  then
                    if #g_zxddGameData.LastChangeCard>0 then
                        if i>self:getLogicValue(g_zxddGameData.LastChangeCard[1]) then
                                            local tab_tip={}
                tab_tip[1]=self.cardType
                tab_tip[2]=tab2
                            table.insert(tab_LaiBomb,tab_tip)
                        end
                    else
                        if i>self:getLogicValue(g_zxddGameData.LastCardData[1]) then
                                            local tab_tip={}
                tab_tip[1]=self.cardType
                tab_tip[2]=tab2
                            table.insert(tab_LaiBomb,tab_tip)
                        end
                    end

            end

                end
            end
        end
    end
    if #tab_LaiBomb >0 then
    self:sortTipTab(tab_LaiBomb)
    local tab=clone(tab_LaiBomb[#tab_LaiBomb])
       table.insert(TypeTab,tab)
end

    --找510k
    if #IndexTab[5]>=3 and #IndexTab[10]>=3 and #IndexTab[13]>=3 then
            local min=#IndexTab[5]
            if min>#IndexTab[10] then
                    min=#IndexTab[10]
            end
            if min>#IndexTab[13] then
                    min=#IndexTab[13]
            end
            for j=3,min do
            local tab_tip={}
            for i=1,j do
                table.insert(tab_tip,IndexTab[5][i])
                table.insert(tab_tip,IndexTab[10][i])
                table.insert(tab_tip,IndexTab[13][i])
            end
            self:getType(tab_tip,false)
            local tab_510k={}
            tab_510k[1]=self.cardType
            tab_510k[2]=tab_tip
            if self.cardType>g_zxddGameData.LastType then
                table.insert(TypeTab,tab_510k)
            end
        end
    end 
    if #IndexTab[17]+#IndexTab[18]>=2 then
        local tab_joker={}
        for i,v in ipairs(IndexTab[17]) do
                table.insert(tab_joker,v)
        end
        for i,v in ipairs(IndexTab[18]) do
                table.insert(tab_joker,v)
        end
        self:getType(tab_joker)
        if self.cardType>g_zxddGameData.LastType then
            local tab={}
            tab[1]=self.cardType
            tab[2]=tab_joker
            table.insert(TypeTab,tab)
        end
    end

        --排序
        self:sortTipTab(TypeTab)
    return clone(TypeTab)
end

function CardsAnalysis:sortTipTab(tab)

    for i=1,#tab do
        for j=1,#tab-1 do
            if tab[j][1]>tab[j+1][1] then
                local test1={}
                local test2={}
                test1=clone(tab[j])
                test2=clone(tab[j+1])
                tab[j]=test2
                tab[j+1]=test1
            elseif tab[j][1]==tab[j+1][1] and tab[j][2][1][1]>tab[j+1][2][1][1]then
                local test1={}
                local test2={}
                test1=clone(tab[j])
                test2=clone(tab[j+1])
                tab[j]=test2
                tab[j+1]=test1
            end
        end
    end

end

function CardsAnalysis:SortCardByScore()

end

function CardsAnalysis:getType(cards,isLast)
    isLast = isLast or false
    dump(cards, "getType ------------")
    -- 提取癞子牌
    local leftCards = {}
    local laiziNum = 0
    local joKerNum = 0      -- 小王
    local bJoKerNum = 0     -- 大王
    for index, value in ipairs(cards) do
        if value[2] == 5 then
            laiziNum = laiziNum + 1
        elseif value[2] == 4   then
            if value[1] == 14 then
                joKerNum = joKerNum + 1
            else
                bJoKerNum = bJoKerNum + 1
            end
        else
            table.insert(leftCards, value)
        end
    end

    leftCards = self:sortCards(leftCards)
    local mergeCards = self:mergeSortCards(leftCards)
    -- local mergeCards = leftCards
    dump(mergeCards)

    if self:isK105(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isK105")
        Is510K=true
        -- 5 10 k 只比cardtype
    elseif self:isJokerBomb(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isJokerBomb")
        isJokerBomb=true
        -- 只比cardtype
    elseif self:isNormalBomb(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isNormalBomb")
        isNormalBomb=true
        -- self.cardMax = mergeCards[1][1]
        -- self.laiziList = {}
    elseif self:isSingle(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isSingle")
        isSingle=true
        -- self.laiziList = {}
        -- self.cardMax = 16
    elseif self:isDouble(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isDouble")
        isDouble=true
        -- self.laiziList = {}
        -- self.cardMax = 16
    elseif self:isThree(mergeCards,laiziNum,joKerNum,bJoKerNum,isLast) then
        dump("isThree")
        isThree=true
        -- self.laiziList = {}
        -- self.cardMax = 16
    elseif self:isShunzi(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isShunzi")
        isShunzi=true
        -- self.laiziList = {}
        -- self.cardMax = 16
    elseif self:isLiandui(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isLiandui")
        isLiandui=true
        -- self.laiziList = {}
        -- self.cardMax = 16
--[[    elseif self:isThree(mergeCards,laiziNum,joKerNum,bJoKerNum) then
        dump("isLiandui")
        isThree=true--]]
    -- elseif self:isFeiji(mergeCards,laiziNum,joKerNum,bJoKerNum,isLast) then
        
    else
        dump("CT_INVALID")
        self.cardType = CT_INVALID
    end
    g_mainScene.laiziList={}
    if self.laiziList then   
        for i=1,#self.laiziList do       
            table.insert(g_mainScene.laiziList,{self.laiziList[i][1],self.laiziList[i][2]})
        end
    end
    dump(g_mainScene.laiziList,"---g_mainScene.laiziList---")
    dump(self.cardType)
    dump(self.cardMax)
    dump(self.laiziList,"----------")

end

function CardsAnalysis:isK105(mergeCards,laiziNum,joKerNum,bJoKerNum)
    if joKerNum >= 1 or bJoKerNum >= 1 or laiziNum >= 1 then
        return false
    end
    
    if #mergeCards == 3 and mergeCards[1][2]>2 and mergeCards[1][1] == 13 and mergeCards[2][1] == 10 and mergeCards[3][1] == 5 and 
        mergeCards[1][2] == mergeCards[2][2] and mergeCards[1][2] == mergeCards[3][2] then
        if mergeCards[1][2] == 3 then
            self.cardType = CT_510k_3
        elseif mergeCards[1][2] == 4 then
            self.cardType = CT_510k_4
        elseif mergeCards[1][2] == 5 then
            self.cardType = CT_510k_5
        elseif mergeCards[1][2] == 6 then
            self.cardType = CT_510k_6
        elseif mergeCards[1][2] == 7 then
            self.cardType = CT_510k_7
        elseif mergeCards[1][2] == 8 then
            self.cardType = CT_510k_8
        elseif mergeCards[1][2] == 9 then
            self.cardType = CT_510k_9
        elseif mergeCards[1][2] == 10 then
            self.cardType = CT_510k_10
        elseif mergeCards[1][2] == 11 then
            self.cardType = CT_510k_11
        else
            self.cardType = mergeCards[1][2] + 33
        end
        return true
    end
    return false
end

function CardsAnalysis:isJokerBomb(mergeCards,laiziNum,joKerNum,bJoKerNum)
    if laiziNum >= 1 or #mergeCards > 0 then
        return false
    end

    if joKerNum >= 1 and bJoKerNum >= 1 then
        -- 大小王混
        if joKerNum + bJoKerNum == 2 then
            self.cardType = CT_JOKER_BS
        elseif joKerNum + bJoKerNum == 3 then
            self.cardType = CT_JOKER_3
        elseif joKerNum + bJoKerNum == 4 then
            self.cardType = CT_JOKER_4
        elseif joKerNum + bJoKerNum == 5 then
            self.cardType = CT_JOKER_5
        elseif joKerNum + bJoKerNum == 6 then
            self.cardType = CT_JOKER_6
        elseif joKerNum + bJoKerNum == 7 then
            self.cardType = CT_JOKER_7
        elseif joKerNum + bJoKerNum == 8 then
            self.cardType = CT_JOKER_8
        end
        return true
    elseif joKerNum + bJoKerNum >= 2 then
        local addNum = 0
        if bJoKerNum >= 1 then
            addNum = 1
        end
        if joKerNum + bJoKerNum == 2 then
            self.cardType = CT_JOKER_SS + addNum
        elseif joKerNum + bJoKerNum == 3 then
            self.cardType = CT_JOKER_3S + addNum
        elseif joKerNum + bJoKerNum == 4 then
            self.cardType = CT_JOKER_4S + addNum
        end
        return true
    end
    return false
end

function CardsAnalysis:isNormalBomb(mergeCards,laiziNum,joKerNum,bJoKerNum)
    if joKerNum > 0 or bJoKerNum > 0 or #mergeCards < 1 then
        return false
    end

    self.cardMax = mergeCards[1][1]
    local allNum = mergeCards[1][2] + laiziNum
    self.laiziList = {}
    for i = 1, laiziNum do
        table.insert(self.laiziList, {mergeCards[1][1],0})
    end
    if allNum == 4 then
        self.cardType = CT_BOMB_4
    elseif allNum == 5 then
        self.cardType = CT_BOMB_5
    elseif allNum == 6 then
        self.cardType = CT_BOMB_6
    elseif allNum == 7 then
        self.cardType = CT_BOMB_7
    elseif allNum == 8 then
        self.cardType = CT_BOMB_8
    elseif allNum == 9 then
        self.cardType = CT_BOMB_9
    elseif allNum == 10 then
        self.cardType = CT_BOMB_10
    elseif allNum == 11 then
        self.cardType = CT_BOMB_11
    elseif allNum == 12 then
        self.cardType = CT_BOMB_12
    elseif allNum == 13 then
        self.cardType = CT_BOMB_13
    elseif allNum == 14 then
        self.cardType = CT_BOMB_14
    elseif allNum == 15 then
        self.cardType = CT_BOMB_15
    elseif allNum == 16 then
        self.cardType = CT_BOMB_16
    else
        self.cardType = CT_INVALID
        return false
    end
    return true
end

function CardsAnalysis:isSingle(mergeCards,laiziNum,joKerNum,bJoKerNum)
    if #mergeCards > 1 then
        return false
    end
    local allNum = laiziNum + joKerNum + bJoKerNum
    if #mergeCards > 0 then
        allNum = allNum + mergeCards[1][2]
    end
    self.laiziList = {}
    if allNum == 1 then
        if #mergeCards > 0 then
            self.cardMax = mergeCards[1][1]
        end
        if laiziNum > 0 then
            table.insert(self.laiziList, {1,5})
            self.cardMax = 16
        end
        if joKerNum > 0 then
            self.cardMax = 17
        end
        if bJoKerNum > 0 then
            self.cardMax = 18
        end
        self.cardType = CT_SINGLE
        return true
    end
    return false
end

function CardsAnalysis:isDouble(mergeCards,laiziNum,joKerNum,bJoKerNum)
    local allNum=0
    for i,v in ipairs(mergeCards) do
        allNum=allNum+v[2]
    end

    if joKerNum > 0 or bJoKerNum > 0 or laiziNum >= 2 or #mergeCards >= 2 or #mergeCards==0 or allNum >2 then
        return false
    end
    self.laiziList = {}
    self.cardMax = mergeCards[1][1]
    if laiziNum == 1 then
        table.insert(self.laiziList, {mergeCards[1][1],0})
    end
    self.cardType = CT_DOUBLE
    return true
end

function CardsAnalysis:isThree(mergeCards,laiziNum,joKerNum,bJoKerNum,isLast)
    if  laiziNum >= 3 then
        return false
    end
    local allNum = laiziNum
    local maxValue = 0
    for index, value in ipairs(mergeCards) do
        allNum = allNum + value[2]
        if value[2] + laiziNum >= 3 and value[1] > maxValue then
            maxValue = value[1]
        end
    end
    self.laiziList = {}
    -- 3 h h 4 4
    if isLast ~= true then
        if allNum ~= 5 then
            return false
        else
            if laiziNum > 0 then
                for i = 1, laiziNum do
                    table.insert(self.laiziList, {maxValue,0})
                end
            end
            self.cardMax = maxValue
            self.cardType = CT_THREE_FULL
            return true
        end
    else

        if allNum >= 3 and allNum <= 5 and maxValue > 0 then
            self.cardMax = maxValue
            self.cardType = CT_THREE
            return true
        end
    end

    return false
end

function CardsAnalysis:isShunzi(mergeCards,laiziNum,joKerNum,bJoKerNum)
    if joKerNum > 0 or bJoKerNum > 0 then
        return false
    end
    -- 3-a
    local allNum = laiziNum
    local cardMin = 15
    local cardMax = 0
    for index, value in ipairs(mergeCards) do
        if value[2] >= 2 or value[1] == 15 then
            return false
        end
        allNum = allNum + value[2]
        if value[1] < cardMin then
            cardMin = value[1]
        end
        if value[1] > cardMax then
            cardMax = value[1]
        end
    end
    -- dump(laiziNum)
    -- dump(allNum)
    if allNum < 5 then
        return false
    end
    self.laiziList = {}
    local leftLaiziNum = laiziNum
    -- 补缺
    for index, value in ipairs(mergeCards) do
        if index ~= 1 then
            if mergeCards[index-1][1] - mergeCards[index][1] ~= 1 then
                for i = 1, mergeCards[index-1][1] - mergeCards[index][1] - 1 do
                    -- dump(mergeCards[index][1])
                    table.insert(self.laiziList, {mergeCards[index-1][1] - i,0})
                end
                leftLaiziNum = leftLaiziNum - (mergeCards[index-1][1] - mergeCards[index][1] - 1)
            end
        end
    end
    -- dump(leftLaiziNum)
    if leftLaiziNum < 0 then
        return false
    end

    -- 前补 
    if leftLaiziNum > 0 then
        local endNum = leftLaiziNum
        for i = 1, endNum do        
            if cardMax + 1 < 15 and leftLaiziNum > 0 then
                cardMax = cardMax + 1
                table.insert(self.laiziList, {cardMax,0})
                leftLaiziNum = leftLaiziNum - 1
            end
        end
    end

    -- 后补 
    if leftLaiziNum > 0 then
        local endNum = leftLaiziNum
        for i = 1, endNum do        
            if cardMin - 1 >= 3 and leftLaiziNum > 0 then
                cardMin = cardMin - 1
                table.insert(self.laiziList, {cardMin,0})
                leftLaiziNum = leftLaiziNum - 1
            end
        end
    end

    if leftLaiziNum ~= 0 then
        return false
    end

    self.cardMax = cardMin
    self.cardType = CT_STRAIGHT
    return true
end

function CardsAnalysis:isLiandui(mergeCards,laiziNum,joKerNum,bJoKerNum)
    if joKerNum > 0 or bJoKerNum > 0 then
        return false
    end

    local allNum = laiziNum
    local cardMin = 15
    local cardMax = 0
    for index, value in ipairs(mergeCards) do
        if value[2] > 2 or value[1] > 13 then
            return false
        end
        allNum = allNum + value[2]
        if value[1] < cardMin then
            cardMin = value[1]
        end
        if value[1] > cardMax then
            cardMax = value[1]
        end
    end
    self.laiziList = {}

    local leftLaiziNum = laiziNum
    dump(leftLaiziNum)

    -- 补缺
    for index, value in ipairs(mergeCards) do
        if index ~= 1 then
            if mergeCards[index-1][1] - mergeCards[index][1] ~= 1 then
                for i = 1, 2 do
                    table.insert(self.laiziList, {mergeCards[index-1][1] - 1,0})
                end
                dump(mergeCards[index-1][1])
                dump(mergeCards[index][1])

                leftLaiziNum = leftLaiziNum - (mergeCards[index-1][1] - mergeCards[index][1] - 1)*2

                dump(leftLaiziNum)
            end
            if mergeCards[index][2] < 2 then
                dump(mergeCards[index][2])
                for i = 1, (2-mergeCards[index][2]) do
                    dump("asdf")

                    table.insert(self.laiziList, {mergeCards[index][1],0})
                end
                leftLaiziNum = leftLaiziNum - (2-mergeCards[index][2])
                dump(leftLaiziNum)

            end
        elseif value[2] < 2 then
            for i = 1, (2 - value[2]) do
                table.insert(self.laiziList, {value[1],0})
            end
            leftLaiziNum = leftLaiziNum - (2 - value[2])
            dump(leftLaiziNum)

        end
        if leftLaiziNum < 0 then
            return false
        end
    end

    -- 前补 
    dump(leftLaiziNum)
    dump(cardMax)
    if leftLaiziNum == 2 then   
        if cardMax + 1 < 14 then
            cardMax = cardMax + 1
            for i = 1,2 do
                table.insert(self.laiziList, {cardMax,0})
            end
            leftLaiziNum = leftLaiziNum - 2
        end
    end

    -- 后补 
    if leftLaiziNum == 2 then   
        if cardMin - 1 >= 3 then
            cardMin = cardMin - 1
            for i = 1,2 do
                table.insert(self.laiziList, {cardMin,0})
            end
            leftLaiziNum = leftLaiziNum - 2
        end
    end

    self.cardType = CT_DOUBLE_LINK
    self.cardMax = cardMin
    return true
end

function CardsAnalysis:isFeiji(mergeCards,laiziNum,joKerNum,bJoKerNum,isLast)
    -- if isLast then
    --     local allNum = laiziNum
    --     for index, value in ipairs(mergeCards) do
    --         allNum = allNum + value[2]
    --     end

    -- else


    -- end

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

function CardsAnalysis:analysisFoldingCards(allHandCards)
    local reList = {}
    local zdList = {}   -- 折叠牌列表
    local lastValue = nil
    for index, value in ipairs(allHandCards) do
        if #zdList == 0 or lastValue == nil then
            table.insert(zdList, value)
            lastValue = value
        elseif value[2] == 4 and lastValue[2] == 4 then
            table.insert(zdList, value)
            lastValue = value
        elseif value[2] ~= 4 and lastValue[2] ~= 4 and value[1] == lastValue[1] then
            table.insert(zdList, value)
            lastValue = value
        else
            table.insert(reList, zdList)
            zdList = {}
            table.insert(zdList, value)
            lastValue = value
        end
    end

    if #zdList ~= 0 then
        table.insert(reList, zdList)
    end
    return reList
end

return CardsAnalysis