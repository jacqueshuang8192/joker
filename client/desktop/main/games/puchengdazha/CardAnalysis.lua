local Color = {
	Diamond = 0, --方块
	Club = 1,    --梅花
	Heart = 2,   --红心
	Spade = 3,   --黑桃
	Joker = 4,   --大小王
}

local CARDTYPE = {
	Error = -1,   --牌型错误
	One = 1,   --单张
	Two = 2,   --对子

	Three = 3,  --三张
	ThreeTakeOne = 4,  --三带一
	ThreeTakeTwo = 5,  --三带二

	OneLine = 6,   --顺子

	TwoLine = 7,   --连对
	Plane = 8,    --飞机
	PlaneTakeOne = 9,  --飞机带一张
	PlaneTakeTwo = 10,  --飞机带翅膀

	FourTakeTwo = 11,  --四带二
	FourTakeThree = 12,   --四带四

	Bomb = 13,    --炸弹
	Rocket = 14,    --火箭
  
   	BombTrailer = 15,   --拖车
	KingBomb = 16,   --天王炸弹
}

local CmpRes = {
	Error = -1,
	Lose = 0,
	Draw = 1,
	Win = 2,
}

local ValidCardTypeList = {
	CARDTYPE.KingBomb,
	CARDTYPE.Bomb,
	CARDTYPE.TwoLine,
	CARDTYPE.OneLine,
	CARDTYPE.ThreeTakeTwo,
	CARDTYPE.Two,
	CARDTYPE.One,
	CARDTYPE.PlaneTakeTwo,
}

local FinalHandValidCardTypeList = {
	CARDTYPE.KingBomb,
	CARDTYPE.Bomb,
	CARDTYPE.TwoLine,
	CARDTYPE.OneLine,
	CARDTYPE.ThreeTakeTwo,
	CARDTYPE.ThreeTakeOne,
	CARDTYPE.Three,
	CARDTYPE.PlaneTakeTwo,
	CARDTYPE.PlaneTakeOne,
	CARDTYPE.Plane,
	CARDTYPE.Two,
	CARDTYPE.One,
}

local LogicValueMap = {
	[0x01] = 14,
	[0x11] = 14,
	[0x21] = 14,
	[0x31] = 14,
	[0x41] = 16,
	[0x4E] = 16,

	[0x02] = 14,
	[0x12] = 15,
	[0x22] = 15,
	[0x32] = 15,
	[0x42] = 17,
	[0x4F] = 17,
}

local BoomType = {[CARDTYPE.Bomb] = true,
					[CARDTYPE.Rocket] = true,
					[CARDTYPE.BombTrailer] = true,
					[CARDTYPE.KingBomb] = true}

local DDZ_HAND_CARD = {}

local CardAnalysis = {}

local DDZ_HAND_CARD_INDEX_TRANSLATE = 
{
	[1]="one",[2]="double",[3]="three",[4]="four",
	[5]= "five",[6]= "six",[7]= "seven",[8]= "eight",
}

local DDZ_HAND_CARD_INDEX = 
{
	[1]="one_rank",[2]="double_rank",[3]="three_rank",[4]="four_rank",
 	[5]= "five_rank",[6]= "six_rank",[7]= "seven_rank",[8]= "eight_rank",
}

--[1]是牌值，[2]是花色
function CardAnalysis:init()
	for i,v in pairs(DDZ_HAND_CARD_INDEX_TRANSLATE) do
        DDZ_HAND_CARD[v] = {}
    end

    for i,v in pairs(DDZ_HAND_CARD_INDEX) do
    	DDZ_HAND_CARD[v] = {}
    end

    self.GetTypeCardFuncMap = {
		[CARDTYPE.One] = handler(self, self.getOne),
		[CARDTYPE.Two] = handler(self, self.getTwo),
		[CARDTYPE.Three] = handler(self, self.getPlaneTakeTwo),
		[CARDTYPE.ThreeTakeOne] = handler(self, self.getPlaneTakeTwo),
		[CARDTYPE.ThreeTakeTwo] = handler(self, self.getPlaneTakeTwo),
		[CARDTYPE.OneLine] = handler(self, self.getOneLine),
		[CARDTYPE.TwoLine] = handler(self, self.getTwoLine),
		[CARDTYPE.Plane] = handler(self, self.getPlaneTakeTwo),
		[CARDTYPE.PlaneTakeOne] = handler(self, self.getPlaneTakeTwo),
		[CARDTYPE.PlaneTakeTwo] = handler(self, self.getPlaneTakeTwo),
		[CARDTYPE.Bomb] = handler(self, self.getBomb),
		[CARDTYPE.KingBomb] = handler(self, self.getKingBomb),
	}
	--大写的为public接口，小写开头的为protected方法，带__为private方法
	self.CardTypeCheckFuncMap = {
		[CARDTYPE.One] = handler(self, self.isOne),
		[CARDTYPE.Two] = handler(self, self.isTwo),
		[CARDTYPE.Three] = handler(self, self.isThree),
		[CARDTYPE.ThreeTakeOne] = handler(self, self.isThreeTakeOne),
		[CARDTYPE.ThreeTakeTwo] = handler(self, self.isThreeTakeTwo),
		[CARDTYPE.OneLine] = handler(self, self.isOneLine),
		[CARDTYPE.TwoLine] = handler(self, self.isTwoLine),
		[CARDTYPE.Plane] = handler(self, self.isPlane),
		[CARDTYPE.PlaneTakeOne] = handler(self, self.isPlaneTakeOne),
		[CARDTYPE.PlaneTakeTwo] = handler(self, self.isPlaneTakeTwo),
		[CARDTYPE.Bomb] = handler(self, self.isBomb),
		[CARDTYPE.KingBomb] = handler(self, self.isKingBomb),
	}
end

function CardAnalysis:belongtoBoomType(card_type)
	if card_type then
		return BoomType[card_type] or false
	end
	return false
end

function CardAnalysis:belongtoSameType(cardTyp1, cardTyp2)
	if cardTyp1 == cardTyp2 then
		return true
	end 

	if (cardTyp2 == CARDTYPE.Three or cardTyp2 == CARDTYPE.ThreeTakeOne and cardTyp1 == CARDTYPE.ThreeTakeTwo) or 
		(cardTyp2 == CARDTYPE.Plane or cardTyp2 == CARDTYPE.PlaneTakeOne and cardTyp1 == CARDTYPE.PlaneTakeTwo) then
		return true
	end

	return false
end

function CardAnalysis:getAllBombs(cards)

	local CardList = {}
    local bombsList = {}

    for i,card in pairs(cards) do
    	CardList[card[1]] = (CardList[card[1]] or 0) + 1
    end

    for cardValue,SameCardCount in pairs(CardList) do
        if  SameCardCount > 3 then
        	bombsList[cardValue] = SameCardCount
        end
    end

    if  CardList[1] == 2 and CardList[2] == 2 then
		bombsList[1] = 2
		bombsList[2] = 2
	end

	return bombsList
end

--获得做小牌
function CardAnalysis:getLitleCard(tmp)

	if USER_INFO["cards"] == nil then
		return false
	end

	if self:fenLei() == false then
		return false
	end

	local min_value
	local handCardCount = #USER_INFO["cards"]

	--倒序找牌
	for i = handCardCount,1,-1 do
		if not tmp[USER_INFO["cards"][i][1]] then
			min_value = USER_INFO["cards"][i][1]
			break
		end
	end
    
    for _,index in pairs(DDZ_HAND_CARD_INDEX_TRANSLATE) do
    	if DDZ_HAND_CARD[index][min_value] then
    		return DDZ_HAND_CARD[index][min_value]
    	end
    end
	
end

--获得比较大的牌
function CardAnalysis:getSuitCard(typ,talbet,main_card_arr)

	dump(typ, "getSuitCard2222")
	dump(talbet, "getSuitCard2222")
	dump(main_card_arr, "getSuitCard2222")

	local main_card = self:isType(typ, talbet)

	if not main_card or self:fenLei() == false then
		return false
	end

	local cards, main_value = self.GetTypeCardFuncMap[typ](main_card, main_card_arr, talbet)

	if typ ~= CARDTYPE.Bomb and typ ~= CARDTYPE.KingBomb then
		if not cards then cards, main_value = self:getBomb(main_card, main_card_arr) end
	end

	dump(cards, "getSuitCard22222222")

	if typ ~= CARDTYPE.KingBomb then
		if not cards then cards, main_value = self:getKingBomb(main_card, main_card_arr) end
	end

	return cards or false, main_value
end

--获得单张牌
function CardAnalysis:getOne(max_value,main_card)
	if DDZ_HAND_CARD["one_rank"] then
		
		for i = #DDZ_HAND_CARD["one_rank"],1,-1 do
			local value      = DDZ_HAND_CARD["one_rank"][i]
			local real_value = DDZ_HAND_CARD["one_rank"][i][1]
			if real_value>max_value and not main_card[real_value]  then
				return {{value[1],value[2]}},value[1]
			end

		end
	end

	if DDZ_HAND_CARD["double_rank"] then
		for i = #DDZ_HAND_CARD["double_rank"],1,-1  do
			local value      = DDZ_HAND_CARD["double_rank"][i]
			local real_value = DDZ_HAND_CARD["double_rank"][i][1]
			if real_value > max_value and not main_card[real_value] then
				return {{value[1],value[2]}},value[1]
			end
		end
	end
   
	if DDZ_HAND_CARD["three_rank"] then
		for i = #DDZ_HAND_CARD["three_rank"],1,-1  do
			local value      = DDZ_HAND_CARD["three_rank"][i]
			local real_value = DDZ_HAND_CARD["three_rank"][i][1]
            
			if real_value>max_value and not main_card[real_value] then
				return {{value[1],value[2]}},value[1]
			end
		end
	end

	return false
end

--获得对子
function CardAnalysis:getTwo(max_value,main_card)

	-- dump(max_value, "getTwo")
	-- dump(main_card, "getTwo22")
	-- dump(DDZ_HAND_CARD["double_rank"], "getTwo111")

	if DDZ_HAND_CARD["double_rank"] then
		for i = #DDZ_HAND_CARD["double_rank"],2,-2  do

			local real_value = DDZ_HAND_CARD["double_rank"][i][1]
			if real_value > max_value and not main_card[real_value]  then
				return {
				{DDZ_HAND_CARD["double_rank"][i][1],DDZ_HAND_CARD["double_rank"][i][2]},
				{DDZ_HAND_CARD["double_rank"][i-1][1],DDZ_HAND_CARD["double_rank"][i-1][2]}
				}, DDZ_HAND_CARD["double_rank"][i][1] 

			end
		end
	end

	if DDZ_HAND_CARD["three_rank"] then
		for i = #DDZ_HAND_CARD["three_rank"],2,-3  do
			local real_value = DDZ_HAND_CARD["three_rank"][i][1]

			if real_value>max_value and not main_card[real_value]  then
				return {{DDZ_HAND_CARD["three_rank"][i][1],DDZ_HAND_CARD["three_rank"][i][2]},
				{DDZ_HAND_CARD["three_rank"][i-1][1],DDZ_HAND_CARD["three_rank"][i-1][2]}
				},DDZ_HAND_CARD["three_rank"][i][1]
			end

		end
	end

	return false
end

--获得三张
function CardAnalysis:getThree(max_value,main_card)

	if DDZ_HAND_CARD["three_rank"] then
		for i = #DDZ_HAND_CARD["three_rank"],3,-3  do
			local value      = DDZ_HAND_CARD["three_rank"][i]
			local real_value = DDZ_HAND_CARD["three_rank"][i][1]


			if real_value>max_value and not main_card[real_value]  then
				return {{DDZ_HAND_CARD["three_rank"][i][1],DDZ_HAND_CARD["three_rank"][i][2]},{DDZ_HAND_CARD["three_rank"][i-1][1],DDZ_HAND_CARD["three_rank"][i-1][2]},{DDZ_HAND_CARD["three_rank"][i-2][1],DDZ_HAND_CARD["three_rank"][i-2][2]}},DDZ_HAND_CARD["three_rank"][i][1]
			end
		end
	end

	return false
end

--获得顺子
function CardAnalysis:getOneLine(max_value,main_card, tbl)
	local all = {}
	local len = #tbl
    for i = 1,8 do
    	local v = DDZ_HAND_CARD_INDEX_TRANSLATE[i] 
       	if DDZ_HAND_CARD[v] then 
			dump(DDZ_HAND_CARD[v], "获得顺子")
			for key,value in pairs(DDZ_HAND_CARD[v]) do
				if value[1][1] >=3 and   value[1][1] <=14 then
					table.insert(all,{value[1][1],value[1][2]})
				end
			end
       	end
    end

	local mount  = len
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local minValue = max_value - len + 1

	for i = 3, 14 do
		if main_card[i] and main_card[i] > 0 then
			local min = i - len + 1
			--print("min:"..tostring(min))
			if minValue < min then
				minValue = min
			end
		end
	end

	for i = #all,1,-1 do 
		if start == false then
			if all[i][1] > minValue and not main_card[all[i][1] + mount - 1] then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
			else
				start = true
				count = 0
				cards = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
			end
		end

		if count == mount then
			return cards,cards[mount][1]
		end
	end

	return false
end

--获得双顺
function CardAnalysis:getTwoLine(max_value,main_card, tbl)
	local all = {}
	local len = #tbl
    for i = 2,8 do
    	local v = DDZ_HAND_CARD_INDEX_TRANSLATE[i] 
       	if DDZ_HAND_CARD[v] then 
			for key,value in pairs(DDZ_HAND_CARD[v]) do
				if type(value[1]) == "table" then
					if value[1][1] >=3 and   value[1][1] <=14 then
						table.insert(all,{value[1][1],value[1][2]})
						table.insert(all,{value[2][1],value[2][2]})
					end
				end
			end
       	end
    end

	local mount  = len/2
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	for i = #all,2,-2 do 
		if start == false then
			if all[i][1] >max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
			else
				start = true
				count = 0
				cards = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
			end
		end

		if count == mount then
			return cards,cards[#cards][1]
		end
	end

	return false
end

--获得飞机不带
function CardAnalysis:getPlane(max_value,main_card, tbl)
	local all = {}
	local len = #tbl
	if DDZ_HAND_CARD["three"] then
		for key,value in pairs(DDZ_HAND_CARD["three"]) do
			if value[1][1] >=3 and   value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			end
		end
	end

	local mount  = len/3
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	for i =#all, 3,-3 do 
		if start == false then
			if all[i][1] > max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
			else
				start = true
				count = 0
				cards = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
			end
		end

		if count == mount then
			return cards,cards[#cards][1]
		end
	end

	return false
end

--获得飞机带一
function CardAnalysis:getPlaneTakeOne(max_value,main_card, tbl)

	local len = #tbl
	local all = {}

	if DDZ_HAND_CARD["three"] then
		for key,value in pairs(DDZ_HAND_CARD["three"]) do
			if value[1][1] >=3 and   value[1][1] <=14 and len > 4 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			elseif value[1][1] >=3 and   value[1][1] <=15 and len == 4 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			end
		end
	end

	local mount  = len/4
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local del_array = {}
	local main
	local flag = 0

	for i = #all,3,-3 do 
		if start == false then
			if all[i][1] > max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			else
				start = false
				count = 0
				cards = {}
				del_array = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			end
		end

		if count == mount then
			flag =  1 
			main =  cards[#cards][1]
			break
		end
	end

	local one_mout = 0
	if flag== 1 then
		for i=#DDZ_HAND_CARD["one_rank"],1,-1 do 

			if(del_array[DDZ_HAND_CARD["one_rank"][i][1]] ~= 1 ) then
	
				table.insert(cards,{DDZ_HAND_CARD["one_rank"][i][1],DDZ_HAND_CARD["one_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end

		for i=#DDZ_HAND_CARD["double_rank"],1,-1 do 
			if(del_array[DDZ_HAND_CARD["double_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{DDZ_HAND_CARD["double_rank"][i][1],DDZ_HAND_CARD["double_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end

		for i=#DDZ_HAND_CARD["three_rank"],1,-1 do 
			if(del_array[DDZ_HAND_CARD["three_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{DDZ_HAND_CARD["three_rank"][i][1],DDZ_HAND_CARD["three_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end
	end

	return false
end

--获得飞机带二
function CardAnalysis:getPlaneTakeTwo(max_value,main_card, tbl)
	local len = #tbl
	local all = {}

	if DDZ_HAND_CARD["three"] then
		for key,value in pairs(DDZ_HAND_CARD["three"]) do
			if value[1][1] >=3 and   value[1][1] <=14 and len>5 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			elseif value[1][1] >=3 and   value[1][1] <=15 and len==5 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			end
		end
	end

	local mount  = len/5
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local flag  = 0
	local main
	local del_array = {}

	for i = #all,3,-3 do 
		if start == false then
			if all[i][1] > max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			else
				start = false
				count = 0
				cards = {}
				del_array = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			end
		end

		if count == mount then
			flag =  1 
			main =  cards[#cards][1]
			break
		end
	end

	local one_mout = 0
	if flag== 1 then

		if #DDZ_HAND_CARD["one_rank"] >= 2 then
			for i=#DDZ_HAND_CARD["one_rank"],1,-1 do 
				if(del_array[DDZ_HAND_CARD["one_rank"][i][1]] ~= 1 ) then

					table.insert(cards,{DDZ_HAND_CARD["one_rank"][i][1],DDZ_HAND_CARD["one_rank"][i][2]})
					one_mout = one_mout + 1
					if (one_mout == 2*mount ) then
						return cards,main
					end
				end
			end
		end

		for i=#DDZ_HAND_CARD["double_rank"],2,-2 do 
			if(del_array[DDZ_HAND_CARD["double_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{DDZ_HAND_CARD["double_rank"][i][1],DDZ_HAND_CARD["double_rank"][i][2]})
				table.insert(cards,{DDZ_HAND_CARD["double_rank"][i-1][1],DDZ_HAND_CARD["double_rank"][i-1][2]})
				one_mout = one_mout + 2
				if (one_mout == 2*mount ) then
					return cards,main
				end
			end
		end

		for i=#DDZ_HAND_CARD["three_rank"],3,-3 do 
			if(del_array[DDZ_HAND_CARD["three_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{DDZ_HAND_CARD["three_rank"][i][1],DDZ_HAND_CARD["three_rank"][i][2]})
				table.insert(cards,{DDZ_HAND_CARD["three_rank"][i-1][1],DDZ_HAND_CARD["three_rank"][i-1][2]})
				one_mout = one_mout + 2
				if (one_mout == 2*mount ) then
					return cards,main
				end
			end
		end
	end

	return false
end

--获得炸弹
function CardAnalysis:getKingBomb(main_value,main_card, tbl)

	if 	(DDZ_HAND_CARD["double"][16] and DDZ_HAND_CARD["double"][17]) and
		(#DDZ_HAND_CARD["double"][16] == 2 and #DDZ_HAND_CARD["double"][17] == 2) then
		return {{16 ,4},{16 ,4},{17 ,4},{17,4}}, 16  --4张鬼牌
	end

end

--获得炸弹
function CardAnalysis:getBomb(main_value,main_card, tbl)

	local big_boom  = 0
    local last_cards = tbl or {}
    	
    local kingCards = {}
    if DDZ_HAND_CARD["double"][16] then 
    	table.insert(kingCards, {16 ,4})
    	table.insert(kingCards, {16 ,4})
    elseif DDZ_HAND_CARD["double"][17] then 
    	table.insert(kingCards, {17 ,4})
    	table.insert(kingCards, {17 ,4})
    elseif DDZ_HAND_CARD["one"][16] then 
    	table.insert(kingCards, {16 ,4})
    elseif DDZ_HAND_CARD["one"][17] then 
    	table.insert(kingCards, {17 ,4})
    end

    for k = 4,8 do
    	--k（炸弹的牌数，如6牌炸弹）
    	local boomQueue = DDZ_HAND_CARD[DDZ_HAND_CARD_INDEX[k]]
		if boomQueue then


			for i = #boomQueue,k,-k  do
       	         
				local cards      = boomQueue[i]
				local real_value = boomQueue[i][1]
              	
				dump(boomQueue, "getBombgetBombgetBomb", real_value)

				if  k + #kingCards > #last_cards
					or (k + #kingCards == #last_cards and real_value > main_value) then 
					local tmp = {}

					local lessNum = (k + #kingCards > #last_cards and real_value <= main_value) and #last_cards - k + 1 or #last_cards - k

					for i = 1, lessNum do
						table.insert(tmp, kingCards[i])
					end

					for cardNum = 1,k do
						local card = 
						{boomQueue[i + 1 - cardNum][1],  --牌值
						boomQueue[i + 1 - cardNum][2]}   --花色
						table.insert(tmp,card)
					end
					return tmp,real_value
				end
			end
		end
	end

	return false
end

local sortRankTable = function(a,b)
	local aweight = (a[2] == 4 and 100 or 0) + a[1]
	local bweight = (b[2] == 4 and 100 or 0) + b[1]

    if aweight == bweight then
        return a[2] > b[2]
    else
        return aweight > bweight
    end
end

--将用户的牌排序
function CardAnalysis:sortCard(handcards)

    handcards = handcards or USER_INFO["cards"]
    if handcards == nil then
        return
    end

    table.sort(handcards, sortRankTable)
end

--得到玩家按同类分类的牌型数组
function CardAnalysis:fenLei()

	local handCards = USER_INFO["cards"]
	if handCards == nil then
		return false
	end

	local tmp = {}
	self:sortCard()
	local tmp_flag = {}

	--以牌的牌值做索引，将手牌按牌值分类，存入TMP
	for _,Card in pairs(handCards) do 
		local tmp_value = Card[1]
		
		if tmp_flag[Card[1]] ~= 1 then
			tmp[Card[1]]  =  {}
		end
		
		table.insert(tmp[Card[1]], {Card[1],Card[2]})
		tmp_flag[Card[1]] = 1	
	end

	for i,v in pairs(DDZ_HAND_CARD_INDEX_TRANSLATE) do
        DDZ_HAND_CARD[v] = {}
    end

    for i,v in pairs(DDZ_HAND_CARD_INDEX) do
    	DDZ_HAND_CARD[v] = {}
    end

	for key,value in pairs(tmp) do
		local mount = #value
        
        local mount_key = DDZ_HAND_CARD_INDEX_TRANSLATE[mount]  --"one","double"
        local card_key = DDZ_HAND_CARD_INDEX[mount]

		DDZ_HAND_CARD[mount_key][key] = value
		for k,v in pairs(value) do
			table.insert(DDZ_HAND_CARD[card_key],v)   
		end
	end

	for _,newkey in pairs(DDZ_HAND_CARD_INDEX) do
		table.sort(DDZ_HAND_CARD[newkey], sortRankTable)
	end

	return true
end

function CardAnalysis:isOne(talbet)
	if #talbet ~= 1 then
		return false
	end
	return talbet[1][1]
end

--对比牌型
function CardAnalysis:isType(typ,talbet)
	if typ == nil then return false end
	return self.CardTypeCheckFuncMap[typ](talbet) or false 
end

-- 获得牌型(这边的牌型对比顺序只影响执行速度，不影响准确性)
function  CardAnalysis:getType(talbet)

	for _, cardTyp in ipairs(FinalHandValidCardTypeList) do
		local main_card = self:isType(cardTyp, talbet)
		if main_card then
			return cardTyp, main_card, #talbet
		end
	end
end

--是不是对子
function CardAnalysis:isTwo(tbl)
	if #tbl ~= 2 then
		return false
	end

	if tbl[1][1] ~= tbl[2][1] then
		return false
	end
    
    local main_value = tbl[1][1]
    if  main_value == 1 or main_value == 2 then
    	main_value = main_value + 15
    end

	return main_value
end

--是不是3张
function CardAnalysis:isThree(tbl)
    
    local cardsNum = #tbl 
	if cardsNum ~= 3 then
		return false
	end

	if tbl[1][1] ~= tbl[2][1] or tbl[1][1] ~= tbl[3][1] then
		return false
	end

	return tbl[1][1]
end

--是不是3张带一
function CardAnalysis:isThreeTakeOne(tbl)
	if #tbl ~= 4 then
		return false
	end

	local tmp = {}
	for key,value in pairs(tbl) do
		tmp[value[1]] = (tmp[value[1]] or 0) + 1
	end

	for key,value in pairs(tmp) do
		if(value == 3) then
			return key
		end
	end

	return false
end

--是不是3张带2
function CardAnalysis:isThreeTakeTwo(tbl)

	if #tbl ~= 5 then
		return false
	end

	local tmp = {}
	for key,value in pairs(tbl) do
		tmp[value[1]] = (tmp[value[1]] or 0) + 1
	end

	local three_flag  = false
	local main_card   = 0
	local double_flag = false

	for key, value in pairs(tmp) do
		if(value >= 3) then
			three_flag =  true
			main_card = key
		end
	end

	if three_flag then
		return main_card
	end

	return false
end

--是不是单顺子
function CardAnalysis:isOneLine(tbl)
	CardAnalysis:sort(tbl)
    
    local cardsNum = #tbl
	if 	cardsNum < 5 then
		return false
	end

	for i=1,cardsNum do
		if tbl[i][1]>14 or tbl[i][1]<3 then
			return false
		end
	end


	for i=1,cardsNum-1 do 
		if(tbl[i][1] ~= tbl[i+1][1] + 1) then
			return false
		end
	end

	return tbl[1][1],cardsNum
end

--是不是双顺
function CardAnalysis:isTwoLine(tbl)
 
	CardAnalysis:sort(tbl)
	local cardsNum = #tbl
	if 	cardsNum < 4 or tbl[1][1] > 14 or tbl[cardsNum][1] < 3 then
		return false
	end

	local tmp = {}
	local tmp_value =  nil

	local tmp_fixed = {}
    local minValue = tbl[cardsNum][1]
    
	for key,value in ipairs(tbl) do
		tmp_fixed[value[1] - minValue + 1] = (tmp_fixed[value[1] - minValue + 1] or 0) + 1
   	end
    
    dump(tmp_fixed,"tmp_fixed")

    local table_size = 0

    for value,cardNum in pairs(tmp_fixed) do
        table_size = table_size + 1
    	if  cardNum ~= 2 then
    		return false
    	end
    end
  
    if  table_size ~= #tmp_fixed then
    	return false
    end

	return tbl[1][1],cardsNum
end

--是不是飞机不带翅膀
function CardAnalysis:isPlane(tbl)

	CardAnalysis:sort(tbl)
    
    local cardsNum = #tbl
	if cardsNum%3 ~= 0 or cardsNum<6 then
		return false
	end

	if tbl[1] and tbl[1][1] and tbl[cardsNum] and tbl[cardsNum][1] then
    	if  tbl[1][1] > 14 or tbl[cardsNum][1] < 3 then
    		return nil
    	end
	end

	local tmp_fixed = {}
    local minValue = tbl[cardsNum][1]
	for key,value in ipairs(tbl) do
		tmp_fixed[value[1] - minValue + 1] = (tmp_fixed[value[1] - minValue + 1] or 0) + 1
   	end
    
    local table_size = 0

    for value,cardNum in pairs(tmp_fixed) do
          
        table_size = table_size + 1

    	if  cardNum ~= 3 then
    		return false
    	end
    end
  
    if  table_size ~= #tmp_fixed then
    	return false
    end

	return tbl[1][1],cardsNum
end


--是不是飞机带翅膀1
function CardAnalysis:isPlaneTakeOne(tbl)
	CardAnalysis:sort(tbl)
	local cardsNum = #tbl

	if cardsNum%4 ~= 0   then
		return false
	end

	local tmp = {}
	local tmp_value = nil
	local main_card 
	for key,value in pairs(tbl) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
		if tmp[value[1]] > 3 then
			return false
		end

		if tmp[value[1]] == 3 then
			if value[1] >14 or  value[1] <3 then
			 	return false
			end

			if  tmp_value ~= nil then
				if tmp_value -1 ~= value[1] then
					return false
				end
				tmp_value = value[1]
			end

			if  tmp_value == nil then
				tmp_value = value[1]
				main_card = value[1]
			end


		end

		if tmp[value[1]] > 3 then
			return false
		end

	end

	return main_card,cardsNum
end

--是不是飞机带翅膀2
function CardAnalysis:isPlaneTakeTwo(tbl)
	CardAnalysis:sort(tbl)
    
    local cardsNum = #tbl
	if  cardsNum%5 ~= 0   then
		return false
	end

	local tmp = {}
	local tmp_value = nil
	local main_card 

	for key,value in ipairs(tbl) do
		tmp[value[1]] = (tmp[value[1]] or 0) + 1
	end
     
	dump(tmp,"isThreeShunWingTwo_tmp")

	local planeCards = {}
	local minValue = 20
	local maxValue = 0

    for cardValue,cardNum in pairs(tmp) do
       
		if  cardNum >= 3 then

			dump(minValue,"牌值不连续minValue")
			dump(cardValue,"牌值不连续cardValue")

			if  cardValue >14 or  cardValue <3 then   --
				dump("2和大王不能加入连牌")
			 	return false
			 end

			if  cardValue > maxValue then
				maxValue = cardValue
			end

			if  cardValue < minValue then
				minValue = cardValue
			end

			planeCards[cardValue] = true
		end

	end

	local seriesCheckTabled = {}
	local planeCardsSize = 0

	dump(planeCards,"牌值不连续2")

	for cardValue in pairs(planeCards) do
		planeCardsSize = planeCardsSize + 1
		seriesCheckTabled[cardValue- minValue + 1] = true
	end

	if  #seriesCheckTabled ~= planeCardsSize then
		dump(seriesCheckTabled,"牌值不连续")
		return false
	end

	return maxValue,cardsNum
end

--天王炸弹
function CardAnalysis:isKingBomb(tbl)
    
    local cardsNum = #tbl

	if  cardsNum ~= 4 then
		return false 
	end

	local main_card = tbl[1][1]

	for i,Card in pairs(tbl) do
		if Card[2] ~= 4 then --有非双鬼的牌值
			return false 
		end
	end

	return main_card 
end

--是不是炸弹
function CardAnalysis:isBomb(tbl)
    
    local  cardsNum = #tbl
	if cardsNum < 4 then
		return false
	end
      
    local main_card = nil
    local main_cardnum = 0
    local kingcardnum = 0
    
    --遍历表，牌值不全相等就不是炸弹
	for i,Card in pairs(tbl) do
		if Card[2]~= 4 then
			if main_card == nil then
				main_card = Card[1]
				main_cardnum = main_cardnum + 1
			elseif main_card ~= Card[1] then
				print("isBomb", main_card, Card[1])
				return false
			elseif main_card == Card[1] then
				main_cardnum = main_cardnum + 1
			end
		else
			kingcardnum = kingcardnum + 1
		end
	end
    
    dump(main_cardnum, "isBomb")
    if main_cardnum < 4 then 
    	return false 
    end

    return main_card
end

--排序
function  CardAnalysis:sort(tablet)
	table.sort(tablet, sortRankTable)
end

CardAnalysis:init()

return {CardAnalysis, CARDTYPE, LogicValueMap}
