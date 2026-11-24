-- lua client/tests/douniu_heartbeat.lua ScoketGame.lua ByteArray.lua Encrypt.lua
local socketPath, bytePath, encryptPath = assert(arg[1]), assert(arg[2]), assert(arg[3])
print = function() end
_G.unpack = table.unpack
local pack, unpack = string.pack, string.unpack
package.preload.pack = function()
    string.pack = function(fmt, v, ...)
        if fmt:sub(-1) == "A" then return v end
        if fmt:match("b%d+$") then return string.char(v, ...) end
        return pack(fmt, v)
    end
    string.unpack = function(data, fmt)
        local value, nextPos = unpack(fmt, data)
        return nextPos, value
    end
end
function class()
    local c = {}
    c.__index = c
    function c.new(...)
        local instance = setmetatable({}, c)
        instance:ctor(...)
        return instance
    end
    return c
end
cc = {utils = {ByteArray = dofile(bytePath)}}
local cipher = dofile(encryptPath)
for _, prefix in ipairs({"hall.network.", "src.socket.", "socket."}) do
    for _, name in ipairs({"PacketBuilder", "PacketParser", "ClockUtils", "PACKET_DATA_TYPE"}) do
        package.loaded[prefix .. name] = {}
    end
    package.loaded[prefix .. "Encrypt"] = cipher
end
package.loaded["framework.scheduler"] = {}
local service = dofile(socketPath)
for _, java in ipairs({false, true}) do
    JAVA_DOUNIU = java
    for _, tid in ipairs({0, 0x070a0001}) do
        HEART_BEAT_TID = tid
        local bytes = service:buildHeart()
        local route = java and 0 or 1
        local prefix = pack(">I4c2I2I4I2I2BB", 18, "BY", 1, 0x110, route, route, 0, tid == 0 and 0 or 0xee)
        local payload = tid == 0 and string.char(0x70,0x70,0x70,0x70) or string.char(0x45,0x2c,0x70,0x2f)
        assert(bytes:getPack() == prefix .. payload, socketPath)
    end
end
io.write("Verified both heartbeat routes and table IDs: ", socketPath, "\n")
