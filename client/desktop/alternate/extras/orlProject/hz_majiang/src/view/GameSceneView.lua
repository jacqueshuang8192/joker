local SendHandle = require("hz_majiang.src.handle.SendHandle")
-- local TestView = require("hz_majiang.src.view.TestView")
local TingView = require("hz_majiang.src.view.TingView")
local OprorateBtn = require("hz_majiang.src.view.OprorateBtn")
local TableCardView = require("hz_majiang.src.view.TableCardView")
local faceUI = require("hall.FaceUI.faceUI")
local PokerCard = require("hz_majiang.src.PokerCard")
local SoundUtils = require("hz_majiang.src.SoundUtils")
local GameConfig = require("hz_majiang.src.GameConfig")
local GPSShowLayer = require("hall.GPSShowLayer")
local UserInfoView = require("hz_majiang.src.view.UserInfoView")
local GameSceneView = class("GameSceneView", function()
    return cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath().."hz_majiang/res/GameScene/GameScene.csb")
end)

function GameSceneView:ctor()
    self:setNodeEventEnabled(true)
    self:initUI()
    self:initEvent()
    require("hall.util.GameMenu"):getDeviceInfo(self.hall.device_info_plane)
    self:setRoomId("000000")
    self:setRound(0, 0)

    self.faceUI = faceUI.new()
    self.faceUI:setHandle(SendHandle)
    self:addChild(self.faceUI, 9999)
    self.faceUI:setName("faceUI")
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
    self.TableCardView = TableCardView.new(self.cards_vw)
    self.TingView = TingView.new(self.ting_vw)
    self.OprorateBtn = OprorateBtn.new(self.hall)
end

function GameSceneView:initUI()
    GameUtils.setNodeNameBindObj(self)
    -- display.doLayout(self)
    self.zhama_vw:hide()
    self.take_bg:hide()
    -- self.hall:hide()
    self.btn_chat = self.hall.btn_chat
    self.txt_round = self.hall.device_info_plane.txt_round
    self.wifi_level = self.hall.device_info_plane.wifi_level:setScale(0.8)
    self.txt_remain = self.hall.device_info_plane.txt_remain:setString("剩余:0张")
    self.btn_cancelTuoGuan = self.take_bg.btn_cancelTuoGuan
    self.btn_voice = self.hall.btn_voice
    self.btn_menu = self.hall.btn_menu
    self.btn_record = self.hall.btn_record
    self.btn_share = self.hall.btn_share
    self.btn_copyRoom = self.hall.btn_copyRoom
    self.btn_ready = self.hall.btn_ready
    self.btn_gameConfig = self.hall.btn_gameConfig
    self.btn_gps = self.hall.btn_gps:show()
    self.btn_piao1 = self.hall.btn_piao1:hide()
    self.btn_piao2 = self.hall.btn_piao2:hide()
    self.btn_piao0 = self.hall.btn_piao0:hide()
    self.txt_gameConfig = self.hall.txt_gameConfig:setString("")
    self.zhizhenNode = self.cards_vw.zhizhenNode
    -- self.guanZhan_img = self.hall.guanZhan_img:hide()
    -- self.btn_tuoGuan = self.hall.btn_tuoGuan
    self:isShowBtnReady( false )
    self:isShowBtnShare( false )
    self:isShowBtnCopy( false )
    self:isShowGameRound( 0, 0 )
    self.UserInfoViews = {
        [g_308.viewId_my] = UserInfoView.new(self.players.player_1, self.cards_vw.player_1, self),
        [g_308.viewId_top] = UserInfoView.new(self.players.player_2, self.cards_vw.player_2),
        [g_308.viewId_right] = UserInfoView.new(self.players.player_3, self.cards_vw.player_3),
        [g_308.viewId_left] = UserInfoView.new(self.players.player_4, self.cards_vw.player_4)
    }
end

function GameSceneView:initEvent()
    self.btn_chat:onClick(handler(self, self.onClick_chat), true)
    self.btn_menu:onClick(handler(self, self.onClick_menu), true)
    self.btn_voice:onClick(handler(self, self.onClick_voice), true)
    self.btn_share:onClick(handler(self, self.onClick_share), true)
    self.btn_ready:onClick(handler(self, self.onClick_ready), true)
    self.btn_cancelTuoGuan:onClick(handler(self, self.onClick_cancelTuoGuan), true)
    self.btn_gps:onClick(handler(self, self.onClick_gps), true)
    -- self.btn_tuoGuan:onClick(handler(self, self.onClick_tuoGuan), true)
    self.btn_gameConfig:onClick(handler(self, self.onClick_gameConfig), true)
    -- self.btn_record:onClick(handler(self, self.onClick_record), true)

    require("hall.util.GameMenu"):registCopyRoomIdFunc(self.btn_copyRoom, self.roomId)
end

function GameSceneView:clearData()
    -- self:isShowTuoGuan( false )
    self:isShowBtnReady( false )
    self:isShowBtnCopy( false )
    self:isShowBtnShare( false )
    for i,UserInfoView in ipairs(self.UserInfoViews) do
        UserInfoView:clearData()
    end
    self:isShowGameRound( 0, 10 )
    self:setRemainCount(0)
    self.TableCardView:clearData()
end

function GameSceneView:hideAllPlayerLight()
    for i,UserInfoView in ipairs(self.UserInfoViews) do
        UserInfoView:isShowLight(false)
    end
end

--指针
function GameSceneView:setZhiZhenAnim(viewId)
	local type = "up"
	if viewId == g_308.viewId_my then
		type = "down"
	elseif viewId == g_308.viewId_left then
		type = "left"
	elseif viewId == g_308.viewId_right then
		type = "right"
	elseif viewId == g_308.viewId_top then
		type = "up"
	end
    self.zhizhenNode:setVisible(true)
	local anim = self.zhizhenNode.zhizhenAnin:getAnimation()
	anim:playWithNames({type}, 0, true);
end

function GameSceneView:isShowBtnReady( isShow )
    self.btn_ready:setVisible(isShow and g_isWatch == 1)
end

function GameSceneView:isShowGuanZhan( isShow )
    self.guanZhan_img:setVisible(isShow)
end

function GameSceneView:isShowTuoGuan( isShow )
    self.take_bg:setVisible(isShow)
end


function GameSceneView:isShowBtnShare( isShow )
    self.btn_share:setVisible(isShow and g_isWatch == 1)
end

function GameSceneView:isShowBtnCopy( isShow )
    if isShow == false then
        dump()
    end
    self.btn_copyRoom:setVisible(isShow and g_isWatch == 1)
end

function GameSceneView:isShowXiaZhu( isShow, string )
    self.bg_chips:setVisible(isShow)--总下注
    if string then
        string = string / 100
        self.bg_chips.txt_chips:setString("总下注:"..string)--总下注
    end
end

function GameSceneView:isShowGameRound( now_turns, all_turns )
    if now_turns > all_turns then
        return
    end
    g_308.now_turns = now_turns
    g_308.all_turns = all_turns
    self.txt_round:setString("轮数:"..now_turns.."/"..all_turns)
end

function GameSceneView:setRemainCount(count)
    self.txt_remain:setString("剩余:"..count.."张")
end

function GameSceneView:onClick_record( )
    local game_round = 1
    if self.round and self.round > 2 then
        game_round = self.round
    end
    SendHandle:CLI_COMMAND_GAMERESULT_RECORD(game_round)
end

function GameSceneView:onClick_gameConfig(event)
    if isOpenControl then
        local TestView = TestView.new()
        local size = self:getContentSize()
        TestView:setAnchorPoint(0.5, 0.5)
        TestView:setPosition(size.width / 2, size.height / 2)
        TestView:addTo(self)
    else
        require("hall.util.GameMenu"):showConfigPanel(g_308.gameConfigTable, 250)
    end
end

function GameSceneView:onClick_chat(event)
    if g_isWatch == 0 then--观战
        return
    end
    self:loadGameMsgLayer()
end

function GameSceneView:onClick_menu(event)
    self:loadMoreFuncLayer()
end

function GameSceneView:onClick_voice(event)
    if g_isWatch == 0 then--观战
        return
    end
    local voice_bt_worldpoint = (self.btn_voice:getParent()):convertToWorldSpace(self.btn_voice:getPosition())
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(self.btn_voice,999)
    else
        self.btn_voice:setVisible(false)
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end
end

function GameSceneView:onClick_share(event)
    local paras = {}
    paras.desc =  USER_INFO.gameConfigMsg or " "
    paras.imagePath = "url"
    paras.name =  g_308.GameName.."房号：" .. self.roomId
    paras.showType = 2;
    paras.url = appDownLoadAddress
    local shareLayer = require("hall.share.ShareLayer").new(paras)
    if shareLayer then
        shareLayer:addTo(SCENENOW.scene, 9999999)
    end
end

function GameSceneView:onClick_ready(event)
    SendHandle:CLI_READYNOW_ROOM()
    self:clearData()
end

function GameSceneView:onClick_start(event)
end

function GameSceneView:onClick_cancelTuoGuan(event)
    -- SendHandle:CLI_PLAYER_CANCELAUTO(0)
end

function GameSceneView:onClick_tuoGuan(event)--点击托管
    -- SendHandle:CLI_PLAYER_CANCELAUTO(1)
end

function GameSceneView:showGPSButton()
    local temptab = {}
    for k,v in pairs(g_308.userInfos) do
        table.insert(temptab,v)
    end
    local isWarning = 0
    for i=1,#temptab do
        for j=i+1,#temptab do
            if temptab[i].latitude and temptab[j].latitude and temptab[i].longitude and temptab[j].longitude and calculateDistance(temptab[i].latitude, temptab[j].latitude, temptab[i].longitude,temptab[j].longitude) <= 100 then
                isWarning = isWarning + 1
                break
            end
        end
    end
    if isWarning > 0 then
        self.btn_gps.img_safe:setVisible(false)
        self.btn_gps.img_warnning:setVisible(true)
    else
        self.btn_gps.img_safe:setVisible(true)
        self.btn_gps.img_warnning:setVisible(false)
    end
    self.btn_gps:setVisible(true)
end

function GameSceneView:onClick_gps(event)
    local gpsLayer = GPSShowLayer.new()
    self:addChild(gpsLayer,1000)
    local temptab = {}
    for k,v in pairs(g_308.userInfos) do
        table.insert(temptab,v)
    end
    gpsLayer:setInfo(temptab)
end

function GameSceneView:setRoomId( roomId )
    self.roomId = roomId
    self.hall.device_info_plane.txt_room:setString("房间号:"..roomId)
end

function GameSceneView:setRound( round, totalRound )
    self.round = round
    self.totalRound = totalRound
    self.hall.device_info_plane.txt_round:setString(round.."/"..totalRound)
    local isShow = round <= 0
    self:isShowBtnCopy(isShow)
    self:isShowBtnShare(isShow)
end

function GameSceneView:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer)
    else
        self.gameMsgLayer:showContentByType(1)
    end
    self.gameMsgLayer:setVisible(true)
end

function GameSceneView:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function GameSceneView:loadMoreFuncLayer()
   
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer, 99999)
        local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandRoom)
        self.moreFuncLayer:registerDisbandFuncs(data)
    else
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end

    if g_308.gameConfig.dis_agree == 3 or g_isWatch == 0 then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    end
end

function GameSceneView:sendFaceByIdx(id, msgType, to_uid)
    SendHandle:CLI_MSG_FACE(id, msgType, to_uid)
end

function GameSceneView:disbandRoom()
    SendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function GameSceneView:rejectDisband()
    SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function GameSceneView:agreeDisband()
    SendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function GameSceneView:quitRoom()
    SendHandle:CLI_QUIT_ROOM()
end

function GameSceneView:setZiPaiTest( pokers )
    if not tolua.isnull(self.ZiPaiTest) then
        self.ZiPaiTest:removeSelf()
    end
    self.ZiPaiTest = ZiPaiTest.new(pokers):addTo(self)
    local size = self:getContentSize()
    self.ZiPaiTest:setAnchorPoint(0.5, 0.5)
    self.ZiPaiTest:setPosition(size.width / 2, size.height / 2)
end

function GameSceneView:getPlayerBySeatId( seatId, viewId )
    if not viewId then
        viewId = g_308.viewIds[seatId] or 0 
    end
    return self.UserInfoViews[viewId]
end

function GameSceneView:showGameConfig(gameConfigtbl)
    local gameConfigStr = gameConfigtbl.name.." "
    local gameConfigStr = ""
    local maxSeatCount = gameConfigtbl.maxSeatCount
    for key, val in pairs(gameConfigtbl) do
        if GameConfig[key] then
            local vals = string.split(val,",")
            gameConfigStr = gameConfigStr..GameConfig[key].name..":"
            for _, va in ipairs(vals) do
                if GameConfig[key][va] then
                    gameConfigStr = gameConfigStr..GameConfig[key][va]
                end
            end
        end
        if key == "tgTime" then
            g_308.aiTime = val == 0 and 60 or val
        end
    end

    local baseChip = gameConfigtbl.baseChip
	g_308.gameConfigTable = {
        {
            ["游戏名"] = gameConfigtbl.name, 
            ["底分"] = baseChip,
        }, 
        {["config"] = gameConfigStr},
    }
    USER_INFO.gameConfig = "玩法: "..gameConfigStr
    .." 底分 "..baseChip
    print(USER_INFO.gameConfig)
end

function GameSceneView:update( dt )
    if self.timing and #self.timing >= 1 then
        for idx, timing in ipairs(self.timing) do
            timing.time = timing.time - dt
            self.timing[idx].time = timing.time
            if timing.time <= 0 then
                timing.func()
                table.remove(self.timing, idx)
            end
        end
    end
    -- self:updateStartTimer(dt)
end

function GameSceneView:updateStartTimer(dt)
    if self.bg_clock.outTime then
        self.bg_clock.outTime = self.bg_clock.outTime - dt
        local outTime = math.ceil(self.bg_clock.outTime) or 0
        self.bg_clock.txt_time:setString(outTime)
        if outTime <= 0 then
            self.bg_clock:hide()
            self.bg_clock.outTime = nil
        end
    end
end

function GameSceneView:showStartTimer(time)
    if time > 0 then
        self.bg_clock:show()
    else
        self.bg_clock:hide()
    end
    self.bg_clock.outTime = time
end

function GameSceneView:setTimingFun( func, time )
    if not self.timing then
        self.timing = {}
    end
    table.insert(self.timing, {func = func, time = time})
end

function GameSceneView:settlement(pack)
	local scenes = SCENENOW.scene
	--去掉提示弹框
	local layer_tips = SCENENOW.scene:getChildByName("layer_tips")
	if layer_tips then
		layer_tips:removeSelf()
	end
	local data = {}
	data.resultSceneType = 2      --战绩界面展示选择，1为长条形，2为方块形
	data.invote_code = USER_INFO.invote_code      --房间号
	data.fenchang = BASE_CHIP            --分场
	data.round = pack.game_amount --.."/"..GROUP_TOTAL_ROUND                  --局数
	data.date = os.date("%Y-%m-%d-%H:%M")    --日期和时间，用这个方法去生成os.date("%Y-%m-%d-%H:%M", 时间戳)
	data['activity_id'] = USER_INFO.activity_id;
	data.resultData = {}

    for uid, user_info in pairs(pack.playerlist) do
        local uid = user_info.uid 
		local user_result = {}             --玩家数据实体
		user_result.uid = uid        --uid
        user_result.nick = g_308.userInfos[uid].nick        --昵称
        user_result.icon_url = g_308.userInfos[uid].portrait        --头像链接
        user_result.sex = g_308.userInfos[uid].sex               --性别
        user_result.isRoomOwer = g_308.OwnerID == uid and 1 or 0        --是否为房主，1是，非1或不填不是
        
		if user_info.totalChips > 0 then
			user_result.isWinner = 1         --是否为赢家，1是，非1或不填不是
		else
			user_result.isWinner = 0
		end
		user_result.total = user_info.totalChips        --总输赢分

		user_result.gameDetail = {}       --游戏详情数组
		local gameDetail1 = {}           --游戏详情实体
		gameDetail1.showName = "赢的次数"   --展示名
		gameDetail1.value = user_info.win_num or 0         --值

		local gameDetail2 = {}
		gameDetail2.showName = "输的次数"
		gameDetail2.value = user_info.lose_num or 0

		table.insert(user_result.gameDetail, gameDetail1)
		table.insert(user_result.gameDetail, gameDetail2)
		table.insert(data.resultData, user_result)
	end
	--返回大厅按钮点击事件
	local backHall_action = function(sender,event)
        local accountScene = SCENENOW.scene:getChildByName("accountScene")
        if not tolua.isnull(accountScene) then
            accountScene:removeSelf()
        end
        USER_INFO.gameConfig = ""
        require("hall.GameCommon"):gExitGroupGame(USER_INFO.enter_mode, CLUB_ID)
	end

	--分享按钮点击事件
	local share_action = function(sender,event)
        local paras = {}
        paras.showType = 2;
        paras.desc =  USER_INFO.gameConfigMsg or " "
        paras.imagePath = "screen"
        paras.name = "分享结果"
        paras.url = appDownLoadAddress
        local shareLayer = require("hall.share.ShareLayer").new(paras)
        if shareLayer then
            shareLayer:addTo(SCENENOW.scene,9999999)
        end
	end

	--再来一局
	local extend_action = function(sender,event)
		require("hall.groudgamemanager"):extend_freegame(USER_INFO.uid, USER_INFO.activity_id, TpackageName .. ".gameScene")
	end

    require("hall.settlement.settlement").new(data, backHall_action, share_action, nil, extend_action)
end

function GameSceneView:onExit( )
    self:stopAllActions()
end

return GameSceneView
