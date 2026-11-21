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

function NewViewBaseLayer:ctor(path)
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
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
    self._csbNode = node
    self:_initUI()
    self:setMask()
end

function NewViewBaseLayer:_initUI()
    if self._csbNode then
        if self._csbNode then
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

            --self:_addToBtnListen(self._csbNode)

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
    if prevStr == "btn" then
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
    local btnCallBack = function ( sender, event )
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
            --require("hall.GameCommon"):playEffectSound(BTN_CLICK_VOICE)
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
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setContentSize(cc.size(size.width, size.height))
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

return NewViewBaseLayer