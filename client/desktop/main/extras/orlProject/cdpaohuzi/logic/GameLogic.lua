--GameLogic.lua
-- Author     : zzy
-- Date       : 2019-01-10

--字牌数据
local s_CardData =
{
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,          --小写 一 ~ 十
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,          --小写
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,          --小写
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,          --小写

    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A,          --大写 壹 ~ 拾
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A,          --大写
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A,          --大写
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A,          --大写
}

local GameLogic = class("GameLogic")

function GameLogic:ctor()
    math.randomseed(os.time())
end

--------------------------控制函数--------------------
function GameLogic:GetValue( cardData )
    return cardData % 16
end

function GameLogic:GetColor( cardData )
    return math.floor(cardData / 16)
end

--混乱字牌
function GameLogic:RandCardData(cardData, bMaxCount)
    local retCardData = {}
    local cardDataTemp = clone(cardData)

    local randCount = 1
    local position = 0
    while (randCount <= bMaxCount) do
        position = math.random(5400) % (FULL_COUNT - randCount + 1) + 1
        retCardData[randCount] = cardDataTemp[position]
        cardDataTemp[position] = cardDataTemp[FULL_COUNT - randCount + 1]
        randCount = randCount + 1
    end
    return retCardData
end 

-------------------------获取字牌组合函数----------------------------
function GameLogic:cardArrSort(arrTemp)
    if #arrTemp == 0 then return arrTemp end
    local tableSortNew = function(a,b)
        local index_1 = self:SwitchToCardIndex(a[1])
        if index_1 > 9 then
            index_1 = index_1 - 10
        end
        local index_2 = self:SwitchToCardIndex(b[1])
        if index_2 > 9 then
            index_2 = index_2 - 10
        end
        return index_1 < index_2 
    end
    for k,v in pairs(arrTemp) do
        table.sort(v)
    end
    table.sort(arrTemp,tableSortNew)
end


--先将全部四个和三个的全部弄出来，再将吃的弄出来就ok了。这个是原来定义的规则，现在的规则太多了，捂脸，老板怎么加就怎么加
function GameLogic:getCurhandCard(cardData)
    local ArrayCount = 0
    local IndexTemp = {}
    local WeaveArray = {}

    IndexTemp = clone(self:SwitchToCardIndexList(cardData))
    -- dump(IndexTemp)

    local TwoNumber_InsertArr_Func = function (index,number)
        local cardArr = {}
        local curCard_1 = self:SwitchToCardData(index)
        local curCard_2 = self:SwitchToCardData(index+number)
        table.insert(cardArr,curCard_1)
        table.insert(cardArr,curCard_2)
        IndexTemp[index] = 0
        IndexTemp[index+number] = 0
        ArrayCount = ArrayCount + 1
        table.insert(WeaveArray,cardArr)
    end

    local InsertArrFunc = function(data,index,cardNum)
        if data[index] == cardNum then
            local curCard = self:SwitchToCardData(index)
            local cardArr = {}
            for j=1,cardNum do
                table.insert(cardArr,curCard)
            end
            data[index] = 0
            ArrayCount = ArrayCount + 1
            table.insert(WeaveArray,cardArr)
        end
    end

    local Other_InsertArr_Func = function(index_1,index_2,index_3)
        local curCard_1 = self:SwitchToCardData(index_1)
        local curCard_2 = self:SwitchToCardData(index_2)
        local curCard_3 = self:SwitchToCardData(index_3)

        local cardArr = {}
        table.insert(cardArr,curCard_1)
        table.insert(cardArr,curCard_2)
        table.insert(cardArr,curCard_3)
        -- IndexTemp[index_1] = 0
        -- IndexTemp[index_2] = 0
        -- IndexTemp[index_3] = 0
        IndexTemp[index_1] = IndexTemp[index_1] - 1 
        IndexTemp[index_2] = IndexTemp[index_2] - 1
        IndexTemp[index_3] = IndexTemp[index_3] - 1
        ArrayCount = ArrayCount + 1
        table.insert(WeaveArray,cardArr)
    end

    --将单独的一张牌加到其他的数组中
    local AddCardToOtherArr = function(index)
        if #WeaveArray == 0 then return end
        print("=====777777=======index===",index)
        local curCard = self:SwitchToCardData(index)
        for k,v in pairs(WeaveArray) do
            if #v == 2 then
                for k1,v1 in pairs(v) do
                    local tempCardIndex = self:SwitchToCardIndex(v1)
                    print("===index===tempCardIndex====",index,tempCardIndex)
                    if index == (tempCardIndex - 1) or index == (tempCardIndex + 1) or index == (tempCardIndex -10) or index == (tempCardIndex +10) then
                        if IndexTemp[index] > 0 then
                            IndexTemp[index] = 0
                            table.insert(v,curCard)
                            return
                        end
                    end
                end
            end
        end
        -- local cardArr = {curCard}
        -- if IndexTemp[index] > 0 then
        --     IndexTemp[index] = 0
        --     ArrayCount = ArrayCount + 1
        --     table.insert(WeaveArray,cardArr)
        -- end
        
    end

    for i=0,9 do
        if IndexTemp[i] > 4 then
            IndexTemp[i] = 0
        end
        --先将全部四个的弄出来AAAA or aaaa
        InsertArrFunc(IndexTemp,i,4)
        InsertArrFunc(IndexTemp,i+10,4)
    end

    for i=0,9 do
        --aaa or AAA
        InsertArrFunc(IndexTemp,i,3) 
        InsertArrFunc(IndexTemp,i+10,3) 
    end

    --changed by zzy 2019.4.1
    --取出123(大小)(全部单牌)
    for i=0,19 do
        if i == 0 or i == 10 then
           if IndexTemp[i] == 1 and IndexTemp[i+1] == 1 and IndexTemp[i+2]  == 1 then
               Other_InsertArr_Func(i,i+1,i+2)
           end
        end
    end

    --取出2 7 10
    for i=0,19 do
        if i == 1 or i == 11 then
           if IndexTemp[i] == 1 and IndexTemp[i+5] == 1 and IndexTemp[i+8]  == 1 then
               Other_InsertArr_Func(i,i+5,i+8)
           end
        end
    end

    --取出123(大小)
    for i=0,19 do
        if i == 0 or i == 10 then
           if IndexTemp[i] >= 1 and IndexTemp[i+1] >= 1 and IndexTemp[i+2]  >= 1 and (IndexTemp[i] + IndexTemp[i+1] + IndexTemp[i+2])  <= 4 then
               Other_InsertArr_Func(i,i+1,i+2)
           end
        end
    end

    --取出2 7 10
    for i=0,19 do
        if i == 1 or i == 11 then
           if IndexTemp[i] >= 1 and IndexTemp[i+5] >= 1 and IndexTemp[i+8]  >= 1 and (IndexTemp[i] + IndexTemp[i+5] + IndexTemp[i+8])  <= 4 then
               Other_InsertArr_Func(i,i+5,i+8)
           end
        end
    end

    --abc，ABC 取出顺子
    for i=0,9 do
        if IndexTemp[i] == 1 and IndexTemp[i+1] == 1 and IndexTemp[i+2] == 1 then
            Other_InsertArr_Func(i,i+1,i+2)
        end 
        if IndexTemp[i+10] == 1 and IndexTemp[i+11] == 1 and IndexTemp[i+12] == 1 then
            Other_InsertArr_Func(i+10,i+11,i+12)
        end 
    end

    --aaB
    for i=0,9 do
        if IndexTemp[i] == 2 and IndexTemp[i+10] == 1 then
             Other_InsertArr_Func(i,i,i+10)
        end
    end

    --AAb
    for i=0,9 do
        if IndexTemp[i+10] == 2 and IndexTemp[i] == 1 then
             Other_InsertArr_Func(i,i+10,i+10)
        end
    end

    --aa
    for i=0,9 do
        if IndexTemp[i] == 2  then
             InsertArrFunc(IndexTemp,i,2)
        end
    end

    --AA
    for i=10,19 do
        if IndexTemp[i] == 2  then
             InsertArrFunc(IndexTemp,i,2)
        end
    end

    --Aa
    for i=0,9 do
        if IndexTemp[i] == 1 and IndexTemp[i+10] == 1 then
             TwoNumber_InsertArr_Func(i,10)
        end
    end

    for i=0,7 do
        if IndexTemp[i] == 1 and IndexTemp[i+2] == 1 then
            local cardArr = {}
            local curCard_1 = self:SwitchToCardData(i)
            local curCard_2 = self:SwitchToCardData(i+2)
            table.insert(cardArr,curCard_1)
            table.insert(cardArr,curCard_2)
            IndexTemp[i] = 0
            IndexTemp[i+2] = 0
            ArrayCount = ArrayCount + 1
            table.insert(WeaveArray,cardArr)
        end
    end

    for i=10,17 do
        if IndexTemp[i] == 1 and IndexTemp[i+2] == 1 then
            local cardArr = {}
            local curCard_1 = self:SwitchToCardData(i)
            local curCard_2 = self:SwitchToCardData(i+2)
            table.insert(cardArr,curCard_1)
            table.insert(cardArr,curCard_2)
            IndexTemp[i] = 0
            IndexTemp[i+2] = 0
            ArrayCount = ArrayCount + 1
            table.insert(WeaveArray,cardArr)
        end
    end

    --（2，7），（2，10），（7，10）：无论大小
    for i=0,9 do
        if i == 1 and IndexTemp[i] == 1 and IndexTemp[i+5] == 1 then
            TwoNumber_InsertArr_Func(i,5)
        end

         if i == 1 and IndexTemp[i] == 1 and IndexTemp[i+8] == 1 then
            TwoNumber_InsertArr_Func(i,8)
        end

        if i == 6 and IndexTemp[i] == 1 and IndexTemp[i+3] == 1 then
            TwoNumber_InsertArr_Func(i,3)
        end

        if i == 1 and IndexTemp[i+10] == 1 and IndexTemp[i+15] == 1 then
            TwoNumber_InsertArr_Func(i+10,15)
        end

        if i == 1 and IndexTemp[i+10] == 1 and IndexTemp[i+18] == 1 then
            TwoNumber_InsertArr_Func(i+10,18)
        end

        if i == 6 and IndexTemp[i+10] == 1 and IndexTemp[i+13] == 1 then
            TwoNumber_InsertArr_Func(i+10,13)
        end
    end



    -- --changed by yang
    -- --取出123（大小）
    -- -- dump(IndexTemp)
    -- for i=0,19 do
    --     for j=1,2 do
    --         if (i == 0 or i == 10) and IndexTemp[i] > 0 and IndexTemp[i+1] > 0 and IndexTemp[i+2] > 0 then
    --             Other_InsertArr_Func(i,i+1,i+2)
    --         end 
    --     end 
    -- end
    -- --取出2，7，10（大小）
    -- for i=0,19 do
    --     for j=1,2 do
    --         if (i == 1 or i == 11) and IndexTemp[i] > 0 and IndexTemp[i+5] > 0 and IndexTemp[i+8] > 0 then
    --             Other_InsertArr_Func(i,i+5,i+8)
    --         end 
    --     end
    -- end

    -- --AAa
    -- for i=0,9 do
    --     if IndexTemp[i+10] == 2 and IndexTemp[i] == 1 then
    --         Other_InsertArr_Func(i+10,i+10,i)
    --     end
    -- end

    -- --aaA
    -- for i=0,9 do
    --     if IndexTemp[i] == 2 and IndexTemp[i+10] == 1 then
    --         Other_InsertArr_Func(i,i,i+10)
    --     end
    -- end

    -- --abc or ABC
    -- for i=0,9 do
    --     for j=1,2 do
    --         if i < 8 and IndexTemp[i] > 0 and IndexTemp[i+1] > 0 and IndexTemp[i+2] > 0  then
    --             Other_InsertArr_Func(i,i+1,i+2)
    --         end
    --         if i < 8 and IndexTemp[i+10] > 0 and IndexTemp[i+11] > 0 and IndexTemp[i+12] > 0 then
    --             Other_InsertArr_Func(i+10,i+11,i+12)
    --         end
    --     end
    -- end

    --  --AAa
    -- for i=0,9 do
    --     if IndexTemp[i+10] == 2 and IndexTemp[i] > 0 then
    --         Other_InsertArr_Func(i+10,i+10,i)
    --     end
    -- end


    -- --aaA
    -- for i=0,9 do
    --     if IndexTemp[i] == 2 and IndexTemp[i+10] > 0 then
    --         Other_InsertArr_Func(i,i,i+10)
    --     end
    -- end

    -- --AA aa
    -- for i=0,9 do
    --     if IndexTemp[i] == 2 and IndexTemp[i+10] == 0 then
    --         InsertArrFunc(IndexTemp,i,2)
    --     end
    --     if IndexTemp[i] == 0 and IndexTemp[i+10] == 2 then
    --         InsertArrFunc(IndexTemp,i+10,2)
    --     end
    -- end

    -- --ab or AB
    -- for i=0,9 do
    --     local cardArr = {}
    --     if i < 9 and IndexTemp[i] == 1 and IndexTemp[i+1] == 1 then
    --         IndexTemp[i] = 0
    --         IndexTemp[i+1] = 0
    --         local curCard_1 = self:SwitchToCardData(i)
    --         local curCard_2 = self:SwitchToCardData(i+1)
    --         cardArr = {curCard_1,curCard_2}
    --         ArrayCount = ArrayCount + 1
    --         table.insert(WeaveArray,cardArr)
    --     end
    --     if i < 9 and IndexTemp[i+10] == 1 and IndexTemp[i+11] == 1 then
    --         IndexTemp[i+10] = 0
    --         IndexTemp[i+11] = 0
    --         local curCard_1 = self:SwitchToCardData(i+10)
    --         local curCard_2 = self:SwitchToCardData(i+11)
    --         cardArr = {curCard_1,curCard_2}
    --         ArrayCount = ArrayCount + 1
    --         table.insert(WeaveArray,cardArr)
    --     end
    -- end

    --(这个干掉---又要改需求了 begain)
    --先保留原来一部分，防止后面又要改回来

    -- for i=0,9 do
    --     --AA aa
    --     if IndexTemp[i] == 2 and IndexTemp[i+10] == 2 then
    --         InsertArrFunc(IndexTemp,i,2)
    --         InsertArrFunc(IndexTemp,i+10,2)
    --     end

    --     if IndexTemp[i] == 2 and IndexTemp[i+10] == 0 then
    --         InsertArrFunc(IndexTemp,i,2)
    --     end

    --     if IndexTemp[i] == 0 and IndexTemp[i+10] == 2 then
    --         InsertArrFunc(IndexTemp,i+10,2)
    --     end

    --     --aaA
    --     if IndexTemp[i] == 2 and IndexTemp[i+10] == 1 then
    --         Other_InsertArr_Func(i,i,i+10)
    --     end
    --     --AAa
    --     if IndexTemp[i] == 1 and IndexTemp[i+10] == 2 then
    --         Other_InsertArr_Func(i,i+10,i+10)
    --     end
        
    -- end

    -- for i=0,9 do
    --     --abc or ABC or 二七十 or aA 
    --     if IndexTemp[i] == 1 then
    --         --abc
    --         if IndexTemp[i+1] == 1 and IndexTemp[i+2] == 1 and i < 8 then
    --             Other_InsertArr_Func(i,i+1,i+2)
    --         end
    --         --ABC
    --         if IndexTemp[i+1] == 1 and IndexTemp[i+2] == 1 and i > 9 and i < 18 then
    --             Other_InsertArr_Func(i,i+1,i+2)
    --         end
    --         --2 7 10
    --         if IndexTemp[i+5] == 1 and IndexTemp[i+8] == 1 and i == 1 then
    --             Other_InsertArr_Func(i,i+5,i+8)
    --         end
    --         --二 七 十
    --         if IndexTemp[i+5] == 1 and IndexTemp[i+8] == 1 and i == 11 then
    --             Other_InsertArr_Func(i,i+5,i+8)
    --         end
    --     end
    -- end

     --(这个干掉---又要改需求了 end)

    -- for i=0,9 do
    --     if i == 1 and IndexTemp[i] == 1 and IndexTemp[i+5] == 1 then
    --         TwoNumber_InsertArr_Func(i,5)
    --     end

    --      if i == 1 and IndexTemp[i] == 1 and IndexTemp[i+8] == 1 then
    --         TwoNumber_InsertArr_Func(i,8)
    --     end

    --     if i == 6 and IndexTemp[i] == 1 and IndexTemp[i+3] == 1 then
    --         TwoNumber_InsertArr_Func(i,3)
    --     end

    --     if i == 1 and IndexTemp[i+10] == 1 and IndexTemp[i+15] == 1 then
    --         TwoNumber_InsertArr_Func(i+10,15)
    --     end

    --     if i == 1 and IndexTemp[i+10] == 1 and IndexTemp[i+18] == 1 then
    --         TwoNumber_InsertArr_Func(i+10,18)
    --     end

    --     if i == 6 and IndexTemp[i+10] == 1 and IndexTemp[i+13] == 1 then
    --         TwoNumber_InsertArr_Func(i+10,13)
    --     end
    -- end

    -- for i=0,9 do
    --     if IndexTemp[i+10] == 1 and IndexTemp[i] == 1 then
    --         local cardArr = {}
    --         local curCard_1 = self:SwitchToCardData(i)
    --         local curCard_2 = self:SwitchToCardData(i+10)
    --         table.insert(cardArr,curCard_1)
    --         table.insert(cardArr,curCard_2)
    --         IndexTemp[i] = 0
    --         IndexTemp[i+10] = 0
    --         ArrayCount = ArrayCount + 1
    --         table.insert(WeaveArray,cardArr)
    --     end
    -- end

    -- for i=0,7 do
    --     if IndexTemp[i] == 1 and IndexTemp[i+2] == 1 then
    --         local cardArr = {}
    --         local curCard_1 = self:SwitchToCardData(i)
    --         local curCard_2 = self:SwitchToCardData(i+2)
    --         table.insert(cardArr,curCard_1)
    --         table.insert(cardArr,curCard_2)
    --         IndexTemp[i] = 0
    --         IndexTemp[i+2] = 0
    --         ArrayCount = ArrayCount + 1
    --         table.insert(WeaveArray,cardArr)
    --     end
    -- end


    -- for i=10,17 do
    --     if IndexTemp[i] == 1 and IndexTemp[i+2] == 1 then
    --         local cardArr = {}
    --         local curCard_1 = self:SwitchToCardData(i)
    --         local curCard_2 = self:SwitchToCardData(i+2)
    --         table.insert(cardArr,curCard_1)
    --         table.insert(cardArr,curCard_2)
    --         IndexTemp[i] = 0
    --         IndexTemp[i+2] = 0
    --         ArrayCount = ArrayCount + 1
    --         table.insert(WeaveArray,cardArr)
    --     end
    -- end

    for i=0,19 do
        if IndexTemp[i] == 1 then
            AddCardToOtherArr(i)
        end
    end

    local addNum = 0
    local tempArr = {}
    for i=0,19 do
        if IndexTemp[i] == 1 then
            local curCard = self:SwitchToCardData(i)
            table.insert(tempArr,curCard)
            addNum = addNum + 1
            IndexTemp[i] = 0
            if addNum == 3 then
                addNum = 0
                ArrayCount = ArrayCount + 1
                table.insert(WeaveArray,tempArr)
                tempArr = {}
            end
        end
    end

    if addNum ~= 0 then
        addNum = 0
        ArrayCount = ArrayCount + 1
        table.insert(WeaveArray,tempArr)
        tempArr = {}
    end

    self:cardArrSort(WeaveArray)

    -- dump(WeaveArray)

    return WeaveArray,ArrayCount
end
-------------------------获取字牌组合函数----------------------------

--吃牌函数--
local c = 
{
    {0,  1,   2,  0,  9},
    {0, -1,   1,  0,  9},
    {0, -2,  -1,  0,  9},
    {0,  1,   2, 10,  19},
    {0, -1,   1, 10,  19},
    {0, -2,  -1, 10,  19},

    {1,  5,   8,  0,  9},
    {6,  -5,   3,  0,  9},
    {9,  -3,   -8,  0,  9},

    {11,  5,   8,  10,  19},
    {16,  -5,   3,  10,  19},
    {19,  -3,   -8,  10,  19},

    {0,  0,  10,  0,  19},
    {0, 10,  10,  0,  19},
    {0,-10, -10,  0,  19},
    {0,-10,   0,  0,  19},
}

function GameLogic:clearCardByCardArr(hash,tempArr,val)
    for k,v in pairs(tempArr) do
        hash[v] = hash[v] + val
    end
    return hash
end

function GameLogic:xuhuan_lookup_chipai(hash,card)
    local tempArr2 = {}
    for _,v in ipairs(c) do
        local tempHash = clone(hash)
        if card == v[1] or v[1] == 0 then
            local card1 = card + v[2]
            local card2 = card + v[3]
            if card1 >= v[4] and card1 <= v[5]
            and card2 >= v[4] and card2 <= v[5] 
            and card >= v[4] and card <= v[5]  then
                tempHash[card] = tempHash[card] - 1
                tempHash[card1] = tempHash[card1] - 1
                tempHash[card2] = tempHash[card2] - 1
                if tempHash[card1] >= 0 and tempHash[card2] >= 0 then
                    local tempArr = {card,card1,card2}
                    table.insert(tempArr2,tempArr)
                end
            end
        end
    end
    return tempArr2
end

function GameLogic:bipai(hash,card,t_cnt)
    if hash[card] <= 0 then
        return true
    end
    local result = false
    for _, v in ipairs(c) do
        local tempHash = clone(hash)
        if card == v[1] or v[1] == 0 then
            local card1 = card + v[2]
            local card2 = card + v[3]
            if card1 >= v[4] and card1 <= v[5]
            and card2 >= v[4] and card2 <= v[5] 
            and card >= v[4] and card <= v[5]  then
                tempHash[card] = tempHash[card] - 1
                tempHash[card1] = tempHash[card1] - 1
                tempHash[card2] = tempHash[card2] - 1
                if tempHash[card1] >= 0 and tempHash[card2] >= 0  then
                    local tempArr = {card,card1,card2}
                    self:clearCardByCardArr(hash,tempArr,-1)
                    local re = self:bipai(hash, card, t_cnt + 1)
                    result = result or  re
                    if re and hash[card] <= 0 then
                        self.cnt = self.cnt + 1
                    end
                    local tempArr = {card,card1,card2}
                    self:clearCardByCardArr(hash,tempArr,1)
                end
            end
        end
    end
    return result
end

function GameLogic:can_bipai(hash,cardlist,card)
    self.cnt = 1
    self:clearCardByCardArr(hash,cardlist,-1)
    if hash[card] > 0 then
        return self:bipai(hash,card,0)
    end
    return true
end 

function GameLogic:get_all_chipai(hash,card)
    local ChiWeave = {}
    local tempAllChiPai = self:get_chipaiArr(hash,card)
    -- if tempAllChiPai == nil or #tempAllChiPai == 0 then return ChiWeave end
    for k,v in pairs(tempAllChiPai) do
        local tempHash = clone(hash)
        local isCanBiPai =  self:can_bipai(tempHash,v,card)
        if isCanBiPai then
            table.insert(ChiWeave,v)
        end
    end
    return ChiWeave
end

function GameLogic:get_all_bipai(tempHash,card,chipaiarr )
    local hash = clone(tempHash)
    self:clearCardByCardArr(hash,chipaiarr,-1)
    local temparr = self:get_all_chipai(hash,card)
    return temparr
end


function GameLogic:get_chipaiArr(hash,card)
    local chipaiArr = {}
    local cardNum = hash[card]
    if hash[card] <= 0 then return chipaiArr end
    local tempArr = self:xuhuan_lookup_chipai(hash,card) 
    return tempArr
end

--获取所有手牌中满足手牌打出能听牌的牌
function GameLogic:getHCSpriteArr()
    local tempHCArr = {}
    local tempHandCardsData = g_CardScene:getMyHandCardData()
    local tempTingCardsData = {}
    if #tempHandCardsData >= 1 then
        tempTingCardsData = self.m_GameLogic:getTingCardArr(tempHandCardsData)
    end
end

--听牌函数
function GameLogic:getTingCardArr(cardList)
    -- print("====进入听牌函数===")
    local final_list = {}
    local tingcard_list = {}
    local MEET_ALL_HU_XI = GAME_HU_XI
    local tempDownCardArr = g_CardScene.m_WeaveItem
    local tempMyChairHuXi = g_CardScene:getMyChairHuXi()

    -- print("==tempDownCardArr==")
    -- dump(tempDownCardArr)

    function get_val(card)
        local val = card
        local isMax = false
        if card > 16 then
            val = card - 16
            isMax = true
        end
        return val,isMax
    end

    function change_hash(hash,val,...)
        local pos_list = {...}
        for k,v in pairs(pos_list) do
            hash[v] = hash[v] + val
        end
        if val < 0 then
            for k, v in ipairs(pos_list) do
                for i = 1, -val do
                    table.insert(final_list, v)
                end
            end
        else
            for k, v in ipairs(pos_list) do
                for i = 1, val do
                    table.remove(final_list)
                end
            end
        end
    end

    --[[
        1：将自己吃过的牌，进行一次筛选，可否（提）
        2：再将手中的牌进行筛选，可否（提、偎）
        3：将手中牌有三张的全部选出来
        4：调用原来的牌型组合，进行彻底的递归，选出所有的听牌
    ]]

    --[[
        1：提（大：12，小：9，）
        2：跑（大：9，小：6）
        3：偎（大：6，小：3）
        -- 4：三张（大：3，小：1）
        5：2，7，10或者1，2，3（大：6，小：3）
        6：abc(0)
        7：aa,AA(0)
    ]]
    local score = 0    --手中的牌的胡息（去掉能提、偎的牌）
    local out_Card_huxi = 0 --桌面上的牌，以及手中可提、偎的牌  胡息
    local allCards = {1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23,24,25,26}
    local tempMyChairArr = g_PHZMainScene:get_my_down_card()
    -- dump(tempMyChairArr)

    function f(cardList)
        if #cardList == 21 then
            return nil
        end
        tingcard_list = {} 
        for k,v in pairs(allCards) do
            local tempCardList = clone(cardList)
            out_Card_huxi = 0
            local tempVal,isMax = get_val(v)
            --第一步
            for k1,v1 in pairs(tempMyChairArr) do
                --判断可提
                if v1.cbWeaveKind == AK_PENG  then
                    if v1.cbCenterCard == v then 
                        if isMax then           -- 碰变成跑，胡息在原来的基础上变化
                            out_Card_huxi = out_Card_huxi + 6
                        else
                            out_Card_huxi = out_Card_huxi + 5
                        end
                        break
                    end
                end

                if v1.cbWeaveKind == AK_SAO then  --偎变成提
                    if v1.cbCenterCard == v then
                        out_Card_huxi = out_Card_huxi + 6
                        break
                    end
                end
            end

            --第二步
            local hash = {}
            for i = 1, 31 do
                hash[i] = 0
            end

            if out_Card_huxi <= 0 then
                table.insert(tempCardList,v)
            end
          
            for k1, v1 in ipairs(tempCardList) do
                hash[v1] = hash[v1] + 1
            end

            for k1,v1 in pairs(hash) do
                if v1 == 4 and k1 == v then  --将手中的三张牌提
                    if k1>16 then
                        out_Card_huxi = out_Card_huxi + 12
                    else
                        out_Card_huxi = out_Card_huxi + 9
                    end
                    hash[k1] = 0
                    -- break
                end

                if v1 == 3 and k1 == v then  --将手中相同的两张牌变成偎
                    -- print("==已经变成v了=="..v)
                    if k1 > 16 then
                        out_Card_huxi = out_Card_huxi + 6
                    else
                        out_Card_huxi = out_Card_huxi + 3
                        -- print("=将手中相同的两张牌变成偎=33333333=="..v.."==k1=="..k1)
                    end
                    hash[k1] = 0
                    -- print("out_Card_huxi=:"..out_Card_huxi)
                    -- dump(hash)
                end

                --第三步
                if v1 == 3 and k1 ~= v then  --将手中相同的三张牌提出来变成偎
                    if k1 > 16 then
                        -- print("=将手中相同的三张牌提出来变成碰=33333333=="..v.."==k1=="..k1)
                        out_Card_huxi = out_Card_huxi + 6
                    else
                        out_Card_huxi = out_Card_huxi + 3
                    end
                    hash[k1] = 0
                    -- dump(hash)
                end
            end

            --第四步
            final_list = {}
            score = 0
            local tempHash = clone(hash)
            score = get_hu_xi(tempHash)

            --最后一步
            if score ~= -1 then
                if (MEET_ALL_HU_XI - tempMyChairHuXi - score - out_Card_huxi) <= 0 then
                    -- print("=============88888888888888888888===============")
                    -- print("==听牌函数：=="..tempMyChairHuXi.."=="..score.."=="..out_Card_huxi)
                    table.insert(tingcard_list,v)
                end
            end
        end
        print("我进来了吗？听牌听牌啊！！！")
        return tingcard_list
    end

    function f2(cardList)
        tingcard_list = {}
        for k,v in pairs(allCards) do
            local tempCardList = clone(cardList)
            out_Card_huxi = 0
            local tempVal,isMax = get_val(v)

            --第二步
            local hash = {}
            for i = 1, 31 do
                hash[i] = 0
            end

            if out_Card_huxi <= 0 then
                table.insert(tempCardList,v)
            end
          
            for k1, v1 in ipairs(tempCardList) do
                hash[v1] = hash[v1] + 1
            end

            for k1,v1 in pairs(hash) do
                if v1 == 4 and k1 == v then  --将手中的三张变成偎
                    if k1>16 then
                        out_Card_huxi = out_Card_huxi + 6
                    else
                        out_Card_huxi = out_Card_huxi + 3
                    end
                    hash[k1] = 1
                end

                -- --第三步
                if v1 == 3 and k1 ~= v then  --将手中相同的三张牌提出来变成偎
                    if k1 > 16 then
                        out_Card_huxi = out_Card_huxi + 6
                    else
                        out_Card_huxi = out_Card_huxi + 3
                    end
                    hash[k1] = 0
                end

            end

            --第四步
            final_list = {}
            score = 0
            local tempHash = clone(hash)
            score = get_hu_xi_min(tempHash,v)

            --最后一步
            if score ~= -1 then
                if (MEET_ALL_HU_XI - tempMyChairHuXi - score - out_Card_huxi) <= 0 then
                    table.insert(tingcard_list,v)
                end
            end
        end
        return tingcard_list
    end

    local cc = 1
    function get_hu_xi(hash)

        -- cc = cc + 1
        -- print("==score_(get_hu_xi)=cc=",cc)
        -- for i=1,31 do
        --     if hash[i] > 0 then
        --         if hash[i] == 3 then
        --             change_hash(hash,-3,i)
        --         end
        --     end
        -- end

        for i = 1, 31 do
            if hash[i] > 0 then
                if hash[i] == 3 then
                    change_hash(hash,-3,i)
                end
                -- print("i == ",i,hash[i])
                local tempV,tempMax = get_val(i)
                
                if get_val(i) == 2 and hash[i + 5] > 0 and hash[i + 5] < 3 and hash[i + 8] > 0 and hash[i + 8] < 3 then
                    change_hash(hash, -1, i, i + 5, i + 8)
                    if i>16 then
                        score = score + 6
                    else
                        score = score + 3
                    end
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, 1, i, i + 5, i + 8)
                        if i>16 then
                            score = score - 6
                        else
                            score = score - 3
                        end
                    else
                        return score
                    end
                end
                
                if hash[i + 1] > 0 and hash[i + 1] < 3 and hash[i + 2] > 0 and hash[i + 2] < 3 then
                    -- print("第一个数为："..i)
                    change_hash(hash, -1, i, i + 1, i + 2)
                    if get_val(i) == 1 then
                        if tempMax then
                            score = score + 6
                        else
                            score = score + 3
                        end
                    end
                    
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, 1, i, i + 1, i + 2)
                        if get_val(i) == 1 then
                            if tempMax then
                                score = score - 6
                            else
                                score = score - 3
                            end
                        end  
                    else
                        return score
                    end
                end
                
                if i < 16 and hash[i + 16] > 0 and hash[i + 16] < 3 and hash[i] + hash[i + 16] >= 3 then
                    local cnt = hash[i]
                    change_hash(hash, -cnt, i)
                    change_hash(hash, -3 + cnt, i + 16)
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, cnt, i)
                        change_hash(hash, 3 - cnt, i + 16)
                    else
                        return score
                    end
                end

                if i > 16 and hash[i - 16] > 0 and hash[i - 16] < 3 and hash[i] + hash[i - 16] >= 3 then
                    local cnt = hash[i]
                    change_hash(hash, -cnt, i)
                    change_hash(hash, -3 + cnt, i - 16)
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, cnt, i)
                        change_hash(hash, 3 - cnt, i - 16)
                    else
                        return score
                    end
                end
            end
        end
        local flag = false
        for i = 1, 31 do
            if hash[i] > 0 then
                if hash[i] == 1 then
                    return -1
                end
                if hash[i] == 2 then
                    if not flag then
                        flag = true
                    else
                        return -1
                    end
                end
            end
        end
        return score
    end

     function get_hu_xi_min(hash,cardIndex)
        for i=1,31 do
            if hash[i] > 0 then
                if hash[i] == 3 and i ~= cardIndex then
                    change_hash(hash,-3,i)
                end
            end
        end

        for i = 1, 31 do
            if hash[i] > 0 then
                local tempV,tempMax = get_val(i)
                
                if get_val(i) == 2 and hash[i + 5] > 0 and hash[i + 5] <= 3 and hash[i + 8] > 0 and hash[i + 8] <= 3 then
                    change_hash(hash, -1, i, i + 5, i + 8)
                    if i>16 then
                        score = score + 6
                    else
                        score = score + 3
                    end
                    local re = get_hu_xi_min(hash,cardIndex)
                    if re == -1 then
                        change_hash(hash, 1, i, i + 5, i + 8)
                        if i>16 then
                            score = score - 6
                        else
                            score = score - 3
                        end
                    else
                        return score
                    end
                end
                
                if hash[i + 1] > 0 and hash[i + 1] <= 3 and hash[i + 2] > 0 and hash[i + 2] <= 3 then
                    -- print("第一个数为："..i)
                    change_hash(hash, -1, i, i + 1, i + 2)
                    if get_val(i) == 1 then
                        if tempMax then
                            score = score + 6
                        else
                            score = score + 3
                        end
                    end
                    
                    local re = get_hu_xi_min(hash,cardIndex)
                    if re == -1 then
                        change_hash(hash, 1, i, i + 1, i + 2)
                        if get_val(i) == 1 then
                            if tempMax then
                                score = score - 6
                            else
                                score = score - 3
                            end
                        end  
                    else
                        return score
                    end
                end
                
                if i < 16 and hash[i + 16] > 0 and hash[i + 16] <= 3 and hash[i] + hash[i + 16] >= 3 then
                    local cnt = hash[i]
                    change_hash(hash, -cnt, i)
                    change_hash(hash, -3 + cnt, i + 16)
                    local re = get_hu_xi_min(hash,cardIndex)
                    if re == -1 then
                        change_hash(hash, cnt, i)
                        change_hash(hash, 3 - cnt, i + 16)
                    else
                        return score
                    end
                end

                if i > 16 and hash[i - 16] > 0 and hash[i - 16] <= 3 and hash[i] + hash[i - 16] >= 3 then
                    local cnt = hash[i]
                    change_hash(hash, -cnt, i)
                    change_hash(hash, -3 + cnt, i - 16)
                    local re = get_hu_xi_min(hash,cardIndex)
                    if re == -1 then
                        change_hash(hash, cnt, i)
                        change_hash(hash, 3 - cnt, i - 16)
                    else
                        return score
                    end
                end
            end
        end
        local flag = false
        for i = 1, 31 do
            if hash[i] > 0 then
                if hash[i] == 1 then
                    return -1
                end
                if hash[i] == 2 then
                    if not flag then
                        flag = true
                    else
                        return -1
                    end
                end
            end
        end

        return score
    end

    local t = f(cardList)

    -- if t == nil or  0 >= #t then
    --     return nil
    -- end

    local t2 = f2(cardList)
    local tingArr = self:getAllTingCardArr(t,t2)
    return tingArr
end


function GameLogic:getAllTingCardArr( arr1,arr2 )
    local t = clone(arr1)
    local tempArr = {}

    for k,v in pairs(arr2) do
        local isHave = false
        for k1,v1 in pairs(arr1) do
            if v == v1 then
                isHave = true
                break
            end
        end
        if isHave == false then
            table.insert(tempArr,v)
        end
    end

    for k,v in pairs(tempArr) do
        table.insert(t,v)
    end
    return t or {}
end

--胡牌函数

function GameLogic:getHuPaiArr(cardList)
    local final_list = {}

    function get_val(card)
        local val = card
        if card > 16 then
            val = card - 16
        end
        return val
    end

    function change_hash(hash, val, ...)
        local pos_list = {...}
        for k, v in ipairs(pos_list) do
            hash[v] = hash[v] + val
        end

        if val < 0 then
            for k, v in ipairs(pos_list) do
                for i = 1, -val do
                    table.insert(final_list, v)
                end
            end
        else
            for k, v in ipairs(pos_list) do
                for i = 1, val do
                    table.remove(final_list)
                end
            end
        end
    end
    --[[
    三张 10
    2 7 10   5
    顺子  3
    吃 2
    ]]
    local score = 0

    function get_hu_xi(hash)
        for i=1,31 do
            if hash[i] > 0 then
                if hash[i] == 3 then
                    change_hash(hash,-3,i)
                    score = score + 10
                end
            end
        end

        for i = 1, 31 do
            if hash[i] > 0 then
                if hash[i] == 3 then
                    change_hash(hash, -3, i)
                    score = score + 10
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, 3, i)
                        score = score - 10
                    else
                        return score
                    end
                end
                
                if get_val(i) == 2 and hash[i + 5] > 0 and hash[i + 5] < 3 and hash[i + 8] > 0 and hash[i + 8] < 3 then
                    change_hash(hash, -1, i, i + 5, i + 8)
                    score = score + 5
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, 1, i, i + 5, i + 8)
                        score = score - 5
                    else
                        return score
                    end
                end
                
                if hash[i + 1] > 0 and hash[i + 1] < 3 and hash[i + 2] > 0 and hash[i + 2] < 3 then
                    change_hash(hash, -1, i, i + 1, i + 2)
                    score = score + 3
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, 1, i, i + 1, i + 2)
                        score = score - 3
                    else
                        return score
                    end
                end
                
                if i < 16 and hash[i + 16] > 0 and hash[i + 16] < 3 and hash[i] + hash[i + 16] >= 3 then
                    local cnt = hash[i]
                    change_hash(hash, -cnt, i)
                    change_hash(hash, -3 + cnt, i + 16)
                    score = score + 2
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, cnt, i)
                        change_hash(hash, 3 - cnt, i + 16)
                        score = score - 2
                    else
                        return score
                    end
                end

                if i > 16 and hash[i - 16] > 0 and hash[i - 16] < 3 and hash[i] + hash[i - 16] >= 3 then
                    local cnt = hash[i]
                    change_hash(hash, -cnt, i)
                    change_hash(hash, -3 + cnt, i - 16)
                    score = score + 2
                    local re = get_hu_xi(hash)
                    if re == -1 then
                        change_hash(hash, cnt, i)
                        change_hash(hash, 3 - cnt, i - 16)
                        score = score - 2
                    else
                        return score
                    end
                end
            end
        end

        local flag = false
        for i = 1, 31 do
            if hash[i] > 0 then
                if hash[i] == 2 then
                    if not flag then
                        flag = true
                    else
                        return -1
                    end
                else
                    return -1
                end
            end
        end

        return score
    end

    function f(card)
        local hash = {}
        for i = 1, 31 do
            hash[i] = 0
        end

        for k, v in ipairs(card) do
            hash[v] = hash[v] + 1
        end

        score = 0
        final_list = {}
        get_hu_xi(hash)

        if score ~= -1 then
            for k, v in pairs(hash) do
                if v > 0 then
                    for i = 1, v do
                        table.insert(final_list, k)
                    end
                end
            end
        end
    end

    local card = cardList
    f(card)
    return final_list
end



--胡牌函数end--


--吃牌函数end--

------------------------------------逻辑函数------------------------------------
--垅牌判断（四張）
function GameLogic:GetAcitonLongCard(cardIndex)
    if cardIndex == nil then
        return {}
    end
    local cardCount = 1
    local cbLongCardIndex = {}
    for k,v in pairs(cardIndex) do
        if v == 4 then
            cbLongCardIndex[cardCount] = k
            cardCount = cardCount + 1
        end
    end
    return cbLongCardIndex
end

--坎牌判断（三張）
function GameLogic:GetActionKanCard(cardIndex)
    if cardIndex == nil then
        return {}
    end
    local cardCount = 1
    local cbKanCardIndex = {}
    for k,v in pairs(cardIndex) do
        if v == 3 then
            cbKanCardIndex[cardCount] = k
            cardCount = cardCount + 1
        end
    end
    return cbKanCardIndex
end

--吃牌判断
function GameLogic:GetActionChiCard(cardIndex, curCard)
    -- ChiWeave
    -- ChiWeave.ChiKind    --吃牌类型
    -- ChiWeave.CenterCard --中心扑克
    -- ChiWeave.CardList   --吃牌字牌 {}
    -- ChiWeave.BiKind     --吃牌字牌 {}
    -- ChiWeave.BiCardList --吃牌字牌 {}{}
    local WeaveCard = {}
    local curIndex = self:SwitchToCardIndex(curCard)
    local curColor = math.floor(curCard / 16)
    local revIndex = (curIndex+10) % 20
    local tempCardIndex = clone(cardIndex)
    
    for k,v in pairs(tempCardIndex) do
        if v >= 3 and k~=curIndex then
            tempCardIndex[k] = 0
        elseif v == 3 and k == curIndex then
            print("====存在三张====",curIndex)
        end
    end

    --大小搭吃
    if tempCardIndex[curIndex]>=2 and tempCardIndex[revIndex]>=1 and tempCardIndex[revIndex]<3 then
        --设置结果
        local tempIndex = clone(tempCardIndex)
        tempIndex[curIndex]=tempIndex[curIndex]-2
        tempIndex[revIndex]=tempIndex[revIndex]-1
        local ChiWeave = {}
        if curColor == 0 then
            ChiWeave.ChiKind = CK_XXD
        else
            ChiWeave.ChiKind = CK_XDD
        end
        ChiWeave.CenterCard = curCard
        ChiWeave.CardList = {}
        ChiWeave.BiCount = 0
        ChiWeave.BiKind = {}
        ChiWeave.BiCardList = {}
        table.insert( ChiWeave.CardList, curCard )
        table.insert( ChiWeave.CardList, curCard )
        table.insert( ChiWeave.CardList, self:SwitchToCardData(revIndex) )
        --设置比牌
        if tempIndex[curIndex] > 0 then
            local biCardWeave = self:GetChiCardWeave(tempIndex, curCard)
            if #biCardWeave > 0 then
                tempIndex[curIndex]=tempIndex[curIndex]-1
            end
            ChiWeave.BiCount = #biCardWeave
            for i=1, #biCardWeave do
                table.insert( ChiWeave.BiKind, biCardWeave[i].WeaveKind )
                local biCard = {}
                for k, v in pairs(biCardWeave[i].CardList) do
                    table.insert( biCard, v )
                end
                table.insert( ChiWeave.BiCardList, biCard )
            end
        end
        if tempIndex[curIndex] == 0 then
            table.insert( WeaveCard, ChiWeave )
        end
    end
    --大小搭吃
    if tempCardIndex[curIndex]>=1 and tempCardIndex[revIndex]==2 then
        --删除扑克
        local tempIndex = clone(tempCardIndex)
        tempIndex[curIndex]=tempIndex[curIndex]-1
        tempIndex[revIndex]=0
        --设置结果
        local ChiWeave = {}
        if curColor == 0 then
            ChiWeave.ChiKind = CK_XDD
        else
            ChiWeave.ChiKind = CK_XXD
        end
        ChiWeave.CenterCard = curCard
        ChiWeave.CardList = {}
        ChiWeave.BiCount = 0
        ChiWeave.BiKind = {}
        ChiWeave.BiCardList = {}
        table.insert( ChiWeave.CardList, curCard )
        table.insert( ChiWeave.CardList, self:SwitchToCardData(revIndex) )
        table.insert( ChiWeave.CardList, self:SwitchToCardData(revIndex) )
        --设置比牌
        if tempIndex[curIndex] > 0 then
            local biCardWeave = self:GetChiCardWeave(tempIndex, curCard)
            if #biCardWeave > 0 then
                tempIndex[curIndex]=tempIndex[curIndex]-1
            end
            ChiWeave.BiCount = #biCardWeave
            for i=1, #biCardWeave do
                table.insert( ChiWeave.BiKind, biCardWeave[i].WeaveKind )
                local biCard = {}
                for k, v in pairs(biCardWeave[i].CardList) do
                    table.insert( biCard, v )
                end
                table.insert( ChiWeave.BiCardList, biCard )
            end
        end
        if tempIndex[curIndex] == 0 then
            table.insert( WeaveCard, ChiWeave )
        end
    end
    --小二七十
    if curCard==0x02 or curCard==0x07 or curCard==0x0A then
        --变量定义
        if tempCardIndex[1]>0 and tempCardIndex[6]>0 and tempCardIndex[9]>0 then
            --删除扑克
            local tempIndex = clone(tempCardIndex)
            tempIndex[1] = tempIndex[1]-1
            tempIndex[6] = tempIndex[6]-1
            tempIndex[9] = tempIndex[9]-1
            print("==删掉吃掉的牌==")
 
            --设置结果
            local ChiWeave = {}
            ChiWeave.CardList = {}
            ChiWeave.CenterCard = curCard
            ChiWeave.ChiKind = CK_EQS
            ChiWeave.BiCount = 0
            ChiWeave.BiKind = {}
            ChiWeave.BiCardList = {}
            table.insert( ChiWeave.CardList, 0x02 )
            table.insert( ChiWeave.CardList, 0x07 )
            table.insert( ChiWeave.CardList, 0x0A )
            --设置比牌
            if tempIndex[curIndex] > 0 then
                local biCardWeave = self:GetChiCardWeave(tempIndex, curCard)
                print("==128==获取能吃的牌==")
                -- dump(biCardWeave)
                if #biCardWeave > 0 then
                    tempIndex[curIndex]=tempIndex[curIndex]-1
                end
                ChiWeave.BiCount = #biCardWeave
                for i=1, #biCardWeave do
                    table.insert( ChiWeave.BiKind, biCardWeave[i].WeaveKind )
                    local biCard = {}
                    for k, v in pairs(biCardWeave[i].CardList) do
                        table.insert( biCard, v )
                    end
                    table.insert( ChiWeave.BiCardList, biCard )
                end

            end
            if tempIndex[curIndex] == 0 then
                table.insert( WeaveCard, ChiWeave )
            end
        end
        -- dump(WeaveCard)
    end
    --大二七十
    if curCard==0x12 or curCard==0x17 or curCard==0x1A then
        --变量定义
        if tempCardIndex[11]>0 and tempCardIndex[16]>0 and tempCardIndex[19]>0 then
            --删除扑克
            local tempIndex = clone(tempCardIndex)
            tempIndex[11] = tempIndex[11]-1
            tempIndex[16] = tempIndex[16]-1
            tempIndex[19] = tempIndex[19]-1
            --设置结果
            local ChiWeave = {}
            ChiWeave.CardList = {}
            ChiWeave.CenterCard = curCard
            ChiWeave.ChiKind = CK_EQS
            ChiWeave.BiCount = 0
            ChiWeave.BiKind = {}
            ChiWeave.BiCardList = {}
            table.insert( ChiWeave.CardList, 0x12 )
            table.insert( ChiWeave.CardList, 0x17 )
            table.insert( ChiWeave.CardList, 0x1A )
            --设置比牌
            if tempIndex[curIndex] > 0 then
                local biCardWeave = self:GetChiCardWeave(tempIndex, curCard)
                if #biCardWeave > 0 then
                    tempIndex[curIndex]=tempIndex[curIndex]-1
                end
                ChiWeave.BiCount = #biCardWeave
                for i=1, #biCardWeave do
                    table.insert( ChiWeave.BiKind, biCardWeave[i].WeaveKind )
                    local biCard = {}
                    for k, v in pairs(biCardWeave[i].CardList) do
                        table.insert( biCard, v )
                    end
                    table.insert( ChiWeave.BiCardList, biCard )
                end
            end
            if tempIndex[curIndex] == 0 then
                table.insert( WeaveCard, ChiWeave )
            end
        end
    end

    --顺子判断
    local firIndex = 0
    local excur={0,1,2}
    for i=1, 3 do
        local Index=curIndex%10
        if Index>=excur[i] and Index-excur[i]<=7 then
            --吃牌判断
            firIndex=curIndex-excur[i]
            if tempCardIndex[firIndex]>0 and tempCardIndex[firIndex+1]>0 and tempCardIndex[firIndex+2]>0 then
                --删除扑克
                local tempIndex = clone(tempCardIndex)
                tempIndex[firIndex] = tempIndex[firIndex]-1
                tempIndex[firIndex+1] = tempIndex[firIndex+1]-1
                tempIndex[firIndex+2] = tempIndex[firIndex+2]-1

                --设置结果
                local cbChiKind={CK_LEFT,CK_CENTER,CK_RIGHT}

                local ChiWeave = {}
                ChiWeave.CardList = {}
                ChiWeave.CenterCard = curCard
                ChiWeave.ChiKind = cbChiKind[i]
                ChiWeave.BiCount = 0
                ChiWeave.BiKind = {}
                ChiWeave.BiCardList = {}
                table.insert( ChiWeave.CardList, self:SwitchToCardData(firIndex) )
                table.insert( ChiWeave.CardList, self:SwitchToCardData(firIndex+1) )
                table.insert( ChiWeave.CardList, self:SwitchToCardData(firIndex+2) )
                --设置比牌
                if tempIndex[curIndex] > 0 then
                    local biCardWeave = self:GetChiCardWeave(tempIndex, curCard)
                    if #biCardWeave > 0 then
                        tempIndex[curIndex]=tempIndex[curIndex]-1
                    end
                    ChiWeave.BiCount = #biCardWeave
                    for j=1, #biCardWeave do
                        table.insert( ChiWeave.BiKind, biCardWeave[j].WeaveKind )
                        local biCard = {}
                        for k, v in pairs(biCardWeave[j].CardList) do
                            table.insert( biCard, v )
                        end
                        table.insert( ChiWeave.BiCardList, biCard )
                    end
                end
                if tempIndex[curIndex] == 0 then
                    table.insert( WeaveCard, ChiWeave )
                end
            end
        end
    end
    return WeaveCard
end
------------------------------------辅助函数------------------------------------
--有效判断
function GameLogic:IsValidCard(cardData)
    if cardData == nil or cardData < 0x01 or cardData > 0x1A then
        return false
    end
    local cbValue = cardData % 16
    local cardColor = math.floor(cardData / 16)
    if cbValue >= 1 and cbValue <= 10 and cardColor >=0 and cardColor <= 1 then
        return true
    else
        return false
    end
end

--扑克数目
function GameLogic:GetCardCount(cardIndex)
    local cbCount = 0
    for k,v in pairs(cardIndex) do
        cbCount = cbCount + v
    end
    return cbCount
end

--获取胡息
function GameLogic:GetWeaveHuXi(WeaveItem, viewId)
    local huxiCount = 0
    local cardColor = math.floor(WeaveItem.cbCardList[1] / 16)
    local cbValue = WeaveItem.cbCardList[1] % 16
    if WeaveItem.cbWeaveKind == AK_SAO_EX then
        print("垅")
        if cardColor == 1 then
            huxiCount = 12
        elseif cardColor == 0 then
            huxiCount = 9
        end
    elseif WeaveItem.cbWeaveKind == AK_DUO then
        print("AK_DUO")
            if cardColor == 1 then
                huxiCount = 9
            elseif cardColor == 0 then
                huxiCount = 6
            end
    elseif WeaveItem.cbWeaveKind == AK_SAO then
        print("AK_SAO")
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
        if viewId and anWei and viewId ~= 0 then
            huxiCount = 0
        end
    elseif WeaveItem.cbWeaveKind == AK_SAO_BAD then
        print("AK_SAO_BAD")
        if cardColor == 1 then
            huxiCount = 6
        elseif cardColor == 0 then
            huxiCount = 3
        end
    elseif WeaveItem.cbWeaveKind == AK_KAN then
        print("坎")
        if cardColor == 1 then
            huxiCount = 6
        elseif cardColor == 0 then
            huxiCount = 3
        end
    elseif WeaveItem.cbWeaveKind == AK_PENG then
        print("碰")
        if cardColor == 1 then
            huxiCount = 3
        elseif cardColor == 0 then
            huxiCount = 1
        end
        -- end
    elseif WeaveItem.cbWeaveKind == AK_CHI then
        print("吃")
        local cbValue = {}
        for i=1,3 do
            cbValue[i] = WeaveItem.cbCardList[i] % 16
        end
        local temp = 0
        for i=1,#cbValue-1 do
            for j=1,#cbValue-i do
                if cbValue[j] > cbValue[j+1] then
                    temp = cbValue[j+1]
                    cbValue[j+1] = cbValue[j]
                    cbValue[j] = temp
                end
            end
        end
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
        if cbValue[1]==1  and cbValue[2]==5 and cbValue[3]==10 and g_mainScene.bRoomTypeYWS == 1 then
            if cardColor == 1 then
                huxiCount = 6
            elseif cardColor == 0 then
                huxiCount = 3
            end
        end
    end
    -- print("huxiCount =",huxiCount)
    return huxiCount
end

--------------------------------------------------------------------------------
------------------------------------转换函数------------------------------------
--扑克转换
function GameLogic:SwitchToCardData(index)
    local cardData = math.floor(index/10)*16
    if cardData == 0 then
        cardData = index%10+1
    else
        cardData = cardData + index%10+1
    end

    return cardData
end

--扑克转换
function GameLogic:SwitchToCardIndex(cardData)
    local cardIndex = math.floor(cardData / 16)*10+(cardData % 16)-1
    return cardIndex
end

function GameLogic:SwitchIndexToCardID(cardIndex)
    if cardIndex >= 0 and cardIndex <= 9 then
        return tonumber(cardIndex+1) 
    else
        return tonumber(cardIndex+7) 
    end    -- body
end

--扑克转换
function GameLogic:SwitchToCardDataList(cardIndex)
    local bPosition = 0
    local cardData = {}
    for i=0,  19 do
        local cbIndex= (i%2)*10+math.floor(i/2)
        if cardIndex[cbIndex] ~= 0 then
            for j=1, cardIndex[cbIndex] do
                bPosition = bPosition + 1
                cardData[bPosition] = self:SwitchToCardData(cbIndex)
            end
        end
    end
    return cardData
end

--扑克转换
function GameLogic:SwitchToCardIndexList(cardData)
    local cardIndex = {}
    for i=0,19 do
        cardIndex[i] = 0
    end
    for k, v in pairs(cardData) do
        if v ~= 0 then
            local index = self:SwitchToCardIndex(v)
            cardIndex[index] = cardIndex[index] + 1
        end
    end
    return cardIndex
end
--------------------------------------------------------------------------------
------------------------------------内部函数------------------------------------
--分析扑克
function GameLogic:AnalyseCard(cardIndex)
end

--获取能吃的牌
function GameLogic:GetChiCardWeave(cardIndex, curCard)

    local WeaveCard = {}
    local curIndex = self:SwitchToCardIndex(curCard)
    local curColor = math.floor(curCard / 16)
    local revIndex = (curIndex+10) % 20
    
    for k,v in pairs(cardIndex) do
        if v >= 3 and k~=curIndex then
            cardIndex[k] = 0
        elseif v == 3 and k == curIndex then
            print("====存在三张====",curIndex)
        end
    end

    --大小搭吃
    if cardIndex[curIndex]==2 and cardIndex[revIndex]>=1 then
        local tempWeave = {}
        tempWeave.CardList = {}
        tempWeave.CenterCard = curCard
        if curColor == 0 then
            tempWeave.WeaveKind = CK_XXD
        else
            tempWeave.WeaveKind = CK_XDD
        end
        table.insert( tempWeave.CardList, curCard )
        table.insert( tempWeave.CardList, curCard )
        table.insert( tempWeave.CardList, self:SwitchToCardData(revIndex) )
        table.insert( WeaveCard, tempWeave )
    end
    if cardIndex[curIndex]>=1 and cardIndex[revIndex]==2 then
        local tempWeave = {}
        tempWeave.CardList = {}
        tempWeave.CenterCard = curCard
        if curColor == 0 then
            tempWeave.WeaveKind = CK_XDD
        else
            tempWeave.WeaveKind = CK_XXD
        end
        table.insert( tempWeave.CardList, curCard )
        table.insert( tempWeave.CardList, self:SwitchToCardData(revIndex) )
        table.insert( tempWeave.CardList, self:SwitchToCardData(revIndex) )
        table.insert( WeaveCard, tempWeave )
    end
    --小二七十
    if curCard==0x02 or curCard==0x07 or curCard==0x0A then
        --变量定义
        if cardIndex[1]>0 and cardIndex[6]>0 and cardIndex[9]>0 then
            --设置结果
            local tempWeave = {}
            tempWeave.CardList = {}
            tempWeave.CenterCard = curCard
            tempWeave.WeaveKind = CK_EQS
            table.insert( tempWeave.CardList, 0x02 )
            table.insert( tempWeave.CardList, 0x07 )
            table.insert( tempWeave.CardList, 0x0A )
            table.insert( WeaveCard, tempWeave )
        end
    end
    --大二七十
    if curCard==0x12 or curCard==0x17 or curCard==0x1A then
        --变量定义
        if cardIndex[11]>0 and cardIndex[16]>0 and cardIndex[19]>0 then
            --设置结果
            local tempWeave = {}
            tempWeave.CardList = {}
            tempWeave.CenterCard = curCard
            tempWeave.WeaveKind = CK_EQS
            table.insert( tempWeave.CardList, 0x12 )
            table.insert( tempWeave.CardList, 0x17 )
            table.insert( tempWeave.CardList, 0x1A )
            table.insert( WeaveCard, tempWeave )
        end
    end
    --顺子判断
    local firIndex = 0
    local excur={0,1,2}
    for i=1, 3 do
        local Index=curIndex%10
        if Index>=excur[i] and Index-excur[i]<=7 then
            --吃牌判断
            firIndex=curIndex-excur[i]
            if cardIndex[firIndex]>0 and cardIndex[firIndex+1]>0 and cardIndex[firIndex+2]>0 then
                --设置结果
                local cbChiKind={CK_LEFT,CK_CENTER,CK_RIGHT}

                local tempWeave = {}
                tempWeave.CardList = {}
                tempWeave.CenterCard = curCard
                tempWeave.WeaveKind = cbChiKind[i]
                table.insert( tempWeave.CardList, self:SwitchToCardData(firIndex) )
                table.insert( tempWeave.CardList, self:SwitchToCardData(firIndex+1) )
                table.insert( tempWeave.CardList, self:SwitchToCardData(firIndex+2) )
                table.insert( WeaveCard, tempWeave )
            end
        end
    end
    return WeaveCard
end

--提取吃牌
function GameLogic:TakeOutChiCard(cardIndex, curCard)
    --变量定义
    local cbResultCard = {}
    local cbResultType = CK_NULL
    local firIndex = 0
    local curIndex = self:SwitchToCardIndex(curCard)

     for k,v in pairs(cardIndex) do
        if v >= 3 and k~=curIndex then
            cardIndex[k] = 0
        elseif v == 3 and k == curIndex then
            print("====存在三张====",curIndex)
        end
    end

    --大小搭吃
    local revIndex = (curIndex+10) % 20
    if cardIndex[curIndex]==2 and cardIndex[revIndex]>=1 and cardIndex[revIndex]<3 then
        --删除扑克
        cardIndex[curIndex] = cardIndex[curIndex] - 2
        cardIndex[revIndex] = cardIndex[revIndex] - 1

        --设置结果
        table.insert( cbResultCard, curCard )
        table.insert( cbResultCard, curCard )
        table.insert( cbResultCard, self:SwitchToCardData(revIndex) )
        if 0 == math.floor(curCard / 16) then
            cbResultType = CK_XXD
        else
            cbResultType = CK_XDD
        end
        return cbResultType, cbResultCard
    end

    --大小搭吃
    if cardIndex[revIndex]==2 then
        --删除扑克
        cardIndex[curIndex] = cardIndex[curIndex] - 1
        cardIndex[revIndex] = cardIndex[revIndex] - 2

        --设置结果
        table.insert( cbResultCard, curCard )
        table.insert( cbResultCard, self:SwitchToCardData(revIndex) )
        table.insert( cbResultCard, self:SwitchToCardData(revIndex) )
        if 0 == math.floor(curCard / 16) then
            cbResultType = CK_XDD
        else
            cbResultType = CK_XXD
        end
        return cbResultType, cbResultCard
    end

    --二七十吃
    local bValue = curCard % 16
    if bValue==0x02 or bValue==0x07 or bValue==0x0A then
        --变量定义
        local cbExcursion = {1,6,9}
        local InceptIndex = 0
        if math.floor(curCard / 16) ~= 0 then
            InceptIndex = 10
        end

        --类型判断
        local i
        for i=1, 3 do
            local cbIndex=InceptIndex+cbExcursion[i]
            if cardIndex[cbIndex]==0 or cardIndex[cbIndex]==3 then
                break
            end
        end

        --成功判断
        if i==3 then
            --删除扑克
            cardIndex[InceptIndex+cbExcursion[0]] = cardIndex[InceptIndex+cbExcursion[0]] - 1
            cardIndex[InceptIndex+cbExcursion[1]] = cardIndex[InceptIndex+cbExcursion[1]] - 1
            cardIndex[InceptIndex+cbExcursion[2]] = cardIndex[InceptIndex+cbExcursion[2]] - 1

            --设置结果
            cbResultCard[0]=SwitchToCardData(InceptIndex+cbExcursion[0])
            cbResultCard[1]=SwitchToCardData(InceptIndex+cbExcursion[1])
            cbResultCard[2]=SwitchToCardData(InceptIndex+cbExcursion[2])

            return CK_EQS,cbResultCard
        end
    end

    --顺子判断
    local cbExcursion={0,1,2}
    for i=0, 2 do
        local cbValueIndex=curIndex%10
        if cbValueIndex>=cbExcursion[i] and cbValueIndex-cbExcursion[i]<=7 then
            --吃牌判断
            firIndex=curIndex-cbExcursion[i]
            if (cardIndex[firIndex]==0 or cardIndex[firIndex]~=3) and
                (cardIndex[firIndex+1]==0 or cardIndex[firIndex+1]~=3) and
                (cardIndex[firIndex+2]==0 or cardIndex[firIndex+2]~=3) then

                --删除扑克
                cardIndex[firIndex] = cardIndex[firIndex] - 1
                cardIndex[firIndex+1] = cardIndex[firIndex+1] - 1
                cardIndex[firIndex+2] = cardIndex[firIndex+2] - 1

                --设置结果
                cbResultCard[0]=self:SwitchToCardData(firIndex)
                cbResultCard[1]=self:SwitchToCardData(firIndex+1)
                cbResultCard[2]=self:SwitchToCardData(firIndex+2)

                local cbChiKind={CK_LEFT,CK_CENTER,CK_RIGHT}
                return cbChiKind[i]
            end
        end
    end

    return CK_NULL
end

--提取全部吃牌（已取出四张、三张）
function GameLogic:TakeOutAllChiCard( cardIndex )
    --变量定义
    local cbResultCard = {}
    --大小搭吃
    for i=0, 19 do
        local revIndex = (i+10) % 20
        if cardIndex[i]==2 and cardIndex[revIndex]==1 then
            --删除扑克
            cardIndex[i] = 0
            cardIndex[revIndex] = 0

            --设置结果
            local arrayTemp = {}
            table.insert( arrayTemp, self:SwitchToCardData(i) )
            table.insert( arrayTemp, self:SwitchToCardData(i) )
            table.insert( arrayTemp, self:SwitchToCardData(revIndex) )

            table.insert( cbResultCard, arrayTemp )

        elseif cardIndex[i]==2 then
            --删除扑克
            cardIndex[i] = 0

            --设置结果
            local arrayTemp = {}
            table.insert( arrayTemp, self:SwitchToCardData(i) )
            table.insert( arrayTemp, self:SwitchToCardData(i) )

            table.insert( cbResultCard, arrayTemp )
        end
    end

    --小字二七十
    if cardIndex[1]>0 and cardIndex[6]>0 and cardIndex[9]>0 then
        --删除扑克
        cardIndex[1] = cardIndex[1] - 1
        cardIndex[6] = cardIndex[6] - 1
        cardIndex[9] = cardIndex[9] - 1

        --设置结果
        local arrayTemp = {}
        table.insert( arrayTemp, self:SwitchToCardData(1) )
        table.insert( arrayTemp, self:SwitchToCardData(6) )
        table.insert( arrayTemp, self:SwitchToCardData(9) )

        table.insert( cbResultCard, arrayTemp )
    end

    --小字一五十
    if cardIndex[0]>0 and cardIndex[4]>0 and cardIndex[9]>0 and g_mainScene.bRoomTypeYWS == 1  then
        --删除扑克
        cardIndex[0] = cardIndex[0] - 1
        cardIndex[4] = cardIndex[4] - 1
        cardIndex[9] = cardIndex[9] - 1

        --设置结果
        local arrayTemp = {}
        table.insert( arrayTemp, self:SwitchToCardData(0) )
        table.insert( arrayTemp, self:SwitchToCardData(4) )
        table.insert( arrayTemp, self:SwitchToCardData(9) )

        table.insert( cbResultCard, arrayTemp )
    end

    --大字二七十
    if cardIndex[11]>0 and cardIndex[16]>0 and cardIndex[19]>0 then
        --删除扑克
        cardIndex[11] = cardIndex[11] - 1
        cardIndex[16] = cardIndex[16] - 1
        cardIndex[19] = cardIndex[19] - 1

        --设置结果
        local arrayTemp = {}
        table.insert( arrayTemp, self:SwitchToCardData(11) )
        table.insert( arrayTemp, self:SwitchToCardData(16) )
        table.insert( arrayTemp, self:SwitchToCardData(19) )

        table.insert( cbResultCard, arrayTemp )
    end
        --大字一五十
    if cardIndex[10]>0 and cardIndex[14]>0 and cardIndex[19]>0 and g_mainScene.bRoomTypeYWS == 1 then
        --删除扑克
        cardIndex[10] = cardIndex[10] - 1
        cardIndex[14] = cardIndex[14] - 1
        cardIndex[19] = cardIndex[19] - 1

        --设置结果
        local arrayTemp = {}
        table.insert( arrayTemp, self:SwitchToCardData(10) )
        table.insert( arrayTemp, self:SwitchToCardData(14) )
        table.insert( arrayTemp, self:SwitchToCardData(19) )

        table.insert( cbResultCard, arrayTemp )
    end
    --小字顺子
    for i=0, 7 do
        if cardIndex[i]>0 and cardIndex[i+1]>0 and cardIndex[i+2]>0 then
            --删除扑克
            cardIndex[i] = cardIndex[i] - 1
            cardIndex[i+1] = cardIndex[i+1] - 1
            cardIndex[i+2] = cardIndex[i+2] - 1

            --设置结果
            local arrayTemp = {}
            table.insert( arrayTemp, self:SwitchToCardData(i) )
            table.insert( arrayTemp, self:SwitchToCardData(i+1) )
            table.insert( arrayTemp, self:SwitchToCardData(i+2) )

            table.insert( cbResultCard, arrayTemp )
        end
    end

    --大字顺子
    for i=10, 17 do
        if cardIndex[i]>0 and cardIndex[i+1]>0 and cardIndex[i+2]>0 then
            --删除扑克
            cardIndex[i] = cardIndex[i] - 1
            cardIndex[i+1] = cardIndex[i+1] - 1
            cardIndex[i+2] = cardIndex[i+2] - 1

            --设置结果
            local arrayTemp = {}
            table.insert( arrayTemp, self:SwitchToCardData(i) )
            table.insert( arrayTemp, self:SwitchToCardData(i+1) )
            table.insert( arrayTemp, self:SwitchToCardData(i+2) )

            table.insert( cbResultCard, arrayTemp )
        end
    end

    return cbResultCard
end

return GameLogic
