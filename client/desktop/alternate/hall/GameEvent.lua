local EventProtocol = require("framework.cc.components.behavior.EventProtocol")
local GameEvent = class("GameEvent", EventProtocol)

--[[
local EXPORTED_METHODS = {
    "addEventListener",
    "dispatchEvent",
    "removeEventListener",
    "removeEventListenersByTag",
    "removeEventListenersByEvent",
    "removeAllEventListeners",
    "hasEventListener",
    "dumpAllEventListeners",
}
--]]
function GameEvent:ctor()
	GameEvent.super.ctor(self, "GameEvent")
	-- cc.bind(self, "event")
	-- cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    local dispatcher = cc.Director:getInstance():getEventDispatcher()

    local listenerBg = cc.EventListenerCustom:create("applicationDidEnterBackground", handler(self, self.onEnterBackground))
    dispatcher:addEventListenerWithFixedPriority(listenerBg, 1)

    local listenerFg = cc.EventListenerCustom:create("applicationWillEnterForeground", handler(self, self.onEnterForeground))
    dispatcher:addEventListenerWithFixedPriority(listenerFg, 1)
end

function GameEvent:onEnterBackground()
    self:dispatch("onEnterBackground")
end

function GameEvent:onEnterForeground()
    self:dispatch("onEnterForeground")
end

function GameEvent:addListen(event_name, event_func, event_tag)
    if event_name == nil then
        error("event_name is nil!")
        return
    end

    if event_func == nil then
        error("event_func is nil!")
        return
	end
	
	local function event_call_back(event)
		event_func(unpack(event.args))
	end

    local handle = self:addEventListener(event_name, event_call_back, event_tag)
	local tbl = {string.upper(tostring(event_name)), handle}
    return tbl
end

function GameEvent:delListen(tbl)
    if tbl == nil then
        return
    end

    if self.listeners_[tbl[1]] == nil then
        return
    end

	self.listeners_[tbl[1]][tbl[2]] = nil
end

function GameEvent:dispatch(event_name, ...)
    local event = {name = event_name, target = self, stop_ = false, stop = nil, tag = nil, args = {...}}
	self:dispatchEvent(event)
end

return GameEvent
