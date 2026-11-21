local Config = class("Config")

function Config:ctor()
    TpackageName = "shaoyangbopi"
    g_353 = {}
    g_353.GameName = "邵阳剥皮"
    g_353.level = 353
    g_353.cardPath = 1
    g_353.allCards = {}
    g_353.my_seat_id = 0 -- 
    g_353.viewIds = {} -- 
    g_353.userInfos = {} -- 
    g_353.OwnerID = nil --房主id 
    g_353.banker_seat_id = nil --庄家id 
    g_353.TOTAL_PLAYERNUM = 3 -- 
    g_353.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_353.curOutCard = nil --当前
    g_353.curOutSeat = nil--当前
    g_353.isCanChuCard = false
    g_353.chuPos = nil--出牌的位置
    g_353.settlementData = nil--总结算数据
    g_353.isTuoGuan = false--托管
    g_353.gameConfig = {}--房间配置
    g_353.isHongPeng = false--带红碰小的2710 6胡息 大的2710 9胡息
    g_353.curClickCardNode = nil -- 
    g_353.fanData = nil -- 翻醒数据
    g_353.piaoPoints = {}--seat_id:piao
    g_353.isPiao = false
    
    g_353.t_ti = "ti"--扫穿 提
    g_353.t_wei = "wei"--歪 起手2张或歪后摸同牌,偎，扫
    g_353.t_sao_bad = 0x03--臭扫
    g_353.t_pao = "pao"--飘 碰后摸同牌 ，开舵 ，溜,跑
    g_353.t_peng = "peng"--碰
    g_353.t_chi = "chi"--吃
    g_353.t_kan = "kan"--坎
    g_353.t_hu = "hu"
    g_353.t_bi = "bi"
    g_353.txtType = {
        [g_353.t_ti] = "提",
        [g_353.t_wei] = "偎",
        [g_353.t_pao] = "跑",
        [g_353.t_peng] = "碰",
        [g_353.t_chi] = "吃",
        [g_353.t_kan] = "坎",
    }
    g_353.gameConfigTable = {
        {
            ["游戏名"] = g_353.GameName, 
            ["倍率"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
end

function Config:starGame()
    g_353.curClickCardNode = nil -- 
    g_353.curOutCard = nil --当前
    g_353.curOutSeat = nil--当前
    g_353.isCanChuCard = false
    g_353.settlementData = nil--总结算数据
    -- g_353.isTuoGuan = false
    g_353.fanData = nil -- 翻醒数据
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    g_353.viewIds[seat_id] = viewId
    if not g_353.userInfos[uid] then
        g_353.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_353.userInfos[uid][key] = value
    end
end

function Config:getUsetInfoBySeatId(seat_id )
    for uid1, userInfo in pairs(g_353.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_353.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_353.viewIds[seat_id] = nil
    g_353.userInfos[uid] = nil
end

function Config:onExit()
    g_353 = nil
    TpackageName = nil
end

return Config