--
-- Author: zzy
-- Date: 2019-6-11 20:11:15
--

local cardLogicNew = class("cardLogicNew")

local SanGongTypeText = {
	[1] = "0点",
	[2] = "1点",
	[3] = "2点",
	[4] = "3点",
	[5] = "4点",
	[6] = "5点",
	[7] = "6点",
	[8] = "7点",
	[9] = "8点",
	[10] = "9点",
	[11] = "三公",
	[12] = "豹子",
	[13] = "豹三",
}

local JinHuaTypeText = {
	[1] = "散牌",    	
	[2] = "对子",		
	[3] = "顺子",		
	[4] = "金花",		
	[5] = "金花顺",		
	[6] = "豹子",		
}

local SanGongType = {
	[1] = 0,      	--0点
	[2] = 0,		--1点
	[3] = 0,		--2点
	[4] = 0,		--3点
	[5] = 0,		--4点
	[6] = 0,		--5点
	[7] = 0,		--6点
	[8] = 0,		--7点
	[9] = 2,		--8点
	[10] = 3,		--9点
	[11] = 4,		--三公
	[12] = 5,		--豹子
	[13] = 9,		--豹三
}

local JinHuaType = {
	[1] = 0,    	--散牌
	[2] = 2,		--对子
	[3] = 3,		--顺子
	[4] = 4,		--金花
	[5] = 5,		--金花顺
	[6] = 6,		--豹子
	
}

--获取花色值(方块、梅花、红桃、黑桃)
function cardLogicNew:getCardColor(_cardValue)
	if not _cardValue or _cardValue < 0 then return 0 end
	return math.modf(_cardValue/16)
end

--获取牌得数值(_gameType:(1:三公  2：金花))
function cardLogicNew:getCardNumByGameType(_gameType,_cardValue)
	if not _cardValue or _cardValue < 0 then return 0 end
	if not _gameType  then return 0 end
	local _tempCardValue = _cardValue%16
	if _gameType == 1 and _tempCardValue == 14 then
		_tempCardValue = 1
	end
	return _tempCardValue
end

function cardLogicNew:CombCard(_index,_begain,len,n,_cardArr,_combArr,_allCardList)
	if _index == (n+1) then
		local tempArr = {}
		for i=1,n do
			table.insert(tempArr,_combArr[i])
		end
		table.insert(_allCardList,tempArr)
		return 
	end

	for i=1,10 do
		print(i)
	end

	for i=_begain,len-n+_index do
		_combArr[_index] = _cardArr[i]
		self:CombCard(_index+1,i+1,len,n,_cardArr,_combArr,_allCardList)
	end
end

--获取所有的牌型组合
function cardLogicNew:getAllCardList( _cardArr )
	local _tempArr = clone(_cardArr)
	local len = 4
	local n = 3
	local _tempCombArr = {}
	local _allCardList = {}

	self:CombCard(1,1,4,3,_tempArr,_tempCombArr,_allCardList)

	return _allCardList
end

function cardLogicNew:testUseTime(func)
	local t1 = os.time();
	for  i =1,10000000  do
	local playerType = math.random(1,4)
	   func()
	end

	local t2 = os.time();
	print(os.difftime(t2, t1),"运行时间");
end

function cardLogicNew:getTypeStringByCardArr( _cardArr )
	local strType_1 = SanGongTypeText[self:getSanGongCardType(_cardArr)] or ""
	local strType_2 = JinHuaTypeText[self:getJinHuaCardType(_cardArr)] or ""

	return strType_1.." "..strType_2
end

--获取三公类型
function cardLogicNew:getSanGongCardType(_cardArr)
	 local cardv1 = self:getCardNumByGameType(1,_cardArr[1])
	 local cardv2 = self:getCardNumByGameType(1,_cardArr[2])
	 local cardv3 = self:getCardNumByGameType(1,_cardArr[3])

	 if cardv1 == cardv2 and cardv1 == cardv3 and cardv1 == 3 then
	 	return 13
	 elseif cardv1 == cardv2 and cardv1 == cardv3 and cardv1 ~= 3 then
	 	return 12
	 elseif cardv1 > 10 and cardv2 > 10 and cardv3 > 10 then
	 	return 11
	 else 
	 	if cardv1 > 10 then cardv1 = 0 end
	 	if cardv2 > 10 then cardv1 = 0 end
	 	if cardv3 > 10 then cardv1 = 0 end
	 	return (cardv1+cardv2+cardv3)%10 + 1
	 end
end

--获取扎金花类型
function cardLogicNew:getJinHuaCardType( _cardArr )
	local _tempCardArr = clone(_cardArr)
	table.sort(_tempCardArr)

	local cardv1 = self:getCardNumByGameType(2,_tempCardArr[1])
	local cardv2 = self:getCardNumByGameType(2,_tempCardArr[2])
	local cardv3 = self:getCardNumByGameType(2,_tempCardArr[3])

	local color1 = self:getCardColor(_tempCardArr[1])
	local color2 = self:getCardColor(_tempCardArr[2])
	local color3 = self:getCardColor(_tempCardArr[3])

	if cardv1 == cardv2 and cardv1 == cardv3 then
		return 6
	elseif color1 == color2 and color1 == color3 then
		if cardv1 == 1 and cardv2 == 12 and cardv3 == 13 then
			return 5
		end
		if (cardv1+ 1) == cardv2 and (cardv2+ 1) == cardv3 then
			return 5
		end
		return 4
	elseif cardv1 == 1 and cardv2 == 12 and cardv3 == 13 then
		return 3
	elseif (cardv1+ 1) == cardv2 and (cardv2+ 1) == cardv3 then
		return 3
	elseif cardv1 == cardv2 or cardv1 == cardv3 then
		return 2
	else
		return 1
	end
end


--获取牌数组中的最大值(按金花数值来算)
function cardLogicNew:getCardMaxValue(_cardArr)
	local tempArr = {}
	local cardv1 = self:getCardNumByGameType(2,_cardArr[1])
	local cardv2 = self:getCardNumByGameType(2,_cardArr[2])
	local cardv3 = self:getCardNumByGameType(2,_cardArr[3])
	table.insert(tempArr,cardv1)
	table.insert(tempArr,cardv2)
	table.insert(tempArr,cardv3)
	return tempArr[3] or 0
end

--add by zzy 2019-6-24 获取最大牌的组合
function cardLogicNew:getMaxCardArr(_cardArr)
	-- local _tempArr = {}
	-- _tempArr.cardList = {}
	-- _tempArr.sortCardList = {}
	-- _tempArr.allBeiShu = 0  --所有的倍数和
	-- _tempArr.maxCardV = 0   --最大的数值（2-A）

	local allList = {}
	
	local _allCardList = {}
	_allCardList = self:getAllCardList(_cardArr)

	for k,v in pairs(_allCardList) do
		local dataCardArr = clone(v)
		table.sort(dataCardArr)

		local sanGongBeiShu = SanGongType[self:getSanGongCardType(v)]
		local JinHuaBeiShu = JinHuaType[self:getJinHuaCardType(v)]

		local _tempArr = {}
		_tempArr.cardList = {}
		_tempArr.sortCardList = {}
		_tempArr.allBeiShu = 0
		_tempArr.maxCardV = 0
		_tempArr.maxColorV = 0

		_tempArr.cardList = v
		_tempArr.sortCardList = dataCardArr
		_tempArr.allBeiShu = (sanGongBeiShu + JinHuaBeiShu) or 0
		_tempArr.maxCardV = self:getCardMaxValue(v)

		_tempArr.maxColorV = self:getCardColor(_tempArr.sortCardList[3] or 0)

		table.insert(allList,_tempArr)
	end

	local ccSort = function(a,b)
		if a.allBeiShu == b.allBeiShu then
			if a.maxCardV == b.maxCardV then
				return a.maxColorV > b.maxColorV
			end
			return a.maxCardV > b.maxCardV
		end
        return a.allBeiShu > b.allBeiShu
    end

   	table.sort(allList,ccSort)
   	return allList[1] or nil
end

return cardLogicNew