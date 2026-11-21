--[[5.1和5.2兼容]]
local _prefix = TpackageName and TpackageName .. ".mahjongLogic." or ""

local unpack = table.unpack or unpack
local inspect = inspect or function() return ""  end

--[[加载模块]]
local toEigenvalue = require(_prefix .. "toEigenvalue")
local keziTable, shunziTable, jiangTable, huTable, qiduiTable = unpack(require(_prefix .. "huTable"))

--[[把高频函数加载到local里]]
local getNumEigen = toEigenvalue.getNumEigen
local getCustomEigen = toEigenvalue.getCustomEigen
local getMatrixCustomEigen = toEigenvalue.getMatrixCustomEigen
local getItemCustomEigen = toEigenvalue.getItemCustomEigen

--[[本文件变量含义:
使用color代表花色 num代表牌值，count代表数量
matrix代表一维key是花色，二维key是牌值的二维数组；item代表牌面值num的集合（item不含花色信息）；cards代表完整牌值的集合（含花色信息）
eigen表示不含花色信息的特征值, customEigen表示包含花色信息的特征值（由完整牌值得到）

一些基础函数和服务端采用同样的下划线命名规则，其他的一般采用驼峰命名，请做好在两种命名方式共存的代码里翱翔的准备：）
]]

local mahjongLogic = {}

local function log( ... )
	print("mahjongLogic \t\t", ... )
end

local COLOR_WAN = 0  --万
local COLOR_TONG = 1  --筒
local COLOR_TIAO = 2 --条
local COLOR_FENG = 3 --风
local COLOR_ZI = 4 --字
local COLOR_HUA = 5 --花
local MAX_HANDCARD_COUNT = 14 --手牌最大数量

--特殊子游戏的配置
local ColorIsInvalid = {}

ColorIsInvalid[COLOR_FENG] = true;
ColorIsInvalid[COLOR_ZI] = true;
ColorIsInvalid[COLOR_HUA] = true;

-------------------------------------------------------------缓存模块---------------------------------------------------
local _CacheCapacity = 6
local _Cache = {["indexTable"] = {}} 

--[[ 格式如{
	[1] = {},
	[2] = xxx,
	[3] = xxx,
	[4] = xxx,
	[5] = xxx,
	[6] = xxx,
	... 
	["indexTable"] = {[customeigen1] = 1, [customeigen2] = 2,}
}]]

--缓冲容量为_CacheCapacity大小的缓存容器
local function cacheHandle(typ, customeigen, key, value)

	if typ == "clear" then
		_Cache = {["indexTable"] = {}} 
	elseif typ == "get" then
		local index = _Cache["indexTable"][customeigen]
		if index and _Cache[index][key] ~= nil then
			print("getCacheData key = ", key)
			return clone(_Cache[index][key])  --返回拷贝而非本体，防止缓存被篡改
		else
			return nil
		end
	elseif typ == "store" then
		local index = _Cache["indexTable"][cuseigen]

		if index then  --更新缓存
			_Cache[index][key] = clone(value)  --存入缓存时都采用拷贝形式
		else  --新增缓存
			if #_Cache > _CacheCapacity - 1 then  --缓存超过容限，去除旧缓存,更新映射表
				table.remove(_Cache, 1)
				for customeigen, index in pairs(_Cache["indexTable"]) do
					if index == 1 then
						_Cache["indexTable"][customeigen] = nil  --第一个数据被冲刷掉
					else 
						_Cache["indexTable"][customeigen] = index - 1  --后面的数据顺序往前减1
					end
				end
			end

			table.insert(_Cache, {[key] = clone(value)}) --存入缓存时都采用拷贝形式
			local index = #_Cache
			_Cache["indexTable"][customeigen] = index
		end

	end

end

-------------------------------------------------------------麻将逻辑---------------------------------------------------
--获取牌值
local function get_card_number(card) 
    return card%16  --bit.band(card, 0x0F)
end

--获取花色
local function get_card_color(card) 
    return math.floor(card/16)   --bit.rshift(bit.band(card, 0xF0), 4)
end

--用花色和牌值获得原始牌
local function make_card(color, num)
    return (color*0x10 + num)
end  

--判断是否是合法的麻将 可以用来屏蔽0值
local function is_valid_card(card) 
    local num =  get_card_number(card)
    local color =  get_card_color(card)

    return (num >= 1 and num <= 9 and color <=5)        --万筒条子
end

--用来判断数组是否相等
local function array_equal(arr1, arr2)

    if #arr1 ~= #arr2 then return false end

    local new_tbl1 = {}
    for _,v in ipairs(arr1) do new_tbl1[v] = (new_tbl1[v] or 0) + 1; new_tbl1_count = new_tbl1_count + 1 end

    local new_tbl2 = {} 
    for _,v in ipairs(arr2) do new_tbl2[v] = (new_tbl2[v] or 0) + 1; new_tbl2_count = new_tbl2_count + 1 end

    for k, v in pairs(new_tbl1) do if new_tbl2[k] ~= v then return false end end

    return true
end

--[[ipairs在lua中不会遍历0、非连续数字、非数字等KEY，所以使用ipairs来遍历这个数组，
使用0来计数则是出于方便移植到别的语言中去的考虑]]

--可以传二维数组进来初始化,循环利用 / 直接返回新的二维数组
local function init_matrix(matrix)
	dump(matrix,"init_matrix(matrix)")
	if type(matrix) == "table" then
		--加载万筒条风箭花
	    for color = 0, 5 do
	    	if ColorIsInvalid[color] then
		    	--根据花色区分数字区间
		    	local endindex = 9
		    	if color == 3 then endindex = 4 
		    	elseif color == 4 then endindex = 3
		    	elseif color == 5 then endindex = 8 end

		    	--初始化牌计数器
		    	for num = 1, endindex do matrix[color][num] = 0 end
		    	--初始化花色计数器
		    	matrix[color][0] = 0
		    	--初始化特征值
		    	matrix[color]["eigen"]= 0
		    end
	    end

	    return matrix
	else
		local matrix = {
		    [0] = {0,0,0,0,0,0,0,0,0, [0]=0, ["eigen"]=0}, --万1~9 [0]位用来计数
		    [1] = {0,0,0,0,0,0,0,0,0, [0]=0, ["eigen"]=0}, --筒
		    [2] = {0,0,0,0,0,0,0,0,0, [0]=0, ["eigen"]=0}, --条
		    [3] = {0,0,0,0, [0]=0, ["eigen"]=0}, --风
		    [4] = {0,0,0, [0]=0, ["eigen"]=0}, --字
		    [5] = {0,0,0,0,0,0,0,0, [0]=0, ["eigen"]=0}, --春夏秋冬花牌
		}

		--for color in pairs(ColorIsInvalid) do
		--	matrix[color] = nil
		--end

		return matrix
	end
end

--可以传一维数组进来初始化,循环利用 / 直接返回新的一维数组
local function init_item(item)
	if type(item) == "table" then

    	for num = 1, #item do item[num] = 0 end
    	--初始化花色计数器
    	item[0] = 0
    	--初始化特征值
    	item["eigen"] = 0
    	return item
    else
    	return {0,0,0,0,0,0,0,0,0, [0]=0, ["eigen"]=0}
    end
end

--将原始手牌数组变成二维数组
local function cards_to_matrix(cards)

    local matrix = init_matrix()
    for _, card in ipairs(cards) do
        local num = card%16 --get_card_number(card)
        local color = math.floor(card/16) --get_card_color(card)
        if (num >= 1 and num <= 9 and color <=5) then --合法牌才处理
	        matrix[color][num] = matrix[color][num] + 1 
	        matrix[color][0] = matrix[color][0] + 1  --统计总牌数
	        matrix[color]["eigen"] = matrix[color]["eigen"] + getNumEigen(num)  --统计总特征值
	    end
    end

    return matrix
end

--二维数组还原为原始手牌数组
local function matrix_to_cards(matrix)

    local cards = {}

    for color, item in pairs(matrix) do if item[0] > 0 then
		for num, count in ipairs(item) do if count > 0 then
        	for i = 1, count do
	            table.insert(cards, color*0x10 + num)
	        end
	    end
	    end
    end
    end

    return cards
end

--二维数组添加牌
local function matrix_add_card(matrix, color, num, count)
	matrix[color][num] = matrix[color][num] + count
	matrix[color][0] = matrix[color][0] + count
	matrix[color]["eigen"] = matrix[color]["eigen"] + getNumEigen(num) * count
end

--一维数组转化为牌值， 转化需补齐花色信息
local function item_to_cards(item, color)

    local cards = {}

	if item[0] > 0 then
		for num, count in ipairs(item) do
        	for i = 1, count do
	            table.insert(cards, make_card(color, num))
	        end
	    end
    end

    return cards
end

--牌值转化为一维数组，转化过程中会丢失花色信息
local function cards_to_item(cards)

    local item = init_item()

    for _, card in ipairs(cards) do
        if is_valid_card(card) then  --合法牌才处理
	        local num = card%16 --get_card_number(card)
	        local color = math.floor(card/16) --get_card_color(card)
            item[num] = item[num] + 1 
            item[0] = item[0] + 1  --统计总牌数
            item["eigen"] = item["eigen"] + getNumEigen(num)  --统计总特征值
        end
    end

    return item
end

--一维数组添加牌
local function item_add_card(item, num, count)
	item[num] = item[num] + count
	item[0] = item[0] + count
	item["eigen"] = item["eigen"] + getNumEigen(num) * count
end

--从原始手牌数组里删除牌
local function delete_cards(orgcards, dcards, ifCreateCopy)  
--orgcards代表原始数组，dcards代表要删除的牌的集合，ifCreateCopy代表是否创建新的拷贝或者是直接从原始数组里删除
	
	if ifCreateCopy == nil then ifCreateCopy = true end  --默认是创建新的拷贝

	local new_cardslist = ifCreateCopy and clone(orgcards) or orgcards

	--匹配上的index缓存下来，用来跳过
	local matchedIndexs = {}
	local indexArray = {}

	for _,v in ipairs(dcards) do

		for i,x in ipairs(orgcards) do
			if v == x and not matchedIndexs[i] then  --在需要删掉的牌里
				matchedIndexs[i] = true
				table.insert(indexArray, i)
				break
			end
		end
	end

	table.sort(indexArray, function(a, b) return a>b end)
	--倒序删除
	for index = 1, #indexArray do
		table.remove(new_cardslist, indexArray[index])
	end

	return new_cardslist, #indexArray == #dcards 
	 --[[后面这个返回值用来标记orgcards是否包含了dcards， dcards里面的每一张都在orgcards里面找到且被删除了]]
end

--item是否包含另一个item,为了优化性能而引入
local function if_include_item(orgitem, ditem)

	if ditem[0] > orgitem[0] then return false end

	for num, count in ipairs(ditem) do if count > 0 then
		if count > orgitem[num] then
			return false
		end
	end
	end

	return true
end

--从一维数组里删除牌
local function delete_item(orgitem, ditem, ifCreateCopy)

	if ifCreateCopy == nil then ifCreateCopy = true end  --默认是创建新的拷贝

	local new_item = ifCreateCopy and clone(orgitem) or orgitem

	local canmatch = true

	for num, count in ipairs(ditem) do if count > 0 then

		new_item[num] = new_item[num] + (-count)
		new_item[0] = new_item[0] + (-count)
		new_item["eigen"] = new_item["eigen"] + getNumEigen(num) * (-count)

		-- item_add_card(new_item, num, -count)
		if new_item[num] < 0 then  --说明orgitem不包含那个ditem
			canmatch = false
			break 
		end

	end
	end

	return new_item, canmatch
	 --[[后面这个值的意思是orgcards是否包含了ditem， ditem里面的每一张都在orgitem里面找到且被删除了]]
end

--一维数组加牌
local function add_item(orgitem, aitem, ifCreateCopy)

	if ifCreateCopy == nil then ifCreateCopy = true end  --默认是创建新的拷贝

	local new_item = ifCreateCopy and clone(orgitem) or orgitem

	for num, count in ipairs(aitem) do if count > 0 then
		-- item_add_card(new_item, num, count)
		new_item[num] = new_item[num] + count
		new_item[0] = new_item[0] + count
		new_item["eigen"] = new_item["eigen"] + getNumEigen(num) * count
	end
	end

	return new_item
	 --[[后面这个值的意思是orgcards是否包含了ditem， ditem里面的每一张都在orgitem里面找到且被删除了]]
end

--特殊牌型：七对
local function isOfQidui(matrix)

	-- local matrixEigenSum = 0
	-- for color, item in pairs(matrix) do
	-- 	matrixEigenSum = matrixEigenSum + item["eigen"]
	-- end

	-- --这是七对牌型的必要不充分条件
	-- if not qiduiTable[matrixEigenSum]then
	-- 	return false
	-- end

	for color, item in pairs(matrix) do if item[0] > 0 then
		if item[0]%2 == 0 then
			for num, count in ipairs(item) do
				if count%2 ~= 0 then
					return false
				end
			end
		else 
			return false
		end
	end
	end 

	return true
end

local function isTingQidui(matrix, totalcardcount)

	--判断
	if totalcardcount == MAX_HANDCARD_COUNT - 1 then

		local matrixEigenSum = 0
		--计算有没有可能是七对，如果加上某个值后是七对肯定满足特征值和在huTable里
		local maybeQiduiNum, maybeQiduiColor = nil, nil

		for color, item in pairs(matrix) do if item[0] > 0 then 
			matrixEigenSum = matrixEigenSum + item["eigen"]
			for num, count in ipairs(item) do
				if count == 1 or count == 3 then
					if maybeQiduiNum then
						return false, nil
					end
					maybeQiduiNum = num
					maybeQiduiColor = color
				end
			end
		end
		end

		--特征值和显示可能是七对，才进行进一步计算
		if maybeQiduiNum then
			matrix_add_card(matrix, maybeQiduiColor, maybeQiduiNum, 1)
			if isOfQidui(matrix) then
				matrix_add_card(matrix, maybeQiduiColor, maybeQiduiNum, -1)
				return true, make_card(maybeQiduiColor, maybeQiduiNum)  --七对只可能胡一张牌，因此
			else
				matrix_add_card(matrix, maybeQiduiColor, maybeQiduiNum, -1)
			end

		end



	end

	return false, nil
end

--快速判断胡
local function isTingQingyise(matrix, totalcardcount)
	if totalcardcount == MAX_HANDCARD_COUNT - 1 then
		for color, item in pairs(matrix) do
			if item[0] == totalcardcount then
				return true, color
			end
		end
	end

	return false, nil
end

--判断是否属于清一色
local function isOfQingyise(matrix, totalcardcount)
	if totalcardcount == MAX_HANDCARD_COUNT then
		for color, item in pairs(matrix) do
			if item[0] == totalcardcount then
				return true, color
			end
		end
	end

	return false, nil
end

--快速判成牌型
local function isCompleted(matrix)

	local hasjiang = false
	for color, item in pairs(matrix) do if item[0] > 0 then
		--满足胡牌队列
		if not huTable[item[0]][item["eigen"]] then 
			return false
		elseif item[0]%3 == 2 then
			if hasjiang then  --有重复的将牌
				return false  
			else
				hasjiang = true
			end
		end

	end
	end

	return true
end

--快速判断胡
local function isHu(cards)

	local ishu = false

	local totalcardcount = #cards

	if totalcardcount%3 ~= 2 then
		return ishu
	end

	-- local customeigen = getCustomEigen(cards)

	-- local cache_isHu = cacheHandle("get", customeigen, "isHu")
	-- if cache_isHu ~= nil then
	-- 	return cache_isHu
	-- end
    dump(cards,"cards_to_matrix")
	local matrix = cards_to_matrix(cards)  --cacheHandle("get", customeigen, "matrix") or  --
	
	--七对判断
	if totalcardcount == MAX_HANDCARD_COUNT and isOfQidui(matrix) then
		return true
	end

	--各种牌型的次数
	local count_3 = 0  --刻或顺的个数
	local count_2 = 0  --将
 
	--满足3N+2的在这里计算
	for color, item in pairs(matrix) do if item[0] > 0 then

		--满足胡牌队列
		if huTable[item[0]][item["eigen"]] then 
			--通过数量来区分
			if item[0]% 3 == 2 then  --3n + 2牌
				count_2 = count_2 + 1
				count_3 = count_3 + (item[0]-2)/3
			elseif item[0]% 3 == 0 then  --3n牌
				count_3 = count_3 + item[0]/3
			end

		end

	end
	end

	ishu = count_2 == 1 and count_3 == (totalcardcount - 2)/3 
	-- cacheHandle("store", customeigen, "isHu", ishu)
	-- cacheHandle("store", customeigen, "matrix", matrix)
	--有一对将，其他都是3n牌
	return ishu
end

--获得听牌
local function getTingCards(cards)

	--needjiang:默认为true，如果为false的话不需要将也可以获取听的牌
	local tingcards = {}

	local totalcardcount = #cards

	if (totalcardcount+1)%3 ~= 2 then 	--要嘛加上一张牌可以凑成3N牌型（不带将）要嘛凑成3N+2（包含七对的14张）
		return tingcards
	end

	-- local customeigen = getCustomEigen(cards)

	-- local cache_tingcards = cacheHandle("get", customeigen, "tingcards")
	-- if cache_tingcards ~= nil then
	-- 	return cache_tingcards
	-- end

	local matrix = cards_to_matrix(cards)   --cacheHandle("get", customeigen, "matrix") or 

	local tingqidui, tingqiduicard = isTingQidui(matrix, totalcardcount)
	if tingqidui then
		table.insert(tingcards, tingqiduicard)
	end

	--各种牌型的次数
	local count_3 = 0  --刻或顺的个数
	local count_2 = 0  --将

	--满足3N+2的在这里计算
	for color, item in pairs(matrix) do if item[0] > 0 then
		
		--满足胡牌队列
		if huTable[item[0]][item["eigen"]] then 

			if item[0]%3 == 0 then 
				count_3 = count_3 + item[0]/3
			elseif item[0]%3 == 2 then 
				count_3 = count_3 + (item[0]-2)/3
				count_2 = count_2 + 1
			end
		end

	end
	end

	--逐个试
	for color, item in pairs(matrix) do if item[0] > 0 then

		if huTable[item[0]][item["eigen"]] then 
		--之前满足胡牌条件的话
			if item[0]%3 == 0 then 
				count_3 = count_3 - item[0]/3
			elseif item[0]%3 == 2 then 
				count_3 = count_3 - (item[0]-2)/3
				count_2 = count_2 - 1
			end
		end

		for num = 1,9 do

			local new_count_2 = count_2
			local new_count_3 = count_3

			--手牌里有同一张牌达到4张，就不能听这张牌了
			if item[num] and item[num] < 4 then 

				--添加完牌之后的新特征值
				local newEigen = item["eigen"] + getNumEigen(num)  
				local newcount = item[0] + 1

				--满足胡牌队列
				if huTable[newcount][newEigen] then 
					--通过数量来区分
					if newcount% 3 == 2 then  --3n + 2牌
						new_count_2 = new_count_2 + 1
						new_count_3 = new_count_3 + (newcount-2)/3
					elseif newcount% 3 == 0 then  --3n牌
						new_count_3 = new_count_3 + newcount/3
					end

					if new_count_2 == 1 and new_count_3 == (totalcardcount + 1 - 2)/3 then
						table.insert(tingcards, make_card(color, num))
					end
				end
			end
		end

		if huTable[item[0]][item["eigen"]] then 
		--之前满足胡牌条件的话
			if item[0]%3 == 0 then 
				count_3 = count_3 + item[0]/3
			elseif item[0]%3 == 2 then 
				count_3 = count_3 + (item[0] - 2)/3
				count_2 = count_2 + 1
			end
		end

	end
	end

	-- local isting = next(tingcards) and true or false

	-- cacheHandle("store", customeigen, "tingcards", tingcards)
	-- cacheHandle("store", customeigen, "matrix", matrix)
	-- cacheHandle("store", customeigen, "isTing", isting)

	--有一对将，其他都是3n牌
	return tingcards
end

--快速判断听
local function isTing(cards)

	local isting = false

	local totalcardcount = #cards
	if (totalcardcount+1)%3 ~= 2 then 	--要嘛加上一张牌可以凑成3N牌型（不带将）要嘛凑成3N+2（包含七对的14张）
		return isting
	end

	-- local customeigen = getCustomEigen(cards)

	-- local cache_isTing = cacheHandle("get", customeigen, "isTing")
	-- if cache_isTing ~= nil then
	-- 	return cache_isTing
	-- end

	local tingcards = getTingCards(cards)

	if next(tingcards) then
		isting = true
	end

	-- cacheHandle("store", customeigen, "isTing", isting)
	return isting
end

-----------------------------------------------------------计算摆牌相关---------------------------------------------------------------
--获得完整的牌型中缺少的牌
local function getLackCards(matrix, totalcardcount, tingfilter)

	local lackcards = {}

	local tingqidui, tingqiduicard = isTingQidui(matrix, totalcardcount)
	if tingqidui then
		table.insert(lackcards, tingqiduicard)
	end

	--逐个试
	for color, item in pairs(matrix) do if item[0] > 0 then

		for num = 1,9 do

			local card = color*0x10 + num
			--手牌里有同一张牌达到4张，就不能听这张牌了,且缺的这张牌必须在听牌列表中
			if item[num] and item[num] < 4 and tingfilter[card] then 

				--添加完牌之后的新特征值
				-- local newEigen = item["eigen"] + getNumEigen(num)  
				-- local newcount = item[0] + 1
				local addtionalEigen = getNumEigen(num)
				item[num] = item[num] + 1
				item[0] = item[0] + 1
				item["eigen"] = item["eigen"] + addtionalEigen

				-- item_add_card(item, num, 1)

				--满足牌型队列	
				if huTable[item[0]][item["eigen"]] and isCompleted(matrix) then
					table.insert(lackcards, card)
				end

				item[num] = item[num] - 1
				item[0] = item[0] - 1
				item["eigen"] = item["eigen"] - addtionalEigen

				-- item_add_card(item, num, -1)

			end
		end

	end
	end

	--有一对将，其他都是3n牌
	return lackcards
end

local cardRelateType = {
	[1] = {{1, 2, 3}, {1, 1}, {1, 1, 1}};
	[2] = {{1, 2, 3}, {2, 3, 4}, {2, 2}, {2, 2, 2}};
	[3] = {{1, 2, 3}, {2, 3, 4}, {3, 4, 5}, {3, 3}, {3, 3, 3}};
	[4] = {{2, 3, 4}, {3, 4, 5}, {4, 5, 6}, {4, 4}, {4, 4, 4}};
	[5] = {{3, 4, 5}, {4, 5, 6}, {5, 6, 7}, {5, 5}, {5, 5, 5}};
	[6] = {{4, 5, 6}, {5, 6, 7}, {6, 7, 8}, {6, 6}, {6, 6, 6}};
	[7] = {{5, 6, 7}, {6, 7, 8}, {7, 8, 9}, {7, 7}, {7, 7, 7}};
	[8] = {{6, 7, 8}, {6, 7, 8}, {8, 8}, {8, 8, 8}};
	[9] = {{7, 8, 9}, {9, 9}, {9, 9, 9}};
}

for num, allnums in ipairs(cardRelateType) do
	cardRelateType[num] = {}
	for _, nums in ipairs(allnums) do
		local item = init_item()
		for _, num in ipairs(nums) do
            item_add_card(item, num, 1)
		end
		table.insert(cardRelateType[num], item)
	end
end

local allTypeTable = {}
for eigen, cards in pairs(keziTable)   do allTypeTable[eigen] = cards end
for eigen, cards in pairs(shunziTable) do allTypeTable[eigen] = cards end
for eigen, cards in pairs(jiangTable)  do allTypeTable[eigen] = cards end

table.include = function(superarr, subarr)  --supertbl父集，subtbl子集,相同也会返回true

	local subtable = {}
	for _, card in ipairs(subarr) do
		subtable[card] = (subtable[card] or 0) + 1
	end

	local supertable = {}
	for _, card in ipairs(superarr) do
		supertable[card] = (supertable[card] or 0) + 1
	end

	for card, count in pairs(subtable) do
		if supertable[card] == nil or supertable[card] < count then
			return false
		end
	end

	return true 
end

--插入摆牌
local function insertBaicards(container, baicards, lackcards, outcard)

	local itemsize = #baicards
	local lacksize = #lackcards

	if itemsize > 0 and lacksize > 0 and itemsize/lacksize < 4 then  --如果摆牌比听牌多太多的话说明摆牌肯定有冗余的

 		local key = getCustomEigen(lackcards)

 		--[[插入新摆牌的思路，
 		①如果不存在则直接插入，
 		②如果存在，则遍历之前的结果，发现冗余结果的话用新的摆牌更新它；
 		③遍历完之后，没有发现冗余结果的话，则插入新的项]]
 		if not container[key] then 
 			container[key] = {} 
 			table.insert(container[key], {["baicards"] = baicards, ["tingcards"] = lackcards, ["outcards"] = {outcard}, ["baicardcount"] = itemsize})
 			return container[key][1]
 		else

	 		for index, olditem in ipairs(container[key]) do

	 			--旧的摆牌比新的多，这时候主要检查旧的牌是否冗余
	 			if olditem["baicardcount"] > itemsize then
		 			--旧项包含新插入的牌，说明旧项有冗余牌，更新它
		 			if olditem["baicardcount"] > 2 and table.include(olditem["baicards"], baicards) then  
		 				olditem = nil
		 				container[key][index] = {["baicards"] = baicards, ["tingcards"] = lackcards, ["outcards"] = {outcard}, ["baicardcount"] = itemsize}
		 				return container[key][index]
		 			end

		 		--新的摆牌比旧的牌多，这时候主要检查新的牌是否冗余，冗余则直接返回
		 		elseif itemsize > olditem["baicardcount"] then

		 			--新的摆牌数量小于2的话一律不判定为冗余
		 			if itemsize > 2 and table.include(baicards, olditem["baicards"]) then   --新插入的牌包含旧项，说明新插入的牌有冗余牌，直接返回
		 				return false 
		 			end

		 		--新旧摆牌数量相等，检查是否相等，相等则直接返回
		 		elseif itemsize == olditem["baicardcount"] then

		 			if table.include(olditem["baicards"], baicards) then --新插入的摆牌和旧的相同，插入失败，直接返回

		 				local outcardexist = false
		 				for i, card in ipairs(olditem["outcards"]) do
		 					if card == outcard then
		 						outcardexist = true
		 						break
		 					end
		 				end

		 				if outcardexist == false then
		 					table.insert(olditem["outcards"], outcard)
		 				end

		 				return false
		 			end

		 		end

	 		end

 			local oldsize = #container[key]
			table.insert(container[key], {["baicards"] = baicards, ["tingcards"] = lackcards, ["outcards"] = {outcard}, ["baicardcount"] = itemsize})
			return container[key][oldsize+1]
	 	end

	end

	return false   --插入失败
end

--获得摆牌
local function calcBaiCards(cards, baicards, outcard)

	local totalcardcount = #cards
	local baicards = baicards or {}

	local matrix = cards_to_matrix(cards)

	--听七对牌型
	local tingqidui, tingqiduicard = isTingQidui(matrix, totalcardcount)
	if tingqidui then
		insertBaicards(baicards, {tingqiduicard}, {tingqiduicard}, outcard)
	end

	--计算这副牌听的牌,如果没听牌直接返回
	local tingcards = getTingCards(cards)
	if next(tingcards) == nil then
		return {}
	end

	local tingfilter = {}
	for i,v in ipairs(tingcards) do
		tingfilter[v] = true
	end

	insertBaicards(baicards, cards, tingcards, outcard)
	if tingqidui then
		return baicards
	end
	--被移除掉的牌能满足胡牌条件或成牌型，同时左边的牌要能听牌
	local ridItemCache = {}

	local delete_item = delete_item
	local if_include_item = if_include_item

	local matrixEigen = getMatrixCustomEigen(matrix)
	-- print("newmatrixEigen = ", matrixEigen)
	--分割最佳摆牌， 这里是修改都不能是永久性的
 	local function ridItem(newmatrix, delete_matrix, matrixEigen, totalcardcount)

		for color, item in pairs(newmatrix) do if item[0] > 0 then

		   --遍历item，寻找可能可以删掉的子牌型
			for num, count in ipairs(item) do if count > 0 then  --屏蔽条件，牌存在时
					
				for i, possibleitem in ipairs(cardRelateType[num]) do

					local itemEigen = getItemCustomEigen(possibleitem, color) 

					--计算删去这张牌后的新特征值
					local newmatrixEigen = matrixEigen - itemEigen

					if ridItemCache[newmatrixEigen] == nil then 

						ridItemCache[newmatrixEigen] = false  --不是ifallmatch

						if possibleitem[0] <= item[0] then

							local ifallmatch = true

							for num, count in ipairs(possibleitem) do if count > 0 then
								if count > item[num] then
									ifallmatch = false
									break
								end
							end
							end

						    --item包含这个牌型
							if ifallmatch then  --if_include_item(item, possibleitem) then  -- ifallmatch then

								ridItemCache[newmatrixEigen] = true

								--删掉旧牌
								delete_item(newmatrix[color], possibleitem, false)
								--删除掉的牌里增加这一次删除的
								add_item(delete_matrix[color], possibleitem, false)

								local newtotalcardcount = totalcardcount - possibleitem[0]

							   --听牌存在
								if isCompleted(delete_matrix) then
									local newlackcards = getLackCards(newmatrix, newtotalcardcount, tingfilter)
									insertBaicards(baicards, matrix_to_cards(newmatrix), newlackcards, outcard)
								end

								--深度删牌
								ridItem(newmatrix, delete_matrix, newmatrixEigen, newtotalcardcount)

								--[[还原系列]]
								--还原二维数组
								add_item(newmatrix[color], possibleitem, false)
								--还原删牌二维数组
								delete_item(delete_matrix[color], possibleitem, false)
								--还原二维数组

							end

						end

					end

					-- newmatrixEigen = matrixEigen + itemEigen

				end

			end
			end

		end		
		end

 	end

	ridItem(clone(matrix), init_matrix(), matrixEigen, totalcardcount)
	return baicards
end

local function calcMingQiduiBaiCards(baicards, cards, pengcards, tinginfotbl, outcard)

	local totalcardcount = #cards + #pengcards
	if totalcardcount ~= MAX_HANDCARD_COUNT - 1 then
		return baicards 
	end

	--不需要打牌的摆
	--有碰杠牌的时候才触发明七对规则
	local myAllCards = {}
	local pengcard = {}

	for i,v in ipairs(cards) do
		table.insert(myAllCards, v)
	end

	for i,v in ipairs(pengcards) do
		pengcard[v] = true
		table.insert(myAllCards, v)
	end

	--local tingqidui, tingcard = isTingQidui(cards_to_matrix(myAllCards), totalcardcount)
    --
	--if tingqidui then
    --
	--	if pengcard[tingcard] then
	--		insertBaicards(baicards, {tingcard, tingcard, tingcard}, {tingcard}, outcard)
	--	else
	--		insertBaicards(baicards, {tingcard}, {tingcard}, outcard)
	--	end
	--end

	return baicards
end

local function calcLuanQiyiseBaiCards(baicards, cards, extracards, tinginfotbl, outcard)

	local totalcardcount = #cards + #extracards

	if totalcardcount ~= MAX_HANDCARD_COUNT - 1 then
		return false 
	end

	local myAllCards = {}

	for i,v in ipairs(cards) do
		table.insert(myAllCards, v)
	end

	for i,v in ipairs(extracards) do
		table.insert(myAllCards, v)
	end

	--只要满足清一色的话，摆出全部牌就可以听任意该色牌，阆中麻将规则
	--local isqing, color = isTingQingyise(cards_to_matrix(myAllCards), totalcardcount)
    --
	--if isqing then
    --
	--	local tingcards = {}
	--	for num = 1,9 do
	--		local tingcard = make_card(color, num)
	--        table.insert(tingcards, tingcard)
	--	end
    --
	--	insertBaicards(baicards, cards, tingcards, outcard)
    --
	--	return true --标记可以摆乱清一色
	--end

	return false
end

local function getBaiCards(cards, tinginfotbl, dangercardfilter, pengcards, extracards)

	pengcards = pengcards or {} 
	extracards = extracards or {}
	tinginfotbl = tinginfotbl or {}

	local totalcardcount = #cards
	local baicalcresult = {}

	if totalcardcount%3 == 2 then  --可以打牌的摆
		local calced_cards = {}
		
		--需要满足没剔除过且不是危险牌的条件
		for i, card in ipairs(cards) do if not calced_cards[card] and dangercardfilter[card] ~= true then calced_cards[card] = true 

			local newcards = delete_cards(cards, {card})

			if calcLuanQiyiseBaiCards(baicalcresult, newcards, extracards, tinginfotbl, card) then

			else
				calcBaiCards(newcards, baicalcresult, card)  --删掉要出的牌，计算摆牌
				calcMingQiduiBaiCards(baicalcresult, newcards, pengcards, tinginfotbl, card)
			end
			
		end
		end

	else  --不需要打牌的摆

		if calcLuanQiyiseBaiCards(baicalcresult, cards, extracards, tinginfotbl) then
			
		else
			baicalcresult = calcBaiCards(cards, baicalcresult)
			calcMingQiduiBaiCards(baicalcresult, cards, pengcards, tinginfotbl)
		end

	end
	
    print(inspect(baicalcresult), "baicalcresult") 

	--组装数据，跟服务端发过来的版本保持一致
	local baiinfo = {}

	for _, data in pairs(baicalcresult) do

		for i, baidata in ipairs(data) do 

			local _eigenvalue = 0
			local _baicards = {}
			local _tingcards = {}	

			--可以摆单副对子的情况下，一定可以摆对楚（双副对子），这个游戏只允许摆对楚，因此过滤掉摆单副对子的情况
			if not (#baidata.baicards == 2 and baidata.baicards[1] == baidata.baicards[2]) then  

		        for _, card in ipairs(baidata.baicards) do
		            _eigenvalue = _eigenvalue + card^3
		            table.insert(_baicards, card)
		        end

		        for _, card in ipairs(baidata.tingcards) do
		        	local item = {}
		            item.tingcard = card
		            item.fannum = tinginfotbl[card] and tinginfotbl[card].fannum or 0
		            item.remain = tinginfotbl[card] and tinginfotbl[card].remain or 0
		            table.insert(_tingcards, item)
		        end

				table.insert(baiinfo, 
					{baicards = _baicards, 
					outcards = baidata.outcards or {}, 
					tingcards = _tingcards, 
					_eigenvalue = _eigenvalue})

			end

		end

	end

    baiinfo.bestbaiindex = 1
	table.sort(baiinfo, function(a, b) return #a.tingcards > #b.tingcards end)
	
	return baiinfo
end

--这里是暴露出来的接口
mahjongLogic = {
	["isHu"] = isHu;
	["getTingCards"] = getTingCards;
	["isTing"] = isTing;
	["getBaiCards"] = getBaiCards;
	["cacheHandle"] = cacheHandle;
}

setmetatable(mahjongLogic, 
	{
		__call = function(self, funcname, ...) return self[funcname](...) end;
	}
)

return mahjongLogic