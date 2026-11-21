--[[
    飘字提示框管理类
]]
local TipLayer = class("TipLayer", cc.Layer)
local scheduler = cc.load("scheduler")

local INTERVAL_TIME = 0.5 --检测间隔
local MAX_NUM = 5 --最大添加飘字提示框个数

function TipLayer:ctor()
    self.tipTb = {}
    self:enableNodeEvents()
 end

function TipLayer:onExit()
    self:closeTimer()
end

--[[
    添加单个飘字提示框
]]
function TipLayer:addTips(tipNode)
    if #self.tipTb >= MAX_NUM then
        printInfo("the tips num is more than max num")
        return
    end
    tipNode:retain()
    local tipItem = {tipNode = tipNode, isRunning = false}
    table.insert(self.tipTb, tipItem)

    self:startTimer()
    if #self.tipTb == 1 then
        self:runTipAction(self.tipTb[1])
    end
end

--[[
    关闭定时器
]]
function TipLayer:closeTimer()
    if self.tipTimerHandle then
        scheduler.unscheduleGlobal(self.tipTimerHandle)
        self.tipTimerHandle = nil
    end
end

--[[
    启动定时器
]]
function TipLayer:startTimer()
    if not self.tipTimerHandle then
        self.tipTimerHandle = scheduler.scheduleGlobal(handler(self, self.update), INTERVAL_TIME)
    end
end

function TipLayer:update(dt)
    if #self.tipTb == 0 then
        self:closeTimer()
        return
    end
    local tip = self:getNextTip()
    if tip then
        self:runTipAction(tip)
    end
end

--[[
    获取下一个飘字提示框
]]
function TipLayer:getNextTip()
    for _, tip in ipairs(self.tipTb) do
        if tip and not tip.isRunning then
            return tip
        end
    end
end

--[[
    执行飘字提示框动作
]]
function TipLayer:runTipAction(target)
    local moveBy1 = cc.MoveBy:create(0.8, cc.p(0, 70))
    local fadeIn = cc.FadeIn:create(0.3)
    local easeIn1 = cc.EaseIn:create(cc.Spawn:create({fadeIn, moveBy1}), 0.6)
    local moveBy2 = cc.MoveBy:create(0.7, cc.p(0, 70))
    local fadeOut = cc.FadeOut:create(0.7)
    local easeIn2 = cc.EaseIn:create(cc.Spawn:create({fadeOut, moveBy2}), 1)
    local callFunc = cc.CallFunc:create(function()
        for pos, tip in pairs(self.tipTb) do
            if tip == target then
                tip.tipNode:release()
                tip.tipNode:removeFromParent()
                table.remove(self.tipTb, pos)
                break
            end
        end
    end)
    target.isRunning = true
    target.tipNode:runAction(cc.Sequence:create({easeIn1, easeIn2, callFunc}))
    self:addChild(target.tipNode)
end

return TipLayer