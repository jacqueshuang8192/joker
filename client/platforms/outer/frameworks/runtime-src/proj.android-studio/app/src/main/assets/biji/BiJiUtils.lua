--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local BiJiUtils = class("BiJiUtils")

--显示组局总结果 5100   

function BiJiUtils:returnToHall()
    --退出房间，返回大厅
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
    HEART_BEAT_TID = 0
end

--获取当前坐下的玩家数量
function BiJiUtils:getPlayerNum()
    
    dump(debug.traceback(),"getPlayerNum") 
    local playerNum = 0
    local audienceNum = 0

    for uid,seat in pairs(BIJI_SEAT_TABLE) do
        if  seat >= 0 then
            playerNum = playerNum + 1
        else
            audienceNum = audienceNum + 1
        end
    end

    return playerNum,audienceNum

end

--整理用户数据
function BiJiUtils:collectPlayerData(data)
    
    dump(data, "玩家信息数据")

    local info ={}
    local m_chips = data.m_chips
    local nickName =  data.nickName
    dump(data.m_chips,"玩家金币")
    local icon_url = data.icon_url
    local sex_num = data.sex
    local userInfo = {}

    --头像图片
    userInfo["icon_url"] = icon_url or ""
    --昵称
    userInfo["nickName"] = nickName or ""
    --金币
    userInfo["m_chips"] = m_chips   --用户总金币
    --UID
    userInfo["uid"] = data.uid or 0
    --性别
    userInfo["sex"] = sex_num or 0 
    --IP
    userInfo["ip"] = data.ip or "0.0.0.0"
    userInfo["if_ready"] = data.if_ready     --用户是否准备
    userInfo["score"] = 0     --用户本局游戏的胜负
    userInfo["totalGold"] = data.totalGold or 0
    userInfo["seat"] = data.seat
    userInfo["m_isOpenCard"] = data.m_isOpenCard
    local uid = data.uid

    BIJI_USERINFO_TABLE[uid] = userInfo
    BIJI_SEAT_TABLE[uid] = data.seat --保存用户座位与id映射
    if uid == USER_INFO["uid"] then
        MY_SEAT_ID = data.seat
    end
    local updateUserInfoData = {}

    if  data.longitude then
        updateUserInfoData["longitude"] = data.longitude
        updateUserInfoData["latitude"] = data.latitude
        updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
    end

    if  data.otherInfo then
        updateUserInfoData["city"] = json.decode(data.otherInfo)["city"]
    end

    updateUserInfoData["nickName"] = userInfo["nickName"]
    updateUserInfoData["ip"] = data.ip

    dump(updateUserInfoData,"updateUserInfoData")

    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,updateUserInfoData)

end

function BiJiUtils:showPlayerAfter(uid,seat,userInfo,playerType)
    BIJI_SEAT_TABLE[uid] = seat --保存用户座位与id映射
    BIJI_UID_TABLE[seat] = uid  --保存用户id与座位映射

    BIJI_PLAYERTYPE_TABLE[uid] = playerType

    -- dump(TOTAL_PLAYERNUM,"TOTAL_PLAYERNUM")
    -- BIJI_SEAT_TABLE_BYPLAYERTYPE[other_index + 1] = seat
    -----------------------------------------------------------------
    -- dump(uid,"uid")

    -- 2,991 = 1, 992 = 2            992 = 1, 991 = 2
    -- 3,991 = 1, 992 = 2, 993 =     992 = 1, 991 = 2,993 =       993 = 1,

    local  head = GamePlaneOperator:showPlayerInfo(playerType,userInfo,seat)


    --将head的坐标映射到世界坐标系中去
    local   worldpoint = (head:getParent()):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法

    PLAYER_HEADS_TABLE[uid] = head
    PLAYER_HEADS_POSITION_TABLE[uid] = worldpoint

    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(userInfo["uid"], worldpoint)
end

--显示玩家头像
function BiJiUtils:showPlayer(uid,seat,userInfo)

    BIJI_SEAT_TABLE[uid] = seat --保存用户座位与id映射
    BIJI_SEAT_TABLE_MAPPING[uid] = seat
    BIJI_UID_TABLE[seat] = uid  --保存用户id与座位映射
    local playerType = self:getPlayerTypeBySeatId(seat)
dump(playerType,"--------------=playerType")
    dump(uid,"--------------=playerType--uid")
    BIJI_PLAYERTYPE_TABLE[uid] = playerType
    GamePlaneOperator:setTotalBetChip(playerType, userInfo.m_chips)
    -- dump(TOTAL_PLAYERNUM,"TOTAL_PLAYERNUM")
    -- BIJI_SEAT_TABLE_BYPLAYERTYPE[other_index + 1] = seat
    -----------------------------------------------------------------
    -- dump(uid,"uid")

    -- 2,991 = 1, 992 = 2            992 = 1, 991 = 2
    -- 3,991 = 1, 992 = 2, 993 =     992 = 1, 991 = 2,993 =       993 = 1,

    local  head = GamePlaneOperator:showPlayerInfo(playerType,userInfo,seat)
    if head == nil then return end

    --将head的坐标映射到世界坐标系中去
    local   worldpoint = (head:getParent()):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法
    
    PLAYER_HEADS_TABLE[uid] = head
    PLAYER_HEADS_POSITION_TABLE[uid] = worldpoint

    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(userInfo["uid"], worldpoint)
end


--重新显示游戏桌面（坐下之后）
function BiJiUtils:relocatePlayer()
    dump(BIJI_SEAT_TABLE,"BIJI_SEAT_TABLE============")
    GamePlaneOperator:clearPlayer()
    --self:clearBIJI_SEAT_TABLE()
    BIJI_SEAT_TABLE_MAPPING = {}
    for  uid,seat in pairs(BIJI_SEAT_TABLE) do

        if seat >= 0 then
            dump(seat,"BIJI_SEAT_TABLEseat")
            local userInfo =  BIJI_USERINFO_TABLE[uid]
            self:showPlayer(uid,seat,userInfo)
        end
    end
    BIJI_SEAT_TABLE = BIJI_SEAT_TABLE_MAPPING
end
function BiJiUtils:clearPlayerGold()
    for  uid,seat in pairs(BIJI_SEAT_TABLE) do
        if seat >= 0 then
            BIJI_USERINFO_TABLE[uid].totalGold = 0
        end
    end

end
function BiJiUtils:getPlayerTypeBySeatId(seat)
    local playerType = 0

    if MY_SEAT_ID >=0 then
        local other_index = seat - MY_SEAT_ID

        if other_index < 0 then
            other_index = other_index + TOTAL_PLAYERNUM
        end
        playerType = other_index + 1
    else
        playerType = seat +1
    end

    dump(playerType,"getPlayerTypeBySeatId")
    return playerType
   -- return seat + 1
end
function BiJiUtils:getChipBtnNew(gold)
    local refuel = nil
    for k,v in ipairs(GAME_CHIP_CONFIG) do
        if gold < v then
            refuel = "refuel_"..k..".png"
            break
        end
    end
    if refuel == nil then
        refuel = "refuel_4.png"
    end
    local img_name = ""
    local num_str  = math.modf(gold)
    if gold > 999 and  gold < 10000 then
        num_str = math.modf(num_str/1000)
        num_str = tostring(num_str).."千"
    elseif gold > 9999 then
        num_str = math.modf(num_str/10000)
        num_str = tostring(num_str).."万"
    end
    local ttfConfig = {}
    ttfConfig.fontFilePath = TpackageName.."/font/fzcs.ttf"
    ttfConfig.fontSize = 32
    local text = cc.Label:createWithTTF(ttfConfig, num_str)
    text:setColor(cc.c3b(0,0,0))
    text:setString(num_str)
    local bg = ccui.ImageView:create(TpackageName.."/images/stake/"..refuel)
    bg:setContentSize(cc.size(30,30))
    text:setPosition(cc.p(bg:getContentSize().width/2 -2,bg:getContentSize().height/2 +5))
    bg:addChild(text)

    return bg
end
function BiJiUtils:getChipBtnText(gold)
    local num_str  = math.modf(gold)
    if gold > 999 and  gold < 10000 then
        num_str = math.modf(num_str/1000)
        num_str = tostring(num_str).."千"
    elseif gold > 9999 then
        num_str = math.modf(num_str/10000)
        num_str = tostring(num_str).."万"
    end
    local ttfConfig = {}
    ttfConfig.fontFilePath = TpackageName.."/font/fzcs.ttf"
    ttfConfig.fontSize = 38
    local text = cc.Label:createWithTTF(ttfConfig, num_str)
    text:setColor(cc.c3b(0,0,0))
    text:setString(num_str)


    return text
end

function BiJiUtils:goldMath(gold)
    local value = 0
    --if gold then
    --    value = string.format("%.2f", gold/100)
    --end
    --return tonumber(value)
    if appName == "真赢棋牌" then
        if gold then
            value = string.format("%.2f", gold/100)
        end
        return tonumber(value)
    else
        if gold then
            return tonumber(gold)
        else
            return 0
        end
    end

end

function BiJiUtils:sortCards()
--    for k,v in ipairs(MY_BEST_CARDS) do
--        table.sort(v,function(a,b)
--            if #a > 0 then
--                if a.son_card_type == b.son_card_type then
--                    local numA ,numB = 0
--                    local colorA, colorB =0
--                    for sona_k , sona_v in ipairs(a.son_card) do
--                        local N, C= GamePlaneOperator:getCardLogicValue(sona_v)
--                        for sonb_k , sonb_v in ipairs(b.son_card) do
--                            local N2, C2= GamePlaneOperator:getCardLogicValue(sonb_v)
--                            if(N2 ~= N) then
--
--                            end
--                        end
--                    end
--                    for k2 , v2 in ipairs(b.son_card) do
--                        local N, C= GamePlaneOperator:getCardLogicValue(v2)
--                        numB = N + numB
--                        colorB = C
--                    end
--                    if numA == numB then
--                        return colorA >colorB
--                    end
--                    return numA > numB
--                end
--
--                return a.son_card_type > b.son_card_type
--            end
--        end)
--    end
end
return  BiJiUtils