-- 调用实际大厅入口，两种后端使用同一打包脚本。
HallHandle_filePath, ServerBase_filePath = "hall.handle", "server.base"
package.loaded[HallHandle_filePath], package.loaded[ServerBase_filePath] = {}, {}
package.loaded["framework.scheduler"] = {}
function import() return {CLI_LOGIN = 0x116, CONFIG = {CLIENT = {}}} end
function class() return {} end
function dump() end
function print() end
UID, DOUNIU_ROOM_KEY = 123, "test-only-room-key"
USER_INFO = {user_info = "original-profile"}
json = {encode = function(v)
    assert(v.roomKey == DOUNIU_ROOM_KEY)
    return "proof-for-this-session"
end}
local fields
local builder = {
    setParameter = function(self, key, value) fields[key] = value; return self end,
    build = function() return fields end,
}
bm = {server = {
    createPacketBuilder = function(_, cmd) assert(cmd == 0x116); fields = {}; return builder end,
    send = function(_, packet) assert(packet == fields) end,
}}
local hall = dofile(assert(arg[1]))
for _, pure in ipairs({false, true, false}) do
    PURE_JAVA_HALL = pure
    hall:LoginHall()
    assert(fields.uid == UID and fields.userInfo == (pure and "proof-for-this-session" or "original-profile"))
    assert(USER_INFO.user_info == "original-profile")
end
