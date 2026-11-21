--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local SanGongUtils = class("SanGongUtils")
-- local GamePlaneOperator = require(TpackageName .. ".operator.GamePlaneOperator")

--显示组局总结果 5100   
function SanGongUtils:showResult(pack)

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    --获取总结算界面
    local GroupEnding = cc.CSLoader:createNode(TpackageName .. "/csb/GroupEnding.csb")
    GroupEnding:setName("GameResult")
    GroupEnding:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    
    local winColor = cc.c3b(0xFF,0xFF,0x00)
    local loseColor =  cc.c3b(0xFF,0x00,0x00)

    SCENENOW["scene"]:addChild(s,999)

    GroupEnding:setVisible(false)
    -- SCENENOW["scene"]:performWithDelay(function()
    --     GroupEnding:setVisible(true)
    -- end,6)

    HAS_RECEIVE_GROUP_RESULT = true

    -- if bm.isDisbandSuccess == true then    --通过解散获得的组局排行榜（马上显示）
    --    GroupEnding:setVisible(true)
    --    bm.isDisbandSuccess = false
    -- end

    --退出按钮（当前组局结算，返回到大厅）
    local btn_exit = GroupEnding:getChildByName("btn_exit")
    btn_exit:addTouchEventListener(
        function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then

                --移除录音按钮
                require("hall.VoiceRecord.VoiceRecordView"):removeView()
             
                if  SCENENOW["scene"].initData() then
                    SCENENOW["scene"]:initData("release")
                end
                
                require(TpackageName..".SanGongUtils"):returnToHall()
                
            end
        end)

    --截屏分享
    local btn_share = GroupEnding:getChildByName("btn_share")
    if isiOSVerify then
        btn_share:setVisible(false)
    end
    btn_share:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                local paras = {}
                paras["showType"] = 2;
                paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
                paras["imagePath"] = "screen"
                paras["name"] = "分享结果"
                paras["url"] = appDownLoadAddress
                local shareLayer = require("hall.share.ShareLayer").new(paras)
                if shareLayer then
                    shareLayer:addTo(SCENENOW["scene"],9999999)
                end
                
                -- --通知APP分享结果
                -- if device.platform == "android" then
                --     require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
                -- elseif device.platform ~= "windows" then
                --     require("hall.common.ShareLayer"):shareGroupResultForIOS()
                -- end

            end
        end)
    

    --结果显示区域
    local content_sv = GroupEnding:getChildByName("content_sv")
    local contentWidth = content_sv:getInnerContainerSize().width
    local contentHeight = content_sv:getInnerContainerSize().height

    local single_result_Item_width = contentWidth/6
    local single_result_Item_height = contentHeight/8

    local room_id = GroupEnding:getChildByName("room_id")
    room_id:setString(USER_INFO["invote_code"])

    -- local time_txt = GroupEnding:getChildByName("time_txt")
    -- time_txt:setString(os.date("%H:%M"))

    local round = GroupEnding:getChildByName("round")
    round:setString(GAME_ROUND)

    local score = GroupEnding:getChildByName("score")
    
    --定义结果分项
    local result_Item = GroupEnding:getChildByName("group_ending_box") 

    --显示用户结算结果
    local playerlist = pack.playerlist

    local fuhao_uid = nil
    local lastChip = 0

    dump(playerlist,"playerlist")
    for k,v in pairs(playerlist) do

        --获取用户id
        local uid = v.uid
        local chips

    ------------------------------------------------数据---------------------------------------
        if  GROUP_MODE == 2 then
            chips = v.chips
        else
            --获取用户信息以及结算情况
            local user_info = json.decode(v.user_info)
            local oriChips = user_info.oriChips or initialChip
            --获取用户分数
            chips = user_info.chips - oriChips
        end

    ---------------------------------------------------------------------------------------------
        if chips ~= nil then
            --比较分数
            if chips > lastChip then
                --记录最新点炮数和点炮id
                lastChip = chips
                fuhao_uid = uid
            end
        end
    end

    
    dump(fuhao_uid,"fuhao_uid")

    local result_Item_position_index = 1
     
    local playerNum =  #playerlist
    
    local lineCount = 4
    if playerNum > 10 then
        lineCount = math.ceil(playerNum/3)
        content_sv:setInnerContainerSize(contentWidth,content_sv:getInnerContainerSize().height/4 * lineCount)
    end

    if playerNum > 0 then

        --生成界面
        for k,v in ipairs(playerlist) do
            
            ------------------------------------------数据-----------------------------------
            local uid = v.uid
            local photo_url
            local sex = 1
            local nick_name
            local chips
            
            if GROUP_MODE == 2 then
                photo_url = v.portrait
                nick_name = v.nickName
                chips  = v.chips
            else
                local user_info = json.decode(v.user_info)

                photo_url = user_info.photo_url
                nick_name = user_info.nick_name
                sex = user_info.sex

                local oriChips = user_info.oriChips or initialChip
                chips = user_info.chips - oriChips
            end

            -------------------------------------------界面-------------------------------------------
                
            local result_Item = result_Item:clone()
            content_sv:addChild(result_Item)
            
            local group_ending_winer = result_Item:getChildByName("group_ending_winer")

            if playerNum <= 10 then

                if  uid == fuhao_uid then
                    group_ending_winer:setVisible(true)
                    local x = 3 * single_result_Item_width 
                    local y = 7 * single_result_Item_height 
                    result_Item:setPosition(cc.p(x,y))
                else
                    group_ending_winer:setVisible(false)
                    local x = contentWidth / 2 - (2 - math.ceil(result_Item_position_index % 3.01)) * 400
                    dump(x,"游戏框位置"..k)
                    -- local x = (math.ceil(result_Item_position_index % 3.01) * 2 - 1) * single_result_Item_width 
                    local y = (7 - math.ceil(result_Item_position_index/3.01)* 2) * single_result_Item_height    
                    
                    result_Item:setPosition(cc.p(x,y))
                    result_Item_position_index = result_Item_position_index + 1
                end

            else
                
                if  uid == fuhao_uid then
                    group_ending_winer:setVisible(true)
                else
                    group_ending_winer:setVisible(false)
                end

                local x = (math.ceil(result_Item_position_index % 3.01) * 2 - 1) * single_result_Item_width 
                local y = ((lineCount*2 + 1) - math.ceil(result_Item_position_index/3.01)* 2) * single_result_Item_height  
                result_Item_position_index = result_Item_position_index + 1
                result_Item:setPosition(cc.p(x,y))

            end

            --用户头像
            local head_im = result_Item:getChildByName("head_im")
            require("hall.GameCommon"):getUserHead(photo_url, uid, sex, head_im, head_im:getContentSize().width, false, nick_name)

            --用户昵称
            local nick_txt = result_Item:getChildByName("nick_txt")
         
            local namenick = ""
            if  SANGONG_USERINFO_TABLE[uid] then
                namenick = SANGONG_USERINFO_TABLE[uid].nick or "未知昵称"
                namenick = SanGongUtils:formatNick(namenick, 7)
            end

            nick_txt:setString(namenick)

            --用户id
            local id_txt = result_Item:getChildByName("id_txt")
            id_txt:setString("ID:" .. tostring(uid))
            
            if GAME_ROUND == 0 and chips == -20000 then
                chips = 0
            end

            local score_txt = result_Item:getChildByName("score_txt")

            if  chips >= 0 then
               score_txt:setTextColor(winColor)
            else
               score_txt:setTextColor(loseColor)
            end  
            
            score_txt:setString(tostring(chips))

            if  uid == USER_INFO["uid"] then
                score:setString(tostring(chips))
            end

        end

    end

end

function SanGongUtils:returnToHall()
    --退出房间，返回大厅
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
    HEART_BEAT_TID = 0
end

--获取当前坐下的玩家数量
function SanGongUtils:getPlayerNum()
    
    -- dump(debug.traceback(),"getPlayerNum") 
    local playerNum = 0
    local audienceNum = 0

    for uid,seat in pairs(SANGONG_SEAT_TABLE) do
        if  seat >= 0 then
            playerNum = playerNum + 1
        else
            audienceNum = audienceNum + 1
        end
    end

    return playerNum,audienceNum

end

--整理用户数据
function SanGongUtils:collectPlayerData(data)
    
    dump(data, "玩家信息数据")

    local info ={}
    local gold = data.gold

    if  GROUP_MODE == 2 then 
    else
        info= json.decode(data["user_info"])
    end

    --data数据是直接获得的，金币场
    --info协议放在userinfo_json里
    local nick_name =  data.nickName or info.nickName or data.nick
    dump(data.gold,"玩家金币")
    local icon_url = data.portrait or (info.photoUrl or info.icon_url) or data.icon_url
    local sex_num = data.sex or info.sex
    local userInfo = {}
    userInfo["ready"] = data.ready or 0
    --头像图片
    userInfo["icon_url"] = icon_url or ""
    --昵称
    userInfo["nick"] = nick_name or ""
    --金币
    userInfo["gold"] = SanGongUtils:goldMath(gold)   --用户总金币
    --UID
    userInfo["uid"] = data.uid or 0
    --性别
    userInfo["sex"] = sex_num or 0 
    --IP
    userInfo["ip"] = data.ip or "0.0.0.0"

    userInfo["score"] = 0     --用户本局游戏的胜负
    userInfo["count"] = data.count or 0
    userInfo["totalGold"] = data.totalGold or 0
    userInfo["otherInfo"] =data.otherInfo
    userInfo["longitude"] = data.longitude
    userInfo["latitude"] = data.latitude
    local uid = data.uid

    SANGONG_USERINFO_TABLE[uid] = userInfo
    SANGONG_SEAT_TABLE[uid] = data.seat --保存用户座位与id映射
    if uid == USER_INFO["uid"] then
        MY_SEAT_ID = data.seat
    end
    local updateUserInfoData = {}

    if  data.longitude then
        updateUserInfoData["longitude"] = data.longitude
        updateUserInfoData["latitude"] = data.latitude
        updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
    end

    if  data.otherInfo and data.otherInfo ~= "" then
        updateUserInfoData["city"] = json.decode(data.otherInfo)["city"]
    end

    updateUserInfoData["nickName"] = userInfo["nick"]
    updateUserInfoData["longitude"] = data.longitude
    updateUserInfoData["latitude"] = data.latitude
    updateUserInfoData["ip"] = data.ip
    dump(updateUserInfoData,"updateUserInfoData")

    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,updateUserInfoData)
    --if isShowAddress == true then
    --    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
    --        local args = {}
    --        args["uid"] =  tostring(userInfo.uid) or "0"
    --        args["latitude"] =  userInfo.latitude  or "0"
    --        args["longitude"] = userInfo.longitude  or "0"
    --        cct.getDataForApp("downloadAddreses", args, "V")
    --    elseif device.platform == "android"then
    --        local args = {}
    --        table.insert(args,tostring(userInfo.uid)  or "0")
    --        table.insert(args,userInfo.latitude  or "0")
    --        table.insert(args,userInfo.longitude  or "0")
    --        cct.getDataForApp("downloadAddreses", args, "V")
    --    end
    --end
end

function SanGongUtils:showPlayerAfter(uid,seat,userInfo,playerType)
    SANGONG_SEAT_TABLE[uid] = seat --保存用户座位与id映射
    SANGONG_UID_TABLE[seat] = uid  --保存用户id与座位映射

    SANGONG_PLAYERTYPE_TABLE[uid] = playerType

    -- dump(TOTAL_PLAYERNUM,"TOTAL_PLAYERNUM")
    -- SANGONG_SEAT_TABLE_BYPLAYERTYPE[other_index + 1] = seat
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
function SanGongUtils:showPlayer(uid,seat,userInfo)

    SANGONG_SEAT_TABLE[uid] = seat --保存用户座位与id映射
    SANGONG_SEAT_TABLE_MAPPING[uid] = seat
    SANGONG_UID_TABLE[seat] = uid  --保存用户id与座位映射
    local playerType = self:getPlayerTypeBySeatId(seat)
    SANGONG_PLAYERTYPE_TABLE[uid] = playerType
    SANGONG_PLAYERTYPE_TABLE_MAPPING[uid] = playerType
    GamePlaneOperator:setTotalBetChip(playerType, SanGongUtils:goldMath(userInfo.totalGold))
    -- dump(TOTAL_PLAYERNUM,"TOTAL_PLAYERNUM")
    -- SANGONG_SEAT_TABLE_BYPLAYERTYPE[other_index + 1] = seat
    -----------------------------------------------------------------
    -- dump(uid,"uid")

    -- 2,991 = 1, 992 = 2            992 = 1, 991 = 2
    -- 3,991 = 1, 992 = 2, 993 =     992 = 1, 991 = 2,993 =       993 = 1,

    local head = GamePlaneOperator:showPlayerInfo(playerType,userInfo,seat)
    if not head then
        return
    end

    --将head的坐标映射到世界坐标系中去
    local   worldpoint = (head:getParent()):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法
    
    PLAYER_HEADS_TABLE[uid] = head
    PLAYER_HEADS_POSITION_TABLE[uid] = worldpoint

    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(userInfo["uid"], worldpoint)
end

--重新显示游戏桌面（坐下之后）
function SanGongUtils:relocatePlayer()

    GamePlaneOperator:clearPlayer()

    SANGONG_SEAT_TABLE_MAPPING = {}
    SANGONG_PLAYERTYPE_TABLE_MAPPING = {}
    for  uid,seat in pairs(SANGONG_SEAT_TABLE) do

        if seat >= 0 then
            dump(seat,"SANGONG_SEAT_TABLEseat")
            local userInfo =  SANGONG_USERINFO_TABLE[uid]
            self:showPlayer(uid,seat,userInfo)
        end
    end

    SANGONG_SEAT_TABLE = SANGONG_SEAT_TABLE_MAPPING   --重新整理 seatid
    SANGONG_PLAYERTYPE_TABLE = SANGONG_PLAYERTYPE_TABLE_MAPPING  --重新整理playerId
end

function SanGongUtils:clearPlayerGold()
    for  uid,seat in pairs(SANGONG_SEAT_TABLE) do
        if seat >= 0 then
            SANGONG_USERINFO_TABLE[uid].totalGold = 0
        end
    end

end
function SanGongUtils:getPlayerTypeBySeatId(seat)
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
function SanGongUtils:getChipBtnNew(gold)
    local refuel = nil
    for k,v in ipairs(GAME_CHIP_CONFIG) do
        dump(GAME_CHIP_CONFIG,"GAME_CHIP_CONFIG")
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
function SanGongUtils:getChipBtnText(gold)
    local num_str  = math.modf(gold)
    --if gold > 999 and  gold < 10000 then
    --    num_str= string.format("%0.1f", math.floor(gold/10)/100)
    --    num_str = tostring(num_str).."千"
    --else
    if gold > 9999 then
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

function SanGongUtils:goldMath(gold)
    local value = 0
    --if gold then
    --    value = string.format("%.2f", gold/100)
    --end
    --return tonumber(value)
    if isRide then
        if gold then
            value = string.format("%.2f",  gold/100)
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

function SanGongUtils:formatNick(str,size)

    if str == nil then
        return ""
    end

    -- body
    local width = 0
    local size = size or 4
    local char_count = 0
    local pos = 1
    local lenInByte = #str

    if lenInByte < 10 then
        return str
    else
        local nick = ""
        for i=1,lenInByte do
            local curByte = string.byte(str, pos)

            if curByte == nil then
                return str
            end

            local byteCount = 1;
            dump(curByte,"curByte")
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<=223 then
                byteCount = 2
            elseif curByte>=224 and curByte<=239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            local char = string.sub(str, pos, pos + byteCount - 1)
            nick = nick .. char
            char_count = char_count + 1
            pos = pos + byteCount
            if char_count >= size then
                return nick .. "..."
            end

        end
    end

end

return  SanGongUtils