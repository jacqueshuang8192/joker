local Card  = class("Card")
local CardAnalysis, CARDTYPE, LogicValueMap = unpack(require("puchengdazha.CardAnalysis"))

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

    self._kind   = bit.brshift(value, 4)
    self._value  = LogicValueMap[value] or bit.band(0x0F,value)

    return self._value, self._kind
end

function Card:restoreCard(color, value)
    if color == 4 then value = value - 2 end
    return color*16 + value
end

function Card:getCardValueAndColor(value)
    local _value  = bit.band(0x0F,value)
    local _kind   = bit.brshift(value, 4)
    return _value, _kind
end

--整图引用画牌
function Card:getCard(value,kind,isLandlord,bShow)
    dump(isLandlord,"isLandlord")
    -- local sizeWidth = 104
    -- local sizeHeight = 145
    local oriScale = 0.72

    local show_logo = isLandlord or 0
    --底

    local cardPath = ""
    
    if kind == 4 then
        cardPath = value == 16 and "small_king" or "big_king"
    elseif  value > 2 and value < 10 then
        cardPath =  tbKind[tonumber(kind)].."_0"..value          
    else
        cardPath =  tbKind[tonumber(kind)].."_"..value
    end

    local card = cc.Sprite:create("puchengdazha/images/cards/"..cardPath..".png")
    
    card:setScale(oriScale)
    card:setAnchorPoint(cc.p(0.5,0.5))

    card._kind = kind
    card._value = value
    card.selected = 0  --选中状态

     if show_logo == 1 then
         local spLogo = self:getLogo(true)
         if spLogo then
             spLogo:setAnchorPoint(cc.p(1,1))
             card:addChild(spLogo)
             local cardSize = card:getContentSize()
             local x = cardSize.width
             local y = cardSize.height
             spLogo:setPosition(cc.p(x,y))
         end
     end

    return card

end

--地主logo
function Card:getLogo(flag)
    local rat = flag or false
    local spBack = display.newSprite("puchengdazha/images/lord_bar.png")
    if spBack then
        local sp = display.newSprite("puchengdazha/images/lord_bar_text_dizhu.png")
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


function Card:getSmallCard(value, kind)

    --底
    local cardPath = ""

    if kind == 4 then
        cardPath = value == 14 and "small_king" or "big_king"
    elseif  value > 2 and value < 10 then
        cardPath =  tbKind[tonumber(kind)].."_0"..value          
    else
        cardPath =  tbKind[tonumber(kind)].."_"..value
    end

    local card = cc.Sprite:create("puchengdazha/images/cards_min/"..cardPath..".png")
    
    dump("puchengdazha/images/cards_min/"..cardPath..".png","牌的路径")
    
    card._kind = kind
    card._value = value
    card.selected = 0  --选中状态

    return card
end

-- --获得小牌
-- function Card:getSmallCard(value,kind)

--     local sizeWidth = 118
--     local sizeHeight = 155
--     local x = 1
--     local y = 1
--     local scale = 0.75
--     --底
--     local spBack = display.newSprite("puchengdazha/images/Game/cards/small_card_bg.png")
--     spBack:setAnchorPoint(cc.p(0.5,0.5))
--     --字
--     local path = "#"..tbKindValue[tonumber(kind)]..tostring(value)..".png"
--     local frame = display.newSpriteFrame(string.sub(path, 2))
--     if frame == nil then
--         print("getSmallCard", tostring(path))
--         return nil
--     end
--     local spUpValue = display.newSprite(path)
--     spBack:addChild(spUpValue)
--     x = 8 + spUpValue:getContentSize().width/2*scale
--     y = spBack:getContentSize().height - 8 - spUpValue:getContentSize().height/2*scale
--     spUpValue:setPosition(x, y)
--     spUpValue:setScale(scale)

--     if kind < 4 then
--         --花
--         path = "#"..tbKind[tonumber(kind)]..".png"
--         local frame = display.newSpriteFrame(string.sub(path, 2))
--         if frame == nil then
--             print("getSmallCard", tostring(path))
--             return nil
--         end
--         local spUpKind = display.newSprite(path)
--         spBack:addChild(spUpKind)
--         -- x = spBack:getContentSize().width - 8 - spUpKind:getContentSize().width/2*scale
--         x = spBack:getContentSize().width/2
--         y = spUpValue:getPositionY() - spUpValue:getContentSize().height/2*scale - 3 - spUpKind:getContentSize().height/2*scale
--         spUpKind:setPosition(x, y)
--         spUpKind:setScale(scale)
--     else
--         scale = 0.35
--         local scale_x = 0.5
--         local scale_y = 0.35
--         x = 8 + spUpValue:getContentSize().width/2*scale_x
--         y = spBack:getContentSize().height - 8 - spUpValue:getContentSize().height/2*scale_y
--         spUpValue:setPosition(x, y)
--         -- spUpValue:setScale(scale)
--         spUpValue:setScaleX(scale_x)
--         spUpValue:setScaleY(scale_y)
--     end

--     return spBack
-- end


--将用户的牌排序
function Card:sortCard(handcards)

    handcards = handcards or USER_INFO["cards"]

    if handcards == nil then
        return
    end

    table.sort(handcards,function(a,b) 
        if( a[2]  == 4 and b[2] == 4) then
            return a[1]>b[1]
        end

        if(a[2] == 4 and b[2] ~= 4) then
            return true
        end

        if(a[2] ~= 4 and b[2] == 4) then
            return false
        end

        if(a[2] ~= 4 and b[2] ~= 4) then
            if a[1] == b[1] then
                return a[2] > b[2]
            else
                return a[1]>b[1]
            end

        end

    end )

end

--获得拍的唯一索引
function Card:getKey(value,kind)
    local re = value + (kind + 100) * 20
    return re
end

--通过tag找寻card数组的下表
function Card:getCardIndex(tag)

    for key,value in pairs(USER_INFO["cards"]) do
        local now_tag = self:getKey(value[1],value[2])
        if now_tag == tag then
            return key
        end
    end
end


--将牌组装成字符串
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


