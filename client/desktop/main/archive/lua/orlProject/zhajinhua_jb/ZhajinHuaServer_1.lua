require("framework.init")


local ZhajinHuaServer = class("ZhajinHuaServer")
local PROTOCOL        = import("zhajinhua_jb.Zhajinhua_Protocol")

function ZhajinHuaServer:ctor()
	
end


--坐下
function ZhajinHuaServer:CLI_SIT_DOWN(seatId)

    dump(seatId, "-----用户发送坐下房间1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :build()
    bm.server:send(pack)

end

--发送开始游戏
function ZhajinHuaServer:BROADCAST_START_GAME()

    dump("-----开始游戏0x2107-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.BROADCAST_START_GAME)
        :build()
    bm.server:send(pack)

end

--站起
function ZhajinHuaServer:CLI_STAND_UP()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
        :build()
    bm.server:send(pack)

end

--选牌
function ZhajinHuaServer:CLI_CHOICE_CARD(cardValue)

    dump(cardValue, "-----选牌1038-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHOICE_CARD)
        :setParameter("card1", cardValue[1])
        :setParameter("card2", cardValue[2])
        :setParameter("card3", cardValue[3])
        :build()
    bm.server:send(pack)

end

--退出房间
--function ZhajinHuaServer:CLI_QUIT_ROOM()
--
--    dump("", "-----用户发送退出房间1033-----")
--
--    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
--        :build()
--    bm.server:send(pack)
--
--end

--进入房间
function ZhajinHuaServer:enterRoom()

    local latitude = "0.00"
    local longitude = "0.00"
    local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = nil
    else
        groupId = tonumber(USER_INFO["family_id"])
    end
    dump(groupId, "club_id")
    -- local otherInfoTable = {["city"] = USER_INFO["LocalCity"] or "", ["club_id"] = groupId}
    local otherInfoTable = {
        ["city"] = USER_INFO["LocalCity"] or "", 
        ["club_id"] = groupId,
        ["addres"] = USER_INFO.addres,
        ["ip"] = USER_INFO.ip,
    }
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
    print("latitude-lua",latitude)
    print("latitude-lua",longitude)
    dump(otherInfo,"otherInfo")
    local sex = USER_INFO["sex"] or 1
    local seatId = USER_INFO["seat_id"] or -1
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
    :setParameter("tid", USER_INFO["tid"])
    :setParameter("uid", USER_INFO["uid"])
    :setParameter("seat_id",seatId)
     :setParameter("sex",sex)
    :setParameter("nickName", USER_INFO["nick"])
    :setParameter("photoUrl", USER_INFO["icon_url"])
    :setParameter("latitude", latitude)
    :setParameter("longitude", longitude)
    :setParameter("otherInfo",otherInfo)
    :setParameter("activity_id", tonumber(USER_INFO["activity_id"]))
    :setParameter("ip", USER_INFO.ip)
    :setParameter("isWatch", USER_INFO.isWatch)
    :build()
    bm.server:send(pack)


    --print("ZhajinHuaServer:enterRoom", tostring(USER_INFO["GroupLevel"]))
    --local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
    --    :setParameter("level", USER_INFO["GroupLevel"])
    --    :setParameter("Chip", 1)
    --    :setParameter("Sid", 1)
    --    :setParameter("activity_id", USER_INFO["activity_id"])
    --    :build()
    --bm.server:send(pack)
end

--发送准备
function ZhajinHuaServer:CLI_READYNOW_ROOM()
    dump("发送准备 2001")
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :build()
    bm.server:send(pack)
end

--请求推出房间
function ZhajinHuaServer:CLI_QUIT_ROOM()
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end

--请求比牌
function ZhajinHuaServer:CLI_BI_CARD(seat)
    print("CLI_BI_CARD", tostring(seat))
    if seat == nil then
        dump(ZJH_USER_UID, "CLI_BI_CARD", nesting)
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_BI_CARD)
        :setParameter("seat", seat)
        :build()
    bm.server:send(pack)

end

--弃牌
function ZhajinHuaServer:CLI_DIU_CARD()
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_DIU_CARD)
        :build()
    bm.server:send(pack)
end

--跟注
function ZhajinHuaServer:CLI_GEN_CARD()
    local zhu  = bm.Room.now_zhu
    
    if bm.User.isKan[USER_INFO["uid"]]  ~= nil then
        zhu = zhu * 2
    end

    print("-------跟注CLI_GEN_CARD", tostring(zhu))

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GEN_CARD)
		:setParameter("gold", zhu)
        :build()
    bm.server:send(pack)
end

--看牌
function ZhajinHuaServer:CLI_SEE_CARD()
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEE_CARD)
        :build()
    bm.server:send(pack)
end

--加注
function ZhajinHuaServer:CLI_JIA_CARD(gold)
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_JIA_CARD)
		:setParameter("gold", gold)
        :build()
    bm.server:send(pack)
end

--火拼
function ZhajinHuaServer:CLI_BET_ALLIN(gold)
    print("CLI_BET_ALLIN", tostring(USER_INFO["uid"]))
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_BET_ALLIN)
        :setParameter("gold", gold)
        :build()
    bm.server:send(pack)
end

function ZhajinHuaServer:CLI_MSG_FACE(id, msgType, to_uid)
    if not msgType then
        msgType = "emoji"
    end
    local data = {
        msgType = msgType,
        type = id,
        uid = USER_INFO["uid"],
        to_uid = to_uid,
    }
    print("CLI_MSG_FACE ----------------- ", USER_INFO["GroupLevel"])
    dump(data, "CLI_MSG_FACE  = ")
    local msg = json.encode(data)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                   :setParameter("level", USER_INFO["GroupLevel"])
                   :setParameter("msg", msg)
                   :build()
    bm.server:send(pack)
    -- local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
    --                 :setParameter("type", id)
    --                 :build()
    -- bm.server:send(sendpack)
end


function ZhajinHuaServer:C2S_DISSOLVE_ROOM()
    print("C2S_DISSOLVE_ROOM ----- 808-------------------------");
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.C2S_DISSOLVE_ROOM)
                    :build()
    bm.server:send(sendpack)
end

--------解散相关-----------
--请求解散房间
function ZhajinHuaServer:C2G_CMD_DISSOLVE_ROOM()
    dump("C2G_CMD_DISSOLVE_ROOM 解散")
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间
function ZhajinHuaServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end
--发送组局信息
function ZhajinHuaServer:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
    :setParameter("level", level)
    :setParameter("msg", msg)
    :build()
    bm.server:send(pack)

end
function ZhajinHuaServer:CLIENT_CMD_FORWARD_MESSAGE(ip)
    dump(ip,"有发ip")
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

function ZhajinHuaServer:CLI_COMMAND_GAMERESULT_RECORD(resultIndex)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_COMMAND_GAMERESULT_RECORD)
    :setParameter("resultIndex", resultIndex)
    :build()
    bm.server:send(pack)
end

return ZhajinHuaServer