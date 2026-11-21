--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local ShiSanZhangUtils = class("ShiSanZhangUtils")

--显示组局总结果 5100   

function ShiSanZhangUtils:returnToHall()
    --退出房间，返回大厅
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"], CLUB_ID)
    HEART_BEAT_TID = 0
end

--获取当前坐下的玩家数量
function ShiSanZhangUtils:getPlayerNum()
    
    dump(debug.traceback(),"getPlayerNum") 
    local playerNum = 0
    local audienceNum = 0

    for uid,seat in pairs(SHISANZHANG_SEAT_TABLE) do
        if  seat >= 0 then
            playerNum = playerNum + 1
        else
            audienceNum = audienceNum + 1
        end
    end

    return playerNum,audienceNum

end

--整理用户数据
function ShiSanZhangUtils:collectPlayerData(data)
    
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

    userInfo["longitude"] = data.longitude 
    userInfo["latitude"] = data.latitude
    userInfo["otherInfo"] = data.otherInfo

    local uid = data.uid


    SHISANZHANG_USERINFO_TABLE[uid] = userInfo

    SHISANZHANG_SEAT_TABLE[uid] = data.seat --保存用户座位与id映射

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

    -- require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,updateUserInfoData)

end

function ShiSanZhangUtils:showPlayerAfter(uid,seat,userInfo,playerType)
    SHISANZHANG_SEAT_TABLE[uid] = seat --保存用户座位与id映射
    SHISANZHANG_UID_TABLE[seat] = uid  --保存用户id与座位映射

    SHISANZHANG_PLAYERTYPE_TABLE[uid] = playerType

    -- SHISANZHANG_SEAT_TABLE_BYPLAYERTYPE[other_index + 1] = seat
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
function ShiSanZhangUtils:showPlayer(uid,seat,userInfo)

    SHISANZHANG_SEAT_TABLE[uid] = seat --保存用户座位与id映射
    SHISANZHANG_SEAT_TABLE_MAPPING[uid] = seat
    SHISANZHANG_UID_TABLE[seat] = uid  --保存用户id与座位映射
    local playerType = self:getPlayerTypeBySeatId(seat)
    dump(playerType,"--------------=playerType")
    dump(uid,"--------------=playerType--uid")
    SHISANZHANG_PLAYERTYPE_TABLE[uid] = playerType
    GamePlaneOperator:setTotalBetChip(playerType, userInfo.m_chips)
    -- SHISANZHANG_SEAT_TABLE_BYPLAYERTYPE[other_index + 1] = seat
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
function ShiSanZhangUtils:relocatePlayer()
    dump(SHISANZHANG_SEAT_TABLE,"重新显示游戏桌面（坐下之后）SHISANZHANG_SEAT_TABLE============")
    GamePlaneOperator:clearPlayer()
    --self:clearSHISANZHANG_SEAT_TABLE()
    SHISANZHANG_SEAT_TABLE_MAPPING = {}
    for  uid,seat in pairs(SHISANZHANG_SEAT_TABLE) do

        if seat >= 0 then
            dump(seat,"SHISANZHANG_SEAT_TABLEseat")
            local userInfo =  SHISANZHANG_USERINFO_TABLE[uid]
            self:showPlayer(uid,seat,userInfo)
        end
    end
    SHISANZHANG_SEAT_TABLE = SHISANZHANG_SEAT_TABLE_MAPPING
end

function ShiSanZhangUtils:getPlayerTypeBySeatId(seat)
	if MY_SEAT_ID < 0 or MY_SEAT_ID == 0 then
		return seat + 1
	else
        local num = 0 - MY_SEAT_ID
		local viewId = (seat + num) % TOTAL_PLAYERNUM
		if seat + num == TOTAL_PLAYERNUM then
			return TOTAL_PLAYERNUM
		end
		return viewId + 1
	end
end


return  ShiSanZhangUtils