local Config = class("Config")

function Config:ctor()
    TpackageName = "zhajinhua_jb"
    g_317 = {}
    g_317.GameName = "欢乐三张"
    g_317.level = 317
    g_317.cardPath = 1
    g_317.allCards = {}
    g_317.my_seat_id = 0 -- 
    g_317.viewIds = {} -- 
    g_317.userInfos = {} -- 
    g_317.OwnerID = nil --房主id 
    g_317.banker_seat_id = nil --庄家id 
    g_317.TOTAL_PLAYERNUM = 3 -- 
    g_317.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_317.settlementData = nil--总结算数据
    g_317.isTuoGuan = false--托管
    g_317.gameConfig = {}--房间配置
    g_317.all_turns = 10
    g_317.gameConfigTable = {
        {
            ["游戏名"] = g_317.GameName, 
            ["底分"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
    g_317.min_pk_round = 0--pk最少轮数
    g_317.min_allin_round = 0--allin最少轮数
    g_317.zhus = {}--加注筹码
    g_317.allZhus = {}--全压筹码
    g_317.table_chips = 0--桌子剩余金额
    g_317.now_zhu = 0--最后一个玩家当前的下注
    g_317.isKan = {}--uid:true 玩家看牌
    g_317.isDiu = {}--uid:1 弃牌， 2 比牌输了
    g_317.countUserAllin = 0--是否可以血拼  1可以血拼 其它不可以
    g_317.isAllin = 0--是否已经全压
    g_317.isCuoPai = false --
    g_317.isCanKan = false--是否可以看牌
    g_317.isCanAllin = 0--用户是否可以全压
    
    g_317.handCards = {}
    g_317.card_type = 0
    g_317.now_turns = 0--下注第几轮
end

function Config:starGame()
    g_317.settlementData = nil--总结算数据
    g_317.isTuoGuan = false
    g_317.table_chips = 0--桌子剩余金额
    g_317.now_zhu = 0--最后一个玩家当前的下注
    g_317.isKan = {}--uid:true 玩家看牌
    g_317.isDiu = {}--uid:1 弃牌， 2 比牌输了
    g_317.isAllin = 0--是否已经全压
    g_317.countUserAllin = 0--是否可以血拼  1可以血拼 其它不可以
    g_317.isCuoPai = false --是否搓牌了
    g_317.isCanKan = false--是否可以看牌

    g_317.handCards = {}
    g_317.card_type = 0
    g_317.now_turns = 0--下注第几轮
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    if seat_id == -1 then
        return
    end
    g_317.viewIds[seat_id] = viewId
    if not g_317.userInfos[uid] then
        g_317.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_317.userInfos[uid][key] = value
    end
end

function Config:getUsetInfoBySeatId(seat_id)
    for uid1, userInfo in pairs(g_317.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_317.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_317.viewIds[seat_id] = nil
    g_317.userInfos[uid] = nil
end

function Config:onExit()
    g_317 = nil
end

return Config