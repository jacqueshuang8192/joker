local NinetySixSendHandle = class("NinetySixSendHandle")
local PROTOCOL = import("96game.src.handle.NinetySixProtocol")

function NinetySixSendHandle:ctor()
    self.ctrl = nil
    self.logic = nil
    self.scene = nil
end

function NinetySixSendHandle:setCtrl(ctrl, logic, scene)
    self.ctrl = ctrl
    self.logic = logic
    self.scene = scene
end

--1001 登陆桌子
function NinetySixSendHandle:LoginRoom(tid, seatId, activityId)
    local latitude = "0.00"
    local longitude = "0.00"
    local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = -1
    else
        groupId = tonumber(USER_INFO["family_id"])
    end
    local otherInfoTable = {
        ["city"] = USER_INFO["LocalCity"] or "",
        ["club_id"] = groupId,
        ["addres"] = USER_INFO.addres,
        ["ip"] = USER_INFO.ip
    }

    if device.platform == "ios" then
        latitude = cct.getDataForApp("getLatitude", {}, "string")
        longitude = cct.getDataForApp("getLongitude", {}, "string")
    elseif device.platform == "android" then
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        local ok, ret = luaj.callStaticMethod(className, "getLongitude", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            longitude = ret
        end

        ok, ret = luaj.callStaticMethod(className, "getLatitude", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            latitude = ret
        end
    elseif device.platform == "windows" then
        latitude = "10.00"
        longitude = "10.00"
    end
    otherInfoTable["latitude"] = latitude or "0.0.0.0"
    otherInfoTable["longitude"] = longitude or "0.0.0.0"
    USER_INFO.latitude = latitude or "0"
    USER_INFO.longitude = longitude or "0"
    local otherInfo = json.encode(otherInfoTable)
    seatId = seatId or -1

    local activity_Id = activityId or USER_INFO["activity_id"]
    local pack = bm.server:createPacketBuilder(PROTOCOL.C_LOGIN_ROOM)
        :setParameter("tid", tid)
        :setParameter("uid", USER_INFO["uid"])
        :setParameter("seatId", seatId)
        :setParameter("sex", USER_INFO["sex"])
        :setParameter("nickName", USER_INFO["nick"])
        :setParameter("portrait", USER_INFO["icon_url"])
        :setParameter("latitude", latitude)
        :setParameter("longitude", longitude)
        :setParameter("otherInfo", otherInfo)
        :setParameter("activityId", activity_Id)
        :setParameter("ip", USER_INFO["ip"] or "")
        :build()
    bm.server:send(pack)

    print(tid, seatId, latitude, longitude, otherInfo, activity_Id, groupId, "LoginRoom")
end

--退出房间
function NinetySixSendHandle:quitRoom()
    self.ctrl.receive.totalSettlePack = nil
    local pack = bm.server:createPacketBuilder(PROTOCOL.C_COMMAND_QUIT):build()
    bm.server:send(pack)
end

--用户发送准备
function NinetySixSendHandle:sendReady(ready)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C_PLAYER_READY)
    :setParameter("ready", ready)
    :build()
    bm.server:send(pack)
end

--出牌
function NinetySixSendHandle:outCard(cardId)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_OUT_CARD)
    :setParameter("cardId", cardId)
    :build()
    bm.server:send(pack)
end

--过牌
function NinetySixSendHandle:userPass()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_PASS):build()
    bm.server:send(pack)
end

--吃牌
function NinetySixSendHandle:chiCard(card_type, cardId1, cardId2, cardId3)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_CHI_CARD)
        :setParameter("card_type", card_type)
        :setParameter("cardId1", cardId1)
        :setParameter("cardId2", cardId2)
        :setParameter("cardId3", cardId3)
        :build()
    bm.server:send(pack)
end

--胡牌
function NinetySixSendHandle:huCard()
    print("userhu---------------------------------------")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_HU_CARD)
                   :build()
    bm.server:send(pack)
end
--贴牌
function NinetySixSendHandle:tieCard(cardId1, cardId2)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_TIE_CARD)
        :setParameter("cardId1", cardId1)
        :setParameter("cardId2", cardId2)
        :build()
    bm.server:send(pack)
end

--坐下
function NinetySixSendHandle:sitDown(seatId)
    dump(seatId, "-----用户发送坐下1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :build()
    bm.server:send(pack)
end

--站起
function NinetySixSendHandle:standUp()
    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP):build()
    bm.server:send(pack)
end

--开始游戏
function NinetySixSendHandle:startGame()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_START_GAME):build()
    bm.server:send(pack)
    dump("---开始游戏--")
end

--解散相关
--请求解散房间
function NinetySixSendHandle:C2G_CMD_DISSOLVE_ROOM()
    dump("", "-----请求解散房间 808-----")
    self.ctrl.receive.totalSettlePack = nil
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM):build()
    bm.server:send(pack)
end

--回复请求解散房间
function NinetySixSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    dump(agree, "-----回复请求解散房间 809-----")
    --self.ctrl.receive.totalSettlePack = nil

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
        :setParameter("agree", agree):build()
    bm.server:send(pack)
end

--聊天相关
function NinetySixSendHandle:CLI_MSG_FACE(id)
    local msg = {["uid"] = USER_INFO["uid"], ["msgType"] = "emoji", ["id"] = id}
    local json_msg = json.encode(msg)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
        :setParameter("level", USER_INFO["GroupLevel"])
        :setParameter("msg", json_msg)
        :build()
    bm.server:send(pack)
end

--发送距离等信息
function NinetySixSendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)
    local latitude = "0.00"
    local longitude = "0.00"
    local msg = {}

    if device.platform == "ios" then
        latitude = cct.getDataForApp("getLatitude", {}, "string")
        longitude = cct.getDataForApp("getLongitude", {}, "string")
    elseif device.platform == "android" then
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        local ok, ret = luaj.callStaticMethod(className, "getLongitude", args, sigs)
        if not ok then
            print("luaj error:", ret)
        else
            longitude = ret
        end

        ok, ret = luaj.callStaticMethod(className, "getLatitude", args, sigs)
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
    msg["uid"] = USER_INFO["uid"]
    msg["nickName"] = USER_INFO["nick"]
    msg["latitude"] = latitude
    msg["longitude"] = longitude
    msg["invote_code"] = self.logic.inviteCode
    msg = json.encode(msg)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
        :setParameter("level", level)
        :setParameter("msg", msg)
        :build()
    bm.server:send(pack)
end
function NinetySixSendHandle:CLIENT_COMMAND_USER_PIAO(piaoFeng)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_PIAO)
                   :setParameter("piaoFeng", piaoFeng)
                   :build()
    bm.server:send(pack)
end
--选牌
function NinetySixSendHandle:CLIENT_COMMAND_GET_CARD()

    -- dump(cardValue[1], "-----选牌1038-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_GET_CARD)
    -- :setParameter("card1", cardValue[1])
    -- :setParameter("card2", cardValue[2])
    -- :setParameter("card3", cardValue[3])
                   :build()
    bm.server:send(pack)

end
function NinetySixSendHandle:CLIENT_COMMAND_USER_CARD(card)
    print("card",card)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_USER_CARD)
     :setParameter("card", card)
                   :build()
    bm.server:send(pack)
end

function NinetySixSendHandle:CLI_ROBOT(value)
local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_ROBOT)
                   :setParameter("m_bAI", value)
                   :build()
    bm.server:send(pack)
end
return NinetySixSendHandle
