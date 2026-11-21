-- GameTouchLayer.lua
-- Author: zzy
-- Date: 2019-01-09 11:00:46
-- 游戏触摸响应层

local scheduler = require("framework.scheduler")

local GameTouchLayer = class("GameTouchLayer", function()
    return display.newLayer()
end)

function GameTouchLayer:ctor()
    self.isTouch = false
    self.isMoved = false
    self.touchCounts = 0
    local size = cc.Director:getInstance():getWinSize()
    self:setContentSize(size.width,size.height)
    self:init()

    -- g_PHZMainScene:setRootSize(self)
end

function GameTouchLayer:init()
    print("---------GameTouchLayer:init()----------")
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return self:onTouchBegan(event.x, event.y)
        elseif event.name == "moved" then
            self:onTouchMoved(event.x, event.y)
        elseif event.name == "ended" then
            self:onTouchEnded(event.x, event.y)
        elseif event.name == "cancel" then
            self:onTouchCancelled(event.x, event.y)
        end
    end)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
end

function GameTouchLayer:onTouchBegan( x, y )
    self.isTouch = true
    g_CardScene:moveBeginCard()
    return true
end

function GameTouchLayer:onTouchMoved( x, y )
    self.isMoved = true
    g_CardScene:movingCard(x,y)
    g_PHZMainLayer:isShowTopOutLine(true)
    return true
end

function GameTouchLayer:onTouchEnded( x, y )
    --print("GameTouchLayer onTouchEnded x = , y = ", x,y)
    self.isTouch = false
    g_PHZMainLayer:isShowTopOutLine(false)

    --做连击判断  
    if self.isMoved then
        self.isMoved = false
        g_CardScene:moveCardEnd()
        return
    end

    if self.touchCounts == 1 then
        scheduler.performWithDelayGlobal(handler(self, self.updateDoubleDelay), 0.25)
        self.touchCounts = self.touchCounts + 1
    elseif self.touchCounts == 0 then
        scheduler.performWithDelayGlobal(handler(self, self.updateSingleDelay), 0.25)
        self.touchCounts = self.touchCounts + 1
    end
end

function GameTouchLayer:onTouchCancelled( x, y )
end

function GameTouchLayer:updateSingleDelay( ft )
    if self.touchCounts == 1 then
        self:onSingleCLick()
        self.touchCounts = 0 
    end
end
  
function GameTouchLayer:updateDoubleDelay( ft )
    if self.touchCounts == 2 then
        self:onDoubleClick()
        self.touchCounts = 0
    end
end

function GameTouchLayer:onSingleCLick()
    print("------GameTouchLayer:onSingleCLick()------")
    if g_CardScene:getTakeUpCard() then
        g_CardScene:setTakeUpCard()
    end
end

function GameTouchLayer:onDoubleClick()
    print("------GameTouchLayer:onDoubleClick()------")
    local outCard = g_CardScene:getTakeUpCard()
    -- if outCard and g_mainScene:ableOutCard() then
    --     g_CardScene:setSelectedCard(outCard)
    -- end
end

return GameTouchLayer

