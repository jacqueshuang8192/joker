
local CardLogic = class("CardLogic")

--排序
function CardLogic:sort(tablet)
	table.sort(tablet,function(a,b)
	    local value_a =bit.band(a,0x0F) 
	    local color_a =bit.band(a,0xF0)

	    local value_b =bit.band(b,0x0F) 
	    local color_b =bit.band(b,0xF0)

        if(color_a  == 4 and color_b == 4) then
            return value_a > value_b
        end

        if(color_a == 4 and color_b ~= 4) then
            return true
        end

        if(color_a ~= 4 and color_b == 4) then
            return false
        end

        if(color_a ~= 4 and color_b ~= 4) then
            return value_a > value_b
        end
    end)
end


function GetCardLogicValue(bCardData)

    local bCardColor=bit.band(bCardData,0xF0)
    local bCardValue=bit.band(bCardData,0x0F)

	--dump1(bCardColor,"bCardColor")
	--dump1(bCardValue,"bCardValue")

    if (bCardColor==0x40) then
        return bCardValue+15;

    elseif bCardValue<=2 and bCardValue>0 then 
        return bCardValue+13
    else 
        return bCardValue
    end   
end

function CardLogic:AnalysebCardDatafortrailer(bCardData,bCardCount)
    
    local BombMap = {}

	local SameCardArray ={}
    
    for i = 0,15 do
	    SameCardArray[i] = 0
	end
   
	--扑克分析
	for i = 0,bCardCount-1 do
		--获取扑克

		local  bCardValueTemp = GetCardLogicValue(bCardData[i]);

		--dump1(bCardValueTemp,"bCardValueTemp")

		if(bCardValueTemp > 2 and bCardValueTemp < 16) then
			SameCardArray[bCardValueTemp] = (SameCardArray[bCardValueTemp] or 0) + 1
		end
	end

	for cardValue = 3,15 do
		BombMap[cardValue] = 0
		if (SameCardArray[cardValue] >= 4) then 
			BombMap[cardValue] = SameCardArray[cardValue]
		end
	end

	return BombMap
end


function CardLogic:GetBonusCardType(bCardData,bCardCount)
    
    local bonus_card_array = {}

	self:sort(bCardData)

	local bonus_score = 0

	local BombMap = self:AnalysebCardDatafortrailer(bCardData, bCardCount)
    
  --dump1(BombMap,"BombMap")
	local BombCount = 0;
	for cardValue = 3,15 do
		if  BombMap[cardValue] and BombMap[cardValue] >= 4 then
			BombCount = BombCount + 1
		end
	end

	--天王炸弹2分
	if bonus_array[10] > 0 then
		if ((bCardData[0] == 0x4F) and (bCardData[1] == 0x4F) and (bCardData[2] == 0x4E) and (bCardData[3] == 0x4E)) then
			bonus_score = bonus_score + bonus_array[10];

			bonus_card_array[GetCardLogicValue(0x4F)] = 2;
			bonus_card_array[GetCardLogicValue(0x4E)] = 2;
			BombCount = BombCount + 1
		end
	end

	if bonus_array[11] > 0 then
		if (bCardCount == 25 and BombCount > 3)  then--农民四副炸弹
			--起手已经算过这里的分了
			for cardValue = 3,15 do

				if  BombMap[cardValue] >= 4 then
					bonus_card_array[cardValue] = BombMap[cardValue];
				end

			end

		elseif (bCardCount == 33 and BombCount > 5)  then--地主六副炸弹
			bonus_score = bonus_score + bonus_array[11] * (BombCount - 5);

			for cardValue = 3,15 do
				if (BombMap[cardValue] >= 4) then
					bonus_card_array[cardValue] = BombMap[cardValue];
				end
			end
		end
	end

	if (bCardCount == 33 and BombCount == 0 and bonus_array[12] > 0) then   --地主无炸弹，明牌，结束游戏
		return 999;
	end

	local continueTimesArray = {}
	for i=0,8 do
       continueTimesArray[i] = 0
	end
	--key = SameCardCount 牌的重复次数 ,value = continue次数 比如444455556666，55556666已被计进拖车连次里去，则需要跳过后面的这些牌
	
	for cardValue = 3,15 do

		while true do

			if BombMap[cardValue] and BombMap[cardValue] > 0 then
	        
				local SameCardCount = BombMap[cardValue]
                 
				if (continueTimesArray[SameCardCount] > 0) then
					continueTimesArray[SameCardCount] = continueTimesArray[SameCardCount] - 1
                	
					break
				end

				if SameCardCount == 8 then

						local series = 1;
						bonus_card_array[cardValue] = SameCardCount;
						for j = 1,4 do
							if ((cardValue + j) >= 15) then 
								--dump1(continueTimesArray,"continueTimesArray")
								continueTimesArray[SameCardCount] = series - 1; 
								break 
							end

							if (BombMap[cardValue + j] == SameCardCount) then
								bonus_card_array[cardValue + j] = SameCardCount;
								series = series + 1
							else
								continueTimesArray[8] = series - 1;
								break
							end
						end

	                    local all_series_count = series + borrow_series + back_series
						if all_series_count == 1 then
							bonus_score = bonus_score + bonus_array[8];
						elseif all_series_count == 2 then
							bonus_score = bonus_score + bonus_array[9];
						elseif all_series_count == 3 then
							bonus_score = bonus_score + bonus_array[9] + 12
						elseif all_series_count == 4 then
							bonus_score = bonus_score + bonus_array[9] + 24
						end

				elseif SameCardCount == 7 then

						local series = 1;
						local borrow_series = 0;
						local back_series = 0;  --向前面张数更多的炸弹借牌凑拖车

						for j = 1,4 do
							if ((cardValue + j) >= 15) then 
								continueTimesArray[SameCardCount] = series - 1; 
								break 
							end

							if (BombMap[cardValue + j] == SameCardCount) then
								series = series + 1
							elseif BombMap[cardValue + j] and (BombMap[cardValue + j] > SameCardCount) then
								borrow_series = borrow_series  + 1
							else
								continueTimesArray[7] = series - 1
								break;
							end
						end

						if (cardValue < 15) then
							for j = -1,-4,-1 do
								if BombMap[cardValue + j] and BombMap[cardValue + j] > SameCardCount then
								 	back_series = back_series + 1
								else break;
								end
							end
						end
                         
                        local total_series = series + borrow_series + back_series
						if (total_series > 1 and bonus_array[6] == 0) or bonus_array[6] > 0 then
							for k = cardValue - back_series,cardValue + borrow_series + series -1 do
								--奖励牌型列表里没有，或者之前的张数较少
								if (bonus_card_array[k] == nil or bonus_card_array[k] < SameCardCount) then
									bonus_card_array[k] = SameCardCount
								end
							end
						end

						if total_series == 1 then
							if (bonus_array[6] > 0) then
								bonus_score = bonus_score + bonus_array[6];
							end
						elseif total_series == 2 then
							bonus_score = bonus_score + bonus_array[7];
						elseif total_series == 3 then
							bonus_score = bonus_score + bonus_array[7] + 8
						elseif total_series == 4 then
							bonus_score = bonus_score + bonus_array[7] + 16
						end

-- 
				elseif SameCardCount == 6 then

						local series = 1;
						local borrow_series = 0;  --向后面张数更多的炸弹借牌凑拖车
						local back_series = 0;  --向前面张数更多的炸弹借牌凑拖车

						for j = 1,5 do
							if ((cardValue + j) >= 15) then 
								--dump1(continueTimesArray,"continueTimesArray")
								continueTimesArray[SameCardCount] = series - 1; 
								break 
							end

							if (BombMap[cardValue + j] == SameCardCount) then
								series =  series + 1
							elseif BombMap[cardValue + j] and (BombMap[cardValue + j] > SameCardCount) then
								borrow_series = borrow_series +1
							else
								continueTimesArray[SameCardCount] = series - 1;
								break
							end
						end

						if (cardValue < 15) then
							for j = -1,-5,-1 do
								if BombMap[cardValue + j] and BombMap[cardValue + j] > SameCardCount then
								 	back_series = back_series + 1
								else break;
								end
							end
						end

						if ((series + borrow_series + back_series) >= 2) then
							for k = cardValue - back_series,cardValue + borrow_series + series -1 do
								--奖励牌型列表里没有，或者之前的张数较少
								if (bonus_card_array[k] == nil or bonus_card_array[k] < SameCardCount) then
									bonus_card_array[k] = SameCardCount
								end
							end
						end

	                    local all_series_count = series + borrow_series + back_series
						if all_series_count == 2 then
							bonus_score = bonus_score + bonus_array[4];
						elseif all_series_count == 3 then
							bonus_score = bonus_score + bonus_array[5];
						elseif all_series_count == 4 then
							bonus_score = bonus_score + bonus_array[5] + 4
						elseif all_series_count == 5 then
							bonus_score = bonus_score + bonus_array[5] + 8
						end

	       		elseif SameCardCount == 5 then

						local series = 1;
						local borrow_series = 0;
						local back_series = 0;  --向前面张数更多的炸弹借牌凑拖车

						for j = 1,6 do
							if ((cardValue + j) >= 15) then 
								--dump1(continueTimesArray,"continueTimesArray")
								continueTimesArray[SameCardCount] = series - 1; 
								break 
							end

							if (BombMap[cardValue + j] == SameCardCount) then
								series =  series + 1
							elseif BombMap[cardValue + j] and (BombMap[cardValue + j] > SameCardCount) then
								borrow_series = borrow_series +1
							else
								continueTimesArray[SameCardCount] = series - 1;
								break
							end
						end

						if (cardValue < 15) then
							for j = -1,-6,-1 do
								if BombMap[cardValue + j] and BombMap[cardValue + j] > SameCardCount then
								 	back_series = back_series + 1
								else break;
								end
							end
						end


                        local total_series = series + borrow_series + back_series
						if (total_series > 2 and bonus_array[2] == 0) or bonus_array[2] > 0 then
							for k = cardValue - back_series,cardValue + borrow_series + series -1 do
								--奖励牌型列表里没有，或者之前的张数较少
								if (bonus_card_array[k] == nil or bonus_card_array[k] < SameCardCount) then
									bonus_card_array[k] = SameCardCount
								end
							end
						end

	                    local all_series_count = series + borrow_series + back_series
						if all_series_count == 2 then
							if bonus_array[2] > 0 then
								bonus_score = bonus_score + bonus_array[2];
							end
						elseif all_series_count == 3 then
							bonus_score = bonus_score + bonus_array[3];
						elseif all_series_count == 4 then
							bonus_score = bonus_score + bonus_array[3] + 4
						elseif all_series_count == 5 then
							bonus_score = bonus_score + bonus_array[3] + 8
						elseif all_series_count == 6 then
							bonus_score = bonus_score + bonus_array[3] + 12
						end

				elseif SameCardCount == 4 then

						local series = 1;
						local borrow_series = 0;
						local back_series = 0;

						for j = 1,8 do
							if ((cardValue + j) >= 15) then 
								continueTimesArray[SameCardCount] = series - 1; 
								break 
							end

							if (BombMap[cardValue + j] == SameCardCount) then
								series =  series + 1
							elseif BombMap[cardValue + j] and (BombMap[cardValue + j] > SameCardCount) then
								borrow_series = borrow_series + 1
							else
								continueTimesArray[SameCardCount] = series - 1;
								break
							end
						end

						if (cardValue < 15) then
							for j = -1,-8,-1 do
								if  BombMap[cardValue + j] and BombMap[cardValue + j] > SameCardCount then
								 	back_series = back_series + 1
								else break;
								end
							end
						end

                        local total_series = series + borrow_series + back_series
						if (total_series > 3 and bonus_array[0] == 0) or bonus_array[0] > 0 then
							for k = cardValue - back_series,cardValue + borrow_series + series -1 do
								--奖励牌型列表里没有，或者之前的张数较少
								if (bonus_card_array[k] == nil or bonus_card_array[k] < SameCardCount) then
									bonus_card_array[k] = SameCardCount
								end
							end
						end
	                     
	                    local all_series_count = series + borrow_series + back_series
						if all_series_count == 3 then
							bonus_score = bonus_score + bonus_array[0]
						elseif all_series_count == 4 then
							bonus_score = bonus_score + bonus_array[1]
						elseif all_series_count == 5 then
							bonus_score = bonus_score + bonus_array[1] + 2;
						elseif all_series_count == 6 then
							bonus_score = bonus_score + bonus_array[1] + 4;
						elseif all_series_count == 7 then
							bonus_score = bonus_score + bonus_array[1] + 6;
						elseif all_series_count == 8 then
							bonus_score = bonus_score + bonus_array[1] + 8;
						end

				end
	        
			end

			break
		end

	end


	if (bonus_score > bonus_array[13]) then 
		bonus_score = bonus_array[13]
	end

	return bonus_score,bonus_card_array  

end

return CardLogic