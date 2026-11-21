local NinetySixLogic = class("NinetySixLogic")
local NinetySixDefine = require("96game.src.ctrl.NinetySixDefine")

function NinetySixLogic:ctor(ctrl, scene)
    self.ctrl = ctrl
    self.scene = scene
    self.mySeatId = -1
    self.playerCount = 0
    self.baseChip = 0
    self.inviteCode = 0  --邀请码
    self.ownerId = 0  --房主
    self.gameConfig = ""
    self.gameConfigMsg = ""
    self.bankerSeatId = 0  --庄家座位id
    self.tPlayerCards = {}  --手牌数据
    self.curRound = 0  --当前回合
    self.totalRound = 0  --总回合
    self.gameStatus = 0 --桌子的状态  0停止游戏状态， 1正在游戏状态，2等待下一局游戏状态
    self.curOptSeatId = 0  --当前操作座位id
    self.duoPai = 0  --垛牌

    self.tingCards = {}
    self.tPlayers = {} --玩家列表

    self.card_config = {
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0B,0x0C,0x0D,  --方块 A - K
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1B,0x1C,0x1D,  --梅花 A - K
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2B,0x2C,0x2D,  --红桃 A - K
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3B,0x3C,0x3D   --黑桃 A - K
    }

    self.tOptStr = {
        -- [0] = {str = "没有动作", voice = "", ani = ""},
        -- [9] = {str = "其它", voice = "", ani = ""},

        [NinetySixDefine.CHI] = {str = "吃", voice = "chi", ani = "chi"},
        [NinetySixDefine.PENG] = {str = "碰", voice = "peng", ani = "peng"},
        [NinetySixDefine.TIE] = {str = "贴", voice = "tie", ani = "tie"},
        [NinetySixDefine.SHAO] = {str = "勺", voice = "shao", ani = "shao"},
        [NinetySixDefine.KAN] = {str = "坎", voice = "", ani = "kan"},
        [NinetySixDefine.ZOU] = {str = "走", voice = "zou", ani = "zou"},
        [NinetySixDefine.HU] = {str = "胡", voice = "hu", ani = "hu"},
        [NinetySixDefine.SHUN] = {str = "顺", voice = "", ani = "shun"},
        [NinetySixDefine.SHUANGLONGXIZHU] = {str = "双龙戏珠", voice = "", ani = "shuanglongxizhu"},
        --[NinetySixDefine.OTHER] = {str = "", voice = "", ani = "shun"},

        [NinetySixDefine.HU_PAI_PU_TONG] = {str = "平胡", voice = "hu", ani = "hu"},
        [NinetySixDefine.HU_PAI_SE_DA] = {str = "色大胡", voice = "dahu", ani = "dahu"},
        [NinetySixDefine.HU_PAI_DI] = {str = "地胡", voice = "dihu", ani = "dihu"},
        [NinetySixDefine.HU_PAI_KUN_DA] = {str = "荤大胡", voice = "", ani = "hundahu"},
        [NinetySixDefine.HU_PAI_KUN] = {str = "荤胡", voice = "hunhu", ani = "hunhu"},
        [NinetySixDefine.HU_PAI_KUN_TAI_TWO] = {str = "荤台胡", voice = "huntaihu", ani = "huntahu"},
        [NinetySixDefine.HU_PAI_QING] = {str = "清胡", voice = "qinghu", ani = "qinhu"},
        [NinetySixDefine.HU_PAI_SE] = {str = "色胡", voice = "sehu", ani = "sehu"},
        [NinetySixDefine.HU_PAI_SU_DA] = {str = "素大胡", voice = "sudahu", ani = "sudahu"},
        [NinetySixDefine.HU_PAI_SU] = {str = "素胡", voice = "suhu", ani = "suhu"},
        [NinetySixDefine.HU_PAI_SU_TAI_FOUR] = {str = "素太胡", voice = "sutaihu", ani = "sutaihu"},
        [NinetySixDefine.HU_PAI_TIAN] = {str = "天胡", voice = "tianhu", ani = "tianhu"},
        [NinetySixDefine.HU_ZHU_PAI] = {str = "抓猪", voice = "zhuozhu", ani = "zhuazhu"},
        [NinetySixDefine.HU_PAI_KUN_TAI_FOUR] = {str = "荤太胡", voice = "huntaihu", ani = "huntaihu"},
        [NinetySixDefine.HU_PAI_SU_QING] = {str = "素清胡", voice = "", ani = "suqinhu"},
        [NinetySixDefine.HU_PAI_SU_TAI_TWO] = {str = "素台胡", voice = "", ani = "sutahu"},
        [NinetySixDefine.HU_PAI_SE_TAI_TWO] = {str = "色台胡", voice = "", ani = "tahu"},
        [NinetySixDefine.HU_PAI_SE_TAI_FOUR] = {str = "色太胡", voice = "", ani = "taihu"},
        [NinetySixDefine.DA_HU] = {str = "大胡", voice = "", ani = "hu"},
        [NinetySixDefine.TAI_HU] = {str = "太胡", voice = "", ani = "hu"},
        [NinetySixDefine.TAI_2_HU] = {str = "台胡", voice = "", ani = "hu"},
        [NinetySixDefine.BAN_ZHAO] = {str = "开半招", voice = "banzhao", ani = "banzao"},
        [NinetySixDefine.MAN_ZHAO] = {str = "开满招", voice = "manzhao", ani = "manzhao"},
        [NinetySixDefine.MAN_YUAN_GUN] = {str = "满圆滚", voice = "manyuangun", ani = "manyuangun"},
        [NinetySixDefine.HU_PAI_ZIMO] = {str = "自摸", voice = "zimo", ani = "zimo"},

        -- [27] = {str = "色大胡", voice = "", ani = "sedahu"},
        -- [28] = {str = "色台胡", voice = "", ani = "setahu"},
        -- [29] = {str = "色太胡", voice = "", ani = "setaihu"},
    }
end

function NinetySixLogic:nextRoundClean()
    self.tPlayerCards = {}
end

function NinetySixLogic:setPlayers(list)
    self.tPlayers = {}
    for k, v in pairs(list) do
        local new_player = clone(v)
        dump(new_player,"new_player")
        if  new_player.uid == USER_INFO["uid"] then
            self.mySeatId = new_player.seatId
            if new_player.ready == 0 then
                --如果自己坐下来就自动准备
                -- self.ctrl.send:sendReady(1)
                GameEvent:dispatch("NinetySixReadyBtnShow", true)
            end
        end

        table.insert(self.tPlayers, new_player)
    end
    if self.mySeatId == nil or self.mySeatId < 0 then
        self.mySeatId = 0
    end
    self:dispatchAllPlayer()
end

function NinetySixLogic:dispatchAllPlayer()
    dump(self.mySeatId ,"self.mySeatId ")
    dump(self.playerCount,"self.playerCount")
    if self.mySeatId < 0 or self.playerCount < 2 then
        return
    end

    for k, p in pairs(self.tPlayers) do
        local viewId = self:getViewId(p.seatId)
        GameEvent:dispatch("NinetySixPlayerInitialEnter", viewId, p)
    end
end

function NinetySixLogic:setPlayerReady(uid, ready)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            p.ready = ready
        end
    end
    GameEvent:dispatch("NinetySixReadyStatus", uid, ready)
    
    if uid == USER_INFO["uid"] and ready == 1 then
        GameEvent:dispatch("NinetySixReadyBtnShow", false)
    end
end

function NinetySixLogic:upateTotalBlc(list)
    for a, b in pairs(list) do
        for k, p in pairs(self.tPlayers) do
            if p.uid == b.uid then
                p.m_totalBlc = b.m_totalBlc
                p.chips = b.chips
            end
        end
    end
end

function NinetySixLogic:getPlayerByUid(uid)
    for k, p in pairs(self.tPlayers) do
        if p.uid == uid then
            return p
        end
    end
    return nil
end

function NinetySixLogic:getPlayerViewId(uid)
    local p = self:getPlayerByUid(uid)
    local viewId = 0
    if p then
        viewId = self:getViewId(p.seatId)
    end
    return viewId
end

function NinetySixLogic:addPlayers(pack)
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
    end

    if pack.uid == USER_INFO["uid"] then
        self.mySeatId = pack.seatId

        --如果自己坐下来就自动准备
        -- self.ctrl.send:sendReady(1)
        GameEvent:dispatch("NinetySixReadyBtnShow", true)
        self:dispatchAllPlayer()
    else
        if self.mySeatId < 0 or self.playerCount < 2 then
            return
        end

        local viewId = self:getViewId(new_player.seatId)
        GameEvent:dispatch("NinetySixAddPlayer", viewId, new_player)
    end
end

function NinetySixLogic:delPlayers(uid)
    for i = #self.tPlayers, 1, -1 do
        local p = self.tPlayers[i]
        if p.uid == uid then
            table.remove(self.tPlayers, i)
        end
    end
    GameEvent:dispatch("NinetySixDelPlayer", uid)
end

function NinetySixLogic:setBankerSeat(id)
    self.bankerSeatId = id
    GameEvent:dispatch("NinetySixChangeBankerSeat")
end

function NinetySixLogic:setCurOptSeatId(id)
    self.curOptSeatId = id
    GameEvent:dispatch("NinetySixMoveHead", id)
    --MoveHead
    --local viewId = self:getViewId(id)
    --GameEvent:dispatch("NinetySixCurOptViewIdChange", viewId)
end

function NinetySixLogic:setDuoPai(num)
    self.duoPai = num
    GameEvent:dispatch("NinetySixDuoPaiChange", num)
end

function NinetySixLogic:setTingCards(tingCards)
    self.tingCards = tingCards
    GameEvent:dispatch("NinetySixTingCardsUpdate", tingCards)
end

function NinetySixLogic:setRoundInfo(curRound, totalRound)
    self.curRound = curRound
    self.totalRound = totalRound
    GameEvent:dispatch("NinetySixUpdateRoundInfo")
end

function NinetySixLogic:setPlayerCards(tCards, isReconnection)
    self.tPlayerCards = tCards
    GameEvent:dispatch("NinetySixDealCards", tCards, isReconnection)
end
function NinetySixLogic:setThePlayerCards(tCards, isReconnection)

    GameEvent:dispatch("NinetySixTheDealCards", tCards, isReconnection)
end
function NinetySixLogic:getViewId(seatId)
    if self.mySeatId < 0 or self.playerCount < 2 then
        local fmt = "error in calc view id! playerCount:%s mySeatId:%s, seatId:%s"
        local str = string.format(fmt, tostring(self.playerCount), tostring(self.mySeatId), tostring(seatId))
        error(str)
        return 0
    end

    if self.playerCount == 2 then
        if seatId == self.mySeatId then
            return 1
        else
            return 3
        end
    elseif self.playerCount > 2 then
        local ret = 1 + (seatId - self.mySeatId + self.playerCount) % self.playerCount
        return ret
    end
end

function NinetySixLogic:setLoginRoom(pack)
    self.playerCount = pack.maxPlayerCount
    self.baseChip = pack.baseChip
    self.inviteCode = pack.inviteCode
    self.ownerId = pack.ownerId
    self.gameConfig = pack.gameConfig
    self.mySeatId = pack.seatId
    dump(self.baseChip,"self.baseChip")
    dump( self.inviteCode," self.inviteCode")
    GameEvent:dispatch("NinetySixLoginRoomInfo")
    GameEvent:dispatch("NinetySixLoginBaseChips")
    
end

function NinetySixLogic:setReconnection(pack)
    self.playerCount = pack.maxPlayerCount
    self.baseChip = pack.baseChip
    self.inviteCode = pack.inviteCode
    self.ownerId = pack.ownerId
    self.gameConfig = pack.gameConfig
    self.mySeatId = pack.seatId
    self.gameStatus = pack.gameStatus
    self.bankerSeatId = pack.bankerSeatId

    GameEvent:dispatch("NinetySixReconnection")
    GameEvent:dispatch("NinetySixLoginBaseChips")
end

--重连牌数据恢复
function NinetySixLogic:reconnectionAllCards()
    for k, p in pairs(self.tPlayers) do
        local viewId = self:getViewId(p.seatId)
        GameEvent:dispatch("NinetySixPlayerInitAllOutCard", viewId, p)
    end
end

return NinetySixLogic
