require("framework.init")


local BiJiSendHandle = class("BiJiSendHandle")
local PROTOCOL        = import("biji.handle.BiJiProtocol")

function BiJiSendHandle:ctor()

end


--坐下
function BiJiSendHandle:CLI_SIT_DOWN(seatId)

    dump(seatId, "-----用户发送坐下房间1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
    :setParameter("seatId", seatId)
    :build()
    bm.server:send(pack)

end


--玩家开牌
function BiJiSendHandle:CLI_OPEN_CARD(cards_1, cards_2, cards_3)

    dump( cards_1, "-----玩家开牌2003-----")
    dump( cards_2, "-----玩家开牌2003-----")
    dump( cards_3, "-----玩家开牌2003-----")
    local cards1 = {}
    for i,v in pairs(cards_1) do
        local tmp_c = {}
        tmp_c['card'] =v.card --v.cardUint_
        table.insert(cards1,tmp_c)
    end
    local cards2 = {}
    for i,v in pairs(cards_2) do
        local tmp_c = {}
        tmp_c['card'] =v.card --v.cardUint_
        table.insert(cards2,tmp_c)
    end
    local cards3 = {}
    for i,v in pairs(cards_3) do
        local tmp_c = {}
        tmp_c['card'] =v.card --v.cardUint_
        table.insert(cards3,tmp_c)
    end

--    local cards3 = {}
--        local tmp_c = {}
--        tmp_c['card'] = 10--v.cardUint_
--        table.insert(cards3,tmp_c)
--        tmp_c = {}
--        tmp_c['card'] =9 --v.cardUint_
--        table.insert(cards3,tmp_c)
--        tmp_c = {}
--        tmp_c['card'] = 8 --v.cardUint_
--        table.insert(cards3,tmp_c)
--
--
--    local cards2 = {}
--    local tmp_c = {}
--    tmp_c['card'] =6 --v.cardUint_
--    table.insert(cards2,tmp_c)
--    tmp_c = {}
--    tmp_c['card'] =7 --v.cardUint_
--    table.insert(cards2,tmp_c)
--    tmp_c = {}
--    tmp_c['card'] = 5 --v.cardUint_
--    table.insert(cards2,tmp_c)
--
--
--
--    local cards1 = {}
--
--    local tmp_c = {}
--    tmp_c['card'] = 3 --v.cardUint_
--    table.insert(cards1,tmp_c)
--    tmp_c = {}
--    tmp_c['card'] = 4 --v.cardUint_
--    table.insert(cards1,tmp_c)
--    tmp_c = {}
--    tmp_c['card'] =2 --v.cardUint_
--    table.insert(cards1,tmp_c)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
    :setParameter("mount_1", #cards1)
    :setParameter("cards1", cards1)
    :setParameter("mount_2", #cards2)
    :setParameter("cards2", cards2)
    :setParameter("mount_3", #cards3)
    :setParameter("cards3", cards3)
--    :setParameter("mount_1", #cards_1)
--    :setParameter("cards_1", cards_1[1].card)
--    :setParameter("cards_2", cards_1[2].card)
--    :setParameter("cards_3", cards_1[3].card)
--    :setParameter("mount_2", #cards_2)
--    :setParameter("cards_4", cards_2[1].card)
--    :setParameter("cards_5", cards_2[2].card)
--    :setParameter("cards_6", cards_2[3].card)
--    :setParameter("mount_3", #cards_3)
--    :setParameter("cards_7", cards_3[1].card)
--    :setParameter("cards_8", cards_3[2].card)
--    :setParameter("cards_9", cards_3[3].card)
    :build()
    bm.server:send(pack)

end


--发送开始游戏
function BiJiSendHandle:BROADCAST_START_GAME()

    dump("-----开始游戏0x2107-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.BROADCAST_START_GAME)
    :build()
    bm.server:send(pack)

end

--站起
function BiJiSendHandle:CLI_STAND_UP()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
    :build()
    bm.server:send(pack)

end

--选牌
function BiJiSendHandle:CLI_CHOICE_CARD()

    -- dump(cardValue[1], "-----选牌1038-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHOICE_CARD)
    -- :setParameter("card1", cardValue[1])
    -- :setParameter("card2", cardValue[2])
    -- :setParameter("card3", cardValue[3])
    :build()
    bm.server:send(pack)

end

--退出房间
--function BiJiSendHandle:CLI_QUIT_ROOM()
--
--    dump("", "-----用户发送退出房间1033-----")
--
--    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
--        :build()
--    bm.server:send(pack)
--
--end

--进入房间
function BiJiSendHandle:enterRoom()
    local latitude = "0.00"
    local longitude = "0.00"

    local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = -1
    else
        groupId = tonumber(USER_INFO["family_id"])
    end
    dump(groupId, "club_id")
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

    local sex = USER_INFO["sex"] or 1
    local seatId = USER_INFO["seat_id"] or -1
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
    :setParameter("tid", USER_INFO["tid"])
    :setParameter("uid", USER_INFO["uid"])
    :setParameter("seat_id",seatId)
    :setParameter("sex",sex)
    :setParameter("nickName", USER_INFO["nick"])
    :setParameter("icon_url", USER_INFO["icon_url"])
    :setParameter("latitude", latitude)
    :setParameter("longitude", longitude)
    :setParameter("otherInfo",otherInfo)
    :setParameter("activity_id", tonumber(USER_INFO["activity_id"]))
    :build()
    bm.server:send(pack)


    --print("BiJiSendHandle:enterRoom", tostring(USER_INFO["GroupLevel"]))
    --local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
    --    :setParameter("level", USER_INFO["GroupLevel"])
    --    :setParameter("Chip", 1)
    --    :setParameter("Sid", 1)
    --    :setParameter("activity_id", USER_INFO["activity_id"])
    --    :build()
    --bm.server:send(pack)
end

--发送准备
function BiJiSendHandle:CLI_READYNOW_ROOM()
    dump("发送准备 2001")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
    :build()
    bm.server:send(pack)
end

--请求推出房间
function BiJiSendHandle:CLI_QUIT_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
    :build()
    bm.server:send(pack)

end

--请求比牌
function BiJiSendHandle:CLI_BI_CARD(seat)
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
function BiJiSendHandle:CLI_DIU_CARD()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_DIU_CARD)
    :build()
    bm.server:send(pack)
end

--跟注
function BiJiSendHandle:CLI_GEN_CARD()
    local zhu  = bm.Room.now_zhu

    if bm.User.isKan[USER_INFO["uid"]]  ~= nil then
        zhu = zhu * 2
    end

    print("CLI_GEN_CARD", tostring(zhu))

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GEN_CARD)
    :setParameter("gold", zhu)
    :build()
    bm.server:send(pack)
end

--看牌
function BiJiSendHandle:CLI_SEE_CARD()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEE_CARD)
    :build()
    bm.server:send(pack)
end

--加注
function BiJiSendHandle:CLI_JIA_CARD(gold)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_JIA_CARD)
    :setParameter("gold", gold)
    :build()
    bm.server:send(pack)
end

--火拼
function BiJiSendHandle:CLI_BET_ALLIN()
    print("CLI_BET_ALLIN", tostring(USER_INFO["uid"]))
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_BET_ALLIN)
    :build()
    bm.server:send(pack)
end
--
--function BiJiSendHandle:CLI_MSG_FACE(id)
--    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
--    :setParameter("type", id)
--    :build()
--    bm.server:send(sendpack)
--end


function BiJiSendHandle:C2S_DISSOLVE_ROOM()
    print("C2S_DISSOLVE_ROOM ----- 808-------------------------");
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.C2S_DISSOLVE_ROOM)
    :build()
    bm.server:send(sendpack)
end

--------解散相关-----------
--请求解散房间
function BiJiSendHandle:C2G_CMD_DISSOLVE_ROOM()
    dump("C2G_CMD_DISSOLVE_ROOM 解散")
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间
function BiJiSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end
--发送组局信息
function BiJiSendHandle:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
    :setParameter("level", level)
    :setParameter("msg", msg)
    :build()
    bm.server:send(pack)

end
function BiJiSendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)
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
-- 聊天相关
function BiJiSendHandle:CLI_MSG_FACE(id)
    local msg = {["uid"] = USER_INFO["uid"], ["msgType"] = "emoji", ["id"] = id}
    local json_msg = json.encode(msg)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
    :setParameter("level", USER_INFO["GroupLevel"])
    :setParameter("msg", json_msg)
    :build()
    bm.server:send(pack)
end


--获取剩余牌
function BiJiSendHandle:CLI_SEND_SELECT_CARDS(cardLst)
    
    local _cardLst = {}
    for i, v in ipairs(cardLst) do
        table.insert(_cardLst, {card = v})
    end
    
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_SELECT_CARDS)
    :setParameter("size", #cardLst)
    :setParameter("cards", _cardLst)
    :build()

    bm.server:send(pack)


end

return BiJiSendHandle