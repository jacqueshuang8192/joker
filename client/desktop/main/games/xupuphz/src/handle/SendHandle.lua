require("framework.init")
local SendHandle = class("SendHandle")
local PROTOCOL =  require("xupuphz.src.handle.Protocol")

function SendHandle:LoginRoom(tid,seatId,activityId)

    local latitude = "0.00"
    local longitude = "0.00"
    local groupId = USER_INFO["family_id"]
    if type(USER_INFO["family_id"]) == "nil" then
        groupId = nil
    else
        groupId = tonumber(USER_INFO["family_id"])
    end
    CLUB_ID = groupId
    dump(groupId, "=========33333333333333333=======club_id")
   
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

    local activityId = activityId or USER_INFO["activity_id"]
    if seatId == nil then
        seatId = -1
    end
    dump(otherInfo,"otherInfo")
    local otherInfoTable = {
        ["city"] = USER_INFO["LocalCity"] or "", 
        ["club_id"] = groupId,
    }
    local otherInfo = json.encode(otherInfoTable)
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
        :setParameter("addres", USER_INFO.addres or "")
        :build()
    bm.server:send(pack)

    print(tid,seatId,latitude,longitude,otherInfo,activityId,"LoginRoom")
end

--坐下
function SendHandle:sitDown(seatId)
    dump("", "-----用户发送坐下协议-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :build()
    bm.server:send(pack)
    
end

--游戏准备
function SendHandle:CLI_READY_GAME(readyState)
    
    readyState = readyState or 1
    -- body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READY_GAME)
        :setParameter("readyState", readyState)
        :build()
    bm.server:send(pack)
end

--玩家pass（过牌）
function SendHandle:CLI_PASS()
    dump("向服务器发送过牌")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PASS)
                :build()
    bm.server:send(pack)
end

--玩家碰牌
function SendHandle:CLI_PLAYER_PENG_CARD()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_PENG_CARD)
        :build()
    bm.server:send(pack)
end

--玩家跑牌
function SendHandle:CLI_PLAYER_PAO_CARD()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_PAO_CARD)
        :build()
    bm.server:send(pack)
end

--玩家胡牌
function SendHandle:CLI_PLAYER_HU_CARD()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_HU_CARD)
        :build()
    bm.server:send(pack)
end

--玩家出牌
function SendHandle:CLI_PLAYER_OUT_CARD(Cardvalue)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_OUT_CARD)
        :setParameter("Cardvalue", Cardvalue)
        :build()
    bm.server:send(pack)
end

--玩家吃牌
function SendHandle:CLI_PLAYER_CHI_CARD(cardV1,cardV2,biCardValue,cards)
    if not cards then
        cards = {}
        biCardValue = 0
    elseif cards and #cards <= 0 then
        biCardValue = 0
    end
    if not biCardValue then
        biCardValue = 0
    end
    dump(cards, "玩家吃牌-------比牌")
    print(cardV1,cardV2,biCardValue)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_CHI_CARD)
        :setParameter("cardV1", cardV1)
        :setParameter("cardV2", cardV2)
        :setParameter("biCardValue", biCardValue)
        :setParameter("Cardcount", #cards)
        :setParameter("Cardbuf", cards)
        :build()
    bm.server:send(pack)
end

--玩家比牌
function SendHandle:CLI_PLAYER_BI_CARD(biCardValue,amount,cards)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_BI_CARD)
        :setParameter("biCardValue", biCardValue)
        :setParameter("Cardcount", amount)
        :setParameter("Cardbuf", cards)
        :build()
    bm.server:send(pack)
end

--退出房间
function SendHandle:quitRoom()

    dump("", "-----用户发送退出房间1033-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end
--------解散相关-----------
--请求解散房间
function SendHandle:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间
function SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

--请求总结算
-- function SendHandle:CLI_BROADCAST_GROUP_RESULT()
    -- local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_BROADCAST_GROUP_RESULT)
        -- :build()
    -- bm.server:send(pack)
-- end

--站起
function SendHandle:standUp()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
        :build()
    bm.server:send(pack)

end
--
function SendHandle:CLI_MSG_FACE(id, msgType, to_uid)
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


function SendHandle:CLI_CHECK_WEI(card)
    dump(card,"self.m_takeCard-card")
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHECK_WEI)
                       :setParameter("card", card)
                       :build()
    bm.server:send(sendpack)

end

function SendHandle:CLI_REQ_TEST_CARDS()
    dump("------ 请求开孔牌")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQ_TEST_CARDS)
    :build()
    bm.server:send(pack)
end

function SendHandle:CLI_PLAYER_GUCHOU()
    dump("------ guchou")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_GUCHOU)
    :build()
    bm.server:send(pack)
end

function SendHandle:CLI_TEST_CARD(card)
    dump(card, "------ 测试牌")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_TEST_CARD)
    :setParameter("card", card)
    :build()
    bm.server:send(pack)
end

function SendHandle:CLI_PIAO(value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PIAO)
    :setParameter("piaovalue", value)
    :build()
    bm.server:send(pack)
end

--0x1212   --玩家取消托管
function SendHandle:CLI_PLAYER_CANCELAUTO(value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_CANCELAUTO)
    :build()
    bm.server:send(pack)
end

return SendHandle