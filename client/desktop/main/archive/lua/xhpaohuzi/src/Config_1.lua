local Config = class("Config")

function Config:ctor()
    TpackageName = "xhpaohuzi"
    g_398 = {}
    g_398.GameName = "新化跑胡子"
    g_398.level = 398
    g_398.cardPath = 1
    g_398.allCards = {}
    g_398.my_seat_id = 0 -- 
    g_398.viewIds = {} -- 
    g_398.userInfos = {} -- 
    g_398.OwnerID = nil --房主id 
    g_398.banker_seat_id = nil --庄家id 
    g_398.TOTAL_PLAYERNUM = 3 -- 
    g_398.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_398.backCount = 112 --所有的牌 
    g_398.curOutCard = nil --当前
    g_398.curOutSeat = nil--当前
    g_398.isCanChuCard = false
    g_398.chuPos = nil--出牌的位置
    g_398.settlementData = nil--总结算数据
    g_398.isTuoGuan = false--托管
    g_398.gameConfig = {}--房间配置
    g_398.isHongPeng = false--带红碰小的2710 6胡息 大的2710 9胡息
    g_398.curClickCardNode = nil -- 
    g_398.fanData = nil -- 翻醒数据
    g_398.isPiao = false
    g_398.piaoPoints = {}--seat_id:piao
    
    g_398.t_ti = "ti"--扫穿 提
    g_398.t_wei = "wei"--歪 起手2张或歪后摸同牌,偎，扫
    g_398.t_sao_bad = 0x03--臭扫
    g_398.t_pao = "pao"--飘 碰后摸同牌 ，开舵 ，溜,跑
    g_398.t_peng = "peng"--碰
    g_398.t_chi = "chi"--吃
    g_398.t_kan = "kan"--坎
    g_398.t_hu = "hu"
    g_398.t_bi = "bi"
    g_398.txtType = {
        [g_398.t_ti] = "提",
        [g_398.t_wei] = "偎",
        [g_398.t_pao] = "跑",
        [g_398.t_peng] = "碰",
        [g_398.t_chi] = "吃",
        [g_398.t_kan] = "坎",
    }
    g_398.gameConfigTable = {
        {
            ["游戏名"] = g_398.GameName, 
            ["底分"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
end

function Config:starGame()
    g_398.curClickCardNode = nil -- 
    g_398.curOutCard = nil --当前
    g_398.curOutSeat = nil--当前
    g_398.isCanChuCard = false
    g_398.settlementData = nil--总结算数据
    -- g_398.isTuoGuan = false
    g_398.fanData = nil -- 翻醒数据
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    g_398.viewIds[seat_id] = viewId
    if not g_398.userInfos[uid] then
        g_398.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_398.userInfos[uid][key] = value
    end
end

function Config:getUsetInfoBySeatId(seat_id )
    for uid1, userInfo in pairs(g_398.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_398.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_398.viewIds[seat_id] = nil
    g_398.userInfos[uid] = nil
end

function Config:onExit()
    g_398 = nil
    TpackageName = nil
end

return Config