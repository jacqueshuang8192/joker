local Config = class("Config")

function Config:ctor()
    TpackageName = "longhu100"
    g_101 = {}
    g_101.GameName = "百人龙虎"
    g_101.TOTAL_PLAYERNUM = 10
    g_101.level = 101
    g_101.cardPath = 1
    g_101.allCards = {}
    g_101.my_seat_id = 0 -- 
    g_101.allUser = {} -- 
    g_101.OwnerID = nil --房主id 
    g_101.banker_seat_id = nil --庄家id 
    g_101.m_isGameOver = false --游戏结束的话不让用户退出不显示 
    g_101.settlementData = nil--总结算数据
    g_101.gameConfig = {}--房间配置
    g_101.recordData = {}
    g_101.gameStatus = 0--游戏状态  --游戏状态  0 空闲，1:进行中
    g_101.xiaZhuData = {}

    g_101.gameConfigTable = {
        {
            ["游戏名"] = g_101.GameName, 
            ["倍率"] = 1
        }, 
        {["特殊玩法"] = ""}
    }

    g_101.userInfos = function(uid)
        for i,v in ipairs(g_101.allUser) do
            if uid == v.uid then
                return v
            end
        end
        return
    end
    g_101.getZhuangUsers = function(_type)
        local users = {}
        for i,v in ipairs(g_101.allUser) do
            if _type == v.isBanker then
                table.insert( users, v )
            end
        end
        return users
    end

    g_101.updateChips = function(uid, chips, isBanker)
        for k, j in ipairs(g_101.allUser) do
            if j.uid == uid then
                if chips then
                    g_101.allUser[k].chips = chips
                end
                if isBanker then
                    g_101.allUser[k].isBanker = isBanker
                end
                return j
            end
        end
    end
end

function Config:starGame()
    g_101.settlementData = nil--总结算数据
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
    if g_101.userInfos(uid) then
        for k, j in ipairs(g_101.allUser) do
            if j.uid == uid then
                for i,v in pairs(userInfo) do
                    g_101.allUser[k][i] = v
                end
                break
            end
        end
        return
    end
    table.insert(g_101.allUser, userInfo)
end

function Config:delUser(uid, seat_id )
    for i,v in ipairs(g_101.allUser) do
        if v.uid == uid then
            table.remove( g_101.allUser, i )
            break
        end
    end
end


function Config:onExit()
    g_101 = nil
    TpackageName = nil
end

return Config