local Config = class("Config")

function Config:ctor()
    TpackageName = "hcphz"
    g_396 = {}
    g_396.GameName = "河池字牌"
    g_396.level = 396
    g_396.my_seat_id = 0 -- 
    g_396.viewIds = {} -- 
    g_396.userInfos = {} -- 
    g_396.OwnerID = nil --房主id 
    g_396.TOTAL_PLAYERNUM = 3 -- 
    g_396.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_396.backCount = 112 --所有的牌 
    g_396.curOutCard = nil --当前
    g_396.curOutSeat = nil--当前
    g_396.isCanChuCard = false
    g_396.settlementData = nil--总结算数据
    g_396.isTuoGuan = false--托管
    g_396.gameConfig = {}--房间配置
    g_396.isHongPeng = false--带红碰小的2710 6胡息 大的2710 9胡息
    g_396.curClickCardNode = nil -- 
    g_396.fanData = nil -- 翻醒数据
    
    g_396.t_ti = "ti"--扫穿 提
    g_396.t_wei = "wei"--歪 起手2张或歪后摸同牌,偎，扫
    g_396.t_sao_bad = 0x03--臭扫
    g_396.t_pao = "pao"--飘 碰后摸同牌 ，开舵 ，溜,跑
    g_396.t_peng = "peng"--碰
    g_396.t_chi = "chi"--吃
    g_396.t_kan = "kan"--坎
    g_396.t_hu = "hu"
    g_396.t_bi = "bi"
    g_396.txtType = {
        [g_396.t_ti] = "提",
        [g_396.t_wei] = "偎",
        [g_396.t_pao] = "跑",
        [g_396.t_peng] = "碰",
        [g_396.t_chi] = "吃",
        [g_396.t_kan] = "坎",
    }
    g_396.gameConfigTable = {
        {
            ["游戏名"] = g_396.GameName, 
            ["底分"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
end

function Config:starGame()
    g_396.curClickCardNode = nil -- 
    g_396.curOutCard = nil --当前
    g_396.curOutSeat = nil--当前
    g_396.isCanChuCard = false
    g_396.settlementData = nil--总结算数据
    g_396.isTuoGuan = false
    g_396.fanData = nil -- 翻醒数据
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    g_396.viewIds[seat_id] = viewId
    if not g_396.userInfos[uid] then
        g_396.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_396.userInfos[uid][key] = value
    end
end

function Config:getUsetInfoBySeatId(seat_id )
    for uid1, userInfo in pairs(g_396.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_396.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_396.viewIds[seat_id] = nil
    g_396.userInfos[uid] = nil
end

function Config:onExit()
    g_396 = nil
    TpackageName = nil
end

return Config