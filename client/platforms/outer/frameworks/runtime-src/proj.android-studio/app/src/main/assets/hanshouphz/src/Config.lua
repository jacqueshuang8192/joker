local Config = class("Config")

function Config:ctor()
    TpackageName = "hanshouphz"
    g_501 = {}
    g_501.GameName = "汉寿跑胡子"
    g_501.level = 501
    g_501.my_seat_id = 0 -- 
    g_501.viewIds = {} -- 
    g_501.userInfos = {} -- 
    g_501.OwnerID = nil --房主id 
    g_501.TOTAL_PLAYERNUM = 3 -- 
    g_501.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_501.backCount = 112 --所有的牌 
    g_501.curOutCard = nil --当前
    g_501.curOutSeat = nil--当前
    g_501.isCanChuCard = false
    g_501.settlementData = nil--总结算数据
    g_501.isTuoGuan = false--托管
    g_501.gameConfig = {}--房间配置
    g_501.isHongPeng = false--带红碰小的2710 6胡息 大的2710 9胡息
    g_501.curClickCardNode = nil -- 
    g_501.fanData = nil -- 翻醒数据
    g_501.isPiao = false
    g_501.piaoPoints = {}--seat_id:piao
    
    g_501.anWei = true --是否暗偎
    g_501.t_ti = "ti"--扫穿 提
    g_501.t_wei = "wei"--歪 起手2张或歪后摸同牌,偎，扫
    g_501.t_sao_bad = 0x03--臭扫
    g_501.t_pao = "pao"--飘 碰后摸同牌 ，开舵 ，溜,跑
    g_501.t_peng = "peng"--碰
    g_501.t_chi = "chi"--吃
    g_501.t_kan = "kan"--坎
    g_501.t_hu = "hu"
    g_501.t_bi = "bi"
    g_501.txtType = {
        [g_501.t_ti] = "提",
        [g_501.t_wei] = "偎",
        [g_501.t_pao] = "跑",
        [g_501.t_peng] = "碰",
        [g_501.t_chi] = "吃",
        [g_501.t_kan] = "坎",
    }
    g_501.gameConfigTable = {
        {
            ["游戏名"] = g_501.GameName, 
            ["底分"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
end

function Config:starGame()
    g_501.curClickCardNode = nil -- 
    g_501.curOutCard = nil --当前
    g_501.curOutSeat = nil--当前
    g_501.isCanChuCard = false
    g_501.settlementData = nil--总结算数据
    -- g_501.isTuoGuan = false
    g_501.fanData = nil -- 翻醒数据
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    g_501.viewIds[seat_id] = viewId
    if not g_501.userInfos[uid] then
        g_501.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_501.userInfos[uid][key] = value
    end
end

function Config:getUsetInfoBySeatId(seat_id )
    for uid1, userInfo in pairs(g_501.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_501.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_501.viewIds[seat_id] = nil
    g_501.userInfos[uid] = nil
end

function Config:onExit()
    g_501 = nil
    TpackageName = nil
end

return Config