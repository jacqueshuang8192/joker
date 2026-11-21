local toEigenvalue = {}

--9次方转换
local basenum = 10
local eigentag = {
	[0] = 0;
	[1] = math.floor(basenum^0);
	[2] = math.floor(basenum^1);
	[3] = math.floor(basenum^2);
	[4] = math.floor(basenum^3);
	[5] = math.floor(basenum^4);
	[6] = math.floor(basenum^5);
	[7] = math.floor(basenum^6);
	[8] = math.floor(basenum^7);
	[9] = math.floor(basenum^8);
}

-- local eigentag = {
-- 	[0] = 0;
-- 	[1] = 1;
-- 	[2] = 512;
-- 	[3] = 19683;
-- 	[4] = 262144;
-- 	[5] = 1953125;
-- 	[6] = 10077696;
-- 	[7] = 40353607;
-- 	[8] = 134217728;
-- 	[9] = 387420489;
-- }

--生成9次方特征值
local function getEigen(values)
	local _sum = 0

	if type(values) == "table" then
		for _, v in ipairs(values) do  --只遍历1-9数组部分，不遍历0 key和hash部分
			local _s = getEigen(v)
			_sum = _sum + _s 
		end
	else
		_sum = _sum + eigentag[values]  --生成特征值
	end

	return _sum
end

local function diffEigen(value1, value2)
	return bit.band(value1, value2)
end

local function getArrayEigen(values, depth)
	local _sum = 0
	local _count = 0

	depth = depth or 1
	for _, v in ipairs(values) do  --只遍历1-9数组部分，不遍历0 key和hash部分
		if depth == 1 then
			_sum = _sum + eigentag[v]
			_count = _count + 1
		else
			local _s, _c = getArrayEigen(v, depth-1)
			_sum = _sum + _s
			_count = _count + _c
		end
	end

	return _sum, _count
end

local function getNumEigen(value)
	return eigentag[value]
end

--生成非9次方的特征值
local customEigenTag = 6
local customEigenTagCache = {} --用来缓存特征化之后的结果
local function getCustomEigen(values)
	local _sum = 0

	if type(values) == "table" then
		for _, v in ipairs(values) do  --只遍历1-9数组部分，不遍历0 key和hash部分
			_sum = _sum + getCustomEigen(v)
		end
	else
		local _eigenvalue = customEigenTagCache[values]  --or eigentag[values]

		if not  _eigenvalue then
		 	_eigenvalue = values^customEigenTag --生成特征值
		 	customEigenTagCache[values] = _eigenvalue
		end

		_sum = _sum + _eigenvalue  
	end

	return math.floor(_sum)
end

local itemEigenTagCache = {} --用来缓存特征化之后的结果
--获取二维矩阵的特征值
local function getItemCustomEigen(item, color)

	--如果有缓存的值则返回缓存值
	if itemEigenTagCache[color] then
		if itemEigenTagCache[color][item["eigen"]] then
			return itemEigenTagCache[color][item["eigen"]]
		end
	else
		itemEigenTagCache[color] = {}
	end

	local _itemsum = 0
	for num, count in ipairs(item) do if count > 0 then
		_itemsum = _itemsum + getCustomEigen(color*0x10 + num) *count  --eigentag[num]
	end 
	end

	itemEigenTagCache[color][item["eigen"]] = _itemsum
	return _itemsum
end

--获取二维矩阵的特征值
local function getMatrixCustomEigen(matrix)
	local _sum = 0
	for color, item in pairs(matrix) do if item[0] > 0 then
		local _itemsum = 0
		for num, count in ipairs(item) do if count > 0 then
			_itemsum = _itemsum + getCustomEigen(color*0x10 + num) *count 
		end 
		end
		_sum = _sum + (_itemsum)  --color*coloreigentag + 
	end
	end
	return _sum
end

--根据特征值获得原值
local function getOriValue(eigenvalue)
	return eigenvalue%10 
end

--这里是暴露出来的接口
toEigenvalue = {
	-- ["getOriValue"] = getOriValue;
	["getEigen"] = getEigen;
	["getArrayEigen"] = getArrayEigen;
	["getNumEigen"] = getNumEigen;
	["diffEigen"] = diffEigen;

	["getMatrixCustomEigen"] = getMatrixCustomEigen;
	["getItemCustomEigen"] = getItemCustomEigen;
	["getCustomEigen"] = getCustomEigen;
}

setmetatable(toEigenvalue, 
	{
		__call = function(_, funcname, ...) return toEigenvalue[funcname](...) end;
	}
)

return toEigenvalue
