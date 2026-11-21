--
-- Author: zhanghongpeng	
-- Date: 2017-06-06 15:40:10
--
local NiuNiuUtils = class("NiuNiuUtils")

-- --显示组局总结果 5100   
-- function NiuNiuUtils:showResult(pack)

--     --去掉提示弹框
--     local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
--     if layer_tips then
--         layer_tips:removeSelf()
--     end

--     --获取总结算界面
--     local s = cc.CSLoader:createNode(TpackageName .. "/csb/GroupEnding.csb")
--     s:setName("GameResult")
--     s:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH)
    
--     local winColor = cc.c3b(0xFF,0xFF,0x00)
--     local loseColor =  cc.c3b(0xFF,0x00,0x00)

--     SCENENOW["scene"]:addChild(s,999)

--     s:setVisible(false)
--     -- SCENENOW["scene"]:performWithDelay(function()
--     --     s:setVisible(true)
--     -- end,6)

--     HAS_RECEIVE_GROUP_RESULT = true

--     -- if bm.isDisbandSuccess == true then    --通过解散获得的组局排行榜（马上显示）
--     --    s:setVisible(true)
--     --    bm.isDisbandSuccess = false
--     -- end

--     --退出按钮（当前组局结算，返回到大厅）
--     local btn_exit = s:getChildByName("btn_exit")
--     btn_exit:addTouchEventListener(
--         function(sender,event)

            -- --触摸开始
            -- if event == TOUCH_EVENT_BEGAN then
            --     sender:setScale(0.9)
            -- end

            -- --触摸取消
            -- if event == TOUCH_EVENT_CANCELED then
            --     sender:setScale(1.0)
            -- end

--             --触摸结束
--             if event == TOUCH_EVENT_ENDED then
    
                  -- sender:setScale(1.0)
--                 --移除录音按钮
--                 require("hall.VoiceRecord.VoiceRecordView"):removeView()
             
--                 if  SCENENOW["scene"].initData() then
--                     SCENENOW["scene"]:initData("release")
--                 end
                
--                 require(TpackageName..".NiuNiuUtils"):returnToHall()
                
--             end
--         end)

--     --截屏分享
--     local btn_share = s:getChildByName("btn_share")
--     if isiOSVerify then
--         btn_share:setVisible(false)
--     end
--     btn_share:addTouchEventListener(
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
--         end)
    

--     --结果显示区域
--     local content_sv = s:getChildByName("content_sv")
--     local contentWidth = content_sv:getInnerContainerSize().width
--     local contentHeight = content_sv:getInnerContainerSize().height

--     local single_result_Item_width = contentWidth/6
--     local single_result_Item_height = contentHeight/8

--     local room_id = s:getChildByName("room_id")
--     room_id:setString(USER_INFO["invote_code"])

--     local time_txt = s:getChildByName("time_txt")
--     time_txt:setString(os.date("%H:%M"))

--     local round = s:getChildByName("round")
--     round:setString(GAME_ROUND)

--     local score = s:getChildByName("score")
    
--     --定义结果分项
--     local result_Item = s:getChildByName("group_ending_box") 

--     --显示用户结算结果
--     local playerlist = pack.playerlist

--     local fuhao_uid = nil
--     local lastChip = 0

--     dump(playerlist,"playerlist")
--     for k,v in pairs(playerlist) do

--         --获取用户id
--         local uid = v.uid
--         local chips

--     ------------------------------------------------数据---------------------------------------
--         if  GROUP_MODE == 2 then
--             chips = v.chips
--         else
--             --获取用户信息以及结算情况
--             local user_info = json.decode(v.user_info)
--             local oriChips = user_info.oriChips or initialChip
--             --获取用户分数
--             chips = user_info.chips - oriChips
--         end

--     ---------------------------------------------------------------------------------------------
--         if chips ~= nil then
--             --比较分数
--             if chips > lastChip then
--                 --记录最新点炮数和点炮id
--                 lastChip = chips
--                 fuhao_uid = uid
--             end
--         end
--     end

    
--     dump(fuhao_uid,"fuhao_uid")

--     local result_Item_position_index = 1
     
--     local playerNum =  #playerlist
    
--     local lineCount = 4
--     if playerNum > 10 then
--         lineCount = math.ceil(playerNum/3)
--         content_sv:setInnerContainerSize(cc.size(contentWidth,content_sv:getInnerContainerSize().height/4 * lineCount))
--     end

--     if playerNum > 0 then

--         --生成界面
--         for k,v in ipairs(playerlist) do
            
--             ------------------------------------------数据-----------------------------------
--             local uid = v.uid
--             local photo_url
--             local sex = 1
--             local nick_name
--             local chips
            
--             if GROUP_MODE == 2 then
--                 photo_url = v.portrait
--                 nick_name = v.nickName
--                 chips  = v.chips
--             else
--                 local user_info = json.decode(v.user_info)

--                 photo_url = user_info.photo_url
--                 nick_name = user_info.nick_name
--                 sex = user_info.sex

--                 local oriChips = user_info.oriChips or initialChip
--                 chips = user_info.chips - oriChips
--             end

--             -------------------------------------------界面-------------------------------------------
                
--             local result_Item = result_Item:clone()
--             content_sv:addChild(result_Item)
            
--             local group_ending_winer = result_Item:getChildByName("group_ending_winer")

--             if playerNum <= 10 then

--                 if  uid == fuhao_uid then
--                     group_ending_winer:setVisible(true)
--                     local x = 3 * single_result_Item_width 
--                     local y = 7 * single_result_Item_height 
--                     result_Item:setPosition(cc.p(x,y))
--                 else
--                     group_ending_winer:setVisible(false)
--                     local x = contentWidth / 2 - (2 - math.ceil(result_Item_position_index % 3.01)) * 400
--                     dump(x,"游戏框位置"..k)
--                     -- local x = (math.ceil(result_Item_position_index % 3.01) * 2 - 1) * single_result_Item_width 
--                     local y = (7 - math.ceil(result_Item_position_index/3.01)* 2) * single_result_Item_height    
                    
--                     result_Item:setPosition(cc.p(x,y))
--                     result_Item_position_index = result_Item_position_index + 1
--                 end

--             else
                
--                 if  uid == fuhao_uid then
--                     group_ending_winer:setVisible(true)
--                 else
--                     group_ending_winer:setVisible(false)
--                 end

--                 local x = (math.ceil(result_Item_position_index % 3.01) * 2 - 1) * single_result_Item_width 
--                 local y = ((lineCount*2 + 1) - math.ceil(result_Item_position_index/3.01)* 2) * single_result_Item_height  
--                 result_Item_position_index = result_Item_position_index + 1
--                 result_Item:setPosition(cc.p(x,y))

--             end

--             --用户头像
--             local head_im = result_Item:getChildByName("head_im")
--             require("hall.GameCommon"):getUserHead(photo_url, uid, sex, head_im, head_im:getContentSize().width, false, nick_name)

--             --用户昵称
--             local nick_txt = result_Item:getChildByName("nick_txt")
         
--             local namenick = ""
--             if  NIUNIU_USERINFO_TABLE[uid] then
--                 namenick = NIUNIU_USERINFO_TABLE[uid].nick or "未知昵称"
--                 namenick = require("hall.GameCommon"):formatNick(namenick, 7)
--             end

--             nick_txt:setString(namenick)

--             --用户id
--             local id_txt = result_Item:getChildByName("id_txt")
--             id_txt:setString("ID:" .. tostring(uid))
            
--             if GAME_ROUND == 0 and chips == -20000 then
--                 chips = 0
--             end

--             local score_txt = result_Item:getChildByName("score_txt")

--             if  chips >= 0 then
--                score_txt:setTextColor(winColor)
--             else
--                score_txt:setTextColor(loseColor)
--             end  
            
--             score_txt:setString(tostring(chips))

--             if  uid == USER_INFO["uid"] then
--                 score:setString(tostring(chips))
--             end

--         end

--     end

-- end

--显示组局总结果 5100   
function NiuNiuUtils:showResult(pack)

    for k,v in pairs(pack.playerlist) do
        NIUNIU_USERINFO_TABLE[v.uid].MatchScore = v.score / 100 or 0
    end

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    local layer_tips_1 = SCENENOW["scene"]:getChildByName("DisbandLayer_tips")
    if layer_tips_1 then
        layer_tips_1:clearState()
        layer_tips_1.secondSchedulerID = nil
        layer_tips_1:removeSelf()
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
            --移除录音按钮
            require("hall.VoiceRecord.VoiceRecordView"):removeView()
            
            require(TpackageName..".NiuNiuUtils"):returnToHall()

            if  SCENENOW["scene"].initData then
                SCENENOW["scene"]:initData("release")
            end
            
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
            local paras = {}
            paras["showType"] = 2;
            paras["desc"] =  USER_INFO["gameConfigMsg"]
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
    end

    --changed by zzy 2019-5-28 10:46 总结算界面
    local s = cc.CSLoader:createNode(TpackageName .. "/csb/GameEnd.csb")
    s:setName("gameresultScene")
    s:setScale(SCREEN_WIDTH/1920,SCREEN_HEIGHT/1080)

    local s2 = s:getChildByName("bg2")
    -- s2:setScale(SCREEN_WIDTH/1280*1920/1280,SCREEN_HEIGHT/960*1080/960)

    
    local winColor = cc.c3b(0xFF,0xFF,0x00)
    local loseColor =  cc.c3b(0xFF,0x00,0x00)

    SCENENOW["scene"]:addChild(s,999999)

    s:setVisible(false)

    HAS_RECEIVE_GROUP_RESULT = true

    --退出按钮（当前组局结算，返回到大厅）
    local btn_exit = s:getChildByName("btn_return")
    btn_exit:addTouchEventListener(
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
                --移除录音按钮
                require("hall.VoiceRecord.VoiceRecordView"):removeView()
             
                if  SCENENOW["scene"].initData() then
                    SCENENOW["scene"]:initData("release")
                end
                
                require(TpackageName..".NiuNiuUtils"):returnToHall()
                
            end
        end)

    --截屏分享
    local btn_share = s:getChildByName("btn_share")
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
                paras["desc"] =  USER_INFO["gameConfigMsg"]
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
    
    local playInfoArr = {}
    for i=1,12 do
        local playInfo = {}
        local itemPlayer = s2:getChildByName("v"..i)
        itemPlayer:setVisible(false)
        local _headImg = itemPlayer:getChildByName("img_head")
        local _winImg = itemPlayer:getChildByName("img_win")
        local _name = itemPlayer:getChildByName("text_name")
        local _id = itemPlayer:getChildByName("text_id")
        local _score = itemPlayer:getChildByName("text_score")
        playInfo._headImg = _headImg
        playInfo._winImg = _winImg
        playInfo._name = _name
        playInfo._id = _id
        playInfo._score = _score
        playInfo._itemPlayer = itemPlayer
        playInfoArr[i] = playInfo
    end

    local tempIndex = 1
    for k,v in pairs(NIUNIU_USERINFO_TABLE) do
        playInfoArr[tempIndex]._itemPlayer:setVisible(true)
        require("hall.GameCommon"):getUserHead(v.icon_url, 0, 1, playInfoArr[tempIndex]._headImg, 52, false)
        local IDSTR = v.uid or ""
        playInfoArr[tempIndex]._id:setString("ID:"..IDSTR)
        playInfoArr[tempIndex]._name:setString(v.nick or "")

        -- local MONEYSTR = v.money or ""
        -- local MONEYSTR = self:getPlayerScore(pack.playerlist,k)
        local MONEYSTR = v.MatchScore or 0
        if MONEYSTR > 0 then
            MONEYSTR = "+"..MONEYSTR
            playInfoArr[tempIndex]._winImg:setVisible(true)
        else
            MONEYSTR = MONEYSTR
            playInfoArr[tempIndex]._winImg:setVisible(false)
        end
        
        playInfoArr[tempIndex]._score:setString(MONEYSTR)

        tempIndex = tempIndex + 1
    end


    -- local data = {}
    -- data["resultSceneType"] = 2       --战绩界面展示选择，1为长条形，2为方块形
    -- data["invote_code"] = USER_INFO["invote_code"]     --房间号
    -- data["fenchang"] = nil            --分场
    -- data["round"] = GAME_ROUND                  --局数
    -- data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    -- data["resultData"] = {}             --玩家数据数组

    -- --显示用户结算结果
    -- local playerlist = pack.playerlist

    -- local fuhao_uid = nil
    -- local lastChip = 0

    -- table.sort(playerlist, function(a,b) return a.chips > b.chips end)

    -- dump(playerlist,"playerlist")
    -- for k,v in ipairs(playerlist) do

    --     --获取用户id
    --     local uid = v.uid
    --     local chips

    -- ------------------------------------------------数据---------------------------------------
    --     if  GROUP_MODE == 2 then
    --         chips = v.chips
    --     else
    --         --获取用户信息以及结算情况
    --         local user_info = json.decode(v.user_info)
    --         local oriChips = user_info.oriChips or initialChip
    --         --获取用户分数
    --         chips = user_info.chips - oriChips
    --     end

    -- ---------------------------------------------------------------------------------------------
    --     if chips ~= nil then
    --         --比较分数
    --         if chips > lastChip then
    --             --记录最新点炮数和点炮id
    --             lastChip = chips
    --             fuhao_uid = uid
    --         end
    --     end
    -- end

    -- local playerNum =  #playerlist

    -- if playerNum > 0 then
    --     --生成界面
    --     for k,v in ipairs(playerlist) do
            
    --         ------------------------------------------数据-----------------------------------
    --         local uid = v.uid
    --         local photo_url
    --         local sex = 1
    --         local nick_name
    --         local chips
            
    --         photo_url = v.portrait
    --         nick_name = v.nickName
    --         chips  = v.chips

    --         -------------------------------------------界面-------------------------------------------

    --         local namenick = ""
    --         if  NIUNIU_USERINFO_TABLE[uid] then
    --             namenick = NIUNIU_USERINFO_TABLE[uid].nick or "未知昵称"
    --             namenick = require("hall.GameCommon"):formatNick(namenick, 7)
    --         end
            
    --         if GAME_ROUND == 0 and chips == -20000 then
    --             chips = 0
    --         end

    --         local p1 = {}             --玩家数据实体
    --         p1["nick"] = namenick         --昵称
    --         p1["uid"] = uid         --uid
    --         p1["icon_url"] = photo_url  --头像链接
    --         p1["sex"] = 1               --性别

    --         if uid == USER_INFO["group_owner"] then
    --             p1["isRoomOwer"] = 1        --是否为房主，1是，非1或不填不是
    --         end

    --         if uid == fuhao_uid then
    --             p1["isWinner"] = 1          --是否为赢家，1是，非1或不填不是
    --         end

    --         if chips > 0 then
    --             p1["total"] = "+" .. chips
    --         elseif  chips < 0 then
    --             p1["total"] = tostring(chips)
    --         end

    --         table.insert(data["resultData"], p1)

    --     end

    -- end

    -- require(GameResultScene_filePath):showScene(data, backHall_action, share_action)

    -- local GameResult = SCENENOW["scene"]:getChildByName("gameresultScene")
    -- if  GameResult then
    --     GameResult:setVisible(false)
    -- end
    
    
end

function NiuNiuUtils:getPlayerScore(data,uid)

    print("=====getPlayerScore======")
    print("=====getPlayerScore======")
    print("=====getPlayerScore======")

    dump(data)
    for k,v in pairs(data) do
        if v.uid == uid then
            return v.score or 0
        end
    end
    return 0
end


function NiuNiuUtils:returnToHall()

    --退出房间，返回大厅
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
    HEART_BEAT_TID = 0

end

--获取当前坐下的玩家数量
function NiuNiuUtils:getPlayerNum()
    
    -- dump(debug.traceback(),"getPlayerNum") 
    local playerNum = 0
    local audienceNum = 0

    for uid,seat_id in pairs(NIUNIU_SEAT_TABLE) do
        if  seat_id >= 0 then
            playerNum = playerNum + 1
        else
            audienceNum = audienceNum + 1
        end
    end

    return playerNum,audienceNum

end

--整理用户数据
function NiuNiuUtils:collectPlayerData(data)
    
    dump(data, "玩家信息数据")

    local info ={}
    local gold = (data.gold / 100) - initialChip

    if  GROUP_MODE == 2 then 
    else
        info= json.decode(data["user_info"])
    end

    --data数据是直接获得的，金币场
    --info协议放在userinfo_json里
    local nick_name =  data.nickName or info.nickName
    -- dump(data.gold,"玩家金币")
    local icon_url = data.portrait or (info.photoUrl or info.icon_url) 
    local sex_num = data.sex or info.sex
    local userInfo = {}

    --头像图片
    userInfo["icon_url"] = icon_url or ""
    --昵称
    userInfo["nick"] = nick_name or ""
    --金币
    userInfo["coins"] = gold or 0   --用户总金币
    --UID
    userInfo["uid"] = data.uid or 0
    --性别
    userInfo["sex"] = sex_num or 0 
    --IP
    userInfo["ip"] = data.ip or "0.0.0.0"

    userInfo["score"] = 0     --用户本局游戏的胜负

    --changed by zzy 2019-5-28
    userInfo["money"] = 0     --用户所有局数金钱的变化

    local uid = data.uid
   
    NIUNIU_USERINFO_TABLE[uid] = userInfo
    NIUNIU_SEAT_TABLE[uid] = data.seat_id --保存用户座位与id映射
    -- PLAYER_HEADS_POSITION_TABLE[uid] = {x = 0, y = 0}
    
    local updateUserInfoData = {}

    if  data.longitude then
        updateUserInfoData["longitude"] = data.longitude
        updateUserInfoData["latitude"] = data.latitude
        updateUserInfoData["invote_code"] = USER_INFO["invote_code"]
    end

    if  data.otherInfo then
        local otherInfo = json.decode(data.otherInfo)
        if otherInfo then
            updateUserInfoData["city"] = otherInfo["city"]
        end
    end

    updateUserInfoData["uid"] = uid
    updateUserInfoData["nickName"] = userInfo["nick"]
    updateUserInfoData["ip"] = data.ip 

    dump(updateUserInfoData,"updateUserInfoData")

    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,updateUserInfoData)

    -- if  data.seat_id >= 0 then
    --     local user_if_outline = data.user_if_outline
    --     self:showPlayer(uid,data.seat_id,userInfo,user_if_outline)
    -- end


end

local Lottery = require(TpackageName .. ".lottery.Lottery")

--显示玩家头像
function NiuNiuUtils:showPlayer(uid,seat_id,userInfo,user_if_outline)

    NIUNIU_SEAT_TABLE[uid] = seat_id --保存用户座位与id映射
    NIUNIU_UID_TABLE[seat_id] = uid  --保存用户id与座位映射

    
    if  seat_id <= -1 then
        return
    end

    Lottery:showPlaneItemChange(seat_id, "sitDown", userInfo)

    local playerType = self:getPlayerTypeBySeatId(seat_id)
    playerType = NiuNiuUtils:getViewChairId(playerType)



    print("======playerType====",playerType)
    if playerType > 0  then
        GamePlaneOperator:getSeatBtnPlane(playerType):setVisible(false)
        GamePlaneOperator:getPlayerPlane(playerType):setVisible(true)
    end

   
    NIUNIU_PLAYERTYPE_TABLE[uid] = playerType
    NIUNIU_PLAYERTYPE_TABLE_BYSEAT[seat_id] = playerType

    print("===显示玩家头像==showPlayer=seat_id==playerType==",seat_id,playerType)
    
    -----------------------------------------------------------------    
    local head = GamePlaneOperator:showPlayerInfo(playerType,userInfo)

    if  isGoldGame == 1 and  seat_id == 0 then   --房卡场情况下，座位号为0的人是房主
        GamePlaneOperator:showHeadSymbol(playerType,"owner",true)
    else
        GamePlaneOperator:showHeadSymbol(playerType,"owner",false)
    end

    GamePlaneOperator:setReadyStatus(playerType,false)  --重置准备状态

    if  GAME_STATE == GAME_STATUS_STOP and  USERS_READY_STATE[uid] == 1 then
        GamePlaneOperator:setReadyStatus(playerType)
    end

    if  user_if_outline == 0 then
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",true)
    else
        GamePlaneOperator:showHeadSymbol(playerType,"disconnect",false)
    end

    --将head的坐标映射到世界坐标系中去
    local   worldpoint = (head:getParent()):convertToWorldSpace(head:getPosition()) --这样写是为了贴近函数的原始用法
    
    PLAYER_HEADS_TABLE[uid] = head
    dump( worldpoint , "showPlayer_worldpoint" )
    PLAYER_HEADS_POSITION_TABLE[uid] = worldpoint

    -- require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(userInfo["uid"], worldpoint)
    
    --新录音位置显示
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(userInfo["uid"], worldpoint)

    -- print("===换位只单个玩家的分数变化！！！===")
    -- dump(userInfo)
    GamePlaneOperator:setCoin(playerType,userInfo.coins)


end 


--重新显示游戏桌面（坐下之后）
function NiuNiuUtils:relocatePlayer()

    GamePlaneOperator:relocate("player")

    local drawCount = 0

    for  uid,seat_id in pairs(NIUNIU_SEAT_TABLE) do      
        if seat_id >= 0 then   
            drawCount = drawCount + 1
            -- SCENENOW["scene"]:performWithDelay(function()
                local userInfo =  NIUNIU_USERINFO_TABLE[uid]
                self:showPlayer(uid,seat_id,userInfo)     
            -- end,1/30 * drawCount)
        end
    end

end

function NiuNiuUtils:getLocationFromDevice()

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

end

function NiuNiuUtils:getPlayerTypeBySeatId(player_seat_id)
    -- return player_seat_id
    -- local playNum = TOTAL_PLAYERNUM
    -- if player_seat_id <= -1 then
    --     return 
    -- end

    -- -- dump(RELATIVE_SEAT_ID,"RELATIVE_SEAT_ID")

    -- --相对定位座位号是显示“我”的位置上坐的人的座位号，如果我进去没有坐下的话，“我”的座位上不一定是我，所以需要这样一个变量
    -- if  RELATIVE_SEAT_ID ~= 0 then  --我坐下且服务器座位号不为0的情况下
    --     local playerType = 2
    --     for seat_id = 0, playNum - 1 do  --遍历座位表

    --         -- dump(seat_id,"getPlayerTypeBySeatId")
    --         -- dump(player_seat_id,"getPlayerTypeBy_player_seat_id")

    --         --如果该玩家座位号不等于相对定位座位号，且遇到相对座位号的话要跳过
    --         if  player_seat_id ~= RELATIVE_SEAT_ID and seat_id ~= RELATIVE_SEAT_ID then  
                
    --             if  seat_id == player_seat_id then  --分配前端座位逻辑：优先把靠前的座位号分发给服务器绝对座位号靠前的玩家
    --                 -- dump(playerType,"getPlayerTypeBySeatId_playerType")
    --                 return playerType
    --             end

    --             playerType = playerType + 1

    --         elseif player_seat_id == RELATIVE_SEAT_ID then

    --             return CARD_PLAYERTYPE_MY

    --         end

    --     end
    -- else
    --     return player_seat_id + 1
    -- end
    return player_seat_id

end

function NiuNiuUtils:getViewChairId(__seatId)
    print("==777777===getViewChairId===__seatId=MY_SEAT_ID=",__seatId,MY_SEAT_ID)
    if __seatId == nil or  __seatId < 0 then
        print("chairId is error!!!")
        return  -1
    end
    --转换椅子
    local wViewId = 0
    if __seatId == MY_SEAT_ID then
        wViewId = 1
        return wViewId
    end
    local wMeViewId = 1
    wViewId =  wMeViewId + MY_SEAT_ID - __seatId + TOTAL_PLAYERNUM
    if wViewId > TOTAL_PLAYERNUM then
        wViewId = wViewId - TOTAL_PLAYERNUM
    elseif wViewId == TOTAL_PLAYERNUM then
        wViewId = TOTAL_PLAYERNUM
    else
        wViewId = wViewId % TOTAL_PLAYERNUM
    end
    return wViewId
end

return  NiuNiuUtils