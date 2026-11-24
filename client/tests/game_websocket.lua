-- Run with the packaged SocketTCP path to exercise the actual selection and connection lifecycle.
local dir = assert(arg[1]:match("^(.*)/SocketTCP.lua$"))
local timers, scheduled = {}, 0
package.preload["framework.scheduler"] = function() return {
    performWithDelayGlobal = function(fn) scheduled = scheduled + 1; timers[scheduled] = fn; return scheduled end,
    unscheduleGlobal = function(id) timers[id] = nil end
} end
package.preload.socket = function() return {} end
package.preload["framework.cc.net.WebSocketTransport"] = function() return dofile(dir .. "/WebSocketTransport.lua") end
function class()
    local c = {}
    c.__index = c
    function c.new(...)
        local s = setmetatable({}, c)
        s:ctor(...)
        return s
    end
    return c
end
function printInfo() end
local last
cc = setmetatable({WEBSOCKET_OPEN = 0, WEBSOCKET_MESSAGE = 1, WEBSOCKET_CLOSE = 2, WEBSOCKET_ERROR = 3,
    WebSocket = {create = function(_, url)
        local ws = {url = url}
        function ws:registerScriptHandler(fn, event) self[event] = fn end
        function ws:sendString(data) self.sent = data end
        function ws:close() self.closed = true; self[2]() end
        last = ws
        return ws
    end}}, {__call = function(_, s)
        s.events = {}
        function s:dispatchEvent(event) self.events[#self.events + 1] = event end
        return {addComponent = function() return {exportMethods = function() end} end}
    end})
local TCP = dofile(arg[1])
assert(TCP.new("localhost", 4700).connect == TCP.connect)
GAME_WSS_URL = "wss://game.example.com/"
assert(TCP.new("localhost", 1234).connect == TCP.connect)
for _, record in ipairs({{4700, "/ws/hall"}, {"13600", "/ws/douniu"}}) do
    local client = TCP.new("localhost", record[1], true)
    client:connect()
    local first = last
    assert(first.url == "wss://game.example.com" .. record[2])
    first[0]()
    assert(client.isConnected and client.events[1].name == TCP.EVENT_CONNECTED)
    local raw = "\0\255abc\0"
    client:send(raw)
    assert(first.sent == "AP9hYmMA")
    first[1](first.sent)
    assert(client.events[2].data == raw)
    first[1]("eA=="); assert(client.events[3].data == "x")
    first[1]("eHk="); assert(client.events[4].data == "xy")
    first[2]()
    assert(not client.isConnected and client.events[6].name == TCP.EVENT_CLOSED)
    first[3](); assert(#client.events == 6)
    timers[client.reconnectScheduler]()
    assert(last ~= first)
    first[0](); assert(not client.isConnected)
    last[0](); client:disconnect()
    assert(last.closed and not client.isConnected and next(timers) == nil)
end
print("Passed transport selection, Base64 bytes, close and reconnect: " .. dir)
