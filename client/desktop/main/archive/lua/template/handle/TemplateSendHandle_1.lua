
local SanGongSendHandle = class("SanGongSendHandle")
local PROTOCOL = import(TpackageName .. ".handle.SanGongProtocol")

function SanGongSendHandle:ctor()
    
end




--1001 登陆桌子
function SanGongSendHandle:LoginRoom(tid,seatId,activityId)

    local latitude = "0.00"
    local longitude = "0.00"
    local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = -1
    else
        groupId = tonumber(USER_INFO["family_id"])
    end
    local otherInfoTable = {["city"] = USER_INFO["LocalCity"] or "", ["club_id"] = groupId}

    local otherInfo = json.encode(otherInfoTable)
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


    seatId  = seatId or -1

    local activityId = activityId or USER_INFO["activity_id"]

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
        :setParameter("tid", tid)
        :setParameter("uid", USER_INFO["uid"])
        :setParameter("sex",USER_INFO["sex"])
        :setParameter("nickName", USER_INFO["nick"])
        :setParameter("portrait", USER_INFO["icon_url"])
        :setParameter("latitude", latitude)
        :setParameter("longitude", longitude)
        :setParameter("otherInfo",otherInfo)
        :setParameter("activityId", activityId)
        :setParameter("city", "广州")
        :setParameter("ip", "127.0.0.1")
		:setParameter("isWatch", USER_INFO.isWatch)
        :build()
    bm.server:send(pack)


end


--请求带控
function SanGongSendHandle:CLIENT_CMD_REQ_TEST()
    dump("", "-----请求带控-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_REQ_TEST)
        :build()
    bm.server:send(pack)
end

--带控
function SanGongSendHandle:CLIENT_CMD_TEST(seat,rank)
    dump(rank, "-----带控-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_TEST)
        --:setParameter("seat", seat)
        :setParameter("rank", rank)
        :build()
    bm.server:send(pack)
end

--坐下
function SanGongSendHandle:sitDown(seatId)

    dump(seatId, "-----用户发送坐下1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seat", seatId)
        :build()
    bm.server:send(pack)

end

--站起
function SanGongSendHandle:standUp()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
        :build()
    bm.server:send(pack)

end


--退出房间
function SanGongSendHandle:quitRoom()

    dump("", "-----用户发送退出房间1033-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end


--开始游戏
function SanGongSendHandle:StartGame()

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_START_GAME)
        :build()
    bm.server:send(pack)
    dump("---开始游戏--")
    
end


--用户发送准备
function SanGongSendHandle:readyNow(readyState)

    dump(readyState, "-----用户发送准备2001-----")
    readyState = readyState or 1
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
            :setParameter("readyState",readyState)
            :build()
        bm.server:send(pack)
end

--解散相关
--请求解散房间
function SanGongSendHandle:C2G_CMD_DISSOLVE_ROOM()

    dump("", "-----请求解散房间 808-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)

end

--回复请求解散房间
function SanGongSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)

    dump(agree, "-----回复请求解散房间 809-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
    
end

--聊天相关
-- 聊天相关
function SanGongSendHandle:CLI_MSG_FACE(id)
    local msg = {["uid"] = USER_INFO["uid"], ["msgType"] = "emoji", ["id"] = id}
    local json_msg = json.encode(msg)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                   :setParameter("level", USER_INFO["GroupLevel"])
                   :setParameter("msg", json_msg)
                   :build()
    bm.server:send(pack)
end

--发送组局信息
function SanGongSendHandle:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
                    :setParameter("level", level)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

--发送距离等信息
function SanGongSendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)

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
    
    local level = USER_INFO["GroupLevel"]
    msg["ip"] = ip
    msg["uid"] =  USER_INFO["uid"]
    msg["nickName"] =  USER_INFO["nick"]
    msg["latitude"] =  latitude
    msg["longitude"] = longitude
    msg["invote_code"] = USER_INFO["invote_code"]
    msg = json.encode(msg)

    --dump(msg,"-----msg-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
    :setParameter("level", level)
    :setParameter("msg", msg)
    :build()
    --dump(pack,"success pack")
    bm.server:send(pack)
end

function SanGongSendHandle:CLIENT_CMD_YA(uid,zhu)

    dump(uid, "押注uid")
    dump(zhu, "-----押注多少-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_YA)
                   :setParameter("uid", uid)
                   :setParameter("zhu", zhu)
                   :build()
    bm.server:send(pack)
end
function SanGongSendHandle:CLIENT_CMD_REQ_YAZHU_DETAILS(seat)
    dump(seat,"CLIENT_CMD_REQ_YAZHU_DETAILS")
    local pack = bm.server:createPacketBuilder(PROTOCOL.SERVER_CMD_REQ_YAZHU_DETAILS)
                   :setParameter("seat", seat)
                   :build()
    bm.server:send(pack)
end
function SanGongSendHandle:CLIENT_CMD_GIVE_COINS(desUid, coins)
    dump(desUid,"CLIENT_CMD_GIVE_COINS")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_GIVE_COINS)
                   :setParameter("desUid", desUid)
                   :setParameter("coins", coins)
                   :build()
    bm.server:send(pack)
end
return SanGongSendHandle