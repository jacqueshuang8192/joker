local Config = class("Config")

function Config:ctor()
    TpackageName = "xupuphz"
    g_392 = {}
    g_392.GameName = "溆浦跑胡子"
    g_392.level = 392
    g_392.my_seat_id = 0 -- 
    g_392.viewIds = {} -- 
    g_392.userInfos = {} -- 
    g_392.OwnerID = nil --房主id 
    g_392.TOTAL_PLAYERNUM = 3 -- 
    g_392.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_392.cardsAllNode = {} --所有的牌 
    g_392.backCount = 112 --所有的牌 
    g_392.curClickCardNode = nil -- 
    g_392.curOutCard = nil --当前
    g_392.curOutSeat = nil--当前
    g_392.isCanChuCard = false
    g_392.settlementData = nil--总结算数据
    g_392.isGuChou = false--箍臭不能出牌
    g_392.isTuoGuan = false--托管
    g_392.gameConfig = {}--房间配置

    g_392.t_ti = "ti"--扫穿 提
    g_392.t_wei = "wei"--歪 起手2张或歪后摸同牌,偎，扫
    g_392.t_sao_bad = 0x03--臭扫
    g_392.t_pao = "pao"--飘 碰后摸同牌 ，开舵 ，溜,跑
    g_392.t_peng = "peng"--碰
    g_392.t_chi = "chi"--吃
    g_392.t_kan = "kan"--坎
    g_392.t_hu = "hu"
    g_392.txtType = {
        [g_392.t_ti] = "提",
        [g_392.t_wei] = "偎",
        [g_392.t_pao] = "跑",
        [g_392.t_peng] = "碰",
        [g_392.t_chi] = "吃",
        [g_392.t_kan] = "坎",
    }
end

function Config:oneGameEnd()
    g_392.curClickCardNode = nil -- 
    g_392.curOutCard = nil --当前
    g_392.curOutSeat = nil--当前
    g_392.isCanChuCard = false
    g_392.cardsAllNode = {} --所有的牌 
    g_392.settlementData = nil--总结算数据
    g_392.isGuChou = false--箍臭不能出牌
    g_392.isTuoGuan = false
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    g_392.viewIds[seat_id] = viewId
    if not g_392.userInfos[uid] then
        g_392.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_392.userInfos[uid][key] = value
    end
end

function Config:getUsetInfoBySeatId(seat_id )
    for uid1, userInfo in pairs(g_392.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_392.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_392.viewIds[seat_id] = nil
    g_392.userInfos[uid] = nil
end

function Config:onExit()
    g_392 = nil
    TpackageName = nil
end

return Config