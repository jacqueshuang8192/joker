--[[
    视图父类
]]

local ViewBase = class("ViewBase", cc.Node)

local MASK_COLOR = cc.c3b(0, 0, 0)
ViewBase.MASK_OPACITY = 150

function ViewBase:ctor()
    self:enableNodeEvents()
    --mask层
    self.maskLayout = ccui.Layout:create()
    self.maskLayout:setContentSize(display.size)
    self.maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.maskLayout:setBackGroundColorType(1)
    self.maskLayout:setBackGroundColor(MASK_COLOR)
    self.maskLayout:setBackGroundColorOpacity(ViewBase.MASK_OPACITY)
    self.maskLayout:setTouchEnabled(true)
    self.maskLayout:setVisible(false)
    self:addChild(self.maskLayout, -1000)
    -- self:setAnchorPoint(cc.p(0.5, 0.5))
    -- self:setContentSize( display.LayerSize )
    --获取csb名字
    local uiFile = rawget(self.class, "UI_FILE")
    if uiFile then
        self:createUINode(uiFile)
    end
    if self.onCreate then self:onCreate() end
end

--[[
    设置该视图关联Model对象
]]
function ViewBase:setModel(model)
    self.model = model
end

--[[
    获取该视图关联Model对象
]]
function ViewBase:getModel()
    return self.model
end

--[[
    返回显示本窗口时，是否要隐藏其他窗口
]]
function ViewBase:isHideOther()
    return false
end

function ViewBase:onEnter()

end
--[[
    获取加载UI文件创建的节点对象
]]
function ViewBase:getUINode()
    return self.uiNode
end

--[[
    递归获取指定名字的子对象，根节点为UI文件场景的节点对象
]]
function ViewBase:getUIChild(name)
    if self.uiNode then
        return self:seekChild(self.uiNode, name)
    end
end

--[[
    递归获取指定名字的子对象
]]
function ViewBase:seekChild(parent, name)
    if tolua.isnull(parent) then
        return
    end

    -- print("ViewBase:seekChild", parent:getName() , name)
    if parent:getName() == name then
        return parent
    end

    local children = parent:getChildren()
    for _, child in pairs(children) do
        local node = self:seekChild(child, name)
        if node then
            return node
        end
    end
end

--[[
    添加Model事件监听，并当本视图销毁时自动移除通过本接口添加的事件
]]
function ViewBase:addModelEvent(eventName, method)
    assert(self.model, "the self.model is nil")
    local handle
    if table.keyof(self.class, method) then
        handle = self.model:addEventListener(eventName, handler(self, method))
    else
        handle = self.model:addEventListener(eventName, method)
    end
    self.modelEventHandles = self.modelEventHandles or {}
    self.modelEventHandles[handle] = true
    return handle
end

--[[
    通过csb文件创建节点
]]
function ViewBase:createUINode(uiFile)
    if self.uiNode then
        self.uiNode:removeSelf()
        self.uiNode = nil
    end
   

    self.uiNode = cc.CSLoader:createNode(uiFile)
    assert(self.uiNode, string.format("ViewBase:createUINode() - load ui node from file \"%s\" failed", uiFile))
    GameUtils.setNodeNameBindObj(self.uiNode)
    self.uiNode:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.uiNode)
    -- ccui.Helper:doLayout(self.uiNode)
end

--[[
    创建新的场景对象，并把该视图现在这个创建对象中
]]
function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene()
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

--[[
    设置mask层可见行以及透明度
]]
function ViewBase:enableMask(value, opacity)
    self.maskLayout:setVisible(value)
    self.maskLayout:setBackGroundColorOpacity(opacity or ViewBase.MASK_OPACITY)
end

--[[
    获取mask层对象
]]
function ViewBase:getMask()
    return self.maskLayout
end

--[[
    设置分辨率
]]
function ViewBase:updateLayoutSize()
    local node = self:getUINode()
    if node then
        display.doLayout(node, node.imgBg)
    end
end

--[[
    移除UI纹理资源
]]
function ViewBase:removeUIRes(plistFile)
    local pngFile = string.sub(plistFile, 1, #plistFile - 5) .. "png"
    display.removeSpriteFrames(plistFile, pngFile)
end

--[[
    检查UI纹理资源是否已经加载
]]
function ViewBase:isLoadedUIRes(plistFile)
    return cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded(plistFile)
end

--[[
    加载UI纹理资源
]]
function ViewBase:loadUIRes(plistFile)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plistFile)
end

--[[
    视图销毁时回调，在该函数中处理清理逻辑
]]
function ViewBase:onExit()
    cc.Node.onExit(self)
    if self.modelEventHandles then
        for handle in pairs(self.modelEventHandles) do
            self.model:removeEventListener(handle)
        end
    end
end

--[[
设置图片大小
    @node
    @maxWidth
    @maxHeight
    @isMin boolean 宽高小于最大值就放大 默认缩小
]]
function ViewBase:setTextureSize(node, maxWidth, maxHeight, isMin)
    node:ignoreContentAdaptWithSize(true)
    local size = node:getContentSize()
    local scaleX = 1
    local scaleY = 1
    local scale = 1
    if maxWidth and (size.width > maxWidth or isMin) then
        scaleX = maxWidth / size.width
    end
    if maxHeight and (size.height > maxHeight or isMin) then
        scaleY = maxHeight / size.height
    end
    if scaleX < scaleY then
        scale = scaleX
    else
        scale = scaleY
    end
    node:setScale(scale)
end

function ViewBase:getZOrderByChilds(parent, ZOrder)
    local childs = parent:getChildren()
    local maxZOrder = ZOrder
    if maxZOrder == nil then
        maxZOrder = 0
    end
    for i,node in ipairs(childs) do
        local zOrder = node:getLocalZOrder()
        if maxZOrder < zOrder then
            maxZOrder = zOrder
        end
        -- local childs1 = node:getChildren()
        -- if #childs1 >= 1 then
        --     ViewBase:getZOrderByChilds(node, maxZOrder)
        -- end
    end
    print(maxZOrder,"---------------ASDfaSDF")

    return maxZOrder
end

return ViewBase
