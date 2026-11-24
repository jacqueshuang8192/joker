-- lua client/tests/douniu_packets.lua src目录 PacketBuilder.lua NiuNiuProtocol.lua
local src, builderPath, protocolPath = assert(arg[1]), assert(arg[2]), assert(arg[3])
local function quiet() end
function class(_, parent)
    local c = setmetatable({}, {__index = parent})
    c.__index = c
    function c.new(...)
        local o = setmetatable({}, c)
        o:ctor(...)
        return o
    end
    return c
end

local pack = string.pack
package.preload.pack = function()
    -- Cocos lpack 使用 A 表示原始字符串。
    string.pack = function(fmt, v)
        if fmt:sub(-1) == "A" then return v end
        return pack(fmt, v)
    end
end
package.preload["hall.HALL_PROTOCOL"] = function() return {CONFIG = {CLIENT = {}, SERVER = {}}} end
local protocol
local types = dofile(src .. "/socket/PACKET_DATA_TYPE.lua")
function import(name)
    if name:match("PACKET_DATA_TYPE$") then return types end
    if name:match("NiuNiuProtocol$") then return protocol end
    error(name)
end
cc = {utils = {ByteArray = dofile(src .. "/framework/cc/utils/ByteArray.lua")}}
bm = {PACKET_DATA_TYPE = types, Logger = {new = function() return {enabled = quiet} end}}
local builder = dofile(builderPath)
print, dump = quiet, quiet
TpackageName, GROUP_MODE = "niuniu", 2
local out
bm.server = {
    createPacketBuilder = function(_, cmd) return builder.new(cmd, protocol.CONFIG.CLIENT[cmd], "hall", true) end,
    send = function(_, bytes) out = bytes:setPos(1):readBuf(bytes:getLen()) end
}

for _, javaRoom in ipairs({false, true}) do
    JAVA_DOUNIU = javaRoom
    protocol = dofile(protocolPath)
    local sender = dofile((protocolPath:gsub("NiuNiuProtocol.lua$", "NiuNiuSendHandle.lua")))
    local function check(cmd, value)
        local length, magic, version, opcode, game, biz = string.unpack(">I4c2I2I4I2I2", out)
        assert(length == #out - 4 and magic == "BY" and version == 1 and opcode == cmd)
        assert(game == (javaRoom and 0 or 1) and biz == game)
        assert(out:sub(19) == (javaRoom and pack(">i4", value) or ""))
    end
    sender:readyNow(1)
    check(0x2001, 1)
    sender:readyNow(0)
    check(0x2001, 0)
    sender:sitDown(3)
    check(0x1031, 3)
end
io.write("Verified Lua ready, cancel, seat selection and both hall routing modes\n")
