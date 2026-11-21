
local CDSSendHandle = class("CDSSendHandle")
local PROTOCOL = import(TpackageName .. ".handle.CDSProtocol")

function CDSSendHandle:ctor()
    
end

--登陆游戏 113 服务器会返回210消息
function CDSSendHandle:enterGroupRoom(Level,Chip,Sid,activity_id)

    dump(Level, "-----牛牛发送113-----")
    dump(Chip, "-----牛牛发送113-----")
    dump(Sid, "-----牛牛发送113-----")
    dump(activity_id, "-----牛牛发送113-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
    :setParameter("level", Level)
    :setParameter("Chip", Chip)
    :setParameter("Sid", Sid)
    :setParameter("activity_id", activity_id)
    :build()
    bm.server:send(pack)

end

-- 113 服务器会返回210消息
function CDSSendHandle:enterRoom(level)

    -- print("request CDSSendHandle:enterRoom")
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter("level", level)
        :setParameter("Chip", 0)
        :setParameter("Sid", 0)
        :setParameter("activity_id", "")
        :build()
    bm.server:send(pack)
end

--1001 登陆桌子
function CDSSendHandle:LoginRoom(tid,seatId,activityId)

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

--请求录纸1035
function CDSSendHandle:CLI_REQUEST_LUZHI()

    dump("", "-----请求录纸1035-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LUZHI)
        :build()
    bm.server:send(pack)
end

--请求带控
function CDSSendHandle:CLIENT_CMD_REQ_TEST()
    dump("", "-----请求带控-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_REQ_TEST)
        :build()
    bm.server:send(pack)
end

--带控
function CDSSendHandle:CLIENT_CMD_TEST(seat,rank)
    dump(rank, "-----带控-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_TEST)
        --:setParameter("seat", seat)
        :setParameter("rank", rank)
        :build()
    bm.server:send(pack)
end

--外围请求下注1040
function CDSSendHandle:CLI_REQUEST_BET(seat,betChip)

    dump(seat, "-----外围请求下注1036_seat-----")
    dump(betChip, "-----外围请求下注1036_bonusCount-----")
    
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_BET)
        :setParameter("seat", seat)
        :setParameter("betChip", betChip)
        :build()
    bm.server:send(pack)
end

--请求查看下注情况1037
function CDSSendHandle:CLIENT_CMD_REQ_YAZHU_INFO()

    dump("", "-----请求查看下注情况1106-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_REQ_YAZHU_INFO)
        :build()
    bm.server:send(pack)
end

--坐下
function CDSSendHandle:sitDown(seatId)

    dump(seatId, "-----用户发送坐下1031-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seat", seatId)
        :build()
    bm.server:send(pack)

end

--站起
function CDSSendHandle:standUp()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
        :build()
    bm.server:send(pack)

end


--退出房间
function CDSSendHandle:quitRoom()

    dump("", "-----用户发送退出房间1033-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end

--请求托管
function CDSSendHandle:requestAutoPlay(isOpenAuto,grab_times,bet_times)

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
function CDSSendHandle:StartGame()

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_START_GAME)
        :build()
    bm.server:send(pack)
    dump("---开始游戏--")
    
end

--请求获取服务器筹码
function CDSSendHandle:getChips()

    dump("", "-----发送获取服务器筹码806-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", USER_INFO["uid"])
    :build()
    bm.server:send(pack)

end

--用户发送准备
function CDSSendHandle:readyNow(readyState)

    dump(readyState, "-----用户发送准备2001-----")
    readyState = readyState or 1
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
            :setParameter("readyState",readyState)
            :build()
        bm.server:send(pack)
    -- if GROUP_MODE == 2 then
    --     local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
    --         :setParameter("readyState",readyState)
    --         :build()
    --     bm.server:send(pack)
    -- else
    --     local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
    --         :build()
    --     bm.server:send(pack)
    -- end

end

--抢庄
function CDSSendHandle:qiang(value)

    dump("1", "-----用户发送抢庄2007 抢庄-----")
    
    local value = tonumber(value) or 1 

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QIANGZHUANG)
        :setParameter("if_qiang", value)
        :build()
    bm.server:send(pack)

end

--加倍倍数
function CDSSendHandle:addBase(base)

    dump(base, "-----加倍倍数 2008-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_USER_BASES)
        :setParameter("bases", base)
        :build()
    bm.server:send(pack)

end

--发送牌数据
function CDSSendHandle:sendMycards(cards)

    dump("", "-----点击出牌sendMycards 2003-----")

    local tmp = {}

    for i,v in ipairs(cards) do
        local tmp_c = {}
        tmp_c['card'] = 0
        table.insert(tmp,tmp_c)
    end

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_OUT_CARD)
        -- :setParameter("mount", #tmp)
        -- :setParameter("cards",tmp)
        :build()
    bm.server:send(pack)

end


--发送牌数据
function CDSSendHandle:sendMycards_no()

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
function CDSSendHandle:C2G_CMD_DISSOLVE_ROOM()

    dump("", "-----请求解散房间 808-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)

end

--回复请求解散房间
function CDSSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)

    dump(agree, "-----回复请求解散房间 809-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
    
end

--聊天相关
-- 聊天相关
function CDSSendHandle:CLI_MSG_FACE(id)
    local msg = {["uid"] = USER_INFO["uid"], ["msgType"] = "emoji", ["id"] = id}
    local json_msg = json.encode(msg)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                   :setParameter("level", USER_INFO["GroupLevel"])
                   :setParameter("msg", json_msg)
                   :build()
    bm.server:send(pack)
end

--发送组局信息
function CDSSendHandle:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
                    :setParameter("level", level)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

--发送距离等信息
function CDSSendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)

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

function CDSSendHandle:CLIENT_CMD_YA(zhu_num,zhu_type)

    dump(zhu_num, "-----押注多少-----")
    dump(zhu_type, "-----押注类型-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_YA)
                   :setParameter("zhu_num", zhu_num)
                   :setParameter("zhu_type", zhu_type)
                   :build()
    bm.server:send(pack)
end


function CDSSendHandle:CLIENT_CMD_REQ_YAZHU_DETAILS(seat)
    dump(seat,"CLIENT_CMD_REQ_YAZHU_DETAILS")
    local pack = bm.server:createPacketBuilder(PROTOCOL.SERVER_CMD_REQ_YAZHU_DETAILS)
                   :setParameter("seat", seat)
                   :build()
    bm.server:send(pack)
end
function CDSSendHandle:CLIENT_CMD_GIVE_COINS(desUid, coins)
    dump(desUid,"CLIENT_CMD_GIVE_COINS")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_GIVE_COINS)
                   :setParameter("desUid", desUid)
                   :setParameter("coins", coins)
                   :build()
    bm.server:send(pack)
end

return CDSSendHandle