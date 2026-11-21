local ddzServer = class("ddzServer")  
local PROTOCOL = require("xinyu510k.ddz_PROTOCOL")

--登录
function ddzServer:LoginRoom(tid, seatId, activityId, groupId)
	print('LoginRoom',debug.traceback())
    local latitude = "0.00"
    local longitude = "0.00"
	
	 local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = nil
    else
        groupId = tonumber(USER_INFO["family_id"])
    end
    CLUB_ID = groupId
    
    if device.platform == "ios" then
        latitude = cct.getDataForApp("getLatitude", {}, "string")
        longitude = cct.getDataForApp("getLongitude", {}, "string")
    elseif device.platform == "android" then
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

		local ok
		local ret
        ok, ret = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            longitude = ret
        end

        ok, ret = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            latitude = ret
        end
    elseif device.platform == "windows" then
        latitude = "10.00"
        longitude = "10.00" 
    end

    USER_INFO["latitude"] = latitude
    USER_INFO["longitude"] = longitude

    seatId  = seatId or -1

    local otherInfoTable = {["city"] = USER_INFO["LocalCity"] or "" , ["club_id"] = groupId}
    local otherInfo = json.encode(otherInfoTable) 

    local activityId = activityId or USER_INFO["activity_id"]
    
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
        :setParameter("tid", tid)
        :setParameter("uid", USER_INFO["uid"])
        :setParameter("seat_id",seatId)
        :setParameter("sex",USER_INFO["sex"])
        :setParameter("nickName", USER_INFO["nick"])
        :setParameter("portrait", USER_INFO["icon_url"])
        :setParameter("latitude", latitude)
        :setParameter("longitude", longitude)
        :setParameter("otherInfo", otherInfo)
        :setParameter("activityId", activityId)
		:setParameter("ip", USER_INFO["ip"] or "")
		:setParameter("addres", USER_INFO["addres"] or "")
        :build()
    bm.server:send(pack)

    print(tid,seatId,latitude,longitude,otherInfo,activityId,groupId,"LoginRoom")
end

function ddzServer:CLI_MSG_FACE(id, msgType, to_uid)
    if not msgType then
        msgType = "emoji"
    end
    local data = {
        msgType = msgType,
        type = id,--两个一致是为了兼容旧的
        id = id,--两个一致是为了兼容旧的
        uid = USER_INFO["uid"],
        to_uid = to_uid,
    }
    
    local msg = json.encode(data)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                    :setParameter("level", USER_INFO["GroupLevel"])
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(sendpack)
end

--退出房间
function ddzServer:quitRoom()
	print('---用户发送退出房间0x1033-----')
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)
end

--游戏准备
function ddzServer:CLI_READY_GAME(readyState)
    readyState = readyState or 1
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READY_GAME)
        :setParameter("readyState", readyState)
        :build()
    bm.server:send(pack)
end

--出牌
function ddzServer:CLI_OUT_CARD(amount,cards)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_OUT_CARD)
        :setParameter("Cardcount", amount)
        :setParameter("Cardbuf", cards)
        :build()
    bm.server:send(pack)
end

--过牌
function ddzServer:CLI_PASS()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PASS)
        :build()
    bm.server:send(pack)
end

--叫边
function ddzServer:CLI_CALL_ASS(card)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CALL_ASS)
		:setParameter("card", card)
        :build()
    bm.server:send(pack)
end

--发送表情包
function ddzServer:Msg_face(id)
    local msg = json.encode({msgType = "emoji",type = id,uid = USER_INFO["uid"]})

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
		:setParameter("level", USER_INFO["GroupLevel"])
		:setParameter("msg", msg)
		:build()
    bm.server:send(pack)

end

--请求解散房间
function ddzServer:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
		:build()
    bm.server:send(pack)
end

--回复请求解散房间
function ddzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("------C2G_CMD_REPLY_DISSOLVE_ROOM--------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

return ddzServer

