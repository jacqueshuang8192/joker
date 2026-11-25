-- 在每个发行副本上驱动实际的触摸回调、手牌选择和断线轮询。
local function noop() end
local Node = {}
Node.__index = function(_, key)
    return rawget(Node,key) or (key:match("^set") and noop)
end
local function node(text)
    return setmetatable({text=text,children={},w=100,h=100},Node)
end
function Node:addChild(child) child.parent=self; self.children[#self.children+1]=child end
function Node:removeFromParent()
    if self.listener then self.listener("exit") end
    for i,child in ipairs(self.parent.children) do
        if child==self then table.remove(self.parent.children,i); return end
    end
end
function Node:setContentSize(size) self.w,self.h=size.width,size.height end
function Node:getContentSize() return {width=self.w,height=self.h} end
function Node:setName(name) self.name=name end
function Node:getChildren() return self.children end
function Node:getChildByName(name)
    for _,child in ipairs(self.children) do if child.name==name then return child end end
end
function Node:removeAllChildren() self.children={} end
function Node:addClickEventListener(fn) self.click=fn end
function Node:onClick(fn) self.click=fn end
function Node:registerScriptHandler(fn) self.listener=fn end
function Node:setString(s) self.text=s end
function Node:getText() return self.text or "" end
function Node:setPlaceHolder(s) self.hint=s end
function Node:pushBackCustomItem(item) self:addChild(item) end
function Node:clone()
    local row=node()
    for i=1,4 do local slot=node();slot.name="btnGame"..i;row:addChild(slot) end
    return row
end
local function find(root,predicate)
    if predicate(root) then return root end
    for _,child in ipairs(root.children) do
        local hit=find(child,predicate)
        if hit then return hit end
    end
end
local function tap(root,title)
    local item=assert(find(root,function(n) return n.text==title end),title)
    while not item.click do item=assert(item.parent) end
    item.click()
end

local defaults={}
function defaults:getIntegerForKey(k,d) return defaults[k] or d end
function defaults:setIntegerForKey(k,v) defaults[k]=v end
function defaults:getStringForKey(k,d) return defaults[k] or d end
function defaults:setStringForKey(k,v) defaults[k]=v end
function defaults:flush() end
local timer
local scheduler={scheduleScriptFunc=function(_,fn) timer=fn;return 1 end,
    unscheduleScriptEntry=function() timer=nil end}
local director={getScheduler=function() return scheduler end,getOpenGLView=function()
    return {getDesignResolutionSize=function() return {width=960,height=540} end} end}
cc={size=function(w,h) return {width=w,height=h} end,p=noop,c3b=function(...) return {...} end,
    Director={getInstance=function() return director end},UserDefault={getInstance=function() return defaults end}}
ccui={Layout={create=function() return node() end},Text={create=function(_,text) return node(text) end},
    EditBox={create=function() return node() end},Scale9Sprite={create=function() return node() end}}
HttpAddr="test";USER_INFO={uid=8}; token="session"; crypto={md5=function(s) return s end}
json={decode=function(data) return data end}
local request
cct={createHttRq=function(r) request=r end}
local function respond(data)
    request.callBack({netData={returnCode="0",data=data}})
end
package.preload["hall.HundredTable"]=function() return dofile(arg[1]:gsub("FriendTable.lua$","HundredTable.lua")) end
package.preload["hall.ChipPurchase"]=function() return dofile(arg[1]:gsub("FriendTable.lua$","ChipPurchase.lua")) end
local ui=dofile(arg[1])
g_hallMainLayer=node()
local list=node()
ui.addEntries(list,node())
for i,id in ipairs({324,325,308}) do
    list.children[1]:getChildByName("btnGame"..i).click()
    assert(request.url=="test/friendTable/current" and request.date.level==id)
    respond({})
    local root=g_hallMainLayer:getChildByName("friendTable")
    tap(root,"创建牌桌")
    local requestId=request.date.requestId
    request.onFailure()
    tap(root,"创建牌桌")
    assert(request.date.requestId==requestId)
    local state={code=10000001,level=id,version=1,seat=0,players={8},capacity=id==308 and 4 or 3,phase="WAITING",waitingMinutes=30}
    respond(state)
    assert(find(root,function(n) return n.text=="30 分钟无人加入或退出后，房间自动解散" end))
    timer()
    assert(request.url=="test/friendTable/state" and request.date.code==state.code)
    state={code=10000001,level=id,version=2,seat=0,turn=0,players={8,9,10},counts={1,1,1},
        phase=id==308 and "DISCARD" or "PLAY",actions={id==308 and "discard" or "play"},hand={3},
        board={lead={},leader=-1,landlord=0,bottom={12,13,1},multiplier=1,
            wall=58,discard=0,rivers={{},{},{},{}},melds={{},{},{},{}}}}
    respond(state)
    tap(root,id==308 and "3万" or "♦3")
    timer()
    local poll=request
    assert(poll.url=="test/friendTable/state" and poll.date.version==2)
    timer(); assert(request==poll,"overlapping polls")
    local play=id==308 and "打出" or "出牌"
    tap(root,play)
    local action=request
    assert(action.url=="test/friendTable/act" and action.date.cards=="3" and action.date.version==2)
    if id==324 then
        -- 刷新先回来，不能放开操作锁或重画选中的手牌。
        poll.callBack({netData={returnCode="0",data={code=state.code,version=3,phase="CLOSED",players={8}}}})
    end
    tap(root,play); timer()
    assert(request==action,"duplicate tap or poll while action in flight")
    respond({code=10000001,level=id,version=3,seat=0,players={8,9,10},phase="FINISHED",points={2,-1,-1},board={}})
    if id==325 then poll.callBack({netData={returnCode="0",data=state}}) end
    if id==308 then
        poll.onFailure()
        assert(not find(root,function(n) return n.text=="网络暂时中断，可重试或重新进入牌桌" end))
    end
    tap(root,"返回开桌")
    local input=find(root,function(n) return n.hint~=nil end);input.text="12345678"
    tap(root,"凭房号加入")
    assert(request.url=="test/friendTable/join" and request.date.code=="12345678")
    tap(root,"返回大厅")
    assert(not timer)
    respond(state) -- 关闭后收到的迟到响应。
end
print("Verified immediate play during polling, duplicate taps, stale poll replies and errors, reconnect and timer cleanup.")

-- 百人桌从当前大厅会话进入。未确认订单退出重开后继续用相同请求编号。
json.encode=function(v) return v end
for i=1,4 do
    local level=i<=2 and 101 or 102
    local button=list.children[2]:getChildByName("btnGame"..i)
    button.click()
    local tid=level*65536+(i-1)%2+1
    assert(request.url=="test/hundredTable/state" and request.date.tid==tid)
    local state={phase="OPEN",round="round",chips=20000,minimum=10000,queue={},bankers={},totals={},own={}}
    respond(state)
    local root=g_hallMainLayer:getChildByName("hundredTable")
    tap(root,level==101 and "龙  0.00" or "青龙  0.00")
    local order=request.date
    assert(request.url=="test/hundredTable/bet" and order.area==1 and order.chips==100)
    request.onFailure()
    tap(root,"返回大厅"); button.click(); respond(state)
    root=g_hallMainLayer:getChildByName("hundredTable")
    tap(root,"确认上笔订单")
    assert(request.date.requestId==order.requestId and request.date.round==order.round)
    respond(state)
    tap(root,"申请上庄"); assert(request.url=="test/hundredTable/apply")
    state.queue={8}; respond(state)
    tap(root,"申请下庄 / 退出排队"); assert(request.url=="test/hundredTable/withdraw")
    respond(state); tap(root,"返回大厅")
    assert(not timer)
end
print("Verified hundred-table selection, wager recovery and banker callbacks.")

local independent={{317,360,365,368},{315,318,369,381},{397,383},{9324,9325,9425},
    {329,320,371,358},{366,389,391},{342,345,501,353},{359,374,375,379},{392,9342,388,384}}
local function hasText(root,value)
    return find(root,function(n) return n.text==value end)
end
for row,levels in ipairs(independent) do
    for slot,level in ipairs(levels) do
        list.children[row+3]:getChildByName("btnGame"..slot).click()
        assert(request.url=="test/friendTable/current" and request.date.level==level)
        local text="独立规则 v1 场次"..level
        respond({terms=text})
        local root=g_hallMainLayer:getChildByName("friendTable")
        assert(hasText(root,text))
        tap(root,"创建牌桌")
        assert(request.url=="test/friendTable/create" and request.date.level==level)
        local s={code=12345678,level=level,version=2,seat=0,turn=0,players={8,9,10},counts={3,3,3},capacity=3}
        if level==342 or level==384 or level==388 or level==329 then
            s.hand=level==388 and {1,33} or {1,2};s.phase="CLAIM";s.actions={"chi","skip"}
            s.board={wall=15,rivers={{3},{},{}},groups={{},{},{}},discard=3,chi={s.hand}}
            respond(s)
            local first=level==329 and "1万" or level==384 and "黑A" or level==388 and "乙" or "一"
            local second=level==329 and "2万" or level==384 and "黑2" or level==388 and "孔" or "二"
            tap(root,first);tap(root,second);tap(root,"吃牌")
            assert(request.date.action=="chi" and request.date.cards==table.concat(s.hand,","))
        elseif level==315 then
            s.hand={1,2,16,17};s.phase="ARRANGE";s.actions={"split","auto"};s.board={summary="配门"}
            respond(s);tap(root,"天");tap(root,"地");tap(root,"选两张配门")
            assert(request.date.cards=="1,2")
        else
            respond({code=12345678,level=level,version=1,seat=0,phase="WAITING",players={8},capacity=3})
        end
        tap(root,"返回大厅")
        assert(not timer)
    end
end
for slot=1,2 do
    list.children[3]:getChildByName("btnGame"..slot).click()
    local root=g_hallMainLayer:getChildByName("hundredTable")
    local s={phase="OPEN",round="b1",chips=20000,minimum=10000,queue={},bankers={},totals={},own={}}
    respond(s);assert(not hasText(root,"庄对  0.00"))
    timer();s.rules="独立规则 v1 · 庄对、闲对净赔11倍";respond(s)
    assert(hasText(root,s.rules));tap(root,"闲对  0.00")
    assert(request.date.area==5 and request.date.tid==9103*65536+slot)
    respond(s);tap(root,"返回大厅")
end
print("Verified independent terms before play, regional tile selection, domino grouping and baccarat pair bets.")


-- 清空设备上的房号也能查看账号战绩、逐局翻页；历史模式不会被后台轮询覆盖。
defaults["friendTable.8.324"]=nil
list.children[1]:getChildByName("btnGame1").click()
respond({}); local root=g_hallMainLayer:getChildByName("friendTable")
tap(root,"我的战绩")
assert(request.url=="test/friendTable/history" and request.date.before==0)
local item={endedAt=1700000000,code=12345678,phase="FINISHED",points=12}
respond({rooms={item},more=true})
local historyRequest=request; timer(); assert(request==historyRequest)
tap(root,"下一页"); assert(request.date.before==12345678); respond({rooms={},more=false})
tap(root,"上一页"); respond({rooms={item},more=true})
tap(root,os.date("%Y-%m-%d %H:%M",item.endedAt).."    房号 12345678    牌桌结算    累计 +12")
assert(request.url=="test/friendTable/rounds")
respond({rounds={{round=1,points=12,outcome="SETTLED",deals=1}}})
tap(root,"第 1 局     我的积分 +12     查看牌谱")
assert(request.url=="test/friendTable/replay" and request.date.step==0)
local frame={hands={{3},{4},{5}},players={8,9,10},steps=1,step=0}
respond(frame); tap(root,"下一步"); assert(request.date.step==1)
frame.step=1; frame.move={seat=0,action="play",cards={3}}; respond(frame)
tap(root,"上一步"); assert(request.date.step==0); frame.step=0; respond(frame)
tap(root,"返回局单"); assert(request.url=="test/friendTable/rounds")
respond({rounds={{round=1,points=12,outcome="SETTLED",deals=1}}})
tap(root,"返回战绩"); assert(request.url=="test/friendTable/history" and request.date.before==0)
respond({rooms={item},more=true})

local older={endedAt=item.endedAt,code=12345677,phase="FINISHED",points=5}
local olderTitle=os.date("%Y-%m-%d %H:%M",older.endedAt).."    房号 12345677    牌桌结算    累计 +5"
tap(root,"下一页"); assert(request.date.before==item.code); respond({rooms={older},more=true})
tap(root,"下一页"); request.onFailure()
tap(root,olderTitle); assert(request.date.code==older.code)
local rounds={}
for i=1,7 do rounds[i]={round=i,points=5,outcome="SETTLED",deals=1} end
respond({rounds=rounds})
tap(root,"下一页"); respond({rounds=rounds})
local lastRound="第 7 局     我的积分 +5     查看牌谱"
tap(root,lastRound); assert(request.date.code==older.code and request.date.round==7); respond(frame)
tap(root,"返回局单"); respond({rounds=rounds}); assert(hasText(root,lastRound))
tap(root,"返回战绩"); assert(request.url=="test/friendTable/history" and request.date.before==item.code)
respond({rooms={older},more=true}); assert(hasText(root,olderTitle))
tap(root,"返回大厅")

list.children[1]:getChildByName("btnGame2").click()
local live={code=19999999,level=325,version=4,seat=0,players={8,9,10},capacity=3,
    phase="PLAY",hand={},actions={},board={summary="出牌"}}
respond(live); root=g_hallMainLayer:getChildByName("friendTable")
tap(root,"提议解散"); assert(request.date.action=="dissolveYes")
local voting={}; for k,v in pairs(live) do voting[k]=v end
voting.version=5; voting.voted=true; voting.voteCount=1; respond(voting)
tap(root,"撤回提议"); assert(request.date.action=="dissolveNo")
tap(root,"返回大厅")

local function openWallet()
    list.children[1]:getChildByName("btnGame4").click()
    return g_hallMainLayer:getChildByName("chipPurchase")
end
root=openWallet()
find(root,function(n) return n.hint=="筹码数量" end).text="100"
tap(root,"核对金额"); tap(root,"确认兑换")
local original=request.date.requestId
assert(request.url=="test/wallet/purchaseChips" and request.date.chips==100)
request.onFailure(); tap(root,"返回大厅"); root=openWallet(); tap(root,"确认原订单")
assert(request.date.requestId==original and request.date.chips==100)
respond({requestId=original,chips=100}); tap(root,"返回大厅"); root=openWallet()
assert(find(root,function(n) return n.hint=="筹码数量" end))
tap(root,"返回大厅")
print("Verified account history, replay navigation, dissolution and persistent purchase confirmation.")
