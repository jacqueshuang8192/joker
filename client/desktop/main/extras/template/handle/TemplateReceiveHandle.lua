local hallHandle = require("hall.HallHandle")
-- local GamePlaneOperator = require(TpackageName .. ".operator.GamePlaneOperator")

local PROTOCOL = import(TpackageName .. ".handle.TemplateProtocol")

local TemplateReceiveHandle  = class("TemplateReceiveHandle", hallHandle)
local   StakeScene = require(TpackageName .. ".StakeScene")
-- local   RoundEnding = require(TpackageName .. ".RoundEnding")
local LowerScoreScene = require(TpackageName .. ".LowerScoreScene")
local run_scene_name = TpackageName..".gameScene"

--local ------Lottery = require(TpackageName .. ".------Lottery")

function TemplateReceiveHandle:ctor()

	TemplateReceiveHandle.super.ctor(self);

	local func_ = {

        --登录房间成功 1007
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, TemplateReceiveHandle.SVR_LOGIN_ROOM)},
        --进入房间失败
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, TemplateReceiveHandle.SVR_LOGIN_ROOM_FAIL)},

        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, TemplateReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户退出房间 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, TemplateReceiveHandle.BROADCAST_USER_STAND_UP)},

        --广播其他用户登录桌子 100D
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, TemplateReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},

        --广播用户退出房间 100E
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, TemplateReceiveHandle.SVR_QUIT_ROOM)},
        --广播用户退出房间 1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, TemplateReceiveHandle.BROADCAST_USER_QUIT_ROOM)},
 
        --用户退出房间成功（自己）
        [PROTOCOL.SVR_QUICK_SUC]            = {handler(self, TemplateReceiveHandle.SVR_QUICK_SUC)},

        --0x2001    --广播用户准备
        [PROTOCOL.SERVER_READYNOW_ROOM]            = {handler(self, TemplateReceiveHandle.SERVER_READYNOW_ROOM)},

        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, TemplateReceiveHandle.BROADCAST_ERROR_TIPS)},


         --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, TemplateReceiveHandle.SVR_CHARGE_BROADCAST)},

    	--6008  单局结算（阶段广播）
    	[PROTOCOL.SVR_SETTLEMENT_BROADCAST]       = {handler(self, TemplateReceiveHandle.SVR_SETTLEMENT_BROADCAST)},
    	--5100，广播总结算
    	[PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, TemplateReceiveHandle.SVR_GROUP_BILLBOARD)},
    	--广播当前回合
    	[PROTOCOL.SVR_GROUP_TIME] = {handler(self, TemplateReceiveHandle.SVR_GROUP_TIME)},
        --请求带控返回
        [PROTOCOL.SERVER_CMD_REQ_TEST] = {handler(self, TemplateReceiveHandle.SERVER_CMD_REQ_TEST)},
        --请求牌值返回
    	[PROTOCOL.SERVER_CMD_TEST] = {handler(self, TemplateReceiveHandle.SERVER_CMD_TEST)},

        --请求录纸返回
        [PROTOCOL.SERVER_CMD_RECORD_PAPER] = {handler(self, TemplateReceiveHandle.SERVER_CMD_RECORD_PAPER)},

    	--解散相关
    	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, TemplateReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, TemplateReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, TemplateReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, TemplateReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, TemplateReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

    	--文字聊天相关
     	--[PROTOCOL.SVR_MSG_FACE]     = {handler(self, TemplateReceiveHandle.SVR_MSG_FACE)},
     	--接收服务器返回的语音表情视频文字 0214
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, TemplateReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
        --接收服务器返回801
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, TemplateReceiveHandle.SERVER_CMD_MESSAGE)},

        -- 0x110A   --- 出牌时间
        [PROTOCOL.SERVER_BROADCAST_START_OUT_CARD] = {handler(self, TemplateReceiveHandle.SERVER_BROADCAST_START_OUT_CARD)},
        -- --接收IP信息 106A
        -- [PROTOCOL.BROADCAST_USER_IP] = {handler(self, TemplateReceiveHandle.BROADCAST_USER_IP)},

        [PROTOCOL.SERVER_NOTIFY_RESULT] = {handler(self, TemplateReceiveHandle.SERVER_NOTIFY_RESULT)},
        [PROTOCOL.SERVER_BROADCAST_START_YA] = {handler(self,TemplateReceiveHandle.SERVER_BROADCAST_START_YA)},
         -- 0x1101   --- 广播押注
        [PROTOCOL.SERVER_BROADCAST_YA] = {handler(self,TemplateReceiveHandle.SERVER_BROADCAST_YA)},
        --0x1102
        [PROTOCOL.SERVER_BROADCAST_CARD] = {handler(self,TemplateReceiveHandle.SERVER_BROADCAST_CARD)},
        [PROTOCOL.SERVER_BROADCAST_OUT_CARD] = {handler(self,TemplateReceiveHandle.SERVER_BROADCAST_OUT_CARD)},
        --0x1104   --- 开牌
        [PROTOCOL.SERVER_BROADCAST_OPEN_CARD] = {handler(self,TemplateReceiveHandle.SERVER_BROADCAST_OPEN_CARD)},

        [PROTOCOL.SERVER_BROADCAST_GIVE_COINS] = {handler(self,TemplateReceiveHandle.SERVER_BROADCAST_GIVE_COINS)},

        --显示开始游戏按钮显示开始游戏按钮 0x2006 
        [PROTOCOL.SERVER_BROADCAST_START_GAME] = {handler(self,TemplateReceiveHandle.SERVER_BROADCAST_START_GAME)},
    }
    table.merge(self.func_, func_)
    
end


--协议返回数据接收


--协议返回数据接收
function TemplateReceiveHandle:callFunc(pack)
--[[    if SCENENOW["name"] ~= run_scene_name then
        print("当前场景不是本场景！")
        return
    end]]
	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end





--显示开始游戏按钮 0x2006 
function TemplateReceiveHandle:SERVER_BROADCAST_START_GAME(pack)

end

--进入房间失败
function TemplateReceiveHandle:SVR_LOGIN_ROOM_FAIL(pack)

    dump(pack, "-----进入房间失败-----")

    local tbErrorCode = {
        [0] = "成功创建新连接",
        [1] = "重连成功",
        [2] = "成功踢其他玩家",
        [3] = "玩家密匙错误",
        [4] = "数据库连接错误",
        [5] = "无此房间",
        [6] = "玩家登录房间错误",
        [7] = "房间人数已满", --"无房间分配",
        [8] = "没有空桌子",
        [9] = "玩家余额不足",
        [10] = "未知错误",
        [14] = "数据库缓存出错",
        [15] = "对不起，您不是VIP",
        [13] = "您当前不能进低分场",
        [12] = "相同IP",
        [16] = "密码错误",
        [17] = "要求携带钻石不足",
        [18] = "游戏已开始，无法加入游戏"
    }

    if  tbErrorCode[pack.errorCode] then
        if pack.errorCode == 18 or pack.errorCode == 7 or pack.errorCode == 5 then
            --require("hall.GameTips"):showTips("提示", "tohall", 1, tbErrorCode[pack.errorCode])
        -- elseif  pack.errorCode == 7 or pack.errorCode == 5 then

             local exitFunc = function()
                 require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
             end

             require("hall.GameTips"):showTips("提示", "", 2, tbErrorCode[pack.errorCode],nil,exitFunc)
        else
            require("hall.GameTips"):showTips("提示", "", 1, tbErrorCode[pack.errorCode]) 
        end
    else
        require("hall.GameTips"):showTips("提示", "", 1, "未知的错误") 
    end

end


--登录房间 1007
function TemplateReceiveHandle:SVR_LOGIN_ROOM(pack)
    USER_INFO["activity_id"] = pack.activityId
    USER_INFO["invote_code"] = pack.inviteCode
    GAME_STATE    =  pack.tableStatus
    HEART_BEAT_TID = USER_INFO["tid"]

end

---------------------------------------------------------------------------------------------------------------

--广播用户登录桌子 100D   其他用户进入房间
function  TemplateReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)


end

--广播自己退出 1008   断线重连
function  TemplateReceiveHandle:SVR_QUICK_SUC(pack)
   --SCENENOW["scene"]:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end

--广播玩家退出返回（断线） 100E
function TemplateReceiveHandle:SVR_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回100E------")
    
    local playerType = TEMPLATE_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        --GamePlaneOperator:showHeadSymbol(playerType,"disconnect",true)
    end

end


--广播用户坐下 1031   其他用户进入房间
function  TemplateReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    
    TEMPLATE_SEAT_TABLE[pack.uid] = pack.seat --保存用户座位与id映射
    

end

--广播玩家站起 1032
function TemplateReceiveHandle:BROADCAST_USER_STAND_UP(pack)

    dump(pack, "------广播玩家站起1032------")
    local playerType =  TEMPLATE_PLAYERTYPE_TABLE[pack.uid]
    if  playerType then
        GamePlaneOperator:removePlayer(playerType)
    end

    TEMPLATE_SEAT_TABLE[pack.uid] = -1
    TEMPLATE_PLAYERTYPE_TABLE[pack.uid] = nil

end

--广播玩家退出返回（离开房间） 1033   如果是大结算的话不要直接退出
function TemplateReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回1033------")

end

--5001
function TemplateReceiveHandle:BROADCAST_ERROR_TIPS(pack)

    dump(pack, "-----返回错误提示5001-----")
    
    local errorCode = pack.errorCode

    local tbErrorCode = {
        [1]  = "操作无效",
        [10] = "您正在游戏中",
        [11] = "您已经坐下了",
        [12] = "您已经准备过了",
        [13] = "您还没准备",
        [14] = "您已经坐下了",
        [15] = "您正在围观中",
        [16] = "桌子已经满啦",
        [17] = "玩家不存在",
        [18] = "您积分不够啦，请充值",
        [20] = "游戏未开始",
        [20] = "游戏正在进行中，请稍后...在做操作",
    }
    
    if  errorCode == 18 then
        SCENENOW["scene"]:performWithDelay(function()

            --去掉提示弹框
            local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
            if  layer_tips then
                layer_tips:removeSelf()
            end

            if not isiOSVerify then
                SCENENOW["scene"]:requestCharge()
            end

         end,1.5)    
    end
    
    dump(tbErrorCode[errorCode],"错误提示")
    
    if tbErrorCode[errorCode] then
        viewMgr:showTip({text = tbErrorCode[errorCode]})
        -- require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode]) 
    else
        viewMgr:showTip({text = "未知的错误"})
        -- require("hall.GameTips"):showTips("提示", "", 3, "未知的错误") 
    end

end



--5101  组局时长
function TemplateReceiveHandle:SVR_GROUP_TIME(pack)
    dump(pack, "SVR_GROUP_TIME")
    GAME_ROUND = pack.round
    GAME_TOTAL_ROUND = pack.round_total or 999

end

 --0x2001    --广播用户准备
function TemplateReceiveHandle:SERVER_READYNOW_ROOM(pack)
    dump(pack, "-------0x2001    --广播用户准备------")
end


--结算6008  单局结算
function TemplateReceiveHandle:SVR_SETTLEMENT_BROADCAST(pack)

    dump(pack, "---模板-----")
    GAME_STATE  = GAME_STATUS_STOP

end

--组局排行榜 5100
function TemplateReceiveHandle:SVR_GROUP_BILLBOARD(pack)

    dump(pack, "-----模板-----")

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end
    local data = {}
    data["resultSceneType"] = 2      --战绩界面展示选择，1为长条形，2为方块形
    data["invote_code"] = USER_INFO["invote_code"]      --房间号
    data["fenchang"] = ""            --分场
    data["round"] = GAME_ROUND --.."/"..GROUP_TOTAL_ROUND                  --局数
    data["date"] = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
    data['activity_id'] = USER_INFO["activity_id"];
    data["resultData"] = {}

    for uid, user_info in pairs(pack.playerlist) do
        local user_result = {}             --玩家数据实体
        user_result["nick"] = user_info["nickName"]        --昵称
        user_result["uid"] = user_info.uid        --uid
        user_result["icon_url"] = user_info["portrait"]        --头像链接
        user_result["sex"] = user_info["sex"]               --性别
        user_result["isRoomOwer"] = 0        --是否为房主，1是，非1或不填不是
        if user_info["chips"] > 0 then
            user_result["isWinner"] = 1         --是否为赢家，1是，非1或不填不是
        else
            user_result["isWinner"] = 0
        end
        user_result["total"] = user_info["chips"]        --总输赢分


        user_result["gameDetail"] = {}       --游戏详情数组
        local gameDetail1 = {}           --游戏详情实体
        gameDetail1["showName"] = "赢的次数"   --展示名
        gameDetail1["value"] = user_info["win_num"] or 0         --值

        local gameDetail2 = {}
        gameDetail2["showName"] = "输的次数"
        gameDetail2["value"] = user_info["lose_num"] or 0

        table.insert(user_result["gameDetail"], gameDetail1)
        table.insert(user_result["gameDetail"], gameDetail2)
        table.insert(data["resultData"], user_result)
    end
    --返回大厅按钮点击事件
    local backHall_action = function(sender,event)
            USER_INFO["gameConfig"] = ""
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
    end

    --再来一局
    local extend_action = function(sender,event)
        require("hall.groudgamemanager"):extend_freegame(USER_INFO["uid"], USER_INFO["activity_id"])
    end

    --分享按钮点击事件
    local share_action = function(sender,event)
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

    end
    -- require(GameResultScene_filePath):showScene(data, backHall_action, share_action)
    require("hall.settlement.settlement").new(data, backHall_action, share_action,nil,extend_action)

    -- SCENENOW["scene"]:performWithDelay(function()
    --     SCENENOW["scene"]:initData("release")
    -- end,5)

end


--------------------------------------周边功能-----------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function TemplateReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    --dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--广播当前组局解散情况
function TemplateReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

    dump(pack, "-----广播当前组局解散情况-----")
    dump(TEMPLATE_USERINFO_TABLE, "-----广播当前房间情况-----")
	if g_isWatch == 0 then
		return
	end

    local applyId = pack.applyId
    local agreeNum = pack.agreeNum
    local agreeMember_arr = pack.agreeMember_arr
    
    local disband_table = {}
   
    --申请解散者信息
    if applyId == USER_INFO["uid"] then
        local player_table = {}
        player_table["playerName"] = "我"
        player_table["state"] = "申请"
        table.insert(disband_table, player_table)
    else
        local player_table = {}
        local applyer_info = TEMPLATE_USERINFO_TABLE[applyId]
        dump(applyer_info, "-----广播当前房间情况applyer_info-----")
        if applyer_info ~= nil then
            local nickName = applyer_info.nick or ""
            if nickName ~= nil then
                player_table["playerName"] = nickName 
            else
                player_table["playerName"] = tostring(applyId)
            end
        else
            player_table["playerName"] = tostring(applyId)
        end

        player_table["state"] = "申请"

        table.insert(disband_table, player_table)
    end
    
    local isMyAgree = 0
    if applyId ~= USER_INFO["uid"] then
        --假如申请者不是自己，添加自己的选择情况
        if agreeNum > 0 then
            for k,v in pairs(agreeMember_arr) do
                if v == USER_INFO["uid"] then
                    isMyAgree = 1
                    break
                end
            end
        end
        
        local player_table = {}
        player_table["playerName"] = "我"
        
        if isMyAgree == 1 then
            player_table["state"] = "同意"
        else
            player_table["state"] = "等待选择"
        end

        player_table["icon"] = USER_INFO["icon_url"]

        table.insert(disband_table, player_table)

    end

    --显示其他人情况
    for k,v in pairs(TEMPLATE_USERINFO_TABLE) do
        dump(v, "-----显示其他人情况-----")
        local uid = v.uid
        --排除掉申请者，申请者不需要显示到这里
        if uid ~= applyId and uid ~= USER_INFO["uid"] then

            --记录当前用户是否已经同意
            local isAgree = 0
            if agreeNum > 0 then
                for k,v in pairs(agreeMember_arr) do
                    if uid == v then
                        --当前用户已经同意
                        isAgree = 1
                        break
                    end
                end
            end

            --显示当前用户情况
            local player_table = {}
            local nickName = v.nick
            if nickName ~= nil then

                player_table["playerName"] = nickName

                if isAgree == 1 then
                    player_table["state"] = "同意"
                else
                    player_table["state"] = "等待选择"
                end

                player_table["icon"] = v.icon_url 

                table.insert(disband_table, player_table)

            end

        end
    end

    local function agree_disband(value)
        TemplateSendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
    end

    if applyId == USER_INFO["uid"] then
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
            require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
        else
            require("hall.GameTips"):showDisbandNewTips("提示", "new_request_disbandGroup", 1, disband_table,agree_disband)
        end
    end
    

end

--广播桌子用户请求解散组局
function TemplateReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function TemplateReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function TemplateReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    --dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        local nickName = TEMPLATE_USERINFO_TABLE[rejectId].nick or "路人甲"
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2,  nickName.. "拒绝解散房间")
    end

end

--聊天
function TemplateReceiveHandle:SVR_MSG_FACE(pack)

    local faceUI = SCENENOW["scene"]:getChildByName("faceUI")

    local sex = 1

    if TEMPLATE_USERINFO_TABLE[pack.uid] then
       sex = TEMPLATE_USERINFO_TABLE[pack.uid].sex or 0
    end

    local isLeft = false

    local node_head = PLAYER_HEADS_TABLE[pack.uid]
    if  tonumber(sex) >= 0 and node_head then
        faceUI:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, false)
    end

end
-----------------------------------------------------------------------------------------------------------------------------
function TemplateReceiveHandle:showTextMessage(pack)

    local s= SCENENOW["scene"]:getChildByName("faceUI")
    
    local sex = 1

    if TEMPLATE_USERINFO_TABLE[pack.uid] then
       sex = TEMPLATE_USERINFO_TABLE[pack.uid].sex or 0
    end

    local node_head = PLAYER_HEADS_TABLE[pack.uid]

    s:showGetText(pack.uid,pack.textMessage,tonumber(sex),node_head, false)  
end


function TemplateReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1
    
    ---------------------------------不同游戏需修改的部分----------------------------
    -- --通过UID获取seat
    -- local seat_from = USERID2SEAT[uid_from] or 2
    -- local seat_to =  USERID2SEAT[seat_to] or 0

    --制定座位号对应的动画播放起始和结束的大概位置
    ------------------------------------------------------------------------------------
    local playerHeadPosition_from = PLAYER_HEADS_POSITION_TABLE[uid_from] or {x=0,y=0}
    local from_x = playerHeadPosition_from.x
    local from_y = playerHeadPosition_from.y
    
    local playerHeadPosition_to = PLAYER_HEADS_POSITION_TABLE[uid_to] or {x=0,y=0}
    local to_x   = playerHeadPosition_to.x
    local to_y   = playerHeadPosition_to.y

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y,to_x,to_y,expressionType)        

end

--接收服务器返回的组局信息
function TemplateReceiveHandle:SERVER_CMD_MESSAGE(pack)

    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    dump(msg, "-----SERVER_CMD_MESSAGE 表情-----")
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= "" then

            if msgType == "expression" then   --表情
                self:showExpression(msg)
            elseif  msgType == "text" then   --文字聊天
                self:showTextMessage(msg)
            elseif msgType == "emoji" then
                local emojiPack = {}
                emojiPack["uid"] = msg.uid
                emojiPack["type"] = msg.id
                self:SVR_MSG_FACE(emojiPack)
            end


            if device.platform == "ios" then
                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                     --通知本地播放录音
                     local arr = {}
                     arr["url"] = msg.url
                     cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    --dump("video", "-----接收服务器返回的组局信息-----")
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")
                end
            else
                if msgType == "voice" then
                    --dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                     --通知本地播放录音
                     local data = {}
                     data["url"] = msg.url
                     local arr = {}
                     table.insert(arr, json.encode(data))
                     cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    --dump("video", "-----接收服务器返回的组局信息-----")
                    local data = {}
                    data["url"] = msg.url
                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVideo", arr, "V")
                end

            end
        end
    end
    
end



-- 0x1101   --- 广播下注
function TemplateReceiveHandle:SERVER_BROADCAST_YA(pack)

end
function TemplateReceiveHandle:SERVER_BROADCAST_START_YA(pack)

    GAME_STATE = GAME_STATUS_YA

end
--发牌时间
function TemplateReceiveHandle:SERVER_BROADCAST_CARD(pack)

    GAME_STATE = GAME_STATUS_SEND_CARD
end

-- 0x1103   -- 广播出牌
function TemplateReceiveHandle:SERVER_BROADCAST_OUT_CARD(pack)
    GAME_STATE = GAME_STATUS_OPEN_CARD
end
--出牌倒计时
function TemplateReceiveHandle:SERVER_BROADCAST_START_OUT_CARD(pack)

    GAME_STATE = GAME_STATUS_OUT_CARD

end
--0x1104   --- 开牌
function TemplateReceiveHandle:SERVER_BROADCAST_OPEN_CARD(pack)  --开牌阶段

    GAME_STATE = GAME_STATUS_OPEN_CARD


end
--个人输赢分
function TemplateReceiveHandle:SERVER_NOTIFY_RESULT(pack)

    GAME_STATE = GAME_STATUS_STOP

    IS_ON_RANKING = true


end
--玩家互相赠送金币
function TemplateReceiveHandle:SERVER_BROADCAST_GIVE_COINS(pack)

end



function TemplateReceiveHandle:SERVER_CMD_REQ_TEST(pack)
    dump(pack,"---------------------------测试1-------------------------------------")
    local count = pack.count
    local testSeats = pack.testSeats
    if count <= 0 or #testSeats <= 0 then
        return
    end

end

function TemplateReceiveHandle:SERVER_CMD_TEST(pack)
    dump(pack,"---------------------------测试2-------------------------------------")
    if pack.errorCode == 0 then
        require("hall.GameTips"):showTips("提示", "", 3, "成功")
    else
        require("hall.GameTips"):showTips("提示", "", 3, "失败")
    end
end





--接收服务器放回的指定用户信息pack111
function TemplateReceiveHandle:SVR_CHARGE_BROADCAST(pack)
   
    local uid = pack.uid
    local playerType = TEMPLATE_PLAYERTYPE_TABLE[uid]
    local userInfo = TEMPLATE_USERINFO_TABLE[uid]
    if not (playerType and userInfo) then return end
    userInfo.gold = userInfo.gold + pack.chargeCoins/100
    -- TemplateUtils:collectPlayerData(userInfo)
    GamePlaneOperator:setCoin(playerType, userInfo.gold)
    dump(pack,"pack111")
end

return TemplateReceiveHandle

--测试性能专用代码
--   local t1 = os.time();
--   for  i =1,10000000  do
--    local TemplateReceiveHandle = math.random(1,4)
--        self:getPlayerPlane(TemplateReceiveHandle)
-- end

-- local t2 = os.time();
-- print(os.difftime(t2, t1),"运行时间");