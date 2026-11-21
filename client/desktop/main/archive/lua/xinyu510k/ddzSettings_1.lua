local ddzSettings  = class("ddzSettings")

local GamePlaneOperator = require("xinyu510k.operator.GamePlaneOperator")
-- local tbDDZErrorCode = {
--     [0] = "成功创建新连接",
--     [1] = "重连成功",
--     [2] = "成功踢其他玩家",
--     [3] = "玩家密匙错误",
--     [4] = "数据库连接错误",
--     [5] = "无此房间",
--     [6] = "玩家登录房间错误",
--     [7] = "无房间分配",
--     [8] = "没有空桌子",
--     [9] = "玩家余额不足",
--     [10] = "游戏策略错误",
--     [11] = "未知错误",
--     [12] = "黑名单",
--     [13] = "玩家请求准备",
--     [14] = "添加黑名单错误",
--     [15] = "您当前不能进低分场",
--     [16] = "等级不够",
--     [17] = "等级太高",
--     [18] = "经验不够",
--     [19] = "经验太多",
--     [20] = "比赛中退赛马上有报名错误",
--     [21] = "比赛场金币不足",
--     [22] = "比赛场钻石不足",
-- }

-- local otherIndex2playerType = 
--    {[0] = CARD_PLAYERTYPE_MY,
--     [1] = CARD_PLAYERTYPE_LEFT,
--     [2] = CARD_PLAYERTYPE_TOP,
--     [3] = CARD_PLAYERTYPE_RIGHT}

-- function ddzSettings:getErrorCode( type )
--     return tbDDZErrorCode[type]
-- end

--整理用户数据
function ddzSettings:collectPlayerData(pack)

    dump(pack, "玩家信息数据")
    local uid = pack.uid
    local sex = pack.sex 
    local nickName = pack.nickName 
    local portrait = pack.portrait 
    local latitude = pack.latitude 
    local longitude = pack.longitude 
    local otherInfo = pack.otherInfo 
    local ip = pack.ip 

    local user_gold = pack.user_gold
    -- dump(user_gold,"showPlayer_user_gold")

    local userInfo = {}
    --头像图片
    userInfo["icon_url"] = portrait
    --昵称
    userInfo["nick"] = nickName 
    --金币
    userInfo["coins"] = user_gold
    --UID
    userInfo["uid"] = uid
    --性别
    userInfo["sex"] = sex 
	userInfo.latitude = latitude
	userInfo.longitude = longitude
	userInfo.ip = ip

    DDZ_USERINFO_TABLE[pack.uid] = userInfo
    DDZ_SEAT_TABLE[uid] = pack.seat_id  

    local updateUserInfoData = {}

    if  pack.longitude then
        updateUserInfoData["longitude"] = pack.longitude
        updateUserInfoData["latitude"] = pack.latitude
        updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
    end

    if  pack.otherInfo then
        local otherInfo = json.decode(pack.otherInfo)
        if otherInfo then
            updateUserInfoData["city"] = otherInfo["city"]
        end
    end

    updateUserInfoData["uid"] = uid
    updateUserInfoData["nickName"] = userInfo["nick"]
    updateUserInfoData["ip"] = pack.ip
	updateUserInfoData["addres"] = pack.addres

    -- dump(updateUserInfoData,"updateUserInfoData")
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,updateUserInfoData)

end

--显示其他玩家信息
function ddzSettings:showPlayer(uid,seat_id,userInfo)
    local playerType = self:getPlayerType(seat_id)
	--dump(userInfo, 'xxx')
	--dump(DDZ_USERINFO_TABLE[uid], 'yyy')
    userInfo = userInfo or DDZ_USERINFO_TABLE[uid]
    SEAT2USERID[seat_id] = uid
    DDZ_SEAT_TABLE[uid] = seat_id  
    
    --设置准备状态
    if  USERS_READY_STATE[uid] == 1 and  GAME_STATE == STATUS_STOP and playerType~= CARD_PLAYERTYPE_MY then
        GamePlaneOperator:setReadyStatus(playerType)
    end
    print("playerType", playerType,userInfo)
    local head = GamePlaneOperator:showPlayerInfo(playerType,userInfo)

    local worldpoint = (head:getParent()):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法
    
    PLAYER_HEADS_TABLE[uid] = head
    PLAYER_HEADS_POSITION_TABLE[uid] = worldpoint
    
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid, worldpoint)

end

--重新显示游戏桌面（坐下之后）
function ddzSettings:relocatePlayer()

    GamePlaneOperator:relocate("player")

    -- local drawCount = 0

    for uid,seat_id in pairs(DDZ_SEAT_TABLE) do      
        if seat_id >= 0 then   
            -- drawCount = drawCount + 1
            -- SCENENOW["scene"]:performWithDelay(function()
                local userInfo =  DDZ_USERINFO_TABLE[uid]
                self:showPlayer(uid,seat_id,userInfo)     
            -- end,1/30 * drawCount)
        end
    end

end

function ddzSettings:getPlayerType(seatId)   --seatId为服务器座位号
    print('getPlayerType  ', seatId, XinYu510KRoomInfo, XinYu510KRoomInfo and XinYu510KRoomInfo.maxSeatCount)    
    if seatId == nil or seatId < 0 then return nil end
	print('f1')
	if not XinYu510KRoomInfo then
		print('ddzSettings:getPlayerType error', debug.traceback())
		return nil
	end
	print('f2')
	local playerType = CARD_PLAYERTYPE_MY
	if XinYu510KRoomInfo.maxSeatCount == 2 then
		if seatId == MY_SEAT_ID then
			playerType = CARD_PLAYERTYPE_MY
		else
			playerType = CARD_PLAYERTYPE_TOP
		end
		
		-- local other_index = seatId - MY_SEAT_ID

		-- if other_index < 0 then
		   -- other_index = other_index + XinYu510KRoomInfo.maxSeatCount
		-- end
		 
		-- playerType =  other_index+1  -- otherIndex2playerType[other_index]
		-- if playerType > 4 then
			-- playerType = 4
		-- end
	else
		local other_index = seatId - MY_SEAT_ID

		if other_index < 0 then
		   other_index = other_index + XinYu510KRoomInfo.maxSeatCount
		end
		 
		playerType =  other_index+1  -- otherIndex2playerType[other_index]
		if playerType > 4 then
			playerType = 4
		end
	end

    print('f3',playerType)
    return playerType
end


function ddzSettings:playEffectSound(sound_path)
    cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
end

-- --显示一局结算的结算界面
-- function ddzSettings:showGroupResult(groupRanking)

--     dump(groupRanking, "-----一局结算信息-----")

--     --去掉提示弹框
--     local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
--     if layer_tips then
--         layer_tips:removeSelf()
--     end

--     --获取总结算界面
--     local s = cc.CSLoader:createNode(TotalResultCsb_filePath)
--     s:setName("GameResult")
--     s:setVisible(false)
--     s:addTo(SCENENOW["scene"],1001)

--     --退出按钮（当前组局结算，返回到大厅）
--     local back_bt = s:getChildByName("back_bt")
--     back_bt:addTouchEventListener(
--         function(sender,event)
--             --触摸开始
--             if event == TOUCH_EVENT_BEGAN then
--                 sender:setScale(0.9)
--             end

--             --触摸取消
--             if event == TOUCH_EVENT_CANCELED then
--                 sender:setScale(1.0)
--             end

--             --触摸结束
--             if event == TOUCH_EVENT_ENDED then
--                 sender:setScale(1.0)

--                 --退出房间，返回大厅
--                 require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

--             end
--     end)

--     --结果显示区域
--     local content_ly = s:getChildByName("content_ly")
--     local content_sv = content_ly:getChildByName("content_sv")

--     --显示用户结算结果
--     local playerlist = groupRanking.playerlist
--     if #playerlist > 0 then

--         --记录最佳炮手和大富豪
--         local paoshou_uid = nil
--         local lastPaoNum = 0

--         local fuhao_uid = nil
--         local lastChip = 0

--         for k,v in pairs(playerlist) do
            
--             --获取用户id
--             local uid = v.uid

--             --获取用户信息以及结算情况
--             local user_info = json.decode(v.user_info)

--             --获取用户分数
--             local chips = user_info.chips
--             local add_chips = user_info.add_chips
        
--             if chips ~= nil then
--                 --比较分数
--                 local cha = chips -  (add_chips or 2000)
--                 if cha > lastChip then
--                     --记录最新点炮数和点炮id
--                     lastChip = cha
--                     fuhao_uid = uid
--                 end
--             end

--         end

--         local zOrder = 10

--         --生成界面
--         for k,v in pairs(playerlist) do

--             --获取用户id
--             local uid = v.uid

--             -- local oriChips = user_info.oriChips or 20000

--             --获取用户信息以及结算情况
--             local user_info = json.decode(v.user_info)

--             --定义结果分项
--             local result_Item = cc.CSLoader:createNode(ResultItemCsb_filePath)
--             result_Item:setLocalZOrder(zOrder)
--             zOrder = zOrder - 1
--             content_sv:addChild(result_Item)

--             local item_ly = result_Item:getChildByName("item_ly")
--             item_ly:setPosition(300 * (k - 1), content_sv:getContentSize().height)

--             --显示大富豪
--             local winner_im = item_ly:getChildByName("winner_im")
--             if fuhao_uid ~= nil then
--                 if fuhao_uid == uid then
--                     winner_im:setVisible(true)
--                 end
--             end

--             local top_ly = item_ly:getChildByName("top_ly")

--             --用户头像
--             local head_im = top_ly:getChildByName("head_im")

--             local head_info = {}
--             head_info["icon_url"] = user_info.photo_url
--             head_info["uid"] = uid
--             head_info["sex"] = user_info.sex
--             head_info["sp"] = head_im
--             head_info["size"] = 61
--             head_info["touchable"] = 0
--             head_info["use_sharp"] = 1
--             -- require("hall.GameCommon"):setPlayerHead(head_info,head_im,61)
--             require("hall.GameCommon"):getUserHead(user_info.photo_url, v.uid, user_info.sex, head_im, 80, false)

--             --是否为房主
--             local roomowner_im = top_ly:getChildByName("roomowner_im")
--             --只有房主才出现房主标志
--             local group_owner = tonumber(USER_INFO["group_owner"])
--             if group_owner == v.uid then
--                 roomowner_im:setVisible(true)
--             else
--                 roomowner_im:setVisible(false)
--             end

--             --中间区域
--             local content_sv = item_ly:getChildByName("content_sv")

--             --单局最高分
--             local high_score = content_sv:getChildByName("dhzm_ly")
--                   high_score:setVisible(false)
--             local zimo_itemNum_tt = high_score:getChildByName("itemNum_tt")
--             local text_box_1_name = high_score:getChildByName("itemName_tt")
--                   text_box_1_name:setString("单局最高分")

--             if user_info.high_scord ~= nil then
--                 zimo_itemNum_tt:setString(tostring(user_info.high_scord))
--             else
--                 zimo_itemNum_tt:setString(tostring(0))
--             end

--             --打出炸弹数
--             local boom_times = content_sv:getChildByName("xhzm_ly")
--             local dianpao_itemNum_tt = boom_times:getChildByName("itemNum_tt")
--             local text_box_2_name = boom_times:getChildByName("itemName_tt")
--                   text_box_2_name:setString("玩家游戏场数")
            
--             local count_boom = DDZ_ROUND
--             -- if user_info.win_times ~= nil and user_info.lose_times ~= nil then
--             --    count_boom = user_info.win_times + user_info.lose_times
--             -- end
--             -- if user_info.boom_times then
--             --     count_boom = user_info.boom_times
--             -- end

--             -- if user_info.missile_times then
--             --     count_boom = count_boom + user_info.missile_times
--             -- end

--             dianpao_itemNum_tt:setString(tostring(count_boom))

--             --胜局数
--             local win_count = content_sv:getChildByName("dhdp_ly")
--             local jiepao_itemNum_tt = win_count:getChildByName("itemNum_tt")
--             local text_box_3_name = win_count:getChildByName("itemName_tt")
--                   text_box_3_name:setString("胜局数")

--             if user_info.win_times ~= nil then
--                 jiepao_itemNum_tt:setString(tostring(user_info.win_times))
--             else
--                 jiepao_itemNum_tt:setString(tostring(0))
--             end

--             --负局数
--             local lose_count = content_sv:getChildByName("xhdp_ly")
--             local jiepao_itemNum_tt = lose_count:getChildByName("itemNum_tt")
--             local text_box_4_name = lose_count:getChildByName("itemName_tt")
--                   text_box_4_name:setString("负局数")

--             if user_info.lose_times ~= nil then
--                 jiepao_itemNum_tt:setString(tostring(user_info.lose_times))
--             else
--                 jiepao_itemNum_tt:setString(tostring(0))
--             end

--             --明杠
--             local dhjp_ly = content_sv:getChildByName("dhjp_ly")
--             dhjp_ly:setVisible(false)

--             local dhjp_itemNum_tt = dhjp_ly:getChildByName("itemNum_tt")
--             if user_info.minggang ~= nil then
--                 -- dhjp_itemNum_tt:setString(tostring(user_info.minggang))
--             end

--             --大叫
--             local xhjp_ly = content_sv:getChildByName("xhjp_ly")
--             xhjp_ly:setVisible(false)
--             local xhjp_itemNum_tt = xhjp_ly:getChildByName("itemNum_tt")
--             if user_info.jiepao_xiaohu ~= nil then
--                 -- xhjp_itemNum_tt:setString(tostring(user_info.jiepao_xiaohu))
--             end


--             --用户昵称
--             local name_tt = top_ly:getChildByName("name_tt")
--             -- name_tt:setString(user_info.nick_name)

--             if  user_info.nick_name and type(user_info.nick_name) == "string" then
--                 local  nickName = require("hall.GameCommon"):formatNick(user_info.nick_name, 6)
--                 name_tt:setString(nickName)
--             else
--                 name_tt:setString("未知昵称")
--             end

--             --用户id
--             local id_tt = top_ly:getChildByName("id_tt")
--             id_tt:setString("ID:" .. tostring(v.uid))

--             --底部区域
--             local bottom_ly = item_ly:getChildByName("bottom_ly")

--             --总成绩
--             --用户当前的积分
--             local chips = user_info.chips - user_info.add_chips
--             local socre_tt = bottom_ly:getChildByName("socre_tt")

--             if  chips == -20000 then chips = 0 end
--             socre_tt:setString(tostring(chips))

--         end

--     end

--     local share_ly = s:getChildByName("share_ly")
--     share_ly:addTouchEventListener(
--         function(sender,event)
--             --触摸开始
--             if event == TOUCH_EVENT_BEGAN then
--                 sender:setScale(0.9)
--             end

--             --触摸取消
--             if event == TOUCH_EVENT_CANCELED then
--                 sender:setScale(1.0)
--             end

--             --触摸结束
--             if event == TOUCH_EVENT_ENDED then
--                 sender:setScale(1.0)

--                 --通知APP分享结果
--                 if device.platform == "android" then
--                     require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
--                 elseif device.platform ~= "windows" then
--                     require("hall.common.ShareLayer"):shareGroupResultForIOS()
--                 end

--             end
--         end
--     )
-- end


function ddzSettings:returnToHall()
    --退出房间，返回大厅
	HEART_BEAT_TID = 0
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)

    if  SCENENOW["scene"].initData then
        SCENENOW["scene"]:initData("release")
    end

    --移除录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):removeView()
end


--显示组局总结果 5100   
function ddzSettings:showGroupResult(pack)

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end
    
    --退出按钮（当前组局结算，返回到大厅）
    local backHall_action = function(sender,event)

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
                self:returnToHall()         
            end
        end

    --截屏分享
    local share_action = function(sender,event)
    
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

                --通知APP分享结果
                if device.platform == "android" then
                    require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
                elseif device.platform ~= "windows" then
                    require("hall.common.ShareLayer"):shareGroupResultForIOS()
                end

            end
        end

    local data = {}
    data["resultSceneType"] = 1       --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = USER_INFO["invote_code"]     --房间号
    data["fenchang"] = nil            --分场
    data["round"] = GAME_ROUND                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["resultData"] = {}             --玩家数据数组

    --显示用户结算结果
    local playerlist = pack.playerlist

    local fuhao_uid = nil
    local lastChip = 0

    dump(playerlist,"playerlist")
    for k,v in pairs(playerlist) do

        --获取用户id
        local uid = v.uid
        local chips = v.chips
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

    local playerNum =  #playerlist

    if playerNum > 0 then
        --生成界面
        for k,v in ipairs(playerlist) do
            
            ------------------------------------------数据-----------------------------------
            local uid = v.uid
            local photo_url = v.portrait
            local sex = v.sex
            local nickName = v.nickName
            local chips = v.chips

            -------------------------------------------界面-------------------------------------------
            nickName = require("hall.GameCommon"):formatNick(nickName, 7)
            
            if GAME_ROUND == 0 and chips == -20000 then
                chips = 0
            end

            local p1 = {}             --玩家数据实体
            p1["nick"] = nickName         --昵称
            p1["uid"] = uid         --uid
            p1["icon_url"] = photo_url  --头像链接
            p1["sex"] = 1               --性别

            if uid == USER_INFO["group_owner"] then
                p1["isRoomOwer"] = 1        --是否为房主，1是，非1或不填不是
            end

            if uid == fuhao_uid then
                p1["isWinner"] = 1          --是否为赢家，1是，非1或不填不是
            end

            if chips > 0 then
                p1["total"] = "+" .. chips
            elseif  chips < 0 then
                p1["total"] = tostring(chips)
            end

            table.insert(data["resultData"], p1)

        end

    end

    require(GameResultScene_filePath):showScene(data, backHall_action, share_action)

    local GameResult = SCENENOW["scene"]:getChildByName("gameresultScene")
    if  GameResult then
        GameResult:setVisible(false)
    end

end

return ddzSettings