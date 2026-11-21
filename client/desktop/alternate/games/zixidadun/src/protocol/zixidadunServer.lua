local zixidadunServer = class("zixidadunServer")  
TpackageName = "zixidadun"
local PROTOCOL         = require(TpackageName .. ".src.protocol.zixidadunProtocol")


-- 7-22 
function zixidadunServer:LoginRoom(tid,seatId,activityId)
    local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = -1
    else
        groupId = tonumber(USER_INFO["family_id"])
    end

    local latitude = "0.00"
    local longitude = "0.00"

    local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = nil
    else
        groupId = tonumber(USER_INFO["family_id"])
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

    USER_INFO["latitude"] = latitude
    USER_INFO["longitude"] = longitude

    seatId  = seatId or -1

    local otherInfoTable = {
        ["city"] = USER_INFO["LocalCity"] or "",
        ["club_id"] = groupId,
        ["addres"] = USER_INFO.addres,
        ["ip"] = USER_INFO.ip,
    }

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
        :setParameter("ip", USER_INFO["ip"])
        :build()
    bm.server:send(pack)

    print(tid,seatId,latitude,longitude,otherInfo,activityId,"LoginRoom")
end

--坐下
function zixidadunServer:sitDown(seatId)

    dump("", "-----用户发送退出房间1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :build()
    bm.server:send(pack)

end

--站起
function zixidadunServer:standUp()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
        :build()
    bm.server:send(pack)

end

-- 7-22 
--退出房间
function zixidadunServer:quitRoom()

    dump("", "-----用户发送退出房间1033-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end

--请求筹码
function zixidadunServer:getChips()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", USER_INFO["uid"])
    :build()
    bm.server:send(pack)
end

-- 7-22
--游戏准备
function zixidadunServer:CLI_READY_GAME(readyState)
    
    readyState = readyState or 1
    -- body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READY_GAME)
        :setParameter("readyState", readyState)
        :build()
    bm.server:send(pack)
end


--请求配牌  2218
function zixidadunServer:CLI_PEI_PAI(cards,cardsCount)
    
    dump(cards,"出的牌")
    dump(cardsCount,"出的牌的数量")


    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PEI_PAI)
                :setParameter("cardCount", cardsCount)
                :setParameter("cardList", cards)
                :build()
    bm.server:send(pack)
end

-- 7-22
--出牌
function zixidadunServer:CLI_PLAYER_CARD(amount,cards,laiziCount,changeCard)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_CARD)
                    :setParameter("laizicount", laiziCount)
                    :setParameter("laizicards", changeCard)
                    :setParameter("Cardcount", amount)
                    :setParameter("Cardbuf", cards)
                    :build()
    bm.server:send(pack)
end
--亮盾
function zixidadunServer:CLI_PLAYER_LIANGDUN()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_LIANGDUN)
                    :build()
    bm.server:send(pack)
end
--吃饼
function zixidadunServer:CLI_PLAYER_CHIBING(isChibing)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_CHIBING)
    :setParameter("IsChiBing", isChibing)
                    :build()
    bm.server:send(pack)
end

--选牌
function zixidadunServer:CLI_PLAYER_SELECT_CARD(amount,cards)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_SELECT_CARD)
                    :setParameter("Cardcount", amount)
                    :setParameter("Cardbuf", cards)
                    :build()
    bm.server:send(pack)
end


--过牌
function zixidadunServer:CLI_PASS()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PASS)
                :build()
    bm.server:send(pack)
end

-- 7-22 
--聊天相关
function zixidadunServer:CLI_MSG_FACE(id, msgType, to_uid)
    if not msgType then
        msgType = "emoji"
    end
    local data = {
        msgType = msgType,
        type = id,
        uid = USER_INFO["uid"],
        to_uid = to_uid,
    }
    local msg = json.encode(data)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                   :setParameter("level", USER_INFO["GroupLevel"])
                   :setParameter("msg", msg)
                   :build()
    bm.server:send(pack)
end

--开直播
function zixidadunServer:CLI_SEND_LIVE_ADDRESS(addr,flag)

    print("send LIVE_ADDRESS ",USER_INFO["uid"],addr,flag);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LIVE_ADDRESS)
                    :setParameter("live_addr", addr)
                    :setParameter("flag", flag)
                    :build()
    bm.server:send(sendpack)
end

--------解散相关-----------
-- 7-22 
--请求解散房间
function zixidadunServer:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end
-- 7-22
--回复请求解散房间
function zixidadunServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

--申请
function zixidadunServer:CLI_SEND_APPLY_FOR_SPECIAL_PERMISSION()

    print("send Apply permission ", USER_INFO["uid"]);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_APPLY_FOR_SPECIAL_PERMISSION)
                    :setParameter("key", "fuck")
                    :build()
    bm.server:send(sendpack)
end

--取消申请
function zixidadunServer:CLI_SEND_CANCEL_FOR_SPECIAL_PERMISSION()

    print("send Cancel permission ", USER_INFO["uid"]);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_CANCEL_FOR_SPECIAL_PERMISSION)
                    :setParameter("key", "fuck")
                    :build()
    bm.server:send(sendpack)
end

--发送距离等信息
function zixidadunServer:CLIENT_CMD_FORWARD_MESSAGE(ip)

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
-- 7-22
--请求配牌
function zixidadunServer:CLIENT_SEND_MINGPAI_REMIND()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_SEND_MINGPAI_REMIND)
    :build()
    bm.server:send(pack)
end
-- 7-22
function zixidadunServer:CLIENT_COMMAND_AUTO(m_bAIUser)
    print("CLIENT_COMMAND_AUTO --------------", m_bAIUser)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_AUTO)
                    :setParameter("m_bAIUser", m_bAIUser)
                   :build()
    bm.server:send(pack)
end

-- 7-22
--切牌0x2016
function zixidadunServer:CLI_QIEPAI()
    dump("------切牌0x2016----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QIEPAI)
    :build()
    bm.server:send(pack)
end

--洗牌0x2017
function zixidadunServer:CLIENT_USER_SHUFFLE()
    dump("------切牌0x2017----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_USER_SHUFFLE)
    :build()
    bm.server:send(pack)
end

return zixidadunServer

