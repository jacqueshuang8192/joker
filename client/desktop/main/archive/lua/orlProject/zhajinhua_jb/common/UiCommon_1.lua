local RoomlevelMap  =  import("zhajinhua_jb.pintu.RoomlevelMap")
local UiCommon      = class("UiCommon")


--显示漂亮的数字
function UiCommon:numFnt(num)
	local num_str  = ""
	num      =  tonumber(num)
	if num < 10000 then
		local thousand = math.modf(num/1000)
		local hundrand = num%1000
		if thousand ~= 0 then
			num_str = thousand..","..hundrand
		else
			num_str = hundrand
		end
	else
		local ten_thousand = math.modf(num/10000)
		local thousand     = math.modf(num%10000/1000)
		if thousand >= 5 then
			thousand = thousand +1
		end
		if thousand ~= 0 then
			num_str = ten_thousand..","..thousand.."w"
		else
			num_str = ten_thousand.."w"
		end
	end

	num_str = tostring(num_str)

	local num_node = display:newNode()
	local point    =  0

	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local image  = ""
		local width  = 0
		if t_byte == "," then
			image = "dou.png"
			width = 20
		elseif  t_byte == 'w' then
			image = "wan.png"
			width = 40
		else
			image = t_byte..".png"
			width = 30
		end

		local map_b = RoomlevelMap[image]

		if map_b == nil then
			return false
		end

		local num_tmp = display.newSprite(map_b["file"])
		num_tmp:setTextureRect(cc.rect(map_b['x'],map_b['y'],map_b['width'],map_b['height']))
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
		num_tmp:addTo(num_node)
		i=i+1
	end


	return num_node

end

--返回数字
function UiCommon:numFormat(num)
	return tostring(num)
	-- local num_str  = ""
	--       num      =  tonumber(num)
	-- if num < 10000 then
	-- 	local thousand = math.modf(num/1000)
	-- 	local hundrand = num%1000
	-- 	if thousand ~= 0 then
	-- 		num_str = thousand..","..hundrand
	-- 	else
	-- 		num_str = hundrand
	-- 	end
	-- else
	-- 	local ten_thousand = math.modf(num/10000)
	-- 	local thousand     = math.modf(num%10000/1000)
	-- 	if thousand >= 5 then
	-- 		thousand = thousand +1
	-- 	end
	-- 	if thousand ~= 0 then
	-- 		num_str = ten_thousand..","..thousand.."w"
	-- 	else
	-- 		num_str = ten_thousand.."w"
	-- 	end
	-- end

	-- num_str = tostring(num_str)

	-- return num_str

end

--显示房间信息的数字
function UiCommon:numRoom(num)
	-- body
	num_str        = tostring(num)
	local num_node = display:newNode()
	local point    = 0
	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local file   = "num"..t_byte..".png"
		local num_tmp    = display.newSprite("zhajinhua_jb/res/room/roombase/"..file)
		num_tmp:addTo(num_node)
		local width  = 20
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
	end

	return num_node

end

--获得数字筹码
function UiCommon:getChipsNum(gold)
	local num_str  = gold
	if gold >=1000 and gold <10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"
	elseif gold >= 10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"
	end
	num_str = tostring(num_str)
	return num_str
end
--获得筹码
function UiCommon:getChips(gold)
	local img_name = ""
	local num_str  = gold

	local node  =display.newNode()
	if gold <500 then
		img_name ="chipBtn1.png"
	elseif gold >=500 and gold<1000 then
		img_name ="chipBtn2.png"
	elseif gold >=1000 and gold <2000 then
		img_name ="chipBtn2.png"
	elseif gold>=2000 and gold<10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"
		img_name ="chipBtn4.png"
	elseif gold >=10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"
		img_name ="chipBtn5.png"
	end

	local chip =  display.newSprite("zhajinhua_jb/res/room/chip/"..img_name)
	chip:addTo(node)
	chip:setScale(0.5)

	num_str     = tostring(num_str)
	local point = -30
	local width = 12

	if #num_str == 4 then
		point = -30
		width = 12
	end

	if #num_str == 2 then
		point = -23
		width = 15
	end

	if #num_str == 3 then
		point = -25
		width = 12
	end

	local num_node = display:newNode()

	for i=1,#num_str do
		local t_byte   = string.sub(num_str,i,i)
		local file     = t_byte..".png"
		if t_byte == 'k' then
			file = "q.png"
		end
		if t_byte == 'w' then
			file = "w.png"
		end
		local num      = display.newSprite("zhajinhua_jb/res/room/chip/"..file)
		num:addTo(num_node)

		if i >=1 then
			num:pos(point+width,2)
			point = point+width
		else
			num:pos(point,2)
		end
		num:setScale(0.7)
	end


	num_node:addTo(node)
	node:setScale(0.7)

	return node
end
--
-- 金币按钮
function UiCommon:getChipBtn(gold,index)
	local img_name = ""
	local num_str  = gold

	if gold <500 then
		img_name ="chipBtn1.png"
	elseif gold >=500 and gold<1000 then
		img_name ="chipBtn2.png"
	elseif gold >=1000 and gold <2000 then
		img_name ="chipBtn2.png"
	elseif gold>=2000 and gold<10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"
		img_name ="chipBtn4.png"
	elseif gold >=10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"
		img_name ="chipBtn5.png"
	end
	if index then
		if index < 1 then
			img_name ="chipBtn1.png"
		elseif index > 5 then
			img_name ="chipBtn5.png"
		else
			img_name ="chipBtn"..tostring(index)..".png"
		end
	end

	local chip =  ccui.Button:create("zhajinhua_jb/res/NewImg/chip/"..img_name, nil, nil)
	chip:setScale(0.3)

	num_str     = tostring(num_str)
	local point = -30
	local width = 12

	if #num_str == 4 then
		point = -30
		width = 12
	end

	if #num_str == 2 then
		point = -23
		width = 15
	end

	if #num_str == 3 then
		point = -25
		width = 12
	end

	local num_node = display:newNode()

	for i=1,#num_str do
		local t_byte   = string.sub(num_str,i,i)
		local file     = t_byte..".png"
		if t_byte == 'k' then
			file = "q.png"
		end
		if t_byte == 'w' then
			file = "w.png"
		end
		local num      = display.newSprite("zhajinhua_jb/res/room/chip/"..file)
		num:addTo(num_node)
		if i >=1 then
			num:pos(point+width,2)
			point = point+width
		else
			num:pos(point,2)
		end
		-- num:setScale(0.7)
	end


	num_node:addTo(chip)
	num_node:setPosition(chip:getContentSize().width/2, chip:getContentSize().height/2)

	return chip
end
-- 金币按钮
function UiCommon:getChipBtnNew(gold,val)

	local img_name = ""
	local num_str  = gold
	if gold>=1000 and gold<10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"

	elseif gold >=10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"
	else
		num_str = math.modf(gold)
	end
	local num_node = display:newNode()
	local ttfConfig = {}
	ttfConfig.fontFilePath = "zhajinhua_jb/res/fonts/fzcy.ttf"
	ttfConfig.fontSize = 32
	local text = cc.Label:createWithTTF(ttfConfig, num_str)
	if val == 1 then
		text:setColor(cc.c3b(4,136,112))
		img_name ="chouma_05.png"
	elseif val == 2 then
		img_name ="chouma_03.png"
		text:setColor(cc.c3b(68,114,158))
	elseif val == 3 then
		img_name ="chouma_04.png"
		text:setColor(cc.c3b(70,58,149))
	elseif val == 4 then
		img_name ="chouma_06.png"
		text:setColor(cc.c3b(149,45,61))
	else
		img_name ="chouma_07.png"
		text:setColor(cc.c3b(149,45,61))
	end
	text:pos(num_node:getPositionX(),num_node:getPositionY()+4)
	text:addTo(num_node)
	local chip =  ccui.Button:create("zhajinhua_jb/res/newroom/"..img_name, nil, nil)
	num_str     = tostring(num_str)
	if #num_str == 5 then
		text:setScale(0.7)
	end
	if #num_str == 4 then
		text:setScale(0.7)
	end
	if #num_str == 3 then
		text:setScale(0.8)
	end

	num_node:addTo(chip)
	num_node:setPosition(chip:getContentSize().width/2, chip:getContentSize().height/2)

	return chip
end

--显示输金币
function UiCommon:gameLostGold(num)
	num_str        = tostring(num)
	local num_node = display:newNode()
	local fu       = display.newSprite("zhajinhua_jb/res/room/gameOver/num/minus.png")
	fu:addTo(num_node)
	local point    = 20
	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local file   = "gray_"..t_byte..".png"
		local num_tmp    = display.newSprite("zhajinhua_jb/res/room/gameOver/num/"..file)
		num_tmp:addTo(num_node)
		local width  = 40
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
	end

	return num_node
end

--显示赢金币
function UiCommon:gameWinGold(num)
	num_str        = tostring(num)
	local num_node = display:newNode()
	local fu       = display.newSprite("zhajinhua_jb/res/room/gameOver/num/plus.png")
	fu:addTo(num_node)
	local point    = 20
	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local file   = "light_"..t_byte..".png"
		local num_tmp    = display.newSprite("zhajinhua_jb/res/room/gameOver/num/"..file)
		num_tmp:addTo(num_node)
		local width  = 40
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
	end

	return num_node
end





return UiCommon