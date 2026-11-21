--[[
* author:   zwm
* date:     2019-04-12
* describe: 有关牌的功能
--]]

local Card  = class("Card")
local CARD_BASE_PATH = "yuanjiangqianfen/res/image/cards" 

local chooseColor = cc.c3b(140,140,140)
local oriColor = cc.c3b(255,255,255)
local UP_HIGHT = 10

function Card:init(value)
    self._value  = bit.band(15,value)
    self._kind   = bit.brshift(value,4)

    return self._value,self._kind
end

--把牌的定义值转换成逻辑值
function Card:Decode(value)
    local card = 0
    local low = bit.band(15,value)
    if low == 1 then
        low = 14
    elseif low == 2 then
        low = 15
    end
    local hi = bit.brshift(value,4)
    card = low + hi*16
    
    return card
end

--把牌的逻辑值转换成定义值
function Card:Encode(value)
    local card = 0
    local low = bit.band(15,value)
    if low == 14 then
        low = 1
    elseif low == 15 then
        low = 2
    end
    local hi = bit.brshift(value,4)
    card = low + hi*16

    return card
    
end


--整图引用画牌
-- 参数：value {[1] = value, [2] = color} -- value 为逻辑值
-- 参数：cardType 1、为手牌；2、打出来的牌
function Card:getCard(value, cardType, card_back)
    local defValue = self:Encode(value[1]+16*value[2]) -- 转换成定义值
    local cardType = cardType == nil and 1 or cardType
    local oriScale = cardType == 1 and 0.95 or 0.485

    local cardPath = string.format("/%02x", defValue)
    print("cardType ----------------", CARD_BASE_PATH..cardPath..".png")
    local card = cc.Sprite:create(CARD_BASE_PATH..cardPath..".png")
    if card_back then 
        card = cc.Sprite:create(CARD_BASE_PATH .. "/card_back.png")
    end
    if card == nil then return end
    card:setScale(oriScale)
    card:setAnchorPoint(cc.p(0.5,0.5))

    if cardType == 1 then
        card = self:addCardFunc(card, cardPath)
        card.value = value
    end

    return card

end

function Card:addCardFunc(card, cardPath)
    card.toBlack = function(card) 
        card:setColor(chooseColor) 
        card._isBlack = true 
    end

    card.isBlack = function(card)
        return card._isBlack
    end

    card.toWhite = function(card) 
        card:setColor(oriColor)  
        card._isBlack = false
    end

    card.toUp = function(card) 
        local pY = card:getPositionY()
        card:setPositionY(pY+UP_HIGHT)
    end

    card.toDown = function(card) 
        local pY = card:getPositionY()
        card:setPositionY(pY-UP_HIGHT)
    end

    card.toRotation = function(card)
        card:setTexture(CARD_BASE_PATH .. cardPath .. ".png")
    end
    
    return card
end

--将用户的牌排序
function Card:sortCard(handcards)

    handcards = handcards

    if handcards == nil then
        return
    end

    table.sort(handcards,function(a,b) 
        if a[1] == b[1] then
            return a[2] > b[2]
        else
            return a[1]>b[1]
        end

    end )

end

--将牌组装成字符串 for test
function Card:dealCardToString(table_tmp)
    local str  = ""

    for key,value in pairs(table_tmp) do

        local kind      = bit.blshift(value[2],4)
       
        local  value           = bit.band(15,value[1]) 
        

        local all = kind + value
        
        local byte = string.char(all)
        str  = str..byte 
    end

    return str
end

return Card


