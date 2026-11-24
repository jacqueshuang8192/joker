-- 现有封包器按字节流工作。WebSocket 文本使用 Base64，保留包头和正文中的零字节。
local scheduler = require("framework.scheduler")
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local indices = {}
for i = 1, #alphabet do indices[alphabet:byte(i)] = i - 1 end

local function encode(bytes)
    local out = {}
    for i = 1, #bytes, 3 do
        local a, b, c = bytes:byte(i, i + 2)
        local n = a * 65536 + (b or 0) * 256 + (c or 0)
        local function digit(div)
            local pos = math.floor(n / div) % 64 + 1
            return alphabet:sub(pos, pos)
        end
        out[#out + 1] = digit(262144) .. digit(4096) .. (b and digit(64) or "=") .. (c and digit(1) or "=")
    end
    return table.concat(out)
end

local function decode(text)
    if type(text) ~= "string" or #text % 4 ~= 0 then return nil end
    local out = {}
    for i = 1, #text, 4 do
        local a, b, c, d = text:byte(i, i + 3)
        if not indices[a] or not indices[b] then return nil end
        if c == 61 and d ~= 61 then return nil end
        if (c == 61 or d == 61) and i + 3 ~= #text then return nil end
        if c ~= 61 and not indices[c] or d ~= 61 and not indices[d] then return nil end
        local n = indices[a] * 262144 + indices[b] * 4096 + (indices[c] or 0) * 64 + (indices[d] or 0)
        out[#out + 1] = string.char(math.floor(n / 65536)) ..
            (c ~= 61 and string.char(math.floor(n / 256) % 256) or "") ..
            (d ~= 61 and string.char(n % 256) or "")
    end
    return table.concat(out)
end

return function(socket, events, url)
    local generation = 0
    local active, timeout
    local function stopTimer()
        if timeout then scheduler.unscheduleGlobal(timeout); timeout = nil end
    end
    local function release(close)
        generation = generation + 1
        local old = active
        active = nil
        socket.isConnected = false
        stopTimer()
        if socket.reconnectScheduler then
            scheduler.unscheduleGlobal(socket.reconnectScheduler)
            socket.reconnectScheduler = nil
        end
        if old and close then old:close() end
    end
    function socket:connect(_, _, retry)
        if retry ~= nil then self.isRetryConnect = retry end
        release(true)
        local ws
        local function ended(close)
            if active ~= ws then return end
            local connected = self.isConnected
            release(close)
            local current = generation
            self:dispatchEvent({name = events.EVENT_CLOSE})
            if generation ~= current then return end
            self:dispatchEvent({name = connected and events.EVENT_CLOSED or events.EVENT_CONNECT_FAILURE})
            if generation == current then self:_reconnect() end
        end
        if cc.WebSocket then
            local ok, instance = pcall(function() return cc.WebSocket:create(url) end)
            if ok then ws = instance end
        end
        if not ws then
            local current = generation
            self:dispatchEvent({name = events.EVENT_CONNECT_FAILURE})
            if generation == current then self:_reconnect() end
            return
        end
        active = ws
        timeout = scheduler.performWithDelayGlobal(function() ended(true) end, 10)
        ws:registerScriptHandler(function()
            if active ~= ws then return end
            stopTimer()
            self.isConnected = true
            self:dispatchEvent({name = events.EVENT_CONNECTED})
        end, cc.WEBSOCKET_OPEN)
        ws:registerScriptHandler(function(text)
            if active ~= ws then return end
            local data = decode(text)
            if not data then ended(true); return end
            self:dispatchEvent({name = events.EVENT_DATA, data = data, partial = data})
        end, cc.WEBSOCKET_MESSAGE)
        ws:registerScriptHandler(function() ended(false) end, cc.WEBSOCKET_CLOSE)
        ws:registerScriptHandler(function() ended(true) end, cc.WEBSOCKET_ERROR)
    end
    function socket:send(bytes)
        assert(self.isConnected and active, "WebSocket is not connected")
        for i = 1, #bytes, 24576 do
            active:sendString(encode(bytes:sub(i, i + 24575)))
        end
    end
    function socket:_disconnect()
        release(true)
        self:dispatchEvent({name = events.EVENT_CLOSED})
    end
    function socket:close()
        release(true)
        self:dispatchEvent({name = events.EVENT_CLOSE})
    end
end
