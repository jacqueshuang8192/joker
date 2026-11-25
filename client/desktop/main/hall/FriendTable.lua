-- 好友桌复用大厅会话。牌的可见范围和操作顺序由服务端决定。
local M = {}
local names = {[324]="斗地主", [325]="跑得快", [308]="红中麻将",[317]="欢乐金花",[360]="快乐三公",[365]="新十三水",
    [9324]="斗地主·明牌加倍",[9325]="双人跑得快",[9425]="三人飘分跑得快",
    [315]="牌九",[318]="推锅牌九",[368]="无限斗公牛",[369]="新余510K",[381]="泰和过炸",[397]="新化打炸",[383]="沅江千分",
    [342]="常德跑胡子",[345]="娄底放炮罚",[501]="汉寿跑胡子",[353]="邵阳剥皮",[359]="八一字牌",[374]="翻三皮",
    [375]="碰碰胡",[379]="沅江鬼胡子",[392]="溆浦跑胡子",[9342]="柳州字牌",[388]="荆楚花牌",[384]="96扑克",
    [329]="柳州麻将",[320]="长沙麻将",[371]="新余麻将",[358]="沅江麻将",[366]="梅州红中宝",[389]="戳虾子麻将",[391]="溆浦老牌"}
local setup = {
    [324]="三人，首局房主首叫，可叫1或3。每席可抢一次，每抢翻倍。本桌约定：火箭最大，只有四张炸弹翻倍。",
    [325]="三人各16张，黑桃三首发，必须跟牌。剩1张免牌分，关门付32分，有效炸弹每家付10分。",
    [308]="四人万条筒，可碰杠、七对及一炮多响。房主选择红中、抓鸟规则后开桌。"
}
local font = "hall/res/font/wryh.ttf"
local paper, ink = cc.c3b(247,240,217), cc.c3b(42,50,50)
local felt, rail, gold = cc.c3b(26,75,65), cc.c3b(22,55,49), cc.c3b(232,197,121)
local independent={{317,360,365,368},{315,318,369,381},{397,383},{9324,9325,9425},{329,320,371,358},{366,389,391},
    {342,345,501,353},{359,374,375,379},{392,9342,388,384}}
local mahjong={[308]=true,[329]=true,[320]=true,[371]=true,[358]=true,[366]=true,[389]=true,[391]=true}
local word={[342]=true,[345]=true,[501]=true,[353]=true,[359]=true,[374]=true,[375]=true,[379]=true,[392]=true,[9342]=true}
local small={"一","二","三","四","五","六","七","八","九","十"}
local large={"壹","贰","叁","肆","伍","陆","柒","捌","玖","拾"}
local flower={"孔","己","化","千","土","子","上","大","人","可","知","礼"}
local domino={"天","地","人","鹅","梅","长三","板凳","斧头","红头","高脚","零霖","杂九","杂八","杂七","杂五","丁三","猴六"}
local phases = {DOUBLE="选择倍率",FLOAT="选择飘分",POT="庄家决定",BET="下注",GRAB="抢庄",REVEAL="亮牌",ARRANGE="摆道",WAITING="等待入座", CALL="叫地主", ROB="抢地主", PLAY="出牌", DISCARD="摸打", CLAIM="响应弃牌", INTERMISSION="局间结算", FINISHED="牌桌结算", CLOSED="牌桌已解散"}
local verbs = {normal="普通",double="暗加倍",openDouble="明牌四倍",float0="不飘",float1="飘1分",float2="飘2分",split="选两张配门",continuePot="留庄",refill="续锅",cut="切锅",sitOut="本手旁观",chi="吃牌",look="看牌",fold="弃牌",call="跟注",raise="加注",allIn="火拼",matchAll="跟火拼",
    compare1="比1座",compare2="比2座",compare3="比3座",grab0="不抢",grab1="抢1倍",grab2="抢2倍",grab3="抢3倍",
    stake1="押1分",stake2="押2分",reveal="亮牌",front="放入头道",middle="放入中道",call1="叫 1 倍", call3="叫 3 倍", rob="抢地主", decline="不叫 / 不抢", play="出牌", pass="过牌",
    auto="代出", discard="打出", win="胡牌", pong="碰", kong="开杠", exposedKong="明杠", skip="过"}

local function box(parent,w,h,x,y,color)
    local node = ccui.Layout:create()
    node:setContentSize(cc.size(w,h))
    node:setBackGroundColorType(1)
    node:setBackGroundColor(color)
    node:setPosition(x,y)
    parent:addChild(node)
    return node
end

local function label(parent,text,x,y,size,color)
    local node = ccui.Text:create(text,font,size)
    node:setPosition(x,y)
    node:setColor(color or paper)
    parent:addChild(node)
    return node
end

local function button(parent,title,w,h,x,y,action,light)
    local node = box(parent,w,h,x-w/2,y-h/2,light and paper or rail)
    label(node,title,w/2,h/2,20,light and ink or paper)
    node:setTouchEnabled(true)
    node:addClickEventListener(action)
    return node
end

local function cardName(code,level)
    if code == 0 then return "暗" end
    if level==315 or level==318 then return domino[code] end
    if word[level] then
        if code==42 then return "鬼" end
        return (code>16 and large or small)[code%16]
    end
    if level==388 then
        if code==45 then return "别杠" end
        if code>32 then return flower[code-32] end
        return (code>16 and "花" or "")..(code%16==1 and "乙" or small[code%16])
    end
    if level==384 then return (code>16 and "红" or "黑")..(({[1]="A",[11]="J",[12]="Q"})[code%16] or tostring(code%16)) end
    if mahjong[level] then
        if code>=49 and code<=55 then return ({"东","南","西","北","中","发","白"})[code-48] end
        if code == 65 then return "红中" end
        return tostring(code%16)..({"万","条","筒"})[math.floor(code/16)+1]
    end
    if code == 78 then return "小王" end
    if code == 79 then return "大王" end
    return ({"♦","♣","♥","♠"})[math.floor(code/16)+1]..(({[1]="A",[11]="J",[12]="Q",[13]="K"})[code%16] or tostring(code%16))
end

local function faces(cards,level)
    local list = {}
    for _,code in ipairs(cards or {}) do list[#list+1]=cardName(code,level) end
    return table.concat(list," ")
end

-- 复用大厅游戏栏的卡槽和字号，好友入口与原有联盟入口分别保留。
function M.addEntries(list,template)
    local row = template:clone()
    for _,child in ipairs(row:getChildren()) do child:setVisible(false) end
    for i,level in ipairs({324,325,308}) do
        local slot = row:getChildByName("btnGame"..i)
        slot:removeAllChildren()
        local size=slot:getContentSize()
        label(slot,names[level],size.width/2,size.height*0.58,25,gold)
        label(slot,"好友桌",size.width/2,size.height*0.30,18)
        slot:setVisible(true)
        slot:onClick(function() M.open(g_hallMainLayer,level) end)
    end
    local ui={box=box,label=label,button=button,faces=faces,gold=gold,felt=felt,rail=rail}
    local wallet=row:getChildByName("btnGame4")
    wallet:removeAllChildren()
    local size=wallet:getContentSize()
    label(wallet,"兑换筹码",size.width/2,size.height/2,25,gold)
    wallet:setVisible(true)
    wallet:onClick(function() require("hall.ChipPurchase").open(g_hallMainLayer,ui) end)
    list:pushBackCustomItem(row)
    require("hall.HundredTable").addEntries(list,template,ui)
    for _,levels in ipairs(independent) do
        local extra=template:clone()
        for _,child in ipairs(extra:getChildren()) do child:setVisible(false) end
        for i,level in ipairs(levels) do
            local slot=extra:getChildByName("btnGame"..i)
            slot:removeAllChildren(); slot:setVisible(true)
            local size=slot:getContentSize()
            label(slot,names[level],size.width/2,size.height*0.58,25,gold)
            label(slot,"独立规则 · 好友桌",size.width/2,size.height*0.30,16)
            slot:onClick(function() M.open(g_hallMainLayer,level) end)
        end
        list:pushBackCustomItem(extra)
    end
end

function M.open(parent,level)
    if not parent or parent:getChildByName("friendTable") then return end
    local visible = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local root=box(parent,visible.width,visible.height,0,0,rail)
    root:setName("friendTable")
    root:setLocalZOrder(1200)
    root:setTouchEnabled(true)
    local scale=math.min(visible.width/960,visible.height/540)
    local stage=box(root,960,540,(visible.width-960*scale)/2,(visible.height-540*scale)/2,felt)
    stage:setScale(scale)
    label(stage,names[level].." · 好友桌",160,509,30,gold)
    button(stage,"返回大厅",120,42,875,508,function() root:removeFromParent() end)
    local body=box(stage,936,425,12,45,felt)
    local message=label(stage,"",480,24,18,gold)
    local cached=cc.UserDefault:getInstance()
    local cacheKey="friendTable."..tostring(USER_INFO.uid).."."..tostring(level)
    local terms
    local state, pending, alive, selected, creationKey = nil,false,true,{},nil
    local rounds,red,birdIndex=1,true,2
    local birdCounts={0,2,4,6,8,999}
    local function birdName(n)
        if n==999 then return "一码全中" end
        return n==0 and "不抓鸟" or "抓"..n.."鸟"
    end
    local render,home,send,openHistory
    local browsing=false
    local function remember(code)
        cached:setIntegerForKey(cacheKey,code or 0)
        cached:flush()
    end
    local function show(s)
        if s and s.terms then terms=s.terms end
        if s and s.unchanged then return end
        if not s or not s.code then state=nil; home(); return end
        if state and state.code==s.code and state.version==s.version then return end
        remember(s.code)
        state,selected=s,{}
        render()
    end
    local pollInFlight,latestRequest=false,0
    send=function(path,params,callback,isPoll)
        if not alive or pending or (isPoll and pollInFlight) then return end
        if isPoll then pollInFlight=true else pending=true end
        latestRequest=latestRequest+1
        local request=latestRequest
        local function finish()
            if isPoll then pollInFlight=false else pending=false end
            -- 玩家点击可以立即发送；较早的刷新回包或网络错误不能覆盖操作结果。
            return alive and request==latestRequest
        end
        cct.createHttRq({url=HttpAddr.."/friendTable/"..path,date=params,type_="POST",isshowfailTip=false,encodeForm=true,
            onFailure=function()
                if finish() then message:setString("网络暂时中断，可重试或重新进入牌桌") end
            end,
            callBack=function(reply)
                if not finish() then return end
                local res=json.decode(reply.netData) or {}
                if tostring(res.returnCode)~="0" then message:setString(res.error or "请求失败"); return end
                message:setString("")
                local receive=callback or show
                receive(res.data)
            end})
    end
    local function act(action)
        local cards={}
        local selects=action=="play" or action=="discard" or action=="kong" or action=="chi" or action=="front" or action=="middle" or action=="split"
        for i,code in ipairs(state.hand or {}) do
            if selects and selected[i] then cards[#cards+1]=tostring(code) end
        end
        if (action=="play" or action=="discard" or action=="kong") and #cards==0 then
            message:setString("请先点选手牌"); return
        end
        send("act",{code=state.code,version=state.version,action=action,cards=table.concat(cards,",")},function(s)
            if action=="leave" and not s.code then remember(nil) end
            show(s)
        end)
    end
    local cursors={}
    local historyPage=1
    local function leaveHistory()
        if pending then return end
        browsing=false
        if state then render() else home() end
    end
    local function historyControls()
        body:removeAllChildren()
        button(body,"返回牌桌",140,38,468,24,leaveHistory)
    end
    local showRounds,showReplay
    showReplay=function(code,item,deal,step,roundPage)
        send("replay",{code=code,round=item.round,deal=deal,step=step},function(frame)
            historyControls()
            label(body,"房号 "..code.." · 第 "..item.round.." 局 · 第 "..deal.." 次发牌",468,396,22,gold)
            local move=frame.move
            local title=move and ((move.seat+1).."座  "..(verbs[move.action] or move.action).."  "..faces(move.cards,level)) or "发牌"
            local detail=label(body,title,468,345,21)
            detail:setTextAreaSize(cc.size(894,65))
            for i,hand in ipairs(frame.hands) do
                local score=frame.points and string.format("  积分 %+d",frame.points[i]) or ""
                local line=label(body,i.."座 "..frame.players[i]..score.."    "..faces(hand,level),468,282-(i-1)*48,17)
                line:setTextAreaSize(cc.size(900,48))
            end
            local board=frame.board or {}
            local note=board.outcome or board.summary
            if not note and board.wall then note="牌墙 "..board.wall.." 张" end
            if not note and board.multiplier then note="当前 "..board.multiplier.." 倍" end
            if note then label(body,note,468,112,16,gold) end
            label(body,"第 "..frame.step.." / "..frame.steps.." 步",468,80,18,gold)
            if frame.step>0 or deal>1 then
                button(body,"上一步",128,38,228,77,function()
                    if frame.step>0 then showReplay(code,item,deal,frame.step-1,roundPage)
                    else showReplay(code,item,deal-1,-1,roundPage) end
                end)
            end
            if frame.step<frame.steps or deal<item.deals then
                button(body,"下一步",128,38,708,77,function()
                    if frame.step<frame.steps then showReplay(code,item,deal,frame.step+1,roundPage)
                    else showReplay(code,item,deal+1,0,roundPage) end
                end,true)
            end
            button(body,"返回局单",136,38,240,24,function() showRounds(code,roundPage) end)
        end)
    end
    showRounds=function(code,page)
        send("rounds",{code=code},function(data)
            historyControls()
            label(body,"房号 "..code.." · 逐局战绩",468,396,24,gold)
            if #data.rounds==0 then label(body,"此桌没有已完成的牌局",468,220,20) end
            for i=page,math.min(page+5,#data.rounds) do
                local item=data.rounds[i]
                local title="第 "..item.round.." 局     "..(item.outcome=="DISSOLVED" and "局中解散" or string.format("我的积分 %+d",item.points))
                if item.deals>0 then
                    button(body,title.."     查看牌谱",570,38,468,343-(i-page)*45,function() showReplay(code,item,1,0,page) end)
                else label(body,title.."     仅存积分",468,343-(i-page)*45,19) end
            end
            if page>1 then button(body,"上一页",110,38,281,76,function() showRounds(code,page-6) end) end
            if page+5<#data.rounds then button(body,"下一页",110,38,655,76,function() showRounds(code,page+6) end) end
            button(body,"返回战绩",136,38,240,24,function() openHistory(historyPage) end)
        end)
    end
    openHistory=function(page,nextCursor)
        if pending then return end
        local before=nextCursor or (page and cursors[page]) or 0
        send("history",{level=level,before=before},function(data)
            if not page then cursors={}; page=1 end
            historyPage,cursors[page]=page,before
            browsing=true
            historyControls()
            label(body,names[level].." · 我的战绩",468,396,24,gold)
            if #data.rooms==0 then label(body,"暂无已结束的好友桌",468,220,20) end
            for i,item in ipairs(data.rooms) do
                local date=os.date("%Y-%m-%d %H:%M",item.endedAt)
                local text=string.format("%s    房号 %d    %s    累计 %+d",date,item.code,phases[item.phase],item.points)
                button(body,text,720,38,468,344-(i-1)*45,function() showRounds(item.code,1) end)
            end
            if page>1 then button(body,"上一页",110,38,280,75,function() openHistory(page-1) end) end
            if data.more then button(body,"下一页",110,38,655,75,function()
                openHistory(page+1,data.rooms[#data.rooms].code)
            end) end
        end)
    end
    button(stage,"我的战绩",128,42,719,508,function() openHistory() end)
    home=function()
        body:removeAllChildren()
        if setup[level] then
            local info=label(body,setup[level],468,376,18)
            info:setTextAreaSize(cc.size(878,73))
        else
            local rules=label(body,terms or "正在读取本桌的独立规则…",468,351,17)
            rules:setTextAreaSize(cc.size(892,125))
        end
        for i,count in ipairs({1,10,20}) do
            button(body,tostring(count).." 局",78,38,468+(i-2)*92,setup[level] and 311 or 268,function()
                rounds=count; creationKey=nil; home()
            end,count==rounds)
        end
        if level==308 then
            button(body,red and "红中癞子" or "无红中",114,38,408,252,function()
                red=not red; creationKey=nil; home()
            end,true)
            button(body,birdName(birdCounts[birdIndex]),114,38,535,252,function()
                birdIndex=birdIndex%#birdCounts+1; creationKey=nil; home()
            end,true)
        end
        local fieldBg=box(body,272,54,332,level==308 and 166 or 208,paper)
        local field=ccui.EditBox:create(cc.size(255,50),ccui.Scale9Sprite:create())
        field:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        field:setPlaceHolder("输入八位房号")
        field:setMaxLength(8)
        field:setFontSize(23)
        field:setFontColor(ink)
        field:setPosition(136,27)
        fieldBg:addChild(field)
        button(body,"凭房号加入",158,50,565,level==308 and 122 or 151,function()
            local code=field:getText()
            if #code~=8 or not code:match("^%d+$") then message:setString("请输入八位房号"); return end
            if not setup[level] and not terms then send("current",{level=level}); return end
            send("join",{level=level,code=code})
        end,true)
        button(body,"创建牌桌",158,50,370,level==308 and 122 or 151,function()
            if not setup[level] and not terms then send("current",{level=level}); return end
            if not creationKey then
                local key="friendCreateSequence"
                local n=cached:getIntegerForKey(key,0)+1
                cached:setIntegerForKey(key,n); cached:flush()
                creationKey=crypto.md5(table.concat({tostring(token),tostring(os.time()),tostring(n)},":"),false)
            end
            send("create",{level=level,requestId=creationKey,rounds=rounds,red=tostring(red),birds=birdCounts[birdIndex]},function(s) creationKey=nil; show(s) end)
        end,true)
        local code=cached:getIntegerForKey(cacheKey,0)
        if code~=0 then button(body,"查看上桌",180,38,468,60,function() send("state",{code=code}) end) end
    end
    render=function()
        body:removeAllChildren()
        local s=state
        label(body,"房号 "..s.code.."     "..(phases[s.phase] or s.phase).."     "..(s.roundNo or 1).."/"..(s.roundLimit or 1).." 局",468,398,25,gold)
        local members={}
        for i,uid in ipairs(s.players) do
            local count=s.counts and (" · "..s.counts[i].."张") or ""
            local seat=i-1
            local prefix=s.turn==seat and s.phase~="FINISHED" and "▶ " or ""
            members[#members+1]=prefix..(seat==s.seat and "我" or tostring(uid))..count
        end
        label(body,table.concat(members,"       "),468,355,20)
        if s.phase~="WAITING" and s.phase~="FINISHED" and s.phase~="CLOSED" and s.phase~="INTERMISSION" then
            if s.voteCount then
                label(body,"解散 "..s.voteCount.."/"..s.capacity,100,397,18,gold)
                if not s.voted then button(body,"同意解散",110,34,758,397,function() act("dissolveYes") end) end
                button(body,s.voted and "撤回提议" or "不同意",105,34,875,397,function() act("dissolveNo") end)
            else button(body,"提议解散",116,34,862,397,function() act("dissolveYes") end) end
        end
        if s.phase=="WAITING" then
            label(body,"将房号告诉好友，"..s.capacity.." 人到齐后发牌",468,230,24)
            if s.mahjong then label(body,(s.mahjong.red and "红中癞子" or "无红中").." · "..birdName(s.mahjong.birds),468,175,22) end
            if s.waitingMinutes then
                label(body,s.waitingMinutes.." 分钟无人加入或退出后，房间自动解散",468,135,17,gold)
            end
            button(body,"退出等候",160,48,468,92,function() act("leave") end)
            return
        end
        local board=s.board or {}
        if s.phase=="FINISHED" or s.phase=="CLOSED" or s.phase=="INTERMISSION" then
            for i,points in ipairs(s.points or {}) do
                local last=s.lastPoints and s.lastPoints[i] or points
                local text=s.phase=="CLOSED" and string.format("%s     累计 %+d",s.players[i],points)
                    or string.format("%s     本局 %+d     累计 %+d",s.players[i],last,points)
                label(body,text,468,307-i*40,24)
            end
            if board.outcome then label(body,board.outcome,468,335,20,gold) end
            if board.winningHand then label(body,"胡牌  "..faces(board.winningHand,level),468,115,16) end
            if board.birds and #board.birds>0 then label(body,"鸟牌  "..faces(board.birds,level),468,90,17) end
            if board.hands and #board.hands>0 then
                local cards={}
                for i,h in ipairs(board.hands) do
                    if level==365 then
                        local lanes={}
                        for seat,group in ipairs(h) do lanes[#lanes+1]=seat.."座 "..faces(group,level) end
                        cards[#cards+1]=table.concat(lanes,"   ")
                    else cards[#cards+1]=i.."座 "..faces(h,level) end
                end
                local result=label(body,table.concat(cards,level==365 and "\n" or "     "),468,109,15)
                result:setTextAreaSize(cc.size(910,77))
            end
            if s.phase=="INTERMISSION" then
                button(body,"结束此桌",160,44,363,43,function() act("leave") end)
                button(body,s.ready and ("已准备 "..s.readyCount.."/"..s.capacity) or "准备下一局",174,44,570,43,
                    function() if not s.ready then act("next") end end,true)
            else
                button(body,"返回开桌",160,44,468,43,function() state=nil; home() end,true)
            end
            return
        end
        if board.wall then
            label(body,"牌墙 "..board.wall.." 张     最近弃牌 "..(board.discard~=0 and cardName(board.discard,level) or "—"),468,310,20)
            for i,river in ipairs(board.rivers) do
                local groups={}
                if board.groups then
                    for _,g in ipairs(board.groups[i]) do groups[#groups+1]=faces(g,level) end
                else
                    for _,g in ipairs(board.melds[i]) do groups[#groups+1]=cardName(g.tile,level).."×"..g.copies end
                end
                local recent={}
                for n=math.max(1,#river-3),#river do recent[#recent+1]=river[n] end
                local info=i.."座 弃 "..faces(recent,level).." ｜ "..table.concat(groups," / ")
                local col=(i-1)%2
                local t=label(body,info,10+col*460,275-math.floor((i-1)/2)*54,15)
                t:setAnchorPoint(cc.p(0,0.5)); t:setTextAreaSize(cc.size(445,53))
            end
            if board.chi and #board.chi>0 and s.actions[1]=="chi" then
                local choices={}
                for _,g in ipairs(board.chi) do choices[#choices+1]=faces(g,level) end
                label(body,"可选  "..table.concat(choices," / "),468,173,16,gold)
            end
        elseif board.summary then
            label(body,board.summary,468,285,21,gold)
            if board.lead and #board.lead>0 then label(body,(board.leader+1).."座   "..faces(board.lead,level),468,239,16) end
            if board.head then label(body,"头道  "..faces(board.head,level),468,236,18) end
            if board.hands then
                for i,h in ipairs(board.hands) do label(body,i.."座  "..faces(h,level),468+(i-(#board.hands+1)/2)*(900/#board.hands),224,16) end
            end
        else
            local last=#board.lead>0 and ((board.leader+1).."座   "..faces(board.lead,level)) or "等待领出"
            label(body,last,468,270,22)
            if board.openHands then
                for i,h in ipairs(board.openHands) do
                    if #h>0 then label(body,i.."座明牌  "..faces(h,level),468,248-(i-1)*27,16) end
                end
            elseif board.floats and (level==9325 or level==9425) then
                label(body,"各座飘分  "..table.concat(board.floats," / "),468,313,20)
            end
            if level==324 or level==9324 then
                local landlord=board.landlord>=0 and tostring(board.landlord+1).."座" or "待定"
                label(body,"地主 "..landlord.."    底牌 "..faces(board.bottom,level).."    "..board.multiplier.." 倍",468,313,20)
            end
        end
        local hand={}
        for i,c in ipairs(s.hand or {}) do hand[#hand+1]={i=i,code=c} end
        local function rank(c)
            if mahjong[level] or word[level] or level==388 or level==384 or level==315 or level==318 or c>=78 then return c end
            local pip=c%16
            return ((pip<3 and pip+13 or pip)*4)+math.floor(c/16)
        end
        table.sort(hand,function(a,b) return rank(a.code)<rank(b.code) end)
        local rows=#hand>24 and 2 or 1
        local cols=math.max(1,math.ceil(#hand/rows))
        local width=math.min(60,math.floor(900/cols))
        for n,item in ipairs(hand) do
            local x=468+((n-1)%cols-(cols-1)/2)*width
            local y=rows==1 and 130 or 156-46*math.floor((n-1)/cols)
            local height=rows==1 and 56 or 40
            local card
            card=button(body,cardName(item.code,level),width-2,height,x,y,function()
                selected[item.i]=not selected[item.i]
                card:setPositionY(y-height/2+(selected[item.i] and 8 or 0))
            end,true)
        end
        for i,name in ipairs(s.actions or {}) do
            local step=math.min(124,math.floor(910/#s.actions))
            button(body,verbs[name] or name,step-6,45,468+(i-(#s.actions+1)/2)*step,46,function() act(name) end,true)
        end
    end
    home()
    send("current",{level=level})
    local scheduler=cc.Director:getInstance():getScheduler()
    local timer=scheduler:scheduleScriptFunc(function()
        if not browsing and state and state.phase~="FINISHED" and state.phase~="CLOSED" then send("state",{code=state.code,version=state.version},nil,true) end
    end,1.5,false)
    root:registerScriptHandler(function(event)
        if event=="exit" and alive then alive=false; scheduler:unscheduleScriptEntry(timer) end
    end)
end

return M
