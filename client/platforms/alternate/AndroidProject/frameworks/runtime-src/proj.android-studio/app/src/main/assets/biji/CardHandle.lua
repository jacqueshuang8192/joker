--
-- Created by IntelliJ IDEA.
-- User: baby1
-- Date: 2018/10/25
-- Time: 21:59
-- To change this template use File | Settings | File Templates.
--
--对子、三条、顺子、同花, 同花顺
CARD_OPTION_MAP =
{
    ONEPAIR = 1,
    STRAIGHT = 2,
    FLUSH = 3,
    STRAIGHTFLUSH = 4,
    THREESAME = 5,

}
local CardHandle = class("CardHandle")

function CardHandle:ctor()
    self.handleFunc = {
        [CARD_OPTION_MAP.ONEPAIR] 			= handler(self, self.onePair),
        [CARD_OPTION_MAP.STRAIGHT]			= handler(self, self.straight),
        [CARD_OPTION_MAP.FLUSH]				= handler(self, self.flush),
        [CARD_OPTION_MAP.STRAIGHTFLUSH] 	= handler(self, self.straightFlush),
        [CARD_OPTION_MAP.THREESAME]			= handler(self, self.threeSame),
    }

    self.resultFunc = {
        [CARD_OPTION_MAP.ONEPAIR] 			= handler(self, self.getOnePair),
        [CARD_OPTION_MAP.THREESAME]			= handler(self, self.getThreeSame),
        [CARD_OPTION_MAP.STRAIGHT]			= handler(self, self.getStraight),
        [CARD_OPTION_MAP.FLUSH]				= handler(self, self.getFlush),
        [CARD_OPTION_MAP.STRAIGHTFLUSH] 	= handler(self, self.getStraightFlush),
    }
end
function CardHandle:getResultFunc(optionType, ...)
    if self.resultFunc[optionType] then
        return self.resultFunc[optionType](...)
    end
end


function CardHandle:callFunc(optionType)
    if self.handleFunc[optionType] then
        return self.handleFunc[optionType]()
    end
end
--分析扑克
function CardHandle:analyseCardData(cardDataList, isTemp)

    -- cardDataList = {{color = 1, value = 2}, {color = 1, value = 3}, {color = 1, value = 4}, {color = 1, value = 5}, 
    --                 {color = 1, value = 6}, {color = 2, value = 2}, {color = 2, value = 3}, {color = 2, value = 5}, 
    --                 {color = 2, value = 14}}
    local info =
    {
        bOnePair = false,   --有一对
        bStraight = false,  --有顺子
        bFlush = false,     --有同花
        bStraightFlush = false,	--有同花顺
        bThreeSame = false,	--有三条
        cardCount = 0,
        onePairNum = 0,
        threeSameNum = 0,
        straightNum = 0,
        --flushNum = 0,
        --straightFlushNum = 0,

        --保存序号
        onePairTab = {},
        threeSameTab = {},
        straightTab = {},
        flushTab = {},
        straightFlushTab = {},
        oneCount = 0,
        -- twoCount = 0,
        -- threeCount = 0,
        -- fourCount = 0,

        oneFirstTab = {},
        straightTab = {},
        colorTab = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {}
        },

        --选择对应组合标记
        selectdState = {0, 0, 0, 0, 0, 0, 0, 0, 0}
    }
    local isTemp = isTemp or false
    if isTemp == false then
        if self.analyseData then
            self.analyseData = nil
        end
        self.analyseData = info
    end

    if cardDataList then
        local cardCount = #cardDataList
        if cardCount == 0 then
            return info
        end

        local sameCount = 1
        local cardTempValue = 0
        local firstCardIndex = 1	--纪录下标

        local straightIndex = 1
        local straightNum = 1 	--纪录顺子数
        local cardTempValue2 = 0
        local straightTempTab = {1}

        local item = cardDataList[1]
        local logicValue = item.value
        local cardColor = item.color

        local straightValue = item.value
        local bContinueStraight = true

        local analyseData = info

        local startTime = os.clock()

        analyseData.cardCount = cardCount

        table.insert(analyseData.colorTab[cardColor], firstCardIndex)

        --分析 对子和三张
        local pairFlag, pairResult, threeFlag, threeResult = self:isPairAndThreeTab(clone(cardDataList))
        if pairFlag then
            analyseData.bOnePair = true
            analyseData.onePairTab = pairResult
            analyseData.onePairNum = #pairResult
        end

        if threeFlag then
            analyseData.bThreeSame = true
            analyseData.threeSameTab = threeResult
            analyseData.threeSameNum = #threeResult
        end

        for i = 2, cardCount do
            item = cardDataList[i]
            cardTempValue = item.value
            cardColor = item.color
            -- if cardTempValue == logicValue then
            --     sameCount = sameCount + 1
            -- end
            -- --保存结果
            -- if (cardTempValue ~= logicValue) or (i == cardCount) then
            --     if sameCount == 1 then
            --         --1张(忽略)
            --     elseif sameCount == 2 then

            --         --2张
            --         analyseData.bOnePair = true
            --         table.insert(analyseData.onePairTab, {firstCardIndex, firstCardIndex+1})
            --         analyseData.onePairNum = analyseData.onePairNum + 1

            --     elseif sameCount == 3 then
            --         --3张
            --         analyseData.bOnePair = true
            --         table.insert(analyseData.onePairTab, {firstCardIndex, firstCardIndex+1})

            --         analyseData.bThreeSame = true
            --         table.insert(analyseData.threeSameTab, {firstCardIndex, firstCardIndex+1, firstCardIndex+2})
            --         analyseData.threeSameNum = analyseData.threeSameNum + 1

            --     else
            --         print("same card count error! count == "..sameCount)
            --     end
            -- end

            -- --设置变量
            -- if cardTempValue  ~= logicValue then
            --     if sameCount == 1 then
            --         if i ~= cardCount then
            --             analyseData.oneCount = analyseData.oneCount + 1
            --             analyseData.oneFirstTab[#(analyseData.oneFirstTab) + 1] = firstCardIndex
            --         else
            --             analyseData.oneCount = analyseData.oneCount + 1
            --             analyseData.oneFirstTab[#(analyseData.oneFirstTab) + 1] = firstCardIndex
            --             analyseData.oneCount = analyseData.oneCount + 1
            --             analyseData.oneFirstTab[#(analyseData.oneFirstTab) + 1] = i
            --         end
            --     else
            --         if i == cardCount then
            --             analyseData.oneCount = analyseData.oneCount + 1
            --             analyseData.oneFirstTab[#(analyseData.oneFirstTab) + 1] = i
            --         end
            --     end

            --     --重置数据
            --     sameCount = 1
            --     logicValue = cardTempValue
            --     firstCardIndex = i
            -- end

            --根据扑克花色分类
            table.insert(analyseData.colorTab[cardColor], i)
        end


        local endTime = os.clock()
        print("analyse pairs time:"..(endTime-startTime))


        --判断顺子

        for i = 2, cardCount do
            item = cardDataList[i]
            --if bContinueStraight == true then
            cardTempValue2 = item.value
            if straightValue == (cardTempValue2 - 1) then
                --构成顺子的牌数
                straightNum = straightNum + 1
                --纪录构成顺子牌数下标
                straightTempTab[#straightTempTab + 1] = i

                straightValue = cardTempValue2
            end

            if ((straightValue+1) < cardTempValue2) or (i==cardCount) then
                --print("straightNum : "..straightNum)
                if straightNum >= 3 then
                    --可以构成顺子
                    for j = 1, straightNum do
                        if (straightNum - j) >= 2 then
                            analyseData.bStraight = true
                            analyseData.straightTab[#(analyseData.straightTab) + 1] =
                            {
                                straightTempTab[j],
                                straightTempTab[j+1],
                                straightTempTab[j+2],
                            }
                            --从手牌中找到和顺子5张中其中一张数值相同的牌，组成另一种顺子
                            local compItem = nil
                            local straightItem = nil
                            local curIndex = 1
                            for k = j, j + 2 do
                                --从下一张牌开始查找
                                curIndex = straightTempTab[k]
                                for m = curIndex+1, cardCount do
                                    compItem = cardDataList[m]
                                    straightItem = cardDataList[curIndex]
                                    if compItem.value == straightItem.value and compItem.color ~= straightItem.color then
                                        --牌值相同的其他牌，再组合顺子
                                        local temp = {}
                                        for n = j, j + 2 do
                                            if n == k then
                                                temp[#temp+1] = m
                                            else
                                                temp[#temp+1] = straightTempTab[n]
                                            end
                                        end
                                        analyseData.straightTab[#(analyseData.straightTab) + 1] = temp
                                    else
                                        --print("no same value ! card index:"..curIndex..", com index:"..m)
                                        break
                                    end
                                end
                            end
                        else
                            print("break:straightNum"..straightNum..", j:"..j)
                            break
                        end
                    end
                end

                if (cardCount - i) < 2 then
                    --不用继续判断
                    --bContinueStraight = false
                    --print("bContinueStraight == false -> cur index : i=="..i)
                    break
                end

                --重置纪录下标
                straightTempTab = {i}
                straightValue = cardTempValue2
                straightNum = 1
            end
            --end
        end 	--end--> for i = 2, cardCount

        --判断是否有 A、2、3、4、5的顺子

        if cardDataList[1].value == 2 and cardDataList[cardCount].value == 14 then
            local frontA = 1
            local backA = 1
            straightTempTab = {1, cardCount}
            straightValue = cardDataList[1].value
            for i = (cardCount-1), 1, -1 do
                dump(cardDataList[i],"item = cardDataList[i]")
                item = cardDataList[i]
                if straightValue == (item.value-1) then
                    frontA = frontA + 1
                    straightTempTab[#straightTempTab+1] = i
                    straightValue = item.value
                end
            end

            --前后各固定存在一张牌（A和2）
            if (frontA + backA) >= 3 then
                for i=backA, 1, -1 do
                    for j=1, frontA, 1 do
                        if (i+j) == 3 then
                            local temp = {}
                            for k=1, i do
                                temp[#temp+1] = straightTempTab[k]
                            end

                            for k=1, j do
                                temp[#temp+1] = straightTempTab[k+backA]
                            end

                            analyseData.bStraight = true
                            analyseData.straightTab[#(analyseData.straightTab) + 1] = temp
                            --dump(temp, "第一个A、2、3、4、5的顺子")

                            --从手牌中找到和顺子3张中其中一张数值相同的牌，组成另一种顺子
                            local compItem = nil
                            local straightItem = nil
                            local curIndex = 1
                            for k=1, 3 do
                                curIndex = straightTempTab[k]
                                -- local s = (k==1 and 1) or -1
                                -- local count = (k==1 and cardCount) or 1
                                for m = 2, cardCount-1 do
                                    compItem = cardDataList[m]
                                    straightItem = cardDataList[curIndex]
                                    if compItem and straightItem and compItem.value == straightItem.value and compItem.color ~= straightItem.color then
                                        --牌值相同的其他牌，再组合顺子
                                        local temp = {}
                                        for n = 1, 3 do
                                            if n == k then
                                                temp[#temp+1] = m
                                            else
                                                temp[#temp+1] = straightTempTab[n]
                                            end
                                        end
                                        analyseData.straightTab[#(analyseData.straightTab) + 1] = temp
                                        --dump(temp, "换牌色A、2、3、4、5的顺子")
                                    else
                                        --print("no same value ! card index:"..curIndex..", com index:"..m)
                                        --break
                                    end
                                end
                            end

                            break
                        end
                    end
                end
            end
        end

        --判断同花顺 zwm
        local flag, indexTab = self:isStrainghtFlushTab(clone(cardDataList))
        if flag then
            analyseData.bStraightFlush = true
            analyseData.straightFlushTab = indexTab
        end

        --判断同花、同花顺
        local sameColorCount = 0

        for i = 1, 4 do
            local tab = analyseData.colorTab[i]
            sameColorCount = #tab
            if sameColorCount >= 3 then
                analyseData.bFlush = true
                for j = 1, sameColorCount do
                    if (sameColorCount - j) >= 2 then
                        local temp = {tab[j], tab[j+1], tab[j+2] }
                        table.insert(analyseData.flushTab, temp)

                        --判断是否同花顺
                        -- if cardDataList[tab[j]].value == cardDataList[tab[j+1]].value + 1 and cardDataList[tab[j]].value == cardDataList[tab[j+2]].value + 2 and
                        -- 	cardDataList[tab[j]].value == cardDataList[tab[j+3]].value + 3 and cardDataList[tab[j]].value == cardDataList[tab[j+4]].value + 4 then

                        -- 	analyseData.bStraightFlush = true
                        -- 	table.insert(analyseData.straightFlushTab, temp)

                        -- end

                        --判断是否同花顺
                       --  straightNum = 1
                       -- local index = j
                       --  straightValue = cardDataList[tab[index]].value
                       --  straightTempTab = {tab[index]}
                       --  while(index < sameColorCount) do
                       --      cardTempValue2 = cardDataList[tab[index+1]].value
                       --      if straightValue == cardTempValue2 + 1 then
                       --          dump(straightNum, "同花顺")
                       --          straightNum = straightNum + 1
                       --          straightTempTab[#straightTempTab + 1] = tab[index+1]
                       --          straightValue = cardTempValue2
                       --      end
                       --      if straightNum >= 3 then
                       --          analyseData.bStraightFlush = true
                       --          table.insert(analyseData.straightFlushTab, straightTempTab)
                       --          break
                       --      end

                       --      if straightValue > cardTempValue2 + 1 then
                       --          break
                       --      end
                       --      index = index + 1
                       --  end
                    else
                        break
                    end
                end

                -- --判断是否同花顺A2345
                -- if cardDataList[tab[sameColorCount]].value == 14 and cardDataList[tab[1]].value==2 then
                --     straightTempTab = {tab[1], tab[sameColorCount]}
                --     straightNum = 2
                --     straightValue = cardDataList[tab[1]].value
                --     local index = sameColorCount-1
                --     while(index > 1) do
                --         cardTempValue2 = cardDataList[tab[index]].value
                --         if straightValue == (cardTempValue2-1) then
                --             straightNum = straightNum + 1
                --             table.insert(straightTempTab, 2, tab[index])
                --             straightValue = cardTempValue2
                --         end

                --         if straightNum >= 3 then
                --             analyseData.bStraightFlush = true
                --             table.insert(analyseData.straightFlushTab, straightTempTab)
                --             break
                --         end

                --         if straightValue < cardTempValue2-1 then
                --             break
                --         end

                --         index = index - 1
                --     end
                -- end

            end
        end
        print("analyse straight time:"..(os.clock()-endTime))

    else
        print("analyseCardData error ! cardDataList is nil !")
    end

    return info
end

function combination(cards,cbntNumber)
    if cbntNumber > #cards then
        return nil
    end
    
    local assistArray = {}
    for i = 1,#cards do
        if i <= cbntNumber then
            assistArray[i] = 1
        else
            assistArray[i] = 0
        end
    end
    
    local cbntResult = {}
    
    local function getResult(astArray,srcArray,cbntResult)
        local oneOfCombination = {}
        for k,v in ipairs(astArray) do
            if v == 1 then
                table.insert(oneOfCombination,srcArray[k])
            end
        end
    
        table.insert(cbntResult,oneOfCombination)
    end
    
    getResult(assistArray,cards,cbntResult)
    
    local idx = 1
    while true do
        if assistArray[idx + 1] == nil then
            break
        end
    
        if assistArray[idx] == 1 and assistArray[idx + 1] == 0 then
            assistArray[idx] = 0
            assistArray[idx + 1] = 1
            for i = 1 , idx -1 do
                for j = i + 1, idx do
                    if assistArray[i] < assistArray[j] then
                        local mid = assistArray[i]
                        assistArray[i] = assistArray[j]
                        assistArray[j] = mid
                    end
                end
            end
            getResult(assistArray,cards,cbntResult)

            idx = 1
        else
            idx = idx + 1
        end    
    end

    return cbntResult
end

function CardHandle:isPairAndThreeTab(lst)
    local tmp = {}
    for i,v in ipairs(lst) do
        if tmp[v.value] == nil then
            local t = {}
            table.insert(t, i)
            tmp[v.value] = t
        else
            table.insert(tmp[v.value], i)
        end
    end

    local resultPair = {}
    local resultThree = {}
    for k,v in pairs(tmp) do
        if #v >= 2 then
            local tt = combination(v, 2)
            for k,v2 in pairs(tt) do
                table.insert(resultPair, v2)
            end
        end
        if #v >= 3 then
            local tt = combination(v, 3)
            for k,v2 in pairs(tt) do
                table.insert(resultThree, v2)
            end
        end
    end

    return #resultPair > 0, resultPair, #resultThree > 0, resultThree
end

function comp(item1, item2)
    if(item1.color == item2.color) then
        return item1.value < item2.value
    else
        return item1.color < item2.color
    end
end

function CardHandle:lookingForAllStrainghtFlush(baseArr, valueArr, color)
    if not valueArr or #valueArr < 3 then return {} end

    local resultTab = {}

    for i = 1, (#valueArr -2) do
        if (valueArr[i] - valueArr[i+1] == -1) and (valueArr[i+1] - valueArr[i+2] == -1) then
            local tmp = {}
            for j,v in ipairs(baseArr) do
                if v.color == color and (v.value == valueArr[i] or v.value == valueArr[i+1] or v.value == valueArr[i+2]) then
                    table.insert(tmp, j)
                end
            end
            table.insert(self.resultTable, tmp)
        end
    end

    if valueArr[1] == 2 and valueArr[2] == 3 and valueArr[#valueArr] == 14 then
        local tmp = {}
        for j,v in ipairs(baseArr) do
            if v.color == color and (v.value == valueArr[1] or v.value == valueArr[2] or v.value == valueArr[#valueArr]) then
                table.insert(tmp, j)
            end
        end
        table.insert(self.resultTable, tmp)
    end

    -- return resultTab
end

function CardHandle:isStrainghtFlushTab(arr)
    if not arr or #arr < 3 then return false end
    local tmpArr = clone(arr)
    table.sort(arr, comp)
    local color = 0
    local colorTab = {}
    self.resultTable = {}
    for k,v in pairs(arr) do
        if color == v.color then
            table.insert(colorTab, v.value)
            if k == #arr then
                self:lookingForAllStrainghtFlush(tmpArr, colorTab, color)
            end
        else
            self:lookingForAllStrainghtFlush(tmpArr, colorTab, color)
            color = v.color
            colorTab = {}
            table.insert(colorTab, v.value)
        end
    end

    return (#self.resultTable ~= 0), self.resultTable
end

function CardHandle:clearSelectedState()
    if 	self.analyseData then
        self.analyseData.selectdState = {0, 0, 0, 0, 0, 0, 0, 0, 0}
    end
end

--对子
function CardHandle:onePair()
    if self.analyseData then
        return self.analyseData.bOnePair, #(self.analyseData.onePairTab)
    end
    return false
end

function CardHandle:getOnePair()
    local analyseData = self.analyseData
    local result = {}
    if analyseData then
        local num = #(analyseData.onePairTab)
        if num > 0 then
            local state = analyseData.selectdState[CARD_OPTION_MAP.ONEPAIR]
            print("state -------------------", state)
            if state < num then
                result = clone(analyseData.onePairTab[state+1])
                analyseData.selectdState[CARD_OPTION_MAP.ONEPAIR] = state + 1
                -- if #(analyseData.oneFirstTab) >= 1 then
                --     result[#result + 1] = analyseData.oneFirstTab[#(analyseData.oneFirstTab)]
                -- else
                --     for i = analyseData.cardCount, 1, -1 do
                --         if i ~= result[1] then
                --             result[#result + 1] = i
                --             if #result == 3 then
                --                 break
                --             end
                --         end
                --     end
                -- end
            else
                analyseData.selectdState[CARD_OPTION_MAP.ONEPAIR] = 0
            end
        end
    end
    
    return result
end

--三条 3张相同点数的牌+2张单牌
function CardHandle:threeSame()
    if self.analyseData then
        return self.analyseData.bThreeSame, #(self.analyseData.threeSameTab)
    end
    return false
end

function CardHandle:getThreeSame()
    local analyseData = self.analyseData
    local result = {}
    if analyseData then
        local num = #(analyseData.threeSameTab)
        if num > 0 then
            local state = analyseData.selectdState[CARD_OPTION_MAP.THREESAME]
            if state < num then
                result = clone(analyseData.threeSameTab[state+1])
                analyseData.selectdState[CARD_OPTION_MAP.THREESAME] = state + 1
            else
                analyseData.selectdState[CARD_OPTION_MAP.THREESAME] = 0
            end
        end
    end

    return result
end
--顺子 5张花色不同但连续的牌
function CardHandle:straight()
    if self.analyseData then
        return self.analyseData.bStraight, #(self.analyseData.straightTab)
    end
    return false
end

function CardHandle:getStraight()
    local analyseData = self.analyseData
    local result = {}
    if analyseData then
        local num = #(analyseData.straightTab)
        if num > 0 then
            local state = analyseData.selectdState[CARD_OPTION_MAP.STRAIGHT]
            if state < num then
                result = clone(analyseData.straightTab[state+1])
                analyseData.selectdState[CARD_OPTION_MAP.STRAIGHT] = state + 1
            else
                analyseData.selectdState[CARD_OPTION_MAP.STRAIGHT] = 0
            end
        end
    end

    return result
end

--同花 5张相同花色不连续的牌
function CardHandle:flush()
    if self.analyseData then
        return self.analyseData.bFlush, #(self.analyseData.flushTab)
    end
    return false
end

function CardHandle:getFlush()
    local analyseData = self.analyseData
    local result = {}
    if analyseData then
        local num = #(analyseData.flushTab)
        if num > 0 then
            local state = analyseData.selectdState[CARD_OPTION_MAP.FLUSH]
            if state < num then
                result = clone(analyseData.flushTab[state+1])
                analyseData.selectdState[CARD_OPTION_MAP.FLUSH] = state + 1
            else
                analyseData.selectdState[CARD_OPTION_MAP.FLUSH] = 0
            end
        end
    end

    return result
end
--同花顺 5张同花色连续的牌
function CardHandle:straightFlush()
    if self.analyseData then
        return self.analyseData.bStraightFlush, #(self.analyseData.straightFlushTab)
    end
    return false
end

function CardHandle:getStraightFlush()
    local analyseData = self.analyseData
    local result = {}
    if analyseData then
        local num = #(analyseData.straightFlushTab)
        if num > 0 then
            local state = analyseData.selectdState[CARD_OPTION_MAP.STRAIGHTFLUSH]
            if state < num then
                result = clone(analyseData.straightFlushTab[state+1])
                analyseData.selectdState[CARD_OPTION_MAP.STRAIGHTFLUSH] = state + 1
            else
                analyseData.selectdState[CARD_OPTION_MAP.STRAIGHTFLUSH] = 0
            end
        end
    end

    return result
end

--分析扑克
function CardHandle:analyseCard(cardData, cardCount)
    local info =
    {
        bFlush = false,			--是否同花
        oneCount = 0,			--单张数目
        twoCount = 0,			--两张数目
        threeCount = 0,			--三张数目

        oneFirst = {},			--单牌位置
        twoFirst = {},			--对牌位置
        threeFirst = {},		--三条位置
    }

    local sameCount = 1
    local sameColorCount = 1
    local firstCardIndex = 1
    local logicValue = cardData[1].value
    local cardColor = cardData[1].color
    local cardTempValue = 0
    for i = 2, cardCount do
        cardTempValue = cardData[i].value
        if cardTempValue == logicValue then
            sameCount = sameCount + 1
        end

        --保存结果
        if cardTempValue ~= logicValue or i == cardCount then
            if sameCount == 1 then

            elseif sameCount == 2 then
                table.insert(info.twoFirst, firstCardIndex)
                info.twoCount = info.twoCount + 1
            elseif sameCount == 3 then
                table.insert(info.threeFirst, firstCardIndex)
                info.threeCount = info.threeCount + 1
            end
        end

        --设置变量
        if cardTempValue  ~= logicValue then
            if sameCount == 1 then
                if i ~= cardCount then
                    info.oneCount = info.oneCount + 1
                    table.insert(info.oneFirst, firstCardIndex)
                else
                    info.oneCount = info.oneCount + 1
                    table.insert(info.oneFirst, firstCardIndex)
                    info.oneCount = info.oneCount + 1
                    table.insert(info.oneFirst, i)
                end
            else
                if i == cardCount then
                    info.oneCount = info.oneCount + 1
                    table.insert(info.oneFirst, i)
                end
            end

            --重置数据
            sameCount = 1
            logicValue = cardTempValue
            firstCardIndex = i
        end

        --判断同花
        if cardData[i].color ~= cardColor then
            sameColorCount = 1
        else
            sameColorCount =  sameColorCount + 1
        end
    end

    if sameColorCount == cardCount then
        info.bFlush = true
    end

    return info
end

return CardHandle