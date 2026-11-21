local SanGongLogic = class("SanGongLogic")
local SanGongDefine = require("sangong_new.src.ctrl.SanGongDefine")

function SanGongLogic:ctor(ctrl, scene)
    self.ctrl = ctrl
    self.scene = scene
    self.bIsTest = false

    self.playerCount = 0
    self.baseChip = 0  --下注倍率 *10 *100.....
    self.inviteCode = 0  --邀请码
    self.ownerId = 0  --房主
    self.gameConfig = ""
    self.gameConfigMsg = ""

    self.bankerSeatId = 0  --庄家座位id
    self.curRound = 0  --当前回合
    self.totalRound = 0 --总回合
    self.club_id = 0 -- 俱乐部id
    self.activityId = 0
    self.bIsWatch = false
    self.minChip = 0 --初始筹码
    self.maxChip = 0 --最高筹码
    self.gamePattern = 0 --房间类型   0金币场  1 房卡场
    self.nDichiBet = 0  --底池

    -- 0:牌局已结束 1:准备 2:等待用户抢庄 3:牌局开始 4:GRABDEALER 5:等待用户选择倍数
    -- 6:CALLTIMES 7:等待出牌 8:OUTCARD 9:ISSPECTATOR
    self.gameStatus = 0
    self.curOptSeatId = 0  --当前操作座位id

    self.tPlayers = {} --玩家列表
    self.tViewIds = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} --玩家座位排列
end

function SanGongLogic:nextRoundClean()
    for k, p in pairs(self.tPlayers) do
        p.handCardArr = {}
        p.cards_type = 0
        p.cards_point = 0
        p.maxCard = 0
    end
end

function SanGongLogic:setGameStatus(st)
    self.gameStatus = st
    GameEvent:dispatch("UpdateSanGongGameStatus", st)
end

function SanGongLogic:assignViewId(player)
    for i = 2, 10 do
        if self.tViewIds[i] == nil then
            self.tViewIds[i] = player
            return i
        end
    end
    assert(false, "over player!!")
    return 0
end

function SanGongLogic:setPlayers(list)
    self.tPlayers = {}
    for k, v in ipairs(list) do
        local new_player = clone(v)
        if new_player.uid == USER_INFO["uid"] then
            new_player.viewId = 1
            self.tViewIds[1] = new_player
            if new_player.ready == 0 then
                -- 如果自己坐下来就自动准备
                -- self.ctrl.send:sendReady(1)
                GameEvent:dispatch("SanGongReadyBtnShow", true)
            end
        else
            new_player.viewId = self:assignViewId(new_player)
        end

        table.insert(self.tPlayers, new_player)
        GameEvent:dispatch("SanGongAddPlayer", new_player.viewId, new_player)
    end
end

function SanGongLogic:addPlayers(pack)
    local is_merge = false
    local new_player = nil
    for i = 1, #self.tPlayers do
        local p = self.tPlayers[i]
        if p.uid == pack.uid then
            table.merge(p, pack)
            new_player = p
            is_merge = true
        end
    end

    if not is_merge then
        new_player = clone(pack)
        table.insert(self.tPlayers, new_player)
        if pack.uid == USER_INFO["uid"] then
            new_player.viewId = 1
            self.tViewIds[1] = new_player
        else
            new_player.viewId = self:assignViewId(new_player)
        end
    end

    if pack.uid == USER_INFO["uid"] then
        --如果自己坐下来就自动准备
        -- self.ctrl.send:sendReady(1)
        GameEvent:dispatch("SanGongReadyBtnShow", true)
    end
    GameEvent:dispatch("SanGongAddPlayer", new_player.viewId, new_player)
end

function SanGongLogic:delPlayers(uid)
    for i = #self.tPlayers, 1, -1 do
        local p = self.tPlayers[i]
        if p.uid == uid then
            local p = table.remove(self.tPlayers, i)
            self.tViewIds[p.viewId] = nil
        end
    end
    GameEvent:dispatch("SanGongDelPlayer", uid)
end

function SanGongLogic:setPlayerReady(uid, ready)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            p.ready = ready
        end
    end
    GameEvent:dispatch("SanGongReadyStatus", uid, ready)

    if uid == USER_INFO["uid"] and ready == 1 then
        GameEvent:dispatch("SanGongReadyBtnShow", false)
    end
end

function SanGongLogic:setPlayerGold(uid, gold, isAdd)
    local nowgold = gold
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            if isAdd then
                p.gold = p.gold + gold
                nowgold = p.gold
            else
                p.gold = gold
            end
        end
    end
    GameEvent:dispatch("UpdateSanGongPlayerGold", uid, nowgold)
end

function SanGongLogic:setPlayerCardsByUid(uid, cards)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            p.handCardArr = cards
        end
    end
end

function SanGongLogic:setPlayerCardsBySeatId(seatId, cards)
    for k, p in pairs(self.tPlayers) do
        if p.seatId == seatId then
            p.handCardArr = cards
        end
    end
end

function SanGongLogic:setOpenCards(uid, cards, ctype, point, maxCard)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            p.handCardArr = cards
            p.cards_type = ctype
            p.cards_point = point
            p.maxCard = maxCard
            GameEvent:dispatch("SanGongPlayerOpenCards", uid)
            return true
        end
    end
    print("Set Open Cards Error!", uid)
end

--是否开启托管
function SanGongLogic:setPlayerAuto(uid, isAuto)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            p.isAuto = isAuto
        end
    end
    GameEvent:dispatch("SanGongAutoState", uid, isAuto)
end

function SanGongLogic:setPlayerOnLine(uid, onLine)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            p.onLine = onLine
        end
    end
    GameEvent:dispatch("SanGongPlayerDisconnect", uid, onLine)
end

function SanGongLogic:getPlayerByUid(uid)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            return p
        end
    end
    return nil
end

function SanGongLogic:getPlayerViewId(uid)
    local p = self:getPlayerByUid(uid)
    return p.viewId
end

function SanGongLogic:setBankerSeat(id)
    self.bankerSeatId = id
    GameEvent:dispatch("SanGongChangeBankerSeat")
end

function SanGongLogic:setRoundInfo(curRound, totalRound)
    self.curRound = curRound
    self.totalRound = totalRound
    GameEvent:dispatch("SanGongUpdateRoundInfo")
end

function SanGongLogic:setLoginRoom(pack)
    self.club_id = pack.club_id -- 俱乐部id
    self.activityId = pack.activityId
    self.baseChip = pack.baseChip  --下注倍率 *10 *100.....
    self.inviteCode = pack.inviteCode --邀请码
    self.ownerId = pack.star_game_uid --等于自己房主就可以开始游戏
    self.gameConfig = pack.gameConfig
    self.gameStatus = pack.tableStatus
    self.bIsWatch = pack.isWatch == 0 --1玩家 0围观
    self.minChip = pack.initialChip  --初始筹码
    self.maxChip = pack.times --最高筹码
    self.gamePattern = pack.gamePattern --房间类型   0金币场  1 房卡场

    -- pack.outCardAniTime
    -- pack.gold

    self.gameConfigTable = json.decode(self.gameConfig) --g_360.anCard
    if self.gameConfigTable['times'] then
        self.baseChip = self.gameConfigTable['times']
    end

    self.playerCount = self.gameConfigTable.maxSeatCount

    -- self.gameConfigTable.times
    -- self.gameConfigTable.startCount

    GameEvent:dispatch("SanGongLoginRoomInfo")
end

return SanGongLogic
