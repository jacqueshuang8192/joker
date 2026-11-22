-- Run from the repo root with Lua 5.3+: lua client/tests/packet_receive.lua path/to/PacketParser.lua
-- The input is a valid pair of frames. Exercise every TCP split point through SocketService:onData.
local parserPath = assert(arg[1], "expected PacketParser.lua path")
local socketDir = assert(parserPath:match("^(.*)/PacketParser%.lua$"))
local servicePath = socketDir .. "/SocketService.lua"
local pack, nativeUnpack = string.pack, string.unpack
local function quiet() end
function class()
    local cls = {}
    cls.__index = cls
    function cls.new(...)
        local obj = setmetatable({}, cls)
        obj:ctor(...)
        return obj
    end
    return cls
end
-- quick-cocos2d-x lpack returns the next position before the decoded value.
package.preload.pack = function()
    string.unpack = function(data, fmt)
        fmt = fmt:gsub("A(%d+)", "c%1")
        local value, pos = nativeUnpack(fmt, data)
        return pos, value
    end
end
device = {platform = "windows"}
DEBUG = 0
print = quiet
printf = quiet
bm = {Logger = {new = function() return {enabled = quiet} end}}
local bytes = dofile(socketDir .. "/../framework/cc/utils/ByteArray.lua")
cc = setmetatable({utils = {ByteArray = bytes}}, {__call = function(_, obj)
    obj.addComponent = function() return {exportMethods = quiet} end
    return obj
end})
local types = dofile(socketDir .. "/PACKET_DATA_TYPE.lua")
local parser
function import(name)
    if name:match("PACKET_DATA_TYPE$") then return types end
    if name:match("PacketParser$") then return parser end
    if name:match("PacketBuilder$") then return {} end
    error(name)
end
local encoded = 0
json = {encode = function() encoded = encoded + 1; return "{}" end}
table.keyof = quiet
parser = dofile(parserPath)
local service = dofile(servicePath)
local cmd = 400
local payload = "game-data"
local protocol = {CONFIG = {SERVER = {[cmd] = {fmt = function(packet, buf)
    packet.payload = buf:readBuf(buf:getAvailable())
end}}}}
-- Use the byte order selected by the actual parser for this platform.
local probe = parser.new(protocol.CONFIG.SERVER, "scoket_chat", true)
probe:read(bytes.new(bytes.ENDIAN_BIG))
local endian = probe.buf_:getEndian() == bytes.ENDIAN_BIG and ">" or "<"
local function frame(code, body)
    return pack(endian .. "i4", 14 + #body) .. "BY\0\0" .. pack(endian .. "i4", code)
            .. string.rep("\0", 6) .. body
end
local stream = frame(cmd, payload) .. frame(272, "") .. frame(cmd, "ok")
local function check(parts)
    local client = service.new("chat-with-explicit-mode", protocol, true)
    local packets = {}
    function client:dispatchEvent(event)
        assert(event.name == service.EVT_PACKET_RECEIVED)
        packets[#packets + 1] = event.data
    end
    for _, part in ipairs(parts) do client:onData({data = part}) end
    assert(#packets == 3 and packets[1].cmd == cmd and packets[1].payload == payload)
    assert(packets[2].cmd == 272 and packets[3].cmd == cmd and packets[3].payload == "ok")
end
isShowNetLog = false
for split = 0, #stream do
    check({stream:sub(1, split), stream:sub(split + 1)})
end
local singles = {}
for i = 1, #stream do singles[i] = stream:sub(i, i) end
check(singles)
assert(encoded == 0, "disabled receive tracing should not JSON-encode decoded packets")
-- Exercise SocketService's diagnostic switch independently of the game's payload codec.
local normal = service.new("lobby", protocol, false)
local dispatched = 0
function normal:dispatchEvent(event)
    assert(event.name == service.EVT_PACKET_RECEIVED)
    dispatched = dispatched + 1
end
function normal.parser_:read()
    return true, {{cmd = cmd}, {cmd = 272}}
end
normal:onData({data = stream})
assert(encoded == 0 and dispatched == 2)
isShowNetLog = true
normal:onData({data = stream})
assert(encoded == 1 and dispatched == 4)
io.write("OK ", parserPath, "\n")
