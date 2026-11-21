--[[
* author:   zwm
* date:     2019-03-11
* describe: 处理适配的基类
* explain:  1> 该基类，会对继承的对象里面的按钮(button) 做监听出来。
               要求在csd里面的按钮命名的时候以字符串"btn..."开头，回调的时候按钮响应的方法
               要定义在子类里。方法命名的规则："onClick"+"Btn...",即把按钮名字第一个字母该成
               大写，前面再加上"onClick"
--]]

local ViewBaseLayer = class("ViewBaseLayer", function()
    return display.newLayer("ViewBaseLayer")
end)
local MASK_COLOR = cc.c3b(0, 0, 0)
ViewBaseLayer.MASK_OPACITY = 150
local BTN_CLICK_VOICE = "hall/scene/res/common/music/Audio_Button_Click.mp3"

function ViewBaseLayer:ctor(path, isDoLayout)
    self:setNodeEventEnabled(true)
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

    if node == nil then
        print(string.format("load csb error, csb path is: %s ...", path))
        return
    end
     --local precent = self:_getScaleParam()
     --local y = node:getPositionY()
     --node:setPositionY(y*precent)
     --mask层
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setContentSize(cc.Director:getInstance():getOpenGLView():getDesignResolutionSize())
    -- dump(cc.Director:getInstance():getOpenGLView():getDesignResolutionSize())
    self.maskLayout:setAnchorPoint(cc.p(0, 0))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(MASK_COLOR)
    self.maskLayout:setBackGroundColorOpacity(ViewBaseLayer.MASK_OPACITY)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(false)
    self:addChild(self.maskLayout, -1000)

    self._csbNode = node
    if isDoLayout == nil then
        isDoLayout = true
    end
    self.isDoLayout = isDoLayout
    self:_initUI()
end

function ViewBaseLayer:_initUI()
    if self._csbNode then
        local bg = self._csbNode:getChildByName("bg")
        local precent = self:_getScaleParam2()
        if bg and self.isDoLayout then
            bg:setScaleX(bg:getScale()*precent)
            local x = bg:getPositionX()
            bg:setPositionX(x*precent)
        end

        local root = self._csbNode:getChildByName("root")
        if root and self.isDoLayout then
            --local k1 = CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH
            --local k2 = CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
            ----root:setContentSize(cc.size(CONFIG_DESIGN_WIDTH * math.min(k1,k2) ,CONFIG_DESIGN_HEIGHT * math.min(k1,k2) ))
            --root:setScaleX(CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)
            --root:setScaleY(CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT)
            local child = root:getChildren()
            for i, v in ipairs( child or {} ) do
                local x = v:getPositionX()
                v:setPositionX(x*precent)
                if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                    local size = v:getContentSize()
                    v:setContentSize(cc.size(size.width * precent, size.height))
                end
            end
        end

        self:_addToBtnListen(self._csbNode)

        self:_toGetObj(self._csbNode)
    end
end


function ViewBaseLayer:doLayoutPosition(node)
    local precent = self:_getScaleParam2()
    local x = node:getPositionX()
    -- node:setPositionX(x*precent)
    node:setPositionX(SCREEN_WIDTH/2)

end

function ViewBaseLayer:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT

    return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function ViewBaseLayer:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    print("ViewBaseLayer _getScaleParam2-------", (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0)))
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function ViewBaseLayer:_addToBtnListen(node)
    if tolua.isnull(node) then
        print("ViewBaseLayer --------------------- add to is null",  debug.traceback())
    end
    if not node or tolua.isnull(node) then return end

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

function ViewBaseLayer:_toBtnListen(obj, callBackStr)
    if device.platform == "windows" then
        local traceback = string.split(debug.traceback(), "\n")
		self.traceback = string.trim(traceback[12] or traceback[9] or traceback[8])
    end  
    local btnCallBack = function ( sender, event )
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)

            local clickPos = sender:getTouchBeganPosition()
			local widgetName = sender:getName() or ""
            print(string.format("控件名:%s, 点击位置[x:%d,y:%d]   %s",
			widgetName, clickPos.x, clickPos.y, self.traceback or ""))

            require("hall.GameCommon"):playEffectSound(BTN_CLICK_VOICE)
        elseif  event == TOUCH_EVENT_CANCELED then
            sender:setScale(1)
        elseif event == TOUCH_EVENT_ENDED then
            sender:setScale(1)
            if callBackStr and   type(self[callBackStr]) == "function" then
                self[callBackStr](self, sender, event)
                --print(string.format("button [%s]: not define corresponding function ...", sender:getName()))
            else
                self:removeSelf()
                print(string.format("button [%s]: callBackStr[%s] not define corresponding function ...", sender:getName(),callBackStr))
            end
        end
    end
    if self[callBackStr] and type(self[callBackStr]) == "function" then
        obj:addTouchEventListener(btnCallBack)
    end
end

function ViewBaseLayer:_toGetObj( node )
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

--[[
    设置mask层可见行以及透明度
]]
function ViewBaseLayer:enableMask(value, opacity)
    self.maskLayout:setVisible(value)
    self.maskLayout:setBackGroundColorOpacity(opacity or ViewBaseLayer.MASK_OPACITY)
end

--[[
    获取mask层对象
]]
function ViewBaseLayer:getMask()
    return self.maskLayout
end

return ViewBaseLayer