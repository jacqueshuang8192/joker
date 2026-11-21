
local PaiJiuSendHandle = class("PaiJiuSendHandle")
local PROTOCOL = import(TpackageName .. ".handle.PaiJiuProtocol")

function PaiJiuSendHandle:ctor()
    
end

--登陆游戏 113 服务器会返回210消息
function PaiJiuSendHandle:enterGroupRoom(Level, Chip, Sid, activity_id)

    dump(Level, "-----牌九发送113-----")
    dump(Chip, "-----牌九发送113-----")
    dump(Sid, "-----牌九发送113-----")
    dump(activity_id, "-----牌九发送113-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
    :setParameter("Level", Level)
    :setParameter("Chip", Chip)
    :setParameter("Sid", Sid)
    :setParameter("activity_id", activity_id)
    :build()
    bm.server:send(pack)
    
end

-- 113 服务器会返回210消息
function PaiJiuSendHandle:enterRoom(level)
    dump("-- 113 服务器会返回210消息")
    -- print("request PaiJiuSendHandle:enterRoom")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
    :setParameter("level", level)
    :setParameter("Chip", 0)
    :setParameter("Sid", 0)
    :setParameter("activity_id", "")
    :build()
    bm.server:send(pack)
end

--1001 登陆桌子
function PaiJiuSendHandle:LoginRoom(tid)

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

    -- if  type(seatId) ~= "number" then
    --     require("hall.GameTips"):showTips("提示", "", 1, "座位号错误，请重选")
    --     return
    -- end
--[[
    dump(USER_INFO["uid"], "uid")
    dump(seatId, "seat_id")
    dump(USER_INFO["nick"], "nickName")
    dump(USER_INFO["icon_url"], "portrait")
    dump(latitude, "latitude")
    dump(longitude, "longitude")
    dump(USER_INFO['activity_id'], "activity_id")
    dump(PROTOCOL.CONFIG.CLIENT[0x1001], "0x1001")
]]
    local city = USER_INFO["LocalCity"] or ""
    -- local otherInfoStr = {}
    -- otherInfoStr["city"] =  city
    dump(USER_INFO['activity_id'], "USER_INFO activity_id")
    dump(PAJIU_ACTIVITY_ID, "---- PAJIU_ACTIVITY_ID ---")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
    :setParameter("tid", tid)
    :setParameter("uid", USER_INFO["uid"])
    :setParameter("seatId", -1)
    :setParameter("sex", USER_INFO["sex"])
    :setParameter("nickName", USER_INFO["nick"])
    :setParameter("portrait", USER_INFO["icon_url"])
    :setParameter("latitude", latitude)
    :setParameter("longitude", longitude)
    -- :setParameter("otherInfoJson", json.encode(otherInfoStr))
    :setParameter("otherInfoJson",otherInfo)

    :setParameter("activityId", USER_INFO['activity_id'])
    :build()
    bm.server:send(pack)

    dump("发送1001", "-----牌九-----")

end

--请求录纸1035
function PaiJiuSendHandle:CLI_REQUEST_LUZHI()

    dump("", "-----请求录纸1035-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LUZHI)
    :build()
    bm.server:send(pack)
end

--外围请求下注1040
function PaiJiuSendHandle:CLI_REQUEST_BET(seat_id,betChip)

    dump(seat_id, "-----外围请求下注1036_seat_id-----")
    dump(betChip, "-----外围请求下注1036_bonusCount-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_BET)
    :setParameter("seat_id", seat_id)
    :setParameter("betChip", betChip)
    :build()
    bm.server:send(pack)
end

--请求查看下注情况1037
function PaiJiuSendHandle:CLI_REQUEST_CHECK_XIAZHU()

    dump("", "-----请求查看下注情况1037-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_CHECK_XIAZHU)
    :build()
    bm.server:send(pack)
end

--坐下
function PaiJiuSendHandle:sitDown(seatId)

    dump("", "-----用户发送坐下1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
    :setParameter("seatId", seatId)
    :build()
    bm.server:send(pack)

end

--站起
function PaiJiuSendHandle:standUp()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
    :build()
    bm.server:send(pack)

end


--退出房间
function PaiJiuSendHandle:quitRoom()

    dump("", "-----用户发送退出房间1033-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
    :build()
    bm.server:send(pack)

end

--请求托管
function PaiJiuSendHandle:requestAutoPlay(isOpenAuto,grab_times,bet_times)

    dump("", "-----用户发送请求托管1034-----")

    grab_times = grab_times or 1
    bet_times = bet_times or 1

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_AUTO_PLAY)
    :setParameter("isOpenAuto", isOpenAuto)
    :setParameter("grab_times", grab_times)
    :setParameter("bet_times", bet_times)
    :build()
    bm.server:send(pack)

end


--开始游戏
function PaiJiuSendHandle:StartGame()

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_START_GAME)
    :build()
    bm.server:send(pack)
    dump("---开始游戏--")

end

--请求获取服务器筹码
function PaiJiuSendHandle:getChips()

    dump("", "-----发送获取服务器筹码806-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", USER_INFO["uid"])
    :build()
    bm.server:send(pack)

end

--用户发送准备
function PaiJiuSendHandle:readyNow(readyState)

    dump(readyState, "-----用户发送准备2001-----")
    readyState = readyState or 1

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
    :setParameter("readyState", readyState)
    :build()
    bm.server:send(pack)

--[[    if GROUP_MODE == 2 then
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :setParameter("readyState", readyState)
        :build()
        bm.server:send(pack)
    else
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :build()
        bm.server:send(pack)
    end]]

end

--抢庄
function PaiJiuSendHandle:qiang(value)

    dump(value, "-----用户发送抢庄2007 抢庄-----")

    local value = tonumber(value)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QIANGZHUANG)
    :setParameter("if_qiang", value)
    :build()
    bm.server:send(pack)

end

--加倍倍数
function PaiJiuSendHandle:addBase(base)

    dump(base, "-----加倍倍数 2008-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_USER_BASES)
    :setParameter("bases", base)
    :build()
    bm.server:send(pack)

end

--发送牌数据
function PaiJiuSendHandle:sendMycards(card_1, card_2)

    dump("", "-----发送牌数据sendMycards 1102-----")
    dump(card_1, "1102---card_1")
    dump(card_2, "1102---card_2")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
    :setParameter("card_1", card_1)
    :setParameter("card_2",card_2)
    :build()
    bm.server:send(pack)

end


--发送牌数据
function PaiJiuSendHandle:sendMycards_no()

    dump("", "-----发送牌数据sendMycards_no 2003-----")

    local tmp = {}
    local ik = 1
    local kkk = {7,11,28}
    for i,v in pairs(bm.Room.Mychoice) do
        local tmp_c = {}
        tmp_c['card'] =kkk[ik] --v.cardUint_
        print("+++++++++++++chen++++++++++++++++++")
        print(v.cardUint_)
        table.insert(tmp,tmp_c)
        ik = ik +1
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
    :setParameter("mount", #tmp)
    :setParameter("cards",tmp)
    :build()
    bm.server:send(pack)

end

--解散相关
--请求解散房间
function PaiJiuSendHandle:C2G_CMD_DISSOLVE_ROOM()

    dump("", "-----请求解散房间 808-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)

end

--回复请求解散房间
function PaiJiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)

    dump(agree, "-----回复请求解散房间 809-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)

end

--聊天相关
function PaiJiuSendHandle:CLI_MSG_FACE(id, msgType, to_uid)
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

--发送组局信息
function PaiJiuSendHandle:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
    :setParameter("level", level)
    :setParameter("msg", msg)
    :build()
    bm.server:send(pack)

end

--发送距离等信息
function PaiJiuSendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)

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

--[[function PaiJiuSendHandle:SEND_BET_GRADE(value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.SEND_BET_GRADE)
    :setParameter("", )
    :setParameter("msg", msg)
    :build()
    bm.server:send(pack)
end]]

function PaiJiuSendHandle:CLI_USER_TIMES(value)
    dump(value, "--CLI_USER_TIMES--")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_USER_TIMES)
    :setParameter("times", value)
    :build()
    bm.server:send(pack)
end

function PaiJiuSendHandle:CLIENT_TEST_AVAIABLE_CARDS()
    dump("--- 0x1FFF ------")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_TEST_AVAIABLE_CARDS)
    :build()
    bm.server:send(pack)
end

function PaiJiuSendHandle:CLIENT_TEST_CARDS(tbl)
    dump(tbl, "--- 0x2000 ----")
    local count = #tbl
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    --写包头，包体长度先写0
    buf:writeInt(15)--包体长度
    buf:writeStringBytes("BY")-- 魔数
    buf:writeUShort(1)-- 版本号
    buf:writeInt(0x2000)                    -- 命令字
    buf:writeUShort(0)                            -- gameid
    buf:writeUShort(0)                            -- 业务id
    buf:writeByte(0)                              --平台ID
    buf:writeByte(0)                              --平台ID

    --修改包体长度
    buf:writeByte(count)
    for k, v in pairs(tbl) do
        buf:writeByte(v)
    end

    --修改包体长度
    buf:setPos(1)
    buf:writeInt(buf:getLen()-4)
    buf:setPos(buf:getLen() + 1)

    buf = require("src.socket.Encrypt"):EncryptBuffer(buf)
    bm.server:send(buf)
end

function PaiJiuSendHandle:CLI_COMMAND_GAMERESULT_RECORD(resultIndex)
    dump(resultIndex,"CLI_COMMAND_GAMERESULT_RECORD = resultIndex =")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_COMMAND_GAMERESULT_RECORD)
    :setParameter("resultIndex", resultIndex)
    :build()
    bm.server:send(pack)
end


return PaiJiuSendHandle