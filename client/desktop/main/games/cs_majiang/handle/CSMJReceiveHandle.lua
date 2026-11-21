
--加载框架初始化类
require("framework.init")
local gamePlaneOperator = require("cs_majiang.operator.GamePlaneOperator")
local manyouPlaneOperator = require("cs_majiang.operator.ManyouPlaneOperator")
local cardUtils = require("cs_majiang.utils.cardUtils")
--加载大厅请求处理
local hallHandle = require("hall.HallHandle")
local voiceUtils = require("cs_majiang.utils.VoiceUtils")
--大厅套接字请求类
local hallPa = require("hall.HALL_PROTOCOL")
--麻将套接字请求类
local PROTOCOL = import("cs_majiang.handle.CSMJProtocol")
local sendHandle = require("cs_majiang.handle.CSMJSendHandle")
--定义麻将游戏处理类
local CSMJReceiveHandle = class("CSMJReceiveHandle",hallHandle)
local aniUtils = require("cs_majiang.utils.AniUtils")
--定义登录超时时间
local LOGIN_OUT_TIMER = 20
--定义麻将游戏界面名称
local run_scene_name = "cs_majiang.gameScene"
--扣除台费百分数
local percent_base = 0.20

local item_ly_list = {}
local LocaArrayByPlayerType = {}
G_CARDS_4_TING_TB = {} -- @brief[保存开杠操作之后听牌状态时的手牌数据]	@Jhao.

local tbErrorCode = {
    [0] = "成功创建新连接",
    [1] = "无效的操作",
    [5] = "登陆错误",
    [10] = "正在游戏中...",
    [11] = "无效的座位",
    [12] = "您已经准备过了",
    [13] = "请先准备",
    [14] = "您已经坐下",
    [15] = "您已经站起",
    [16] = "桌子已满人",
    [17] = "不存在的用户",
    [18] = "要求携带钻石不足",
    [19] = "已经购买过奖池",
    [20] = "桌子状态不正确",
    [21] = "值超出范围",
    [100] = "战绩不存在",
}

function CSMJReceiveHandle:ctor()

	CSMJReceiveHandle.super.ctor(self);

	--定义麻将游戏请求	
	local  func_ = {
        --录音，表情，文字聊天0x801
        [PROTOCOL.G2H_BROADCAST_SPECIAL_FACE] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_SPECIAL_FACE)},  
		    --广播错误消息0x5001
        [PROTOCOL.G2H_BROADCAST_ERROR_MSG] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_ERROR_MSG)},  
        --广播玩家充值 0x111
        [PROTOCOL.G2H_BROADCAST_ACCOUNT_RECHARGE]       = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_ACCOUNT_RECHARGE)},
        --解散房间失败0x908
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, CSMJReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播当前组局解散情况 0x909
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, CSMJReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户同意解散组局 0x103A
        [PROTOCOL.G2H_BROADCAST_DISSOLVE_GROUP]     = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户拒绝解散组局 0x104A
        [PROTOCOL.G2H_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --广播用户坐下 0x1031
        [PROTOCOL.G2H_BROADCAST_USER_SIT_DOWN] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_USER_SIT_DOWN)},
        --广播用户站起 0x1032
        [PROTOCOL.G2H_BROADCAST_USER_STAND_UP] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_USER_STAND_UP)},
        --广播用户退出房间 0x1033
        [PROTOCOL.G2H_BROADCAST_USER_QUIT_ROOM] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_USER_QUIT_ROOM)},
        --广播用户准备 0x2001
        [PROTOCOL.G2H_BROADCAST_ACCOUNT_READY] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_ACCOUNT_READY)},
        --登陆错误 0x1005
        [PROTOCOL.SVR_ERROR]      = {handler(self, CSMJReceiveHandle.SVR_ERROR)},
        -- 广播用户登录 0x100D
        [PROTOCOL.G2H_BROADCAST_ACCOUNT_LOGIN] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_ACCOUNT_LOGIN)},
        -- 广播用户登出 0x100E
        [PROTOCOL.G2H_BROADCAST_ACCOUNT_LOGOUT] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_ACCOUNT_LOGOUT)},
        -- 给自己发登出成功 0x1008
        [PROTOCOL.G2H_ACCOUNT_LOGIN_SUCCESS] = {handler(self, CSMJReceiveHandle.G2H_ACCOUNT_LOGIN_SUCCESS)},
        --单局结算 0x6008
        [PROTOCOL.G2H_BROADCAST_ROUND_RESULT] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_ROUND_RESULT)}, 
        --总结算 0x5100
        [PROTOCOL.G2H_BROADCAST_GROUP_RESULT]     = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_GROUP_RESULT)},
        --组局局数 0x5101
        [PROTOCOL.G2H_BROADCAST_REFRESH_ROUND] = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_REFRESH_ROUND)},
        --用户登录 0x1007
        [PROTOCOL.G2H_REFRESH_ACCOUNT_LIST]={handler(self, CSMJReceiveHandle.G2H_REFRESH_ACCOUNT_LIST)},
        --广播用户出牌 0x1102
        [PROTOCOL.SVR_SEND_MAJIANG_BROADCAST] = {handler(self, CSMJReceiveHandle.SVR_SEND_MAJIANG_BROADCAST)},
        --广播当前操作玩家ID 0x1103
        [PROTOCOL.SVR_PLAYING_UID_BROADCAST] = {handler(self, CSMJReceiveHandle.SVR_PLAYING_UID_BROADCAST)},
        --广播用户进行了什么操作 0x1104
        [PROTOCOL.SVR_PLAYER_USER_BROADCAST] = {handler(self, CSMJReceiveHandle.SVR_PLAYER_USER_BROADCAST)},
        --广播用户抓牌 0x1105
        [PROTOCOL.SVR_OWN_CATCH_BROADCAST] = {handler(self, CSMJReceiveHandle.SVR_OWN_CATCH_BROADCAST)},
        -- 听状态下杠之后 0x1106
        [PROTOCOL.SVR_GET_GANGED_CARD_IN_TING_STATUS]={handler(self, CSMJReceiveHandle.SVR_GET_GANGED_CARD_IN_TING_STATUS)},
        --用户重新登录(要做修改) 0x1107
        [PROTOCOL.SVR_REGET_ROOM]      = {handler(self, CSMJReceiveHandle.SVR_REGET_ROOM)},--重登
        --发牌 0x1108
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, CSMJReceiveHandle.SVR_SEND_USER_CARD)},
        --服务器告知客户端可以进行的操作 0x1109
        [PROTOCOL.SVR_NORMAL_OPERATE]      = {handler(self, CSMJReceiveHandle.SVR_NORMAL_OPERATE)},--广播可以进行的操作
        --海底牌 SVR_HAIDI_CARD 0x1110
        [PROTOCOL.SVR_HAIDI_CARD] = {handler(self, CSMJReceiveHandle.SVR_HAIDI_CARD)}, 
        --漫游 0x1111
        [PROTOCOL.SVR_MANYOU] = {handler(self, CSMJReceiveHandle.SVR_MANYOU)},
        --请求托管 0x1112
        [PROTOCOL.SVR_ROBOT] = {handler(self, CSMJReceiveHandle.SVR_ROBOT)}, 
        --出牌错误返回 0x1113
        [PROTOCOL.SVR_CHUPAI_ERROR] = {handler(self, CSMJReceiveHandle.SVR_CHUPAI_ERROR)}, 
         --获取上一局记录 0x1114
        [PROTOCOL.G2H_GET_LAST_RECORD] = {handler(self, CSMJReceiveHandle.G2H_GET_LAST_RECORD)}, 
        -- 广播金币变化 0x4800
        [PROTOCOL.G2H_BROADCAST_CHIP_CHANGE]       = {handler(self, CSMJReceiveHandle.G2H_BROADCAST_CHIP_CHANGE)},

  --       --开始选择缺一门
  --       [PROTOCOL.SVR_START_QUE_CHOICE] = {handler(self, CSMJReceiveHandle.SVR_START_QUE_CHOICE)},
  --       --广播缺一门选择
  --       [PROTOCOL.SVR_BROADCAST_QUE] = {handler(self, CSMJReceiveHandle.SVR_BROADCAST_QUE)},
  --       --广播胡
     	[PROTOCOL.SVR_HUPAI_BROADCAST]       = {handler(self, CSMJReceiveHandle.SVR_HUPAI_BROADCAST)},
  --   	[PROTOCOL.SVR_MSG_FACE]={handler(self, CSMJReceiveHandle.SVR_MSG_FACE)},
  --   	[PROTOCOL.BROADCAST_USER_IP]={handler(self, CSMJReceiveHandle.BROADCAST_USER_IP)},
  --   	--获取房间id结果
  --   	[PROTOCOL.SVR_GET_ROOM_OK]     = {handler(self, CSMJReceiveHandle.SVR_GET_ROOM_OK)},
  --    	--服务器告知客户端游戏结束
  --    	[PROTOCOL.SVR_GAME_OVER]      = {handler(self, CSMJReceiveHandle.SVR_GAME_OVER)},
  --    	--广播刮风下雨（返回）杠
  --    	[PROTOCOL.SVR_GUFENG_XIAYU]      = {handler(self, CSMJReceiveHandle.SVR_GUFENG_XIAYU)},
  --    	--用户聊天消息
  --    	[PROTOCOL.CHAT_MSG]      = {handler(self, CSMJReceiveHandle.CHAT_MSG)},
  --    	--组局
  --    	--请求获取筹码返回
  --    	[PROTOCOL.SVR_GET_CHIP]     = {handler(self, CSMJReceiveHandle.SVR_GET_CHIP)},
  --    	--请求兑换筹码返回
  --    	[PROTOCOL.SVR_CHANGE_CHIP]     = {handler(self, CSMJReceiveHandle.SVR_CHANGE_CHIP)},
  --    	--组局历史记录
  --    	[PROTOCOL.SVR_GET_HISTORY]     = {handler(self, CSMJReceiveHandle.SVR_GET_HISTORY)},
  --    	--广播桌子用户请求解散组局
  --    	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, CSMJReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
  --    	--广播桌子用户成功解散组局
  --    	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, CSMJReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
  --    	--广播桌子用户解散组局 ，解散组局失败
  --    	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, CSMJReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
  --    	--接收服务器发来的距离
  --       [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, CSMJReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
  --    	--换牌
  --    	--服务器告诉客户端，可以换牌
  --    	[PROTOCOL.SERVER_COMMAND_NEED_CHANGE_CARD]     = {handler(self, CSMJReceiveHandle.SERVER_COMMAND_NEED_CHANGE_CARD)},
  --    	--//服务器广播换牌的结果 zsw
  --    	[PROTOCOL.SERVER_COMMAND_CHANGE_CARD_RESULT]     = {handler(self, CSMJReceiveHandle.SERVER_COMMAND_CHANGE_CARD_RESULT)},
  --    	--比赛场相关
  --    	--用户请求进入比赛场的返回值
  --    	[PROTOCOL.s2c_JOIN_MATCH_RETURN]     = {handler(self, CSMJReceiveHandle.s2c_JOIN_MATCH_RETURN)},
  --    	--进入比赛失败
  --    	[PROTOCOL.s2c_JOIN_MATCH_FAIL]     = {handler(self, CSMJReceiveHandle.s2c_JOIN_MATCH_FAIL)},
  --    	-- 进入比赛成功
		-- [PROTOCOL.s2c_JOIN_MATCH_SUCCESS]     = {handler(self, CSMJReceiveHandle.s2c_JOIN_MATCH_SUCCESS)},
		-- --同时，已经报名的玩家会收到其他玩家进入的消息
  --    	[PROTOCOL.s2c_OTHER_PEOPLE_JOINT_IN]     = {handler(self, CSMJReceiveHandle.s2c_OTHER_PEOPLE_JOINT_IN)},
  --    	--返回退出比赛结果
  --    	[PROTOCOL.s2c_QUIT_MATCH_RETURN]     = {handler(self, CSMJReceiveHandle.s2c_QUIT_MATCH_RETURN)},
  --    	--比赛开始逻辑0x7104//牌局，开始发送其他玩家信息
  --    	[PROTOCOL.s2c_GAME_BEGIN_LOGIC]     = {handler(self, CSMJReceiveHandle.s2c_GAME_BEGIN_LOGIC)},
  --    	--每轮打完之后 会给玩家发送比赛状态信息0x7106
  --    	[PROTOCOL.s2c_GAME_STATE_MSG]     = {handler(self, CSMJReceiveHandle.s2c_GAME_STATE_MSG)},
  --    	-- 比赛的过程中会收到比赛的排名信息  0x7114
  --    	[PROTOCOL.s2c_PAI_MING_MSG]     = {handler(self, CSMJReceiveHandle.s2c_PAI_MING_MSG)},
  --    	--发送用户重连回比赛开赛后的等待界面
  --    	[PROTOCOL.s2c_SVR_MATCH_WAIT]     = {handler(self, CSMJReceiveHandle.s2c_SVR_MATCH_WAIT)},
  --    	--用户重新登录比赛场房间的消息返回
  --    	[PROTOCOL.s2c_SVR_REGET_MATCH_ROOM] = {handler(self, CSMJReceiveHandle.s2c_SVR_REGET_MATCH_ROOM)},
			--111 广播玩家充值
			[PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, CSMJReceiveHandle.SVR_CHARGE_BROADCAST)},

               --开始选漂
      [PROTOCOL.BROADCAST_BEGIN_CHOSE_PIAO]={handler(self, CSMJReceiveHandle.BROADCAST_BEGIN_CHOSE_PIAO)},

      --玩家选漂的结果
      [PROTOCOL.BROADCAST_CHOSE_PIAO_RESULT]={handler(self, CSMJReceiveHandle.BROADCAST_CHOSE_PIAO_RESULT)},

    }
    table.merge(self.func_, func_)

end

--麻将游戏加载请求方法
function CSMJReceiveHandle:callFunc(pack)
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

-- 广播金币变化 0x4800
function CSMJReceiveHandle:G2H_BROADCAST_CHIP_CHANGE(pack)
    -- dump(pack,"G2H_BROADCAST_CHIP_CHANGE")
    local account_count = pack.account_count
    local user_infos = pack.user_infos
    for k,user_info in pairs(user_infos) do

        local seat_id = CSMJ_SEAT_TABLE[user_info.uid .. ""]
        local userInfo = CSMJ_USERINFO_TABLE[seat_id .. ""]
        userInfo.coins = userInfo.coins + user_info.change_chip
        local playerType = cardUtils:getPlayerType(seat_id)
        gamePlaneOperator:showPlayerInfo(playerType, userInfo)

        if user_info.uid == USER_INFO["uid"] then
            local change_chip_text = cc.Label:createWithTTF("扣除台费"..user_info.change_chip,"/cs_majiang/fonts/fzcs.ttf",40)
            change_chip_text:setColor(cc.c3b(125, 125, 125))
            change_chip_text:setPosition(cc.p(640,250))
            SCENENOW["scene"]._scene:addChild(change_chip_text, 999)
            local func = cc.CallFunc:create(function ()
                change_chip_text:removeSelf()
            end)
            local seq = cc.Sequence:create(cc.FadeIn:create(0.2),cc.DelayTime:create(0.2), cc.FadeOut:create(0.2), cc.DelayTime:create(0.2), func)
            change_chip_text:runAction(seq)
        end
    end 
end

function CSMJReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1
    
    ---------------------------------不同游戏需修改的部分----------------------------
    --通过UID获取seatId
    local seatId_from = CSMJ_SEAT_TABLE[uid_from.. ""] or 2
    local seatId_to =  CSMJ_SEAT_TABLE[uid_to.. ""] or 1
    
    local playerType_from = cardUtils:getPlayerType(seatId_from)
    local head_from = gamePlaneOperator:getHeadNode(playerType_from)
    local playerType_to = cardUtils:getPlayerType(seatId_to)
    local head_to = gamePlaneOperator:getHeadNode(playerType_to)
    
    local playerHeadPosition_from = (head_from:getParent()):convertToWorldSpace(head_from:getPosition()) or {x=0,y=0}
    local from_x = playerHeadPosition_from.x
    local from_y = playerHeadPosition_from.y

    local playerHeadPosition_to = (head_to:getParent()):convertToWorldSpace(head_to:getPosition()) or {x=0,y=0}
    local to_x   = playerHeadPosition_to.x
    local to_y   = playerHeadPosition_to.y

    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y,to_x,to_y,expressionType)        
end

function CSMJReceiveHandle:showTextMessage(pack)

    local s = SCENENOW["scene"]:getChildByName("faceUI")
    local seatId = CSMJ_SEAT_TABLE[pack.uid .. ""]
    local sex = 1
    if pack.uid == USER_INFO["uid"] then
        sex = CSMJ_MY_USERINFO.sex
    else
        sex = CSMJ_USERINFO_TABLE[seatId .. ""].sex or 0
    end

    local playerType = cardUtils:getPlayerType(seatId)
    local node_head = gamePlaneOperator:getHeadNode(playerType)

    s:showGetText(pack.uid, pack.textMessage, tonumber(sex), node_head, false)
end

function CSMJReceiveHandle:SVR_MSG_FACE(pack)
    if SCENENOW["name"] == run_scene_name then
        local seatId = CSMJ_SEAT_TABLE[pack.uid .. ""]
        local sex = CSMJ_USERINFO_TABLE[seatId .. ""].sex
        local playerType = cardUtils:getPlayerType(seatId)
        local msg_type = pack.type
        local isLeft = false
        if playerType == CARD_PLAYERTYPE_RIGHT then
            isLeft = true
        end

        local node_head = gamePlaneOperator:getHeadNode(playerType)
        if node_head == nil then
            return
        end
        local s = SCENENOW["scene"]:getChildByName("faceUI")
        if tonumber(sex) >= 0 then
            s:showGetFace(uid, msg_type, tonumber(sex), node_head, isLeft)
        end
    end
end

--语音和互动表情 0x801
function CSMJReceiveHandle:G2H_BROADCAST_SPECIAL_FACE(pack)
   if bm.isInGame == false then
        return
    end
    
    local msg = json.decode(pack.msg)
    -- dump(msg, "-----TDKReceiveHandle 表情-----")
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
                    dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                     --通知本地播放录音
                     local arr = {}
                     arr["url"] = msg.url
                     cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    dump("video", "-----接收服务器返回的组局信息-----")
                    local arr = {}
                    arr["url"] = msg.url
                    cct.getDateForApp("playVideo", arr, "V")
                end
            else
                if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")
                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url,msg.uid,msg.voiceTime)
                     require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
                     --通知本地播放录音
                     local data = {}
                     data["url"] = msg.url
                     local arr = {}
                     table.insert(arr, json.encode(data))
                     cct.getDateForApp("playVoice", arr, "V")
                elseif msgType == "video" then
                    dump("video", "-----接收服务器返回的组局信息-----")
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

--解散房间失败0x908
function CSMJReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)
    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")
end

--广播桌子用户同意解散组局 0x103A
function CSMJReceiveHandle:G2H_BROADCAST_DISSOLVE_GROUP(pack)
    -- dump(pack, "-----广播桌子用户成功解散组局-----")
    bm.isDisbandSuccess = true
end

--广播桌子用户拒绝解散组局 0x104A
function CSMJReceiveHandle:G2H_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)
    -- dump(pack, "-----广播当前组局解散情况-----")
    local rejectId = pack.rejectId
    if rejectId == USER_INFO["uid"] then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        local seatId = CSMJ_SEAT_TABLE[rejectId .. ""]
        local userInfo = CSMJ_USERINFO_TABLE[seatId .. ""]
        if userInfo then
          local nickName = userInfo.nick or "路人甲"
          require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2,  nickName.. "拒绝解散房间")
        end
    end
end

--广播当前组局解散情况 0x909
function CSMJReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)
    -- dump(pack, "-----广播当前组局解散情况-----")
    local applyId = pack.applyId
    local agreeNum = pack.agreeNum
    local agreeMember_arr = pack.agreeMember_arr
    local disband_table = {}

    --申请解散者信息
    local applyer_info = {}
    if applyId == USER_INFO["uid"] then
        local player_table = {}
        player_table["playerName"] = "我"
        player_table["state"] = "申请"
        table.insert(disband_table, player_table)
    else
        local player_table = {}
        local seatId = CSMJ_SEAT_TABLE[applyId .. ""]
        if seatId then
            local userInfo = CSMJ_USERINFO_TABLE[seatId .. ""]
            if userInfo then
                local nickName = userInfo.nick
                player_table["playerName"] = nickName
                player_table["state"] = "申请"
                table.insert(disband_table, player_table)
            end
        end
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
    if CSMJ_USERINFO_TABLE then
        for k,v in pairs(CSMJ_USERINFO_TABLE) do
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
                local player_table = {}
                local nickName = v.nick
                if nickName ~= nil then
                    player_table["playerName"] = nickName
                    if isAgree == 1 then
                        player_table["state"] = "同意"
                    else
                        player_table["state"] = "等待选择"
                    end
                    player_table["icon"] = v.photoUrl
                    table.insert(disband_table, player_table)
                end
            end
        end
    end

    local function agree_disband(value)
        sendHandle:H2G_REPLY_DISSOLVE_ROOM(value)
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

--广播错误消息 0x5001
function CSMJReceiveHandle:G2H_BROADCAST_ERROR_MSG(pack)
    -- dump(pack,"G2H_BROADCAST_ERROR_MSG")
    local error_code = pack.error_code
    local show_tips_data = tbErrorCode[error_code]
    if error_code == 18 then
      -- local call_func = function ()
        -- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
      --   require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
      -- end
      -- require("hall.GameTips"):showTips("提示", "", 3,show_tips_data,nil,call_func)
      require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
    else
      -- require("hall.GameTips"):showTips("提示", "", 3,show_tips_data)
      require("hall.GameTips"):showTips("提示", "", 2, "游戏中不可以退出！")
    end
end

--广播玩家充值 0x111
function CSMJReceiveHandle:G2H_BROADCAST_ACCOUNT_RECHARGE(pack)
  -- dump(pack,"G2H_BROADCAST_ACCOUNT_RECHARGE")
  local uid = tonumber(pack.uid)
  local chargeCoins = pack.chargeCoins
  local seat_id = CSMJ_SEAT_TABLE[uid .. ""]
  if seat_id == nil or seat_id < 0 then
    return
  end
  local playerType = cardUtils:getPlayerType(seat_id)
  local userInfo = CSMJ_USERINFO_TABLE[seat_id .. ""]
  userInfo.coins = userInfo.coins + chargeCoins
  gamePlaneOperator:showPlayerInfo(playerType, userInfo)
end

--登陆错误 0x1005
function CSMJReceiveHandle:SVR_ERROR(pack)
  
  -- dump(pack, "-----登陆错误-----")

  local errcode = "error"
  local showBtn = 2
  if pack["type"] == 9 then
    errcode = "change_money"
    showBtn = 1
  end
  require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
  require("hall.GameTips"):showTips("提示","",3,"登陆失败")
end

--广播用户坐下 0x1031
function CSMJReceiveHandle:G2H_BROADCAST_USER_SIT_DOWN(pack)
  -- dump(pack,"G2H_BROADCAST_USER_SIT_DOWN")
  local uid = tonumber(pack.uid)
  local seat_id = pack.seat_id
  local sex = pack.sex
  local nickname = pack.nickname
  local icon_url = pack.icon_url
  local gold = pack.chips
  if GROUP_MODE == ROOMCARD_MODE then
    -- gold = gold -2000
  end
  -- dump(CSMJ_USERINFO_TABLE,"CSMJ_USERINFO_TABLE111")
  if uid == USER_INFO["uid"] then
    CSMJ_MY_USERINFO.seat_id = seat_id
    CSMJ_MY_USERINFO.coins      = gold
    CSMJ_MY_USERINFO.photoUrl = icon_url
    CSMJ_MY_USERINFO.nick = nickname
    CSMJ_MY_USERINFO.uid = uid
    CSMJ_MY_USERINFO.sex = sex
  end



  CSMJ_SEAT_TABLE[uid .. ""] = seat_id
  if CSMJ_USERINFO_TABLE[seat_id .. ""] == nil then
    CSMJ_USERINFO_TABLE[seat_id .. ""] = {}
  end
  CSMJ_USERINFO_TABLE[seat_id .. ""].photoUrl = icon_url
  CSMJ_USERINFO_TABLE[seat_id .. ""].uid = uid
  CSMJ_USERINFO_TABLE[seat_id .. ""].nick = nickname
  CSMJ_USERINFO_TABLE[seat_id .. ""].coins = gold
  CSMJ_USERINFO_TABLE[seat_id .. ""].sex = sex
  CSMJ_USERINFO_TABLE[seat_id .. ""].ip = ip
  -- dump(CSMJ_USERINFO_TABLE,"CSMJ_USERINFO_TABLE222")
  SCENENOW["scene"]:refresh_user_info()
end

--广播用户站起 0x1032
function CSMJReceiveHandle:G2H_BROADCAST_USER_STAND_UP(pack)
  if GAME_IS_OVER then return end
  -- dump(pack,"广播用户站起")
  local seat_id = pack.seat_id
  local uid = pack.uid
  CSMJ_SEAT_TABLE[uid .. ""] = nil
  CSMJ_USERINFO_TABLE[seat_id .. ""] = nil
  SCENENOW["scene"]:refresh_user_info()
end

--广播用户退出 0x1033
function CSMJReceiveHandle:G2H_BROADCAST_USER_QUIT_ROOM(pack)
  -- dump(pack,"G2H_BROADCAST_USER_QUIT_ROOM")
  local uid = pack.uid
  if uid == USER_INFO["uid"] and CSMJ_GROUP_ENDING_DATA == nil then
    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
  end
  if uid and require("hall.view.userInfoView.userInfoView").upDateUserInfo then
      require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,{},"reset")
  end
end

--进出房间相关
--用户进入房间 0x100D
function CSMJReceiveHandle:G2H_BROADCAST_ACCOUNT_LOGIN(pack)
    -- dump(pack,"G2H_BROADCAST_ACCOUNT_LOGIN")
    local uid = tonumber(pack.uid)
    local seat_id = pack.seat_id
    local sex = pack.sex
    local nickname = pack.nickname
    local icon_url = pack.icon_url
    local latitude = pack.latitude
    local longitude = pack.longitude
    local user_game_info = pack.user_game_info
    local ip = pack.ip
    local gold = pack.gold
    -- if GROUP_MODE == ROOMCARD_MODE then
    --   gold = gold - 2000
    -- end
    --设置IP和地理位置
    local dict = {}
    dict.uid = uid
    dict.nickName = nickname
    dict.longitude = longitude
    dict.latitude = latitude
    dict.ip = ip
    dict.invote_code = USER_INFO["invote_code"]
    dict.city = user_game_info["LocalCity"]
    if GROUP_MODE == GOLD_MODE then
        dict.gold = gold
    end
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,dict) 
    if pack ~= nil and pack.seat_id > -1 then
       self:showPlayer(pack)
        local playerType = cardUtils:getPlayerType(pack.seat_id)
        gamePlaneOperator:showNetworkImg(playerType, false)
       --SCENENOW["scene"]:refresh_user_info()
    end

end

--用户退出房间 0x100E
function CSMJReceiveHandle:G2H_BROADCAST_ACCOUNT_LOGOUT(pack)
  -- dump(pack,"-----用户退出房间-----")

  if SCENENOW['name'] ~= run_scene_name then
    return
  end

  local uid = pack.uid
  local seatId = CSMJ_SEAT_TABLE[uid .. ""]

  if not seatId then
      return
  end



  local playerType = cardUtils:getPlayerType(seatId)


  --if CSMJ_GAME_STATUS == 0 then
  --    --table.remove(CSMJ_SEAT_TABLE_BY_TYPE, playerType .. "")
  --    --todo
  --    gamePlaneOperator:removePlayer(playerType)
  --else
    gamePlaneOperator:showNetworkImg(playerType, true)
  --end


  local uid_arr = {}

  for k,v in pairs(CSMJ_USERINFO_TABLE) do
      table.insert(uid_arr, v.uid)
  end
    --table.remove(CSMJ_SEAT_TABLE, uid .. "")
    --table.remove(CSMJ_USERINFO_TABLE, seatId .. "")
    --table.remove(CSMJ_GAMEINFO_TABLE, seatId .. "")
  require("hall.GameSetting"):setPlayerUid(uid_arr)
end

--广播用户准备 0x2001
function CSMJReceiveHandle:G2H_BROADCAST_ACCOUNT_READY(pack)
  -- dump(pack,"pack333")
  local uid = pack.uid
  local flag = pack.flag
  local seatId = CSMJ_SEAT_TABLE[uid .. ""]
  local playerType = cardUtils:getPlayerType(seatId)
  if flag == 1 then
    gamePlaneOperator:setReadyStatus(playerType) 
    if uid == USER_INFO["uid"] then
      SCENENOW["scene"]:showReadyBtn(false)
    end
  else
    gamePlaneOperator:setReadyStatus(playerType,false) 
    if uid == USER_INFO["uid"] then
      SCENENOW["scene"]:showReadyBtn(true)
    end
  end
  if CSMJ_USERINFO_TABLE[seatId..""] then
    CSMJ_USERINFO_TABLE[seatId..""].ready_flag = flag
  end
end

--给自己发登出成功 0x1008
function  CSMJReceiveHandle:G2H_ACCOUNT_LOGIN_SUCCESS(pack)
    -- dump(pack,"G2H_ACCOUNT_LOGIN_SUCCESS")
    if not is_End then
        --if SCENENOW["scene"].reConnect then
        --    SCENENOW["scene"]:reConnect()
        --end
        require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
    end
end

--单局结算 6008
function CSMJReceiveHandle:G2H_BROADCAST_ROUND_RESULT(pack)
    dump(pack,"-----一盘结束，进行结算-----")
    CSMJ_GAME_STATUS = 0

    CS_GAME_TG:setVisible(false)

    manyouPlaneOperator:hide()

    for k,user_info in pairs(pack.players) do
        local seat_id = CSMJ_SEAT_TABLE[user_info["uid"]..""]
        local userInfo = CSMJ_USERINFO_TABLE[seat_id .. ""]
        userInfo.coins = user_info.coins
        if GROUP_MODE == ROOMCARD_MODE then
          userInfo.coins = userInfo.coins
        end
        local playerType = cardUtils:getPlayerType(seat_id)
        gamePlaneOperator:showPlayerInfo(playerType, userInfo)
      end

      CSMJ_ENDING_DATA = pack

      for k,v in pairs(pack.players) do
        if v.huTypeCount > 0 then
          local playerType = cardUtils:getPlayerType(k - 1)
          gamePlaneOperator:showCardsForHu(playerType, v.remainCards, pack.huCard)

        end
      end

      _G.G_CARDS_4_TING_TB = nil
      _G.G_CARDS_4_TING_TB = {}

      CSMJ_STATE = 3
       dump(CSMJ_ENDING_DATA,"====6008=====")
      GAME_IS_DANJU_OVER = true
      if  pack.isGameDist == 1 then
        require("cs_majiang.RoundEndingLayer"):showZhuaniao(CSMJ_ENDING_DATA, true)
      else
        require("cs_majiang.RoundEndingLayer"):showZhuaniao(CSMJ_ENDING_DATA, false)
      end
end

--总结算 0x5100
function CSMJReceiveHandle:G2H_BROADCAST_GROUP_RESULT(pack)
    -- dump(pack,"G2H_BROADCAST_GROUP_RESULT")
    GAME_IS_OVER = true
    CSMJ_GAME_STATUS = 0
    local s = SCENENOW["scene"]:getChildByName("layer_tips")
    if s then
        s:removeSelf()
    end
    if pack then
      CSMJ_GROUP_ENDING_DATA = pack
      HEART_BEAT_TID = 0
      local isShow = require("cs_majiang.RoundEndingLayer"):isShow()
      if isShow then
    
      else
          require("cs_majiang.GroupEndingLayer"):showGroupResult(CSMJ_GROUP_ENDING_DATA)
      end

      -- if require("hall.gameSettings"):getGameMode() == "group" then
      --   local isShow = require("cs_majiang.RoundEndingLayer"):isShow()
      --   if not isShow then
      --     require("cs_majiang.GroupEndingLayer"):showGroupResult(CSMJ_GROUP_ENDING_DATA)
      --   end
      -- end
    end
end

--组局局数 0x5101
function CSMJReceiveHandle:G2H_BROADCAST_REFRESH_ROUND(pack)
  -- dump(pack, "-----组局时长-----")
  --记录当前局数
  CSMJ_ROUND = pack.round
  --记录总局数
  CSMJ_TOTAL_ROUNDS = pack.total_round
end

--登录房间成功 1007
function CSMJReceiveHandle:G2H_REFRESH_ACCOUNT_LIST(pack)
    -- dump(pack, "-----登录房间成功-----")
    require(NetworkLoadingView_filePath):removeView(888)
    -- 初始化大厅心跳桌子ID
    HEART_BEAT_TID = USER_INFO["tid"]
    local GROUP_MODE = pack.group_mode
    local activityId = pack.activityId
    local inviteCode = pack.inviteCode
    local base = pack.base
    local play_count = pack.play_count
    local out_card_time = pack.out_card_time
    local handle_time = pack.handle_time
    local game_config = pack.game_config
    CS_PLAYERNUM = pack.max_playerCount
    local other_user_infos = pack.other_user_infos
    USER_INFO["activity_id"] = activityId
    USER_INFO["invote_code"] = inviteCode
    SCENENOW['scene']:showInviteCode()
    if pack.club_id >0 then
        CLUB_ID = pack.club_id
    end

    CSMJ_GROUP_ENDING_DATA = nil
    CSMJ_GAME_STATUS = 0   
    CSMJ_ROOM.base      = base

    -- CSMJ_GAMEINFO_TABLE[pack.users_info[i].seat_id .. ""] = gameInfo

    SCENENOW["scene"]:after_account_login()

    --绘制其他玩家
    if pack.user_count > 0  then
        for i,user_info in pairs(pack.other_user_infos) do
   
            CSMJReceiveHandle:showPlayer(user_info)
        end
    end

    SCENENOW["scene"]:ShowRecordButton()
    SCENENOW["scene"]:ShowChatButton()

    SCENENOW["scene"]:refresh_user_info()
    SCENENOW["scene"]:set_game_config(pack.game_config,pack.fenchang)
    -- local uid_arr = {}
    -- for k,v in pairs(CSMJ_USERINFO_TABLE) do
    --     table.insert(uid_arr, v.uid)
    -- end
    -- require("hall.GameSetting"):setPlayerUid(uid_arr)

    -- local playerType = cardUtils:getPlayerType(pack.seat_id)
    -- LocaArrayByPlayerType[playerType] = {[1] = tonumber(pack.longitude) ,[2] = tonumber(pack.latitude)}

    -- -- if require("hall.gameSettings"):getGameMode() == "group" then
    -- --     USER_INFO["base_chip"] = CSMJ_ROOM.base;
    -- -- else
    -- --     SCENENOW["scene"]:gameReady();
    -- -- end
    -- -- sendHandle:readyNow()
    -- if #LocaArrayByPlayerType>3 then
    --     if CSMJ_GAME_STATUS ~= 1 then
    --         gamePlaneOperator:showDistance(LocaArrayByPlayerType,true)
    --     else
    --         gamePlaneOperator:showDistance(LocaArrayByPlayerType,false)
    --     end
    -- end
    self:remaidIP()
    voiceUtils:playBackgroundMusic()
    
end

--显示其他玩家
function CSMJReceiveHandle:showPlayer(user_info)
  -- dump(user_info,"user_info3333")
  local uid = tonumber(user_info.uid)
  local seat_id = user_info.seat_id
  local sex = user_info.sex
  local nickname = user_info.nickname
  local icon_url = user_info.icon_url
  local latitude = user_info.latitude
  local longitude = user_info.longitude
  local user_game_info = json.decode(user_info["user_game_info"])
  local ip = user_info.ip
  local gold = user_info.gold
  if GROUP_MODE == ROOMCARD_MODE then
    -- gold = gold - 2000
  end
  local ready_flag = user_info.ready_flag

  if uid == USER_INFO["uid"] then
    CSMJ_MY_USERINFO.seat_id = seat_id
    CSMJ_MY_USERINFO.coins = gold
    CSMJ_MY_USERINFO.photoUrl = icon_url
    CSMJ_MY_USERINFO.nick = nickname
    CSMJ_MY_USERINFO.uid = uid
    CSMJ_MY_USERINFO.sex = sex
    CSMJ_MY_USERINFO.ready_flag = ready_flag
  end
  --保存用户座位与id映射
  CSMJ_SEAT_TABLE[uid .. ""] = seat_id
  if seat_id>=0 then
    if not CSMJ_USERINFO_TABLE[seat_id .. ""] then
      CSMJ_USERINFO_TABLE[seat_id .. ""] = {}
    end
    CSMJ_USERINFO_TABLE[seat_id .. ""].uid = uid
    CSMJ_USERINFO_TABLE[seat_id .. ""].photoUrl =icon_url
    CSMJ_USERINFO_TABLE[seat_id .. ""].uid = uid
    CSMJ_USERINFO_TABLE[seat_id .. ""].nick = nickname
    CSMJ_USERINFO_TABLE[seat_id .. ""].coins = gold
    CSMJ_USERINFO_TABLE[seat_id .. ""].sex = sex
    CSMJ_USERINFO_TABLE[seat_id .. ""].ip = ip
    CSMJ_USERINFO_TABLE[seat_id .. ""].ready_flag = ready_flag

    --设置IP和地理位置
    local dict = {}
    dict.uid = uid
    dict.nickName = nickname
    dict.longitude = longitude
    dict.latitude = latitude
    dict.ip = ip
    dict.invote_code = USER_INFO["invote_code"]
    dict.city = user_game_info["LocalCity"]
    if GROUP_MODE == GOLD_MODE then
        dict.gold = gold
    end
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid,dict) 
  end
end

--用户重登房间 1107
function CSMJReceiveHandle:SVR_REGET_ROOM(pack)
  require(NetworkLoadingView_filePath):removeView(888)

  dump(pack, "-----重连房间成功-----")

  HEART_BEAT_TID = USER_INFO["tid"]
  CSMJ_STATE = 2
  CSMJ_GAME_STATUS = pack.gameStatus
  CSMJ_GROUP_ENDING_DATA = nil

  local scenes  = SCENENOW['scene']
  if SCENENOW['name'] ~= run_scene_name then
    return
  end

  USER_INFO["activity_id"] = pack.activityId
  USER_INFO["invote_code"] = pack.inviteCode
  scenes:showInviteCode()
  SCENENOW["scene"]:set_game_config(pack.game_config,pack.fenchang)

  local gameConfigtbl = json.decode(pack["game_config"])

  if pack.club_id >0 then
        CLUB_ID = pack.club_id
  end
  local tableStatus = pack.tableStatus
  if tableStatus ~= 0 then
      scenes:hideCloseRoomButton()
      scenes:hideShareButton()
      scenes:showCopyBtn(false)
  end

  scenes:ShowSettingButton()
  scenes:ShowRecordButton()
  scenes:ShowChatButton()

  gamePlaneOperator:clearGameDatas()
  gamePlaneOperator:showCenterPlane()

  CSMJ_REMAIN_CARDS_COUNT = pack.card_less
  CS_PLAYERNUM = pack.max_playerCount
  local gold =pack.gold
  local ready_flag = pack.ready_flag
  if GROUP_MODE == ROOMCARD_MODE then
    -- gold = gold -2000
  end
  --绘制自己的信息
  CSMJ_MY_USERINFO.seat_id = pack.seat_id
  CSMJ_MY_USERINFO.coins      = gold
  CSMJ_MY_USERINFO.photoUrl = USER_INFO["icon_url"]
  CSMJ_MY_USERINFO.nick = USER_INFO["nick"]
  CSMJ_MY_USERINFO.coins = pack.gold
  CSMJ_MY_USERINFO.uid = USER_INFO["uid"]
  CSMJ_MY_USERINFO.sex = USER_INFO["sex"]
  CSMJ_MY_USERINFO.ready_flag = ready_flag

  CSMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] = pack.seat_id
  CSMJ_SEAT_TABLE[USER_INFO["uid"] .. ""] = pack.seat_id

  CSMJ_USERINFO_TABLE[pack.seat_id .. ""] = {}
  CSMJ_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = USER_INFO["icon_url"]
  CSMJ_USERINFO_TABLE[pack.seat_id .. ""].uid = USER_INFO["uid"]
  CSMJ_USERINFO_TABLE[pack.seat_id .. ""].nick = USER_INFO["nick"]
  CSMJ_USERINFO_TABLE[pack.seat_id .. ""].coins = gold
  CSMJ_USERINFO_TABLE[pack.seat_id .. ""].sex = USER_INFO["sex"]
  CSMJ_USERINFO_TABLE[pack.seat_id .. ""].ip = pack.ip
  CSMJ_USERINFO_TABLE[pack.seat_id .. ""].ready_flag = pack.ready_flag

  SCENENOW["scene"]:after_account_login()


  --绘制自己的漂结果
  if pack.piaoNum > 0 then
      if gameConfigtbl.piaoType == 1 and pack.piaoStatus == 0 then
            --自由选漂的话 显示选漂结果
            local tempPack ={}
            tempPack.uid = pack.uid
            tempPack.piaoNum = pack.piaoNum
            self:BROADCAST_CHOSE_PIAO_RESULT(tempPack)
      end
  end



  --绘制其他玩家
  if pack.nPlayerCount > 0  then
    for i,user_info in pairs(pack.users_info) do

        self:showPlayer(user_info)

        if gameConfigtbl.piaoType == 1 and pack.piaoStatus == 0 then
            --自由选漂的话 显示选漂结果
            local tempPack ={}
            tempPack.uid = user_info.uid
            tempPack.piaoNum = user_info.piaoNum
            self:BROADCAST_CHOSE_PIAO_RESULT(tempPack)
        end
    end
  end
  scenes:refresh_user_info()
  -- local playerType = cardUtils:getPlayerType(pack.seat_id)
  -- LocaArrayByPlayerType[playerType] = {[1] = tonumber(pack.longitude) ,[2] = tonumber(pack.latitude)}

  -- if #LocaArrayByPlayerType>3 then
  --   if CSMJ_GAME_STATUS ~= 1 then
  --     gamePlaneOperator:showDistance(LocaArrayByPlayerType,true)
  --   else
  --     gamePlaneOperator:showDistance(LocaArrayByPlayerType,false)
  --   end
  --   -- LocaArrayByPlayerType ={}
  -- end
  self:remaidIP()

  local uid_arr = {}

  for k,v in pairs(CSMJ_USERINFO_TABLE) do
    table.insert(uid_arr, v.uid)
  end

  require("hall.GameSetting"):setPlayerUid(uid_arr)


  CSMJ_ZHUANG_UID = CSMJ_USERINFO_TABLE[tostring(pack.m_nBankSeatId)].uid

  local zhuangPlayerType = cardUtils:getPlayerType(pack.m_nBankSeatId)
  gamePlaneOperator:showZhuang(zhuangPlayerType)

  if require("hall.gameSettings"):getGameMode() == "group" then
    -- USER_INFO["base_chip"] = CSMJ_ROOM.base;
  else
    scenes:gameReady()
  end

  voiceUtils:playBackgroundMusic()

  if tableStatus == 0 then
      return
  end

      ------------------------------绘制玩家的漂信息，房间属性的漂----------------------------------
--[[    if gameConfigtbl.piaoType and (gameConfigtbl.piaoType == 2 or gameConfigtbl.piaoType == 3) then
        for i,v in pairs(pack.users_info) do
            local seatId = HZMJ_SEAT_TABLE[v.uid]
            local playerType = cardUtils:getPlayerType(seatId)
            GamePlaneOperator:showPiaoImg(playerType, gameConfigtbl.piaoType, true)
        end
    end--]]
    ------------------------------------------------------------------------------------------------
   
    ------------------------------------- --当前漂阶段------------------------------
    if pack.piaoStatus == 1 and pack.chosePiao[1].userPiaoInfo then  
        for i,v in ipairs(pack.chosePiao[1].userPiaoInfo or {}) do
            if v.uid == USER_INFO['uid'] then
                if v.feedback == -1 then  --未操作
                    gamePlaneOperator:showJiapiaoPlane(true)
                    local centerPlane = CSMJ_GAME_PLANE:getChildByName("center_plane")
                    centerPlane:setVisible(false)
                else
                    local tempPack ={}
                    tempPack.uid = v.uid
                    tempPack.piaoNum = v.piaoNum
                    self:BROADCAST_CHOSE_PIAO_RESULT(tempPack)
                end
            else
                if v.feedback == 1 then
                    local tempPack ={}
                    tempPack.uid = v.uid
                    tempPack.piaoNum = v.piaoNum
                    self:BROADCAST_CHOSE_PIAO_RESULT(tempPack)
                else
                    local centerPlane = CSMJ_GAME_PLANE:getChildByName("center_plane")
                    centerPlane:setVisible(false)
                end
            end
        end
    end  

  local myCards = pack.handCards
    
  table.sort(myCards)

    if #myCards%3 == 2 then
        D3_CHUPAI = 1
    end

  if pack.nPlayerCount > 0  then
    for i,v in pairs(pack.users_info) do
      local gameInfo = {}
      gameInfo.porg = {}
      gameInfo.hand = {}

      for i=1,pack.users_info[i].countHandCards do
        table.insert(gameInfo.hand, 0)
      end

      gameInfo.out = {}

      CSMJ_GAMEINFO_TABLE[pack.users_info[i].seat_id .. ""] = gameInfo

      local playerType = cardUtils:getPlayerType(pack.users_info[i].seat_id)
      gamePlaneOperator:redrawGameInfo(playerType, pack.users_info[i])
    end
  end
  if pack.gameStatus == 2 or pack.gameStatus == 1 then
    if pack.currentPlayerId == USER_INFO["uid"] then
      --todo
      D3_CHUPAI = 1
      local newCard = myCards[table.getn(myCards)]
      table.remove(myCards, table.getn(myCards))
      local myGameInfo = {}
      myGameInfo.porg = {}
      myGameInfo.hand = myCards
      myGameInfo.out = {}

      CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""] = myGameInfo

      -- 重绘桌面信息
      gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

      cardUtils:getNewCard(CSMJ_MY_USERINFO.seat_id, newCard)

      gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard)

            CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].tingCards = pack.tingCards
    else
      D3_CHUPAI = 0

      local myGameInfo = {}
      myGameInfo.porg = {}
      myGameInfo.hand = myCards
      myGameInfo.out = {}

      CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""] = myGameInfo

      -- 重绘桌面信息
      gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)
    end

  elseif pack.gameStatus == 3 then
    --if pack.handle ~= CONTROL_TYPE_NONE then
    --  --todo
    --  D3_CHUPAI = 2
    --else
    --  D3_CHUPAI = 1
    --end
    local data_pack = {}
    data_pack["handle"] = pack["handle"]
    if pack["handle"] > 0 then
      data_pack["has_bonus"] = pack["has_bonus"]
    else
      data_pack["has_bonus"] = 0
    end
    local gang_cards = string.split(pack["handle_gang_cards"], ",")
    -- dump(gang_cards, "SVR_REGET_ROOM gang_cards")
    data_pack["cards"] = {}
    for k, v in pairs(gang_cards) do
      table.insert(data_pack["cards"], tonumber(v))
    end
    -- dump(data_pack, "SVR_PLAYER_USER_BROADCAST data_pack")
    local controlTable = cardUtils:getControlTable(data_pack, pack.handleCard, data_pack["cards"], pack.bonusCards)

    -- dump(controlTable, "test 0428 controltable")
    gamePlaneOperator:showControlPlane(controlTable)
        
        local newCard
        if  table.getn(myCards)%3 == 2 then
            newCard = myCards[table.getn(myCards)]
            table.remove(myCards, table.getn(myCards))
        end

    local myGameInfo = {}
    myGameInfo.porg = {}
    myGameInfo.hand = myCards
    myGameInfo.out = {}

    CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""] = myGameInfo

    if pack.nTingFlag == 1 then -- 将手牌保存起来
      -- dump(CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand, "---++_+_+_+_+_+___+_++_+_+_+_+_+_+_+_+_+_+_")
      -- G_CARDS_4_TING_TB = CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand
      for k,v in pairs(CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand) do
        if v ~= pack.grabCard then
          _G.G_CARDS_4_TING_TB[k] = v
          --print(k, v, _G.G_CARDS_4_TING_TB[k])
        end
      end
    end

    -- 重绘桌面信息
    gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

        if newCard then 
           cardUtils:getNewCard(CSMJ_MY_USERINFO.seat_id, newCard)
           gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard)
        end

    -- if pack.currentPlayerId ~= USER_INFO["uid"] then

      local playerTypeT = cardUtils:getPlayerType(CSMJ_SEAT_TABLE[pack.currentPlayerId .. ""])

      local removeResult = gamePlaneOperator:removeLatestOutCard(playerTypeT, pack.handleCard)

      if removeResult then

        gamePlaneOperator:playCard(playerTypeT, 0, pack.handleCard)
      end

    -- end

    local t_seatId = CSMJ_SEAT_TABLE[pack.currentPlayerId .. ""]
    gamePlaneOperator:beginPlayCard(cardUtils:getPlayerType(t_seatId))
  else
    local myGameInfo = {}
    myGameInfo.porg = {}
    myGameInfo.hand = myCards
    myGameInfo.out = {}

    CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""] = myGameInfo

    -- 重绘桌面信息
    gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)
  end

  -- 开杠弹窗
  if pack.bonusLen > 0 then
    local uid = 0
    if pack.opeBonuseUid ~= nil then
      uid = pack.opeBonuseUid 
    end

    local cardValue1 = pack.bonusSet[1].bonusOpCard
    local opeValue1  = pack.bonusSet[1].bonusOpCode
    local cardValue2 = pack.bonusSet[2].bonusOpCard
    local opeValue2  = pack.bonusSet[2].bonusOpCode

    local sidTemp = CSMJ_SEAT_TABLE[uid .. ""]

    require("cs_majiang.seleteOpeLayer"):pop(CSMJ_USERINFO_TABLE[sidTemp .. ""].nick, cardValue1, cardValue2, opeValue1, opeValue2)
  end
  gamePlaneOperator:rotateTimer(cardUtils:getPlayerType(CSMJ_SEAT_TABLE[CSMJ_ZHUANG_UID .. ""]))
  gamePlaneOperator:clearAllReadyStatus()
  D3_WAIT_OPRATE_CARD = 1
    if  pack.m_bAI  == 1 then
        scenes:TgState(true)

    else
        scenes:TgState(false)
    end
end

--广播用户出牌 0x1102
function CSMJReceiveHandle:SVR_SEND_MAJIANG_BROADCAST(pack)
  
   dump(pack,"-----广播用户出牌-----")
  
  local scenes    = SCENENOW['scene']
  if SCENENOW['name'] ~= run_scene_name then
    return
  end
  gamePlaneOperator:hideControlPlane()
  local value = bit.band(pack.card, 0xFF)

  local handleResult = cardUtils:getControlTable(pack, value)

  if pack.uid ~= USER_INFO["uid"] then
    --todo
    gamePlaneOperator:showControlPlane(handleResult)
  end

  local seatId = CSMJ_SEAT_TABLE[pack.uid .. ""]
  local playerType = cardUtils:getPlayerType(seatId)

  local tag = cardUtils:playCard(seatId, value)
  gamePlaneOperator:playCard(playerType, tag, value)

  
  -- self:showHandlesView(pack.handle,pack.card)

  -- local index     = self:getIndex(pack.uid)
  -- local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
  -- local result    = MajiangcardHandle:getHandles(pack.handle)

  -- local zhua      = scenes._scene:getChildByName("layer_card"):getChildByName("zhua")
  -- if zhua then  zhua:removeSelf() end
    
  -- if index == 0 then
  --  MajiangcardHandle:removeCardValue(CSMJ_ROOM.Card[index]['hand'],pack.card,1,index)    
  -- else
  --  MajiangcardHandle:removeCardValue(CSMJ_ROOM.Card[index]['hand'],0,1,index)
  -- end

 --     --这里表示的是牌从哪个位置开始打出来
  -- local config = {[0]={['x'] = 430,['y'] = 200,},
  --        [1]={['x'] = 200,['y'] = 350,},
  --        [2]={['x'] = 430,['y'] = 500,},
  --        [3]={['x'] = 750,['y'] = 350,},}

  -- local tmp = Majiangcard.new()
  -- tmp:setCard(pack.card)
  -- tmp:setMyOutCard()
  -- tmp:setScale(1)
  -- tmp:addTo(scenes)
  -- tmp:setName("chu")
  -- tmp:zorder(1500)
  -- tmp:pos(config[index]['x'],config[index]['y'])


  -- CSMJ_ROOM.last       = "chupai" --上次的动作
  -- CSMJ_ROOM.index      = index --上次的序号
  -- CSMJ_ROOM.card_value = pack.card --上次的牌

   --self:drawHandCard(index)

  voiceUtils:playCardSound(seatId,pack.card)

    local zhuangSeatId = CSMJ_SEAT_TABLE[CSMJ_ZHUANG_UID .. ""]


    --if (seatId + 1) % CS_PLAYERNUM == zhuangSeatId then
        --todo
    --for i=0,CS_PLAYERNUM do
    --
    --    -- dump(CSMJ_GAMEINFO_TABLE[i .. ""].isShowCards, "test 0509 isShowCards ")
    --
    --    if CSMJ_GAMEINFO_TABLE[i .. ""] and CSMJ_GAMEINFO_TABLE[i .. ""].isShowCards then
    --        for k,v in pairs(CSMJ_GAMEINFO_TABLE[i .. ""].hand) do
    --            v = 0
    --        end
    --        --todo
    --        gamePlaneOperator:showCards(cardUtils:getPlayerType(i))
    --    end
    --end
    --end


    --todo

    --找出保存到本地的那些先手胡的 玩家 然后执行   

    --2020/10/27 有出牌情况下

    --CSMJ_GAMEINFO_TABLE 这个数据只是在普通游戏下有 断线重连那里需要加上


    dump(CSMJ_GAMEINFO_TABLE,"数据 CSMJ_GAMEINFO_TABLE")


    for k,v in pairs(CSMJ_SEAT_TABLE_BY_TYPE) do
        local seatId = tonumber(k)

        if  CSMJ_GAMEINFO_TABLE and CSMJ_GAMEINFO_TABLE[seatId..""] and CSMJ_GAMEINFO_TABLE[seatId..""].qishouhu then

          local playerType = cardUtils:getPlayerType(seatId)
          if playerType then
              gamePlaneOperator:showCards(playerType)
          end

          CSMJ_GAMEINFO_TABLE[seatId..""].qishouhu = false

        end
    end


end

--广播当前操作玩家ID 0x1103
function CSMJReceiveHandle:SVR_PLAYING_UID_BROADCAST(pack)
  
  -- dump(pack,"-----广播抓牌用户-----")

  local scenes  = SCENENOW['scene']
  if SCENENOW['name'] ~= run_scene_name then
    return
  end
  gamePlaneOperator:hideControlPlane()
  -- self:showLastEvent()
  -- CSMJReceiveHandle:showTimer(pack.uid,8)
  -- local index = self:getIndex(pack.uid)
  -- self:zhuaMajiang(index)
  -- if CSMJ_ROOM.Card and CSMJ_ROOM.Card[index] then
  --  --todo
  --  MajiangcardHandle:insertCardTo(CSMJ_ROOM.Card[index]['hand'],{0}) 
  -- end

  -- --设置剩余的牌数
  -- --scenes:set_left_card_num_visible(true)
  -- scenes:set_left_card_num(tostring(pack.simplNum))

  local playerType = cardUtils:getPlayerType(CSMJ_SEAT_TABLE[pack.uid .. ""])
  local seatId = CSMJ_SEAT_TABLE[pack.uid .. ""]

  if playerType ~= CARD_PLAYERTYPE_MY then
    --todo
    cardUtils:getNewCard(seatId, 0)

    gamePlaneOperator:getNewCard(playerType, 0)
  end

  CSMJ_REMAIN_CARDS_COUNT = pack.simplNum
  gamePlaneOperator:showRemainCardsCount()
end

--广播用户进行了什么操作 0x1104
function CSMJReceiveHandle:SVR_PLAYER_USER_BROADCAST(pack)
  
   dump(pack," - SVR_PLAYER_USER_BROADCAST ----广播用户进行了什么操作-----")

  local scenes          = SCENENOW['scene']
  if SCENENOW["name"] ~= run_scene_name then
    return
  end

  local handle = pack.handle
  local value = bit.band(pack.card, 0xFF)

  local seatId = CSMJ_SEAT_TABLE[pack.uid .. ""]

  local playerType = cardUtils:getPlayerType(seatId)
  --print("SVR_PLAYER_USER_BROADCAST playerType ----:", playerType)

  if playerType == CARD_PLAYERTYPE_MY then
    --todo
    D3_CHUPAI = 1
  end


  local tmp = SCENENOW["scene"]:getChildByName("seleteOpeLayer")
  if tmp ~= nil then
    tmp:removeFromParent()
  end

    local handCards = CSMJ_GAMEINFO_TABLE[seatId .. ""].hand
    -- dump(handCards, "++++++++++++++ CSMJ_GAMEINFO_TABLE +++++++++++ ")

  -- 默认处理
  local progCards, removeCards = cardUtils:processControl(seatId, handle, value)

     --牌的来源玩家
    local fromplayerType = cardUtils:getPlayerType(pack.lid)

    if  D3_WAIT_OPRATE_CARD == 1  then
        if fromplayerType~=playerType  then
            D3_WAIT_OPRATE_CARD = gamePlaneOperator:removeLatestOutCard(fromplayerType,value)
        else
            D3_WAIT_OPRATE_CARD = nil
        end
    end

    -- dump(handCards, "++++++++++++++ CSMJ_GAMEINFO_TABLE +++++++++++ ")
  gamePlaneOperator:control(playerType, progCards, handle, nil, removeCards)
  gamePlaneOperator:hideControlPlane()
  voiceUtils:playControlSound(seatId, handle, pack.bonus) 

  -- @add @Brief[起手胡逻辑] @Jhao.
  local cardsNum = 0
  local cardSet = {}

  if bit.band(CONTROL_TYPE_HU, handle) > 0 then
  -- if bit.band(CONTROL_TYPE_HU, handle) >= 0 then

    cardsNum = pack.cardsNum
    cardSet = pack.cardSet
    
    -- gamePlaneOperator:showCardsForQiShouHu(playerType, CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand, handle) -- 显示
    -- gamePlaneOperator:showCardsForQiShouHu(playerType, cardSet, handle) -- 显示

    -- local handCards = CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand
    local handCards = CSMJ_GAMEINFO_TABLE[seatId .. ""].hand
    -- dump(handCards, "++++++++++++++ CSMJ_GAMEINFO_TABLE +++++++++++ ")
    local liangCards = cardSet
    --gamePlaneOperator:showCardsForQiShouHu(playerType, handCards, liangCards) -- 显示

    CSMJ_CURRENT_QI_SHOU_PLAYER_TYPE = playerType

    -- next_handle 按钮弹出
    local func = function()
      if pack["uid"] == USER_INFO["uid"] then

        local data_pack = {}
        data_pack["handle"] = pack["next_handle"]
        if pack["next_handle"] > 0 then
          data_pack["has_bonus"] = pack["bonus"]
        else
          data_pack["has_bonus"] = 0
        end
        data_pack["cards"] = pack["gang_cards"]
        -- dump(data_pack, "SVR_PLAYER_USER_BROADCAST data_pack")

        local controlTable = cardUtils:getControlTable(data_pack, 0, pack.gang_cards, pack.bonusCards)

        gamePlaneOperator:showControlPlane(controlTable)
      end
    end

    local spdelay = display.newSprite():addTo(SCENENOW["scene"])
        spdelay:runAction(cc.Sequence:create(cc.DelayTime:create(COMMON_SHOW_HU_CARD_TIME),
            -- cc.CallFunc:create(function() 
            --  gamePlaneOperator:showCards(playerType)
            -- end),
            cc.CallFunc:create(function() 
              func()
            end),
            cc.CallFunc:create(function() 
              spdelay:removeSelf() 
            end)))
    else
      if pack["uid"] == USER_INFO["uid"] then

                CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].tingCards = pack.tingCards
                
        local data_pack = {}
        data_pack["handle"] = pack["next_handle"]
        if pack["next_handle"] > 0 then
          data_pack["has_bonus"] = pack["bonus"]
        else
          data_pack["has_bonus"] = 0
        end
        data_pack["cards"] = pack["gang_cards"]
        -- dump(data_pack, "SVR_PLAYER_USER_BROADCAST data_pack")

        local controlTable = cardUtils:getControlTable(data_pack, 0, pack.gang_cards, pack.bonusCards)

        gamePlaneOperator:showControlPlane(controlTable)
      end
  end

end

--广播用户抓牌  0x1105
function CSMJReceiveHandle:SVR_OWN_CATCH_BROADCAST(pack)

  -- dump(pack,"-----通知我抓的牌-----")

  local scenes = SCENENOW['scene']

  if SCENENOW['name'] ~= run_scene_name then
    return
  end
  gamePlaneOperator:hideControlPlane()
  -- CSMJ_ROOM.my_out_card_time = 1
  -- scenes:show_Text_18(false)
  -- CSMJ_ROOM.change_card_over = true
  -- self:showLastEvent()


  -- self:showHandlesView(pack.handle,pack.card)

  -- CSMJReceiveHandle:showTimer(UID,8)


  -- local card_node = scenes:getChildByName("owncard")
  -- if card_node == nil then
  --  card_node = display.newNode()
  --  card_node:addTo(scenes)
  --  card_node:setName("owncard")
  -- end
  
  -- MajiangcardHandle:insertCardTo(CSMJ_ROOM.Card[0]['hand'],{pack.card})

  -- --local s_point  = 148.83
  -- --local gang_num = table.nums(CSMJ_ROOM.Gang[0])
  -- -- local start = (#CSMJ_ROOM.Card[index]['porg'] - gang_num*4 )*(74*0.8 - 6) + gang_num*3*(74*0.8 - 6) + s_point
  -- local tmp = Majiangcard.new()
  -- tmp:setCard(pack.card)
  -- -- tmp:setScale(0.8)
  -- tmp:setMyHandCard()
  -- tmp:setName("zhua")
  -- tmp:addTo(scenes._scene:getChildByName("layer_card"))
  -- tmp:pos(836, 50.00)

  -- self:anyCanOut(tmp)

  CSMJ_REMAIN_CARDS_COUNT = CSMJ_REMAIN_CARDS_COUNT - 1
  gamePlaneOperator:showRemainCardsCount()

  if pack.handle == CONTROL_TYPE_NONE then
    --todo
    D3_CHUPAI = 1
  else
    D3_CHUPAI = 2
  end
  

  local value = bit.band(pack.card, 0xFF)

  cardUtils:getNewCard(CSMJ_MY_USERINFO.seat_id, value)

  gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, value)

  local controlTable = cardUtils:getControlTable(pack, 0, pack.cards, pack.bonusCards)

  gamePlaneOperator:showControlPlane(controlTable)

  CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].tingCards = pack.tingCards

  -- 自动打牌
  if pack.handle == 0 and #_G.G_CARDS_4_TING_TB > 0 then
        D3_CHUPAI = 0

        local seqAc = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
                CSMJ_CONTROLLER:playCard(pack.card)

                CSMJ_CONTROLLER:didSelectOutCard(pack.card)
            end))

        SCENENOW["scene"]:runAction(seqAc)
  end

end

-- 0x1106
function CSMJReceiveHandle:SVR_GET_GANGED_CARD_IN_TING_STATUS(_data)
  -- dump(_data, "CSMJReceiveHandle:SVR_GET_GANGED_CARD_IN_TING_STATUS")
    

  local cardValue1  = _data.cardArr[1].card
  local cardValue2  = _data.cardArr[2].card

  local opeValue1   = _data.cardArr[1].opeCode
  local opeValue2   = _data.cardArr[2].opeCode

  local hasBonus1   = _data.cardArr[1].has_bonus
  local hasBonus2   = _data.cardArr[2].has_bonus

  -- 画牌
  -- afterKaiGangMsgDrawTableCard(_data.uid, cardValue1, cardVale2)
  local function drawTableCard(_uid, _cardValue)
    local CHILD_NAME_OUTHANDPLANE = "outhand_plane"
    local seatId    = CSMJ_SEAT_TABLE[tostring(_uid)]
    local playerType  = cardUtils:getPlayerType(seatId)
    local parentPlane = require("cs_majiang.operator.GamePlaneOperator"):getPlayerPlane(playerType)
    local outHandPlane  = parentPlane:getChildByName(CHILD_NAME_OUTHANDPLANE)

    require("cs_majiang.operator.OuthandPlaneOperator"):playCard(playerType, _cardValue, outHandPlane)
  end
  -- drawTableCard(_data.uid, cardValue1)
  -- drawTableCard(_data.uid, cardValue2)

  -- 画牌是一个action,要等画动作完成之后才能画新的牌
  -- local sp = display.newSprite("majiang/image/quan_guo.png")
  -- sp:setVisible(false)

  -- local durTime    = 1.1 
  -- local delayAction  = cc.DelayTime:create(durTime)
  -- local seqAc  = cc.Sequence:create(cc.CallFunc:create(function() 
  --                    drawTableCard(_data.uid, cardValue1) 
  --                  end),
  --                delayAction, 
  --                cc.CallFunc:create(function() 
  --                    drawTableCard(_data.uid, cardValue2) 
  --                  end)
  --                )
  -- sp:runAction(seqAc)

  -- 弹窗

  local sidTemp = CSMJ_SEAT_TABLE[_data.uid .. ""]

  require("cs_majiang.seleteOpeLayer"):pop(CSMJ_USERINFO_TABLE[sidTemp .. ""].nick, 
                      cardValue1, cardValue2, 
                      opeValue1, opeValue2, 
                      hasBonus1, hasBonus2)

  local showTime = 2
  local spdelay = display.newSprite():addTo(SCENENOW["scene"])
  local action = cc.Sequence:create(cc.DelayTime:create(showTime),
            cc.CallFunc:create(function() 
              drawTableCard(_data.uid, cardValue1)
              drawTableCard(_data.uid, cardValue2)
            end),
            cc.CallFunc:create(function() spdelay:removeSelf() end))

  if opeValue1 == 0 and opeValue2 == 0 then
    action = cc.Sequence:create(cc.DelayTime:create(showTime),
            cc.CallFunc:create(function() 
              drawTableCard(_data.uid, cardValue1)
              drawTableCard(_data.uid, cardValue2)
            end),
            cc.CallFunc:create(function() 
              require("cs_majiang.seleteOpeLayer"):onClose()
            end),
            cc.CallFunc:create(function() spdelay:removeSelf() end))
  end

    spdelay:runAction(action)

  -- 听牌逻辑
  if _G.CSMJ_MY_USERINFO.uid == _data.uid then -- 将手牌保存起来
    -- G_CARDS_4_TING_TB = CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand
    for k,v in pairs(CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand) do
      _G.G_CARDS_4_TING_TB[k] = v
      --print(k, v, _G.G_CARDS_4_TING_TB[k])
    end
  end
    

    if CSMJ_MY_USERINFO.uid == _data.uid then
        D3_CHUPAI = 0
      gamePlaneOperator:showCards(CARD_PLAYERTYPE_MY) -- 隐藏
    end

    gamePlaneOperator:kaigang(cardValue1, cardValue2)
end


--发牌协议 0x1108
function CSMJReceiveHandle:SVR_SEND_USER_CARD(pack)

  dump(pack, "-----发牌协议-----")

  local scenes  = SCENENOW['scene']
  if SCENENOW['name'] ~= run_scene_name then
    return
  end
  require("cs_majiang.RoundEndingLayer"):hide()
  CSMJ_CONTROLLER:clearGameDatas()

  local zhuaniaoLayout = SCENENOW["scene"]:getChildByName("zhuaniaoLayout")
  if zhuaniaoLayout then
    zhuaniaoLayout:removeFromParent()
  end
  --[[local change_chip_plane = SCENENOW["scene"]._scene:getChildByName("change_chip_plane")
  change_chip_plane:setVisible(false)--]]

  SCENENOW["scene"]:showCopyBtn(false)
  SCENENOW["scene"]:showShareButton(false)
  CSMJ_GAME_STATUS = 1

  gamePlaneOperator:clearGameDatas()
  
  scenes:hideCloseRoomButton()
  scenes:ShowSettingButton()
  scenes:hideShareButton()

  gamePlaneOperator:clearAllReadyStatus()
  gamePlaneOperator:showCenterPlane()

  -- if table.getn(CSMJ_SEAT_TABLE_BY_TYPE) < 4 then
  --  --todo
  --  return
  -- end

  bm.palying = true
  bm.isRun=true

  CSMJ_ENDING_DATA = nil

  --记录庄家的座位
  bm.zuan_seat = pack.seat
  
  -- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
        --todo
        CSMJ_STATE = 2
    end
  --scenes:set_basescole_txt_visible(false)

  --隐藏解散房间按钮
  -- scenes:hidendisband()

  --隐藏用户准备标志
  -- scenes:hideAllSelect()

  --显示设置按钮
  -- scenes:ShowSettingButton()

  --开始游戏时需要移动其他玩家的信息显示位置

  --移动自己
  -- scenes:hide_self_info()

  --移动其他用户
  -- scenes:hide_otherplayer_info(1)--false表示隐藏
  -- scenes:hide_otherplayer_info(2)--false表示隐藏
  -- scenes:hide_otherplayer_info(3)--false表示隐藏

  --骰子动画
  -- aniUtils:shuaiZi(pack.shai)

  self:SchedulerSendCard(pack)

  -- bm.SchedulerPool:delayCall(CSMJReceiveHandle.SchedulerSendCard,5,pack)
    gamePlaneOperator:rotateTimer(cardUtils:getPlayerType(CSMJ_SEAT_TABLE[CSMJ_ZHUANG_UID .. ""]))


  --关闭准备按钮
    SCENENOW["scene"]:showReadyBtn(false)
end


--服务器告知客户端可以进行的操作 0x1109
function CSMJReceiveHandle:SVR_NORMAL_OPERATE(pack)

  -- dump(pack, "-----服务器告知客户端可以进行的操作-----");

  local controlTable = cardUtils:getControlTable(pack, pack.card)

  gamePlaneOperator:showControlPlane(controlTable)

  D3_CHUPAI = 2
end

--海底牌 0x1110
function CSMJReceiveHandle:SVR_HAIDI_CARD(pack)
  CSMJ_REMAIN_CARDS_COUNT = 0
  gamePlaneOperator:showRemainCardsCount()
  manyouPlaneOperator:show(pack.card, pack.uid)
end

--漫游 0x1111
function CSMJReceiveHandle:SVR_MANYOU(pack)
  if USER_INFO["uid"] == pack.uid then
    manyouPlaneOperator:show()
  else
    manyouPlaneOperator:hide()
  end
end

--出牌错误返回 0x1113
function CSMJReceiveHandle:SVR_CHUPAI_ERROR(pack)
  -- dump(SVR_CHUPAI_ERROR,"SVR_CHUPAI_ERROR333")
  local errorCode = pack.errorCode

  if errorCode == 1 then -- 不是合法的牌
    D3_CHUPAI = 1   
        -- D3_OPERATOR:revertOutCardPosition()
  elseif errorCode == 2 then -- 不是游戏进行中
    D3_CHUPAI = 1
    require("hall.GameCommon"):showAlert(true, "正在等待自己或者其他玩家操作", 200)
  elseif errorCode == 3 then -- 不是当前出牌玩家
    D3_CHUPAI = 0
  elseif errorCode == 4 then -- 手牌中没有此牌
    D3_CHUPAI = 1
        -- D3_OPERATOR:revertOutCardPosition()
  end
  
end

-- 获取上一局记录 0x1114
function CSMJReceiveHandle:G2H_GET_LAST_RECORD(pack)
  -- dump(pack,"G2H_GET_LAST_RECORD")
  require("cs_majiang.RoundEndingLayer"):show(pack,false)
end





















--接收服务器发来的距离数据
function CSMJReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)
	-- showDumpData=true

    -- dump(pack,"-------距离数据---------")   

    local msgList = pack.msgList
    --存放距离数据的数组
    
    local LocaArrayByPlayerType = {}

    for k,v in pairs(msgList) do
    	if v ~= nil and v ~= "" then
    		local msg = json.decode(v)
            if msg ~= nil then
                if msg.uid ~= nil then
                    if CSMJ_SEAT_TABLE and next(CSMJ_SEAT_TABLE)~=nil then
                    local playerType = cardUtils:getPlayerType(CSMJ_SEAT_TABLE[msg.uid.. ""])
                    LocaArrayByPlayerType[playerType] = {[1] = tonumber(msg.longitude) ,[2] = tonumber(msg.latitude)}
                    end
                    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid,msg)

                end
            end
    	end
    end
    
    if #LocaArrayByPlayerType>3 then 
       if CSMJ_GAME_STATUS ~= 1 then
         gamePlaneOperator:showDistance(LocaArrayByPlayerType,true)
       else
         gamePlaneOperator:showDistance(LocaArrayByPlayerType,false)
       end 
    end
end

function CSMJReceiveHandle:BROADCAST_USER_IP(pack)
	local playeripdata = pack.playeripdata or {}
    local new_ip_table={}
    for _,ip_data in pairs(playeripdata) do
        local ip_ = ip_data.ip or ""
        local uid_ = ip_data.uid or 0
        if uid_ ~= 0 then
            local seatId = CSMJ_SEAT_TABLE[uid_ .. ""]

            if seatId then
                if CSMJ_USERINFO_TABLE[seatId .. ""] then
                    CSMJ_USERINFO_TABLE[seatId .. ""].ip = ip_
                    new_ip_table[uid_..""] = ip_
                    
                end
            end
        end
    end

	local myIp = ""

    if CSMJ_MY_USERINFO.seat_id and CSMJ_USERINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""] then
    	myIp = CSMJ_USERINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].ip
    end


    local ipTable = {}
    for k,v in pairs(CSMJ_USERINFO_TABLE) do
    	if v.ip and v.ip ~= myIp and v.ip~= "" then
    		--todo
    		if not ipTable[v.ip] then
    			--todo
    			ipTable[v.ip] = {}
    		end
    		table.insert(ipTable[v.ip], v.nick)
    	end
    end

    local msg = ""
    for k,v in pairs(ipTable) do
    	if table.getn(v) > 1 then
    		--todo
    		for i=1,table.getn(v) do
    			msg = msg .. v[i] .. " "
    		end
    	end
    end
    
    if  CSMJ_ROUND and CSMJ_ROUND < 2 then    --重连时CSMJ_ROUND也会重置，所以自己重连时也会生效         

        if msg ~= "" then
        	--todo
        	require("hall.GameCommon"):showAlert(false, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
        	require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
        end

        local ip = new_ip_table[USER_INFO["uid"] .. ""] or ""
        sendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)
    end
end





--获取玩家显示的位置号 0自己，1左边玩家，2对家，3右边玩家
function CSMJReceiveHandle:getIndex(uid)

	if tonumber(uid) == tonumber(USER_INFO["uid"]) then
		return 0
	end
	local other_seat  = CSMJ_ROOM.User[uid]
	-- dump( CSMJ_ROOM.User, " CSMJ_ROOM.User")

	--print(other_seat,bm.User.Seat,"2")
	local other_index = other_seat - bm.User.Seat
	if other_index < 0 then
		other_index = other_index + 4
	end
	--print(other_index,"3")
	   
	if other_index == 1 then
    	other_index = 3
    elseif other_index == 3 then
    	other_index = 1 
    end

	return other_index

end



--显示倒计时器
function CSMJReceiveHandle:showTimer(uid,time)

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--设置显示计时器
	scenes:show_timer_visible(true)

	--初始化计时器
	scenes:init_clock()

	if CSMJ_ROOM.timerid then
		bm.SchedulerPool:clear(CSMJ_ROOM.timerid)
	end

	local index = self:getIndex(uid)
	scenes:show_timer_index(index)
	CSMJ_ROOM.timer   = time
	self.timecount_ = 0 
	CSMJ_ROOM.timerid = nil

	CSMJ_ROOM.timerid = bm.SchedulerPool:loopCall(function()

		self.timecount_ = self.timecount_ + 1

		if CSMJ_ROOM.timer and self.timecount_ % 5 == 0 then
			CSMJ_ROOM.timer  = CSMJ_ROOM.timer - 1
		end

		if CSMJ_ROOM.timer and CSMJ_ROOM.timer >= 0 and CSMJ_ROOM.timer <= 9 then
			local scenes  = SCENENOW['scene']
			if SCENENOW['name'] == run_scene_name and scenes.show_timer_num then
				--显示时间数字
				scenes:show_timer_num(CSMJ_ROOM.timer)
				--
				scenes:showClock(index,CSMJ_ROOM.timer,true)
			end
		end
		
		return true

	end,0.2)
	
end

--清理界面
function CSMJReceiveHandle:clearUserView(index)

	-- dump(index, "-----清理界面-----")

	-- local index   = self:getIndex(uid)
	local scenes  = SCENENOW['scene']

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	if index == 0 then
		local node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
		if node then
			node:removeSelf()
		end

		local node = scenes:getChildByName("play_info")
		if node then
			node:removeSelf()
		end

		
	else
		local node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if node then
			node:removeSelf()
		end

		local node = scenes:getChildByName("play_info"..index)
		if node then
			node:removeSelf()
		end
	end

	local node = scenes:getChildByName("cardout"..index)
	if node then
		node:removeSelf()
	end

	if CSMJ_ROOM.timerid then
		bm.SchedulerPool:clear(CSMJ_ROOM.timerid)
	end  

	local node = scenes:getChildByName("timer") 
	if node then
		node:removeSelf()
	end

	local node = scenes:getChildByName("zhuang") 
	if node then
		node:removeSelf()
	end

	local node = scenes:getChildByName("has_xuan_que") 
	if node then
		node:removeSelf()
	end

	local node    = scenes:getChildByName("user"..index)
	if node ~= nil then
		node:removeSelf()
	end

	scenes:show_tuoguan_layout(false)
	scenes:set_left_card_num_visible(false)

	bm.palying = false
	
end
-------------------------------------------------------------------------------------------------------------------

--协议相关


-------------------------------------------------------------------------------------------------------------------




-- -- 画牌到牌桌 @Jhao 临时处理
-- function afterKaiGangMsgDrawTableCard(_uid, _cardValue1, _cardValue2)
-- 	local function drawTableCard(_uid, _cardValue)
-- 		local CHILD_NAME_OUTHANDPLANE = "outhand_plane"
-- 		local seatId		= CSMJ_SEAT_TABLE[tostring(_uid)]
-- 		local playerType	= cardUtils:getPlayerType(seatId)
-- 		local parentPlane	= require("cs_majiang.operator.GamePlaneOperator"):getPlayerPlane(playerType)
-- 		local outHandPlane	= parentPlane:getChildByName(CHILD_NAME_OUTHANDPLANE)

-- 		require("cs_majiang.operator.OuthandPlaneOperator"):playCard(playerType, _cardValue, outHandPlane)
-- 	end

-- 	-- 画牌是一个action,要等画动作完成之后才能画新的牌
-- 	local sp = display.newSprite("majiang/image/quan_guo.png")
-- 	sp:setVisible(false)

-- 	local durTime		= 1.1 
-- 	local delayAction	= cc.DelayTime:create(durTime)
-- 	local seqAc	= cc.Sequence:create(cc.CallFunc:create(function() 
-- 											drawTableCard(_uid, _cardValue1) 
-- 										end),
-- 									delayAction, 
-- 									cc.CallFunc:create(function() 
-- 											drawTableCard(_uid, _cardValue2) 
-- 										end)
-- 									)
-- 	sp:runAction(seqAc)
-- end


-- 0x1106


--处理进入房间
function CSMJReceiveHandle:SVR_GET_ROOM_OK(pack_data)
	--print("---------------------------SVR_GET_ROOM_OK----------------------------------")
	-- dump(pack_data)
	--print("denglusuccess table id is ",pack_data['tid'],bm.isGroup,USER_INFO["activity_id"])

    if pack_data.tid == 0 then
        --todo
        display_scene(GameScene_filePath, 1)

        require("hall.GameTips"):showTips("提示", "", 2, "游戏已结束!")

        return
    end

	--print("group test")
	-- if not bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() ~= "group" then
		--todo
		local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
        :setParameter("tableid", pack_data['tid'])
        :setParameter("nUserId", USER_INFO["uid"])
        :setParameter("strkey", "")
        :setParameter("strinfo", USER_INFO["user_info"])
        :setParameter("iflag", 2)
        :setParameter("version", 1)
        :setParameter("activity_id","")
        :build()
    	bm.server:send(pack)
    	--print("sending----------------1001............")
	else
		--print("group test ok")

		local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
        :setParameter("tableid", pack_data['tid'])
        :setParameter("nUserId", USER_INFO["uid"])
        :setParameter("strkey", json.encode("kadlelala"))
        :setParameter("strinfo", USER_INFO["user_info"])
      	:setParameter("iflag", 2)
        :setParameter("version", 1)
        :setParameter("activity_id", USER_INFO["activity_id"])
        :build()
    	bm.server:send(pack)
    	--print("sending----------------1001............")
	end
	
end













----------------------------------------------------------------------------------------------------------------

--用户准备相关


--显示其他玩家准备
function CSMJReceiveHandle:showOtherReady(index)

	local scenes         = SCENENOW['scene']
	scenes:show_ready_bar(index,false)

end
----------------------------------------------------------------------------------------------------------------

--用户操作相关


--显示可以操作的界面
function CSMJReceiveHandle:showHandlesView(handle,card)	

	-- dump(handle,"-----显示可以操作的界面-----")
	-- dump(card,"-----显示可以操作的界面-----")

	--获取界面
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local result = MajiangcardHandle:getHandles(handle)
	local start = 420
	local has   = 1
	local width = 200

	local node = scenes:getChildByName("myhandles")
	if node then
		node:removeSelf()
	end

	node = display.newNode()
	node:addTo(scenes, 9000)
	node:setName("myhandles")
	node:setLocalZOrder(9000)

	--胡
	if result['h'] then
		has   = 0
		local path_other_hu = CARD_PATH_MANAGER:get_card_path("path_other_hu")
		local hu = display.newSprite(path_other_hu)
		hu:addTo(node)
		hu:pos(start,200)
		start = start + 133
		bm.nodeClickHandler(hu,MajiangroomServer.requestHandle,result['h'],card)
	end

	--碰和杠
	local ifpg = 0
	if result['pg'] then
		ifpg = 1
		has = 0
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local g       = display.newSprite(path_other_gang)
		g:addTo(node)
		g:pos(start,200)
		bm.nodeClickHandler(g,MajiangroomServer.requestHandle,result['pg'],card)

		start         = start + 133
		local path_other_peng = CARD_PATH_MANAGER:get_card_path("path_other_peng")
		local p       = display.newSprite(path_other_peng)
		p:addTo(node)
		p:pos(start,200)

		bm.nodeClickHandler(p,MajiangroomServer.requestHandle,0x008,card)
		start = start + 133
	end

	--碰
	if result['p'] and ifpg == 0 then
		has = 0
		local path_other_peng = CARD_PATH_MANAGER:get_card_path("path_other_peng")
		local p       = display.newSprite(path_other_peng)
		p:addTo(node)
		p:pos(start,200)
		start         = start + 133
		bm.nodeClickHandler(p,MajiangroomServer.requestHandle,result['p'],card)
	end

	--杠
	if result['g'] and ifpg == 0 then
		has   = 0
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local p       = display.newSprite(path_other_gang)
		p:pos(start,200)
		p:addTo(node)
		start         = start + 133

		--下面这几行是添加碰了的时候，我手上还有这个一个牌可以杆下的话，那么
		local find_flag =  false
		-- dump(CSMJ_ROOM.Card[0]['porg'],"porg")

		local gang = {}
		for i,v in pairs(CSMJ_ROOM.Card[0]['porg']) do
			if gang[v] == nil then 
				gang[v]=  1
			else
				gang[v]= gang[v] + 1
			end

			if v == card then
				find_flag = true-----摸到的牌是要杆的牌
			end
		end

		local hand_gang = {}
		for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do
			if hand_gang[v] == nil then 
				hand_gang[v]=  1
			else
				hand_gang[v]= hand_gang[v] + 1
			end
		end

		local hand_gang_one = false 
		if find_flag == false then -----手牌就是要杆的牌
			-- dump(CSMJ_ROOM.Card[0]['hand'],"hand")
			for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do
				if gang[v] ~= nil and gang[v] == 3  then
					card = v;
					hand_gang_one = true
					break
				end
			end
		end

		if hand_gang_one  == false and find_flag == false then
			for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do-----手牌就有四张要杆的牌
				if hand_gang[v] ~= nil and hand_gang[v] == 4  then
					card = v;
					break
				end
			end
		end
 
		bm.nodeClickHandler(p,MajiangroomServer.requestHandle,result['g'],card)
	end

	if has == 0 then
		local guo       = display.newSprite("majiang/image/quan_guo.png")
		guo:pos(start,200)
		guo:addTo(node)

		guo:setTouchEnabled(true)
        guo:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
                if event.name == "began" then
                	bm.guo_card =card 
                    require("hall.GameCommon"):playEffectSound(audio_path,false)
                    MajiangroomServer:requestHandle(0,card)
					local scenes = SCENENOW['scene']
                	local  node  = scenes:getChildByName("myhandles")
					if node then
						node:removeSelf()
					end	

					return true
                end
        end)
	end

end



--这里专门用来显示你看到的其他玩家（1，2，3）的碰杠动画显示
function CSMJReceiveHandle:pengHuGangAnim(uid,result)

	-- dump(uid,"-----显示你看到的其他玩家（1，2，3）的碰杠动画显示-----")
	-- dump(result,"-----显示你看到的其他玩家（1，2，3）的碰杠动画显示-----")

	local scenes = SCENENOW['scene']
	local index  = self:getIndex(uid)

	local config = {[1] = {['x'] = 300,['y'] = 300},
					[2] = {['x'] = 500,['y'] = 450},
					[3] = {['x'] = 750,['y'] = 300}
	}

	local  node  = scenes:getChildByName("pghuamin")

	if node then
		node:removeSelf()
	end

	node = display.newNode()
	node:addTo(scenes)
	node:setName("pghuamin")
	node:setLocalZOrder(2000)

	local object = nil

	if result['g'] or result['pg'] then
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local object       = display.newSprite(path_other_gang)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)
	end

	if result['p']then
		local path_other_peng = CARD_PATH_MANAGER:get_card_path("path_other_peng")
		local object       = display.newSprite(path_other_peng)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)
	end

	if result['h']then
		local path_other_hu = CARD_PATH_MANAGER:get_card_path("path_other_hu")
		local object      = display.newSprite(path_other_hu)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)
	end

	bm.SchedulerPool:delayCall(function ()
		if tolua.isnull(SCENENOW['scene'])==true then
			--todo
			return;
		end
		local n=SCENENOW['scene']:getChildByName("pghuamin")
		if n then
			--todo
			n:removeSelf()
		end
		
	end,1)

end

--显示上次动作
function CSMJReceiveHandle:showLastEvent()

	-- dump("","-----显示上次动作-----")

	local scenes    = SCENENOW['scene']
	if CSMJ_ROOM.last == "chupai" then
		local chu       = scenes:getChildByName("chu")
		if chu then
			local fade = cc.FadeOut:create(0.5)
			chu:runAction(fade)
		end
		
		MajiangcardHandle:insertCardTo(CSMJ_ROOM.Card[CSMJ_ROOM.index]['out'],{CSMJ_ROOM.card_value})
		bm.SchedulerPool:delayCall(CSMJReceiveHandle.drawOut,0.5,CSMJ_ROOM.index)
		-- self:sendOtherPlayerCard(CSMJ_ROOM.index)
		bm.SchedulerPool:delayCall(function()
			if tolua.isnull(scenes) == false then
				local chu       = scenes:getChildByName("chu")
				if chu then
					chu:removeSelf()
				end
			end
		end,0.5)
		
	end

	if  CSMJ_ROOM.last == "otherhand"  then

		local chu       = scenes:getChildByName("chu")
		if chu then
			chu:removeSelf()
		end

	end

end
---------------------------------------------------------------------------------------------------------------

--托管相关
--广播用户托管
function CSMJReceiveHandle:SVR_ROBOT(pack)

    dump(pack,"-----广播用户托管-----")

    --local scenes = SCENENOW['scene']
    --if SCENENOW["name"] ~= run_scene_name then
    --    return
    --end

    if pack.uid == UID then
        local scenes  = SCENENOW['scene']
        if  pack.kind  == 1 then
            scenes:TgState(true)
            --CS_ROOM.tuoguan_ing = 1
            -- scenes:show_tuoguan_layout(true)
        else
            scenes:TgState(false)
            --CS_ROOM.tuoguan_ing = 0
            -- scenes:show_tuoguan_layout(false)
        end
    end

end
-------------------------------------------------------------------------------------------------------------------

--发牌相关


--发牌
function CSMJReceiveHandle:SchedulerSendCard(pack)

	CSMJReceiveHandle:initCardForUser(pack)
  -- dump(CSMJ_SEAT_TABLE_BY_TYPE,"CSMJReceiveHandle:SchedulerSendCard(pack)")

  -- k是 playerType 就是上下左右   1，2, 3，4
  dump(CSMJ_SEAT_TABLE_BY_TYPE,"=CSMJ_SEAT_TABLE_BY_TYPE")
  for k,v in pairs(CSMJ_SEAT_TABLE_BY_TYPE) do
    local tempK = tonumber(k)
    CSMJReceiveHandle:showPlayerCards(tempK)
  end

	-- for i=0,CS_PLAYERNUM-1 do
	-- 	CSMJReceiveHandle:showPlayerCards(i)
	-- end

	--显示庄家
	-- CSMJReceiveHandle:showZhuang(pack.seat)

  --getPlayerType得到位置类型 如 CARD_PLAYERTYPE_MY = 1  CARD_PLAYERTYPE_LEFT = 2
	local playerType = cardUtils:getPlayerType(pack.seat)

  --把庄家uid 标记出来
	CSMJ_ZHUANG_UID = CSMJ_USERINFO_TABLE[pack.seat .. ""].uid

  --把庄家标识展示出来     这个playerType 就是庄家客户端位置
	gamePlaneOperator:showZhuang(playerType)

end

--发牌
-- function CSMJReceiveHandle:sendCard(pack)

-- 	MajiangcardHandle:setMyCards(pack.cards)
-- 	MajiangcardHandle:sortCards()
-- 	self:showMyHandMajiang()

-- end

--牌库初始化
function CSMJReceiveHandle:initCardForUser(pack)
	for i=0,3 do
		local gameInfo = {}
		gameInfo.porg = {}
		gameInfo.hand = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		gameInfo.out = {}

    -- 2020/10/27
    gameInfo.qishouhu = false
		-- CSMJ_ROOM.Gang[i]         = {}

		CSMJ_GAMEINFO_TABLE[i .. ""] = gameInfo
	end

	local myCards = pack.cards

	table.sort(myCards)

	CSMJ_GAMEINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].hand = myCards	--0号玩家的手牌

	-- dump(CSMJ_GAMEINFO_TABLE, "cards test ")
end

--显示玩家的牌
function CSMJReceiveHandle:showPlayerCards( seatId )

	-- CSMJReceiveHandle:drawHandCard(index)
	-- CSMJReceiveHandle:drawOut(index)


  --把隐藏的牌亮出来 seatId这里是1-4
  --这里先屏蔽不转换看看 2020/10/28
	-- local playerType = cardUtils:getPlayerType(seatId)
 --  if playerType then
 --      --dump("CSMJReceiveHandle:showPlayerCards seatId="..seatId.." playerType="..playerType.." CSMJ_MY_USERINFO.seat_id="..CSMJ_MY_USERINFO.seat_id)
 --      gamePlaneOperator:showCards(playerType)
 --  end


  --直接调用看看 ok 逻辑正确
  if seatId then
      gamePlaneOperator:showCards(seatId)
  end
  
	-- dump(CSMJ_GAMEINFO_TABLE, "cards test 11")



end

--显示庄家
function CSMJReceiveHandle:showZhuang(seat)

	local uid = USER_INFO["uid"]

	if seat ~= bm.User.Seat then
		uid = CSMJ_ROOM.seat_uid[seat]
	end

	local index = self:getIndex(uid)
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_widget_tip(index,true,"zuan_tip")

end

--显示手牌
function CSMJReceiveHandle:drawHandCard(index)
	
	--获取界面
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if index == 0 then

		--自己

		-- CSMJ_ROOM.Card[0]['porg'] = {0x01,0x01,0x01,0x01}
  		-- CSMJ_ROOM.Card[0]['hand'] = {0x11,0x12,0x13,0x14,0x15,0x16,0x02,0x02,0x02}
		-- CSMJ_ROOM.Gang[0][0x01] = 1

		--获取碰的牌
		CSMJ_ROOM.Card[index]['porg'] = MajiangcardHandle:sortCards(CSMJ_ROOM.Card[index]['porg'])

		--获取手牌
		CSMJ_ROOM.Card[index]['hand'] = MajiangcardHandle:sortCards(CSMJ_ROOM.Card[index]['hand'])

		--获取牌的显示区域
		local layer_card = scenes._scene:getChildByName("layer_card")

		--移除用户所有手牌
		local card_node = layer_card:getChildByName("owncard")
		if card_node then
			card_node:removeSelf()
		end

		local card_node = display.newNode()
		card_node:addTo(layer_card)
		card_node:setName("owncard")
		card_node:setLocalZOrder(1150)

		local huase = {	[0] = 0, [1] = 0, [2] = 0,}
		local s_point  = 119.00
		local y_ponit  = 50.00
		local y        = 0
		local pi       = 1
		local count    = 0
		local gang_num = 0
		local width    = 0 
		local my_point = 0
		local an_gang  = 0

		--绘制碰和杠的牌
		for i,v in pairs(CSMJ_ROOM.Card[index]['porg']) do

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			tmp:setScale(1.862, 1.521)
			y = y_ponit

			-- my_point = s_point + (pi - 1) * (54 * 0.8 - 6)
			my_point = s_point + (pi - 1) * 54
			if CSMJ_ROOM.Gang[index][v] then

				if CSMJ_ROOM.Gang[index][v] == 1 then
					tmp:setMyBlack()
					-- tmp:setScale(0.8,0.8383)
					-- my_point = s_point+(pi-1)*(54*0.8 - 6)
					my_point = s_point + (pi-1) * 54
				end

				count = count + 1

				if count == 4 then
					tmp:setMyOutCard()
					-- tmp:setScale(0.8,0.8383)
					gang_num = gang_num +1
					-- my_point = s_point+(pi-3)*(54*0.8 - 6)
					my_point = s_point + (pi-3) * 54
					y  = y_ponit + 15
					count = 0
					pi =pi -1
				end

			else
				count = 0
			end

			tmp:pos(my_point, y-10)
			tmp:addTo(card_node)
			
			pi = pi + 1

		end

		--绘制手牌
		--local s_point  = 148.83
		-- local start = (#CSMJ_ROOM.Card[index]['porg'] - gang_num * 4 ) * (54 * 0.8 - 6) + gang_num * 3 * (54 * 0.8 - 6) + s_point
		local start = (#CSMJ_ROOM.Card[index]['porg'] - gang_num * 4 ) * 54 + gang_num * 3 * 54 + s_point
		local pi = 1
		local last_card_pos_x = 0
		for i,v in pairs(CSMJ_ROOM.Card[index]['hand']) do 
			----print("inex:"..i)
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyHandCard()
			-- tmp:setScale(0.8,0.8383)
			-- tem:setScaleY()
			--tmp:dark()
			-- last_card_pos_x = start+(pi-1)*(54*0.8 - 6)
			last_card_pos_x = start+(pi-1) * 54
			tmp:pos(last_card_pos_x,y_ponit)
			tmp:setName(i)
			tmp:addTo(card_node)
			huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
			pi = pi + 1

		end

		if CSMJ_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(CSMJ_ROOM.Card[index]['hu'])
			tmp:setMyOutCard()
			tmp:pos(877.03,44.00)--877.03,104.61
			tmp:addTo(card_node)
		end

		local min = nil 
		local se  = nil
		for i,v in pairs(huase) do
			if min == nil then
				min = v
				se  = i
			else
				if min > v then
					min = v
					se  = i
				end
			end
		end
		bm.User.Pque = se

	end
	
	if index == 1 then

		--左边玩家

		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node then
			card_node:removeSelf()
		end

		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("othercard"..index)


		local cout_s_point = 485.00
		local x_ponit = 143.00

		local pi      = 1
		local count    = 0
		local gang_num = 0
		-- dump(CSMJ_ROOM.Card[index]['porg'])
		-- dump(CSMJ_ROOM.Gang[index])

		-- CSMJ_ROOM.Card[1]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04,0x04}
  		-- CSMJ_ROOM.Card[1]['hand'] = {1}--{0x01,0x01,0x01}
		-- CSMJ_ROOM.Gang[1][0x01] = 0
		-- CSMJ_ROOM.Gang[1][0x02] = 0
		-- CSMJ_ROOM.Gang[1][0x03] = 0

		--绘制碰和杠的牌
		local last_y_pos = 0
		for i,v in pairs(CSMJ_ROOM.Card[index]['porg']) do
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setLeftOutCard()
			-- tmp:setScale(0.54,0.45)
			local my_point = cout_s_point-(pi-1)*(17.72)
			last_y_pos = cout_s_point-(pi-1)*(17.72)
			if CSMJ_ROOM.Gang[index][v] then
				if CSMJ_ROOM.Gang[index][v] == 1 then
					tmp:setLeftBlack()
					tmp:setScale(1)
				end
				count = count + 1
				if count == 4 then
					tmp:setLeftOutCard()
					-- tmp:setScale(0.54,0.45)
					gang_num = gang_num + 1
					my_point =  cout_s_point-(pi-3)*(17.72)
					count = 0
					pi = pi -1
				end
			else
				count = 0
			end  
			tmp:pos(x_ponit,my_point)
			tmp:addTo(card_node)
			pi = pi + 1
		end

		--绘制手牌
		start = cout_s_point
		if last_y_pos ~= 0 then
			start = last_y_pos - 30
		end

		local pi    = 1
		for i,v in pairs(CSMJ_ROOM.Card[index]['hand']) do 
			local tmp = Majiangcard.new()
			if v == 0 then --0标示，这个牌是在打的状态，显示的是背面
				tmp:setLeftHand()
				tmp:pos(x_ponit,start - (pi-1) * 22)
				last_y_pos = start - (pi-1) * 22
			else
				tmp:setCard(v)
				tmp:setLeftOutCard()
				-- tmp:setScale(0.54,0.45)
				tmp:pos(x_ponit,start - (pi-1)*17.72)--手牌自摸
				last_y_pos =start - (pi-1)*17.72
			end
			tmp:addTo(card_node)
			tmp:setName(i)
			pi = pi + 1
		end
		
		if CSMJ_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(CSMJ_ROOM.Card[index]['hu'])
			tmp:setLeftOutCard()
			-- tmp:setScale(0.54,0.45)
			tmp:pos(x_ponit,last_y_pos - 30)
			tmp:addTo(card_node)
		end

	end

	if index == 2 then

		--对家

		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node then
			card_node:removeSelf()
		end

		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("othercard"..index)

		local s_point = 766.00
		local y_ponit = 497.00
	
		local pi      = 1

		--绘制碰和杠的牌
		local count    = 0
		local gang_num = 0
		local item_width = 30
		local item_heigth = 42

		-- CSMJ_ROOM.Card[2]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04,0x04}
  --  		CSMJ_ROOM.Card[2]['hand'] = {0x01,0x01,0x01}
		-- CSMJ_ROOM.Gang[2][0x01] = 1
		-- CSMJ_ROOM.Gang[2][0x02] = 1
		-- CSMJ_ROOM.Gang[2][0x03] = 1

		-- dump(CSMJ_ROOM.Card[index]['porg'],"porg_card_index_2")

		local last_posss = 0
		for i,v in pairs(CSMJ_ROOM.Card[index]['porg']) do

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.48)
			-- local my_point = s_point-(pi-1)*(74*0.4 -2)
			local my_point = s_point - (pi-1) * 27
			last_posss = my_point
			local less = 0
			if CSMJ_ROOM.Gang[index][v] then

				if CSMJ_ROOM.Gang[index][v] == 1 then
					tmp:setTopBlack()
				end

				count = count + 1

				if count == 4 then
					tmp:setMyOutCard()
					gang_num = gang_num + 1
					-- my_point =  s_point-(pi-3)*(74*0.4 -2)
					my_point =  s_point - (pi-3) * 27
					count    =  0 
					pi       = pi -1
					less 	 = 10
				end

			else
				count = 0
			end 
			tmp:pos(my_point, y_ponit + less)
			tmp:addTo(card_node)
			pi = pi + 1

		end

		--绘制手牌
		local start = s_point
		if last_posss ~= 0 then
			start = last_posss - 30
		end
		
		local pi = 1
		for i,v in pairs(CSMJ_ROOM.Card[index]['hand']) do 

			local tmp = Majiangcard.new()

			if v == 0 then
				tmp:setTopHandCard()
				tmp:pos(start - (pi-1) * 30, y_ponit)
				last_posss = start - (pi-1) * 30
			else
				tmp:setCard(v)
				tmp:setMyOutCard()
				-- tmp:setScale(0.4,0.48)
				-- tmp:pos(start-(pi-1)*(74*0.4-2),y_ponit)
				tmp:pos(start - (pi-1) * 54, y_ponit)
				-- last_posss = start-(pi-1)*(74*0.4-2)
				last_posss = start - (pi-1) * 54
			end
			
			tmp:addTo(card_node)
			tmp:setName(i)
			pi = pi + 1

		end

		--CSMJ_ROOM.Card[2]['hu'] = 0x02
		if CSMJ_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(CSMJ_ROOM.Card[index]['hu'])
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.48)
			tmp:pos(last_posss - 40, y_ponit)
			tmp:addTo(card_node)
		end

	end

	if index == 3 then

		--右边玩家

		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node then
			card_node:removeSelf()
		end

		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("othercard"..index)


		local hand_width = 23
		local hand_heigth = 56
		local cout_width = 36
		local cout_heigth = 30

		local s_point  = 158.00
		local x_ponit  = 820.00
		local pi       = 1
		local count    = 0
		local gang_num = 0
		local c        = 2000

		-- CSMJ_ROOM.Card[3]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03}
  		-- CSMJ_ROOM.Card[3]['hand'] = {0x01,0x01,0x01,0x01}
		-- CSMJ_ROOM.Gang[3][0x01] = 1
		-- CSMJ_ROOM.Gang[3][0x02] = 1
		-- CSMJ_ROOM.Gang[3][0x03] = 0

		local last_ppos = 0
			--绘制碰和杠的牌
		for i,v in pairs(CSMJ_ROOM.Card[index]['porg']) do
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setRightOutCard()
			-- tmp:setScale(0.54,0.45)
			tmp:zorder(c-pi)
			local my_point = s_point+(pi-1) * 17.72
			if CSMJ_ROOM.Gang[index][v] then
				if CSMJ_ROOM.Gang[index][v] == 1 then
					tmp:setLeftBlack()
					tmp:setScale(1)
				end
				count = count + 1
				if count == 4 then
					tmp:setRightOutCard()
					-- tmp:setScale(0.54,0.45)
					gang_num = gang_num +1
					my_point = s_point+(pi-3) * 17.72
					tmp:zorder(c+pi)
					count = 0
					pi = pi - 1
				end
			else
				count = 0
			end  
			tmp:pos(x_ponit,my_point)
			last_ppos = my_point
			tmp:addTo(card_node)
			pi = pi + 1
		end

		--绘制手牌
		if last_ppos ~= 0 then
			s_point     =  last_ppos + 30
		end
		
		local   c   =  1000
		
		local pi    = 1
		local last_y_pos = 0
		for i,v in pairs(CSMJ_ROOM.Card[index]['hand']) do 
			local tmp = Majiangcard.new()
			if v ==  0 then
				tmp:setRightHand()
				last_y_pos = s_point+(pi-1) * 22
				tmp:pos(x_ponit,s_point+(pi-1) * 22)  --手牌
			else
				tmp:setCard(v)
				tmp:setRightOutCard()
				-- tmp:setScale(0.54,0.45)
				tmp:pos(x_ponit,s_point+(pi-1)*17.72)--手牌自摸
				last_y_pos = s_point+(pi-1)*17.72
			end

			tmp:addTo(card_node) 
			tmp:zorder(c-pi)
			tmp:setName(i)
			pi = pi + 1

		end

		--CSMJ_ROOM.Card[index]['hu'] = 0x01
		if CSMJ_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(CSMJ_ROOM.Card[index]['hu'])
			tmp:setRightOutCard()
			-- tmp:setScale(0.54,0.45)        
			tmp:pos(x_ponit,last_y_pos + 30)
			tmp:addTo(card_node)
		end
	end

end

--绘出玩家已经出的牌
function CSMJReceiveHandle:drawOut(index)

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if tolua.isnull(SCENENOW['scene']) then
		return
	end

	local scenes    = SCENENOW['scene']
	local card_node = scenes:getChildByName("cardout"..index)
	if card_node  then
		card_node:removeSelf()
	end

	card_node = display.newNode():addTo(scenes)
	card_node:setName("cardout"..index)

	--自己
	if index == 0 then
		--CSMJ_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		--绘制已经出的牌
		local item_width = 27.00
		local item_heigth = 31.00

		local x_start = 302.00
		local y_start = 122.00

		local pi      = 1
		local count   = 1
		local all     = 100
		for i,v in pairs(CSMJ_ROOM.Card[index]['out']) do 

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.5)
			tmp:pos( x_start + (pi-1) * item_width, y_start + (count-1) * item_heigth)
			tmp:addTo(card_node,all)
			all = all -1

			pi = pi + 1
			if pi > 11 then
				pi = 1
				count =count +1
			end
		end
	end

	--左边
	if index == 1 then
		local item_width = 36.00
		local item_heigth = 23.00
		local x_start = 191.00
		local y_start = 442.00
		local pi      = 1
		local count   = 1
        --CSMJ_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		for i,v in pairs(CSMJ_ROOM.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setLeftOutCard()
			-- tmp:setScale(0.5)
			tmp:pos(x_start + (count-1) * item_width, y_start - (pi-1) * (item_heigth))
			tmp:addTo(card_node)

			pi = pi + 1
			if pi > 12 then
				pi = 1
				count = count + 1
			end
		end
	end

	--对家
	if index == 2 then
		--CSMJ_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		local item_width = 27.00
		local item_heigth = 31.00

		local x_start = 647.00
		local y_start = 448.00
		local pi      = 1
		local count   = 1

		for i,v in pairs(CSMJ_ROOM.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.5)
			tmp:pos(x_start-(pi-1)*item_width,y_start-(count-1)*item_heigth)
			tmp:addTo(card_node)
			pi = pi + 1
			if pi > 11 then
				pi = 1
				count = count +1
			end
		end
	end

	--右边
	if index == 3 then
		--CSMJ_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		local x_start = 774.00
		local y_start = 170.00
		local item_width = 36.00
		local item_heigth = 23.00
		local pi      = 1
		local count   = 1
		local zorder_z = 1000
		for i,v in pairs(CSMJ_ROOM.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setRightOutCard()
			-- tmp:setScale(0.5)
			tmp:pos(x_start-(count-1)*item_width,y_start+(pi-1)*(item_heigth))
			tmp:addTo(card_node)
			tmp:zorder(zorder_z-pi)
			pi = pi + 1
			if pi > 12 then
				pi = 1
				count =count +1
			end
		end
	end

end

--重新显示牌
function  CSMJReceiveHandle:showMyHandMajiang()
	local scenes    = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
	if card_node == nil then
		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("owncard")
	end
	local count = #bm.User.Mycards
	local start = (CONFIG_SCREEN_WIDTH -  count * 82*0.7)/2
	local pi    = 1
	local huase = {
		[0] = 0,
		[1] = 0,
		[2] = 0,
	}

	for i,v in pairs(bm.User.Mycards) do
		local tmp = Majiangcard.new()
		tmp:setCard(v)
		tmp:setScale(0.7)
		tmp:setMyHandCard()
		tmp:dark()
		tmp:addTo(card_node)
		tmp:pos(start+(pi-1) * 82 * 0.7, 60)
		huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
		pi = pi +1
	end

	local min = nil 
	local se  = nil
	for i,v in pairs(huase) do
		if min == nil then
			min = v
			se  = i
		else
			if min > v then
				min = v
				se  = i
			end
		end
	end
	bm.User.Pque = se

end
----------------------------------------------------------------------------------------------------------------

--换牌相关
--服务器告诉客户端，可以换牌
function CSMJReceiveHandle:SERVER_COMMAND_NEED_CHANGE_CARD(pack)

	-- dump(pack, "-----可以换牌-----")

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	CSMJ_ROOM.change_card_over = false
	-- dump(pack, "SERVER_COMMAND_NEED_CHANGE_CARD")
	CSMJ_ROOM.cardHuan={};
	bm.huanCardsStart = true

	scenes:show_Text_18(true)

	local txtTimer = display.newBMFontLabel({
	    text = 10,
	    font = "majiang/image/num2.fnt",
	})
	scenes._scene:getChildByName("layer_card"):addChild(txtTimer, 100000)
	txtTimer:setPositionX(487)
	txtTimer:setPositionY(185)

	--换牌倒计时
	local timer = 10 
	local ac = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
			timer=timer-1
			txtTimer:setString(timer)
			if timer==0 then

				txtTimer:stopAllActions();
				txtTimer:removeFromParent();

				scenes:show_Text_18(false)

			end
		end)))
	txtTimer:runAction(ac)

end

--服务器广播换牌的结果
function CSMJReceiveHandle:SERVER_COMMAND_CHANGE_CARD_RESULT(pack)

	-- dump(pack, "-----服务器广播换牌的结果-----")

	local scenes  = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_Text_18(false)

	CSMJ_ROOM.change_card_over = true
	--CSMJ_ROOM.cardHuan = CSMJ_ROOM.cardHuan or {} -- 可能存在没有换的状况

	local old_hand_card = CSMJ_ROOM.Card[0]['hand']
	-- dump(old_hand_card,"old_hand_card") 
	if pack.mount > 0 then
		--0号玩家的手牌
		CSMJ_ROOM.Card[0]['hand'] = pack.cards	
		self:drawHandCard(0)
	end

	-- dump(CSMJ_ROOM.Card[0]['hand'],"-----当前用户换牌后的新手牌-----") 

	CSMJ_ROOM.Card[0]['hand'] = MajiangcardHandle:sortCards(CSMJ_ROOM.Card[0]['hand'])

	local gang_num  = 0
	local scenes = SCENENOW['scene']
	local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
	if card_node  then card_node:removeSelf() end
	card_node = display.newNode()
	card_node:addTo(scenes._scene:getChildByName("layer_card"))
	card_node:setName("owncard")
	card_node:setLocalZOrder(50)

	local s_point  = 119.00
	local y_ponit  = 44.00

	local start = 119.00
	local pi    = 1

	local time_index  = 1
	for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do 

		local tmp = Majiangcard.new()
		tmp:setCard(v)
		tmp:setMyHandCard()
		-- tmp:setScale(0.8,0.8383)
		-- tmp:dark()
		local find_index = table.indexof(old_hand_card,v)
		if find_index == false then
			-- tmp:pos(start+(pi-1)*(74*0.8 - 6),y_ponit + 40)
			tmp:pos(start + (pi-1) * 54, y_ponit + 40)
			tmp:moveBy(1, 0, -40)
		else
			table.remove(old_hand_card,find_index)
			-- tmp:pos(start+(pi-1)*(74*0.8 - 6),y_ponit)
			tmp:pos(start+(pi-1) * 54, y_ponit)
		end

		tmp:setName(i)
		tmp:addTo(card_node)
		--huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
		pi = pi + 1

	end

	SCENENOW['scene']._scene:getChildByName("Button_11"):hide()
	SCENENOW['scene']._scene:getChildByName("Button_11_0"):hide()

	bm.huanCardsStart = false;

end
----------------------------------------------------------------------------------------------------------------------------------

--选缺相关
--开始选择缺门
function  CSMJReceiveHandle:SVR_START_QUE_CHOICE(pack)

	-- dump(pack,"-----开始选择缺门-----")

	local scenes  = SCENENOW['scene']


	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	scenes:show_other_xuanqueing(true)
	scenes:show_choosing_que(true)
	
end

--广播缺一门  通知用户选缺选了哪一门,这时游戏还没有开始，
function CSMJReceiveHandle:SVR_BROADCAST_QUE(pack)

	-- dump(pack,"-----广播缺一门-----")


	bm.User.Que = nil
	CSMJ_ROOM.Que = true

	for i,v in pairs(pack.content) do
		self:hasChoiceQue(v.uid,v.que)
	end

end

--设置已经选缺
function CSMJReceiveHandle:hasChoiceQue(uid,que)

	-- dump(uid,"-----设置已经选缺-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if uid == USER_INFO["uid"] then
		--print("uid------------------que",que)
		bm.User.Que = que
	end

	local index  = self:getIndex(uid)
	local str = CARD_PATH_MANAGER:get_que_tip(que)
	scenes:show_widget_tip(index,true,"que_tip",str,cc.rect(0,0,36,36),1.0)
	
	scenes:show_other_xuanqueing_index(index,false)

	--que是0，1,2万筒条

	scenes:show_hasselect(index,true)
	if scenes:check_all_select() == true then
		scenes:showwaitingotherchoose(false)

		scenes:show_hasselect(0,false)  --隐藏所有的已选“筒”，“条”
		scenes:show_hasselect(1,false)
		scenes:show_hasselect(2,false)
		scenes:show_hasselect(3,false)
	end

	scenes:hideAllSelect()

end
----------------------------------------------------------------------------------------------------------------

--抓牌相关




--显示其他人抓牌
function CSMJReceiveHandle:zhuaMajiang(index)

	-- dump(index,"-----显示其他人抓牌-----")

	local scenes  = SCENENOW['scene']
	--local  index =  self:getIndex(uid)

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if index == 1 then
		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node == nil then
			card_node = display.newNode()
			card_node:addTo(scenes._scene:getChildByName("layer_card"))
			card_node:setName("othercard"..index)
		end

		local tmp = Majiangcard.new()
		tmp:setLeftHand()
		tmp:pos(124.00, 195.00)
		tmp:addTo(card_node)
		tmp:setName("zhua")

	end

	if index == 2 then
		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node == nil then
			card_node = display.newNode()
			card_node:addTo(scenes._scene:getChildByName("layer_card"))
			card_node:setName("othercard"..index)
		end

		local tmp     =  Majiangcard.new()
		tmp:setTopHandCard()
		tmp:pos(373.00, 505.00)
		tmp:setName("zhua")
		tmp:addTo(card_node)	
	end

	if index == 3 then
		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node == nil then
			card_node = display.newNode()
			card_node:addTo(scenes._scene:getChildByName("layer_card"))
			card_node:setName("othercard"..index)
		end
		
		local tmp = Majiangcard.new()
		tmp:setRightHand()
		tmp:pos(839.00, 485.00)
		tmp:setName("zhua")
		tmp:addTo(card_node)
	
	end

end
---------------------------------------------------------------------------------------------------------------

--出牌相关
--显示我的牌哪些可以出，去掉暗化
function CSMJReceiveHandle:anyCanOut(node)

	-- dump(node,"-----显示我的牌哪些可以出，去掉暗化-----")

	local scenes    = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local que_num = 0 
	for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do
		local huase     = Majiangcard:getVariety(v)
		if huase == bm.User.Que then
			que_num = que_num + 1
		end
	end

	--print("que_num==================",que_num)
	-- dump(CSMJ_ROOM.Card[0]['hand'])
	if que_num ~= 0 then
		for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do
			local huase     = Majiangcard:getVariety(v)
			local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
			local card_tmp = card_node:getChildByName(i) 
			if huase == bm.User.Que then
				if card_tmp then 
					card_tmp:setMyHandCard()
				end
			else
				if card_tmp then card_tmp:dark() end
			end
		end

		if node  then
			--todo
			if node.cardVariety_ ~= bm.User.Que then
				node:dark()
			end
		end
		
	end

end

--从手中出牌
function CSMJReceiveHandle:canoutFromHand()

	-- dump("","-----从手中出牌-----")

	local scenes    = SCENENOW['scene']
	if SCENENOW['name']~= run_scene_name then
		return
	end

	local count = 0
	for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do
			local huase     = Majiangcard:getVariety(v)
			local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
			if huase == bm.User.Que then
				local card_tmp = card_node:getChildByName(i) 
				card_tmp:setMyHandCard()
				count = count +1
			end
	end

	if count == 0 then
		for i,v in pairs(CSMJ_ROOM.Card[0]['hand']) do
				
				local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
				local card_tmp = card_node:getChildByName(i) 
				card_tmp:setMyHandCard()
				
		end
	end

end 


---------------------------------------------------------------------------------------------------------------


--广播刮风下雨（返回）杠
function CSMJReceiveHandle:SVR_GUFENG_XIAYU(pack)

	-- dump(pack, "-----广播刮风下雨-----");

	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local config = {[0]={['x'] = 480,['y'] = 200,},
					[1]={['x'] = 300,['y'] = 250,},--左
					[2]={['x'] = 480,['y'] = 450,},--上
					[3]={['x'] = 750,['y'] = 300,},--右
	}

	local node = display.newNode()
	local userid_index = self:getIndex(pack.userid)

	local action_deley = cc.DelayTime:create(1.5)
	local action_removeself = cc.RemoveSelf:create()
	local action_sequence = cc.Sequence:create(action_deley,action_removeself)

	if pack.gangType == 1 then
		local guafeng = CARD_PATH_MANAGER:get_card_path("guafeng")
		local object  = display.newSprite(guafeng)
		
		object:pos(config[userid_index].x,config[userid_index].y)
		object:addTo(scenes)
		object:runAction(action_sequence)

	elseif pack.gangType ==2 then
		local xiayu = CARD_PATH_MANAGER:get_card_path("xiayu")
		local object  = display.newSprite(xiayu)
		object:pos(config[userid_index].x,config[userid_index].y)
		object:addTo(scenes)
		object:runAction(action_sequence)
	else
		--print("....error..............pack.gangType............",pack.gangType)
	end


	local path_font_res = CARD_PATH_MANAGER:get_card_path("path_font_res")
	local wingold = tostring(pack.wingold)
	local label = display.newBMFontLabel({
	    text = wingold,
	    font = path_font_res,
	})
	label:pos(config[userid_index].x,config[userid_index].y)
	label:addTo(node)


	if pack.czgangType == 1 then
		local index = self:getIndex(pack.fuqianUserId)
		local wingold = tostring(pack.fuqiannum)
		local path_font_res = CARD_PATH_MANAGER:get_card_path("path_font_res")
		local label = display.newBMFontLabel({
		    text = wingold,
		    font = path_font_res,
		})
		label:pos(config[index].x,config[index].y)
		label:addTo(node)


	elseif pack.czgangType == 0 then
		for _,sheMoenydate in pairs(pack.sheMoenydate) do
			local index = self:getIndex(sheMoenydate.userid)
			local wingold = tostring(sheMoenydate.userPaymoney)
			local path_font_res = CARD_PATH_MANAGER:get_card_path("path_font_res")
			local label = display.newBMFontLabel({
			    text = wingold,
			    font = path_font_res,
			})
			label:pos(config[index].x,config[index].y)
			label:addTo(node)
		end		
	end


	local action_move = cc.MoveBy:create(1,cc.p(0,100))
	local action_fadeout = cc.Sequence:create(action_move,cc.FadeOut:create(0.3),cc.RemoveSelf:create())
	--local action_swpan =cc.Spawn:create(action_move,action_fadeout)
	node:runAction(action_fadeout)
	node:addTo(scenes)

end
---------------------------------------------------------------------------------------------------------------

--胡牌
--胡牌协议
function CSMJReceiveHandle:SVR_HUPAI_BROADCAST(pack)

	dump(pack,"-----胡牌协议-----")

  CSMJ_GAME_STATUS = 0


  local seatId = pack.seatId
  local playerType = cardUtils:getPlayerType(seatId)
  gamePlaneOperator:showCardsForHu(playerType, pack.remainCards,0)

  --加入判断是不是起手胡 需要知道是不是起手胡 注意服务器发过来的seatID 服务器是0-3 客户端是1-4 还有显示位置1-4
  --2020/10/27

  local isQishouHu = pack.isQishouHu
  --print("-----起手胡 seatId="..seatId.."isQishouHu:"..isQishouHu)
  if isQishouHu == 1 and CSMJ_GAMEINFO_TABLE[seatId..""].qishouhu ~= nil and not CSMJ_GAMEINFO_TABLE[seatId..""].qishouhu then

      --print("-----起手胡成功赋值")

      CSMJ_GAMEINFO_TABLE[seatId..""].qishouhu = true
  end

  


  --if  CSMJ_GAMEINFO_TABLE[seatId .. ""] and CSMJ_GAMEINFO_TABLE[seatId .. ""].isShowCards then
  --    SCENENOW['scene']:performWithDelay(
  --        function()
  --            if CSMJ_GAMEINFO_TABLE[seatId .. ""] and CSMJ_GAMEINFO_TABLE[seatId .. ""].isShowCards then
  --                gamePlaneOperator:showCards(playerType)
  --            end
  --        end, 3)
  --end

end

--显示自摸
function CSMJReceiveHandle:show_zimo_tip(index,hu_type)

	-- dump(index,"-----显示自摸-----")
	-- dump(hu_type,"-----显示自摸-----")

	local config = {
		[0] = {['x'] = 480,['y'] = 185},
		[1] = {['x'] = 320,['y'] = 306},
		[2] = {['x'] = 480,['y'] = 380},
		[3] = {['x'] = 610,['y'] = 306}	
		}

	local scenes  = SCENENOW['scene']

	if SCENENOW["name"]~= run_scene_name then
		return
	end
	
	local object    = scenes:getChildByName("hashu"..index)
	if object then
		object:removeSelf()
	end

	local pos_x,pos_y = scenes:gettimerpos()
	if hu_type == 1 then
		local path_hu = CARD_PATH_MANAGER:get_card_path("path_hu")
	 	local object  = display.newSprite(path_hu)
		object:addTo(scenes)
		object:pos(config[index]['x'],config[index]['y'])

		 if index == 0 then
		 	show_zimo_effect(scenes,pos_x,pos_y,hu_type)
		 end
	end

	if hu_type == 2 then
		 local path_zimo = CARD_PATH_MANAGER:get_card_path("path_zimo")
		 local object  = display.newSprite(path_zimo)
		 object:addTo(scenes)
		 object:pos(config[index]['x'],config[index]['y'])

		 if index == 0 then
		 	show_zimo_effect(scenes,pos_x,pos_y,hu_type)
		 end
	end

end

--调整胡牌带未打完手牌
function CSMJReceiveHandle:drawPlayerHupaiCard(uid,card,hkind)

	-- dump(uid,"-----调整胡牌带未打完手牌-----")
	-- dump(card,"-----调整胡牌带未打完手牌-----")
	-- dump(hkind,"-----调整胡牌带未打完手牌-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	local index   = self:getIndex(uid)

	local node_name = "othercard"..index
	if index == 0 then
		node_name = "owncard"
	end

	--这里做区分手牌是自摸胡，还是平胡别人，显示有区别
	if hkind == 2 then
		MajiangcardHandle:removeCardValue(CSMJ_ROOM.Card[index]["hand"],card,1,index)
		CSMJ_ROOM.Card[index]["hu"] = card
	else
		CSMJ_ROOM.Card[index]["hu"] = card
	end

	self:drawHandCard(index)

	--print(tostring(node_name))
	local node = scenes._scene:getChildByName("layer_card"):getChildByName(node_name)


	--print(tostring(node))
	local pos_x  = 0
	for i,v in pairs(CSMJ_ROOM.Card[index]["hand"]) do
		local tmp = node:getChildByName(i)
		if tmp then
			if index == 1 or index == 3 then
				tmp:setLeftBlack()
				local item_width = 36
				local item_heigth = 30
				local contentsize =  tmp.pannel_:getContentSize()
				tmp.pannel_:setScale(item_width/contentsize.width,item_heigth/contentsize.height)

			end

			if index == 2 then
				tmp:setTopBlack()
				local contentsize =  tmp.pannel_:getContentSize()
				tmp.pannel_:setScale(30/contentsize.width,42/contentsize.height)

				if pos_x ~= 0 then
					tmp:setPositionX( pos_x - 30 )
					pos_x = pos_x - 30
				else
					pos_x = tmp:getPositionX()
				end
			end
		end
	end

end
------------------------------------------------------------------------------------------------------------------



--显示当轮结算界面
function CSMJReceiveHandle:showRoundResult(pack)

	--假如是最后一轮，则不需要弹出一轮结算
	if bm.round == bm.round_total then
		return
	end

	-- dump(pack, "-----一轮结算信息-----")
	-- dump(USER_INFO["user_info"], "-----当前用户信息-----")
	-- dump(CSMJ_ROOM, "-----显示房间信息-----")

	--登录用户信息（自己）
	local now_user_info = json.decode(USER_INFO["user_info"])

	--获取单轮结算界面
    local s = cc.CSLoader:createNode("majiang/common/GameRoundResult.csb")
    SCENENOW["scene"]:addChild(s)

    --结果标签
    local result_ly = s:getChildByName("result_ly")
    local result_bg_iv = result_ly:getChildByName("result_bg_iv")
    local result_iv = result_ly:getChildByName("result_iv")

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")

    --记录自己是否胜出,默认是输
    local isWin = 0
    --记录是否有人胡了
    local ishu = 0
    for k,v in pairs(pack.content) do
    	--遍历四位用户的结算信息

    	--0 自己 1左边 2对家 3右边
    	local index = self:getIndex(v.uid)
    	if index == 0 then

    		--判断输赢
			if v.userpergold > 0 then

				--赢
				isWin = 1

				--结果标签改成赢的样式
				result_bg_iv:loadTexture("hall/group/create/red_button_p.png")
				result_iv:loadTexture("majiang/common/mahjong_win.png")

			end
    	end

    	--显示用户当局情况
    	--添加显示区域
    	local result_Item = cc.CSLoader:createNode("majiang/common/GameRoundResult_Item.csb")
    	content_ly:addChild(result_Item)
    	local item_ly = result_Item:getChildByName("item_ly")
    	item_ly:setPosition(21, (content_ly:getContentSize().height - 23) - (88 * (k - 1) ) )
    	item_ly_list[k] = item_ly

    	--庄家
    	local zuan_iv = item_ly:getChildByName("zuan_iv")

    	--显示用户名称
    	local name_tt = item_ly:getChildByName("name_tt")
    	if index == 0 then
    		--当前用户信息
    		name_tt:setString(now_user_info.nickName)

    		-- dump(bm.zuan_seat, "----庄家座位-----")
    		-- dump(bm.User.Seat, "----玩家座位-----")

    		--判断是否为庄家
    		if bm.User.Seat == bm.zuan_seat then
    			zuan_iv:setVisible(true)
    		else
    			zuan_iv:setVisible(false)
    		end

    	else
    		--其他用户信息
    		local user_info = CSMJ_ROOM.UserInfo[v.uid]
    		local other_user_info = json.decode(user_info.user_info)
    		name_tt:setString(other_user_info.nickName)

    		-- dump(bm.zuan_seat, "----庄家座位-----")
    		-- dump(user_info.seat_id, "----玩家座位-----")

    		--判断是否为庄家
    		if user_info.seat_id == bm.zuan_seat then
    			zuan_iv:setVisible(true)
    		else
    			zuan_iv:setVisible(false)
    		end

    	end

    	--显示用户手牌
    	-- dump(CSMJ_ROOM.Card[k], "-----"... tostring(index) ..."用户手牌-----")
    	local showCard_ly = item_ly:getChildByName("showCard_ly")
    	local userleftcard = v.userleftcard
    	-- dump(userleftcard,"-----" .. tostring(index) .. "用户手牌-----")
    	for k,v in pairs(userleftcard) do

    		--定义牌
    		local card = cc.CSLoader:createNode("hall/majiangCard/csb/roundResult_card.csb")
    		showCard_ly:addChild(card)
    		local card_ly = card:getChildByName("card_ly")
    		card_ly:setPosition(38 * (k - 1), showCard_ly:getContentSize().height)

    		--显示牌内容
    		local card_iv = card_ly:getChildByName("card_iv")
    		local value = tonumber(v)
    		if value > 0 and value < 10 then
    			--万
    			card_iv:loadTexture("hall/majiangCard/wan/".. tostring(value) ..".png")
    		elseif value > 16 and value < 26 then
    			--筒
    			card_iv:loadTexture("hall/majiangCard/tong/".. tostring(value - 16) ..".png")
    		elseif value > 32 and value < 42 then
    			--条
    			card_iv:loadTexture("hall/majiangCard/tiao/".. tostring(value - 32) ..".png")
    		end

    	end

    	--显示胡、胡内容、番数、分数、是否流局
    	--结果
    	local result_tt = item_ly:getChildByName("result_tt")
    	local result_str = ""

    	--番
    	local fan_tt = item_ly:getChildByName("fan_tt")
    	local fan_total = 0

    	--胡标志
    	local hu_iv = item_ly:getChildByName("hu_iv")

    	--是否胡了
    	local ifhu = v.ifhu
    	if ifhu == 1 then

    		if #v.hucontent > 0 then
    			
	    		--获取胡的内容
	    		local hucontent = v.hucontent[1]
	    		-- dump(hucontent,"-----" .. tostring(index) .. "胡的内容----")

	    		--获取胡的牌型
				local cardkind = hucontent.cardkind
				local card_kind_name = CARD_TYPE[cardkind]
				result_str = result_str .. card_kind_name .. " "

				--记录胡的牌
				local kucard

				--记录点炮的用户id
				local paoid

				--胡的类型
				local hutype = hucontent.hutype
				if hutype == 1 then

					--接炮
					result_str = result_str .. "接炮 "

					local pinghu = hucontent.pinghu[1]

					--是否杠上炮
					if pinghu.ifgangpao == 1 then 
						result_str = result_str .. "杠上炮 "
					end

					--是否抢杠胡
					if pinghu.ifqiangganghu == 1 then
						result_str = result_str .. "抢杠胡 "
					end

					--记录胡的牌
					kucard = pinghu.hucard

					--记录谁点炮
					paoid = pinghu.paoid 

				else 

					--自摸
					result_str = result_str .. "自摸 "

					local zimo = hucontent.zimo[1]

					--记录胡的牌
					kucard = zimo.hucard

					--是否杠上花
					if zimo.ifgangshanghua then
						result_str = result_str .. "杠上花 "
					end

				end

	    		--添加番数
	    		fan_total = fan_total + hucontent.fanshu

				-- local money = hucontent.money--钱
				-- local gen = hucontent.gen--根根的数量
				-- local gangnum = hucontent.gangnum--杠的数量

	    	end

	    	--显示胡标志图片
    		hu_iv:setVisible(true)

    		--记录有人胡了
    		ishu = 1

    	else

    		--隐藏胡标志图片
    		hu_iv:setVisible(false)

    	end

    	--是否点炮
		if v.ifpao==1 then
			result_str = result_str .. "点炮 "
		end

		--刮风下雨
		local ifgua = v.ifgua
		if ifgua > 0 then
			-- result_str = result_str .. "刮风下雨所得：" .. ifgua .. " "
			result_str = result_str .. "刮风下雨"
			-- fan_total = fan_total + ifgua
		elseif ifgua < 0 then
			-- fan_total = fan_total + ifgua
		end

		--是否花猪
		if v.ifhua == 1 then

			-- local huazhu = v.huazhu[1]
			-- --local getMonetPlaynum = huazhu.huamount --收钱玩家数量
			-- --收钱玩家id
			-- local moneyhuazhu = huazhu.huazhuuids
			-- for k,v in pairs(moneyhuazhu) do
			-- 	--print("收钱玩家id",k,v)
			-- end
			result_str = result_str .. "花猪 "

		end

		--是否大叫
		if v.ifdajiao==1 then

			local dajiaocontent = v.dajiaocontent[1]
			--local dajiaomout=dajiaocontent.dajiaomout--大叫人数
			local dajiagetMoeny = dajiaocontent.dajiaouserinfo[1]

			--大叫番数
			local f = 0
			--大叫收钱
			local m = 0
			for kd,vd in pairs(dajiagetMoeny) do

				-- --收钱玩家id
				-- if kd == "dajiaouid" then

				-- end

				--番数
				if kd == "dajiaofan" then 
					f = f + vd
				end

				-- --大叫赢的钱
				-- if kd=="dajiaowin" then
				-- 	m = m+vd
				-- end

			end

			--添加番数
			fan_total = fan_total + f

			-- if f ~= 0 then
			-- 	str = str.."番数："..f.."  ".."输赢："..(m*-1).."   "
			-- end

			result_str = result_str.."大叫"
		end

		--显示牌局结果
		result_tt:setString(result_str)

		--显示番数
		if fan_total > 0 then
    		fan_tt:setString(tostring(fan_total) .. "番")
    		fan_tt:setTextColor(cc.c3b(0, 255, 0))

    	else
    		fan_tt:setString("0番")
    		fan_tt:setTextColor(cc.c3b(255, 0, 0))

		end

		--显示分数
    	local fen_tt = item_ly:getChildByName("fen_tt")
    	if v.userpergold > 0 then
    		fen_tt:setTextColor(cc.c3b(0, 255, 0))
    		fen_tt:setString("+" .. tostring(v.userpergold))
    	else
    		if v.userpergold < 0 then
    			fen_tt:setTextColor(cc.c3b(255, 0, 0))
    		end
    		fen_tt:setString(tostring(v.userpergold))
    	end
    	
    end

    --设置流局显示
    if ishu == 0 then
    	--结果标签改成赢的样式
		result_bg_iv:loadTexture("hall/group/create/grey_button.png")
		result_iv:loadTexture("majiang/common/text_liuju.png")
    end

    --显示抓鸟显示
    local pickBird_ly = s:getChildByName("pickBird_ly")
    pickBird_ly:setVisible(false)

    --显示房间号
    local roodId_tt = s:getChildByName("roodId_tt")
    roodId_tt:setString("房间号：" .. USER_INFO["invote_code"])

    --显示房间名
    local roodName_tt = s:getChildByName("roodName_tt")
    roodName_tt:setString("血战到底")

    --显示当前轮数
    local time_tt = s:getChildByName("time_tt")
    time_tt:setString("当前局数" .. tostring(bm.round))

    --开始游戏按钮（再来一局）
    local again_ly = s:getChildByName("again_ly")
    again_ly:addTouchEventListener(
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

                if require("hall.gameSettings"):getGameMode() == "group" then
					require("majiang.majiangServer"):LoginGame(USER_INFO["GroupLevel"] or 37)
				else
					require("majiang.majiangServer"):LoginGame(bm.nomallevel)
			    end

			    s:removeSelf()

            end
        end
    )

end


-------------------------------------------------------------------------------------------------------------------

--组局相关
--请求获取筹码返回
function CSMJReceiveHandle:SVR_GET_CHIP(pack)
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
		--todo
		require("majiang.gameScene"):onNetGetChip(pack)
	end
	
end

--请求兑换筹码返回
function CSMJReceiveHandle:SVR_CHANGE_CHIP(pack)
	
	-- dump(pack, "-----请求兑换筹码返回------")
	-- if bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() == "group" then
			
		require("majiang.gameScene"):onChipSuccess(pack)
	end

end





--组局历史记录
function CSMJReceiveHandle:SVR_GET_HISTORY(pack)

	-- dump(pack, "-----组局历史记录-----")

    if pack then
        -- if bm.isGroup then
    	if require("hall.gameSettings"):getGameMode() == "group" then
            require("majiang.gameScene"):onNetHistory(pack)
        end
    end

end
-----------------------------------------------------------------------------------------------------------------------------

--广播桌子用户请求解散组局
function CSMJReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

	-- dump("", "广播桌子用户请求解散组局")

	-- require("hall.GameTips"):showTips("确认解散房间","cs_request_disbandGroup",1)

end

--广播桌子用户成功解散组局
function CSMJReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

	-- dump("", "广播桌子用户成功解散组局")

	-- require("hall.GameTips"):showTips("解散房间成功","cs_disbandGroup_success",3)

	CSMJ_ROUND = CSMJ_TOTAL_ROUNDS

	if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end

    if require("cs_majiang.RoundEndingLayer"):isShow() then
    	--todo
    	require("cs_majiang.RoundEndingLayer"):hide()
    	if CSMJ_ENDING_DATA then
    		--todo
    		require("cs_majiang.RoundEndingLayer"):show(CSMJ_ENDING_DATA, true)
    	end
    	
    end

end

--广播桌子用户解散组局 ，解散组局失败
function CSMJReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

	-- dump("", "广播桌子用户解散组局 ，解散组局失败")

	require("hall.GameTips"):showTips("解散房间失败", "disbandGroup_fail", 2, "用户拒绝解散房间")

end

---------------------------------------------------------------------------------------------------------------

--聊天相关
--收到聊天消息
function CSMJReceiveHandle:CHAT_MSG( pack )
	-- dump(pack, "================CHAT_MSG========================")
	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local config = {[0]={['x'] = 480,['y'] = 200,},
					[1]={['x'] = 300,['y'] = 250,},--左
					[2]={['x'] = 480,['y'] = 450,},--上
					[3]={['x'] = 750,['y'] = 300,},--右
	}

	local msg = pack.msg or "nothing to get"
	local index = self:getIndex(pack.uid or USER_INFO["uid"])

	local niu_txt = scenes:getChildByName("chat_msg"..tostring(index))
	if niu_txt ~= nil then niu_txt:removeSelf() end

	local params =
    {
        text = msg,
        font = "res/fonts/fzcy.ttf",
        size = 25,
        color = cc.c3b(255,0,0), 
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    }
    niu_txt =  display.newTTFLabel(params)
    niu_txt:enableShadow(cc.c4b(255,0,0,255), cc.size(1,0))
    scenes:addChild(niu_txt, "3000", "chat_msg"..tostring(index))
    niu_txt:setPositionX(config[index].x)
    niu_txt:setPositionY(config[index].y)

    local action_deley = cc.DelayTime:create(0.5)
    local action_move = cc.MoveBy:create(0.5,cc.p(0,-80))
    local action_reself = cc.RemoveSelf:create()
    local action_seq = cc.Sequence:create(action_deley,action_move,action_reself)
    niu_txt:runAction(action_seq)

end
---------------------------------------------------------------------------------------------------------------

--比赛相关
function CSMJReceiveHandle:s2c_JOIN_MATCH_RETURN(pack)
	--print("===recieve====0x211====================")
	-- dump(pack)
	--print("UID------------------", USER_INFO["uid"])
    USER_INFO["match_id"] = pack["Matched"]
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
    :setParameter("tableid", pack.Matched)
    :setParameter("nUserId", USER_INFO["uid"])
    :setParameter("strkey", json.encode("kadlelala"))
    :setParameter("strinfo", USER_INFO["user_info"])
    :setParameter("iflag", 1)
    :setParameter("version", 1)
    :setParameter("activity_id","")
    :build()
	bm.server:send(pack)
	--print("sending ------------------1001-------------")
end

function CSMJReceiveHandle:s2c_JOIN_MATCH_FAIL(pack)
	--print("0x7109==========return==========")
	-- dump(pack)
	USER_INFO["match_fee"] = 0
    require("majiang.MatchSetting"):setJoinMatch(false)
end

function CSMJReceiveHandle:s2c_JOIN_MATCH_SUCCESS(pack)
	--print("0x7101==========return==========")
	-- dump(pack)

	--重设玩家的金币数，这个是扣除了报名费
	USER_INFO["gold"] = pack.Score
	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] =="majiang.MJselectChip"  then
		scenes:goldUpdate()
	end
	 require("majiang.MatchSetting"):setJoinMatch(true)


    if USER_INFO["match_fee"] then
        if USER_INFO["match_fee"] > 0 then
            bMatchJoin = true
            require("majiang.MatchSetting"):showMatchSignup(true,pack["MatchUserCount"],pack["totalCount"],pack["Costformatch"],"majiang",USER_INFO["curr_match_level"])
        end
    end

    USER_INFO["match_fee"] = pack["Costformatch"]

    --进入比赛模式
    --进入比赛模式
    require("hall.GameData"):enterMatch(4)
end

function CSMJReceiveHandle:s2c_OTHER_PEOPLE_JOINT_IN(pack)
	--print("0x7103==========return==========")
	-- dump(pack)
	require("majiang.MatchSetting"):setJoinMatch(true)
	require("majiang.MatchSetting"):joinMatch(pack.Usercount,pack.Totalcount)
end

function CSMJReceiveHandle:s2c_QUIT_MATCH_RETURN(pack)
	--print(" 0x7110==========return==========")
	-- dump(pack)
	-- require("majiang.MatchSetting"):setJoinMatch(false)

    if pack then
        local flag = pack["Flag"]
        -- 成功退赛
        if flag == 1 or flag == 2 then
            --退回报名费
			local scenes         = SCENENOW['scene'] 
            USER_INFO["gold"] = USER_INFO["gold"] + pack["nCostForMatch"]
			if SCENENOW['name'] =="majiang.MJselectChip"  then
				scenes:goldUpdate()
			end
            
            require("majiang.MatchSetting"):setJoinMatch(false)
            MajiangroomServer:quickRoom()

            local layer_sign = scenes:getChildByName("layer_sign")

            if layer_sign then
                local txt = layer_sign:getChildByName("layout_join"):getChildByName("txt_playercount")
                if txt then
                    local str = "退赛成功"
                    txt:setString(str)
                end
            end
            USER_INFO["match_fee"] = 0
            bMatchJoin = false


        else
            --失败原因
            --print("match logout failed,error type:"..pack["Errortype"])
            require("majiang.MatchSetting"):setJoinMatch(true)
        end

    end
end

function CSMJReceiveHandle:s2c_GAME_BEGIN_LOGIC(pack)
	--print("0x7104==========return==========")
	-- dump(pack)
	
	bm.User={}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.gold or pack.Matchpoint
	bm.User.Pque      = nil

	CSMJ_ROOM={}
	CSMJ_ROOM.User      = {}	
    CSMJ_ROOM.UserInfo  = {}
    CSMJ_ROOM.seat_uid  = {}
	CSMJ_ROOM.Card      = {}
	CSMJ_ROOM.Gang      = {}
	CSMJ_ROOM.base      = pack.base 

	CSMJ_ROOM.tuoguan_ing = 0

	--bm.display_scenes("majiang.scenes.MajiangroomScenes")

	SCENENOW["scene"]:removeSelf()
	SCENENOW["scene"]=nil;

	local sc=require("majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    --SCENENOW["scene"]:retain();
    SCENENOW["name"]  = "majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)
	local scenes   = sc

	--绘制自己的信息
	scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["Matchpoint"],USER_INFO["sex"])

	--绘制其他玩家
	if pack.Usercount > 0  then
		for i,v in pairs(pack.other_players) do
			CSMJReceiveHandle:showPlayer(v)
		end
	end

	--绘制其他内容
	scenes:set_basescole_txt(CSMJ_ROOM.base) 

	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		-- USER_INFO["base_chip"]=CSMJ_ROOM.base;
		require("majiang.gameScene"):showTimer(bm.GroupTimer)

		require("majiang.gameScene"):checkChip(scenes)

	else
		SCENENOW["scene"]:gameReady();
		
	end
	majiangGameMode = 2
	require("hall.gameSettings"):setGameMode("match")
	require("majiang.MatchSetting"):setCurrentRound(pack["Round"],pack["Sheaves"])
	voiceUtils:playBackgroundMusic()

    if scenes:getChildByName("match_win") then
        scenes:removeChildByName("match_win")
    end
    if scenes:getChildByName("match_lose") then
        scenes:removeChildByName("match_lose")
    end
    if scenes:getChildByName("match_wait") then
        scenes:removeChildByName("match_wait")
    end
    if scenes:getChildByName("match_result") then
        scenes:removeChildByName("match_result")
    end

end

function CSMJReceiveHandle:s2c_PAI_MING_MSG(pack)
	--print("0x7114==========return==========")
	-- dump(pack)
end

function CSMJReceiveHandle:s2c_SVR_MATCH_WAIT(pack)
	--print("0x7113==========return==========")
	-- dump(pack)
	SCENENOW["scene"]:removeSelf()
	SCENENOW["scene"]=nil;

	local sc=require("majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    --SCENENOW["scene"]:retain();
    SCENENOW["name"]  = "majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)
	local scenes   = sc
	if tolua.isnull(scenes) == false then
	    USER_INFO["match_gold"] = pack["Matchpoint"]
		scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["Matchpoint"],USER_INFO["sex"])
	    require("majiang.HallHttpNet"):MatchloadBattles(4)
	    require("majiang.MatchSetting"):setMatchState(1)
	end

	if pack["table_count"]>0 then
        require("majiang.MatchSetting"):showMatchWait(true,"majiang")
        return
    end
end

function CSMJReceiveHandle:s2c_GAME_STATE_MSG(pack)
	--print("0x7106==========return==========")
	-- dump(pack)
	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	if pack == nil then
		return
	end

    if pack["Tablecount"]>0 then
        require("majiang.MatchSetting"):showMatchWait(true,"majiang")
        return
    end

	local status = pack["Status"]
    if status==0 then --晋级
        if USER_INFO["match_rank"] == nil then
            USER_INFO["match_rank"] = 0
        end
        if USER_INFO["match_rank"] == 0 then
            USER_INFO["match_rank"] = pack["Maxnumber"]
        end
        -- self:showMatchWin(pack["Rank"],USER_INFO["match_rank"],currentRound)
        if pack["Tablecount"] == 0 then
            require("majiang.MatchSetting"):showMatchWin(pack["Rank"],USER_INFO["match_rank"],require("majiang.MatchSetting"):getCurrentRank(),"majiang")
        end
    elseif status==1 then --淘汰后显示结果
        require("majiang.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"majiang",require("majiang.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
        require("majiang.MatchSetting"):showMatchLose(pack["Rank"],pack["Maxnumber"],require("majiang.MatchSetting"):getCurrentRank(),"majiang")
        bMatchStatus = 2
        local sp = display.newSprite():addTo(scenes)
        sp:performWithDelay(function()
            require("majiang.MatchSetting"):showMatchResult()
        end,5)
        audio.stopMusic(true)
    elseif status==2 then --赢了显示结果
    	audio.stopMusic(true)

        bMatchStatus = 2
        
        require("majiang.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"majiang",require("majiang.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
		require("majiang.MatchSetting"):showMatchResult()	
	end
       
end

function CSMJReceiveHandle:s2c_SVR_REGET_MATCH_ROOM(pack)
	
	dump(pack)
	--重新调用1009部分的功能
	self:SVR_REGET_ROOM(pack)
	majiangGameMode = 2
	require("hall.gameSettings"):setGameMode("match")
	data_manager:set_game_mode(2)
	
	-- --print("recieve msg ----------7112--------------------------")
 --    --print("pack.m_nMatchRank--------------",pack.m_nMatchRank)--当前排名
 --    --print("pack.m_nPoint--------------",pack.m_nPoint)--当前积分
 --    --print("pack.m_strUserInfo--------------",pack.m_strUserInfo)--用户信息
    --pack.m_nplayecount

	--for index,user_data in pairs(pack.other_point) do
		-- --print("index.............",index)
		-- --print("user_data.m_userid--------------",user_data.m_userid)
		-- --print("user_data.m_nMatchRank--------------",user_data.m_nMatchRank)
		-- --print("user_data.m_nPoint--------------",user_data.m_nMatchRank)
	--end

	-- --print("index............over")
 --    --print("pack.m_nLevel--------------",pack.m_nLevel)
    USER_INFO["curr_match_level"] = pack.m_nLevel
    USER_INFO["match_fee"] = 100

    -- --print("pack.m_nSheaves--------------",pack.m_nSheaves)--第几局`
    -- --print("pack.m_nRound--------------",pack.m_nRound)--第几轮
    -- require("majiang.MatchSetting"):setCurrentRound(pack["m_nRound"],pack["m_nSheaves"])

    -- --print("pack.m_nLowPoint--------------",pack.m_nLowPoint)
    -- --print("pack.m_nNuber--------------",pack.m_nNuber)
    -- --print("pack.m_nCurrentCount--------------",pack.m_nCurrentCount)
    -- --print("pack.m_nstr--------------",pack.m_nstr)
    -- --print("pack.m_nFinalplayTimesInTable--------------",pack.m_nFinalplayTimesInTable)

    --require("majiang.HallHttpNet"):MatchloadBattles(4)

    data_manager:match_game_http(pack.m_nLevel)
    require("majiang.HallHttpNet"):requestIncentive(pack.m_nLevel)

 --    if pack.pHuSeatId == 1 then
	-- 	require("majiang.MatchSetting"):showMatchWait(true,"majiang")
	-- end

end

function CSMJReceiveHandle:remaidIP()
    local myIp = ""

    if CSMJ_MY_USERINFO.seat_id and CSMJ_USERINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""] then
        --todo
        myIp = CSMJ_USERINFO_TABLE[CSMJ_MY_USERINFO.seat_id .. ""].ip
    end


    local ipTable = {}

    for k,v in pairs(CSMJ_USERINFO_TABLE) do
        if v.ip and v.ip ~= myIp then
            --todo
            if not ipTable[v.ip] then
                --todo
                ipTable[v.ip] = {}
            end
            table.insert(ipTable[v.ip], v.nick)
        end
    end

    local msg = ""
    for k,v in pairs(ipTable) do
        if table.getn(v) > 1 then
            --todo
            for i=1,table.getn(v) do
                msg = msg .. v[i] .. " "
            end
        end
    end

    if msg ~= "" then
        --todo
        require("hall.GameCommon"):showAlert(false, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
        require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
    end
end
---------------------------------------------------------------------------------------------------------------

--接收服务器放回的指定用户信息pack111
function CSMJReceiveHandle:SVR_CHARGE_BROADCAST(pack)
   
    local uid = pack.uid
	dump(pack,"pack111")
	
	local seat_id = CSMJ_SEAT_TABLE[uid .. ""]
	local userInfo = CSMJ_USERINFO_TABLE[seat_id .. ""]
    if not (userInfo) then return end
	userInfo.coins = userInfo.coins + pack.chargeCoins
	local playerType = cardUtils:getPlayerType(seat_id)
	gamePlaneOperator:showPlayerInfo(playerType, userInfo)

end

--通知开始选漂 --0x110B
function CSMJReceiveHandle:BROADCAST_BEGIN_CHOSE_PIAO(pack)
    dump(pack,"BROADCAST_BEGIN_CHOSE_PIAO--pack--0x110B")
    if pack then
        --移除用户准备标志
        local scenes  = SCENENOW['scene']
        if SCENENOW['name'] ~= run_scene_name then
            return
        end

        CSMJ_ENDING_DATA = nil

        --gamePlaneOperator:clearGameTableCards()
        
        gamePlaneOperator:clearAllReadyStatus()
        gamePlaneOperator:clearGameDatas()

        HZMJ_GAME_STATUS = 1
        scenes:hideCloseRoomButton()
        scenes:ShowSettingButton()
        scenes:hideShareButton()

        gamePlaneOperator:clearPiaoImg()

        gamePlaneOperator:showJiapiaoPlane(true)
    end
end

--广播选漂结果 --0x110C
function CSMJReceiveHandle:BROADCAST_CHOSE_PIAO_RESULT(pack)
    dump(pack,"广播选漂结果--BROADCAST_CHOSE_PIAO_RESULT--pack--0x110C")
    dump(CSMJ_SEAT_TABLE,"CSMJ_SEAT_TABLE===>>>")
    if pack then
        local uid = pack.uid    
        local seatId = CSMJ_SEAT_TABLE[uid..""]

        if not (seatId) then
            return 
        end

        if not pack.piaoNum then
            return
        end

        local playerType = cardUtils:getPlayerType(seatId)
        gamePlaneOperator:showPiaoImg(playerType, pack.piaoNum, true)
    end

end



return CSMJReceiveHandle
