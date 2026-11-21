local Card  = class("Card")
local CardAnalysis, CARDTYPE, LogicValueMap, ValueMap = unpack(require("xinyu510k.CardAnalysis"))

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
    --if color == 4 then value = value - 2 end
	value = ValueMap[value] or value
    return color*16 + value
end

function Card:getCardValueAndColor(value)
    local _value  = bit.band(0x0F,value)
    local _kind   = bit.brshift(value, 4)
    return _value, _kind
end

function Card:getCardImagePath(value, kind)
	local cardPath = ""
	if kind == 4 then
        cardPath = value == 16 and "small_king" or "big_king"
    elseif  value > 2 and value < 10 then
        cardPath =  tbKind[tonumber(kind)].."_0"..value          
    else
        cardPath =  tbKind[tonumber(kind)].."_"..value
    end
	return "xinyu510k/images/cards_min/"..cardPath..".png"
end

--整图引用画牌
function Card:getCard(value,kind,isLandlord,bShow)
    dump(isLandlord,"isLandlord")
    -- local sizeWidth = 104
    -- local sizeHeight = 145
    local oriScale = 0.86

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

    local card = cc.Sprite:create("xinyu510k/images/cards/"..cardPath..".png")
    
    card:setScale(oriScale)
    card:setAnchorPoint(cc.p(0.5,0.5))

    card._kind = kind
    card._value = value
    card.selected = 0  --选中状态

    if show_logo == 1 then
         --local spLogo = self:getLogo(true)
		 local spLogo = self:getAssLogo()
         if spLogo then
             spLogo:setAnchorPoint(cc.p(0,0.5))
			 spLogo:setPosition(cc.p(0,0))
         
             local cardSize = card:getContentSize()
             --local x = cardSize.width
			 local y = cardSize.height/2
			 spLogo:setPosition(cc.p(0,y))
			 card:addChild(spLogo)
             
         end
    end

    return card

end

function Card:getCardByMagic(value,kind, magicvalue)
    local oriScale = 0.86

    local cardPath = ""
    
	if magicvalue > 2 and magicvalue < 10 then
        cardPath =  "magic_0"..magicvalue          
    else
        cardPath =  "magic_"..magicvalue
    end

    local card = cc.Sprite:create("xinyu510k/images/cards/"..cardPath..".png")
    
    card:setScale(oriScale)
    card:setAnchorPoint(cc.p(0.5,0.5))

    card._kind = kind
    card._value = value
    card.selected = 0

    return card

end

--地主logo
function Card:getLogo(flag)
    local rat = flag or false
    local spBack = display.newSprite("xinyu510k/images/lord_bar.png")
    if spBack then
        local sp = display.newSprite("xinyu510k/images/lord_bar_text_dizhu.png")
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

--伙牌logo
function Card:getAssLogo()
    local rat = flag or false
    local spBack = display.newSprite("xinyu510k/images/help.png")
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

    local card = cc.Sprite:create("xinyu510k/images/cards_min/"..cardPath..".png")
    
    dump("xinyu510k/images/cards_min/"..cardPath..".png","牌的路径")
    
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
--     local spBack = display.newSprite("xinyu510k/images/Game/cards/small_card_bg.png")
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

--手牌排序
function Card:HandCardSort(handcards)
	local kindCard = {}
	local five10K = {}
	local otherCard = {}
	for _, v in pairs(handcards) do
		if v[2] == 4 then
			kindCard[ #kindCard + 1 ] = v
		elseif v[1] == 0x05 or v[1] == 0x0a or v[1] == 0x0D then
			five10K[ #five10K + 1 ] = v
		else
			otherCard[ #otherCard + 1 ] = v
		end
	end
	
	self:sortCard(kindCard)
	self:sortCard(five10K)
	
	local AnalyseResult = CardAnalysis:AnalysebCardData(otherCard)
	otherCard = {}
	dump(AnalyseResult, 'AnalyseResult')
	for i=8, 1, -1 do
		if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
			self:sortCard(AnalyseResult.cbCardData[i])
			
			for j=1, AnalyseResult.cbBlockCount[i]*i do
				otherCard[ #otherCard + 1 ] = AnalyseResult.cbCardData[i][j]
			end
		end
	end
	
	--dump(handcards, 'handcards')
	dump(five10K, 'five10K')
	dump(otherCard, 'otherCard')
	dump(kindCard, 'kindCard')
	if #handcards ~= (#kindCard+#five10K+#otherCard) then
		print('----error-----',debug.traceback())
		-- dump(handcards)
		-- dump(kindCard)
		-- dump(five10K)
		-- dump(otherCard)
		return
	end
	local temp = {}
	for i=1, #kindCard do
		temp[ #temp + 1 ] = kindCard[i]
	end
	for i=1, #five10K do
		temp[ #temp + 1 ] = five10K[i]
	end
	for i=1, #otherCard do
		temp[ #temp + 1 ] = otherCard[i]
	end
	return temp
end


--牌排序
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
			--5 10 K放前面
			-- if (a[1] == 0x05 or a[1] == 0x0a or a[1] == 0x0D) and (b[1] ~= 0x05 and b[1] ~= 0x0a and b[1] ~= 0x0D) then
				-- return true
			-- end
			-- if (a[1] ~= 0x05 and a[1] ~= 0x0a and a[1] ~= 0x0D) and (b[1] == 0x05 or b[1] == 0x0a or b[1] == 0x0D) then
				-- return false
			-- end
			
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


