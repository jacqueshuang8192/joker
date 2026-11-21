
local PROTOCOL = import(HallProtocol_filePath)

local HallHandle = require(HallHandle_filePath)

local ServerBase = require(ServerBase_filePath)
local HallServer = class("HallServer", ServerBase)

local RELOGIN_TIMER

--初始化
function HallServer:ctor()
    g_hall_addresss = {}
    HallServer.super.ctor(self, "HallServer", PROTOCOL)
end

--建立Socket连接（连接大厅服务器）
function HallServer:connectSocket()

    local ip = hall_ip
    -- ip = "game." .. hall_ip

    dump(ip, hall_port, "-----建立Socket连接-----")

    if bm.server:isConnected() then
        bm.server:disconnect()
    end

    self:connect(ip, hall_port, 0)
    
end

--Socket连接成功
function HallServer:onAfterConnected()

    print("===== HallServer:onAfterConnected 被调用 =====")
    dump("", "-----Socket连接成功-----")
    
    if RELOGIN_TIMER then
        SCENENOW["scene"]:stopAllActions()
        RELOGIN_TIMER = nil
        local s = SCENENOW["scene"]:getChildByName("reconnect_tips")
        if s then
           s:removeSelf()
        end
    end

    --记录第一次连接Socket成功（就是开游戏第一次连接）
    if bm.SocketFirstConnectSuccess == false then
        require("hall.GameCommon"):setLoadingProgress(60)
        require("hall.GameCommon"):showLoadingTips("登录大厅")
        bm.SocketFirstConnectSuccess = true
    end

    local tbl = self:getProtocol() or {}
    local protocol_name = tbl.HALL_PROTOCOL_EX or ""
    dump(protocol_name, "-----protocol_name-----")
    dump(PROTOCOL.HALL_PROTOCOL_EX, "-----PROTOCOL.HALL_PROTOCOL_EX-----")

    -- if protocol_name ~= PROTOCOL.HALL_PROTOCOL_EX then

    --     dump("protocol_name不是HALL_PROTOCOL_EX", "-----Socket连接成功-----")

    --     bm.server.oldProtoacal = self:getGameProtocol()
    --     bm.server.oldHandle = self:getHandle()

    -- else

    --     dump("protocol_name是HALL_PROTOCOL_EX", "-----Socket连接成功-----")

    --     bm.server.oldProtoacal = self:getProtocol()
    --     bm.server.oldHandle = self:getHandle()

    -- end

    --记录游戏Protocol和Handle
    bm.server.oldProtoacal = self:getGameProtocol()
    bm.server.oldHandle = self:getGameHandle()

    --设置大厅Socket协议和对应处理方法
    print("===== 开始设置大厅Socket协议 =====")
    bm.server:setProtocol(PROTOCOL, true)
    print("===== 协议设置完成，开始设置Handle =====")
    
    local handle = HallHandle.new()
    print("===== HallHandle 创建成功 =====", handle)
    bm.server:setHandle(handle, true)
    print("===== HallHandle 设置完成 =====")
    
    print("===== 准备调用 LoginHall =====")
    self:LoginHall();

    if bm.netdisConnect then

        --require("hall.GameTips"):showTips("提示","",4,"重新连接成功")
        print("setUpdateStatus")
        --设置当前没在更新
        require("hall.GameUpdate"):setUpdateStatus(0)
        return

    end
    print("setLoadingProgress====")

    if SCENENOW["name"] == "hall.hallScene" then
        -- SCENENOW["scene"]:onConnected()
    else
        require("hall.HallUpdate"):landLoading(true)
        require("hall.HallUpdate"):queryVersion(2)
    end
end


--登录游戏大厅
function HallServer:LoginHall()

    print("===== HallServer:LoginHall 被调用 =====")
    dump("-----Socket登录大厅---116-----", "-----HallServer-----")
    dump(USER_INFO["user_info"], "-----HallServer-----")
    print("===== UID =====", UID)

    if type(USER_INFO["user_info"]) ~= "string" then
        USER_INFO["user_info"] =json.encode(USER_INFO["user_info"])
    end
    
    print("===== 准备发送登录大厅数据 =====")
    print("  uid:", UID)
    print("  storeId:", 1)
    print("  kind:", 1)
    print("  userInfo:", USER_INFO["user_info"])
    
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN)
        :setParameter("uid", UID)
        :setParameter("storeId", 1)
        :setParameter("kind", 1)
        :setParameter("userInfo", USER_INFO["user_info"])       
        :build()
    bm.server:send(pack)
    print("===== 登录大厅数据包已发送 =====")

end

----登录密码房 114
--function HallServer:loginEncryptGame(level, tid, activityId, baseChip, password)
--
--    level = level or 0
--
--    USER_INFO["tid"] = tid
--
--    baseChip = baseChip or 1
--
--    password = tostring(password)
--
--    require(NetworkLoadingView_filePath):showLoading("加入游戏中")
--
--    -- dump(PROTOCOL["CONFIG"]["CLIENT"][PROTOCOL.CLI_LOGIN_ENCRYPT_GAME],"loginGameNe_LI_LOGIN_ENCRYPT_GAME")  --
--    -- dump(password,"loginGameNew_password")
--
--    local aid = tonumber(activityId) or 0
--    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ENCRYPT_GAME)
--                    :setParameter("Level",  level)
--                    :setParameter("Chip", 10)
--                    :setParameter("Sid", 1)
--                    :setParameter("tid", tid)
--                    :setParameter("activity_id", aid)
--                    :setParameter("baseChip", baseChip)
--                    :setParameter("password", password)
--                    :build()
--    bm.server:send(pack)
--
--end

--新登录游戏 113
function HallServer:loginGameNew(level, tid, activityId, baseChip,isWatch,juli)

    level = level or 0
    tid = tid or 0

    USER_INFO["tid"] = tid

    baseChip = baseChip or 1 
    
    print(level, tid, activityId, baseChip, "loginGameNew")
    
    require(NetworkLoadingView_filePath):showLoading("加入游戏中")
    if isWatch == nil then
        isWatch = 1
    end
    if juli==nil then
        juli = 0
    end
    dump(isWatch,"===========isWatch")
    dump(juli,"===========juli")
    local aid = tonumber(activityId) or 0
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_GAME)
                    :setParameter("Level",  level)
                    :setParameter("Chip", 10)
                    :setParameter("Sid", 1)
                    :setParameter("tid", tid)
                    :setParameter("activity_id", aid)
                    :setParameter("baseChip", baseChip)
                    :setParameter("isWatch", isWatch)
                    :setParameter("juli", juli)
                    :setParameter("latitude", USER_INFO["Latitude"] or "0")
                    :setParameter("longitude", USER_INFO["Longitude"] or "0")
                    :build()
    bm.server:send(pack)
            --:setParameter("isWatch", USER_INFO["isWatch"] or 1)
end

--新登录游戏
function HallServer:loginAlloc(level)

    if  type(level) ~= "number" then
        local data = {type = 1, title = "提示", content = "游戏模式错误"} 
        require(CommonTips_filePath):showTips(data)
        return
    end

    dump(level, "loginAlloc")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_LOGIN_ALLOC)
        :setParameter("level",level)
        :build()
    bm.server:send(pack)

end


--退出ALLOC
function HallServer:logoutAlloc(level)

    dump("HallServer_logoutAlloc")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_LOGOUT_ALLOC)   --退出alloc
        :setParameter("level",level)
        :build()
    bm.server:send(pack)

end
--快速加入
function HallServer:CLIENT_CMD_JOIN_TABLE(level,club_id,configId)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_JOIN_TABLE)
                   :setParameter("level", level)
                   :setParameter("club_id",club_id)
                   :setParameter("configId",configId)
                   :build()
    bm.server:send(pack)

end


--网络断开
function HallServer:netClose()

    dump(bm.netdisConnect, "-----HallServer-----netClose-----")

    if bm.SocketFirstConnectSuccess then
        
    --     bm.netdisConnect = true

    --     dump(bm.netdisConnect, "-----HallServer-----netClose-----")

    --     -- if  SCENENOW["name"]=="hall.hallScene" or SCENENOW["name"]=="hall.gameScene" then
    --     --     --todo
    --     --     return;
    --     -- end
          
    -- --  and bm.isInGame == true and not RELOGIN_TIMER 
    --    if not SCENENOW["scene"]:getChildByName("loading") then
    --         --todo
    --         --self:connect()
    --         -- if self.socket_.isConnected then
    --         --      self.socket_:_onDisconnect()
    --         -- else
    --         --      self.socket_:_connectFailure()
    --         -- end
            
    --         -- cct.showLoadingTip()

    --     end

    else

        self:connectSocket()

    end
    
end

--发送组局信息
function HallServer:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
                    :setParameter("level", level)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

--发送大厅信息
function HallServer:SendHallMsg(uid,msg)

    dump(uid, "-----接收方uid-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_HALL_SEND_MSG_TO_SERVER)
                    :setParameter("uid", uid)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)
end


--发送广播消息
function HallServer:broadcastHallMsg(type,msg)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_BROADCAST_MSG)
                    :setParameter("type", type)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

--获取联盟信息
function HallServer:sendClubData(club_id, groupType, page, num, gameType, configId)
    if groupType == nil then
        groupType = 2
    end
    if page == nil then
        page = 0
    end
    if num == nil then
        num = 10
    end
    gameType = tonumber(gameType)
    configId = tonumber(configId)
    if gameType == nil or gameType == 0 then
        gameType = -1
    end
    if configId == nil then
        configId = -1
    end
    print(club_id, groupType, page, num, gameType, configId, "sendClubData11")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLUB_DATA)
                   :setParameter("club_id", club_id)
                   :setParameter("groupType", groupType)
                    :setParameter("page", page)
                    :setParameter("num", num)
                    :setParameter("gameType", gameType)
                    :setParameter("configId", configId)
                    :setParameter("nickName", USER_INFO["nick"])
                    :setParameter("portrait", USER_INFO["icon_url"])
                   :build()
    bm.server:send(pack)
end
--获取联盟信息
function HallServer:CLIENT_REMOVE_GROUP(tid)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_REMOVE_GROUP)
                   :setParameter("tid", tid)
                   :build()
    bm.server:send(pack)
    dump(tid, "-----发送-----")
end

--禁用某个玩家玩游戏
function HallServer:CLIENT_DISABLE_USER_GAME(club_id, ohetUid, status)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_DISABLE_USER_GAME)
                    :setParameter("club_id", tonumber(club_id))
                    :setParameter("ohetUid", tonumber(ohetUid))
                    :setParameter("status", tonumber(status))
                    :build()
    bm.server:send(pack)
    print(club_id,ohetUid,status, "-----禁用某个玩家玩游戏-----")
end


function HallServer:cliUserGameStatus()
    print("=========cliUserGameStatus===请求重连状态数据========")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_USER_GAME_STATUS):build()
    bm.server:send(pack)
end
function HallServer:CLIENT_COMMAND_USER_INFO()
    print("Latitude",USER_INFO["Latitude"])

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_INFO)
                   :setParameter("latitude",  USER_INFO["Latitude"] or "0")
                   :setParameter("longitude", USER_INFO["Longitude"] or "0")
                   :setParameter("ip", USER_INFO["ip"] or "0")
                   :build()
    bm.server:send(pack)
end



function HallServer:CLIENT_COMMAND_USER_ONLINE(club_id)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_ONLINE)
                   :setParameter("club_id",  club_id)
                   :build()
    bm.server:send(pack)
end

function HallServer:CLIENT_COMMAND_ONLINE(club_id,page,num)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_ONLINE)
                   :setParameter("club_id",  club_id)
                   :setParameter("page", page)
                   :setParameter("num", num)
                   :build()
    bm.server:send(pack)
end

function HallServer:SPEED_JOIN(clubid,gamelevel,id)
    dump(clubid,"-----clubid-----")
    dump(gamelevel,"-----gamelevel-----")
    dump(id,"-----id-----")
    
    require(NetworkLoadingView_filePath):showLoading("加入游戏中")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_JOIN_TABLE)
                   :setParameter("level",  gamelevel)
                   :setParameter("club_id",clubid)
                   :setParameter("configId", id)
                   :build()
    bm.server:send(pack)
end


function HallServer:CLINET_CMD_ENET_GAME(uid,club_id,tid,activityId,level,nickName,portrait,GameConfig)
       local pack = bm.server:createPacketBuilder(PROTOCOL.CLINET_CMD_ENET_GAME)
                   :setParameter("uid",  uid)
                   :setParameter("club_id", club_id)
                   :setParameter("tid", tid)
                   :setParameter("activityId", activityId)
                   :setParameter("level", level)
                   :setParameter("nickName", nickName)
                   :setParameter("portrait", portrait)
                   :setParameter("config", GameConfig)
                   :build()
    bm.server:send(pack)
end

return HallServer