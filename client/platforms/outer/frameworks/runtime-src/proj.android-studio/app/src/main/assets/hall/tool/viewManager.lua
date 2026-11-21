--[[
	视图管理类
-- ]]
local viewMgr = class("viewMgr")

function viewMgr:ctor()
end

--[[
	初始化视图管理对象
]]
function viewMgr:init(scene)
    self.tipList = {} --tip视图集合
end

--[[
	显示TIP信息提示框
]]
function viewMgr:showTip(params, pos)
    dump(params)
    print(debug.traceback("", 2))
    local Tip = require("hall.tool.tip")
    local tip = Tip.new(params)
    local tipPos = pos or display.CENTER
    local size = SCENENOW["scene"]:getContentSize()
    tip:setPosition(size.width / 2, size.height / 2)
    SCENENOW["scene"]:addChild(tip, 9999999)
    self:runTipAction(tip)
    -- dump(tip:getContentSize())
    -- dump(tip:getPosition())
    -- dump(tip)
end
function viewMgr:runTipAction(target)
    local moveBy1 = cc.MoveBy:create(0.8, cc.p(0, 70))
    local fadeIn = cc.FadeIn:create(0.3)
    local easeIn1 = cc.EaseIn:create(cc.Spawn:create({fadeIn, moveBy1}), 0.6)
    local moveBy2 = cc.MoveBy:create(0.7, cc.p(0, 70))
    local fadeOut = cc.FadeOut:create(0.7)
    local easeIn2 = cc.EaseIn:create(cc.Spawn:create({fadeOut, moveBy2}), 1)
    local callFunc =
        cc.CallFunc:create(
        function()
            target:release()
            target:removeFromParent()
            -- for pos, tip in pairs(self.tipTb) do
            --     if tip == target then
            --         tip.tipNode:release()
            --         tip.tipNode:removeFromParent()
            --         table.remove(self.tipTb, pos)
            --         break
            --     end
            -- end
        end
    )

    target:runAction(cc.Sequence:create({easeIn1, easeIn2, callFunc}))
end

--[[
	错误信息飘字显示
]]
function viewMgr:showErrorMsg(errorCode)
    self:showTip({text = errmsg(errorCode)})
end

--[[
	关闭指定tip信息提示框
]]
function viewMgr:closeTip(tip)
    self.tipList[tip] = nil
    tip:removeFromParent()
end

--[[
	关闭所有tip信息提示框
]]
function viewMgr:clearTips()
    for tip in pairs(self.tipList) do
        tip:removeFromParent()
        self.tipList[tip] = nil
    end
end

function viewMgr:setSceneScale(scene)
    local scenenow = SCENENOW["scene"]
    local csize = scenenow:getContentSize()
    local size = scene:getContentSize()
    local scale = 1
    if size.width > csize.width then
        scale = csize.width / size.width
    else
        scale = size.width / csize.width
    end
    if size.height > csize.height then
        scale = csize.height / size.height
    else
        scale = size.height / csize.height
    end
    scene:setScale(scale)
    if not tolua.isnull(scene.mask) then
        scene.mask:setScale(1 / scale)
    end
    scene:setAnchorPoint(0.5, 0.5)
    scene:setPosition(csize.width / 2, csize.height / 2)
end

function viewMgr:setScenePos(scene)
    local scenenow = SCENENOW["scene"]
    local csize = scenenow:getContentSize()
    scene:setAnchorPoint(0.5, 0.5)
    scene:setPosition(csize.width / 2, csize.height / 2)
end

function viewMgr:setMask(scene, flag, Opacity, color)
    if flag == nil then
        flag = false
    end
    if Opacity == nil then
        Opacity = 150
    end
    if color == nil then
        color = cc.c3b(0, 0, 0)
    end
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local ssize = SCENENOW["scene"]:getContentSize()
    local sssize = scene:getContentSize()
    local maskLayout = ccui.Layout:create()
    maskLayout:setContentSize(sssize)
    maskLayout:setAnchorPoint(cc.p(0.5, 0.5))
    maskLayout:setPosition(cc.p(sssize.width / 2, sssize.height / 2))
    maskLayout:setBackGroundColorType(1)
    maskLayout:setBackGroundColor(color)
    maskLayout:setBackGroundColorOpacity(Opacity)
    maskLayout:setTouchEnabled(true)
    maskLayout:setVisible(flag)
    scene:addChild(maskLayout, -1000)
    scene.maskLayout = maskLayout
end
return viewMgr
