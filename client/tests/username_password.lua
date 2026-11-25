-- 从打包的账号入口触发真实回调，只替换 Cocos 控件、传输和场景切换。
local function noop() end
local Node = {}
Node.__index = function(_, key) return Node[key] or (key:match("^set") and noop) end
local function node(text)
    return setmetatable({text=text, children={}, visible=true, enabled=true}, Node)
end
function Node:addChild(n) self.children[#self.children+1]=n; n.parent=self end
function Node:getParent() return self.parent end
function Node:removeFromParent()
    for i,n in ipairs(self.parent.children) do
        if n==self then table.remove(self.parent.children,i); self.parent=nil; return end
    end
end
function Node:setName(name) self.name=name end
function Node:getChildByName(name)
    for _,child in ipairs(self.children) do if child.name==name then return child end end
end
function Node:setVisible(value) self.visible=value end
function Node:isVisible() return self.visible end
function Node:setTouchEnabled(value) self.enabled=value end
function Node:setString(s) self.text=s end
function Node:setText(s) self.text=s end
function Node:getText() return self.text or "" end
function Node:getPositionX() return 0 end
function Node:getPositionY() return 0 end
function Node:getScaleX() return 1 end
function Node:getScaleY() return 1 end
function Node:getContentSize() return {width=312,height=85} end
function Node:addTouchEventListener(fn) self.touch=fn end
function Node:registerScriptEditBoxHandler(fn) self.edit=fn end
Node.enableOutline=noop
Node.ignoreContentAdaptWithSize=noop

local widget={create=function() return node() end}
ccui={Layout=widget, ImageView=widget, EditBox=widget, Scale9Sprite=widget,
      Text={create=function(_,s) return node(s) end}, TouchEventType={ended=2}}
local gl={getDesignResolutionSize=function() return {width=960,height=540} end}
cc={Sprite=widget, p=noop,c3b=noop,c4b=noop,rect=noop,size=noop,
    Director={getInstance=function() return {getOpenGLView=function() return gl end} end}}
tolua={isnull=function() return false end}
device={platform="windows"}
json={encode=function(v) return v end,decode=function(v) return v end}
string.urlencode=function(v) return tostring(v) end
HttpAddr="https://game.example/hbiInterface"
local request
cc.XMLHttpRequest={new=function()
    return {open=function(self,method,url) assert(method=="POST"); self.url=url end,
            setRequestHeader=function(self,_,value) self.contentType=value end,
            registerScriptHandler=function(self,fn) self.callback=fn end,
            unregisterScriptHandler=function(self) self.callback=nil end,
            send=function(self,body) assert(not request,"duplicate request"); self.body=body; request=self end}
end}
local scenes=0
function display_scene(name) assert(name=="hall.hallScene"); scenes=scenes+1 end
local function reply(data,err)
    local xhr=assert(request); request=nil
    xhr.status,xhr.readyState=200,4
    xhr.response={returnCode=err and "1" or "0",data=data,error=err}
    xhr.callback()
end
local module=dofile(assert(arg[1]))
local layer
local function find(n,fn)
    if not n.visible then return end
    if fn(n) then return n end
    for _,child in ipairs(n.children) do
        local hit=find(child,fn)
        if hit then return hit end
    end
end
local function shown(value) return find(layer,function(n) return n.text==value end) end
local function tap(label)
    local n=assert(shown(label),label)
    while not n.touch do n=assert(n.parent,label) end
    assert(n.enabled,label); n.touch(n,ccui.TouchEventType.ended)
end
local function field(hint)
    local n=find(layer,function(n)
        if not n.edit then return false end
        for _,sibling in ipairs(n.parent.children) do
            if sibling.text==hint then return true end
        end
    end)
    return assert(n,hint)
end
local function fill(hint,value)
    local n=field(hint); n:setText(value); n.edit("ended")
end
local function open(action)
    layer=node(); layer.btnPhone=node(); layer.btnLogin=node()
    layer:addChild(layer.btnPhone); layer:addChild(layer.btnLogin)
    module.attach(layer); tap(action)
end
local function endpoint(action)
    assert(request and request.url==HttpAddr.."/playerUser/username/"..action,action)
    assert(request.contentType=="application/json; charset=utf-8")
    return request.body
end
local name,old,new="Player_8",string.rep("a",8),string.rep("b",9)
local code=table.concat({"0123","4567","89AB","CDEF","FEDC","BA98","7654","3210"})
local function acknowledge()
    assert(shown("0123-4567-89AB-CDEF") and shown("FEDC-BA98-7654-3210"))
    tap("已保存，继续")
end
open("注册")
fill("请输入手机号或用户名",name); fill("设置登录密码",old); tap("注册并登录")
assert(endpoint("register").requestRecoveryCode); reply({recoveryCode=code})
assert(not request and scenes==0); acknowledge()
assert(endpoint("login").password==old); reply({userId=8,token="new-session"})
assert(scenes==1 and USER_INFO.loginMethod=="username")

open("账号登录")
fill("请输入手机号或用户名",name); tap("修改密码")
assert(field("输入注册的用户名"):getText()==name)
fill("输入原登录密码",old); fill("设置 8 至 64 字节的新密码",new); fill("再次输入新密码",old)
tap("保存新密码"); assert(not request and shown("两次输入的新密码不一致"))
fill("再次输入新密码",new); tap("保存新密码")
local payload=endpoint("changePassword")
assert(payload.oldPassword==old and payload.newPassword==new and payload.username==name)
reply(nil,"用户名或原密码错误"); assert(shown("用户名或原密码错误"))
tap("保存新密码"); reply({recoveryCode=code}); acknowledge()
assert(shown("密码已更新，请用新密码登录") and field("请输入密码"):getText()=="")

tap("忘记密码")
fill("输入保存的完整恢复码","abc"); fill("设置 8 至 64 字节的新密码",old); fill("再次输入新密码",old)
tap("重设密码"); assert(not request and shown("请输入完整的 32 位恢复码"))
fill("输入保存的完整恢复码","0123-4567-89ab-cdef fedc-ba98-7654-3210")
tap("重设密码"); payload=endpoint("resetPassword")
assert(payload.recoveryCode==code and payload.newPassword==old and payload.username==name)
reply({recoveryCode=code}); acknowledge()
fill("请输入密码",old); tap("登录游戏")
assert(endpoint("login").password==old); reply({userId=8,token="reset-session"})
assert(scenes==2 and token=="reset-session")

open("账号登录")
tap("修改密码")
fill("输入注册的用户名",name); fill("输入原登录密码",old)
fill("设置 8 至 64 字节的新密码",new); fill("再次输入新密码",new)
tap("保存新密码"); reply({})
assert(shown("未收到恢复码，请用新密码登录后再次改密领取"))

open("账号登录")
fill("请输入手机号或用户名",name); fill("请输入密码",old); tap("登录游戏")
assert(endpoint("login").requestRecoveryCode); reply({userId=8,token="legacy",recoveryCode=code})
assert(scenes==2); acknowledge(); assert(scenes==3)
open("账号登录")
fill("请输入手机号或用户名","13900000000"); fill("请输入密码",old)
assert(not shown("修改密码") and not shown("忘记密码"))
tap("登录游戏"); assert(request.url==HttpAddr.."/userLogin" and request.body:match("phone=13900000000"))
reply({userId=9,token="phone"}); assert(scenes==4 and USER_INFO.loginMethod=="phone")
print("Verified username change, reset, code acknowledgement, legacy enrollment and phone login.")
