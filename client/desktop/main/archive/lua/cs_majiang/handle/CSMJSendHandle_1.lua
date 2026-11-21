require("framework.init")


-- local ServerBase = import("socket.ServerBase")
local majiangServer = class("majiangServer")
local PROTOCOL         = import("cs_majiang.handle.CSMJProtocol")
function majiangServer:ctor()
    
end

function majiangServer:ctor()
    majiangServer.super.ctor(self, "majiangServer", PROTOCOL)
end

-- 0x1001
function majiangServer:LoginGame()
    local latitude = "0.00"
    local longitude = "0.00"

    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end

    if device.platform == "ios" then
        latitude = cct.getDataForApp("getLatitude", {}, "string")
        longitude = cct.getDataForApp("getLongitude", {}, "string")
    elseif device.platform == "android" then
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            longitude = ret
        end
        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            latitude = ret
        end
    elseif device.platform == "windows" then
        latitude = "10.00"
        longitude = "10.00" 
    end
    
    seatId  = -1
    local user_game_info = json.encode({["LocalCity"]=USER_INFO["LocalCity"] or "", ["club_id"] = groupId})
    local activityId = USER_INFO["activity_id"]
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_ACCOUNT_LOGIN)
        :setParameter("tid", USER_INFO["tid"])
        :setParameter("uid", USER_INFO["uid"])
        :setParameter("seat_id", -1)
        :setParameter("sex",USER_INFO["sex"])
        :setParameter("nickName", USER_INFO["nick"])
        :setParameter("portrait", USER_INFO["icon_url"])
        :setParameter("latitude", latitude)
        :setParameter("longitude", longitude)
        :setParameter("user_game_info", user_game_info)
        :setParameter("activityId", activityId)
        :build()
    bm.server:send(pack)
    dump(PROTOCOL.CONFIG.CLIENT[PROTOCOL.H2G_ACCOUNT_LOGIN],"pack222")

end

--请求解散房间 0x808
function majiangServer:H2G_DISSOLVE_ROOM()
    dump("请求解散房间","H2G_DISSOLVE_ROOM")
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间 0x809
function majiangServer:H2G_REPLY_DISSOLVE_ROOM(agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

--坐下0x1031
function majiangServer:H2G_ACCOUNT_SIT(seat_id)
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_ACCOUNT_SIT)
        :setParameter("seat_id", seat_id)
        :build()
    bm.server:send(pack)
end

--站起0x1032
function majiangServer:H2G_ACCOUNT_STAND()
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_ACCOUNT_STAND)
        :build()
    bm.server:send(pack)
end

--退出房间0x1033
function majiangServer:H2G_QUIT_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_QUIT_ROOM)
        :build()
    bm.server:send(pack)
end

--获取上局战绩 0x1114
function majiangServer:H2G_GET_LAST_RECORD()
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_GET_LAST_RECORD)
        :build()
    bm.server:send(pack)
end

--用户发送准备0x2001
function majiangServer:H2G_ACCOUNT_READY(readyState)
    dump(val, "-----用户发送准备2001-----")
    local readyState = readyState or 1
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_ACCOUNT_READY)
        :setParameter("readyState",readyState)
        :build()
    bm.server:send(pack)
end

--用户请求操作,这里是哪些碰，杆，胡的操作
function majiangServer:requestHandle(handle, value, use_bonus)
	if use_bonus == nil then use_bonus = 0 end
    --print("user caozuo peng gan hu caozuo ------------- @@@@@@@@@", use_bonus)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_HANDLE)
        :setParameter("handle", handle)
        :setParameter("card", value)    
        :setParameter("use_bonus", use_bonus)    
        :build()
    bm.server:send(pack)
end


--出牌
function majiangServer:sendCard(value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.SEND_CARD)
        :setParameter("card", value)
        :build()
    bm.server:send(pack)
end

--请求退出房间
function majiangServer:CLI_LOGOUT_ROOM()
    if bm.server == nil then
        return
    end
    -- body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGOUT_ROOM)
        :build()
    bm.server:send(pack)

    local btnEixt   = SCENENOW["scene"]:getChildByName("btn_exit")
    if btnEixt then
        btnEixt:setTouchEnabled(false)
    end
end
--请求退出比赛
function majiangServer:CLI_SEND_LOGOUT_MATCH(match_id)
    -- body
    if bm.server == nil then
        return
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LOGOUT_MATCH)
        :setParameter("MatchID", match_id)
        :setParameter("nUserId", USER_INFO["uid"])
        :build()
    bm.server:send(pack)
end

--用户发送准备0x2001
function majiangServer:H2G_ACCOUNT_READY(readyState)
    dump(val, "-----用户发送准备2001-----")
    local readyState = readyState or 1
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_ACCOUNT_READY)
        :setParameter("readyState",readyState)
        :build()
    bm.server:send(pack)
end

--过牌
function majiangServer:CLI_PASS()
    -- body
    if bm.server == nil then
        return
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PASS)
                :build()
    bm.server:send(pack)
end

--比赛报名
function majiangServer:CLI_SEND_JOIN_MATCH(level)

    if bm.server == nil then
        return
    end
    --print("jion_match:"..tostring(level))
    --print("taotaotaotao")
    require("hall.gameSettings"):setGameMode("match")
    -- body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_JOIN_MATCH)
        :setParameter("Level", level)
        :setParameter("flag", 1)
        :build(1)
    bm.server:send(pack)
end

--自动托管
function majiangServer:CLI_AUTO(action)
    -- body
    if bm.server == nil then
        return
    end
    local flag = action
    if flag < 0 then
        flag = 0
    elseif flag > 1 then
        flag = 1
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_AUTO)
                :setParameter("action", action)
                :build()
    bm.server:send(pack)
end

--围观进入房间
function majiangServer:CLI_LOGIN_ROOM_ONLOOK(tid,onLookId)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_ONLOOK)
                    :setParameter("tableid", tid)
                    :setParameter("nUserId", USER_INFO["uid"])
                    :setParameter("on_look_uid", onLookId)
                    :setParameter("strkey", json.encode("kadlelala"))
                    :setParameter("strinfo", USER_INFO["user_info"])
                    :setParameter("iflag", 1)
                    :setParameter("version", 1)
                    :build()
    bm.server:send(sendpack)

    --准备围观
    require("ddz.ddzSettings"):setLookState(1)
end

--退出围观
function majiangServer:CLI_REQUEST_LOOK_OUT(tid,onLookId)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LOOK_OUT)
                    :setParameter("tid", tid)
                    :setParameter("uid", USER_INFO["uid"])
                    :setParameter("onlook_uid", onLookId)
                    :build()
    bm.server:send(sendpack)
end

--请求记牌器历史
function majiangServer:CLI_REQUEST_CALC_HISTORY()
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_CALC_HISTORY)
                    :build()
    bm.server:send(sendpack)
end


--
function majiangServer:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
                    :setParameter("type", id)
                    :build()
    bm.server:send(sendpack)
end

--开直播
function majiangServer:CLI_SEND_LIVE_ADDRESS(addr,flag)

    --print("send LIVE_ADDRESS ",USER_INFO["uid"],addr,flag);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LIVE_ADDRESS)
                    :setParameter("live_addr", addr)
                    :setParameter("flag", flag)
                    :build()
    bm.server:send(sendpack)
end



-- 聊天相关
function majiangServer:CLI_MSG_FACE(id)
    local msg = {["uid"] = USER_INFO["uid"], ["msgType"] = "emoji", ["id"] = id}
    local json_msg = json.encode(msg)
    local pack = bm.server:createPacketBuilder(PROTOCOL.H2G_SEND_SPECIAL_FACE)
    :setParameter("level", USER_INFO["GroupLevel"])
    :setParameter("msg", json_msg)
    :build()
    bm.server:send(pack)
end

function majiangServer:CLIENT_CMD_FORWARD_MESSAGE(ip)

    local latitude = "0.00"
    local longitude = "0.00"
    local msg= {}
    
    if device.platform == "ios" then

        latitude = cct.getDataForApp("getLatitude", {}, "string")
        longitude = cct.getDataForApp("getLongitude", {}, "string")

    elseif device.platform == "android" then

        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            --print("luaj error:", ret)
        else
            longitude = ret
        end

        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            --print("luaj error:", ret)
        else
            latitude = ret
        end
    else   
           latitude = "10.00"
           longitude = "10.00"
    end
    
    local level = USER_INFO["GroupLevel"]
    msg["ip"] = ip
    msg["uid"] =  USER_INFO["uid"]
    msg["nickName"] =  USER_INFO["nick"]
    msg["latitude"] =  latitude
    msg["longitude"] = longitude
    msg["invote_code"] = USER_INFO["invote_code"]
    msg = json.encode(msg)

    -- showDumpData=true
    dump(level,"-----msg-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
    :setParameter("level", level)
    :setParameter("msg", msg)
    :build()
    -- dump(pack,"success pack")
    bm.server:send(pack)
end


function majiangServer:CLI_CHOSE_PIAO(value)
    dump("---------- 110B 选漂结果 ----------")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHOSE_PIAO)
    :setParameter("piaoNum", value)
    :build()
    bm.server:send(pack)
end
function majiangServer:CLI_ROBOT(value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_ROBOT)
                   :setParameter("kind", value)
                   :build()
    bm.server:send(pack)
end
return majiangServer
