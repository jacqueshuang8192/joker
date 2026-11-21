
LSuperTools = class("LSuperTools")

function LSuperTools:ctor()
	
end

function LSuperTools:copyTable(_t1, _t2)
	local function func(t1, t2)
		for key, var in pairs(t1) do
			if type(var) == "table" then
				t2[key] = {}
				func(var, t2[key])
			else	
				t2[key] = var
			end
		end
	end
	if _t2 == nil then _t2 = {} end
	func(_t1, _t2)
	return _t2
end

--此接口清理太彻底(deep == true, 遍历置空,慎用)
function LSuperTools:clearTable(t, isDeep)
	for key, var in pairs(t) do
		if type(var) == "table" then
			--深度清理(传true要谨慎)
			if isDeep ~= nil and isDeep == true then clearTable(var) end
		end
		t[key] = nil
    end
end

--print table
function LSuperTools:printTab(tab)
    print("********************table begin*********************")
    for i,v in pairs(tab) do
        if type(v) == "table" then
            print("table",i,"{")
            printTab(v)
            print("}")
        else
            print("key == "..i..", value == "..v)
        end
    end
    print("********************table end*********************")
end

--用于非数字下标的table计算
function LSuperTools:getTableSize(tb)
	local num = 0
	for i, v in pairs(tb) do
        num = num + 1
    end
	return num
end

function LSuperTools:createEnumTable(tb, index)
    local enumTable = {}
    local enumIndex = index or -1
    for i, v in ipairs(tb) do
        enumTable[v] = enumIndex + i
    end
    return enumTable
end

function LSuperTools:toboolean(arg)
	if arg == nil then return false end
	if type(arg) == "number" then
		return CSuperTools:getInstance():itob(arg)
	elseif 	type(arg) == "string" then
		return CSuperTools:getInstance():atob(arg)
	end	
	return false
end

local ColorCodeValue = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G"}
ColorCodeValue[0] = "0"

-- RGB值转换为颜色码
function LSuperTools:changeRGBtoColorCode(_color)
	local c = ColorCodeValue
	local r1 = math.floor(_color.r / 16)
	local r2 = math.floor(_color.r % 16)
	local g1 = math.floor(_color.g / 16)
	local g2 = math.floor(_color.g % 16)
	local b1 = math.floor(_color.b / 16)
	local b2 = math.floor(_color.b % 16)
	local newC = "#"..c[r1]..c[r2]..c[g1]..c[g2]..c[b1]..c[b2]
	return newC
end

--计算字符串长度
function LSuperTools:calculateStringLen(_str, _fontSize)
	local lenInByte = #_str
	local width = 0
	 
	for i = 1, lenInByte do
		local curByte = string.byte(_str, i)
		local byteCount = 1
--		print("curByte:"..curByte)
		if curByte > 0 and curByte <= 127 then			--字母数字(英文)
--			print("byteCount == 1")
			byteCount = 1
		elseif curByte >= 192 and curByte <= 223 then
--			print("byteCount == 2")
			byteCount = 2
		elseif curByte >= 224 and curByte < 239 then	--文字
--			print("byteCount == 3")
			byteCount = 3
		elseif curByte >= 240 and curByte <= 247 then	
--			print("byteCount == 4")
			byteCount = 4
		else	--中文符号
--			print("byteCount == 5")
			byteCount = 5
		end
		 
		local char = string.sub(_str, i, i + byteCount - 1)
		i = i + byteCount -1

--		print("byteCount:"..byteCount)
		if byteCount == 1 then
--			width = width + _fontSize * 0.5
			local tempW = _fontSize * (14 / 26)
			width = width + tempW
		elseif byteCount == 2 or byteCount == 3 or byteCount == 4 then
--			width = width + _fontSize
			local tempW = _fontSize * (29 / 26)
			width = width + tempW
		else
			width = width + 1
		end
	end
	width = math.modf(width)
	height = math.modf(_fontSize * (34 / 26))-- + _fontSize * 0.1
--	print("总宽度:"..width.." 高度:"..height.." 字体大小:".._fontSize)
	return width, height
end


--下载图片写入本地
function LSuperTools:downloadPhoto(_url, _newName, _localPath, _backCall, _backArgList)
	print("LSuperTools:downloadPhoto  _url:".._url.."  _localPath:".._localPath)
	local test = string.split(_url, "http")
	if #test <= 1 then 
		print("url不合法")
		return
	end
	local function onRequestFinished(event, newName, path, backCall, backArgList)
		print("LSuperTools:downloadPhoto onRequestFinished  _url:".._url.."  _newName:".._newName.."  _localPath:".._localPath)
		
		local ok = (event.name == "completed")
		print("onRequestFinished")
		local request = event.request
		if not ok then
			-- 请求失败，显示错误代码和错误消息
			print(request:getErrorCode(), request:getErrorMessage())
			if backCall ~= nil then backCall(false, "error", backArgList) end
			return
		end

		local code = request:getResponseStatusCode()
		if code ~= 200 then
			-- 请求结束，但没有返回 200 响应代码
			print(code)
			if backCall ~= nil then backCall(false, "not 200", backArgList) end
			return
		end

		-- 请求成功，显示服务端返回的内容
		local response = request:getResponseString()
		print(response)
		
		--保存下载数据到本地文件，如果不成功，重试30次。
		local times = 1
		local newPath = path..newName
		print("savedata fileName:"..newPath)
		while (not request:saveResponseData(newPath)) and times < 30 do
			times = times + 1
		end
		local isOvertime = (times == 10) --是否超时
		if isOvertime then
			if backCall ~= nil then backCall(false, "overTIme", backArgList) end
		else
			if backCall ~= nil then backCall(true, "yes", backArgList) end
		end		
		
	end
	
	local request = network.createHTTPRequest(function (event)
		-- body
		if event.name == "completed" then
			onRequestFinished(event, _newName, _localPath, _backCall, _backArgList)
		end
		
	end, _url, "GET")
	request:start()
	
end
