-- 使用打包脚本的实际请求与邀请入口。这里只替换网络、弹窗和设备存储。
local function noop() end
local seq, failed, retry, posted = 0
function class() return {} end
function dump() end
function print() end
HttpAddr, token, USER_INFO, PURE_JAVA_HALL = "http://localhost", "session", {uid=123}, true
CommonTips_filePath, NetworkLoadingView_filePath = "test.tips", "test.loading"
package.loaded[CommonTips_filePath] = {showTips=function(_, dialog) retry = dialog.callBackSure end}
package.loaded[NetworkLoadingView_filePath] = {removeView=noop}
package.loaded["hall.GameCommon"] = {landLoading=noop, getUserHead=noop}
package.loaded["framework.scheduler"] = {}
cc = {PACKAGE_NAME="framework", UserDefault={getInstance=function()
    return {getIntegerForKey=function() return seq end, setIntegerForKey=function(_,_,v) seq=v end, flush=noop}
end}}
crypto = {md5=function(s) return s end}
network = {createHTTPRequest=function(handler)
    failed, posted = function() handler({name="failed"}) end, {}
    return {addRequestHeader=noop, setTimeout=noop, start=noop, addPOSTValue=function(_,k,v) posted[k]=v end}
end}
if arg[3] then
    GameState = {}
    ccui, cc.Node = {Widget={},ListView={}}, {}
    package.loaded["cocos.framework.extends.UIWidget"] = {}
    cc.XMLHttpRequest = {new=function()
        local xhr={readyState=4,status=503,open=noop,unregisterScriptHandler=noop}
        function xhr:registerScriptHandler(handler) failed=handler end
        function xhr:send(body)
            posted={}
            for k,v in body:gmatch("([^&=]+)=([^&]*)") do
                posted[k]=v:gsub("%%(%x%x)",function(hex) return string.char(tonumber(hex,16)) end)
            end
        end
        return xhr
    end}
    dofile(arg[3])
end
local request = dofile(arg[1])
request:ctor()
local function gift() cct.createHttRq({url=HttpAddr.."/playerXXX", date={playerId1=123,playerId2=124,count=10,remark="礼物 & + %"}}) end
gift()
local id = assert(posted.requestId)
assert(posted.remark=="礼物 & + %")
assert(failed)()
assert(retry)()
assert(posted.requestId==id and seq==1)
gift()
assert(posted.requestId~=id and seq==2)
cct.createHttRq({url=HttpAddr.."/other"})
assert(not posted.requestId and seq==2)

package.loaded["hall.ViewBaseLayer"], package.loaded["hall.NewViewBaseLayer"], package.loaded["hall.HallServer"] = {},{},{}
local family = {gameConfigList={}}
SCENENOW = {scene={hallMainLayer={familyMainlayer=family}}}
json = {decode=function() return {id=9, inviteCode="ABC", clubName="club"} end}
local data = {config="fixture", level=302, tid=99, activityId=8, uid=123, nickName="name", portrait="",club_id=1}
local layer = dofile(arg[2])
layer.ImageHead={getContentSize=function() return {width=1} end}
for _,k in ipairs({"TextName","textId","TextMessage","TextConfig"}) do layer[k]={setString=noop} end
layer.data,layer.removeSelf=data,noop
layer:SetInfo(data)
for _,pure in ipairs({true,false}) do
    PURE_JAVA_HALL=pure
    local called=false
    function family:CreateGameTable(flag, info, _, mode)
        assert(flag==2 and info.config.table_id==99 and info.config.table_info.activityId==8)
        assert(info.config.m_strInviteCode=="ABC" and info.config.id==9 and info.config1)
        assert(mode==(pure and 1 or 0))
        called=true
    end
    layer:onClickBtnTongYi()
    assert(called)
end
