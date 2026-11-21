local Color = {
	Diamond = 0, --方块
	Club = 1,    --梅花
	Heart = 2,   --红心
	Spade = 3,   --黑桃
	Joker = 4,   --大小王
}

local CARDTYPE = {
	CT_ERROR 		=	0,   		--牌型错误
	CT_SINGLE		=	1,			--单牌类型
	CT_DOUBLE		=	2,			--对子类型
	CT_THREE		=	3,			--三条类型
	CT_510K_DC		=	4,			--副510K
	CT_510K_SC		=	5,			--正510K
	
	CT_BOMB_4		=	6,			--4炸类型
	CT_BOMB_5		=	7,			--5弹类型
	CT_BOMB_6		=	8,			--6炸类型
	CT_BOMB_7		=	9,			--7炸类型
	CT_BOMB_8		=	10,			--8炸类型
	CT_BOMB_9		=	11,			--9炸类型
	CT_BOMB_10		=	12,			--10炸类型
	CT_BOMB_11		=	13,			--11炸类型
	CT_BOMB_12		=	14,			--12炸类型
	CT_BOMB_13		=	15,			--13炸类型
	CT_BOMB_14		=	16,			--14炸类型
	CT_BOMB_15		=	17,			--15炸类型
	CT_BOMB_16		=	18,			--16炸类型
	
	CT_BOMB_TW4		=	19,			--4天王炸弹
	CT_BOMB_TW6		=	20,			--6天王炸弹
}

local CmpRes = {
	Error = -1,
	Lose = 0,
	Draw = 1,
	Win = 2,
}


--值转逻辑值
local LogicValueMap = {
	[0x01] = 14,
	[0x11] = 14,
	[0x21] = 14,
	[0x31] = 14,
	[0x4e] = 16,
	[0x4f] = 17,

	[0x02] = 15,
	[0x12] = 15,
	[0x22] = 15,
	[0x32] = 15,
}
--逻辑值转值
local ValueMap = {
	[14] = 0x01,
	[15] = 0x02,
	[16] = 0x0e,
	[17] = 0x0f,
}

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

function CardAnalysis:AnalyseMagicData(cards)
	local tagMagicResult = {cbMagicCardCount = 0, cbNormalCardCount = 0, cbMagicCard = {}, cbNormalCard = {}}
	if (#cards <= 0) then
		return tagMagicResult
	end
	for i = 1, #cards do
		if cards[i][2] == 4 then
			tagMagicResult.cbMagicCardCount = tagMagicResult.cbMagicCardCount + 1
			tagMagicResult.cbMagicCard[ tagMagicResult.cbMagicCardCount ] = cards[i]
		else
			tagMagicResult.cbNormalCardCount = tagMagicResult.cbNormalCardCount + 1
			tagMagicResult.cbNormalCard[ tagMagicResult.cbNormalCardCount ] = cards[i]
		end
	end
	table.sort(tagMagicResult.cbNormalCard, function(a, b) return a[1] < b[1] end)
	table.sort(tagMagicResult.cbMagicCard, function(a, b) return a[1] < b[1] end)
	return tagMagicResult
end

function CardAnalysis:GetNormalType(cards)
	local cbCardCount = #cards
	if cbCardCount == 0 then
		return CARDTYPE.CT_ERROR
	elseif cbCardCount == 1 then
		return CARDTYPE.CT_SINGLE
	elseif cbCardCount == 2 then
		if cards[1][1] == cards[2][1] then
			return CARDTYPE.CT_DOUBLE
		else
			--王不当赖子时算对
			if cards[1][2] == 4 and cards[2][2] == 4 then
				return CARDTYPE.CT_DOUBLE
			end
		end
		return CARDTYPE.CT_ERROR
	elseif cbCardCount == 3 then
		if cards[1][1] == cards[3][1]  then
			return CARDTYPE.CT_THREE
		elseif 5 == cards[1][1] and 10 == cards[2][1] and 13 == cards[3][1] then
			if cards[1][2] == cards[2][2] and cards[1][2] == cards[3][2] then
				return CARDTYPE.CT_510K_SC
			else
				return CARDTYPE.CT_510K_DC
			end
		end
		return CARDTYPE.CT_ERROR
	elseif cbCardCount == 4 then
		if cards[1][1] == cards[4][1] then
			return CARDTYPE.CT_BOMB_4
		else
			if cards[1][2] == 4 and cards[2][2] == 4 and cards[3][2] == 4 and cards[4][2] == 4 then
				return CARDTYPE.CT_BOMB_TW4
			end
		end
		return CARDTYPE.CT_ERROR
	elseif cbCardCount == 6 then
		if cards[1][1] == cards[5][1] then
			return CARDTYPE.CT_BOMB_6
		else
			local isTW6 = true
			for i=1, 6 do
				if cards[i][2] ~=4 then
					isTW6 = false
					break
				end
			end
			if isTW6 then
				return CARDTYPE.CT_BOMB_TW6
			end
		end
		return CARDTYPE.CT_ERROR
	else
		if cards[1][1] == cards[cbCardCount][1] then
			return CARDTYPE.CT_BOMB_4 + (cbCardCount - 4)
		end
	end
	return CARDTYPE.CT_ERROR
end

function CardAnalysis:getType(MagicResult)
	--local MagicResult = self:AnalyseMagicData(cards)
	--只有赖子牌的时候
	if MagicResult.cbNormalCardCount == 0 then
		if MagicResult.cbMagicCardCount >= 1 and MagicResult.cbMagicCardCount <= 3 then
			return CARDTYPE.CT_SINGLE + MagicResult.cbMagicCardCount - 1
		elseif MagicResult.cbMagicCardCount == 4 then
			return CARDTYPE.CT_BOMB_TW4
		elseif MagicResult.cbMagicCardCount == 6 then
			return CARDTYPE.CT_BOMB_TW6
		elseif MagicResult.cbMagicCardCount == 5 then
			return CARDTYPE.CT_BOMB_5
		end
		return CARDTYPE.CT_ERROR
	end
	local cbType = self:GetNormalType(MagicResult.cbNormalCard)
	--无赖子
	if 0 == MagicResult.cbMagicCardCount then
		return cbType
	end
	--510K与赖子不能组合
	if CARDTYPE.CT_510K_DC == cbType or CARDTYPE.CT_510K_SC == cbType then
		return CARDTYPE.CT_ERROR
	end

	if CARDTYPE.CT_ERROR == cbType then
		--普通牌为ERROR要考虑赖子合成510K
		if 2 == MagicResult.cbNormalCardCount and 1 == MagicResult.cbMagicCardCount then
			if (MagicResult.cbNormalCard[1][1] == 5 and MagicResult.cbNormalCard[2][1] == 10) or (MagicResult.cbNormalCard[1][1] == 5 and MagicResult.cbNormalCard[2][1] == 13) or (MagicResult.cbNormalCard[1][1] == 10 and MagicResult.cbNormalCard[2][1] == 13) then
				if MagicResult.cbNormalCard[1][2] == MagicResult.cbNormalCard[2][2] then
					return CARDTYPE.CT_510K_SC
				else
					return CARDTYPE.CT_510K_DC
				end
			end
		end
	--普通牌为单牌要考虑赖子合成对子、三条、510K以及炸弹
	elseif CARDTYPE.CT_SINGLE == cbType then
		if 1 == MagicResult.cbMagicCardCount then
			return CARDTYPE.CT_DOUBLE
		elseif 2 == MagicResult.cbMagicCardCount then
			local cbValue = MagicResult.cbNormalCard[1][1]
			if 5 == cbValue or 10 == cbValue or 13 == cbValue then
				return CARDTYPE.CT_510K_SC
			else
				return CARDTYPE.CT_THREE
			end
		else
			return CARDTYPE.CT_BOMB_4 + MagicResult.cbMagicCardCount - 3
		end
	--普通牌为对子要考虑赖子合成三条及炸弹
	elseif CARDTYPE.CT_DOUBLE == cbType then
		if 1 == MagicResult.cbMagicCardCount then
			return CARDTYPE.CT_THREE
		else
			return CARDTYPE.CT_BOMB_4 + MagicResult.cbMagicCardCount - 2
		end
	--普通牌为三条要考虑赖子合成炸弹
	elseif CARDTYPE.CT_THREE == cbType then
		return CARDTYPE.CT_BOMB_4 + MagicResult.cbMagicCardCount - 1
	--其他都是4炸以上与赖子合成更高的炸弹
	else
		return cbType + MagicResult.cbMagicCardCount
	end

	return CARDTYPE.CT_ERROR
end

function CardAnalysis:IsSpeType(MagicResult)
	local cbRetType = CARDTYPE.CT_ERROR
	if not MagicResult.cbNormalCard[1] or 3 ~= MagicResult.cbNormalCard[1][1] then
		return false, cbRetType
	end
	--6个三相当于8个三，加一个王相当于9个三，6个三必须由8个四以上的牌才能大过
	local cbType = self:GetNormalType(MagicResult.cbNormalCard)
	if cbType >= CARDTYPE.CT_BOMB_6 then
		cbRetType = cbType
		return true, cbRetType
	end
	return false, cbRetType
end

function CardAnalysis:CompareCard(MagicResultLeft, MagicResultRight)
	local cbLeftType = self:getType(MagicResultLeft)
	local cbRightType = self:getType(MagicResultRight)
	
	if CARDTYPE.CT_ERROR == cbLeftType or CARDTYPE.CT_ERROR == cbRightType then
		return false
	end
	
	--特殊牌处理(为true表示6个王的玩法也就是用m_cbCardDataSpe牌的玩法)
	if _G.XinYu510KRoomInfo and XinYu510KRoomInfo.cardtype ~= 1 then
		local bIsSpeLeft, cbSpeTypeLeft = self:IsSpeType(MagicResultLeft)
		local bIsSpeRight, cbSpeTypeRight = self:IsSpeType(MagicResultRight)
		if bIsSpeLeft then
			cbLeftType = cbSpeTypeLeft + 2 + MagicResultLeft.cbMagicCardCount
		end
		if bIsSpeRight then
			cbRightType = cbSpeTypeRight + 2 + MagicResultRight.cbMagicCardCount;
		end
	end
	if cbLeftType >= CARDTYPE.CT_510K_DC and cbLeftType > cbRightType then
		return true
	elseif cbLeftType == cbRightType then
		if CT_510K_DC == cbLeftType or CT_510K_SC == cbLeftType then
			return false
		end
		
		--只出赖子牌不允许
		if MagicResultLeft.cbNormalCardCount == 0 then
			return false
		end

		--牌型相同，要注意区分只有赖子牌的情况
		local cbCardLeft = 0
		local cbCardRight = 0
		if MagicResultLeft.cbNormalCardCount > 0 then
			cbCardLeft = MagicResultLeft.cbNormalCard[1][1]
		else
			cbCardLeft = MagicResultLeft.cbMagicCard[1][1]
		end
		if MagicResultRight.cbNormalCardCount > 0 then
			cbCardRight = MagicResultRight.cbNormalCard[1][1]
		else
			cbCardRight = MagicResultRight.cbMagicCard[1][1]
		end
		if cbCardLeft > cbCardRight then
			return true
		end
	else
		return false
	end
	return false
end

function CardAnalysis:IsCallAssCard(cbCardData, cbCallAssCard)
	local cbHasCardCount = {}
	for i = 1, #cbCardData do
		if cbCardData[i] ~= 0x4e and cbCardData[i] ~= 0x4f then
			if cbHasCardCount[cbCardData[i]] then
				cbHasCardCount[cbCardData[i]] = cbHasCardCount[cbCardData[i]] + 1
			else
				cbHasCardCount[cbCardData[i]] = 1
			end
		end
	end
	if cbHasCardCount[cbCallAssCard] == 1 then
		return true
	end
	return false
end

--分析牌
function CardAnalysis:AnalysebCardData(cbCardData)
	local AnalyseResult = {cbBlockCount={}, cbCardData={}}
	--lua 循环里不能改变控制变量的值，只能使用这种方式处理
	local ii = 0
	local f = function()
		ii = ii + 1
		return ii
	end
	for i in f do
		if ii > #cbCardData then
			break
		end
		
		local cbSameCount = 1
		local cbLogicValue = cbCardData[i][1]
		
		for j=i+1, #cbCardData do
			if cbCardData[j][1] ~= cbLogicValue then
				break
			end
			cbSameCount = cbSameCount + 1
		end
		AnalyseResult.cbCardData[cbSameCount] = AnalyseResult.cbCardData[cbSameCount] or {}
		AnalyseResult.cbBlockCount[cbSameCount] = AnalyseResult.cbBlockCount[cbSameCount] or 0
		local cbIndex = AnalyseResult.cbBlockCount[cbSameCount]
		AnalyseResult.cbBlockCount[cbSameCount] = AnalyseResult.cbBlockCount[cbSameCount] + 1
		print(cbSameCount, cbIndex, i)
		for j=1, cbSameCount do
			AnalyseResult.cbCardData[cbSameCount][cbIndex*cbSameCount + j] = cbCardData[i+j-1]
		end
		ii = ii + (cbSameCount - 1)
	end
	return AnalyseResult
end

function CardAnalysis:GetTipCard()
	local tipCards = {}
	local handCardCount = #USER_INFO["cards"]
	if not tbPlayCardInfo or handCardCount == 0 then
		return tipCards
	end
	local tagMagicResult = CardAnalysis:AnalyseMagicData(USER_INFO["cards"])
	local AnalyseResult = CardAnalysis:AnalysebCardData(tagMagicResult.cbNormalCard)
	--print('tbPlayCardInfo.card_type',tbPlayCardInfo.card_type)
	--dump(tagMagicResult,'tagMagicResult')
	--dump(AnalyseResult,'AnalyseResult')
	--主动出牌
	if not tbPlayCardInfo.card_type or tbPlayCardInfo.card_type == CARDTYPE.CT_ERROR then
		--dump(AnalyseResult)
		--从单牌、对子、三条、炸弹依次判断
		for i=1, 8 do
			if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
				for j=1, i do
					tipCards[j] = AnalyseResult.cbCardData[i][j]
				end
				return tipCards
			end
		end
		--没有普通牌，处理赖子
		if (tagMagicResult.cbMagicCardCount > 0) then
			tipCards[1] = tagMagicResult.cbMagicCard[0]
			return tipCards
		end
	--被动出牌
	elseif tbPlayCardInfo["last_cards"] then
		local turnCardValue = 0
		if tbPlayCardInfo["last_cards"].cbNormalCardCount > 0 then
			turnCardValue = tbPlayCardInfo["last_cards"].cbNormalCard[1][1]
		else
			turnCardValue = 17
		end
		if tbPlayCardInfo.card_type == CARDTYPE.CT_SINGLE then
			if AnalyseResult.cbBlockCount[1] and AnalyseResult.cbBlockCount[1] > 0 then
				for i=1, AnalyseResult.cbBlockCount[1] do
					if AnalyseResult.cbCardData[1][i][1] > turnCardValue then
						tipCards[1] = AnalyseResult.cbCardData[1][i]
						return tipCards
					end
				end
			end
		elseif tbPlayCardInfo.card_type == CARDTYPE.CT_DOUBLE then
			if AnalyseResult.cbBlockCount[2] and AnalyseResult.cbBlockCount[2] > 0 then
				for i=1, AnalyseResult.cbBlockCount[2] do
					if AnalyseResult.cbCardData[2][(i-1)*2+1][1] > turnCardValue then
						tipCards[1] = AnalyseResult.cbCardData[2][(i-1)*2+1]
						tipCards[2] = AnalyseResult.cbCardData[2][(i-1)*2+2]
						return tipCards
					end
				end
			end
		elseif tbPlayCardInfo.card_type == CARDTYPE.CT_THREE then
			if AnalyseResult.cbBlockCount[3] and AnalyseResult.cbBlockCount[3] > 0 then
				for i=1, AnalyseResult.cbBlockCount[3] do
					if AnalyseResult.cbCardData[3][(i-1)*3+1][1] > turnCardValue then
						tipCards[1] = AnalyseResult.cbCardData[3][(i-1)*3+1]
						tipCards[2] = AnalyseResult.cbCardData[3][(i-1)*3+2]
						tipCards[3] = AnalyseResult.cbCardData[3][(i-1)*3+3]
						return tipCards
					end
				end
			end
		elseif tbPlayCardInfo.card_type == CARDTYPE.CT_510K_DC or tbPlayCardInfo.card_type == CARDTYPE.CT_510K_SC then
			--从4炸弹依次判断
			for i=4, 8 do
				if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
					for j=1, i do
						tipCards[j] = AnalyseResult.cbCardData[i][j]
					end
					return tipCards
				end
			end
		else
			--从4炸弹依次判断
			for i=tbPlayCardInfo.card_type-CARDTYPE.CT_BOMB_4+4, 8 do
				if i == (tbPlayCardInfo.card_type-CARDTYPE.CT_BOMB_4+4) then
					if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
						for j=1, AnalyseResult.cbBlockCount[i] do
							if AnalyseResult.cbCardData[i][(j-1)*i+1][1] > turnCardValue then
								for k = 1, i do
									tipCards[k] = AnalyseResult.cbCardData[i][(j-1)*i+k]
								end
								return tipCards
							end
						end
					end
				else
					if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
						for j=1, i do
							tipCards[j] = AnalyseResult.cbCardData[i][j]
						end
						return tipCards
					end
				end
			end
		end
		print('----x1--- ',tbPlayCardInfo.card_type)
		--炸弹以下用炸弹打
		if tbPlayCardInfo.card_type < CARDTYPE.CT_BOMB_4 then
			for i=4, 8 do
				if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
					for j=1, i do
						tipCards[j] = AnalyseResult.cbCardData[i][j]
					end
					return tipCards
				end
			end
		end
		print('----x2--- ',tbPlayCardInfo.card_type)
		--510K以下可以出510K
		if tbPlayCardInfo.card_type < CARDTYPE.CT_510K_DC then
			local tempT = {}
			local n = 0
			for _, v in ipairs(tagMagicResult.cbNormalCard) do
				if v[1] == 5 and not tempT[5] then
					tempT[5] = v
					n = n + 1
				elseif v[1] == 10 and not tempT[10] then
					tempT[10] = v
					n = n + 1
				elseif v[1] == 13 and not tempT[13] then
					tempT[13] = v
					n = n + 1
				end
			end
			
			if n > 0 then
				if n == 3 then
					for _, v in pairs(tempT) do
						tipCards[ #tipCards + 1 ] = v
					end
					return tipCards
				else
					if tagMagicResult.cbMagicCardCount >= (3-n) then
						for _, v in pairs(tempT) do
							tipCards[ #tipCards + 1 ] = v
						end
						for i=1, (3-n) do
							tipCards[ #tipCards + 1 ] = tagMagicResult.cbMagicCard[i]
						end
						return tipCards
					end
				end
			end
			
			if tbPlayCardInfo.card_type == CARDTYPE.CT_SINGLE then
				--单牌考虑从对子、三条里拆牌打
				if AnalyseResult.cbBlockCount[2] and AnalyseResult.cbBlockCount[2] > 0 then
					for i=1, AnalyseResult.cbBlockCount[2] do
						if AnalyseResult.cbCardData[2][(i-1)*2+1][1] > turnCardValue then
							tipCards[1] = AnalyseResult.cbCardData[2][(i-1)*2+1]
							return tipCards
						end
					end
				end
				if AnalyseResult.cbBlockCount[3] and AnalyseResult.cbBlockCount[3] > 0 then
					for i=1, AnalyseResult.cbBlockCount[3] do
						if AnalyseResult.cbCardData[3][(i-1)*3+1][1] > turnCardValue then
							tipCards[1] = AnalyseResult.cbCardData[3][(i-1)*3+1]
							return tipCards
						end
					end
				end
			elseif tbPlayCardInfo.card_type == CARDTYPE.CT_DOUBLE then
				--对子考虑从三条里拆牌打
				if AnalyseResult.cbBlockCount[3] and AnalyseResult.cbBlockCount[3] > 0 then
					for i=1, AnalyseResult.cbBlockCount[3] do
						if AnalyseResult.cbCardData[3][(i-1)*3+1][1] > turnCardValue then
							tipCards[1] = AnalyseResult.cbCardData[3][(i-1)*3+1]
							tipCards[2] = AnalyseResult.cbCardData[3][(i-1)*3+2]
							return tipCards
						end
					end
				end
				--对子考虑从单牌里加个赖子合成对子
				if tagMagicResult.cbMagicCardCount > 0 then
					if AnalyseResult.cbBlockCount[1] and AnalyseResult.cbBlockCount[1] > 0 then
						for i=1, AnalyseResult.cbBlockCount[1] do
							if AnalyseResult.cbCardData[1][i][1] > turnCardValue then
								tipCards[1] = tagMagicResult.cbMagicCard[1]
								tipCards[2] = AnalyseResult.cbCardData[1][i]
								return tipCards
							end
						end
					end
				end
			elseif tbPlayCardInfo.card_type == CARDTYPE.CT_THREE then
				--三个考虑从单牌里加两个赖子合成，或者从对子里合一个赖子
				if tagMagicResult.cbMagicCardCount >= 2 then
					if AnalyseResult.cbBlockCount[1] and AnalyseResult.cbBlockCount[1] > 0 then
						for i=1, AnalyseResult.cbBlockCount[1] do
							if AnalyseResult.cbCardData[1][i][1] > turnCardValue then
								tipCards[1] = tagMagicResult.cbMagicCard[1]
								tipCards[2] = tagMagicResult.cbMagicCard[2]
								tipCards[3] = AnalyseResult.cbCardData[1][i]
								return tipCards
							end
						end
					end
				elseif tagMagicResult.cbMagicCardCount >= 1 then
					if AnalyseResult.cbBlockCount[2] and AnalyseResult.cbBlockCount[2] > 0 then
						for i=1, AnalyseResult.cbBlockCount[2] do
							if AnalyseResult.cbCardData[2][(i-1)*2+1][1] > turnCardValue then
								tipCards[1] = tagMagicResult.cbMagicCard[1]
								tipCards[2] = AnalyseResult.cbCardData[2][(i-1)*2+1]
								tipCards[3] = AnalyseResult.cbCardData[2][(i-1)*2+2]
								return tipCards
							end
						end
					end
				end
			end
		end
		print('----x3--- ',tbPlayCardInfo.card_type)
		--最后判断赖子能不能合成出的牌
		if tagMagicResult.cbMagicCardCount > 0 then
			for i=8, 3, -1 do
				if AnalyseResult.cbBlockCount[i] and AnalyseResult.cbBlockCount[i] > 0 then
					local temptype = CARDTYPE.CT_BOMB_4 + (i-4) + tagMagicResult.cbMagicCardCount
					print('-------------x-------',temptype,tbPlayCardInfo.card_type,AnalyseResult.cbBlockCount[i],i,turnCardValue)
					if temptype > tbPlayCardInfo.card_type then
						for j=1, AnalyseResult.cbBlockCount[i] do
							--if AnalyseResult.cbCardData[i][(j-1)*i+1][1] > turnCardValue then
								for k = 1, tagMagicResult.cbMagicCardCount do
									tipCards[#tipCards + 1] = tagMagicResult.cbMagicCard[k]
								end
								for k = 1, i do
									tipCards[#tipCards + 1] = AnalyseResult.cbCardData[i][(j-1)*i+k]
								end
								return tipCards
							--end
						end
					elseif temptype == tbPlayCardInfo.card_type then
						for j=1, AnalyseResult.cbBlockCount[i] do
							if AnalyseResult.cbCardData[i][(j-1)*i+1][1] > turnCardValue then
								for k = 1, tagMagicResult.cbMagicCardCount do
									tipCards[#tipCards + 1] = tagMagicResult.cbMagicCard[k]
								end
								for k = 1, i do
									tipCards[#tipCards + 1] = AnalyseResult.cbCardData[i][(j-1)*i+k]
								end
								return tipCards
							end
						end
					end
				end
			end
		end
		
	end
	return tipCards
end

--[1]是牌值，[2]是花色
function CardAnalysis:init()
end

function CardAnalysis:belongtoBoomType(card_type)
	
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

return {CardAnalysis, CARDTYPE, LogicValueMap, ValueMap}
