local ddzServer = class("ddzServer")  
local PROTOCOL         = require("puchengdazha.ddz_PROTOCOL")

function ddzServer:LoginRoom(tid,seatId,activityId , groupId)

    local latitude = "0.00"
    local longitude = "0.00"
    
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
        :build()
    bm.server:send(pack)

    print(tid,seatId,latitude,longitude,otherInfo,activityId,"LoginRoom")
end

--坐下
function ddzServer:sitDown(seatId)

    dump("", "-----用户发送退出房间1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :build()
    bm.server:send(pack)

end

--站起
function ddzServer:standUp()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
        :build()
    bm.server:send(pack)

end

--退出房间
function ddzServer:quitRoom()

    dump("", "-----用户发送退出房间1033-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end

--请求筹码
function ddzServer:getChips()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", USER_INFO["uid"])
    :build()
    bm.server:send(pack)
end

--游戏准备
function ddzServer:CLI_READY_GAME(readyState)
    
    readyState = readyState or 1
    -- body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READY_GAME)
        :setParameter("readyState", readyState)
        :build()
    bm.server:send(pack)
end

--请求配牌  2218
function ddzServer:CLI_PEI_PAI(cards,cardsCount)
    
    dump(cards,"出的牌")
    dump(cardsCount,"出的牌的数量")


    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PEI_PAI)
                :setParameter("cardCount", cardsCount)
                :setParameter("cardList", cards)
                :build()
    bm.server:send(pack)
end

--出牌
function ddzServer:CLI_PLAYER_CARD(amount,cards)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_CARD)
                    :setParameter("Cardcount", amount)
                    :setParameter("Cardbuf", cards)
                    :build()
    bm.server:send(pack)
end

--过牌
function ddzServer:CLI_PASS()
    dump("向服务器发送过牌")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PASS)
                :build()
    bm.server:send(pack)
end

--过牌
function ddzServer:CLI_CHOOSETEAM(flag)
    dump("向服务器发送过牌")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHOOSETEAM)
                :setParameter("flag", flag)
                :build()
    bm.server:send(pack)
end

--自动托管
function ddzServer:CLI_AUTO(action)
    -- local flag = action
    -- if flag < 0 then
    --     flag = 0
    -- elseif flag > 1 then
    --     flag = 1
    -- end
    -- local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_AUTO)
    --             :setParameter("action", action)
    --             :build()
    -- bm.server:send(pack)
end

--请求记牌器历史
function ddzServer:CLI_REQUEST_CALC_HISTORY()
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_CALC_HISTORY)
                    :build()
    bm.server:send(sendpack)
end
--
function ddzServer:CLI_MSG_FACE(id)

    -- local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
    --                 :setParameter("type", id)
    --                 :build()
    -- bm.server:send(sendpack)
    
    local msg = json.encode({msgType = "emoji",type = id,uid = USER_INFO["uid"]})

    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                    :setParameter("level", USER_INFO["GroupLevel"])
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(sendpack)

end
--------解散相关-----------
--请求解散房间
function ddzServer:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间
function ddzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

--申请
function ddzServer:CLI_SEND_APPLY_FOR_SPECIAL_PERMISSION()

    print("send Apply permission ", USER_INFO["uid"]);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_APPLY_FOR_SPECIAL_PERMISSION)
                    :setParameter("key", "fuck")
                    :build()
    bm.server:send(sendpack)
end

--取消申请
function ddzServer:CLI_SEND_CANCEL_FOR_SPECIAL_PERMISSION()

    print("send Cancel permission ", USER_INFO["uid"]);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_CANCEL_FOR_SPECIAL_PERMISSION)
                    :setParameter("key", "fuck")
                    :build()
    bm.server:send(sendpack)
end

--发送距离等信息
function ddzServer:CLIENT_CMD_FORWARD_MESSAGE(ip)

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

return ddzServer

