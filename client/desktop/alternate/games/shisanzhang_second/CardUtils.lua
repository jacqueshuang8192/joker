local CardUtils = class("CardUtils")
local ShiSanZhangConfig = require(TpackageName..".config.ShiSanZhangConfig")
--g_guiNumber 全局变量软鬼功能
--设置牌的类型*/
CardUtils.TYPE = {
    WuLong = 1,
    DuiZi = 2,
    LiangDui = 3,
    SanTiao = 4,
    ShunZi = 5,
    TongHua = 6,
    HuLu = 7,
    TieZhi = 8,
    TongHuaShun = 9,
    WuTong = 10,
    --LiuTong = 28,
    SanTongHua= 11,  --三同花
    SanShunZi = 12,  --三顺子
    LiuDuiBan = 13,  --六对半
    WuDuiSanTiao = 14,  --五对三条
    SiTaoSanTiao = 15,  --四套三条
    ShuangGuaiChongSan = 16,  --双怪冲三
    QuanXiao = 17,  --全小
    QuanDa = 18,  --全大
    CouYiSe = 19,  --凑一色
    SanFenTianZia = 20,  --三分天下
    SanTongHuaShun = 21,  --三同花顺
    ShiErHuangZhu = 22,  --十二皇族
    YiTiaoLong = 23,  --一条龙
    QingLong = 24,  --至尊清龙
    TieZhiPai = 25,  --铁子牌
    TongHuaShunBaoDao = 26,  --同花顺报道
    WuTongZuan = 27,  --五同钻

}

if ShiSanZhangConfig:getVersion() then
    CardUtils.TYPE = {
        WuLong = 1,
        DuiZi = 2,
        LiangDui = 3,
        SanTiao = 4,
        ShunZi = 5,
        TongHua = 6,
        HuLu = 7,
        TieZhi = 8,
        TongHuaShun = 9,
        WuTong = 10,
        --LiuTong = 11,

        SanTongHua= 12,  --三同花
        SanShunZi = 13,  --三顺子
        LiuDuiBan = 14,  --六对半
        WuDuiSanTiao = 15,  --五对三条
        CouYiSe = 16,  --凑一色
        QuanXiao = 17,  --全小
        QuanDa = 18,  --全大
        ShiErHuangZhu = 19,  --十二皇族
        SiTaoSanTiao = 20,  --四套三条
        SanFenTianZia = 22,  --三分天下
        SanTongHuaShun = 23,  --三同花顺
        YiTiaoLong = 24,  --一条龙
        QingLong = 25,  --至尊清龙

        -- ShuangGuaiChongSan = 21,  --双怪冲三
        -- TieZhiPai = 25,  --铁子牌
        -- TongHuaShunBaoDao = 26,  --同花顺报道
        -- WuTongZuan = 27,  --五同钻

        LiuLiuDaShun = 29,--六六大顺：13张牌出现6张相同的牌
        SanHuanWuDi = 30,--三皇五帝:2个五同加一个三条
        QiXinLianZhu = 31,--七星连珠:13张牌出现7张相同的牌(不含10)
        BaXianGuoHai = 32,--八仙过海:13张牌出现8张相同的牌

    }

end


CardUtils.NAME = {
    [CardUtils.TYPE.SanTongHua]= "三同花", --"三同花"
    [CardUtils.TYPE.SanShunZi] = "三顺子", --"三顺子"
    [CardUtils.TYPE.LiuDuiBan] = "六对半", --"六对半"
    [CardUtils.TYPE.WuDuiSanTiao] = "五对三条", --"五对三条"
    [CardUtils.TYPE.SiTaoSanTiao] = "四套三条", --"四套三条"
    -- [CardUtils.TYPE.ShuangGuaiChongSan] = "双怪冲三", --"双怪冲三"
    [CardUtils.TYPE.QuanXiao] = "全小", --"全小"
    [CardUtils.TYPE.QuanDa] = "全大", --"全大"
    [CardUtils.TYPE.CouYiSe] = "凑一色", --"凑一色"
    [CardUtils.TYPE.SanFenTianZia] = "三分天下", --"三分天下"
    [CardUtils.TYPE.SanTongHuaShun] = "三同花顺", --"三同花顺"
    [CardUtils.TYPE.ShiErHuangZhu] = "十二皇族", --"十二皇族"
    [CardUtils.TYPE.YiTiaoLong] = "一条龙", --"一条龙"
    [CardUtils.TYPE.QingLong] = "至尊清龙", --"至尊清龙"
    -- [CardUtils.TYPE.TieZhiPai] = "铁子牌", --"铁子牌"
    -- [CardUtils.TYPE.TongHuaShunBaoDao] = "同花顺报道", --"同花顺报道"
    -- [CardUtils.TYPE.WuTongZuan] = "五同钻", --"五同钻"
    [CardUtils.TYPE.LiuLiuDaShun] = "六六大顺", 
    [CardUtils.TYPE.SanHuanWuDi] = "三皇五帝", 
    [CardUtils.TYPE.QiXinLianZhu] = "七星连珠", 
    [CardUtils.TYPE.BaXianGuoHai] = "八仙过海",
}

CardUtils.FILENAME = {
    [CardUtils.TYPE.WuLong] = "wulong",
    [CardUtils.TYPE.DuiZi] = "duizi",
    [CardUtils.TYPE.LiangDui] = "liangdui",
    [CardUtils.TYPE.SanTiao] = "santiao",
    [CardUtils.TYPE.ShunZi] = "shunzi",
    [CardUtils.TYPE.TongHua] = "tonghua",
    [CardUtils.TYPE.HuLu] = "hulu",
    [CardUtils.TYPE.TieZhi] = "tiezhi",
    [CardUtils.TYPE.TongHuaShun] = "tonghuashun",
    [CardUtils.TYPE.WuTong] = "wutong",
    --[CardUtils.TYPE.LiuTong] = "liutong",
    
    [CardUtils.TYPE.SanTongHua] = "santonghua", --"三同花"
    [CardUtils.TYPE.SanShunZi] = "sanshunzi", --"三顺子"
    [CardUtils.TYPE.LiuDuiBan] = "liuduiban", --"六对半"
    [CardUtils.TYPE.WuDuiSanTiao] = "wuduisantiao", --"五对三条"
    [CardUtils.TYPE.SiTaoSanTiao] = "sitaosantiao", --"四套三条"
    -- [CardUtils.TYPE.ShuangGuaiChongSan] = "shuangguaichongsan", --"双怪冲三"
    [CardUtils.TYPE.QuanXiao] = "quanxiao", --"全小"
    [CardUtils.TYPE.QuanDa] = "quanda", --"全大"
    [CardUtils.TYPE.CouYiSe] = "couyise", --"凑一色"
    [CardUtils.TYPE.SanFenTianZia] = "sanfentianxia", --"三分天下"
    [CardUtils.TYPE.SanTongHuaShun] = "santonghuashun", --"三同花顺"
    [CardUtils.TYPE.ShiErHuangZhu] = "shierhuangzhu", --"十二皇族"
    [CardUtils.TYPE.YiTiaoLong] = "yitiaolong", --"一条龙"
    [CardUtils.TYPE.QingLong] = "qinglong", --"至尊清龙"

    [CardUtils.TYPE.LiuLiuDaShun] = "liuliudashun",  --六六大顺
    [CardUtils.TYPE.SanHuanWuDi] = "sanhuanwudi",   --三皇五帝
    [CardUtils.TYPE.QiXinLianZhu] = "qixinlianzhu",  --七星连珠
    [CardUtils.TYPE.BaXianGuoHai] = "baxianguohai",  --八仙过海

    -- [CardUtils.TYPE.TieZhiPai] = "tiezhipai", --"铁子牌"
    -- [CardUtils.TYPE.TongHuaShunBaoDao] = "tonghuashunbaodao", --"同花顺报道"
    -- [CardUtils.TYPE.WuTongZuan] = "wutongzuan", --"五同钻"
    ["冲三"] = "congsan", --冲三
    ["中墩葫芦"] = "zhongdunhulu",  --中墩葫芦
}

function CardUtils:getTypeName(type)
    return CardUtils.NAME[type]
end

function CardUtils:getTypeFileName(type)
    return CardUtils.FILENAME[type]
end

local colorKey = "color"
local scoresKey = "scores" 
local changeColorKey = "changeColor" 
local numberKey = "number"
local guiValue = 20

-- 获得花色
function CardUtils:getVariety(card)
    local value = bit.band(card, 0xF0)
    return value
end

-- 获得牌值
function CardUtils:getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 14 then
        value = 20--小王 大王
    elseif value == 15 then
        value = 20-- 大王
    end
    return value
end


--转换牌
-- 0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x01,   --方块
-- 0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x11,   --樱花
-- 0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x21,   --红桃
-- 0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x31,   --黑桃
-- -- 0x4E 0x4f 大小鬼牌
function CardUtils:getClientCardByServerCard(cards)
    local VARIETY_DIAMOND = 0x00 -- 方块
    local VARIETY_CLUB    = 0x10 -- 梅花
    local VARIETY_HEART   = 0x20 -- 红桃
    local VARIETY_SPADE   = 0x30 -- 黑桃
    local gui_1   = 0x4E -- 小王黑桃
    local gui_2   = 0x4f -- 大王黑桃
    
    local result = {}
    for idx,card in ipairs(cards) do
        local tbl = {}
        tbl["serverCard"] = card
        tbl[numberKey] = CardUtils:getValue(card)
        local Variety = CardUtils:getVariety(card)
        if Variety == VARIETY_DIAMOND then -- 方块
            tbl[colorKey] = 1
        elseif Variety == VARIETY_CLUB then-- 梅花
            tbl[colorKey] = 2
        elseif Variety == VARIETY_HEART then-- 红桃
            tbl[colorKey] = 3
        elseif Variety == VARIETY_SPADE then-- 黑桃
            tbl[colorKey] = 4
        elseif card == gui_1 then--大小鬼牌
            tbl[colorKey] = 1
        elseif card == gui_2 then--大小鬼牌
            tbl[colorKey] = 2
        end

        tbl[scoresKey] = tbl[numberKey]
        tbl[changeColorKey] = tbl[colorKey]
		tbl.id = idx
        table.insert( result, tbl)
    end
   return result
end

--转换成16进制的
function CardUtils:getServerCardByClientCard(clientCards)
    local result = {}
    for idx, clientCard in ipairs(clientCards) do
        local score = clientCard[scoresKey] == 14 and 1 or clientCard[scoresKey]
        local value = clientCard[numberKey] + (clientCard[colorKey]-1) * 0x10
        local valueKin = score + (clientCard[changeColorKey]-1) * 0x10
        value = string.format("%#x", value)
        valueKin = string.format("%#x", valueKin)
        value = tonumber(value)
        valueKin = tonumber(valueKin)
        local tal = {}
        if clientCard[numberKey] == guiValue then
            if clientCard[colorKey] == 1 then
                tal.isKing = 0x4E--小王
            elseif clientCard[colorKey] == 2 then
                tal.isKing = 0x4f--大王
            end
        else
            tal.isKing = 0
        end
        tal.card = valueKin

        table.insert(result, tal)
    end
    return result
end

--根据点数统计牌
function CardUtils:getSamescoresCount(cards)
    local cardNumbers = {}
    for _, card in pairs(cards) do
        local scores = card[scoresKey]
        if cardNumbers[scores] then
            cardNumbers[scores] = cardNumbers[scores] + 1
        else
            cardNumbers[scores] = 1
        end
    end
    return cardNumbers
end

--找出最大的那张牌
function CardUtils:findMaxNumber(cards, cardsType)
    local getSamePointCount = self:getSamescoresCount(clone(cards))
    local index = 0
    local result = 0
    if (cardsType == self.TYPE.TieZhi) then
        local cardCont = 0 --一共有多少张相同点数的牌
        local ruangui = self:_getRuanGui()
        local allCard_is_one = true
        local cards_num = 0--一共有多少张牌
        for score, cont in pairs(getSamePointCount) do
            cardCont = cardCont + 1
            cards_num = cards_num + cont
            if cont >= 2 then
                allCard_is_one = false
            end
        end
        if (cardCont == 3 and allCard_is_one) or (cardCont == 2 and cards_num == 4) then
            local max = 0
            for score, cont in pairs(getSamePointCount) do
                local flag = self:_isRuanGui(nil, score)
                if flag then
                    if (max < score) then
                        -- max = score
                        local numbera = getSamePointCount[max] or 0
                        local numberb = getSamePointCount[score]
                        if numbera and numberb and numbera < numberb then
                            max = score
                        end
                    end
                end
            end
            if max ~= 0 then
                return max
            end
        end
    elseif (cardsType == self.TYPE.WuTong) then
        local max = 0
        for score, cont in pairs(getSamePointCount) do
            local flag = self:_isRuanGui(nil, score)
            if flag then
                if (max < score) then
                    local numbera = getSamePointCount[max] or 0
                    local numberb = getSamePointCount[score]
                    if numbera and numberb and numbera < numberb then
                        max = score
                    end
                end
            end
        end
        if max ~= 0 then
            return max
        end
    end
    for value, number in pairs(getSamePointCount) do
        if (index < number) then
            index = number
            result = tonumber(value)
        end

        if (index == number and result < tonumber(value)) then
            result = tonumber(value)
        end
    end

    return result
end

--max 排序从到少 大到小*/
--min 排序从少到多 小到大*/
--sortMin 按点数小到大*/
--sortMax 按点数大到小*/
function CardUtils:_typeServeCardsSortByScores(serverCards, type)
    if not type then type = "max" end 
    local cards =  self:getClientCardByServerCard(serverCards)
    local scoresHelper = self:getSamescoresCount(cards)
    table.sort(
        serverCards,
        function(card1, card2)
            card1 = self:getClientCardByServerCard({card1})[1]
            card2 = self:getClientCardByServerCard({card2})[1]

            local numberOfCard1 = scoresHelper[card1[scoresKey]]

            local numberOfCard2 = scoresHelper[card2[scoresKey]]

            if (numberOfCard2 ~= numberOfCard1) then
                if type == "max" then
                    return numberOfCard2 < numberOfCard1
                elseif type == "min" then
                    return numberOfCard2 > numberOfCard1
                end
            end

            local scores1 = card1[scoresKey]
            local scores2 = card2[scoresKey]

            if scores1 == 1 then
                scores1 = 14
            end
            if scores2 == 1 then
                scores2 = 14
            end

            scores1 = scores1 + card1[colorKey] / 10

            scores2 = scores2 + card2[colorKey] / 10

            if type == "max" then
                return scores2 < scores1
            elseif type == "sortMin" then
                return scores2 > scores1
            elseif type == "sortMax" then
                return scores2 < scores1
            end
            return scores2 < scores1
        end
    )
end

--排序从多到少 大到小*/
-- function CardUtils:_typeCardsSortByScores(cards, maxScore)
--     local cardsGui = self:_findGuiCards(cards) or {}
--     cards = self:_delCards(cardsGui, cards)
--     for i, card in ipairs(cards) do
--         local number = card[scoresKey]
--         -- if (number >= guiValue) then
--         --     local cardGui = table.remove(cards, i)
--         --     table.insert(cardsGui, cardGui)
--         -- end
--         if (card[scoresKey] == 1) then
--             card[scoresKey] = 14
--         end
--     end

--     local scoresHelper = self:getSamescoresCount(cards)
--     -- local maxScoretal = {[maxScore] = maxScore}
--     table.sort(
--         cards,
--         function(card1, card2)
            
--             local scores1 = card1[scoresKey]
--             local scores2 = card2[scoresKey]
           
--             if maxScore then
--                 if scores1 == maxScore then
--                     local flag = scores1 == maxScore
--                     -- return flag
--                 end
--                 if scores2 == maxScore then
--                     local flag = scores1 == maxScore
--                     -- return flag
--                 end
--             end

--             local numberOfCard1 = scoresHelper[scores1]
--             local numberOfCard2 = scoresHelper[scores2]

--             if (numberOfCard2 ~= numberOfCard1) then
--                 return numberOfCard2 < numberOfCard1
--             end

--             if scores1 == 1 then
--                 scores1 = 14
--             end
--             if scores2 == 1 then
--                 scores2 = 14
--             end

--             scores1 = scores1 + card1[colorKey] / 10
--             scores2 = scores2 + card2[colorKey] / 10

--             return scores2 < scores1
--         end
--     )

--     self:_convert_1To14(cards)
--     cards = tableConcat(cardsGui, cards)
--     return cards
-- end

--排序从多到少 大到小*/
function CardUtils:_typeCardsSortByScores(cards, maxScore)
    local cardsGui = self:_findGuiCards(cards) or {}
    cards = self:_delCards(cardsGui, cards)
    for i, card in ipairs(cards) do
        local number = card[scoresKey]
        -- if (number >= guiValue) then
        --     local cardGui = table.remove(cards, i)
        --     table.insert(cardsGui, cardGui)
        -- end
        if (card[scoresKey] == 1) then
            card[scoresKey] = 14
        end
    end
    local scoresHelper = self:getSamescoresCount(cards)

    local sfun = function(card1, card2)
        local scores1 = card1[scoresKey]
        local scores2 = card2[scoresKey]
       
        if maxScore then
            if scores1 == maxScore then
                local flag = scores1 == maxScore
                return flag
            end
            if scores2 == maxScore then
                local flag = scores1 == maxScore
                return flag
            end
        end

        local numberOfCard1 = scoresHelper[scores1]
        local numberOfCard2 = scoresHelper[scores2]

        if (numberOfCard2 ~= numberOfCard1) then
            return numberOfCard2 < numberOfCard1
        end

        if scores1 == 1 then
            scores1 = 14
        end
        if scores2 == 1 then
            scores2 = 14
        end

        scores1 = scores1 + card1[colorKey] / 10
        scores2 = scores2 + card2[colorKey] / 10

        return scores2 < scores1
    end

    local cardCount = #cards
    for i=1, cardCount do
        for j=1,cardCount - i do
            local flag = sfun(cards[j+1], cards[j])
            if flag then
                local temp = cards[j+1]
                cards[j+1] = cards[j]
                cards[j] = temp
            end
        end
    end
    
    self:_convert_1To14(cards)
    cards = tableConcat(cardsGui, cards)
    return cards
    
end


--从所有牌中删除手牌
function CardUtils:_delCards(cardsAyys, cards)
    cardsAyys = cardsAyys or {}
    if (#cardsAyys == 0) then
        return cards
    end
    
    local cards = clone(cards)

    local cardsAyy = clone(cardsAyys)

    for _, card1 in ipairs(cardsAyy) do
        local id = card1.id

        for j, card in ipairs(cards) do
            local cardsId = card.id
            if (cardsId == id) then
                table.remove(cards, j)
                break
            end
        end
    end

    return cards or {}
end

--A把一个1转换成14*/
function CardUtils:_convert_1To14(cardModes, isOneBreak)
    cardModes = clone(cardModes)
    for _, card in ipairs(cardModes) do
        if (card[scoresKey] == 1) then
            card[scoresKey] = 14
            if (isOneBreak) then
                break
            end
        end
    end
    return cardModes
end

--A把一个14转换成1*/
function CardUtils:_convert_14To1(cardModes, isOneBreak)
    cardModes = clone(cardModes)
    for _, card in ipairs(cardModes) do
        if (card[scoresKey] == 14) then
            card[scoresKey] = 1
            if (isOneBreak) then
                break
            end
        end
    end
    return cardModes
end
--找出鬼牌*/
function CardUtils:_findGuiCards(cards)
    if (#cards <= 0) then
        return {}
    end
    local tables = {}
    for i, card in ipairs(cards) do
        if card[numberKey] >= guiValue then
            table.insert(tables, card)
        end
    end
    return tables
end

--根据点数寻找牌索引*/
function CardUtils:_findScoresLength(cards, length)
    if (#cards < length) and length > 0 then
        return {}
    end
    local obj, result = {}, {}

    for i, card in ipairs(cards) do
        local scores = card[scoresKey]
        if not obj[scores] then
            obj[scores] = {}
        end
        table.insert(obj[scores], i)
    end

    for _, prop in pairs(obj) do
        -- while (#prop > length and length ~= 0) do --有多的分割多个数组
        --     local splices = table.splice(prop, 1, length)
        --     if (#splices >= length) then
        --         table.insert(result, splices)
        --     end
        -- end
        -- if (#prop >= length) then
        --     table.insert(result, prop)
        -- end
        if #prop >= length then
            for start = 1, #prop - length + 1 do
                local subCards = table.slice(prop, start, length)
                if (#subCards >= length) then
                    table.insert(result, subCards)
                end
            end
        end
    end

    return result
end

--根据花色寻找牌索引*/
function CardUtils:_findSuitLength(cards, length)
    if not length then
        length = 1
    end

    local obj, result = {}, {}

    for i, card in ipairs(cards) do
        local color = card[colorKey]
        if obj[color] then
            table.insert(obj[color], i)
        else
            obj[color] = {}
            table.insert(obj[color], i)
        end
    end

    for i, prop in pairs(obj) do
        if (#prop >= length) then
            table.insert(result, prop)
        end
    end
    return result
end

--寻找牌复数牌*/
function CardUtils:_findFuShuCard(cards, length)
    if length < 1 then
        return {}
    end
    local indexs = self:_findScoresLength(cards, length)

    if (#indexs >= 1) then
        local result = self:_findCards(indexs, cards)
        return result or {}
    else
        return {}
    end
end

--根据索引寻找牌*/
function CardUtils:_findCards(indexs, cards)
    local cardsAyy = {}
    for _, indexArr in ipairs(indexs) do
        local cardArr = {}
        for _, index in ipairs(indexArr) do
            if (cards[index]) then
                table.insert(cardArr, cards[index])
            end
        end
        table.insert(cardsAyy, cardArr)
    end

    return cardsAyy
end

--牌去重*/
function CardUtils:GetRepeatFwxmmc(ary1)
    local newCard, ids = {}, {}
    for _, v in ipairs(ary1) do
        local id = v.id
        if not ids[id] then
            ids[id] = id
            table.insert(newCard, v)
        end
    end
    return newCard or {}
end

--判断是否有重复的根据ID
function CardUtils:_isTableRepeatById(cardsAyys, cards)
    cardsAyys = clone(cardsAyys)
    cards = clone(cards)

    table.sort(cards,function(a1, a2)
        return a1.id < a2.id
    end)
    local idsa = ""
    for _, card in ipairs(cards) do
        idsa = idsa .. card.id
    end
    for _, cardsa in ipairs(cardsAyys) do
        table.sort(cardsa,function(a1, a2)
            return a1.id < a2.id
        end)

        local idsb = ""
        for _, cardb in ipairs(cardsa) do
            idsb = idsb .. cardb.id
        end
        if idsb == idsa then
            return true
        end
    end
    return false
end

--排序
function CardUtils:_cardsResultSort(result, cardsType)
    local idsfun = function ( cards )
        local ids = ""
        for _, card in ipairs(cards) do
            ids = ids..card.id
        end
        return ids
    end

    local idsArr = {}
    for i,cards in ipairs(result) do
        local ids = idsfun(cards)
        local scorea = self:scoreOfCards(cards, cardsType)
        idsArr[ids] = scorea
    end


    table.sort( result, function(a,b)
        local idsa = idsfun(a)
        local idsb = idsfun(b)
        local scorea = idsArr[idsa]
        local scoreb = idsArr[idsb]
        local guiCardsa = self:_findGuiCards(a) or {}
        local guiCardsb = self:_findGuiCards(b) or {}
        if #guiCardsa > 0 and #guiCardsb > 0 then
            if #guiCardsa == #guiCardsb then
                return scorea > scoreb
            else
                return #guiCardsa < #guiCardsb
            end
        elseif #guiCardsa > 0 then
            return false
        elseif #guiCardsb > 0 then
            return true
        end
        return scorea > scoreb
    end )
end

function CardUtils:_isA(cards)
    for _, card in ipairs(cards) do
        if card[numberKey] == 1 then
            return true
        end
    end
    return false
end

--找出同花顺*/
function CardUtils:_findTongHuaShun(cardModes, length, isSort)
    if (not length) then
        length = 5
    end
    if (#cardModes < length) then
        return {}
    end
    cardModes = clone(cardModes)

    local guiCards = self:_findGuiCards(cardModes) or {}
    local cards = self:_delCards(guiCards, cardModes)
    local idxArrs = self:_findSuitLength(cards) or {}
    cards = self:_convert_1To14(cards)
    local colorCardsArr = {} --总共有几种花色 [5,3,0....]
    local repeatCards = {} --重复的牌

    for _, idxArr in ipairs(idxArrs) do
        if #idxArr >= (5 - #guiCards) then
            local cardsi = {}
            local numbers = {}

            for _, index in ipairs(idxArr) do
                local card = cards[index]
                if (table.indexof(numbers, card[numberKey]) == false) then
                    table.insert(numbers, card[numberKey])
                    table.insert(cardsi, card)
                else
                    local key = card[numberKey]..card[colorKey]
                    if not repeatCards[key] then
                        repeatCards[key] = {}
                    end
                    table.insert(repeatCards[key], card)
                end
            end
            table.sort(
                cardsi,
                function(a1, a2)
                    return a1[scoresKey] < a2[scoresKey]
                end
            )
            table.insert(colorCardsArr, cardsi)
        end
    end

    local result = {}
    local func = function(result, isA)
        for _, CardsArr in ipairs(colorCardsArr) do

            if isA then
                for _, ca in ipairs(CardsArr) do
                    ca[scoresKey] = ca[numberKey]
                end
                table.sort(CardsArr,function(a1, a2)
                    return a1[scoresKey] < a2[scoresKey]
                end)
            end
            for t = 0, #guiCards do
                local num = length - t
                for start = 1, #CardsArr - num + 1 do
                    local subCards = table.slice(CardsArr, start, num)
                    local bool = self:_isShunZi(subCards, 5)
                    if (isA and CardUtils:_isA(cardModes) and bool ) or (not isA and bool ) then
                        subCards = tableConcat(subCards, table.slice(guiCards, 1, t))
                        if not self:_isTableRepeatById(result, subCards) and #subCards == length then
                            table.insert(result, subCards)
                            self:_handleRepeatCards(result, repeatCards, subCards)

                        end
                    end
                end
            end
        end
        return result
    end
    func(result)
    if CardUtils:_isA(cardModes) then
        func(result, true)
    end
    if isSort then
        self:_cardsResultSort(result, self.TYPE.TongHuaShun)
    end

    return result
end

--     --找出顺子*/
function CardUtils:_findShunZi(cardModes, length, isSort)
    if (not length) then
        length = 5
    end
    if (#cardModes < length) then
        return {}
    end
    cardModes = clone(cardModes)

    local guiCards = self:_findGuiCards(cardModes)
    local cards = self:_delCards(guiCards, cardModes)
    local newCards, numbers = {}, {}
    cards = self:_convert_1To14(cards)
    local repeatCards = {} --重复的牌

    -- 先根据点数去重
    for _, card in ipairs(cards) do
        if (table.indexof(numbers, card[numberKey]) == false) then
            table.insert(numbers, card[numberKey])
            table.insert(newCards, card)
        else
            local key = card[numberKey]
            if not repeatCards[key] then
                repeatCards[key] = {}
            end
            table.insert(repeatCards[key], card)
        end
    end

    table.sort(
        newCards,
        function(n1, n2)
            return n1[scoresKey] < n2[scoresKey]
        end
    )

    local result = {}
    local func = function(result, isA)
        if isA then
            for _, ca in ipairs(newCards) do
                ca[scoresKey] = ca[numberKey]
            end
            table.sort(newCards,function(a1, a2)
                return a1[scoresKey] < a2[scoresKey]
            end)
        end
        
        for t = 0, #guiCards do
            local num = length - t
            for start = 1, #newCards - num + 1 do
                local subCards = table.slice(newCards, start, num)
                local bool = self:_isShunZi(subCards, 5)
                if (isA and CardUtils:_isA(cardModes) and bool ) or (not isA and bool ) then
                    local indexs = {}
                    subCards = tableConcat(subCards, table.slice(guiCards, 0, t))
                    if not self:_isTableRepeatById(result, subCards) and #subCards == length then
                        table.insert(result, subCards)
                        self:_handleRepeatCards(result, repeatCards, subCards, self.TYPE.ShunZi)
                    end
                end
            end
        end
    end
    
    func(result)
    if CardUtils:_isA(cardModes) then
        func(result, true)
    end

    if isSort then
        self:_cardsResultSort(result, self.TYPE.ShunZi)
    end
    return result
end

function CardUtils:_isShunZi(cards, length, log)
    if not (cards and #cards) then
        return false
    end
    local isShunzi = true

    length = length - 1

    local numbers = {}
    for _, v in ipairs(cards) do
        if (table.indexof(numbers, v[numberKey])) then --有重复 不是顺子
            return false
        end
        table.insert(numbers, v[numberKey])
    end
   
    cards = self:_convert_14To1(cards)
    for _, carda in ipairs(cards) do
        local scoresa = carda[scoresKey]
        for _, cardb in ipairs(cards) do
            local scoresb = cardb[scoresKey]

            if (scoresa > scoresb) then
                if ((scoresa - scoresb) > length) then
                    isShunzi = false
                    break
                end
            else
                if ((scoresb - scoresa) > length) then
                    isShunzi = false
                    break
                end
            end

        end

        if isShunzi == false then
            isShunzi = false
            break
        end
    end

    if (isShunzi == false) then
        isShunzi = true
        cards = self:_convert_1To14(cards)
        for _, carda in ipairs(cards) do
            local scoresa = carda[scoresKey]
            for _, cardb in ipairs(cards) do
                local scoresb = cardb[scoresKey]
    
                if (scoresa > scoresb) then
                    if ((scoresa - scoresb) > length) then
                        isShunzi = false
                        break
                    end
                else
                    if ((scoresb - scoresa) > length) then
                        isShunzi = false
                        break
                    end
                end
    
            end

            if isShunzi == false then
                isShunzi = false
                break
            end
        end
    end
    
    return isShunzi
end

--找出同花*/
function CardUtils:_findTongHua(cardModes, length, isSort)
    if (not length) then
        length = 5
    end
    if (#cardModes < length) then
        return {}
    end
    cardModes = clone(cardModes)

    local guiCards = self:_findGuiCards(cardModes) or {}
    local cards = self:_delCards(guiCards, cardModes)
    local idxArrs = self:_findSuitLength(cards) or {}

    local colorCardsArr = {} --总共有几种花色 [5,3,0....]
    local repeatCards = {} --重复的牌
    for _, idxArr in ipairs(idxArrs) do
        if #idxArr >= (5 - #guiCards) then
            local cardsi = {}
            local numbers = {}
            for _, index in ipairs(idxArr) do
                local card = cards[index]
                table.insert(cardsi, card)
            end
            table.sort(
                cardsi,
                function(a1, a2)
                    return a1[scoresKey] < a2[scoresKey]
                end
            )
            table.insert(colorCardsArr, cardsi)
        end
    end

    local result = {}
    for _, CardsArr in ipairs(colorCardsArr) do
        for t = 0, #guiCards do
            local num = length - t
            for start = 1, #CardsArr - num + 1 do
                local subCards = table.slice(CardsArr, start, num)
                subCards = tableConcat(subCards, table.slice(guiCards, 1, t))
                if #subCards == length then
                    table.insert(result, subCards)
                    self:_handleRepeatCards(result, repeatCards, subCards)
                end
            end
        end
    end
    if isSort then
        self:_cardsResultSort(result, self.TYPE.TongHua)
    end
    return result
end

--处理有重复的牌
function CardUtils:_handleRepeatCards(result, repeatCards, cards, type)
    for idx,card in ipairs(cards) do
        local key = card[numberKey]..card[colorKey]
        if type == self.TYPE.ShunZi then
            key = card[numberKey]
        end
        local reCards = repeatCards[key]
        if reCards and #(reCards) > 0 then
            for _,reCard in ipairs(reCards) do
                local rsubCards = clone(cards)
                rsubCards[idx] = reCard
                table.insert(result, rsubCards)
            end
        end
    end
end

--  寻找牌对子，五同..复数的
function CardUtils:_findResult(cards, length, isSort)
    if (not length) then
        length = 5
    end
    if (#cards < length) then
        return {}
    end
    cards = clone(cards)
    local result = {}
    local cardsGui = self:_findGuiCards(cards) or {}

    cards = self:_delCards(cardsGui, cards)
 
    for t = 0, #cardsGui do
        local num = length - t
        local re = self:_findFuShuCard(cards, num)
        for _, arr in ipairs(re) do
            arr = tableConcat(arr, table.slice(cardsGui, 1, t))
            if #arr == length then
                table.insert(result, arr)
            end
        end
    end
    if #cardsGui >= length then
        local re = self:_findFuShuCard(cardsGui, length)
        for _, arr in ipairs(re) do
            if #arr == length then
                table.insert(result, arr)
            end
        end
    end
    if isSort then
        self:_cardsResultSort(result, self.TYPE.WuTong)
    end
    return result
end

--判断是否是234567牌的六同
function CardUtils:_findLiuTong(oriCards, isSort)
    local length = 5
    local resultWuTong = self:_findResult(oriCards, length, isSort)
    local result = {}

    -- for _,cards in ipairs(resultWuTong) do
    --     local isLiuTong = self:_isRuanGui(cards)
    --     if isLiuTong then
    --         table.insert(result, cards)
    --     end 
    -- end
    return result
end

function CardUtils:_handRepeatResult( result_1, retult_2 )
    local result = result_1
    local ids = {}
    for i,cards in ipairs(result_1) do
        local idsArr = {}
        for _, card in ipairs(cards) do
            table.insert(idsArr, card.id)
        end
        table.sort(idsArr,function(a1, a2)
            return a1 < a2
        end)
        local key = table.concat( idsArr )
        ids[key] = idsArr
    end

    for i,cards in ipairs(retult_2) do
        local idsArr = {}
        for _, card in ipairs(cards) do
            table.insert(idsArr, card.id)
        end
        table.sort(idsArr,function(a1, a2)
            return a1 < a2
        end)
        local key = table.concat( idsArr )
        if not ids[key] then
            table.insert(result, cards)
            ids[key] = idsArr
        end
    end
    return result
end

--寻找牌五同*/
function CardUtils:_findWuTong(cards, length, isSort)
    local length = 5
    local result_1 = self:_findResult(cards, length, isSort)
    local retult_2 = self:_findWuTong_2(cards, isSort)

    local result = self:_handRepeatResult( result_1, retult_2 )
    
    if true then
        return result
    else
        return result_1
    end
end

--判断是否是234567牌的五同
function CardUtils:_findWuTong_2(oriCards, isSort)
    local length = 4
    local resultTieZhi = self:_findResult(oriCards, length, isSort)
    local result = {}

    for _,cards in ipairs(resultTieZhi) do
        local isWuTong = self:_isRuanGui(cards)
        if isWuTong then
            table.insert(result, cards)
        end 
    end
    return result
end

--寻找牌铁支*/
function CardUtils:_findTieZhi(oriCards, isSort)
    local length = 4
    local result_1 = self:_findResult(oriCards, length, isSort)
    local retult_2 = self:_findTieZhi_2(oriCards, isSort)
    local result = self:_handRepeatResult( result_1, retult_2 )
    if true then
        return result
    else
        return result_1
    end
end

--判断是否是234567牌的铁支
function CardUtils:_findTieZhi_2(oriCards, isSort)
    local length = 3
    if (#oriCards < length) then
        return {}
    end
    local result = {}
    local cards = {}
    local cardsGui = self:_findGuiCards(oriCards) or {}
    if #cardsGui <= 2 then
        local retultSanTiao = self:_findSanTiao(oriCards, isSort)
        for _,cards in ipairs(retultSanTiao) do
            local isTieZhi = self:_isRuanGui(cards)
            if isTieZhi then
                table.insert(result, cards)
            end 
        end
    end

    return result
end

--判断是否是234567牌的铁支五同六同
function CardUtils:_isRuanGui(oriCards, score)
    local tal = self:_getRuanGui() 
    if score then
        if table.indexof(tal, score) then
            return true
        end
        return false
    end
    for _,card in ipairs(oriCards) do
        local score = card[numberKey]
        if table.indexof(tal, score) == false and score ~= guiValue then
            return false
        end
    end
    return true
end

--g_guiNumber 软鬼功能
function CardUtils:_getRuanGui()
    local tals = {
        [0] = {},
        [1] = {2},
        [2] = {2,3},
        [3] = {2,3,4},
        [4] = {2,3,4,5},
        [5] = {2,3,4,5,6},
        [6] = {2,3,4,5,6,7},
    }
    local key = g_guiNumber or 0
    local tal = tals[key]
    return tal
end

--寻找牌葫芦*/
function CardUtils:_findHuLu(oriCards, isSort)
    local length = 5
    if (#oriCards < length) then
        return {}
    end
    local ids = {}
    local result = {}
    
    local sanTiao = self:_findSanTiao(oriCards) --三条没有带单牌
    local duiZi = self:_findDuiZi(oriCards) --对子没有带单牌
 
    for i = 1, #duiZi do
        local pre = duiZi[i]
        local cardsGui = self:_findGuiCards(pre) or {}
        if #cardsGui == 0 then
            for j = 1, #sanTiao do
                local next = sanTiao[j]
                local newCards = tableConcat(next, pre)
                newCards = self:GetRepeatFwxmmc(newCards)
    
                if (#newCards == length) then
                    local cardsGui = self:_findGuiCards(newCards)
                    if #cardsGui <= 1 then

                        local idsArr = {}
                        for _, card in ipairs(newCards) do
                            table.insert(idsArr, card.id)
                        end
                        table.sort(idsArr,function(a1, a2)
                            return a1 < a2
                        end)
                        local key = table.concat( idsArr )
                        if not ids[key] then
                            ids[key] = idsArr
                            table.insert(result, newCards)
                        end

                    end
                end
            end
        end
        
    end
   
    if isSort then
        self:_cardsResultSort(result, self.TYPE.HuLu)
    end
    return result
end

--寻找牌三条*/
function CardUtils:_findSanTiao(cards, isSort)
    local length = 3
    return self:_findResult(cards, length, isSort)
end

--寻找牌两对*/
function CardUtils:_findLiangDui(cards, isSort)
    if (#cards < 4) then
        return {}
    end
    cards = clone(cards)
    local result = {}
    local duiZiCards = self:_findFuShuCard(cards, 2)
    for i = 1, #duiZiCards do
        local pre = duiZiCards[i]
        for j = i + 1, #duiZiCards do
            local next = duiZiCards[j]
            local s = tableConcat(next, pre)
            s = self:GetRepeatFwxmmc(s)
            if (#s == 4) then
                table.insert(result, s)
            end
        end
    end
    if isSort then
        self:_cardsResultSort(result, self.TYPE.LiangDui)
    end
    return result
end

--寻找牌对子*/
function CardUtils:_findDuiZi(cards, isSort)
    local length = 2
    return self:_findResult(cards, length, isSort)
end

--获取牌的类型*/
function CardUtils:_cardsType(cards)
    if (#(self:_findLiuTong(cards)) > 0) then
        --return self.TYPE.LiuTong
    elseif (#(self:_findWuTong(cards)) > 0) then
            return self.TYPE.WuTong
    elseif (#(self:_findTongHuaShun(cards, 5)) > 0) then
        return self.TYPE.TongHuaShun
    elseif (#(self:_findTieZhi(cards)) > 0) then
        return self.TYPE.TieZhi
    elseif (#(self:_findHuLu(cards)) > 0) then
        return self.TYPE.HuLu
    elseif (#(self:_findTongHua(cards, 5)) > 0) then
        return self.TYPE.TongHua
    elseif (#(self:_findShunZi(cards, 5)) > 0) then
        return self.TYPE.ShunZi
    elseif (#(self:_findSanTiao(cards)) > 0) then
        return self.TYPE.SanTiao
    elseif (#(self:_findLiangDui(cards)) > 0) then
        return self.TYPE.LiangDui
    elseif (#(self:_findDuiZi(cards)) > 0) then
        return self.TYPE.DuiZi
    end
    return self.TYPE.WuLong
end

--改变鬼牌的分数*/
function CardUtils:_changeCardScors(cardModel)
    for _, card in ipairs(cardModel) do
        card[scoresKey] = card[numberKey]
    end
    cardModel = self:_convert_1To14(cardModel)

    local is14 = true
     --是A K Q J 10

    local is1 = true
     --是1 2 3 4 5

    for _, card in ipairs(cardModel) do
        if (card[scoresKey] < 10) then
            is14 = false
        end

        if card[scoresKey] > 5 and card[scoresKey] ~= 14 and card[scoresKey] < guiValue then
            is1 = false
        end
    end

    local scoresArr = {} --一副牌的分数
    if is14 then
        table.sort(
            cardModel,
            function(a1, a2)
                return a1[scoresKey] < a2[scoresKey]
            end
        )
        local minScore = 10 --最小的牌的分数
        for i = minScore, minScore + 4 do
            table.insert(scoresArr, i)
        end
    elseif is1 then --是1 2 3 4 5
        table.sort(
            cardModel,
            function(a1, a2)
                return a2[scoresKey] < a1[scoresKey]
            end
        )
        local minScore = 1 --最小的牌的分数
        for i = minScore, minScore + 4 do
            table.insert(scoresArr, i)
        end
    else
        table.sort(
            cardModel,
            function(a1, a2)
                return a1[scoresKey] < a2[scoresKey]
            end
        )
        local minScore = tonumber(cardModel[1][scoresKey])--最小的牌的分数
        for i = minScore, minScore + 4 do
            table.insert(scoresArr, i)
        end
    end

    for i, card in ipairs(cardModel) do --删除不是鬼牌的分
        local scores = card[scoresKey]
        local indexof = table.indexof(scoresArr, scores)
        if indexof then
            table.splice(scoresArr, indexof, 1)
        end
    end

    for i, card in ipairs(cardModel) do
        if card[scoresKey] >= guiValue then
            card[scoresKey] = table.splice(scoresArr, 1, 1)[1]
         --改变牌的分数
        end
    end

    cardModel = self:_convert_1To14(cardModel)
    table.sort(
        cardModel,
        function(a1, a2)
            return a1[scoresKey] > a2[scoresKey]
        end
    )
    return cardModel
end

function CardUtils:handleSortCards(cards, cardsType, notHuaSe, isNotSort)
    if (not cards) then
        return {}
    end
    if not cardsType then
        cardsType = self:_cardsType(cards)
    end
    local caleCards = self:_convert_1To14(cards)
    local guiCards = self:_findGuiCards(caleCards)
    local maxScore
    if #guiCards > 0 then
        maxScore = self:findMaxNumber(self:_delCards(guiCards, caleCards), cardsType )--获取除鬼牌外最大的的点数
        local maxScoreColor = 0

        for _, card in ipairs(caleCards) do --改变有鬼牌的牌型scores Color
            if (card[scoresKey] == maxScore and maxScoreColor < card[colorKey] and card[numberKey] < guiValue) then
                maxScoreColor = card[colorKey]
            end
        end
        if #guiCards == #cards then maxScoreColor = 4 end
        if maxScore == 0 then maxScore = 14 end
        for _, card in ipairs(caleCards) do --改变有鬼牌的牌型scores Color
            if (card[numberKey] >= guiValue) then
                card[scoresKey] = maxScore
                card[changeColorKey] = maxScoreColor
            end
        end
    end
    
    if cardsType == self.TYPE.ShunZi or cardsType == self.TYPE.TongHuaShun then --鬼牌顺子的分不同
        if (#guiCards > 0) then
            caleCards = self:_changeCardScors(caleCards)
        else
            caleCards = self:_typeCardsSortByScores(caleCards)
        end
    elseif cardsType == self.TYPE.TieZhi then
        caleCards = self:_typeCardsSortByScores(caleCards, maxScore)
    elseif not isNotSort then
        caleCards = self:_typeCardsSortByScores(caleCards)
    end
    caleCards = self:_convert_1To14(caleCards)
   
    return caleCards
end

--开始计算分数*/
function CardUtils:scoreOfCards(cards, cardsType, notHuaSe)
    if (not cards) then
        return
    end
    cards = clone(cards)
    if not cardsType then
        cardsType = self:_cardsType(cards)
    end
    for _, card in ipairs(cards) do
        card[changeColorKey] = card[colorKey]
        card[scoresKey] = card[numberKey]
    end
    local isTou = #cards == 3
    local caleCards = self:handleSortCards(cards, cardsType, notHuaSe)
    local totalValue = ""
    local valueColor = ""
    --牌色
    local obj = {}
    if cardsType == self.TYPE.TongHua then
        for i, card in ipairs(caleCards) do
            local scores = card[scoresKey]
            if not obj[scores] then
                obj[scores] = 0
            else
                obj[scores] = obj[scores] + 1
            end
        end
    end

    for _, card in ipairs(caleCards) do
        local tonghuaPoint = 0
        if cardsType == self.TYPE.TongHua then
            tonghuaPoint = obj[card[scoresKey]] * 14
        end
        local s = card[scoresKey] + tonghuaPoint
        totalValue = totalValue .. string.format("%02d", s)
        local c = card[changeColorKey]
         --牌色
        valueColor = valueColor .. c
     --牌色
    end

    if isTou then
        totalValue = totalValue .. "0000"
        valueColor = valueColor .. "00"
    end
    if notHuaSe or true then
        totalValue = cardsType .. totalValue
    else
        totalValue = cardsType .. totalValue .. valueColor
    end
    return tonumber(totalValue)
end

--分别获取type,value,cards  得到的格式应该是这样：type: 5,value: 50000000,cards:suit:'s',number: 4end,end,endend
function CardUtils:getDaoTypeAndValue(cards)
    local result = {}
    -- self:_typeCardsSortByScores(cards)
    result.type = self:_cardsType(cards)
    result.value = self:scoreOfCards(cards, result.type)
    cards = self:handleSortCards(clone(cards),result.type,nil)
    result.cards = cards
    local ids = {}
    local colors = {}
    local numbers = {}
    for _, card in ipairs(cards) do
        table.insert(ids, card.id)
        table.insert(colors, card[colorKey])
        table.insert(numbers, card[numberKey])
    end

    result.ids = ids
    result.colors = colors
    result.numbers = numbers
    return result
end

--自动选择牌，由大到小*/
function CardUtils:getAllCardsTypeAndValue(resultCards, cards)
    local remnantCards = clone(cards)
    for _, card in ipairs(resultCards) do
        remnantCards = self:_delCards(card, remnantCards)
    end
    remnantCards = self:_typeCardsSortByScores(remnantCards)

    for i = 1, 3 do
        local length = 5
        if i == 3 then
            length = 3
        end
        if (not resultCards[i]) then
            resultCards[i] = {}
        end
        if (#resultCards[i] < length) then
            while (#resultCards[i] < length) do
                local card = table.splice(remnantCards,1,1)[1]
                table.insert(resultCards[i], card)
            end
        end
    end

    local weiDaoCards = resultCards[1]
    local zhongDaoCards = resultCards[2]
    local touDaoCards = resultCards[3]
    local touServerInfo = self:getDaoTypeAndValue(touDaoCards)
    local zhongServerInfo = self:getDaoTypeAndValue(zhongDaoCards)
    local weiServerInfo = self:getDaoTypeAndValue(weiDaoCards)
    local weiScore = weiServerInfo.value 
    local zhongScore = zhongServerInfo.value
    local touScore = touServerInfo.value
   
    if (zhongScore > weiScore) then
        local tem = weiServerInfo
        weiServerInfo = zhongServerInfo
        zhongServerInfo = tem

        weiScore = weiServerInfo.value 
        zhongScore = zhongServerInfo.value
    end
    
    if touScore > zhongScore then
        -- dump(weiServerInfo)
        -- dump("touScore倒水：--"..tostring(touScore), "-----zhongScore----"..tostring(zhongScore))
        return
    end
    if zhongScore > weiScore then
        -- dump("zhongScoree倒水：---"..tostring(zhongScore), "----weiScore---"..tostring(weiScore))
        return
    end
    local result = {touServerInfo, zhongServerInfo, weiServerInfo}
    return result
end

function CardUtils:autoSelectCards(originCards)
    dump(os.now())
    originCards = self:_convert_1To14(originCards)
    local cards = clone(originCards)
    cards = self:_typeCardsSortByScores(cards)
 
    local findFuncs = {
        --self._findLiuTong,
        self._findWuTong,
        self._findTongHuaShun,
        self._findTieZhi,
        self._findHuLu,
        self._findTongHua,
        self._findShunZi,
        self._findSanTiao,
        self._findLiangDui,
        self._findDuiZi
    }
    local types = {
        --self.TYPE.LiuTong,
        self.TYPE.WuTong,
        self.TYPE.TongHuaShun,
        self.TYPE.TieZhi,
        self.TYPE.HuLu,
        self.TYPE.TongHua,
        self.TYPE.ShunZi,
        self.TYPE.SanTiao,
        self.TYPE.LiangDui,
        self.TYPE.DuiZi,
    }
    --收集尾道  
    local weiArrays = {}
    local isSort = false
    for idx, func in ipairs(findFuncs) do
        local cardsArrays = handler(self, func)(cards, nil, isSort) or {}
        local cardsType = types[idx]
        local weiData = {}
        local rescore = {}
        local rescore1 = {}
        for _, tempCards in ipairs(cardsArrays) do
            local score = self:scoreOfCards(tempCards, cardsType, true)
            if not rescore[score] then
                rescore[score] = score
                table.insert(weiData, tempCards)
                table.insert(rescore1, score)
            end
        end
       
        weiData = table.slice(weiData,1,4,true)
        weiArrays = tableConcat(weiArrays,weiData)
    end
    --根据尾道收集中道
    local zhongAndWeiArrays = {}
    for idx, tempCards in ipairs(weiArrays) do
        local zhongCards = self:_delCards(tempCards, cards)
        -- local cardsArrays = {}

        local zhongData = {}
        for _, func in ipairs(findFuncs) do
            local cardsArrays = handler(self, func)(zhongCards, nil, isSort) or {}
            if #cardsArrays > 0 then
                zhongData = cardsArrays[1]
                break
            end
        end

        if #zhongData == 0 then
            zhongData = table.slice(zhongCards, 1, 5)
        end
        table.insert(zhongAndWeiArrays, {tempCards, zhongData})
    end
    --根据尾道中道收集头道
    for idx, tempCards in ipairs(zhongAndWeiArrays) do
        local delCards = self:_delCards(tempCards[1], cards)
        delCards = self:_delCards(tempCards[2], delCards)
        local touData = {}

        for _, func in ipairs(findFuncs) do
            local cardsArrays = handler(self, func)(delCards, nil, isSort) or {}
            if (cardsArrays and #cardsArrays > 0 and #cardsArrays[1] <= 3) then
                touData = cardsArrays[1]
                break
            end
        end

        if #touData == 0 then
            touData = table.slice(delCards, 1, 3)
        end
        table.insert(tempCards, touData)
    end

    local tem = {}
    local result = {}
    for i, resultCards in ipairs(zhongAndWeiArrays) do
        local dao = self:getAllCardsTypeAndValue(resultCards, cards)
        if (dao) then
            local ids = ""
            for _, v in ipairs(dao) do
                local idsArr = clone(v.ids)
                table.sort(idsArr,function(a1, a2)
                    return a1 < a2
                end)
                ids = ids.. table.concat( idsArr )
            end
            if not tem[ids] then
                tem[ids] = ids
                table.insert(result, dao)
            end
        end
    end

    local sortf = function (result)
        table.sort(
            result,
            function(a, b)
                local toua, zhonga, weia, toub, zhongb, weib
                toua = a[1]
                zhonga = a[2]
                weia = a[3]
                toub = b[1]
                zhongb = b[2]
                weib = b[3]
                local typea = tonumber("" .. weia.type .. zhonga.type .. toua.type)
                local typeb = tonumber("" .. weib.type .. zhongb.type .. toub.type)
                if typeb ~= typea then
                    return typeb < typea
                else
                    if (weib.value ~= weia.value) then
                        return weib.value < weia.value
                    elseif (zhongb.value ~= zhonga.value) then
                        return zhongb.value < zhonga.value
                    else
                        return weib.value < weia.value
                    end
                end
            end
        )
    end
    
    -- sortf(result)
    if #result > 12 then
        local b = {}
        for i, dao in ipairs(result) do
            local type = ""
            local ids = ""
            for _, v in ipairs(dao) do
                type = type .. v.type
            end
            if (not tem[type]) then
                tem[type] = {}
            end
            -- local len = 2
            -- if #result > 20 then
            --     len = 1
            -- end
            if #(tem[type]) < 1 and #b < 5 then
                table.insert(tem[type], type)
                table.insert(b, dao)
            end
        end
        result = b
    else
        local wei = table.slice(cards, 1, 5)
        local zhong = table.slice(cards, 6, 5)
        local tou = table.slice(cards, 11, 3)
        local dao = self:getAllCardsTypeAndValue({wei, zhong, tou}, cards)
        if (dao) then
            table.insert(result, dao)
        end
    end
    dump(os.now())
    result = table.slice(result,1,5,true)
    sortf(result)

    return result
end

--获取对子 五同等牌组合
function CardUtils:_findHandCards(originCards)
    
    -- table.sort(originCards,function(a, b)
    --     return a.id < b.id
    -- end)

    local findFuncs = {
        self._findDuiZi,
        self._findLiangDui,
        self._findSanTiao,
        self._findShunZi,
        self._findTongHua,
        self._findHuLu,
        self._findTieZhi,
        self._findTongHuaShun,
        self._findWuTong,
        self._findLiuTong,
    }

    local types = {
        self.TYPE.DuiZi,
        self.TYPE.LiangDui,
        self.TYPE.SanTiao,
        self.TYPE.ShunZi,
        self.TYPE.TongHua,
        self.TYPE.HuLu,
        self.TYPE.TieZhi,
        self.TYPE.TongHuaShun,
        self.TYPE.WuTong,
        self.TYPE.LiuTong,
    }
    --收集尾道  
    local result = {}
    for idx, func in ipairs(findFuncs) do
        local type = types[idx]
        local isSort = true
        local cardsArrays = handler(self, func)(originCards, nil, isSort) or {}
        local idxArr = {}
        for _, tempCards in ipairs(cardsArrays) do
            local indexs = {}
            for _, card in ipairs(tempCards) do
                table.insert( indexs, card.id )
            end
            table.insert( idxArr, indexs )
        end
        table.insert( result, idxArr )
    end
    return result
end


-- --下面是测试的代码
-- local testCards = {
--     -- {number = 8,  color = 4,},
--     -- {number = 7,  color = 4,},
--     -- {number = 6,  color = 4,},
--     -- {number = 6,  color = 4,},
--     -- {number = 20,  color = 4,},

--     {number = 10,  color = 4,},
--     {number = 10,  color = 4,},
--     {number = 10,  color = 4,},
--     {number = 12,  color = 4,},
--     {number = 12,  color = 4,},

--     -- {number = 7,  color = 4,},
--     -- {number = 4,  color = 2,},
--     -- {number = 20,  color = 2,},
-- }
-- for i,v in ipairs(testCards) do
--     v.scores = v.number
--     v.id = i
-- end
-- testCards = {
--     0x02,0x03,0x04,0x05,0x06,
--     0x14,0x15,0x16,0x17,0x18,
--     -- 0x3C,0x3D,0x31,
--     0x4E,0x4f,0x4f,
-- }
-- testCards = CardUtils:getClientCardByServerCard(testCards)

-- dump(testCards)
-- local cardValue_ = getValue(cardUint)
    -- local cardVariety_ = getVariety(cardUint)
-- dump(os.now())
-- CardUtils:_findHandCards(testCards)
-- local result = CardUtils:_findHuLu(testCards)
-- local result = CardUtils:getClientCardByServerCard(testCards, 2)
-- dump(os.now())
-- print()
return CardUtils
