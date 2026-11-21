local Config = class("Config")

function Config:ctor()
    TpackageName = "shenshou100"
    g_102 = {}
    g_102.GameName = "百人神兽"
    g_102.TOTAL_PLAYERNUM = 10
    g_102.level = 102
    g_102.cardPath = 1
    g_102.allCards = {}
    g_102.my_seat_id = 0 -- 
    g_102.allUser = {} -- 
    g_102.OwnerID = nil --房主id 
    g_102.banker_seat_id = nil --庄家id 
    g_102.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_102.settlementData = nil--总结算数据
    g_102.gameConfig = {}--房间配置
    g_102.recordData = {}
    g_102.gameStatus = 0--游戏状态  --游戏状态  0 空闲，1:进行中
    g_102.xiaZhuData = {}
    g_102.gameConfigTable = {
        {
            ["游戏名"] = g_102.GameName, 
            ["倍率"] = 1
        }, 
        {["特殊玩法"] = ""}
    }

    g_102.userInfos = function(uid)
        for i,v in ipairs(g_102.allUser) do
            if uid == v.uid then
                return v
            end
        end
        return
    end
    g_102.getZhuangUsers = function(_type)
        local users = {}
        for i,v in ipairs(g_102.allUser) do
            if _type == v.isBanker then
                table.insert( users, v )
            end
        end
        return users
    end

    g_102.updateChips = function(uid, chips, isBanker)
        for k, j in ipairs(g_102.allUser) do
            if j.uid == uid then
                if chips then
                    g_102.allUser[k].chips = chips
                end
                if isBanker then
                    g_102.allUser[k].isBanker = isBanker
                end
                return j
            end
        end
    end
end

function Config:starGame()
    g_102.settlementData = nil--总结算数据
end
function Config:updateUser( playerList )
    for i,v in ipairs(playerList) do
        -- local userInfo = {
        --     uid = v.uid,
        --     chips = v.chips,
        --     nickName = v.nickName,
        --     portrait = v.portrait,
        -- }
        self:addUser( v.uid, v )
    end
end

function Config:addUser( uid, userInfo )
    if g_102.userInfos(uid) then
        for k, j in ipairs(g_102.allUser) do
            if j.uid == uid then
                for i,v in pairs(userInfo) do
                    g_102.allUser[k][i] = v
                end
                break
            end
        end
        return
    end
    table.insert(g_102.allUser, userInfo)
end

function Config:delUser(uid, seat_id )
    for i,v in ipairs(g_102.allUser) do
        if v.uid == uid then
            table.remove( g_102.allUser, i )
            break
        end
    end
end


function Config:onExit()
    g_102 = nil
    TpackageName = nil
end

return Config