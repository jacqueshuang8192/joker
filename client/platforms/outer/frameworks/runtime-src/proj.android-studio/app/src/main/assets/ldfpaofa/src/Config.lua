local Config = class("Config")

function Config:ctor()
    TpackageName = "ldfpaofa"
    g_345 = {}
    g_345.GameName = "娄底放炮罚"
    g_345.level = 345
    g_345.cardPath = 1
    g_345.allCards = {}
    g_345.my_seat_id = 0 -- 
    g_345.viewIds = {} -- 
    g_345.userInfos = {} -- 
    g_345.OwnerID = nil --房主id 
    g_345.banker_seat_id = nil --庄家id 
    g_345.TOTAL_PLAYERNUM = 3 -- 
    g_345.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_345.backCount = 112 --所有的牌 
    g_345.curOutCard = nil --当前
    g_345.curOutSeat = nil--当前
    g_345.isCanChuCard = false
    g_345.chuPos = nil--出牌的位置
    g_345.settlementData = nil--总结算数据
    g_345.isTuoGuan = false--托管
    g_345.gameConfig = {}--房间配置
    g_345.isHongPeng = false--带红碰小的2710 6胡息 大的2710 9胡息
    g_345.curClickCardNode = nil -- 
    g_345.fanData = nil -- 翻醒数据
    g_345.piaoPoints = {}--seat_id:piao
    g_345.isPiao = false
    g_345.isSiShou = false
    
    g_345.t_ti = "ti"--扫穿 提
    g_345.t_wei = "wei"--歪 起手2张或歪后摸同牌,偎，扫
    g_345.t_sao_bad = 0x03--臭扫
    g_345.t_pao = "pao"--飘 碰后摸同牌 ，开舵 ，溜,跑
    g_345.t_peng = "peng"--碰
    g_345.t_chi = "chi"--吃
    g_345.t_kan = "kan"--坎
    g_345.t_hu = "hu"
    g_345.t_bi = "bi"
    g_345.txtType = {
        [g_345.t_ti] = "提",
        [g_345.t_wei] = "偎",
        [g_345.t_pao] = "跑",
        [g_345.t_peng] = "碰",
        [g_345.t_chi] = "吃",
        [g_345.t_kan] = "坎",
    }
    g_345.gameConfigTable = {
        {
            ["游戏名"] = g_345.GameName, 
            ["倍率"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
end

function Config:starGame()
    g_345.curClickCardNode = nil -- 
    g_345.curOutCard = nil --当前
    g_345.curOutSeat = nil--当前
    g_345.isCanChuCard = false
    g_345.settlementData = nil--总结算数据
    if g_345.gameConfig.modetype == 2 then--1 100胡息结算 2 单局结算
        g_345.isTuoGuan = false
    end
    g_345.fanData = nil -- 翻醒数据
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    dump(g_345.viewIds)
    g_345.viewIds[seat_id] = viewId
    if not g_345.userInfos[uid] then
        g_345.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_345.userInfos[uid][key] = value
    end
    dump(g_345.viewIds, "addUseraddUser asdf")
    print(debug.traceback())
end

function Config:getUsetInfoBySeatId(seat_id )
    for uid1, userInfo in pairs(g_345.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_345.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    dump(g_345.userInfos)
    g_345.viewIds[seat_id] = nil
    g_345.userInfos[uid] = nil
    dump(g_345.viewIds, "delUserdelUser asdf")
    print(debug.traceback())
end

function Config:onExit()
    g_345 = nil
    TpackageName = nil
end

return Config