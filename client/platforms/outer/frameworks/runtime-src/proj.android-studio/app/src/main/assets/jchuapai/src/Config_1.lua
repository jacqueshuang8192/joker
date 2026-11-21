local Config = class("Config")

function Config:ctor()
    TpackageName = "jchuapai"
    g_388 = {}
    g_388.GameName = "荆楚花牌"
    g_388.version = "1.0.1"
    g_388.level = 388
    g_388.isHua_388 = false -- 是否显示花牌 默认不同牌
    g_388.isHua_388 = cc.UserDefault:getInstance():getBoolForKey("isHua_388")
    g_388.my_seat_id = 0 -- 
    g_388.viewIds = {} -- 
    g_388.userInfos = {} -- 
    g_388.OwnerID = nil --房主id 
    g_388.TOTAL_PLAYERNUM = 3 -- 
    g_388.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_388.cardsAllNode = {} --所有的牌 
    g_388.backCount = 112 --所有的牌 
    g_388.curClickCardNode = nil -- 
    g_388.curOutCard = nil --当前
    g_388.curOutSeat = nil--当前
    g_388.isCanChuCard = false
    g_388.gameConfig = {}--房间配置
    g_388.gameModel = 0  --游戏模式

    g_388.gameConfigTable = {
        {
            ["游戏名"] = g_388.GameName, 
            ["底分"] = 1
        }, 
        {["特殊玩法"] = ""}
    }
    g_388.disableTouch = true --是否禁用表情动画
end

function Config:oneGameEnd()
    g_388.curClickCardNode = nil -- 
    g_388.curOutCard = nil --当前
    g_388.curOutSeat = nil--当前
    g_388.isCanChuCard = false
    g_388.cardsAllNode = {} --所有的牌 
end

function Config:addUser( uid, seat_id, viewId, userInfo )
    g_388.viewIds[seat_id] = viewId
    if not g_388.userInfos[uid] then
        g_388.userInfos[uid] = {}
    end
    for key, value in pairs(userInfo) do
        g_388.userInfos[uid][key] = value
    end
end

function Config:delUser(uid, seat_id )
    if not seat_id then
        for uid1, userInfo in pairs(g_388.userInfos) do
            if uid == userInfo.uid then
                seat_id = userInfo.seat_id
            end
        end
    end
    g_388.viewIds[seat_id] = nil
    g_388.userInfos[uid] = nil
end

function Config:getUsetInfoBySeatId(seat_id )
    for uid1, userInfo in pairs(g_388.userInfos) do
        if seat_id == userInfo.seat_id then
            return userInfo
        end
    end
    return {}
end

function Config:onExit()

end

return Config