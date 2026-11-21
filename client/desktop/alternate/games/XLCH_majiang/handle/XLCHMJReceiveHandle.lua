
-- --加载麻将设置类（麻将公共方法类）
-- require("majiang.setting_help")

--加载框架初始化类
require("framework.init")

local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")

local cardUtils = require(TpackageName..".utils.cardUtils")

--加载大厅请求处理
local hallHandle = require("hall.HallHandle")

local voiceUtils = require(TpackageName..".utils.VoiceUtils")

--大厅套接字请求类
local hallPa = require("hall.HALL_PROTOCOL")

--麻将套接字请求类
local PROTOCOL = import(TpackageName..".handle.XLCHMJProtocol")
setmetatable(PROTOCOL, {
		__index=hallPa
	})

local sendHandle = require(TpackageName..".handle.XLCHMJSendHandle")

--定义麻将游戏处理类
local XLCHMJReceiveHandle = class("XLCHMJReceiveHandle",hallHandle)

local aniUtils = require(TpackageName..".utils.AniUtils")

--定义登录超时时间
local LOGIN_OUT_TIMER = 20

--定义麻将游戏界面名称
local run_scene_name = TpackageName..".gameScene"

--扣除台费百分数
local percent_base = 0.20

local item_ly_list = {}

local liujuFlag = true

local LocaArrayByPlayerType = {}

local is_End = false

local tbErrorCode = {
    [0] = "成功创建新连接",
    [1] = "无效的操作",
    [10] = "游戏进行中",
    [11] = "无效的座位",
    [12] = "您已经准备过了",
    [13] = "请先准备",
    [14] = "您已经坐下",
    [15] = "您已经站起",
    [16] = "请先坐下",
    [17] = "不存在的用户",
    [18] = "要求携带钻石不足",
    [19] = "已经购买过奖池",
    [20] = "桌子状态不正确",
    [21] = "值超出范围",
    [22] = "要求携带积分不足",
    [100] = "战绩不存在",

}

local loginErrorCode = {
    [3] = "玩家密匙错误",
    [4] = "数据库连接错误",
    [5] = "无此房间",
    [7] = "房间已满人",
    [8] = "没有多余座位",
    [9] = "金币不足",
    [11] = "未知错误",
    [12] = "相同IP",
    [13] = "钱太多",
    [14] = "缓存错误",
    [15] = "VIP错误",
    [16] = "密码错误",
    [17] = "要求携带不满足",
    [18] = "组局已开始",
    [19] = "积分不足",
}



function XLCHMJReceiveHandle:ctor()

	XLCHMJReceiveHandle.super.ctor(self);

	--定义麻将游戏请求
	local  func_ = {

		--用户自己退出成功
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, XLCHMJReceiveHandle.SVR_QUICK_SUC)},
        --广播用户准备
        [PROTOCOL.SVR_USER_READY_BROADCAST] = {handler(self, XLCHMJReceiveHandle.SVR_USER_READY_BROADCAST)},
        --登陆房间广播
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, XLCHMJReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},
        --广播玩家退出返回
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, XLCHMJReceiveHandle.SVR_QUIT_ROOM)},
        --发牌
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, XLCHMJReceiveHandle.SVR_SEND_USER_CARD)},
        --开始选择缺一门
        [PROTOCOL.SVR_START_QUE_CHOICE] = {handler(self, XLCHMJReceiveHandle.SVR_START_QUE_CHOICE)},
        --广播缺一门选择
        [PROTOCOL.SVR_BROADCAST_QUE] = {handler(self, XLCHMJReceiveHandle.SVR_BROADCAST_QUE)},
        --当前抓牌用户广播
        [PROTOCOL.SVR_PLAYING_UID_BROADCAST] = {handler(self, XLCHMJReceiveHandle.SVR_PLAYING_UID_BROADCAST)},
        --广播用户出牌
        [PROTOCOL.SVR_SEND_MAJIANG_BROADCAST] = {handler(self, XLCHMJReceiveHandle.SVR_SEND_MAJIANG_BROADCAST)},
        --svr通知我抓的牌
        [PROTOCOL.SVR_OWN_CATCH_BROADCAST] = {handler(self, XLCHMJReceiveHandle.SVR_OWN_CATCH_BROADCAST)},
        --广播用户进行了什么操作
        [PROTOCOL.SVR_PLAYER_USER_BROADCAST] = {handler(self, XLCHMJReceiveHandle.SVR_PLAYER_USER_BROADCAST)},
        --广播胡
    	[PROTOCOL.SVR_HUPAI_BROADCAST]       = {handler(self, XLCHMJReceiveHandle.SVR_HUPAI_BROADCAST)},
    	--结算
    	[PROTOCOL.SVR_ENDDING_BROADCAST] = {handler(self, XLCHMJReceiveHandle.SVR_ENDDING_BROADCAST)},
    	--请求托管
    	[PROTOCOL.SVR_ROBOT] = {handler(self, XLCHMJReceiveHandle.SVR_ROBOT)},
    	--出牌错误返回
    	-- [PROTOCOL.SVR_CHUPAI_ERROR] = {handler(self, XLCHMJReceiveHandle.SVR_CHUPAI_ERROR)},
    	--海底牌 SVR_HAIDI_CARD
    	-- [PROTOCOL.SVR_HAIDI_CARD] = {handler(self, XLCHMJReceiveHandle.SVR_HAIDI_CARD)},
    	--亮倒提示
    	-- [PROTOCOL.SVR_LIANGDAO_REMAID] = {handler(self, XLCHMJReceiveHandle.SVR_LIANGDAO_REMAID)},
    	[PROTOCOL.SVR_MSG_FACE]={handler(self, XLCHMJReceiveHandle.SVR_MSG_FACE)},

    	[PROTOCOL.BROADCAST_USER_IP]={handler(self, XLCHMJReceiveHandle.BROADCAST_USER_IP)},

    	-- [PROTOCOL.SVR_HUIPAI]={handler(self, XLCHMJReceiveHandle.SVR_HUIPAI)},

    	-- [PROTOCOL.SVR_JIAPIAO]={handler(self, XLCHMJReceiveHandle.SVR_JIAPIAO)},
    	-- [PROTOCOL.SVR_JIAPIAO_BROADCAST]={handler(self, XLCHMJReceiveHandle.SVR_JIAPIAO_BROADCAST)},

    	--获取房间id结果
    	--[PROTOCOL.SVR_GET_ROOM_OK]     = {handler(self, XLCHMJReceiveHandle.SVR_GET_ROOM_OK)},
    	--登陆房间返回
        [PROTOCOL.SVR_LOGIN_ROOM]      = {handler(self, XLCHMJReceiveHandle.SVR_LOGIN_ROOM)},
        --登陆错误
     	[PROTOCOL.SVR_ERROR]      = {handler(self, XLCHMJReceiveHandle.SVR_ERROR)},
     	--用户重新登录普通房间的消息返回（4105(10进制s)）
     	[PROTOCOL.SVR_REGET_ROOM]      = {handler(self, XLCHMJReceiveHandle.SVR_REGET_ROOM)},--重登
     	--服务器告知客户端可以进行的操作
     	[PROTOCOL.SVR_NORMAL_OPERATE]      = {handler(self, XLCHMJReceiveHandle.SVR_NORMAL_OPERATE)},--广播可以进行的操作
     	--服务器告知客户端游戏结束
     	[PROTOCOL.SVR_GAME_OVER]      = {handler(self, XLCHMJReceiveHandle.SVR_GAME_OVER)},
     	--广播刮风下雨（返回）杠
     	[PROTOCOL.SVR_GUFENG_XIAYU]      = {handler(self, XLCHMJReceiveHandle.SVR_GUFENG_XIAYU)},

     	--用户聊天消息
     	[PROTOCOL.CHAT_MSG]      = {handler(self, XLCHMJReceiveHandle.CHAT_MSG)},

     	--组局
     	--请求获取筹码返回
     	[PROTOCOL.SVR_GET_CHIP]     = {handler(self, XLCHMJReceiveHandle.SVR_GET_CHIP)},
     	--请求兑换筹码返回
     	[PROTOCOL.SVR_CHANGE_CHIP]     = {handler(self, XLCHMJReceiveHandle.SVR_CHANGE_CHIP)},
     	--组局时长
     	[PROTOCOL.SVR_GROUP_TIME]     = {handler(self, XLCHMJReceiveHandle.SVR_GROUP_TIME)},
     	--组局排行榜
     	[PROTOCOL.SVR_GROUP_BILLBOARD]     = {handler(self, XLCHMJReceiveHandle.SVR_GROUP_BILLBOARD)},
     	--组局历史记录
     	[PROTOCOL.SVR_GET_HISTORY]     = {handler(self, XLCHMJReceiveHandle.SVR_GET_HISTORY)},
     	--漫游
     	-- [PROTOCOL.SVR_MANYOU] = {handler(self, XLCHMJReceiveHandle.SVR_MANYOU)},

     	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, XLCHMJReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, XLCHMJReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, XLCHMJReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, XLCHMJReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, XLCHMJReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

     	--换牌
     	--服务器告诉客户端，可以换牌
     	[PROTOCOL.SERVER_COMMAND_NEED_CHANGE_CARD]     = {handler(self, XLCHMJReceiveHandle.SERVER_COMMAND_NEED_CHANGE_CARD)},
     	--//服务器广播换牌的结果 zsw
     	[PROTOCOL.SERVER_COMMAND_CHANGE_CARD_RESULT]     = {handler(self, XLCHMJReceiveHandle.SERVER_COMMAND_CHANGE_CARD_RESULT)},

        --录音
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, XLCHMJReceiveHandle.SERVER_CMD_MESSAGE)},
        --接收服务器发来的距离
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, XLCHMJReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},

     	--比赛场相关
     	--用户请求进入比赛场的返回值
     	[PROTOCOL.s2c_JOIN_MATCH_RETURN]     = {handler(self, XLCHMJReceiveHandle.s2c_JOIN_MATCH_RETURN)},
     	--进入比赛失败
     	[PROTOCOL.s2c_JOIN_MATCH_FAIL]     = {handler(self, XLCHMJReceiveHandle.s2c_JOIN_MATCH_FAIL)},
     	-- 进入比赛成功
		[PROTOCOL.s2c_JOIN_MATCH_SUCCESS]     = {handler(self, XLCHMJReceiveHandle.s2c_JOIN_MATCH_SUCCESS)},
		--同时，已经报名的玩家会收到其他玩家进入的消息
     	[PROTOCOL.s2c_OTHER_PEOPLE_JOINT_IN]     = {handler(self, XLCHMJReceiveHandle.s2c_OTHER_PEOPLE_JOINT_IN)},
     	--返回退出比赛结果
     	[PROTOCOL.s2c_QUIT_MATCH_RETURN]     = {handler(self, XLCHMJReceiveHandle.s2c_QUIT_MATCH_RETURN)},
     	--比赛开始逻辑0x7104//牌局，开始发送其他玩家信息
     	[PROTOCOL.s2c_GAME_BEGIN_LOGIC]     = {handler(self, XLCHMJReceiveHandle.s2c_GAME_BEGIN_LOGIC)},
     	--每轮打完之后 会给玩家发送比赛状态信息0x7106
     	[PROTOCOL.s2c_GAME_STATE_MSG]     = {handler(self, XLCHMJReceiveHandle.s2c_GAME_STATE_MSG)},
     	-- 比赛的过程中会收到比赛的排名信息  0x7114
     	[PROTOCOL.s2c_PAI_MING_MSG]     = {handler(self, XLCHMJReceiveHandle.s2c_PAI_MING_MSG)},
     	--发送用户重连回比赛开赛后的等待界面
     	-- [PROTOCOL.s2c_SVR_MATCH_WAIT]     = {handler(self, XLCHMJReceiveHandle.s2c_SVR_MATCH_WAIT)},
     	--用户重新登录比赛场房间的消息返回
     	-- [PROTOCOL.s2c_SVR_REGET_MATCH_ROOM] = {handler(self, XLCHMJReceiveHandle.s2c_SVR_REGET_MATCH_ROOM)},
        --错误提示5001
        [PROTOCOL.BROADCAST_ERROR_TIPS] = {handler(self, XLCHMJReceiveHandle.BROADCAST_ERROR_TIPS)},

        --4800扣台费协议
        [PROTOCOL.BROADCAST_CHANGE_COINS] = {handler(self, XLCHMJReceiveHandle.BROADCAST_CHANGE_COINS)},

        --111 广播玩家充值
        [PROTOCOL.SVR_CHARGE_BROADCAST]       = {handler(self, XLCHMJReceiveHandle.SVR_CHARGE_BROADCAST)},
        -- 1108
        [PROTOCOL.SERVER_SEND_LAST_RECORD] = {handler(self, XLCHMJReceiveHandle.SERVER_SEND_LAST_RECORD)},
        --广播其他用户坐下（金币场） 1031
        [PROTOCOL.BROADCAST_USER_SIT_DOWN] = {handler(self, XLCHMJReceiveHandle.BROADCAST_USER_SIT_DOWN)},
        --广播用户站起 1032
        [PROTOCOL.BROADCAST_USER_STAND_UP] = {handler(self, XLCHMJReceiveHandle.BROADCAST_USER_STAND_UP)},
        --1033
        [PROTOCOL.BROADCAST_USER_QUIT_ROOM] = {handler(self, XLCHMJReceiveHandle.BROADCAST_USER_QUIT_ROOM)},

        [PROTOCOL.SVR_REQ_TEST_CARDS]={handler(self, XLCHMJReceiveHandle.SVR_REQ_TEST_CARDS)},
        [PROTOCOL.SVR_TEST_CARD]={handler(self, XLCHMJReceiveHandle.SVR_TEST_CARD)},



        --通知可以出牌
        [PROTOCOL.SVR_OUT_CARD]={handler(self, XLCHMJReceiveHandle.SVR_OUT_CARD)},
        --接收服务器放回的指定用户信息pack168
         -- [PROTOCOL.SERVER_CMD_HALL_GET_MESSAGE] = {handler(self, XLCHMJReceiveHandle.SERVER_CMD_HALL_GET_MESSAGE)},



        [PROTOCOL.SVR_HUAN_PAI] = {handler(self, XLCHMJReceiveHandle.SVR_HUAN_PAI)},
        [PROTOCOL.SVR_HUAN_PAI_REUSLT] = {handler(self, XLCHMJReceiveHandle.SVR_HUAN_PAI_REUSLT)},
        
        [PROTOCOL.SVR_CHOICE_QUE] = {handler(self, XLCHMJReceiveHandle.SVR_CHOICE_QUE)},
        
        [PROTOCOL.SVR_QUE_REUSLT] = {handler(self, XLCHMJReceiveHandle.SVR_QUE_REUSLT)},
        
        [PROTOCOL.SVR__UPDATE_SCORE] = {handler(self, XLCHMJReceiveHandle.SVR__UPDATE_SCORE)},
        [PROTOCOL.SVR_UPDATE_GANGSCORE] = {handler(self, XLCHMJReceiveHandle.SVR_UPDATE_GANGSCORE)},

    }
    table.merge(self.func_, func_)

end

function XLCHMJReceiveHandle:SERVER_SEND_LAST_RECORD(pack)
    dump(pack, "--------- 2016, 查看上局战绩")
    if pack then
        isShowRecord = true
        require(TpackageName..".RoundEndingLayer"):showZhuaniao(pack, false)
    end
end


--5001
function XLCHMJReceiveHandle:BROADCAST_ERROR_TIPS(pack)

    dump(pack, "-----返回错误提示5001-----")

    local errorCode = pack.errorCode
    if tbErrorCode[errorCode] then

        if errorCode == 18 then
            -- local sure_fuc = function ()
            --     require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
            -- end
            -- require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode], "", sure_fuc)
            require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
        else
            require("hall.GameTips"):showTips("提示", "", 3, tbErrorCode[errorCode])
        end
    else
        require("hall.GameTips"):showTips("提示", "", 3, "未知的错误")
    end
end

function XLCHMJReceiveHandle:showExpression(msg)
    local uid_from = tonumber(msg["uid_from"]) or 1
    local uid_to = tonumber(msg["uid_to"]) or 1
    local expressionType = tonumber(msg["expressionType"]) or 1

    local positionTable_BySeatId = XLCHMJ_ROOM.positionTable
    ------------------------------------------------------------------------------------
    local from_x = positionTable_BySeatId[uid_from ].x
    local from_y = positionTable_BySeatId[uid_from ].y

    local to_x   = positionTable_BySeatId[uid_to ].x
    local to_y   = positionTable_BySeatId[uid_to ].y
    require("hall.view.animView.animView"):ShowAnimationByPosition(from_x, from_y, to_x, to_y, expressionType)
end

function XLCHMJReceiveHandle:showTextMessage(pack)

    local s = SCENENOW["scene"]:getChildByName("faceUI")
    local seatId = XLCHMJ_SEAT_TABLE[pack.uid ]
    local sex = 1
    if pack.uid == USER_INFO["uid"] then
        sex = XLCHMJ_MY_USERINFO.sex
    else
        sex = XLCHMJ_USERINFO_TABLE[seatId ].sex or 0
    end

    local playerType = cardUtils:getPlayerType(seatId)
    local node_head = GamePlaneOperator:getHeadNode(playerType)

    s:showGetText(pack.uid, pack.textMessage, tonumber(sex), node_head, false)
end

--接收服务器返回的组局信息
function XLCHMJReceiveHandle:SERVER_CMD_MESSAGE(pack)

    if bm.isInGame == false then
        return
    end

    local msg = json.decode(pack.msg)
    dump(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
        local msgType = msg.msgType
        if msgType ~= nil and msgType ~= "" then
			if msgType == "expression" then   --表情
                self:showExpression(msg)
			elseif msgType == "text" then
                self:showTextMessage(msg)
            elseif msgType == "emoji" then
                local emojiPack = {}
                emojiPack["uid"] = msg.uid
                emojiPack["type"] = msg.type
				self:SVR_MSG_FACE(emojiPack)
			elseif  msgType == "EmojiArmatureView" then   --文字聊天
                self:SVR_MSG_EMOJI_ARMATURE(msg)
           end

            if device.platform == "ios" then

                if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")

                     --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url, msg.uid, msg.voiceTime)
					require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
					--通知本地播放录音

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

            elseif device.platform == "android" then


                if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")

                    --require("hall.view.voicePlayView.voiceListView"):addVoiceMsg(msg.url, msg.uid, msg.voiceTime)
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

function XLCHMJReceiveHandle:SVR_MSG_EMOJI_ARMATURE(pack)
    local EmojiArmatureView = SCENENOW.scene:getChildByName("EmojiArmatureView")
    if not EmojiArmatureView then
        return
    end
    local from_id = pack.uid
    local to_uid = pack.to_uid
    local emojiType = pack.type
    local toPos = XLCHMJ_ROOM.positionTable[to_uid]
    local fromPos = XLCHMJ_ROOM.positionTable[from_id]
	
    EmojiArmatureView:showAnimi(toPos, fromPos, emojiType)
end

--接收服务器发来的距离数据
function XLCHMJReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack,"-------距离数据---------")

    local msgList = pack.msgList
    --存放距离数据的数组

    local LocaArrayByPlayerType = {}

    for k,v in pairs(msgList) do
    	if v ~= nil and v ~= "" then
    		local msg = json.decode(v)
            if msg ~= nil then
                if msg.uid ~= nil then
                    if XLCHMJ_SEAT_TABLE and next(XLCHMJ_SEAT_TABLE)~=nil then
                    local seatId = XLCHMJ_SEAT_TABLE[msg.uid] or 1
                    local playerType = cardUtils:getPlayerType(seatId)
                    LocaArrayByPlayerType[playerType] = {[1] = tonumber(msg.longitude) ,[2] = tonumber(msg.latitude)}
                    end
                    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid,msg)

                end
            end
    	end
    end

    --[[if #LocaArrayByPlayerType>XLCH_PLAYER_COUNT-1 then
       if XLCHMJ_GAME_STATUS ~= 1 then
         GamePlaneOperator:showDistance(LocaArrayByPlayerType,true)
       else
         GamePlaneOperator:showDistance(LocaArrayByPlayerType,false)
       end
    end--]]

end

--会牌协议
function XLCHMJReceiveHandle:SVR_HUIPAI(pack)

	HUIPAI=pack.PrivateHuipai or {}
    local PublicHuipai=pack.Huipai
    table.insert(HUIPAI,PublicHuipai)

    GamePlaneOperator:HuiPai(CARD_PLAYERTYPE_MY,pack.Huipai)
end

--加注协议
function XLCHMJReceiveHandle:SVR_JIAPIAO(pack)

	local scenes  = SCENENOW['scene']

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()

	GamePlaneOperator:showCenterPlane()

	GamePlaneOperator:showJiapiaoPlane(true)
end

--加注协议
function XLCHMJReceiveHandle:SVR_JIAPIAO_BROADCAST(pack)
	local playerType = cardUtils:getPlayerType(pack.seatId)
	GamePlaneOperator:showPiaoImg(playerType, pack.jiapiao, true)
	GamePlaneOperator:showPiaoPlane(playerType, pack.jiapiao, true)
end

--广播用户IP
function XLCHMJReceiveHandle:BROADCAST_USER_IP(pack)

    dump(pack,"-------广播用户IP---------")
	 local playeripdata = pack.playeripdata or {}
     local new_ip_table={}
    for _,ip_data in pairs(playeripdata) do
      local ip_ = ip_data.ip or ""
      local uid_ = ip_data.uid or 0
      if uid_ ~= 0 then
        local seatId = XLCHMJ_SEAT_TABLE[uid_ ]
        new_ip_table[uid_] = ip_
	    if seatId then
	        --todo

	        if XLCHMJ_USERINFO_TABLE[seatId ] then
	            --todo
	            XLCHMJ_USERINFO_TABLE[seatId ].ip = ip_


	        end
	    end
      end
    end

    			local myIp = ""

	            if XLCHMJ_MY_USERINFO.seat_id and XLCHMJ_USERINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ] then
	            	--todo
	            	myIp = XLCHMJ_USERINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ].ip
	            end


	            local ipTable = {}
	            for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
	            	if v.ip and v.ip ~= myIp and v.ip~="" then
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

                if  XLCHMJ_ROUND and XLCHMJ_ROUND < 2  then    --重连时GDMJ_ROUND也会重置，所以自己重连时也会生效

    	            if msg ~= "" then
    	            	--todo
    	            	require("hall.GameCommon"):showAlert(false, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
    	            	require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
    	            end


                    local ip = new_ip_table[USER_INFO["uid"] ] or ""
                    sendHandle:CLIENT_CMD_FORWARD_MESSAGE(ip)

                end


end

--表情协议
function XLCHMJReceiveHandle:SVR_MSG_FACE(pack)
	if SCENENOW["name"] == run_scene_name then
		local seatId = XLCHMJ_SEAT_TABLE[pack.uid ] or 0

		local sex = 1

        if  XLCHMJ_USERINFO_TABLE[seatId ] then
            sex = XLCHMJ_USERINFO_TABLE[seatId ].sex
        end

		local playerType = cardUtils:getPlayerType(seatId)

		local isLeft = false
		if playerType == CARD_PLAYERTYPE_RIGHT then
			--todo
			isLeft = true
		end

		local node_head = GamePlaneOperator:getHeadNode(playerType)

        SCENENOW["scene"]:SVR_MSG_FACE(pack.uid, pack.type, sex, node_head, isLeft)
    end
end

--海底牌
function XLCHMJReceiveHandle:SVR_HAIDI_CARD(pack)
	XLCHMJ_REMAIN_CARDS_COUNT = 0
	GamePlaneOperator:showRemainCardsCount()
	manyouPlaneOperator:show(pack.card, pack.uid)
end

function XLCHMJReceiveHandle:SVR_LIANGDAO_REMAID(pack)
	XLCHMJ_ROOM.dianpao_card = pack.card

	local desc = "不能点炮，请重新出牌\n\n"

	desc = desc .. "接炮的玩家："

	for k,v in pairs(pack.winSeats) do
		desc = desc .. XLCHMJ_USERINFO_TABLE[v ].nick .. "  "
	end

	require("hall.GameCommon"):showAlert(true, desc, 300)

	D3_CHUPAI = 1
end

--出牌错误返回
function XLCHMJReceiveHandle:SVR_CHUPAI_ERROR(pack)
    dump(pack,"SVR_CHUPAI_ERROR")
	local errorCode = pack.errorCode

	if errorCode == 1 then
		--todo
		D3_CHUPAI = 1
	elseif errorCode == 2 then
		D3_CHUPAI = 1
		require("hall.GameCommon"):showAlert(true, "正在等待自己或者其他玩家操作", 200)
	elseif errorCode == 3 then
		D3_CHUPAI = 0
	elseif errorCode == 4 then
		D3_CHUPAI = 1
	end
end

--获取玩家显示的位置号 0自己，1左边玩家，2对家，3右边玩家
function XLCHMJReceiveHandle:getIndex(uid)

	if tonumber(uid) == tonumber(USER_INFO["uid"]) then
		return 0
	end
	local other_seat  = XLCHMJ_ROOM.User[uid]
	--dump( XLCHMJ_ROOM.User, " XLCHMJ_ROOM.User")

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

--漫游
function XLCHMJReceiveHandle:SVR_MANYOU(pack)
	manyouPlaneOperator:show()
end

--显示倒计时器
function XLCHMJReceiveHandle:showTimer(uid,time)

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--设置显示计时器
	scenes:show_timer_visible(true)

	--初始化计时器
	scenes:init_clock()

	if XLCHMJ_ROOM.timerid then
		bm.SchedulerPool:clear(XLCHMJ_ROOM.timerid)
	end

	local index = self:getIndex(uid)
	scenes:show_timer_index(index)
	XLCHMJ_ROOM.timer   = time
	self.timecount_ = 0
	XLCHMJ_ROOM.timerid = nil

	XLCHMJ_ROOM.timerid = bm.SchedulerPool:loopCall(function()

		self.timecount_ = self.timecount_ + 1

		if XLCHMJ_ROOM.timer and self.timecount_ % 5 == 0 then
			XLCHMJ_ROOM.timer  = XLCHMJ_ROOM.timer - 1
		end

		if XLCHMJ_ROOM.timer and XLCHMJ_ROOM.timer >= 0 and XLCHMJ_ROOM.timer <= 9 then
			local scenes  = SCENENOW['scene']
			if SCENENOW['name'] == run_scene_name and scenes.show_timer_num then
				--显示时间数字
				scenes:show_timer_num(XLCHMJ_ROOM.timer)
				--
				scenes:showClock(index,XLCHMJ_ROOM.timer,true)
			end
		end

		return true

	end,0.2)
end

--清理界面
function XLCHMJReceiveHandle:clearUserView(index)

	--dump(index, "-----清理界面-----")

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

	if XLCHMJ_ROOM.timerid then
		bm.SchedulerPool:clear(XLCHMJ_ROOM.timerid)
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
--麻将游戏加载请求方法
function XLCHMJReceiveHandle:callFunc(pack)

    if SCENENOW['name'] ~= run_scene_name then
        return
    end

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end
-------------------------------------------------------------------------------------------------------------------

--进出房间相关
--用户进入房间 100D
function XLCHMJReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
    --[[
	--dump(pack ,"-----用户进入房间-----")
	if pack ~= nil then
		self:showPlayer(pack)

		local uid_arr = {}

		for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
			table.insert(uid_arr, v.uid)
		end

		require("hall.GameSetting"):setPlayerUid(uid_arr)

        if #LocaArrayByPlayerType>3 then
           if XLCHMJ_GAME_STATUS ~= 1 then
             GamePlaneOperator:showDistance(LocaArrayByPlayerType,true)
           else
             GamePlaneOperator:showDistance(LocaArrayByPlayerType,false)
           end
           -- LocaArrayByPlayerType ={}
        end

        self:remaidIP()
	end
    --]]
    dump(pack ,"----- 100D 用户进入房间-----")

    if pack ~= nil and pack.seat_id > -1 then
        local playerType = cardUtils:getPlayerType(pack.seat_id)
        if playerType then
			GamePlaneOperator:showNetworkImg(playerType, false)
			if not XLCHMJ_USERINFO_TABLE[pack.seat_id ] then
				XLCHMJ_USERINFO_TABLE[pack.seat_id ] = {}
			end
			if not XLCHMJ_PLAYERS_INFOS[pack.uid ] then
				XLCHMJ_PLAYERS_INFOS[pack.uid ] = {}
			end
            XLCHMJ_USERINFO_TABLE[pack.seat_id ].is_online = 1
            XLCHMJ_PLAYERS_INFOS[pack.uid].is_online = 1
			XLCHMJ_PLAYERS_INFOS[pack.uid].nick = pack.nick
			XLCHMJ_PLAYERS_INFOS[pack.uid].photoUrl = pack.photoUrl
			XLCHMJ_PLAYERS_INFOS[pack.uid].latitude = pack.latitude
			XLCHMJ_PLAYERS_INFOS[pack.uid].longitude = pack.longitude
			XLCHMJ_PLAYERS_INFOS[pack.uid].otherInfoJson = pack.otherInfoJson
			XLCHMJ_PLAYERS_INFOS[pack.uid].ip = pack.ip
			XLCHMJ_PLAYERS_INFOS[pack.uid].if_ready = pack.if_ready
			XLCHMJ_PLAYERS_INFOS[pack.uid].coins = pack.coins
			XLCHMJ_PLAYERS_INFOS[pack.uid].seat_id = pack.seat_id

            --gps显示
            SCENENOW['scene']:showGPSButton()
        end
    end
end

--处理进入房间
--function XLCHMJReceiveHandle:SVR_GET_ROOM_OK(pack_data)
--	--print("---------------------------SVR_GET_ROOM_OK----------------------------------")
--	--dump(pack_data)
--	--print("denglusuccess table id is ",pack_data['tid'],bm.isGroup,USER_INFO["activity_id"])
--
--	--print("group test")
--	-- if not bm.isGroup  then
--
--    if pack_data.tid == 0 then
--        --todo
--        display_scene(GameScene_filePath, 1)
--
--        require("hall.GameTips"):showTips("提示", "", 2, "游戏已结束!")
--
--        return
--    end
--
--    if require("hall.gameSettings"):getGameMode() ~= "group" then
--		--todo
--		local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
--        :setParameter("tableid", pack_data['tid'])
--        :setParameter("nUserId", USER_INFO["uid"])
--        :setParameter("strkey", "")
--        :setParameter("strinfo", USER_INFO["user_info"])
--        :setParameter("iflag", 2)
--        :setParameter("version", 1)
--        :setParameter("activity_id","")
--        :build()
--    	bm.server:send(pack)
--    	--print("sending----------------1001............")
--	else
--		--print("group test ok")
--
--		local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
--        :setParameter("tableid", pack_data['tid'])
--        :setParameter("nUserId", USER_INFO["uid"])
--        :setParameter("strkey", json.encode("kadlelala"))
--        :setParameter("strinfo", USER_INFO["user_info"])
--      	:setParameter("iflag", 2)
--        :setParameter("version", 1)
--        :setParameter("activity_id", USER_INFO["activity_id"])
--        :build()
--    	bm.server:send(pack)
--    	--print("sending----------------1001............")
--	end
--end

--登录房间成功  1007
function XLCHMJReceiveHandle:SVR_LOGIN_ROOM(pack)
	require(NetworkLoadingView_filePath):removeView(888)
	dump(pack,"1007登入")
	G_game.laiziCount = pack.laiziCount

	voiceUtils:playBackgroundMusic()
	SCENENOW['scene']:removeChildByName("loading")
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
    USER_INFO.configData=pack.gameConfigJson
    is_End = false
	local gameConfigtbl = json.decode(pack["gameConfigJson"])
    isGoldGame = pack.isGoldGame
    dump(pack, "------------ 1007 -----------")
    USER_INFO["activity_id"] = pack.activityId
    USER_INFO["invote_code"] = pack.inviteCode
	if pack.club_id >0 then
		CLUB_ID = pack.club_id
		USER_INFO["family_id"] = pack.club_id
	end
    SCENENOW['scene']:showInviteCode()
    HEART_BEAT_TID = USER_INFO["tid"]

    TableState = 0
	XLCH_PLAYER_COUNT = gameConfigtbl.maxSeatCount
	OnSeatCount = XLCH_PLAYER_COUN

    XLCHMJ_CARDS_LESS_INIT =  pack.card_less
	XLCHMJ_GAME_STATUS = 0

	XLCHMJ_USERINFO_TABLE = {}
	XLCHMJ_SEAT_TABLE = {}
    XLCHMJ_PLAYERS_INFOS = {}

	--dump(pack, "-----登录房间成功-----")

	XLCHMJ_GROUP_ENDING_DATA = nil

	bm.User = {}

    initialChip = pack.baseChip
    -- if isGoldGame == 0 then
    if isGoldGame ~= 1 then
        initialChip = 0
    end

    BASE_CHIP = pack.base
    XLCHMJ_ROOM.base = pack.base

    MY_SEAT_ID = pack.seat_id
    if MY_SEAT_ID >= 0 then
        RELATIVE_SEAT_ID = MY_SEAT_ID
    else
        RELATIVE_SEAT_ID = 0
    end

    --绘制自己的信息
    XLCHMJ_MY_USERINFO.uid = pack.uid
	XLCHMJ_MY_USERINFO.seat_id = pack.seat_id
    XLCHMJ_MY_USERINFO.nick = pack.nick
	XLCHMJ_MY_USERINFO.coins = pack.coins
	XLCHMJ_MY_USERINFO.photoUrl = pack.photoUrl
	XLCHMJ_MY_USERINFO.sex = pack.sex

    XLCHMJ_REMAIN_CARDS_COUNT = pack.card_less
    SCENENOW['scene']:showGameConfig(gameConfigtbl)
   
    --[[
	XLCHMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY ] = pack.seat_id
	XLCHMJ_SEAT_TABLE[USER_INFO["uid"] ] = pack.seat_id

	XLCHMJ_USERINFO_TABLE[pack.seat_id ] = {}
	XLCHMJ_USERINFO_TABLE[pack.seat_id ].photoUrl = USER_INFO["icon_url"]
	XLCHMJ_USERINFO_TABLE[pack.seat_id ].uid = USER_INFO["uid"]
	XLCHMJ_USERINFO_TABLE[pack.seat_id ].nick = USER_INFO["nick"]
	XLCHMJ_USERINFO_TABLE[pack.seat_id ].coins = pack["gold"]
	XLCHMJ_USERINFO_TABLE[pack.seat_id ].sex = USER_INFO["sex"]

    XLCHMJ_USERINFO_TABLE[pack.seat_id ].ip = pack.ip
    XLCHMJ_USERINFO_TABLE[pack.seat_id ].latitude = pack.latitude
    XLCHMJ_USERINFO_TABLE[pack.seat_id ].longitude = pack.longitude


	local infoPlane = GamePlaneOperator:showPlayerInfo(CARD_PLAYERTYPE_MY, XLCHMJ_MY_USERINFO)
	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width, infoPlane:getAnchorPoint().y * infoPlane:getSize().height)

	XLCHMJ_ROOM.positionTable[USER_INFO["uid"] ] = infoPlane:convertToWorldSpace(point)
	local position = XLCHMJ_ROOM.positionTable[USER_INFO["uid"] ]
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(USER_INFO["uid"]),position)
     ]]

    --设置自己已准备
    -- GamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_MY)
	--绘制其他玩家
	if pack.user_mount > 0  then
		for i,v in pairs(pack.users_info) do
			--dump(pack, "player test")
			-- XLCHMJReceiveHandle:showPlayer(v)
            XLCHMJReceiveHandle:collectPlayerData(v)
		end
	end

	--SCENENOW["scene"]:ShowRecordButton()

	local uid_arr = {}

	for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)
    local playerType = cardUtils:getPlayerType(pack.seat_id)
    LocaArrayByPlayerType[playerType] = {[1] = tonumber(pack.longitude) ,[2] = tonumber(pack.latitude)}

    --[[
    local dict = {}

    dict.uid = USER_INFO["uid"]
    dict.nickName = USER_INFO["nick"]
    dict.longitude = pack.longitude
    dict.latitude = pack.latitude
    dict.ip = pack.ip
    dict.invote_code = USER_INFO["invote_code"]
    dump("---------10007 ------ ")
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(USER_INFO["uid"], dict)

    XLCHMJ_USERINFO_TABLE[pack.seat_id ].ip = pack.ip

	-- sendHandle:readyNow()
    --]]

	SCENENOW["scene"]:ShowChatButton()
    --[[dump(LocaArrayByPlayerType, "LocaArrayByPlayerType")
    LocaArrayByPlayerType = {}
    if #LocaArrayByPlayerType>3 then
           if XLCHMJ_GAME_STATUS ~= 1 then
             GamePlaneOperator:showDistance(LocaArrayByPlayerType,true)
           else
             GamePlaneOperator:showDistance(LocaArrayByPlayerType,false)
           end
           -- LocaArrayByPlayerType ={}
    end--]]

    self:remaidIP()

end

function XLCHMJReceiveHandle:collectPlayerData(data)
    dump(data, "------- collectPlayerData ----")
    if SCENENOW['name'] ~= run_scene_name then
        return
    end

    local userInfo = {}

    userInfo.uid = data.uid
    userInfo.seat_id = data.seat_id
    userInfo.nick = data.nick
    userInfo.coins = data.coins 
    userInfo.photoUrl = data.photoUrl
    userInfo.sex = data.sex
    userInfo.if_ready = data.if_ready or 0
    userInfo.latitude = data.latitude
    userInfo.longitude = data.longitude
    userInfo.is_online = data.is_online or 1
	--IP
	userInfo.ip = "0.0.0.0"
	userInfo.otherInfo = data.otherInfoJson

    userInfo.m_tianTing = data.m_tianTing or 0 --是否听天
    userInfo.m_isMenHu = data.m_isMenHu or 0 --是否闷胡了

    userInfo.m_bAI = data.m_bAI or 0 --是否托管了

    -- 城市
    local otherInfo = json.decode(data.otherInfoJson)
    userInfo.city = otherInfo.city
	if otherInfo.ip then
		userInfo.ip = otherInfo.ip
	end

    -- 这个用来存所有玩家信息：在座玩家+围观玩家
    XLCHMJ_PLAYERS_INFOS[data.uid] = userInfo
    XLCHMJ_SEAT_TABLE[data.uid ] = data.seat_id

	dump(userInfo, "------- collectPlayerData ----")
	
    if not userInfo.addres or userInfo.addres == "" then
        ReqMgr:getAddress( userInfo.latitude, userInfo.longitude, userInfo.uid)
    end

    local seat_id = data.seat_id
    if seat_id < 0 then
        return
    else
        XLCHMJReceiveHandle:showPlayer(userInfo)
    end

end

--登陆错误
function XLCHMJReceiveHandle:SVR_ERROR(pack)

	dump(pack, "----- 1005 登陆错误-----")

	local errcode = "error"
	local showBtn = 2
	if pack["type"] == 9 then
		errcode = "change_money"
		showBtn = 1
	end

    require("hall.GameTips"):showTips("提示", "tohall", 3, loginErrorCode[pack["type"]])

    local callFuncAc = cc.CallFunc:create(
        function ()
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
        end)
    SCENENOW['scene']:runAction(cc.Sequence:create(cc.DelayTime:create(3), callFuncAc))
	-- require("hall.GameTips"):showTips(tbErrorCode[pack["type"]],errcode,showBtn)

end


---------------------------------------------------重连--------------------------------------------------------
--用户重登房间   1107
function XLCHMJReceiveHandle:SVR_REGET_ROOM(pack)
	require(NetworkLoadingView_filePath):removeView(888)
	SCENENOW['scene']:setDefine()
	voiceUtils:playBackgroundMusic()
	dump(pack, "-----1107 重连房间成功-----")
	G_game.laiziCount = pack.laiziCount
    --局数赋值
    XLCHMJ_TOTAL_ROUNDS= pack.totalRound or 0
    XLCHMJ_ROUND=pack.GroudAllTimes or 0
    is_End = false
	local gameConfigtbl = json.decode(pack["gameConfigJson"])
	XLCHMJ_GROUP_ENDING_DATA = nil
    USER_INFO.family_id=pack.club_id
    USER_INFO.configData=pack.gameConfigJson
	SCENENOW['scene']:removeChildByName("loading")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	if pack.club_id >0 then
		CLUB_ID = pack.club_id
		USER_INFO["family_id"] = pack.club_id
	end
    XLCHMJ_USERINFO_TABLE = {}
    XLCHMJ_SEAT_TABLE = {}
    XLCHMJ_PLAYERS_INFOS = {}
	XLCHMJ_AI = pack.m_bAI
    isGoldGame = pack.isGoldGame

    USER_INFO["activity_id"] = pack.activityId
    USER_INFO["invote_code"] = pack.inviteCode

    BASE_CHIP = pack.base
    XLCHMJ_ROOM.base = pack.base

    initialChip = pack.baseChip

    if isGoldGame ~= 1 then
        initialChip = 0
    end

    scenes:showInviteCode()

    HEART_BEAT_TID = USER_INFO["tid"]

	XLCHMJ_GAME_STATUS = pack.TableState

	XLCH_PLAYER_COUNT = gameConfigtbl.maxSeatCount
    local TableState = pack.TableState


    scenes:ShowSettingButton()
	scenes:ShowChatButton()

	GamePlaneOperator:clearGameDatas()

	GamePlaneOperator:showCenterPlane()

    MY_SEAT_ID = pack.seat_id
    if MY_SEAT_ID >= 0 then
        RELATIVE_SEAT_ID = MY_SEAT_ID
    else
        RELATIVE_SEAT_ID = 0
    end

    if MY_SEAT_ID < 0 and OnSeatCount == XLCH_PLAYER_COUNT  then
        -- 隐藏坐下按钮，相当于准备状态
        SCENENOW['scene']:showBtnByUserStatus("ready")
    end

	XLCHMJ_REMAIN_CARDS_COUNT = pack.card_less
	if XLCHMJ_GAME_STATUS == 1 then
		XLCHMJ_CARDS_LESS_INIT = pack.cardCount
		GamePlaneOperator:initUI_CardBackMgr(pack.card_less, pack.m_nShaiZi)
	end

	XLCHMJ_MY_USERINFO.seat_id = pack.seat_id

	------------------------------------------------绘制杂项信息-----------------------------------------
	XLCHMJ_MY_USERINFO.photoUrl = pack.photoUrl
	XLCHMJ_MY_USERINFO.nick = pack.nick
	XLCHMJ_MY_USERINFO.coins = pack.coins
	XLCHMJ_MY_USERINFO.uid = pack.uid
	XLCHMJ_MY_USERINFO.sex = pack.sex

	SCENENOW['scene']:showGameConfig(gameConfigtbl)
	SCENENOW['scene']:showCopyInviteBtn(true)
    if  TableState ~= 0 then
        scenes:hideCloseRoomButton()
        scenes:hideShareButton()
    end


    ------------------------------------------------绘制玩家数据----------------------------------------
    if pack.nPlayerCount > 0  then
        for i,v in pairs(pack.users_info) do
            self:collectPlayerData(v)
        end
    end

    self:remaidIP()

	local uid_arr = {}

	for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end
	require("hall.GameSetting"):setPlayerUid(uid_arr)


    if  TableState == 0 then
        return
    end
	XLCHMJ_ZHUANG_UID = XLCHMJ_USERINFO_TABLE[pack.m_nBankSeatId ].uid
	local zhuangPlayerType = cardUtils:getPlayerType(pack.m_nBankSeatId)
	GamePlaneOperator:showZhuang(zhuangPlayerType)

    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"] = XLCHMJ_ROOM.base
	else
		SCENENOW["scene"]:gameReady()
	end
	-----------------------------------------绘制其他玩家手牌-----------------------------------------------
	if pack.nPlayerCount > 0  then
		for i,v in pairs(pack.users_info) do
            if v.uid ~= USER_INFO['uid'] then
                local gameInfo = {}
                gameInfo.porg = {}
                gameInfo.hand = {}
                for i=1,pack.users_info[i].countHandCards do
                    table.insert(gameInfo.hand, 0)
                end
                gameInfo.out = {}
                XLCHMJ_GAMEINFO_TABLE[pack.users_info[i].seat_id ] = gameInfo
                local playerType = cardUtils:getPlayerType(pack.users_info[i].seat_id)
                GamePlaneOperator:redrawGameInfo(playerType, pack.users_info[i])
            end
		end
	end
	------------------------------------------绘制自己的手牌和操作-----------------------------------------------
    UserDingQueHuaSe=pack.que
	local myCards = pack.handCards
    table.sort(myCards)


		local myGameInfo = {}
		myGameInfo.porg = {}
		myGameInfo.hand = myCards
		myGameInfo.out = {}

		XLCHMJ_GAMEINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ] = myGameInfo
        --在听状态的话创建听牌数组
		if pack.tingHuCount>0 then
			--todo
			XLCHMJ_GAMEINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ].ting = 1
			XLCHMJ_GAMEINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ].tingHuCards = pack.tingHuCards
		end
        -------------------------------------------新抓的牌移到右侧及绘制手牌----------------------------------
        if pack.handCount%3  == 2 then     --手牌数量对3取余数为2

            D3_CHUPAI = 1
            local newCard = myCards[#myCards]
            local isGrep = false

            for k,v in pairs(myCards) do
                if v == newCard then
                    --todo
                    table.remove(myCards, k)
                    isGrep = true
                    break
                end
            end

            -- 重绘桌面信息
            GamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)
            --手里有新抓到的牌
            if isGrep then
				GamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard,pack.tingCards)
				
				--听牌 蓝色提示点点
				GamePlaneOperator:setDianNodeBytingpai()
			end
        else
            GamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)
        end

        --这里了需要去掉报听 如果玩家已经點擊天听 正在等待出牌
        if pack.m_tianTing and pack.m_tianTing > 0 and bit.band(pack.handle, CONTROL_TYPE_BAOJIAO) > 0 then
            pack.handle = pack.handle - CONTROL_TYPE_BAOJIAO
        end

		local controlTable = {}
		controlTable = cardUtils:getControlTable(pack.handle, pack.handleCard, 3, pack.ableGangCards)
		GamePlaneOperator:showControlPlane(controlTable)



    ----------------------------------------------绘制闷牌数据---------------------------------------
    if pack.mhuCounts > 0 then  --自己的
        for k,v in pairs(pack.mhuCards) do
            local value = bit.band(v, 0xFF)
            local seatId = XLCHMJ_SEAT_TABLE[USER_INFO.uid]
            local playerType = cardUtils:getPlayerType(seatId)
            GamePlaneOperator:playHuaCard(playerType, value)
            table.insert(XLCHMJ_MENHUCARD[playerType],value)
        end
    end


    if pack.nPlayerCount > 0  then
        for i,v in pairs(pack.users_info) do
            if v.uid ~= USER_INFO.uid then
                if v.mhuCounts > 0 then
                    for k,v1 in pairs(v.mhuCards) do         
                            local value = bit.band(v1, 0xFF)
                            local playerType = cardUtils:getPlayerType(v.seat_id)
                            GamePlaneOperator:playHuaCard(playerType, value)
                            table.insert(XLCHMJ_MENHUCARD[playerType],value)
                  
                    end
                end
            end
        end
    end


    --------------------------------------换牌定缺状态重连-----------------------------------------------
--[[       Table_STATUS_HUANPAI=5      --换牌状态
    Table_STATUS_DINGQUE=6      --定缺状态--]]
    
    if pack.m_TableStatus==Table_STATUS_HUANPAI then
        if pack.IsChange==0 then   --显示换牌提示
            SCENENOW['scene']:ShowHuanPai()
        end
    elseif pack.m_TableStatus==Table_STATUS_DINGQUE then
        if pack.IsDingQue==0 then
            SCENENOW['scene']:ShowDingQue()         --显示定缺按钮
        end
    else
        --显示玩家头像上的que
        for i,v in ipairs(pack.users_info) do
            local seatId = XLCHMJ_SEAT_TABLE[v.uid]
            local playerType=cardUtils:getPlayerType(seatId)
            GamePlaneOperator:showQueImg(v.que,playerType)
            if v.uid==USER_INFO.uid then
                UserDingQueHuaSe=v.que
            end
        end
    end

    ---------------------------------------设置流水面板-------------------------------------------------
    SCENENOW['scene']:SetLiuShuiReconnet(pack)

	-----------------------------------------------------------------------------------------------

	local playerTyp = 0
	if pack.handle ~= 0 then   --重连后自己有操作的情况下
		playerTyp = cardUtils:getPlayerType(pack.currentPlayerId-1)
	    D3_CHUPAI = 2
	else
		playerTyp = cardUtils:getPlayerType(pack.currentPlayerId)
	end

    --有人报听了 现在自己还不能出牌
    if pack.can_out_card == 0 and pack.currentPlayerId == MY_SEAT_ID then
        D3_CHUPAI = 1
    end

    if (pack.can_out_card and pack.can_out_card ~= 0) or controlTable.type == BAO_JIAO_TYPE then
        --不可出牌
        D3_CHUPAI = 2
    end 

    XLCH_can_out_card = pack.can_out_card

	GamePlaneOperator:beginPlayCard(playerTyp)
    GamePlaneOperator:rotateTimer(playerTyp)

    --D3_WAIT_OPRATE_CARD = 1

	if playerTyp ~= CARD_PLAYERTYPE_MY then
		GamePlaneOperator:hideDianNodeBytingpai()
	end

	if pack.m_bAI == 1 then
		XLCHMJ_ROOM.tuoguan_ing = 1
		scenes:TgState(true)
	else
		scenes:TgState(false)
	end

    --gps显示
    scenes:showGPSButton()

    if pack.m_tianTingOutCard and pack.m_tianTingOutCard > 0 then
        BAO_JIAO_FIRST_OUT_CARD = true
    end

    GamePlaneOperator:showRemainCardsCount()

        ----------------------------------------------禁用手牌--------------------------------------------
        --这里重连的时候要知道刚抓的牌值
    if pack.IsAlreadyHu==1 then
        SCENENOW['scene']:SetSelfHandCardTouch(true,pack.CurGardCard)
    end

end
----------------------------------------------------------------------------------------------------------------


--显示其他玩家
function XLCHMJReceiveHandle:showPlayer(data)
	dump(data,"showPlayer-----data")
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

    local seat_id = data.seat_id
    if  seat_id < 0 then
        return
    end

    dump(data, "---- XLCHMJReceiveHandle:showPlayer ----")

    XLCHMJ_SEAT_TABLE[data.uid ] = seat_id

    XLCHMJ_USERINFO_TABLE[seat_id] = {}
    XLCHMJ_USERINFO_TABLE[seat_id].uid = data.uid
    XLCHMJ_USERINFO_TABLE[seat_id].seat_id = data.seat_id
    XLCHMJ_USERINFO_TABLE[seat_id].nick = data.nick
    XLCHMJ_USERINFO_TABLE[seat_id].coins = data.coins
    XLCHMJ_USERINFO_TABLE[seat_id].photoUrl = data.photoUrl
    XLCHMJ_USERINFO_TABLE[seat_id].sex = data.sex
    XLCHMJ_USERINFO_TABLE[seat_id].if_ready = data.if_ready
    XLCHMJ_USERINFO_TABLE[seat_id].latitude = data.latitude
    XLCHMJ_USERINFO_TABLE[seat_id].longitude = data.longitude
    XLCHMJ_USERINFO_TABLE[seat_id].ip = data.ip
    XLCHMJ_USERINFO_TABLE[seat_id].city = data.city
    XLCHMJ_USERINFO_TABLE[seat_id].is_online = data.is_online
	XLCHMJ_USERINFO_TABLE[seat_id].otherInfo = data.otherInfo
    XLCHMJ_USERINFO_TABLE[seat_id].m_tianTing = data.m_tianTing
    XLCHMJ_USERINFO_TABLE[seat_id].m_isMenHu = data.m_isMenHu


    local playerType = cardUtils:getPlayerType(seat_id)
    XLCHMJ_SEAT_TABLE_BY_TYPE[playerType ] = seat_id
    local userInfo = XLCHMJ_USERINFO_TABLE[seat_id ]
    LocaArrayByPlayerType[playerType] = {[1] = tonumber(data.longitude) ,[2] = tonumber(data.latitude)}

    local headNode = GamePlaneOperator:showPlayerInfo(playerType, userInfo)



    GamePlaneOperator:showTuoGuanState(playerType,data.m_bAI == 1)



    XLCHMJ_ROOM.positionTable[data.uid ] = (headNode:getParent()):convertToWorldSpace(headNode:getPosition())

    local position = XLCHMJ_ROOM.positionTable[data.uid ]

    if position then
        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(data.uid), position)
    end

    local dict = {}
    dict.uid = userInfo.uid
    dict.nickName = userInfo.nick
    dict.longitude = userInfo.longitude
    dict.latitude = userInfo.latitude
    dict.ip = userInfo.ip
    dict.city = userInfo.city
    dict.invote_code = USER_INFO["invote_code"]

    -- if isGoldGame == 0 then
    if isGoldGame ~= 1 then
        dict.gold = userInfo.coins
    end

    dump(dict, "------------ showPlayer  upDateUserInfo ---------")
    require("hall.view.userInfoView.userInfoView"):upDateUserInfo(dict.uid, dict)

    if data.uid == USER_INFO["uid"] then
        -- 显示按钮
        if XLCHMJ_GAME_STATUS == 0 then
            if data.if_ready == 0 then
                SCENENOW['scene']:showBtnByUserStatus("sit")
            else
                SCENENOW['scene']:showBtnByUserStatus("ready")
            end
        end
        -- 显示语音和聊天表情
        SCENENOW['scene']:ShowRecordButton()
        -- 显示玩家距离
    end

    if XLCHMJ_GAME_STATUS == 0 and data.if_ready == 1 then
        GamePlaneOperator:setReadyStatus(playerType)
    end

    OnSeatCount = XLCH_PLAYER_COUNT

    --[[if XLCH_PLAYER_COUNT > 3 then
        if #LocaArrayByPlayerType>3 then
            if XLCHMJ_GAME_STATUS ~= 1 then
                GamePlaneOperator:showDistance(LocaArrayByPlayerType, true)
            else
                GamePlaneOperator:showDistance(LocaArrayByPlayerType, false)
            end
        end
    end--]]

    self:remaidIP()

end

--用户退出房间
function XLCHMJReceiveHandle:SVR_QUIT_ROOM(pack)

	dump(pack,"-----100E 用户退出房间-----")

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local uid = pack.uid
	local seatId = XLCHMJ_SEAT_TABLE[uid ]

	if seatId < 0 then
		return
	end

    local playerType = cardUtils:getPlayerType(seatId)

	GamePlaneOperator:showNetworkImg(playerType, true)

    XLCHMJ_USERINFO_TABLE[seatId].is_online = 0
    XLCHMJ_PLAYERS_INFOS[pack.uid].is_online = 0

	local uid_arr = {}

	for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)
end

--用户退出游戏成功 1008
function XLCHMJReceiveHandle:SVR_QUICK_SUC(pack)
	--dump(pack,"-----玩家退出游戏成功-----")
	--audio.stopMusic(true)
    if SCENENOW['name'] ~= run_scene_name then
        return
    end
    if not is_End then
        --SCENENOW["scene"]:reConnect()
        require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
        --require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
    end
end

--用户准备相关
--广播用户准备
function XLCHMJReceiveHandle:SVR_USER_READY_BROADCAST(pack)
    local seatId = XLCHMJ_SEAT_TABLE[pack.uid ]
	local playerType = cardUtils:getPlayerType(seatId)
	if XLCHMJ_USERINFO_TABLE[seatId] then
		XLCHMJ_USERINFO_TABLE[seatId].if_ready = 1
		XLCHMJ_USERINFO_TABLE[seatId].userInfo = nil
		XLCHMJ_USERINFO_TABLE[seatId].userInfo = XLCHMJ_USERINFO_TABLE[seatId]
		if pack.uid == USER_INFO["uid"] then
			SCENENOW['scene']:showBtnByUserStatus("ready")
			local GameResult = SCENENOW["scene"]:getChildByName("GameResult")
            local roundEnd = SCENENOW["scene"]:getChildByName("roundEnd")
			if tolua.isnull(GameResult) == false then
				GameResult:removeSelf()
			end
            if tolua.isnull(roundEnd) == false then
                roundEnd:removeSelf()
            end

		end
		GamePlaneOperator:setReadyStatus(playerType)
	end
end
------------------------------------------------------------------------------------------------------

--用户操作相关
--服务器告知客户端可以进行的操作   3005
function XLCHMJReceiveHandle:SVR_NORMAL_OPERATE(pack)

	dump(pack, "-----服务器告知客户端可以进行的操作-----")
	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 1,pack.gangCards)
    dump(controlTable,"controlTable--->>>>>")
	GamePlaneOperator:showControlPlane(controlTable)
end

--广播用户进行了什么操作   4005
function XLCHMJReceiveHandle:SVR_PLAYER_USER_BROADCAST(pack)

	dump(pack,"-----广播用户进行了什么操作-----")

	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

    BAO_JIAO_FIRST_OUT_CARD = false

	local handle = pack.handle       --执行操作
	local value = bit.band(pack.card, 0xFF)  --牌值
	local seatId = XLCHMJ_SEAT_TABLE[pack.uid] --得到是哪个seatid操作
	local playerType = cardUtils:getPlayerType(seatId) --得到操作人的位置

    local isNotMenHu = true


    if bit.band(handle,HU_TYPE_ZM) > 0 or bit.band(handle,HU_TYPE_H)> 0 or bit.band(handle,HU_TYPE_GH) > 0 then
        isNotMenHu = false
        print("======进行了闷胡操作！！！=======")

       -- GamePlaneOperator:showImgAnim(playerType,500) --显示闷胡的动画

        if pack.isZimo == 1 then
            if playerType == CARD_PLAYERTYPE_MY  then
                D3_CHUPAI = 2
                GamePlaneOperator:removeCard_ZIMO_MENHU()  --删除掉手中摸到的牌
            else
                --其他范围的自摸闷胡 也要删掉最后一张手牌的位置的牌背
                GamePlaneOperator:removeCard_ZIMO_MENHU_for_Other(playerType)
            end
            cardUtils:getNewCardAfterMenPai(seatId, value) --删除掉手中牌的数据
        else
            --这里待定  可能和上面的删牌逻辑重复了
            if D3_WAIT_OPRATE_CARD ~= nil and D3_WAIT_OPRATE_CARD:getParent() then
                for i,v in ipairs(D3_HIGHLIGHT_OUT_CARDS) do
                    if v == D3_WAIT_OPRATE_CARD then
                        table.remove(D3_HIGHLIGHT_OUT_CARDS, i)
                    end
                end

                D3_WAIT_OPRATE_CARD:removeFromParent()

                D3_WAIT_OPRATE_CARD = nil

                D3_OPERATOR:hidePOINTER()
            end

            XLCHMJ_CARD_POINTER:setVisible(false)
        end

        --显示自己闷的牌
        if pack.uid == USER_INFO.uid then
            GamePlaneOperator:playHuaCard(playerType, value)
            table.insert(XLCHMJ_MENHUCARD[playerType],value)
            --禁用所有手牌
            SCENENOW['scene']:SetSelfHandCardTouch(true)
        else
                GamePlaneOperator:playHuaCard(playerType, value)
                table.insert(XLCHMJ_MENHUCARD[playerType],value)
           
           
        end
       
       -- voiceUtils:playControlSound(seatId, HU_TYPE_MEN_HU)

        --记录玩家已经胡过牌
        --XLCHMJ_USERINFO_TABLE[seatId].m_isMenHu = 1
    else
        
        local tingSeq = pack.tingCards  --听的牌
        TINGSEQ = tingSeq

        --removeCards得到要删的牌  --progCards 碰杠要显示的牌
        local progCards,removeCards = cardUtils:processControl(seatId, handle, value)

        local reloginFlage = false

        --牌的来源玩家
        local fromplayerType = cardUtils:getPlayerType(pack.lid)

        --是否有出的牌
        if  D3_WAIT_OPRATE_CARD == 1 and isNotMenHu then
            reloginFlage = true
            if fromplayerType ~= playerType then  --不是自己的操作
                D3_WAIT_OPRATE_CARD = GamePlaneOperator:removeLatestOutCard(fromplayerType,value) --这是删除桌面上的牌
            else
                D3_WAIT_OPRATE_CARD = nil
            end
        end

        dump(progCards,"progCards = ")

        --5个参数
        GamePlaneOperator:control(playerType, progCards, handle, tingSeq,removeCards,fromplayerType,reloginFlage)
        --播放音效
        voiceUtils:playControlSound(seatId, handle)     
    end
   

	if playerType == CARD_PLAYERTYPE_MY then 
        if isNotMenHu then
            D3_CHUPAI = 1
        end
        GamePlaneOperator:setDianNodeBytingpai()
	else 
        GamePlaneOperator:hideControlPlane(playerType) --取消其他玩家的操作
	end

    if playerType == CARD_PLAYERTYPE_MY then
        --长期显示自己胡什么牌
            D3_CONTROLLER:showHupai_vw(pack.card)
        
    end
end

-------------------------------------------------------------------------------------------------------------------

--发牌相关
--发牌协议
function XLCHMJReceiveHandle:SVR_SEND_USER_CARD(pack)

	dump(pack, "-----1100 发牌协议-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
    XLCHMJ_ENDING_DATA = nil
	local GameResult = SCENENOW["scene"]:getChildByName("GameResult")
	if GameResult then
		GameResult:removeSelf()
	end

    for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
        v.m_tianTing = 0
        v.m_isMenHu = 0
        XLCHMJ_MENHUCARD[k]={}
    end

    GamePlaneOperator:hideJiShow()


    GamePlaneOperator:clearAllReadyStatus()
	--GamePlaneOperator:clearPiaoImg()
	GamePlaneOperator:clearGameDatas()
    SCENENOW["scene"]:initSome()
	XLCHMJ_CARDS_LESS_INIT = pack.maxCardCount
	XLCHMJ_REMAIN_CARDS_COUNT = pack.m_nCardOffset
	GamePlaneOperator:initUI_CardBackMgr(pack.m_nCardOffset, pack.nShaizi)
	GamePlaneOperator:showRemainCardsCount()

	XLCHMJ_GAME_STATUS = 1

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()

	GamePlaneOperator:showCenterPlane()

	-- if table.getn(XLCHMJ_SEAT_TABLE_BY_TYPE) < 4 then
	-- 	--todo
	-- 	return
	-- end

	bm.palying = true
	bm.isRun=true

	XLCHMJ_ENDING_DATA = nil

	--记录庄家的座位
	bm.zuan_seat = pack.seat

	zhuangPlayerType = cardUtils:getPlayerType(bm.zuan_seat)
	GamePlaneOperator:rotateTimer(zhuangPlayerType)

	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
        --todo
        XLCHMJ_STATE = 2
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
	-- bm.SchedulerPool:delayCall(XLCHMJReceiveHandle.SchedulerSendCard,2,pack)
end

--发牌
function XLCHMJReceiveHandle:SchedulerSendCard(pack)

	XLCHMJReceiveHandle:initCardForUser(pack)
	local count = XLCH_PLAYER_COUNT -1
	for i=0, count do
		XLCHMJReceiveHandle:showPlayerCards(i)
	end

	--显示庄家
	-- XLCHMJReceiveHandle:showZhuang(pack.seat)
	local playerType = cardUtils:getPlayerType(pack.seat)

	XLCHMJ_ZHUANG_UID = XLCHMJ_USERINFO_TABLE[pack.seat ].uid

	GamePlaneOperator:showZhuang(playerType)
end

--牌库初始化
function XLCHMJReceiveHandle:initCardForUser(pack)

	for i=0,3 do
		local gameInfo = {}
		gameInfo.porg = {}
		gameInfo.hand = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		gameInfo.out = {}
		gameInfo.ting = 0
		-- XLCHMJ_ROOM.Gang[i]         = {}

		XLCHMJ_GAMEINFO_TABLE[i ] = gameInfo
	end

	local myCards = pack.cards

	table.sort(myCards)

	XLCHMJ_GAMEINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ].hand = myCards	--0号玩家的手牌

	--dump(XLCHMJ_GAMEINFO_TABLE, "cards test ")
end

--显示玩家的牌
function XLCHMJReceiveHandle:showPlayerCards( seatId )
	local playerType = cardUtils:getPlayerType(seatId)
	GamePlaneOperator:showCards(playerType)
end

--显示庄家
-- function XLCHMJReceiveHandle:showZhuang(seat)

-- 	local uid = USER_INFO["uid"]

-- 	if seat ~= bm.User.Seat then
-- 		uid = XLCHMJ_ROOM.seat_uid[seat]
-- 	end

-- 	local index = self:getIndex(uid)
-- 	local scenes = SCENENOW['scene']
-- 	if SCENENOW['name'] ~= run_scene_name then
-- 		return
-- 	end

-- 	scenes:show_widget_tip(index,true,"zuan_tip")
-- end
----------------------------------------------------------------------------------------------------------------

--换牌相关
--服务器告诉客户端，可以换牌
function XLCHMJReceiveHandle:SERVER_COMMAND_NEED_CHANGE_CARD(pack)

	--dump(pack, "-----可以换牌-----")

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	XLCHMJ_ROOM.change_card_over = false
	--dump(pack, "SERVER_COMMAND_NEED_CHANGE_CARD")
	XLCHMJ_ROOM.cardHuan={};
	bm.huanCardsStart = true

	scenes:show_Text_18(true)

	local txtTimer = display.newBMFontLabel({
	    text = 10,
	    font = "majiang/res/image/num2.fnt",
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
function XLCHMJReceiveHandle:SERVER_COMMAND_CHANGE_CARD_RESULT(pack)

	--dump(pack, "-----服务器广播换牌的结果-----")

	local scenes  = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	scenes:show_Text_18(false)

	XLCHMJ_ROOM.change_card_over = true
	--XLCHMJ_ROOM.cardHuan = XLCHMJ_ROOM.cardHuan or {} -- 可能存在没有换的状况

	local old_hand_card = XLCHMJ_ROOM.Card[0]['hand']
	--dump(old_hand_card,"old_hand_card")
	if pack.mount > 0 then
		--0号玩家的手牌
		XLCHMJ_ROOM.Card[0]['hand'] = pack.cards
		self:drawHandCard(0)
	end

	--dump(XLCHMJ_ROOM.Card[0]['hand'],"-----当前用户换牌后的新手牌-----")

	XLCHMJ_ROOM.Card[0]['hand'] = MajiangcardHandle:sortCards(XLCHMJ_ROOM.Card[0]['hand'])

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
	for i,v in pairs(XLCHMJ_ROOM.Card[0]['hand']) do

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
function  XLCHMJReceiveHandle:SVR_START_QUE_CHOICE(pack)

	--dump(pack,"-----开始选择缺门-----")

	local scenes  = SCENENOW['scene']


	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	scenes:show_other_xuanqueing(true)
	scenes:show_choosing_que(true)
end

--广播缺一门  通知用户选缺选了哪一门,这时游戏还没有开始，
function XLCHMJReceiveHandle:SVR_BROADCAST_QUE(pack)

	--dump(pack,"-----广播缺一门-----")


	bm.User.Que = nil
	XLCHMJ_ROOM.Que = true

	for i,v in pairs(pack.content) do
		self:hasChoiceQue(v.uid,v.que)
	end
end

--设置已经选缺
function XLCHMJReceiveHandle:hasChoiceQue(uid,que)

	--dump(uid,"-----设置已经选缺-----")

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
--广播抓牌用户   4006
function XLCHMJReceiveHandle:SVR_PLAYING_UID_BROADCAST(pack)

	dump(pack,"-----广播抓牌用户-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local playerType = cardUtils:getPlayerType(XLCHMJ_SEAT_TABLE[pack.uid ])
	local seatId = XLCHMJ_SEAT_TABLE[pack.uid ]

	if playerType ~= CARD_PLAYERTYPE_MY then
		GamePlaneOperator:getNewCard(playerType, 0)
        GamePlaneOperator:hideControlPlane()
	end

	XLCHMJ_REMAIN_CARDS_COUNT = pack.simplNum
	GamePlaneOperator:showRemainCardsCount()
end

--通知我抓的牌   3002
function XLCHMJReceiveHandle:SVR_OWN_CATCH_BROADCAST(pack)

	dump(pack,"-----通知我抓的牌-----")

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

    --显示剩余牌数
	XLCHMJ_REMAIN_CARDS_COUNT = XLCHMJ_REMAIN_CARDS_COUNT - 1
	GamePlaneOperator:showRemainCardsCount()

    --刷新手牌以显示听牌队列
	local tingSeq = pack.tingCards
          TINGSEQ = tingSeq

	local value = bit.band(pack.card, 0xFF)

	GamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY,value,tingSeq)

	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 2, pack.cards)

    GamePlaneOperator:showControlPlane(controlTable)

    GamePlaneOperator:setDianNodeBytingpai()

	if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
		D3_CHUPAI = 1
	else
		D3_CHUPAI = 2
	end

    if (pack.can_out_card and pack.can_out_card ~= 0) or controlTable.type == BAO_JIAO_TYPE then
        --不可出牌
        D3_CHUPAI = 2
    end 

    XLCH_can_out_card = pack.can_out_card

    --已经听牌的情况下  摸到牌以后不可自己出牌了
    local seatId = XLCHMJ_SEAT_TABLE[USER_INFO["uid"]]
    if XLCHMJ_USERINFO_TABLE[seatId].m_tianTing == 1 or XLCHMJ_USERINFO_TABLE[seatId].m_isMenHu == 1 then
         --不可出牌
        D3_CHUPAI = 2
    end 

    --长期显示自己胡什么牌
    if XLCHMJ_USERINFO_TABLE[seatId].m_tianTing == 1 or XLCHMJ_USERINFO_TABLE[seatId].m_isMenHu == 1 then
        D3_CONTROLLER:showHupai_vw(pack.card)
    elseif bit.band(pack.handle, HU_TYPE_MEN_HU) > 0 or bit.band(pack.handle, HU_TYPE_H) > 0 or bit.band(pack.handle, HU_TYPE_ZM) > 0 then
        D3_CONTROLLER:showHupai_vw(pack.card)
    end
	

end
---------------------------------------------------------------------------------------------------------------
--广播用户出牌
function XLCHMJReceiveHandle:SVR_SEND_MAJIANG_BROADCAST(pack)

	dump(pack,"-----广播用户出牌-----")

	local scenes    = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	local uid = pack.uid
	if uid == USER_INFO["uid"] then
		D3_CHUPAI = 0
	end
	--移除用户准备标志
	GamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_MY, false)
	GamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_LEFT, false)
	GamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_RIGHT, false)
	GamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_TOP, false)

	local value = bit.band(pack.card, 0xFF)

	local handleResult = cardUtils:getControlTable(pack.handle, value, 1)
    local m_isAuto = pack.m_isAuto == 1

	if (XLCHMJ_ROOM.tuoguan_ing == 1 or m_isAuto) and not BAO_JIAO_FIRST_OUT_CARD then
		if uid ~= USER_INFO["uid"] then
			GamePlaneOperator:showControlPlane(handleResult)
		end
		local seatId = XLCHMJ_SEAT_TABLE[uid ]
		local playerType = cardUtils:getPlayerType(seatId)
		GamePlaneOperator:showNetworkImg(playerType, false)
		local tag = cardUtils:playCard(seatId, value)
		GamePlaneOperator:playCard(playerType, tag, value)
		voiceUtils:playCardSound(seatId,pack.card)
		if playerType == CARD_PLAYERTYPE_MY then
			GamePlaneOperator:hideDianNodeBytingpai()
		end
	else
		if uid ~= USER_INFO["uid"] then
			GamePlaneOperator:showControlPlane(handleResult)
			local seatId = XLCHMJ_SEAT_TABLE[uid ]
			local playerType = cardUtils:getPlayerType(seatId)
			GamePlaneOperator:showNetworkImg(playerType, false)
			local tag = cardUtils:playCard(seatId, value)
			GamePlaneOperator:playCard(playerType, tag, value)
			voiceUtils:playCardSound(seatId,pack.card)
			if playerType == CARD_PLAYERTYPE_MY then
				GamePlaneOperator:hideDianNodeBytingpai()
			end
		end
	end

    BAO_JIAO_FIRST_OUT_CARD = false
end
---------------------------------------------------------------------------------------------------------------
--游戏广播相关
--广播结束游戏 没用
function XLCHMJReceiveHandle:SVR_GAME_OVER(pack)




end

---------------------------------------------------------------------------------------------------------------

--胡牌
--胡牌协议 1106
function XLCHMJReceiveHandle:SVR_HUPAI_BROADCAST(pack)

	--dump(pack,"-----胡牌协议-----")

	require("hall.recordUtils.RecordUtils"):closeRecordFrame()
	XLCHMJ_GAME_STATUS = 0

    -- for i,v in pairs(pack.hucontent) do

	-- 	local seatId = XLCHMJ_SEAT_TABLE[pack.hucontent[i].uid ]
	-- 	local playerType = cardUtils:getPlayerType(seatId)
		
	-- 	GamePlaneOperator:showCardsForHu(playerType, pack.hucontent[i].remainCards,pack.hucontent[i].card)
	-- end


    liujuFlag = false

end


--显示自摸
function XLCHMJReceiveHandle:show_zimo_tip(index,hu_type)

	--dump(index,"-----显示自摸-----")
	--dump(hu_type,"-----显示自摸-----")

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
------------------------------------------------------------------------------------------------------------------
--红中游戏结束时协议顺序   胡了4013---4008    (最后一局)4008---5100     (解散组局) 5100
--结算相关
--结算协议  6008
function XLCHMJReceiveHandle:SVR_ENDDING_BROADCAST(pack)

	dump(pack,"----一盘结束，进行结算-----")

	XLCHMJ_ENDING_DATA = pack
    UserDingQueHuaSe= 99 --定缺花色

    --流局与否判断
	XLCHMJ_ENDING_DATA['type'] = 0

    SCENENOW["scene"]:TgState(false)
    XLCHMJ_ROOM.tuoguan_ing = 0
    --查大叫处理
    local time=0
    if pack.chadajiaoSize>0 or pack.chahuazhuSize>0 then
        SCENENOW['scene']:ShowChaEnd(pack.chadajiaoSize>0,pack.chahuazhuSize>0)
        time=2
    end
    SCENENOW['scene']:performWithDelay(function ( ... )
        local roundEnd=require(TpackageName ..".RoundEndingLayer").new(pack)
        roundEnd:setName("roundEnd")
        roundEnd:addTo(SCENENOW['scene'],999)
    end,time)


    --显示剩余的牌
	for k,player in pairs(pack.players) do
		local playerType = cardUtils:getPlayerType(player.seat_id)
		local huCard = 0
		if player.hucontent then
			local hucontent = player.hucontent[1]
			local hutype = hucontent.hutype
			if hutype == 1 then 
				huCard = hucontent.pinghu[1].huCard
			else
				huCard = hucontent.zimo[1].huCard
			end
		end
		GamePlaneOperator:showCardsForHu(playerType, player.remainCards, huCard)
	end
end
-------------------------------------------------------------------------------------------------------------------

--组局相关
--请求获取筹码返回
function XLCHMJReceiveHandle:SVR_GET_CHIP(pack)
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
		--todo
		require("majiang.gameScene"):onNetGetChip(pack)
	end
end

--请求兑换筹码返回
function XLCHMJReceiveHandle:SVR_CHANGE_CHIP(pack)

	--dump(pack, "-----请求兑换筹码返回------")
	-- if bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() == "group" then

		require("majiang.gameScene"):onChipSuccess(pack)
	end
end

--组局时长
function XLCHMJReceiveHandle:SVR_GROUP_TIME(pack)
	dump(pack, "-----组局时长-----")

	--  加入当前游戏模式是组局 if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
    	--记录当前局数
		XLCHMJ_ROUND = pack.round
		--记录总局数
		XLCHMJ_TOTAL_ROUNDS = pack.round_total
    end

    if XLCHMJ_TOTAL_ROUNDS == 0 then
        SCENENOW['scene']:hideInviteCode()
    end
    
    --GamePlaneOperator:showRemainCardsCount()


    --add by XLCHy 2019-7-17 游戏没有开始屏蔽解散房间
	SCENENOW["scene"].GameRound = pack.round
	SCENENOW["scene"]:showCopyInviteBtn(true)
end

--组局排行榜（一局结算之后返回的数据）    正常情况下解散才走这边  0x5100
function XLCHMJReceiveHandle:SVR_GROUP_BILLBOARD(pack)
	dump(pack,"----5100 ----")
    is_End = true
    if pack then
        local disaband_flag = false
        if  XLCHMJ_ROUND <=1  then
             disaband_flag =true
        end
    	XLCHMJ_GROUP_ENDING_DATA = pack
		--if not XLCHMJ_ENDING_DATA then--没有单局结算的话
		--	if XLCHMJ_GROUP_ENDING_DATA then --总结算
		--		dump("-----333")
		--		dump(XLCHMJ_GROUP_ENDING_DATA, "--XLCHMJ_GROUP_ENDING_DATA")
		--		require(TpackageName ..".GroupEndingLayer"):showGroupResult(XLCHMJ_GROUP_ENDING_DATA)
		--	end
		--end
    end
end

--组局历史记录
function XLCHMJReceiveHandle:SVR_GET_HISTORY(pack)

	--dump(pack, "-----组局历史记录-----")

    if pack then
        -- if bm.isGroup then
    	if require("hall.gameSettings"):getGameMode() == "group" then
            require("majiang.gameScene"):onNetHistory(pack)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------

--组局解散相关
--没有此房间，解散房间失败
function XLCHMJReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

	--dump("", "没有此房间，解散房间失败")

	require("hall.GameTips"):showTips("解散房间失败","disbandGroup_fail",2)
end

--广播桌子用户请求解散组局
function XLCHMJReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

	--dump("", "广播桌子用户请求解散组局")

	-- require("hall.GameTips"):showTips("确认解散房间","cs_request_disbandGroup",1)
end

--广播桌子用户成功解散组局 103a
function XLCHMJReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)
	dump(pack, "广播桌子用户成功解散组局")
	-- require("hall.GameTips"):showTips("解散房间成功","cs_disbandGroup_success",3)
    SCENENOW["scene"]:showBtnByUserStatus(false)
	if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
	end
	--if not XLCHMJ_ENDING_DATA then--没有单局结算的话
		if XLCHMJ_GROUP_ENDING_DATA then --总结算
			dump("-----333")
			require(TpackageName ..".GroupEndingLayer"):showGroupResult(XLCHMJ_GROUP_ENDING_DATA)
		else
			dump("----444")
			--require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
		end
	--end

end

--广播桌子用户解散组局 ，解散组局失败
function XLCHMJReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

	--dump("", "广播桌子用户解散组局 ，解散组局失败")
	if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
	end
	require("hall.GameTips"):showTips("解散房间失败", "disbandGroup_fail", 2, "用户拒绝解散房间")
end

--广播当前组局解散情况
function XLCHMJReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

	--dump(pack, "-----广播当前组局解散情况-----")
	--dump(bm.Room, "-----广播当前房间情况-----")

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
		-- showMsg = "您申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
	else
        local player_table = {}
		local seatId = XLCHMJ_SEAT_TABLE[applyId ]
		if seatId then
			--todo
			local userInfo = XLCHMJ_USERINFO_TABLE[seatId ]

			if userInfo then
				--todo
				local nickName = userInfo.nick

                player_table["playerName"] = nickName
                player_table["state"] = "申请"
                table.insert(disband_table, player_table)

				-- showMsg = "玩家【" .. nickName .. "】申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
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

		-- if isMyAgree == 1 then
		-- 	showMsg = showMsg .. "  【我】已同意" .. "\n"
		-- else
		-- 	showMsg = showMsg .. "  【我】等待选择" .. "\n"
		-- end

	end

	--显示其他人情况
		if XLCHMJ_USERINFO_TABLE then
			for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
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

						-- if isAgree == 1 then
						-- 	showMsg = showMsg .. "  【" .. nickName .. "】已同意" .. "\n"
						-- else
						-- 	showMsg = showMsg .. "  【" .. nickName .. "】等待选择" .. "\n"
						-- end

					end

				end
			end
		end


	local function agree_disband(value)
		sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(value)
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

	--if applyId == USER_INFO["uid"] then
	--	--假如申请者是自己，则直接显示其他用户的选择情况
	--	require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
	--else
	--	--申请者不是自己，根据自己的同意情况进行界面显示
	--	if isMyAgree == 1 then
	--		require("hall.GameTips"):showDisbandNewTips("提示", "agree_disbandGroup", 4, disband_table)
	--	else
	--		require("hall.GameTips"):showDisbandNewTips("提示", "XLCHMJ_request_disbandGroup", 1, disband_table)
	--	end
	--end
end

---------------------------------------------------------------------------------------------------------------
--聊天相关
--收到聊天消息
function XLCHMJReceiveHandle:CHAT_MSG( pack )
	--dump(pack, "================CHAT_MSG========================")
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
        font = "res/res/fonts/fzcy.ttf",
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
function XLCHMJReceiveHandle:s2c_JOIN_MATCH_RETURN(pack)
	--print("===recieve====0x211====================")
	--dump(pack)
	--print("UID------------------",UID)
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

function XLCHMJReceiveHandle:s2c_JOIN_MATCH_FAIL(pack)
	--print("0x7109==========return==========")
	--dump(pack)
	USER_INFO["match_fee"] = 0
    require("majiang.MatchSetting"):setJoinMatch(false)
end

function XLCHMJReceiveHandle:s2c_JOIN_MATCH_SUCCESS(pack)
	--print("0x7101==========return==========")
	--dump(pack)

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

function XLCHMJReceiveHandle:s2c_OTHER_PEOPLE_JOINT_IN(pack)
	--print("0x7103==========return==========")
	--dump(pack)
	require("majiang.MatchSetting"):setJoinMatch(true)
	require("majiang.MatchSetting"):joinMatch(pack.Usercount,pack.Totalcount)
end

function XLCHMJReceiveHandle:s2c_QUIT_MATCH_RETURN(pack)
	--print(" 0x7110==========return==========")
	--dump(pack)
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

function XLCHMJReceiveHandle:s2c_GAME_BEGIN_LOGIC(pack)
	--print("0x7104==========return==========")
	--dump(pack)

	bm.User={}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.gold or pack.Matchpoint
	bm.User.Pque      = nil

	XLCHMJ_ROOM={}
	XLCHMJ_ROOM.User      = {}
    XLCHMJ_ROOM.UserInfo  = {}
    XLCHMJ_ROOM.seat_uid  = {}
	XLCHMJ_ROOM.Card      = {}
	XLCHMJ_ROOM.Gang      = {}
	XLCHMJ_ROOM.base      = pack.base

	XLCHMJ_ROOM.tuoguan_ing = 0

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
			XLCHMJReceiveHandle:showPlayer(v)
		end
	end

	--绘制其他内容
	scenes:set_basescole_txt(XLCHMJ_ROOM.base)

	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"]=XLCHMJ_ROOM.base;
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

function XLCHMJReceiveHandle:s2c_PAI_MING_MSG(pack)
	--print("0x7114==========return==========")
	--dump(pack)
end

function XLCHMJReceiveHandle:s2c_SVR_MATCH_WAIT(pack)
	--print("0x7113==========return==========")
	--dump(pack)
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

function XLCHMJReceiveHandle:s2c_GAME_STATE_MSG(pack)
	--print("0x7106==========return==========")
	--dump(pack)
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

function XLCHMJReceiveHandle:s2c_SVR_REGET_MATCH_ROOM(pack)

	----dump(pack)
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
---------------------------------------------------------------------------------------------------------------
function XLCHMJReceiveHandle:remaidIP()
    local myIp = ""

    if XLCHMJ_MY_USERINFO.seat_id and XLCHMJ_USERINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ] then
        --todo
        myIp = XLCHMJ_USERINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ].ip
    end


    local ipTable = {}

    for k,v in pairs(XLCHMJ_USERINFO_TABLE) do
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

--获取当前坐下的玩家数量
function XLCHMJReceiveHandle:getOnSeatCount()

    local XLCH_PLAYER_COUNT = 0
    local audienceNum = 0

    for uid, seat_id in pairs(XLCHMJ_SEAT_TABLE) do
        if  seat_id >= 0 then
            XLCH_PLAYER_COUNT = XLCH_PLAYER_COUNT + 1
        else
            audienceNum = audienceNum + 1
        end
    end

    return XLCH_PLAYER_COUNT, audienceNum

end

--广播用户坐下 1031   其他用户进入房间
function  XLCHMJReceiveHandle:BROADCAST_USER_SIT_DOWN(pack)
    dump(pack, "1031_BROADCAST_USER_SIT_DOWN")


	if  USER_INFO["uid"] == pack.uid then
		--重定位逻辑
		MY_SEAT_ID = pack.seat_id
		XLCHMJ_MY_USERINFO.seat_id = MY_SEAT_ID
	end
	self:collectPlayerData(pack)
    if  USER_INFO["uid"] == pack.uid then
        --重定位逻辑
        --游戏过程中加入不会重定位
        if  XLCHMJ_GAME_STATUS == 0 then
            RELATIVE_SEAT_ID = MY_SEAT_ID
            dump(RELATIVE_SEAT_ID, "RELATIVE_SEAT_ID -- 1031")
            self:relocatePlayer()
            --self:collectPlayerData(pack)
        end
        SCENENOW['scene']:showCopyInviteBtn(true)
	else
		dump("")
		XLCHMJ_USERINFO_TABLE[pack.seat_id ].is_online = 1
		XLCHMJ_PLAYERS_INFOS[pack.uid].is_online = 1
		XLCHMJ_PLAYERS_INFOS[pack.uid].nick = pack.nick
		XLCHMJ_PLAYERS_INFOS[pack.uid].photoUrl = pack.photoUrl
		XLCHMJ_PLAYERS_INFOS[pack.uid].latitude = pack.latitude
		XLCHMJ_PLAYERS_INFOS[pack.uid].longitude = pack.longitude
		XLCHMJ_PLAYERS_INFOS[pack.uid].otherInfoJson = pack.otherInfoJson
		XLCHMJ_PLAYERS_INFOS[pack.uid].ip = pack.ip
		XLCHMJ_PLAYERS_INFOS[pack.uid].if_ready = pack.if_ready
		XLCHMJ_PLAYERS_INFOS[pack.uid].coins = pack.coins
		XLCHMJ_PLAYERS_INFOS[pack.uid].seat_id = pack.seat_id
		self:showPlayer(XLCHMJ_PLAYERS_INFOS[pack.uid])
    end

    if MY_SEAT_ID < 0 and OnSeatCount == XLCH_PLAYER_COUNT  then
        -- 隐藏坐下按钮，相当于准备状态
        SCENENOW['scene']:showBtnByUserStatus("ready")
    end

    --gps显示
    SCENENOW['scene']:showGPSButton()
end

--广播玩家站起 1032
function XLCHMJReceiveHandle:BROADCAST_USER_STAND_UP(pack)
    dump(pack, "------广播玩家站起1032------")
    local uid = pack.uid

    local seat_id = XLCHMJ_SEAT_TABLE[uid ]
    local playerType = cardUtils:getPlayerType(seat_id)
    if  playerType and not is_End then
        -- true表示不清出牌界面
        GamePlaneOperator:removePlayer(playerType, true)

        -- 将准备文本清空
        GamePlaneOperator:setReadyStatus(playerType, false)

        if isGoldGame == 0 then
            if pack.uid == USER_INFO["uid"] then
                XLCHMJ_MY_USERINFO.seat_id = -1
                SCENENOW['scene']:showBtnByUserStatus("stand")
                MY_SEAT_ID = -1
                XLCHMJ_MY_USERINFO.seat_id = MY_SEAT_ID
                if XLCHMJ_GAME_STATUS == 0 then
                    RELATIVE_SEAT_ID = 0
                    self:relocatePlayer()
                end
            elseif  MY_SEAT_ID < 0 and OnSeatCount < XLCH_PLAYER_COUNT then
                SCENENOW['scene']:showBtnByUserStatus("stand")
            end
        end

        if not is_End then
            XLCHMJ_SEAT_TABLE_BY_TYPE[playerType ] = nil
            XLCHMJ_SEAT_TABLE[pack.uid] = nil
            require("hall.view.userInfoView.userInfoView"):upDateUserInfo(uid, {}, "reset")
        end
    end
    -- 在座玩家信息表
    if not is_End then
        XLCHMJ_USERINFO_TABLE[seat_id] = nil
    end

    SCENENOW['scene']:showGPSButton()  
end

--广播玩家退出返回（离开房间） 1033
function XLCHMJReceiveHandle:BROADCAST_USER_QUIT_ROOM(pack)

    dump(pack, "------广播玩家退出返回1033------")
    dump(XLCHMJ_SEAT_TABLE, "----xx-----")
    local seat_id = XLCHMJ_SEAT_TABLE[pack.uid]

    -- if seat_id and seat_id >= 0 then
    --     local playerType = cardUtils:getPlayerType(seat_id)
    --     -- 最后一把，先不清界面，等待摊牌操作完成
    --     if  playerType and not is_End then
    --         GamePlaneOperator:removePlayer(playerType)
    --     end
    --     if not is_End then
    --         XLCHMJ_USERINFO_TABLE[seat_id ] = nil
    --         XLCHMJ_SEAT_TABLE_BY_TYPE[playerType ] = nil
    --     end
    -- end

    if not is_End then
        XLCHMJ_PLAYERS_INFOS[pack.uid ] = nil
        -- XLCHMJ_SEAT_TABLE[pack.uid] = nil
    end
    --[[    local dict = {}
        dict.uid = pack.uid
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(pack.uid, {}, "reset")]]

    if  pack.uid == USER_INFO["uid"] and not is_End and not XLCHMJ_GROUP_ENDING_DATA then
        HEART_BEAT_TID = 0
        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"],CLUB_ID)
    end

end

--重新显示游戏桌面（坐下之后）
function XLCHMJReceiveHandle:relocatePlayer()
    dump(XLCHMJ_SEAT_TABLE, "-------- XLCHMJ_SEAT_TABLE:")
    GamePlaneOperator:reSetPlayerPlane()
    for uid, seat_id in pairs(XLCHMJ_SEAT_TABLE) do
		dump(seat_id,"seat_id-relocatePlayer")
        if seat_id >= 0 then
            local userInfo =  XLCHMJ_PLAYERS_INFOS[uid]
            if userInfo then
                self:showPlayer(userInfo)
            end
        end
    end
end

function XLCHMJReceiveHandle:BROADCAST_CHANGE_COINS(pack)
    dump(pack, "--- 4800 扣台费 -----")
    local myChangeCoins = 0
    for _, v in pairs(pack.changeCoinsInfo) do
        local uid = v.uid
        local seat_id = XLCHMJ_SEAT_TABLE[uid ]
        local coins = XLCHMJ_USERINFO_TABLE[seat_id ].coins
        local new_coins = coins + v.changeChip
        XLCHMJ_USERINFO_TABLE[seat_id ].coins = new_coins
        XLCHMJ_PLAYERS_INFOS[uid ].coins = new_coins

        local playerType = cardUtils:getPlayerType(seat_id)
        GamePlaneOperator:updateUserCoins(playerType, new_coins)

        local dict = {}
        dict.uid = uid
        dict.gold = XLCHMJ_USERINFO_TABLE[seat_id ].coins
        dump(dict, "------------ showPlayer  upDateUserInfo ---------")
        require("hall.view.userInfoView.userInfoView"):upDateUserInfo(dict.uid, dict, "gold")

        if uid == USER_INFO["uid"] then
            myChangeCoins = v.changeChip
        end
    end

    -- 展示扣台费文本
    GamePlaneOperator:showTaiFeiTxt(myChangeCoins)
end


function XLCHMJReceiveHandle:SVR_TEST_CARD(pack)

    if SCENENOW["name"] ~= run_scene_name then
        return
    end
	local text = "成功"
    if pack.res == 1 then
        -- require("hall.GameTips"):showTips("提示", "", 3, "成功")
    else
		-- require("hall.GameTips"):showTips("提示", "", 3, "失败")
		text = "失败"
	end
	viewMgr:showTip({text = text})
end

function XLCHMJReceiveHandle:SVR_REQ_TEST_CARDS(pack)
    dump(pack, "---- SVR_REQ_TEST_CARDS ------")
    local scenes  = SCENENOW['scene']

    if SCENENOW["name"] ~= run_scene_name then
        return
    end

    if pack.cardCount > 0 then

        local ConfigPanel = SCENENOW["scene"]:getChildByName("ConfigPanel")
        if ConfigPanel then
            ConfigPanel:removeSelf()
        end

        local cardDict = {}
        for i,v in ipairs(pack.cards) do
            cardDict[v] = 1
        end

        local ableCards = {}
        for i,v in pairs(cardDict) do
            table.insert(ableCards, i)
        end

        local function CLI_SEND_TEST_CARD_FUNC(card)
            local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_TEST_CARD)
            :setParameter("card", card)
            :build()
            bm.server:send(pack)
        end

	local maPath = TpackageName .. "/2DMahjongCard/res/newImage/down_holds/"
	require("hall.scene.verify.testConfig"):chooseCard(ableCards, maPath, CLI_SEND_TEST_CARD_FUNC, "快乐麻将")
    end
end

--接收服务器放回的指定用户信息pack111
function XLCHMJReceiveHandle:SVR_CHARGE_BROADCAST(pack)
    dump(pack,"pack111")
   
    local uid = pack.uid	
	local seatId = XLCHMJ_SEAT_TABLE[uid ]
    if not (seatId) then return end
	local playerType = cardUtils:getPlayerType(seatId)
	
    local userInfo = XLCHMJ_PLAYERS_INFOS[uid ]
    userInfo.coins = userInfo.coins + pack.chargeCoins
	GamePlaneOperator:updateUserCoins(playerType, userInfo.coins)
	
end

--托管相关
--广播用户托管
function XLCHMJReceiveHandle:SVR_ROBOT(pack)
	dump(pack,"-----广播用户托管-----")
	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	if pack.uid == USER_INFO["uid"] then
        BAO_JIAO_FIRST_OUT_CARD = false
		local scenes  = SCENENOW['scene']
		if  pack.m_bAI == 1 then
			scenes:TgState(true)
			XLCHMJ_ROOM.tuoguan_ing = 1

            --托管的时候 操作按钮都隐藏
            GamePlaneOperator:hideControlPlane()
		else
			scenes:TgState(false)
			XLCHMJ_ROOM.tuoguan_ing = 0
		end
	end

    local seatId = XLCHMJ_SEAT_TABLE[pack.uid]
    local playerType = cardUtils:getPlayerType(seatId)
    GamePlaneOperator:showTuoGuanState(playerType,pack.m_bAI == 1)

end

--接收服务器放回的指定用户信息pack111
function XLCHMJReceiveHandle:SVR_BROADCAST_BAO_JIAO_RESULT(pack)
    dump(pack,"SVR_BROADCAST_BAO_JIAO_RESULT")
    dump(D3_CHUPAI,"D3_CHUPAI---")

    if pack then
        if pack.result >= 1 then
            local seatId = XLCHMJ_SEAT_TABLE[pack.userid]
            XLCHMJ_USERINFO_TABLE[seatId].m_tianTing = 1
            local playerType = cardUtils:getPlayerType(seatId)
          
            if pack.userid == USER_INFO["uid"] then
                GamePlaneOperator:setDianNodeBytingpaiTianTing()
            end

            --播放音效
            voiceUtils:playControlSound(seatId, CONTROL_TYPE_BAOJIAO)

            GamePlaneOperator:showImgAnim(playerType,800)  --天听的效果
        end
    end
end

--通知可以出牌

function XLCHMJReceiveHandle:SVR_OUT_CARD(pack)
    dump(pack,"SVR_OUT_CARD")
    if pack then
       D3_CHUPAI = 1

       --不是托管状态下 需要这样
       if XLCHMJ_ROOM.tuoguan_ing == 0 then
            BAO_JIAO_FIRST_OUT_CARD = true
       end
    end
end






function XLCHMJReceiveHandle:SVR_HUAN_PAI()
    IS_HUANPAI_STATE=true
    SCENENOW['scene']:ShowHuanPai()
end

function XLCHMJReceiveHandle:SVR_HUAN_PAI_REUSLT(pack)
    dump(pack,"SVR_HUAN_PAI_REUSLT")
    SCENENOW['scene']:ShowChangeCard(pack.ChangeCardbuf,pack.ChangeType)
    XLCHMJReceiveHandle:ShuaXinHandCard(pack)
   SCENENOW['scene']:performWithDelay(function()
        SCENENOW['scene']:RemoveChangeCard()
       
   end,2) 
   
end

--刷新手牌
function XLCHMJReceiveHandle:ShuaXinHandCard(pack)
  -- GXLZMJReceiveHandle:initCardForUser(pack)
  dump(pack,"ShuaXinHandCard")
  dump("---------5555--")
    local myCards = pack.HandCardbuf

    table.sort(myCards)

    XLCHMJ_GAMEINFO_TABLE[XLCHMJ_MY_USERINFO.seat_id ].hand = myCards   --0号玩家的手牌
    
    XLCHMJReceiveHandle:showPlayerCards(MY_SEAT_ID)
    GamePlaneOperator:setDianNodeBytingpai()
    
end

function XLCHMJReceiveHandle:SVR_CHOICE_QUE()
    SCENENOW['scene']:ShowDingQue()
end

--显示玩家头像上的定缺图标
function XLCHMJReceiveHandle:SVR_QUE_REUSLT(pack )  
    IS_HUANPAI_STATE=false

    XLCHMJ_SCENE:getChildByName("NodeDingQue"):setVisible(false)
    for i,v in ipairs(pack.Dingque) do
        local seatId = XLCHMJ_SEAT_TABLE[v.Uid]
        local playerType=cardUtils:getPlayerType(seatId)
        GamePlaneOperator:showQueImg(v.que,playerType)
        if v.Uid==USER_INFO.uid then
            UserDingQueHuaSe=v.que
        end
    end
    XLCHMJReceiveHandle:showPlayerCards(MY_SEAT_ID)--手中的定缺牌变色
end

function XLCHMJReceiveHandle:SVR__UPDATE_SCORE(pack)
    --设置流水面板
    dump(pack,"SVR__UPDATE_SCORE")
    SCENENOW['scene']:SetLiuShuiForHu(pack)
    --更新玩家筹码
    for i,v in ipairs(pack.players) do
        local seatId = XLCHMJ_SEAT_TABLE[v.Uid]
        local playerType=cardUtils:getPlayerType(seatId)
        GamePlaneOperator:updateUserCoins(playerType,v.chips) 
    end
    --播放分数改变
    SCENENOW['scene']:showChangScore(pack)
end 


function XLCHMJReceiveHandle:SVR_UPDATE_GANGSCORE(pack )
    dump(pack,"SVR_UPDATE_GANGSCORE")
        --设置流水面板
    SCENENOW['scene']:SetLiuShuiForGang(pack)
          --更新玩家筹码
    for i,v in ipairs(pack.players) do
        local seatId = XLCHMJ_SEAT_TABLE[v.Uid]
        local playerType=cardUtils:getPlayerType(seatId)
        GamePlaneOperator:updateUserCoins(playerType,v.chips) 
    
    end  

      --播放分数改变
    SCENENOW['scene']:showChangScore(pack)
end

return XLCHMJReceiveHandle
