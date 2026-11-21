

LMyTimer = class("LMyTimer")

local VALUE = 0.02
function LMyTimer:getInstance()
	if self._instance == nil then
		self._instance = LMyTimer.new()
	end
	return self._instance
end

function LMyTimer_update()
	LMyTimer:getInstance():update()
end

function LMyTimer_update_call()
	LMyTimer:getInstance():update_call()
end

function LMyTimer:ctor()
	--启动定时器
	local scheduler = cc.Director:getInstance():getScheduler()
	self._updateHandle = scheduler:scheduleScriptFunc(LMyTimer_update, VALUE, false)
	self._updateHandle_call = scheduler:scheduleScriptFunc(LMyTimer_update_call, 0, false)
	self._updateLine = {}
	self._updateLine_call = {}
	self._removeObjKey = ""
end

function LMyTimer:reset()
	for i, v in ipairs(self._updateLine) do
		v["needRecycle"] = true
	end
end

function LMyTimer:getCount()
	return #(self._updateLine)
end

function LMyTimer:isExist(_key)
	for i, v in ipairs(self._updateLine) do
		if v["key"] == _key then
			return true
		end
	end
	return false
end

--注册
function LMyTimer:register(_key, _this, _func, _interval, _time, ...)
	--最小只能是0.01秒
	if _time == nil or _time < -1 then _time = -1 end
	if _interval <= VALUE then _interval = VALUE end
	for i, v in ipairs(self._updateLine) do
		if v["key"] == _key then
			v["this"] = _this
			v["func"] = _func
			v["interval"] = _interval
			v["time"] = _time
			v["count"] = 0
			v["needRecycle"] = false
			v["argList"] = {...}
			return
		end
	end
	table.insert(self._updateLine, {
	["key"] = _key, 
	["this"] = _this,
	["func"] = _func, 
	["interval"] = _interval,
	["time"] = _time, 
	["count"] = 0,
	["needRecycle"] = false,
	["argList"] = {...}
	})
end

--取消
function LMyTimer:unregister(_key)
	for i, v in ipairs(self._updateLine) do
		if v["key"] == _key then
			v["needRecycle"] = true
			break
		end
	end
end

--延迟callFunc (封装)
function LMyTimer:delayCall(_this, _func, _interval)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local num = math.random(100000)
	local key = num.."_hehe_"..LMyTimer:getInstance():getCount()
	print("delayCall key:"..key)
	LMyTimer:getInstance():register(key, _this, _func, _interval, 1)
end

function LMyTimer:update()
	for i, v in ipairs(self._updateLine) do
		if v["needRecycle"] == false then
			if v["count"] >= v["interval"] then
				v["count"] = v["count"] - v["interval"]
				if v["time"] == -1 then	-- -1永久
					--call
					--[[
					if v["this"] ~= nil then
						v["func"](v["this"], v["key"], v["argList"])
					else
						v["func"](v["key"], v["argList"])
					end
					--]]
					table.insert(self._updateLine_call, {["this"] = v["this"], ["func"] = v["func"], ["key"] = v["key"], ["argList"] = v["argList"], ["time"] = v["time"]})
					
				elseif v["time"] == 0 then
					v["needRecycle"] = true
					if self._removeObjKey == "" then
						self._removeObjKey = v["key"]
					end
					
				elseif v["time"] > 0 then
					v["count"] = 0
					v["time"] = v["time"] - 1
					
					--call
					--[[
					if v["this"] ~= nil then
						v["func"](v["this"], v["key"], v["argList"], v["time"])
					else
						v["func"](v["key"], v["argList"], v["time"])
					end
					--]]
					table.insert(self._updateLine_call, {["this"] = v["this"], ["func"] = v["func"], ["key"] = v["key"], ["argList"] = v["argList"], ["time"] = v["time"]})
					
				end
				
			end
			v["count"] = v["count"] + VALUE * 1
		end
	end
	if self._removeObjKey ~= "" then
		for i, v in ipairs(self._updateLine) do
			if self._removeObjKey == v["key"] then
				table.remove(self._updateLine, i)
				break
			end
		end
		self._removeObjKey = ""
	end
end

function LMyTimer:update_call()
	if #self._updateLine_call > 0 then
		local v = self._updateLine_call[1]
		table.remove(self._updateLine_call, 1)
		--call
		if v["time"] == -1 then	-- -1永久
			if v["this"] ~= nil then
				v["func"](v["this"], v["key"], v["argList"])
			else
				v["func"](v["key"], v["argList"])
			end
		else
			if v["this"] ~= nil then
				v["func"](v["this"], v["key"], v["argList"], v["time"])
			else
				v["func"](v["key"], v["argList"], v["time"])
			end
		end
	end
end