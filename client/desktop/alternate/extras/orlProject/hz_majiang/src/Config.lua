local Config = class("Config")

function Config:ctor()
    TpackageName = "hz_majiang"
    g_308 = {}
    g_308.GameName = "红中麻将"
    g_308.level = 308
    g_308.cardPath = 1
    g_308.allCards = {}
    g_308.my_seat_id = 0 -- 
    g_308.viewIds = {} -- 
    g_308.userInfos = {} -- 
    g_308.OwnerID = nil --房主id 
    g_308.banker_seat_id = nil --庄家id 
    g_308.TOTAL_PLAYERNUM = 2 -- 
    g_308.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_308.settlementData = nil--总结算数据
    g_308.isTuoGuan = false--托管
    g_308.gameConfig = {}--房间配置
    g_308.gameConfigTable = {
        {
            ["游戏名"] = g_308.GameName, 
            ["底分"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
    g_308.handCards = {}

    g_308.viewId_my = 1
    g_308.viewId_top = 2
    g_308.viewId_right = 3
    g_308.viewId_left = 4


    --胡类型
    g_308.hu_ping = 0x040
    g_308.hu_gang = 0x080
    g_308.hu_h = 0x100
    g_308.hu_zm = 0x800
    --杠类型
    g_308.gang_peng = 0x010
    g_308.gang_hua = 0x020
    g_308.gang_an = 0x200
    g_308.gang_bu = 0x400
    --碰类型
    g_308.t_peng = 0x008
    --吃类型
    g_308.chi_right = 0x001
    g_308.chi_middle = 0x002
    g_308.chi_left = 0x004
    --界面操作类型
    g_308.t_hu = bit.bor(bit.bor(bit.bor(g_308.hu_ping, g_308.hu_gang), g_308.hu_h), g_308.hu_zm)
    g_308.t_gang = bit.bor(bit.bor(bit.bor(g_308.gang_peng, g_308.gang_hua), g_308.gang_an), g_308.gang_bu)
    g_308.t_chi = bit.bor(bit.bor(g_308.chi_right, g_308.chi_middle), g_308.chi_left)
     --胡牌类型
     g_308.huArr = {"胡牌", "天胡", "地胡", "混一色", "门清","清一色", "七对", "豪华七对", "双豪华七对", "三豪华七对", "杂幺九", "全幺九", "全风头", "坎坎", "十三幺", "十八罗汉", "碰碰", "海底"}
end

function Config:starGame()
    g_308.settlementData = nil--总结算数据
    g_308.isTuoGuan = false
    g_308.handCards = {}
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    if seat_id == -1 then
        return
    end
    g_308.viewIds[seat_id] = viewId
    if not g_308.userInfos[uid] then
        g_308.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_308.userInfos[uid][key] = value
    end
end

function Config:getUsetInfoBySeatId(seat_id)
    for uid1, userInfo in pairs(g_308.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_308.userInfos) do
            if uid1 == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_308.viewIds[seat_id] = nil
    g_308.userInfos[uid] = nil
end

function Config:onExit()
    g_308 = nil
end

return Config