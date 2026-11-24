-- lua client/tests/douniu_password.lua group_join.lua
function class() return {} end
local group = dofile(assert(arg[1]))
NetworkLoadingView_filePath = "loading"
local panel = {}
local scene = {getChildByName = function() return panel end}
SCENENOW = {scene = scene}
USER_INFO = {tid = 101, activity_id = 81, enter_mode = 302}
HttpAddr = "/hbiInterface"
local req, submit, cancel, errorText, exited, entered
cct = {createHttRq = function(options) req = options end}
json = {decode = function(reply) return reply end}
tolua = {isnull = function(node) return not node end}
package.loaded.loading = {removeView = function() end}
package.loaded["hall.GameTips"] = {showTips = function(_, _, _, _, message) errorText = message end}
package.loaded["hall.GameCommon"] = {gExitGroupGame = function(_, mode) exited = mode end}
function group:showInputPasswordScene(mode, onSubmit, onCancel)
    assert(mode == "join")
    submit, cancel = onSubmit, onCancel
end
function group:removeInputPasswordScene() panel = nil end
group:unlockDouniuRoom(101, 81, function() entered = true end)
submit("047219")
assert(req.type_ == "POST" and req.url == HttpAddr .. "/freeGame/unlockDouniuRoom")
assert(req.date.password == "047219" and req.date.activityId == 81)
req.callBack({netData = {returnCode = "1", error = "密码错误"}})
assert(panel and errorText == "密码错误" and not entered)
submit("000007")
local reply = {netData = {returnCode = "0"}}
USER_INFO.activity_id = 82
req.callBack(reply)
assert(panel and not entered)
USER_INFO.activity_id = 81
req.callBack(reply)
assert(not panel and entered)
cancel()
assert(exited == 302)
