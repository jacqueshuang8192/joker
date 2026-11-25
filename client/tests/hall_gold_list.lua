-- 用实际打包的协议与解包器读取 0x151 的嵌套座位和空密码数组。
local hall, byteArrayFile = arg[1], arg[2]
local pack, unpackValue = string.pack, string.unpack
function class()
    local t = {}; t.__index = t
    function t.new(...)
        local o = setmetatable({}, t)
        o:ctor(...)
        return o
    end
    return t
end
package.preload.pack = function()
    string.unpack = function(data, fmt)
        local value, nextPos = unpackValue(fmt:gsub("A(%d+)", "c%1"), data)
        return nextPos, value
    end
end
local types = dofile(hall .. "/network/PACKET_DATA_TYPE.lua")
bm = {PACKET_DATA_TYPE = types, Logger = {new = function() return {enabled = function() end} end}}
cc = {utils = {ByteArray = dofile(byteArrayFile)}}
function import() return types end
device = {platform = "windows"}
function print() end
printf, dump = print, print
json = {encode = function() return "{}" end}
local protocol = dofile(hall .. "/HALL_PROTOCOL.lua")
local parser = dofile(hall .. "/network/PacketParser.lua").new(protocol.CONFIG.SERVER,"hall",true)
local function str(value) return pack(">I4", #value + 1) .. value .. "\0" end
local function read(body)
    local frame = pack(">I4c2I2I4I4I2", #body+14, "BY",1,0x151,0,0) .. body
    local bytes = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    bytes:writeBuf(frame):setPos(1)
    return parser:parsePacket_(bytes)
end
local row = pack(">i4i4",150,12)..str("420731")..str("牛牛")..pack(">Bi4i4Bi4",2,100,2,4,301)
    ..str("房主")..str("")..pack(">i4Bii",0,2,0,3)
local result = read(pack(">BI2",0,1)..row..str(""))
assert(result.cmd == 0x151 and result.tableListSize == 1)
local t = result.tableList[1]
assert(t.tid == 150 and t.invity_code == "420731" and t.play_nums == 2 and t.userMap[2] == 3)
assert(result.tablePasswordList[1] == "")
assert(#read(pack(">BI2",0,0)).tableList == 0)
