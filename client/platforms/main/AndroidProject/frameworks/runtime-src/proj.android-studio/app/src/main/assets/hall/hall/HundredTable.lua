-- 两种经典/拼庄桌共用同一游戏钱包。请求编号在网络发送前落盘，重开大厅后仍可确认。
local M = {}
local titles={[101]="百人龙虎",[102]="百人神兽",[9103]="百家乐"}
local areas={[101]={"龙","虎","和"},[102]={"青龙","白虎","朱雀","玄武"},[9103]={"庄","闲","和","庄对","闲对"}}
local function points(n) return string.format("%.2f",(n or 0)/100) end

function M.addEntries(list,template,ui)
    local layouts={{101,101,102,102},{9103,9103}}
    for _,levels in ipairs(layouts) do
        local row=template:clone()
        for _,child in ipairs(row:getChildren()) do child:setVisible(false) end
        for i,level in ipairs(levels) do
            local kind=(i-1)%2+1
            local slot=row:getChildByName("btnGame"..i)
            slot:removeAllChildren()
            local size=slot:getContentSize()
            ui.label(slot,titles[level],size.width/2,size.height*0.58,25,ui.gold)
            local subtitle=kind==1 and "经典桌" or "拼庄桌"
            ui.label(slot,level==9103 and subtitle.." · 独立规则" or subtitle,size.width/2,size.height*0.30,18)
            slot:setVisible(true)
            slot:onClick(function() M.open(g_hallMainLayer,level,kind,ui) end)
        end
        list:pushBackCustomItem(row)
    end
end

function M.open(parent,level,kind,ui)
    if not parent or parent:getChildByName("hundredTable") then return end
    local tid=level*65536+kind
    local size=cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local root=ui.box(parent,size.width,size.height,0,0,ui.rail)
    root:setName("hundredTable"); root:setLocalZOrder(1200); root:setTouchEnabled(true)
    local scale=math.min(size.width/960,size.height/540)
    local stage=ui.box(root,960,540,(size.width-960*scale)/2,(size.height-540*scale)/2,ui.felt)
    stage:setScale(scale)
    ui.label(stage,titles[level].." · "..(kind==1 and "经典桌" or "拼庄桌"),195,503,28,ui.gold)
    ui.button(stage,"返回大厅",125,44,866,505,function() root:removeFromParent() end)
    local panel=ui.box(stage,936,409,12,50,ui.felt)
    local msg=ui.label(stage,"",480,26,17,ui.gold)
    local store=cc.UserDefault:getInstance()
    local cacheKey="hundredOrder."..USER_INFO.uid.."."..tid
    local saved=store:getStringForKey(cacheKey,"")
    local order=saved~="" and json.decode(saved) or nil
    local alive,busy,state,stake=true,false,nil,100
    local render,send,history,historyIndex
    historyIndex=1
    local function remember(nextOrder)
        order=nextOrder
        store:setStringForKey(cacheKey,order and json.encode(order) or "")
        store:flush()
    end
    send=function(action,params)
        if busy or not alive then return end
        busy=true
        local form={tid=tid}
        for k,v in pairs(params or {}) do form[k]=v end
        cct.createHttRq({url=HttpAddr.."/hundredTable/"..action,date=form,type_="POST",encodeForm=true,isshowfailTip=false,
            onFailure=function()
                busy=false
                if alive then msg:setString("网络中断，请重新确认订单或稍后刷新"); render() end
            end,
            callBack=function(reply)
                busy=false
                if not alive then return end
                local res=json.decode(reply.netData) or {}
                if tostring(res.returnCode)=="0" then
                    if action=="bet" then remember(nil); msg:setString("订单已确认") end
                    if action=="history" then history=res.data.rounds; historyIndex=1 else state=res.data end
                else
                    if action=="bet" and tostring(res.returnCode)=="1" and res.error then remember(nil) end
                    msg:setString(res.error or "请重新登录后查询")
                end
                render()
            end})
    end
    render=function()
        panel:removeAllChildren()
        if history then
            ui.label(panel,"最近二十局",468,355,26,ui.gold)
            if #history==0 then ui.label(panel,"本桌还没有已结算的牌局",468,220,21) end
            for i=historyIndex,math.min(historyIndex+5,#history) do
                local r=history[i];local note=r.delta and ("我的净分 "..points(r.delta)) or "未参与"
                ui.label(panel,os.date("%H:%M:%S",math.floor(r.closedAt/1000)).."     "..ui.faces(r.cards,level).."     "..note,468,310-(i-historyIndex)*40,19)
            end
            if historyIndex>1 then ui.button(panel,"上一页",115,40,300,33,function() historyIndex=historyIndex-6; render() end) end
            if historyIndex+5<#history then ui.button(panel,"下一页",115,40,630,33,function() historyIndex=historyIndex+6; render() end) end
            ui.button(panel,"返回牌桌",130,40,468,33,function() history=nil; render(); send("state") end)
            return
        end
        ui.button(panel,"近二十局",138,40,470,27,function() send("history") end)
        if order then
            ui.button(panel,"确认上笔订单",180,40,790,27,function() send("bet",order) end,true)
        end
        if not state then return end
        if state.rules then
            local text=level==9103 and state.rules or ("本桌赔率与拼庄取整约定 · "..state.rules)
            local terms=ui.label(panel,text,468,397,16,ui.gold)
            terms:setTextAreaSize(cc.size(910,45))
        elseif level==9103 then
            ui.label(panel,"等待本桌赔率",468,397,20,ui.gold)
            return
        end
        local names=areas[level]
        local stageName=state.phase=="WAITING" and "等待玩家上庄" or state.phase=="SETTLED" and "本局已结算" or "接受下注"
        ui.label(panel,stageName,468,364,30,ui.gold)
        ui.label(panel,"我的筹码  "..points(state.chips).."     上庄门槛  "..points(state.minimum),468,315,20)
        local queued=false
        for _,uid in ipairs(state.queue or {}) do if uid==USER_INFO.uid or tostring(uid)==tostring(USER_INFO.uid) then queued=true end end
        ui.button(panel,queued and "申请下庄 / 退出排队" or "申请上庄",210,40,142,27,function()
            send(queued and "withdraw" or "apply")
        end)
        local bankerNames={}
        for _,b in ipairs(state.bankers or {}) do bankerNames[#bankerNames+1]=tostring(b.uid) end
        ui.label(panel,"本局庄家  "..(#bankerNames>0 and table.concat(bankerNames,"、") or "待定").."    上庄队列  "..#(state.queue or {}),468,276,16)
        if state.phase=="OPEN" then
            for i,name in ipairs(names) do
                local x=468+(i-(#names+1)/2)*183
                ui.button(panel,name.."  "..points((state.totals or {})[i]),169,64,x,197,function()
                    if order or busy then return end
                    local key=cacheKey..".seq"
                    local n=store:getIntegerForKey(key,0)+1
                    store:setIntegerForKey(key,n)
                    local id=crypto.md5(table.concat({tostring(token),state.round,tostring(os.time()),tostring(n)},":"),false)
                    remember({round=state.round,area=i,chips=stake,requestId=id})
                    send("bet",order)
                end,true)
                ui.label(panel,"我已下 "..points((state.own or {})[i]),x,146,17)
            end
            for i,n in ipairs({100,1000,10000}) do
                ui.button(panel,points(n).." 分",116,42,468+(i-2)*126,82,function() stake=n; render() end,stake==n)
            end
        elseif state.bankerCards then
            ui.label(panel,"庄  "..ui.faces(state.bankerCards,level).."  "..state.bankerPoints.."点    闲  "..ui.faces(state.playerCards,level).."  "..state.playerPoints.."点",468,209,23)
            local tags=(state.bankerPair and "   庄对" or "")..(state.playerPair and "   闲对" or "")
            local verdict=state.bankerPoints==state.playerPoints and "和" or (state.bankerPoints>state.playerPoints and "庄赢" or "闲赢")
            local net=0
            for _,r in ipairs(state.receipt or {}) do if tostring(r.uid)==tostring(USER_INFO.uid) then net=r.turnBlc end end
            ui.label(panel,verdict..tags.."     本局净分  "..points(net),468,146,25,ui.gold)
        elseif state.cards then
            ui.label(panel,(level==101 and "龙  虎" or "庄  青龙  白虎  朱雀  玄武").."     "..ui.faces(state.cards,level),468,204,22)
            local net=0
            for _,receipt in ipairs(state.receipt or {}) do
                if tostring(receipt.uid)==tostring(USER_INFO.uid) then net=receipt.turnBlc end
            end
            ui.label(panel,"本局净分  "..points(net),468,142,25,ui.gold)
        end
    end
    render(); send("state")
    local scheduler=cc.Director:getInstance():getScheduler()
    local timer=scheduler:scheduleScriptFunc(function() if not history then send("state") end end,2,false)
    root:registerScriptHandler(function(event)
        if event=="exit" then alive=false; scheduler:unscheduleScriptEntry(timer) end
    end)
end
return M
