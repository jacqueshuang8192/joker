local GroupEndingLayer = class("GroupEndingLayer")

--显示一局结算的结算界面
function GroupEndingLayer:showGroupResult(pack)
	local data = {}
    data["resultSceneType"] = 1      --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = USER_INFO["invote_code"]      --房间号
    data["fenchang"] = BASE_CHIP            --分场
    data["round"] = ZZMJ_ROUND--.."/"..GROUP_TOTAL_ROUND                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data["resultData"] = {}             --玩家数据数组

    for _, user_info in pairs(pack.playerlist) do
        local user_result = {}             --玩家数据实体
        user_result["nick"] = user_info.nick_name        --昵称
        user_result["uid"] = user_info.uid        --uid
        user_result["icon_url"] = user_info.photo_url    --头像链接
        user_result["sex"] = user_info.sex              --性别
        user_result["isRoomOwer"] = (tonumber(USER_INFO["group_owner"]) == user_info.uid and 1) or 0 --是否为房主，1是，非1或不填不是
        if user_info.chips > 0 then
            user_result["isWinner"] = 1         --是否为赢家，1是，非1或不填不是
        else
            user_result["isWinner"] = 0
        end
        user_result["total"] = user_info.chips     --总输赢分

        user_result["gameDetail"] = {}       --游戏详情数组

        local gameDetail1 = {}           --游戏详情实体
        gameDetail1["showName"] = "自摸次数"   --展示名
        gameDetail1["value"] = user_info.zimo or 0         --值

        local gameDetail2 = {}
        gameDetail2["showName"] = "接炮次数"
        gameDetail2["value"] = user_info.jiepao or 0

        local gameDetail3 = {}
        gameDetail3["showName"] = "点炮次数"
        gameDetail3["value"] = user_info.dianpao or 0

        local gameDetail4 = {}
        gameDetail4["showName"] = "angang"
        gameDetail4["value"] = user_info.angang or 0

        local gameDetail5 = {}
        gameDetail5["showName"] = "明杠"
        gameDetail5["value"] = user_info.minggang or 0

        table.insert(user_result["gameDetail"], gameDetail1)
        table.insert(user_result["gameDetail"], gameDetail2)
        table.insert(user_result["gameDetail"], gameDetail3)
        table.insert(user_result["gameDetail"], gameDetail4)
        table.insert(user_result["gameDetail"], gameDetail5)
        table.insert(data["resultData"], user_result)
    end

    --返回大厅按钮点击事件
    local backHall_action = function(sender,event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        elseif event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        elseif event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            HEART_BEAT_TID = 0
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
        end
    end

    --分享按钮点击事件
    local share_action = function(sender,event)
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        elseif event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        elseif event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            --通知APP分享结果
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
            
            -- if device.platform == "android" then
            --     require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
            -- elseif device.platform ~= "windows" then
            --     require("hall.common.ShareLayer"):shareGroupResultForIOS()
            -- end
        end
    end

    require(GameResultScene_filePath):showScene(data, backHall_action, share_action)
end

return GroupEndingLayer