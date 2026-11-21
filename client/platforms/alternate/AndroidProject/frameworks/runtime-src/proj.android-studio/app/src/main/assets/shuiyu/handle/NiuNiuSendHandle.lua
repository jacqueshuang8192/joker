
local NiuNiuSendHandle = class("NiuNiuSendHandle")
local PROTOCOL = import(TpackageName .. ".handle.NiuNiuProtocol")

--登陆游戏 113 服务器会返回210消息
function NiuNiuSendHandle:enterGroupRoom(Level,Chip,Sid,activity_id)

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
function NiuNiuSendHandle:enterRoom(level)

    -- print("request NiuNiuSendHandle:enterRoom")
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter("level", level)
        :setParameter("Chip", 0)
        :setParameter("Sid", 0)
        :setParameter("activity_id", "")
        :build()
    bm.server:send(pack)
end

--1001 登陆桌子
function NiuNiuSendHandle:LoginRoom(tid,seatId,activityId,groupId)

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

    if  GROUP_MODE == 2 then

        dump(seatId,"LoginRoomseatId")
        dump(tid,"LoginRoomseatId")
        -- if  type(seatId) ~= "number" then
        --     require("hall.GameTips"):showTips("提示", "", 1, "座位号错误，请重选") 
        --     return
        -- end        
        seatId  = seatId or -1

        local otherInfoTable = {["city"] = USER_INFO["LocalCity"] or "", ["club_id"] = groupId}
        local otherInfo = json.encode(otherInfoTable) 

        local activityId = activityId or USER_INFO["activity_id"]
        
        print("--seatId--",seatId)
        print("--uid--",USER_INFO["uid"])

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

    else

        local info = json.decode(USER_INFO["user_info"])
              info.nickName = USER_INFO["nick"]
              USER_INFO["user_info"] = json.encode(info)

        print("--seatId--",seatId)
        print("--uid--",USER_INFO["uid"])

        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
            :setParameter("tid", tid)
            :setParameter("uid", USER_INFO["uid"])
            :setParameter("mtkey", "")
            :setParameter("strinfo", USER_INFO["user_info"])
            :build()
        bm.server:send(pack)

        dump(PROTOCOL.CLI_LOGIN_ROOM, "-----牛牛1001-----")
        dump(tid, "-----牛牛1001-----")
        dump(USER_INFO["user_info"], "-----牛牛1001-----")

    end

    dump("发送1001", "-----牛牛-----")

end

--请求录纸1035
function NiuNiuSendHandle:CLI_REQUEST_LUZHI()

    dump("", "-----请求录纸1035-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LUZHI)
        :build()
    bm.server:send(pack)
end

--外围请求下注1040
function NiuNiuSendHandle:CLI_REQUEST_BET(seat_id, betChip)

    dump(seat_id, "-----外围请求下注1036_seat_id-----")
    dump(betChip, "-----外围请求下注1036_bonusCount-----")
    
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_BET)
        :setParameter("seat_id", seat_id)
        :setParameter("betChip", betChip)
        :build()
    bm.server:send(pack)
end


--请求押注情况1106
function NiuNiuSendHandle:CLI_CMD_REQ_YAZHU_INFO(seatId)

    dump(seatId, "-----请求押注情况1106 seat_id-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CMD_REQ_YAZHU_INFO)
        :setParameter("seatId", seatId)
        :build()
    bm.server:send(pack)
end

--请求押注详情1107
function NiuNiuSendHandle:CLI_CMD_REQ_YAZHU_DETAILS(seatId)

    dump(seatId, "-----请求押注详情1107 seat_id-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CMD_REQ_YAZHU_DETAILS)
        :setParameter("seatId", seatId)
        :build()
    bm.server:send(pack)
end

--外围请求查看外围结果110B
function NiuNiuSendHandle:CLI_COMMAND_REQ_WAIWEI_RESULT()

    dump("-----外围请求查看外围结果110B -----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_COMMAND_REQ_WAIWEI_RESULT)
        :build()
    bm.server:send(pack)
end


--外围请求坐庄110A
function NiuNiuSendHandle:CLI_REQUEST_GRAB_BANKER(seat_id)

    dump(seat_id, "-----外围请求坐庄110A seat_id-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_COMMAND_GRAB_WW_DEALER)
        :build()
    bm.server:send(pack)
end


--请求查看下注情况1037
function NiuNiuSendHandle:CLI_REQUEST_CHECK_XIAZHU()

    dump("", "-----请求查看下注情况1037-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_CHECK_XIAZHU)
        :build()
    bm.server:send(pack)
end

--坐下
function NiuNiuSendHandle:sitDown(seatId)

    dump("", "-----用户发送退出房间1031-----")

    print (seatId , "----坐下的座位Id---")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :build()
    dump (pack , "---协议包--")
    dump (PROTOCOL , "---协议包23333--")
    bm.server:send(pack)

end

--坐下
function NiuNiuSendHandle:sitDown_NEW(seatId)

    dump("", "-----用户发送换位置8001-----")

    print (seatId , "----坐下的座位Id---")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN_NEW)
        :setParameter("seat_id", seatId)
        :build()
    -- dump (pack , "---协议包--")
    -- dump (PROTOCOL , "---协议包23333--")
    bm.server:send(pack)

end

--坐下
function NiuNiuSendHandle:ReplaceDown_NEW(seatId)

    dump("", "-----用户发送换位置8006-----")

    print (seatId , "----坐下的座位Id---")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN_NEW_REPLACE_SEATID)
        :setParameter("seat_id", seatId)
        :build()
    -- dump (pack , "---协议包--")
    -- dump (PROTOCOL , "---协议包23333--")
    bm.server:send(pack)

end

--站起
function NiuNiuSendHandle:standUp()

    dump("", "-----用户发送退出房间1032-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_STAND_UP)
        :build()
    bm.server:send(pack)

end

--退出房间
function NiuNiuSendHandle:quitRoom()
    dump("", "-----用户发送退出房间1033-----")
    dump("", "-----用户发送退出房间1033-----")
    dump("", "-----用户发送退出房间1033-----")
    dump("", "-----用户发送退出房间1033-----")
    dump("", "-----用户发送退出房间1033-----")
    print("====GAME_STATE====",GAME_STATE)
    print("====GAME_ROUND====",GAME_ROUND)
    if GAME_ROUND < 1 and (GAME_STATE == 9 or GAME_STATE == 7 or GAME_STATE == 0 )   then
        print("玩家请求退出房间")
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
            :build()
        bm.server:send(pack)
    else
        require("hall.GameTips"):showTips("提示", "", 3, "游戏进行中...") 
    end
   

end

--坐下
function NiuNiuSendHandle:senTestCard(_cards)

    dump(_cards, "-----用户发送testcard-----")

    local cards = nil
    if type(_cards) == "number" then
        cards = {}
        table.insert(cards,_cards)
    elseif type(_cards) == "table" then
        cards = _cards
    end

    local mount = #cards
    

    local tmp = {}

    for i,v in ipairs(cards) do
        local tmp_c = {}
        tmp_c['card'] = v
        table.insert(tmp,tmp_c)
    end

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_TEST_CARD)
        :setParameter("mount", mount)
        :setParameter("cards", tmp)
        :build()
    bm.server:send(pack)

end

--请求托管
function NiuNiuSendHandle:requestAutoPlay(isOpenAuto,grab_times,bet_times)

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
function NiuNiuSendHandle:StartGame()

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_START_GAME)
        :build()
    bm.server:send(pack)
    dump("---开始游戏--")
    
end

--请求获取服务器筹码
function NiuNiuSendHandle:getChips()
    -- GamePlaneOperator:clearGameDatas(1)
    dump("", "-----发送获取服务器筹码806-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", USER_INFO["uid"])
    :build()
    bm.server:send(pack)

end

--用户发送准备
function NiuNiuSendHandle:readyNow(readyState)

    dump(val, "-----用户发送准备2001-----")
    readyState = readyState or 1
    
    if GROUP_MODE == 2 then
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
            :setParameter("readyState",readyState)
            :build()
        bm.server:send(pack)
    else
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
            :build()
        bm.server:send(pack)
    end

end

--抢庄
function NiuNiuSendHandle:qiang(value)

    dump("1", "-----用户发送抢庄2007 抢庄-----")
    
    local value = tonumber(value) or 1 

    print (value , "----用戶发送的抢庄倍数---")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QIANGZHUANG)
        :setParameter("if_qiang", value)
        :build()
    bm.server:send(pack)

end

--加倍倍数
function NiuNiuSendHandle:addBase(base)

    dump(base, "-----加倍倍数 2008-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_USER_BASES)
        :setParameter("bases", base)
        :build()
    bm.server:send(pack)

end

--发送牌数据
function NiuNiuSendHandle:sendMycards(rand_card)

    -- print (rand_card , "---随机发送的牌值---")
    -- local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
    --     :setParameter("card", rand_card)
    --     :build()
    -- bm.server:send(pack)

end


--发送牌数据
function NiuNiuSendHandle:sendMycards_no()

    -- dump("", "-----发送牌数据sendMycards_no 2003-----")

    -- local tmp = {}
    -- local ik = 1
    -- local kkk = {7,11,28} 
    -- for i,v in pairs(bm.Room.Mychoice) do
    --     local tmp_c = {}
    --     tmp_c['card'] =kkk[ik] --v.cardUint_
    --     print("+++++++++++++chen++++++++++++++++++")
    --     print(v.cardUint_)
    --     table.insert(tmp,tmp_c)
    --     ik = ik +1
    -- end
    -- local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
    --     :setParameter("mount", #tmp)
    --     :setParameter("cards",tmp)
    --     :build()
    -- bm.server:send(pack)

end

--解散相关
--请求解散房间
function NiuNiuSendHandle:C2G_CMD_DISSOLVE_ROOM()

    dump("", "-----请求解散房间 808-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)

end

--回复请求解散房间
function NiuNiuSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)

    dump(agree, "-----回复请求解散房间 809-----")
    dump( "-----回复请求解散房间 809-----")
    dump( "-----回复请求解散房间 809-----")
    dump( "-----回复请求解散房间 809-----")
    dump( "-----回复请求解散房间 809-----")
    dump( "-----回复请求解散房间 809-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
    
end

--聊天相关
function NiuNiuSendHandle:CLI_MSG_FACE(id)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
    :setParameter("type", id)
    :build()
    bm.server:send(pack)
end

--发送组局信息
function NiuNiuSendHandle:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
                    :setParameter("level", level)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

--发送距离等信息
function NiuNiuSendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)

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
    msg["uid"] =  USER_INFO["uid"]
    msg["nickName"] =  USER_INFO["nick"]
    msg["latitude"] =  latitude
    msg["longitude"] = longitude
    msg["city"] = USER_INFO["LocalCity"] or ""
    msg["invote_code"] = USER_INFO["invote_code"]
    msg = json.encode(msg)

    --dump(msg,"-----msg-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
    :setParameter("level", level)
    :setParameter("msg", msg)
    :build()
    bm.server:send(pack)

    dump(msg,"successsendmyonfo")

end

--发送配牌信息
function NiuNiuSendHandle:CLIENT_SHOW_CARD(cardValue)

    dump(cardValue[1], "-----选牌1038-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHOICE_CARD)
        :setParameter("card1", cardValue[1])
        :setParameter("card2", cardValue[2])
        :setParameter("card3", cardValue[3])
        :build()
    bm.server:send(pack)

end


--发送选择牌信息
function NiuNiuSendHandle:CLI_PLAY_CARD(card_type , cardValue)

    dump(cardValue, "-----选牌1038-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
        :setParameter("card_type", card_type)
        :setParameter("card1", cardValue[1])
        :setParameter("card2", cardValue[2])
        :build()
    bm.server:send(pack)

end

--发送选择牌信息
function NiuNiuSendHandle:CLIENT_ZHUANG_OPT(value)

    dump(cardValue, "-----6022-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_ZHUANG_OPT)
        :setParameter("value", value)
        :build()
    bm.server:send(pack)

end


--发送选择牌信息
function NiuNiuSendHandle:CLIENT_XIAN_OPT(value)

    print(value, "-----6024-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_XIAN_OPT)
        :setParameter("value", value)
        :build()
    bm.server:send(pack)

end

--请求回放信息
function NiuNiuSendHandle:CLIENT_PlAY_BACK()

    print(value, "-----6028-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_PlAY_BACK)
        :build()
    bm.server:send(pack)

end

return NiuNiuSendHandle