local socket = require("socket.core")
function os.now()
    return socket.gettime()
end

function table.empty(t)
    return _G.next(t) == nil
end

function table.is_include(tbl, value)
    for k,v in pairs(tbl) do
      if v == value then
          return true
      end
    end
    return false
end
--lag:len不够也添加 bool
function table.slice(tbl,start,len,lag)
	if start == 0 then
		start = 1
	end
	local endin=start+len - 1
	local tab={}
	if endin > #tbl and lag == nil then
		return tab
	end
	for i=start,endin do
		if tbl[i] then
			table.insert(tab, tbl[i])
		end
    end
    return tab
end

function table.splice(tbl,start,len)
    local tab={}
    local ended = start + len - 1
    for idx = start, ended do
		local data = table.remove(tbl, start)
		table.insert(tab, data)
    end
    return tab
end

function table.pop(tbl)
	if #tbl == 0 then
		return {}
	end
    return table.remove(tbl, #tbl)
end


function tableConcat(...)
	local tabs = {...}
    if not tabs then
        return {}
    end
    local origin = clone(tabs[1])
    for i = 2,#tabs do
        if origin then
            if tabs[i] then
                for k,v in ipairs(tabs[i]) do
                    table.insert(origin,v)
                end
            end
        else
            origin = tabs[i]
        end
    end
    return origin
end

local Widget = ccui.Widget
function Widget:getTouchListener()
	return self.touchListener
end

function Widget:onTouch(callback, isScale, clickTime)

	
	if device.platform == "windows" then
        local traceback = string.split(debug.traceback(), "\n")
		self.traceback = string.trim(traceback[4] or traceback[3] or traceback[2])
    end  
	self.touchListener = callback
	self:setTouchEnabled(true)
	local canScale = false
	local startScaleX = self:getScaleX()
	local startScaleY = self:getScaleY()
	canScale = isScale
	if tolua.type(self) == "ccui.Button" then
		if isScale == nil then
			canScale = true
		end
		self:setZoomScale(0)
		self:setPressedActionEnabled(false)
	end
	if canScale then
		local size = self:getContentSize()
		local pos = self:getPosition()
		local startX, startY = pos.x, pos.y
		local anchorPos = self:getAnchorPoint()
		self:setPosition(startX + size.width * (0.5 - anchorPos.x), startY + size.height * (0.5 - anchorPos.y))
		self:setAnchorPoint(cc.p(0.5,0.5))
	end
	self:addTouchEventListener(function(sender, state)
		local event = {}
		local pos
		if state == 0 then
			event.name = "began"
			pos = self:getTouchBeganPosition()
			if canScale then self:setScaleX(startScaleX*0.9) self:setScaleY(startScaleY*0.9) end
			local clickPos = self:getTouchBeganPosition()
			local widgetName = self:getName() or ""
			-- local viewName = viewMgr:getViewNameByChild(self)
			-- print(string.format("视图[%s], 控件名:%s, 点击位置[x:%d,y:%d]",
			-- viewName, widgetName, clickPos.x, clickPos.y))
			print(string.format("控件名:%s, 点击位置[x:%d,y:%d]   %s",
			widgetName, clickPos.x, clickPos.y, self.traceback or ""))
			
			local newPos = self:getParent():convertToNodeSpace(clickPos);
			require("hall.GameCommon"):onClickSound()

		elseif state == 1 then
			event.name = "moved"
			pos = self:getTouchMovePosition()
		elseif state == 2 then
			event.name = "ended"
			pos = self:getTouchEndPosition()
            if canScale then self:setScaleX(startScaleX) self:setScaleY(startScaleY) end
            local time = os.now()
            if clickTime and sender.clickTime and (time - sender.clickTime) < clickTime then
                viewMgr:showTip({text = "操作太频繁！"})
                return
            end
            if clickTime then
                sender.clickTime = time
            end
		else
			event.name = "cancelled"
			pos = self:getTouchMovePosition()
			if canScale then self:setScaleX(startScaleX) self:setScaleY(startScaleY) end
		end
		event.target = sender
		event.x = pos.x
		event.y = pos.y
		callback(event)
	end)
	return self
end

function Widget:onClick(callback, isScale, clickTime)
	-- isScale = not (isScale == false)
	self:onTouch(function(event)
		if event.name == "ended" then
			callback(event)
		end
	end, isScale, clickTime)
end

function calculateDistance(latitude1,latitude2,longitude1,longitude2)
    if not (latitude1 and latitude2 and longitude1 and longitude2) then
        return
    end
    local radLat1 = latitude1 * math.pi / 180.0
    local radLat2 = latitude2 * math.pi / 180.0
    local a = radLat1 - radLat2
    local b = (longitude1 - longitude2) * math.pi / 180.0
    local s = 2 * math.asin(math.sqrt(math.pow(math.sin(a / 2), 2)
            + math.cos(radLat1) * math.cos(radLat2)
            * math.pow(math.sin(b / 2), 2)))
    s = s * 6378137.0
    s = math.round(s * 10000) / 10000;
    return s
end


function handler(obj, method)
	return function(...)
		if obj and type(method) == "function" then
			return method(obj, ...)
		else
			return function(...) end
		end
	end
end

function display.doLayout(panel,bg)
	local director = cc.Director:getInstance()

	-- local truesize = cc.Director:getInstance():getVisibleSize()
	local size = director:getWinSize()
	if panel then
		-- local chis = panel:getChildren()
		-- local psize = panel:getContentSize()
		-- local scaX = size.width / psize.width
		-- local scaY = size.height / psize.height
		-- for i,node in ipairs(chis) do
		-- 	if tolua.type(node) == "ccui.Layout" then
		-- 		local cSize = node:getSize()
		-- 		local pos = node:getPosition()
		-- 		-- node:setPosition(pos.x * scaX, pos.y * scaY)
		-- 		node:setContentSize(cSize.width * scaX, cSize.height * scaY)
		-- 		ccui.Helper:doLayout(node)

		-- 	end
		-- end
        panel:setContentSize(size)
        ccui.Helper:doLayout(panel)
	end

    ---[[拉升上下两个按钮菜单层背景
    --等比拉伸背景
    if bg then
        local bsize = bg:getContentSize()
        local scaX = size.width / bsize.width
		local scaY = size.height / bsize.height
		bg:setContentSize(size)
		ccui.Helper:doLayout(bg)
		-- bg:setContentSize(size.width, size.height)
        -- if scaX > scaY then
        --     bg:setScale( scaX )
        -- else
        --     bg:setScale( scaY )
        -- end
    end
end

local Node = cc.Node
function Node:removeSelf()
	if not tolua.isnull(self) then
		self:removeFromParent(true)
    end
end


function setGrayNode(node, flag)
    local cache = cc.GLProgramCache:getInstance()
    local name, shader = nil, nil
 
    if flag then
        name = "MQ_ShaderPositionTextureGray"
        shader = cache:getGLProgram(name)
 
        if not shader then
            shader = cc.GLProgram:createWithByteArrays(
            -- vertex shader
            [[
            attribute vec4 a_position;
            attribute vec2 a_texCoord;
            attribute vec4 a_color;
 
            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;
 
            void main()
            {
                gl_Position = CC_PMatrix * a_position;
                v_fragmentColor = a_color;
                v_texCoord = a_texCoord;
            }
            ]],
            -- fragment shader
            [[
            varying vec2 v_texCoord;
            varying vec4 v_fragmentColor;
 
            void main()
            {
                vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
                float gray = dot(v_orColor.rgb, vec3(0.299, 0.587, 0.114));
                gl_FragColor = vec4(gray, gray, gray, v_orColor.a);
            }
            ]]
            )
            cache:addGLProgram(shader, name)
        end
    else
        name = "ShaderPositionTextureColor_noMVP"
        shader = cache:getGLProgram(name)
    end
 
    -- 不用调用
    --shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    --shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    --shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
 
    -- 不用调用
    --shader:link()
    --shader:updateUniforms()
 
    local errno = gl.getError()
    if errno ~= 0 then print("gl error:", errno) end
 
    local list = {}
 
    if tolua.type(node) == "ccui.Button" then
        -- cocos2dx 3.3 release，而起需要修改 UIButton.cpp
        local render
 
        render = node:getProtectedChildByTag(1)
        if render then table.insert(list, render:getSprite()) end
 
        render = node:getProtectedChildByTag(2)
        if render then table.insert(list, render:getSprite()) end
 
        render = node:getProtectedChildByTag(3)
        if render then table.insert(list, render:getSprite()) end
 
        -- cocos2dx 3.3 rc
        --if node:getRender(0) then table.insert(list, node:getRender(0):getSprite()) end
        --if node:getRender(1) then table.insert(list, node:getRender(1):getSprite()) end
        --if node:getRender(2) then table.insert(list, node:getRender(2):getSprite()) end
    else
        table.insert(list, node)
    end
 
    for i, v in ipairs(list) do
        -- 这里设置 shader
        v:setGLProgram(shader)
        -- 这里调用了才起效果
        v:getGLProgram()
    end
end

function tableToStr(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 10 end
    local lookupTable = {}
    local result = {}
    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end
    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then

            local str_1 = indent
            local str_2 = _v(desciption)
            local str_3 = spc
            local str_11 = (string.gsub(str_1, " ", ""))
            local str_22 = (string.gsub(str_2, " ", ""))
            local str_33 = (string.gsub(str_3, " ", ""))
            if str_11 ~= "" then
                str_1 = "[" .. str_1 .. "]"
            end
            if str_22 ~= "" then
                str_2 = "[" .. str_2 .. "]"
            end
            if str_33 ~= "" then
                str_3 = "[" .. str_3 .. "]"
            end
            result[#result +1 ] = string.format("%s%s%s = %s,", str_1, str_2, str_3, _v(value))

            -- result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                local str_1 = indent
                local str_2 = _v(desciption)
                local str_3 = spc
                local str_11 = (string.gsub(str_1, " ", ""))
                local str_22 = (string.gsub(str_2, " ", ""))
                local str_33 = (string.gsub(str_3, " ", ""))
                if str_11 ~= "" then
                    str_1 = "[" .. str_1 .. "]"
                end
                if str_22 ~= "" then
                    str_2 = "[" .. str_2 .. "]"
                end
                if str_33 ~= "" then
                    str_3 = "[" .. str_3 .. "]"
                end
                result[#result +1 ] = string.format("%s%s = {", str_1, str_2)

                -- result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s},", indent)
            end
        end
    end
    _dump(value, desciption, "", 1)

    -- for i, line in ipairs(result) do
    --     print(line)
    -- end
    local str = ""
    for i, line in ipairs(result) do
        local tmp = line
        if i == 1 then
            -- line = "self.datad = {"
        elseif i == #result then
            line = string.gsub(line, ",", "")
        end
        -- print(line.."")
        str = str .. line.."\n"
	end
    print(str)
	return str
end
local function checkArguments(args, sig,type_)
    if type(args) ~= "table" then args = {} end
    if sig then return args, sig end

    sig = {"("}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    if not next(args) then
        if type_ == "string" then
            sig[#sig + 1] = "Ljava/lang/String;"
        elseif type_ == "number" then
            sig[#sig + 1] = "F"
        elseif type_ =="V" then
            sig[#sig + 1] = ")V"
        elseif type_ =="function" then
            sig[#sig + 1] = "I"
        end
    else
        sig[#sig + 1] = ")V"
    end
    return args, table.concat(sig)
end

function callStaticMethod_new(className, methodName, args, sig,type_)
    local args, sig = checkArguments(args, sig,type_)
    print("callLua")
    print(methodName,sig)
    dump(args,"args")
    return LuaJavaBridge.callStaticMethod(className, methodName, args, sig)
end

function copyDumpLog( str )
    if type(str) ~= "string" or type(str) ~= "tonumber" then
        str = ""
    end
    str = str.."----" ..debug.traceback("", 2).."\n"
    local tiem = os.date("%Y-%m-%d %H:%M:%S", os.time())
    str = "\n--" .. tiem .. "\n" .. str .. "\n\n\n\n"
    if not copyDumpLogStr then
        copyDumpLogStr = ""
    end
    copyDumpLogStr = copyDumpLogStr..str
    require(GameSetting_filePath):copyToClipboard(copyDumpLogStr) 
end

if type(printW) ~= "function" then
    function printW(  )
    end
end

function dumpW(value, desciption, nesting)

    if not showDumpData then
        --todo
        return;
    end
    -- showDumpData = false

    local time = os.date("%Y-%m-%d %H:%M:%S", os.time())
    if not desciption and os.now then
        desciption = time..os.now()
    elseif tostring(desciption) and os.now then
        desciption = tostring(desciption).."--"..time.."--"..os.now()
    end

    if type(nesting) ~= "number" then nesting = 10 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local traceback = string.split(debug.traceback("", 2), "\n")
    printW("dump from: " .. string.trim(traceback[3]))

    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then

            local str_1 = indent
            local str_2 = _v(desciption)
            local str_3 = spc
            local str_11 = (string.gsub(str_1, " ", ""))
            local str_22 = (string.gsub(str_2, " ", ""))
            local str_33 = (string.gsub(str_3, " ", ""))
            if str_11 ~= "" then
                str_1 = "[" .. str_1 .. "]"
            end
            if str_22 ~= "" then
                str_2 = "[" .. str_2 .. "]"
            end
            if str_33 ~= "" then
                str_3 = "[" .. str_3 .. "]"
            end
            result[#result +1 ] = string.format("%s%s%s = %s,", str_1, str_2, str_3, _v(value))

            -- result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                local str_1 = indent
                local str_2 = _v(desciption)
                local str_3 = spc
                local str_11 = (string.gsub(str_1, " ", ""))
                local str_22 = (string.gsub(str_2, " ", ""))
                local str_33 = (string.gsub(str_3, " ", ""))
                if str_11 ~= "" then
                    str_1 = "[" .. str_1 .. "]"
                end
                if str_22 ~= "" then
                    str_2 = "[" .. str_2 .. "]"
                end
                if str_33 ~= "" then
                    str_3 = "[" .. str_3 .. "]"
                end
                result[#result +1 ] = string.format("%s%s = {", str_1, str_2)

                -- result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s},", indent)
            end
        end
    end
    _dump(value, desciption, "", 1)

    -- for i, line in ipairs(result) do
    --     printW(line)
    -- end
    local str = ""
    for i, line in ipairs(result) do
        local tmp = line
        if i == 1 then
            -- line = "self.datad = {"
        elseif i == #result then
            line = string.gsub(line, ",", "")
        end
        -- printW(line.."")
        str = str .. line.."\n"
    end
    printW(str)

end

function dumpWs(...)
    local tab = {...}
    for i,v in ipairs(tab) do
        dumpW(v)
    end
end