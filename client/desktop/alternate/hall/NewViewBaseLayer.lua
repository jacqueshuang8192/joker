--[[
* author:   zwm
* date:     2019-03-11
* describe: 处理适配的基类
* explain:  1> 该基类，会对继承的对象里面的按钮(button) 做监听出来。
               要求在csd里面的按钮命名的时候以字符串"btn..."开头，回调的时候按钮响应的方法
               要定义在子类里。方法命名的规则："onClick"+"Btn...",即把按钮名字第一个字母该成
               大写，前面再加上"onClick"
--]]

local NewViewBaseLayer = class("NewNewViewBaseLayer", function()
    return display.newLayer("NewNewViewBaseLayer")
end)
local MASK_COLOR = cc.c3b(0, 0, 0)
NewViewBaseLayer.MASK_OPACITY = 150
local BTN_CLICK_VOICE = "hall/scene/res/common/music/Audio_Button_Click.mp3"

function NewViewBaseLayer:ctor(path, isAutoObj, isDoLayout)
    if tolua.isnull(self) then
        return
    end
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
   
    -- local director = cc.Director:getInstance()
    -- local size = director:getWinSize()
    -- SCREEN_WIDTH = size.width
    local node = nil 
    if device.platform == "ios" then
        if isiOSVerify then
            node = cc.CSLoader:createNode(path):addTo(self)
        else
            node = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. path):addTo(self)
        end
    else
        node = cc.CSLoader:createNode(path):addTo(self)
    end
    -- GameUtils.setNodeNameBindObj(node)
    if node == nil then
        print(string.format("load csb error, csb path is: %s ...", path))
        return
    end
    if isAutoObj == nil then
        isAutoObj = true
    end
    if isDoLayout == nil then
        isDoLayout = true
    end
    self.isDoLayout = isDoLayout
    self.isAutoObj = isAutoObj
     --local precent = self:_getScaleParam()
     --local y = node:getPositionY()
     --node:setPositionY(y*precent)
    self._csbNode = node
    self:_initUI()
    self:setMask()
end

function NewViewBaseLayer:_initUI()
    if self._csbNode then
        if self.isDoLayout then
            local make = self._csbNode:getChildByName("make")
            local root = self._csbNode:getChildByName("root")
            local bg = self._csbNode:getChildByName("bg")
           
            if root then
                root:setPositionX(SCREEN_WIDTH/2)
            end
            if bg then
                bg:setPositionX(SCREEN_WIDTH/2)
            end
            if make then
                make:setContentSize(cc.size(SCREEN_WIDTH/1280*make:getContentSize().width, make:getContentSize().height))
            end
        end
        if self.isAutoObj then
            self:_addToBtnListen(self._csbNode)
            self:_toGetObj(self._csbNode)
        end            
    end
end

function NewViewBaseLayer:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT

    return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function NewViewBaseLayer:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function NewViewBaseLayer:_addToBtnListen(node)
    if not node then return end

    local name = node:getName()
    if name == nil then return end
    
    local prevStr = string.sub(name, 1, 3)
    if prevStr == "btn" and tolua.type(node) == "ccui.Button" then
        local cStr = string.gsub(name,'b','B',1)
        local callBackStr = "onClick"..cStr
        self:_toBtnListen(node, callBackStr)
    end

    local child = node:getChildren()
    if #child ~= 0 then
        for i, v in ipairs( child or {} ) do
            self:_addToBtnListen(v)
        end
    end
    
end

function NewViewBaseLayer:_toBtnListen(obj, callBackStr)
    if device.platform == "windows" then
        local traceback = string.split(debug.traceback(), "\n")
		self.traceback = string.trim(traceback[8] or traceback[7] or traceback[6])
    end  

    local btnCallBack = function ( sender, event )
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
            require("hall.GameCommon"):playEffectSound(BTN_CLICK_VOICE)

            local clickPos = sender:getTouchBeganPosition()
			local widgetName = sender:getName() or ""
            print(string.format("控件名:%s, 点击位置[x:%d,y:%d]   %s",
			widgetName, clickPos.x, clickPos.y, self.traceback or ""))

        elseif  event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        elseif event == TOUCH_EVENT_ENDED then
            sender:setScale(1)
            if callBackStr and  type(self[callBackStr]) == "function" then
                self[callBackStr](self, sender, event)
                --print(string.format("button [%s]: not define corresponding function ...", sender:getName()))
            else
                self:removeSelf()
                print(string.format("button [%s]: callBackStr[%s] not define corresponding function ...", sender:getName(),callBackStr))
            end
        end
    end
    obj:addTouchEventListener(btnCallBack)
end

function NewViewBaseLayer:_toGetObj( node )
    if node == nil then return end

    if node.getName then
        --去掉csb命名的空格，加一层括号，只返回格式化后的字符串
        local name = (string.gsub(node:getName(), "^%s*(.-)%s*$", "%1")) 
        self[name] = node
    end

    local child = node:getChildren()
    if #child ~= 0 then
        for i, v in ipairs( child or {} ) do
            self:_toGetObj(v)
        end
    end
end

function NewViewBaseLayer:setMask()
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local ssize = SCENENOW["scene"]:getContentSize()
    local sssize = self._csbNode:getContentSize()
    if size.width < ssize.width then
        size.width = ssize.width
    end
    if size.height < ssize.height then
        size.height = ssize.height
    end
    if size.width < sssize.width then
        size.width = sssize.width
    end
    if size.height < sssize.height then
        size.height = sssize.height
    end
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setContentSize(size)
    self.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.maskLayout:setPosition(cc.p(size.width / 2, size.height / 2))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(MASK_COLOR)
    self.maskLayout:setBackGroundColorOpacity(NewViewBaseLayer.MASK_OPACITY)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(false)
    self:addChild(self.maskLayout, -1000)
    
end
--[[
    设置mask层可见行以及透明度
]]
function NewViewBaseLayer:enableMask(value, opacity)
    self.maskLayout:setVisible(value)
    self.maskLayout:setBackGroundColorOpacity(opacity or NewViewBaseLayer.MASK_OPACITY)
end

--[[
    获取mask层对象
]]
function NewViewBaseLayer:getMask()
    return self.maskLayout
end

function NewViewBaseLayer:setClickMaskClose()
    self.maskLayout:onClick(function(  )
        self:removeSelf()
    end)
end

function NewViewBaseLayer:commonRequest(interfaceName, data, callback, httpType, param)
	cct.createHttRq({
        url = HttpAddr .. interfaceName,
        date = data,
        type_= httpType,
        callBack = function(data)
            callback(data, param)
    	end })
end

function NewViewBaseLayer:onExit()
    if (type(self._eventHandles) == "table") then 
        for i, v in ipairs(self._eventHandles) do
            self:removeEventListener(v)
        end
        self._eventHandles = {}
        dump(self._eventHandles, "清除事件over-------self._eventHandles--------")
    end
end

return NewViewBaseLayer