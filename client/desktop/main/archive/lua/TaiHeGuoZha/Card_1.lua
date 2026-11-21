local Card = class("Card")
local CardAnalysis, CARDTYPE, LogicValueMap, ValueMap = unpack(require("TaiHeGuoZha.CardAnalysis"))

local tbKindValue = {
    [0] = "small_card_num_",
    [1] = "small_card_num_balck_",
    [2] = "small_card_num_",
    [3] = "small_card_num_balck_",
    [4] = "joker"
}

local tbKind = {
    [0] = "diamonds",
    [1] = "clubs",
    [2] = "hearts",
    [3] = "spades",
    [4] = "joker_tb"
}
function Card:init(value)
    self._kind = bit.brshift(value, 4)
    self._value = LogicValueMap[value] or bit.band(0x0F, value)

    return self._value, self._kind
end

function Card:restoreCard(color, value)
    --if color == 4 then value = value - 2 end
    value = ValueMap[value] or value
    return color * 16 + value
end

function Card:getCardValueAndColor(value)
    local _value = bit.band(0x0F, value)
    local _kind = bit.brshift(value, 4)
    return _value, _kind
end

function Card:getCardImagePath(value, kind)
    local cardPath = ""
    if kind == 4 then
        cardPath = value == 16 and "small_king" or "big_king"
    elseif value > 2 and value < 10 then
        cardPath = tbKind[tonumber(kind)] .. "_0" .. value
    else
        cardPath = tbKind[tonumber(kind)] .. "_" .. value
    end
    return "TaiHeGuoZha/res/images/cards_min/" .. cardPath .. ".png"
end

--整图引用画牌
function Card:getCard(value, kind)
    local oriScale = 0.86
    --底
    local cardPath = ""
    if kind == 4 then
        cardPath = value == 16 and "small_king" or "big_king"
    elseif value > 2 and value < 10 then
        cardPath = tbKind[tonumber(kind)] .. "_0" .. value
    else
        cardPath = tbKind[tonumber(kind)] .. "_" .. value
    end

    local card = ccui.ImageView:create("TaiHeGuoZha/res/images/cards/" .. cardPath .. ".png")
    -- card:setScale(oriScale)
    card:setAnchorPoint(cc.p(0.5, 0.5))
    card._kind = kind
    card._value = value
    card.selected = 0 --选中状态
    return card
end

function Card:getCardByMagic(value, kind, magicvalue)
    local oriScale = 0.86

    local cardPath = ""

    if magicvalue > 2 and magicvalue < 10 then
        cardPath = "magic_0" .. magicvalue
    else
        cardPath = "magic_" .. magicvalue
    end

    local card = cc.Sprite:create("TaiHeGuoZha/res/images/cards/" .. cardPath .. ".png")

    card:setScale(oriScale)
    card:setAnchorPoint(cc.p(0.5, 0.5))

    card._kind = kind
    card._value = value
    card.selected = 0

    return card
end

--地主logo
function Card:getLogo(flag)
    local rat = flag or false
    local spBack = display.newSprite("TaiHeGuoZha/res/images/lord_bar.png")
    if spBack then
        local sp = display.newSprite("TaiHeGuoZha/res/images/lord_bar_text_dizhu.png")
        spBack:addChild(sp)
        sp:setPosition(59, 56)
        if rat == true then
            sp:setRotation(45)
        else
            sp:setRotation(-135)
        end
    end

    if rat == false then
        spBack:setRotation(90)
    end

    return spBack
end

function Card:getAssLogo()
    local rat = flag or false
end

function Card:getSmallCard(value, kind)
    --底
    local cardPath = ""

    if kind == 4 then
        cardPath = value == 14 and "small_king" or "big_king"
    elseif value > 2 and value < 10 then
        cardPath = tbKind[tonumber(kind)] .. "_0" .. value
    else
        cardPath = tbKind[tonumber(kind)] .. "_" .. value
    end
    local card = cc.Sprite:create("TaiHeGuoZha/res/images/cards_min/" .. cardPath .. ".png")
    if card then
        card._kind = kind
        card._value = value
        card.selected = 0 --选中状态

        return card
    end
  return nil
end

--手牌排序
function Card:HandCardSort(handcards)
    local allCard = {}
    local kindCard = {}
    for _, v in pairs(handcards) do
        if v[2] == 4 then
            kindCard[#kindCard + 1] = v
        else
            allCard[#allCard + 1] = v
        end
    end

    self:sortCard(kindCard)

    local AnalyseResult = CardAnalysis:AnalysebCardData(allCard)
    allCard = {}
    for i = 24, 1, -1 do
        if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
            self:sortCard(AnalyseResult.cbCardData[i])
            for j = 1, AnalyseResult.cbBlockCount[i] * i do
                allCard[#allCard + 1] = AnalyseResult.cbCardData[i][j]
            end
        end
    end

    if #handcards ~= (#kindCard + #allCard) then
        print("----error-----", debug.traceback())
        return
    end

    local temp = {}

    local testTemp = {}
    for i = 1, #allCard do
        if not testTemp[allCard[i][1]] then
            testTemp[allCard[i][1]] = 0
        end
        testTemp[allCard[i][1]] = testTemp[allCard[i][1]] + 1
    end
    local index = 1
    local mjudgement = true

    for i = 1, #allCard do
        if testTemp[allCard[i][1]] == #kindCard then
            mjudgement = false
        end
    end
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "add_joker" then
            if v == 8 or v == 12 then
                if mjudgement == true then
                    for i = 1, #kindCard do
                        temp[#temp + 1] = kindCard[i]
                        WanDeZhangShu = #kindCard
                        index = index + 1
                    end
                end
            end
        end
    end

    for i = 1, #allCard do
        if testTemp[allCard[i][1]] == #kindCard then
            break
        end
        index = index + 1
        temp[#temp + 1] = allCard[i]
    end
    if mjudgement == false then
        for i = 1, #kindCard do
            temp[#temp + 1] = kindCard[i]
            WanDeZhangShu = #kindCard
        end
    end
    local indexTemp = #allCard - index
    if indexTemp > 0 then
        for i = index, #allCard do
            temp[#temp + 1] = allCard[i]
        end
    end
    for k, v in pairs(TaiHeGuoZhaRoomInfo) do
        if k == "add_joker" then
            if v == 0 or v == 4 then
                if mjudgement == true then
                    for i = 1, #kindCard do
                        temp[#temp + 1] = kindCard[i]
                        WanDeZhangShu = #kindCard
                        index = index + 1
                    end
                end
            end
        end
    end
    local cardvalue = 0
    local Bindings = {}
    for i, v in ipairs(temp) do
        if i > 1 then
            if temp[i][1] ~= temp[i - 1][1] or i == #temp then
                cardvalue = i - cardvalue - 1
                if i == #temp then
                    table.insert(Bindings, #Bindings + 1, cardvalue + 1)
                else
                    table.insert(Bindings, #Bindings + 1, cardvalue)
                end
                cardvalue = i - 1
            end
        end
    end
    
    --dump(Bindings, "Bindings ====== ")
    
    --dump(temp, "temp ====== ")

    return temp
end

--牌排序
function Card:sortCard(handcards)
    handcards = handcards or USER_INFO["cards"]

    if handcards == nil then
        return
    end

    table.sort(
        handcards,
        function(a, b)
            if (a[2] == 4 and b[2] == 4) then
                return a[1] > b[1]
            end

            if (a[2] == 4 and b[2] ~= 4) then
                return true
            end

            if (a[2] ~= 4 and b[2] == 4) then
                return false
            end

            if (a[2] ~= 4 and b[2] ~= 4) then
                if a[1] == b[1] then
                    return a[2] > b[2]
                else
                    return a[1] > b[1]
                end
            end
        end
    )
end

--获得牌的唯一索引
function Card:getKey(value, kind)
    local re = value + (kind + 100) * 20
    return re
end

--通过tag找寻card数组的下表
function Card:getCardIndex(tag)
    for key, value in pairs(USER_INFO["cards"]) do
        local now_tag = self:getKey(value[1], value[2])
        if now_tag == tag then
            return key
        end
    end
end

--将牌组装成字符串
function Card:dealCardToString(table_tmp)
    local str = ""

    for key, value in pairs(table_tmp) do
        local kind = bit.blshift(value[2], 4)

        local value = bit.band(15, value[1])

        local all = kind + value

        local byte = string.char(all)
        str = str .. byte
    end

    return str
end

function Card:setCardNum( cardNode, txt_num)
    --显示牌数Logo
    local psLogo = cc.CSLoader:createNode("TaiHeGuoZha/res/Node.csb")
    local nbbg = psLogo:getChildByName("nbbg")
    local smallking = false
    local bigking = false
    local paishu_txt = psLogo:getChildByName("paishu_txt")
    paishu_txt:setString(txt_num)
    if psLogo then
        psLogo:setScale(0.8)
        local cardSize = cardNode:getContentSize()
        local y = cardSize.height * 5 / 9
        local nbbgSize = psLogo:getContentSize()
        psLogo:setPosition(cc.p(25, y))
        cardNode:addChild(psLogo)
    end
end
return Card
