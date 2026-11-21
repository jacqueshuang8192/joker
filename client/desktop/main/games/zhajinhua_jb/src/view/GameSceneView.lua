local SendHandle = require("zhajinhua_jb.src.handle.SendHandle")
local OprorateBtn = require("zhajinhua_jb.src.view.OprorateBtn")
local PlayersMgr = require("zhajinhua_jb.src.view.PlayersMgr")
local CardMgr = require("zhajinhua_jb.src.view.CardMgr")
local ChatMgr = require("zhajinhua_jb.src.view.ChatMgr")
local TestView = require("zhajinhua_jb.src.view.TestView")
local faceUI = require("hall.FaceUI.faceUI")
local PokerCard = require("zhajinhua_jb.src.PokerCard")
local SoundUtils = require("zhajinhua_jb.src.SoundUtils")
local LayerShuffling = require("zhajinhua_jb.src.view.LayerShuffling")
local GameSceneView = class("GameSceneView", function()
    return cc.CSLoader:createNode("zhajinhua_jb/res/GameScene/GameScene.csb")
end)

function GameSceneView:ctor()
    self.UserInfoViews = {}
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
    self.OprorateBtn = OprorateBtn.new(self)
    self.PlayersMgr = PlayersMgr.new(self.players)
    self.CardMgr = CardMgr.new(self)
    self.ChatMgr = ChatMgr.new(self)
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)
end

function GameSceneView:initUI()
    GameUtils.setNodeNameBindObj(self)
    display.doLayout(self)
    -- local size = self:getContentSize()
    -- self.GameScene:setAnchorPoint(0.5, 0.5)
    -- self.GameScene:setPosition(size.width / 2, size.height / 2)
    -- self.GameScene:addTo(self)

    -- display.doLayout(self.GameScene.hall, self.GameScene.bg)
    -- display.doLayout(self.GameScene.players)
    -- display.doLayout(self.GameScene.players_6)
    -- display.doLayout(self.GameScene.players_8)
    -- display.doLayout(self.GameScene.players_9)
    -- display.doLayout(self.GameScene.players_10)
    -- self.GameScene:setScale(0.666666)
    -- self.bg = self.bg
    -- self.hall = self.hall
    -- self.players = self.players
    -- self.players_6 = self.players_6
    -- self.players_8 = self.players_8
    -- self.players_9 = self.players_9
    -- self.players_10 = self.players_10

    self.compare_vw:hide()
    self.btn_chat = self.hall.btn_chat
    self.txt_game_round = self.hall.device_info_plane.txt_game_round
    self.take_bg = self.take_bg:hide()
    self.btn_cancelTuoGuan = self.take_bg.btn_cancelTuoGuan
    self.btn_voice = self.hall.btn_voice:hide()
    self.btn_menu = self.hall.btn_menu
    self.btn_record = self.hall.btn_record
    self.btn_share = self.hall.btn_share
    self.btn_copyRoom = self.hall.btn_copyRoom
    self.btn_ready = self.hall.btn_ready
    self.btn_gameConfig = self.hall.btn_gameConfig
    self.guanZhan_img = self.hall.guanZhan_img:hide()
    self.bg_chips = self.hall_1.bg_chips:hide()--总下注
    self.bg_clock = self.hall_1.bg_clock:hide()--倒计时
    self.btn_tuoGuan = self.hall.btn_tuoGuan
    self.chips_dui_vw = self.hall_1.chips_dui_vw
    self:isShowBtnReady( false )
    self:isShowBtnShare( false )
    self:isShowBtnCopy( false )
    self:isShowGameRound( 0, 0 )
end

function GameSceneView:initEvent()
    self.btn_chat:onClick(handler(self, self.onClick_chat), true)
    self.btn_menu:onClick(handler(self, self.onClick_menu), true)
    self.btn_voice:onClick(handler(self, self.onClick_voice), true)
    self.btn_share:onClick(handler(self, self.onClick_share), true)
    self.btn_ready:onClick(handler(self, self.onClick_ready), true)
    self.btn_cancelTuoGuan:onClick(handler(self, self.onClick_cancelTuoGuan), true)
    self.btn_tuoGuan:onClick(handler(self, self.onClick_tuoGuan), true)
    self.btn_gameConfig:onClick(handler(self, self.onClick_gameConfig), true)
    self.btn_record:onClick(handler(self, self.onClick_record), true)

    require("hall.util.GameMenu"):registCopyRoomIdFunc(self.btn_copyRoom, self.roomId)
end

function GameSceneView:clearData()
    self:clearCampare()
    self.OprorateBtn:clearData()
    -- self:isShowTuoGuan( false )
    self:isShowBtnReady( false )
    self:isShowBtnCopy( false )
    self:isShowBtnShare( false )
    for i,UserInfoView in pairs(self.UserInfoViews) do
        UserInfoView:clearData()
    end
    self:isShowGameRound( 0, g_317.all_turns )
    self.chips_dui_vw:removeAllChildren()
	LayerShuffling:removeScene()
end

function GameSceneView:hideAllPlayerLight()
    for i,UserInfoView in pairs(self.UserInfoViews) do
        UserInfoView:isShowLight(false)
    end
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
    g_317.now_turns = now_turns
    g_317.all_turns = all_turns
    self.txt_game_round:setString("轮数:"..now_turns.."/"..all_turns)
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
        require("hall.util.GameMenu"):showConfigPanel(g_317.gameConfigTable)
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
    paras.name =  g_317.GameName.."房号：" .. self.roomId
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

    if g_317.gameConfig.dis_agree == 3 or g_isWatch == 0 then
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
        viewId = g_317.viewIds[seatId] or 0 
    end
    return self.UserInfoViews["player_"..viewId]
end

function GameSceneView:showGameConfig(gameConfigtbl)
    local gameConfigStr = ""
    local maxSeatCount = gameConfigtbl.maxSeatCount
	for k, v in pairs(gameConfigtbl) do
        if k == "pay_type" then
            if v == "fangka" then
                gameConfigStr = gameConfigStr .. "房主开房 "
            elseif v == "AA" then
                gameConfigStr = gameConfigStr .. "AA开房 "
            end
        elseif k == "huxi_score" then
            if v == 15 then
                gameConfigStr = gameConfigStr .. "十五胡起胡 "
            elseif v == 18 then
                gameConfigStr = gameConfigStr .. "十八胡起胡 "
            end
        elseif k == "bankpiao" then
            if v == 0 then
                gameConfigStr = gameConfigStr .. "庄家自摸飘分不翻倍 "
            elseif v == 1 then
                gameConfigStr = gameConfigStr .. "庄家自摸飘分翻倍 "
            end
        elseif k == "piao" then
            if v == 0 then
                g_317.isPiao = false
            elseif v == 1 then
                g_317.isPiao = true
                gameConfigStr = gameConfigStr .. "飘 "
            end
        elseif k == "backscore" then
            if v == 1 then
                gameConfigStr = gameConfigStr .. "1/2/3 "
            elseif v == 2 then
                gameConfigStr = gameConfigStr .. "5/10/15 "
            elseif v == 3 then
                gameConfigStr = gameConfigStr .. "10/20/30 "
            end
        elseif k == "back_score" then
            gameConfigStr = gameConfigStr .. "底注: "..v.." "
        elseif k == "choupai" then
            if v == 5 then
                gameConfigStr = gameConfigStr .. "抽5张 "
            elseif v == 10 then
                gameConfigStr = gameConfigStr .. "抽10张 "
            elseif v == 15 then
                gameConfigStr = gameConfigStr .. "抽15张 "
            elseif v == 20 then
                gameConfigStr = gameConfigStr .. "抽20张 "
            end
        elseif k == "wanfa" then
            local canPickStr= string.split(v, ",")
            for _, x in pairs(canPickStr) do
                if x == '1' then
                    gameConfigStr = gameConfigStr .. "全名堂 "
                elseif x == '2' then
                    gameConfigStr = gameConfigStr .. "大团圆 "
                end
            end
        end
    end
    local baseChip =  "底分:"..gameConfigtbl.baseChip .." "
    gameConfigStr = gameConfigtbl.auto_ai == 0 and "无托管 " or gameConfigStr
	g_317.gameConfigTable = {
        {
            ["游戏名"] = g_317.GameName, 
            ["底分"] = gameConfigtbl.baseChip,
        }, 
        {["特殊玩法"] = gameConfigStr},
    }
    USER_INFO.gameConfig = "玩法: "..gameConfigStr
    .." 底分 "..baseChip.." 人数 "..maxSeatCount.." 游戏名 "..g_317.GameName
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
    self:updateStartTimer(dt)
end

function GameSceneView:updateStartTimer(dt)
    if self.bg_clock.outTime then
        self.bg_clock.outTime = self.bg_clock.outTime - dt
        local outTime = math.ceil(self.bg_clock.outTime) or 0
        self.bg_clock.txt_time:setString("倒计时:"..outTime)
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

--玩家扔出筹码
function GameSceneView:diuChips(uid, gold, isQuanYa)
    local chipIdx = 7
    local scale = 0.8
    if isQuanYa then
        local startIdx = 7 - #g_317.allZhus
        for idx, value in ipairs(g_317.allZhus) do
            if gold == value then
                chipIdx = idx
                break
            end
        end
        chipIdx = chipIdx + startIdx
        scale = 1
    else
        for idx, value in ipairs(g_317.zhus) do
            if gold == value then
                chipIdx = idx
                break
            end
        end
        scale = 0.8
    end
    if chipIdx > 7 then
        chipIdx = 7
    end
	dump(chipIdx)
    local chip_btn = self.hall_1["chip_btn"..chipIdx]:clone()
    GameUtils.setNodeNameBindObj(chip_btn)
    chip_btn.txt:setString(gold/100)
    chip_btn:show()
    chip_btn:setScale(scale)
    local userInfo = g_317.userInfos[uid]
    local UsetInfoView = self:getPlayerBySeatId( userInfo.seat_id )
    chip_btn:setPosition(UsetInfoView:getWorldpoint())
    chip_btn:addTo(self.chips_dui_vw)
	local size = self.chips_dui_vw:getContentSize()
	local x = size.width / 2
	local y = size.height / 2
	local rand_x = math.random(x-120, x+120)
    local rand_y = math.random(y-50, y+50)
    local random = math.random(1, 90)
	local rotate = cc.RotateBy:create(0.1, random)
    local move = cc.MoveTo:create(0.1, cc.p(rand_x, rand_y))
    local Spawn = cc.Spawn:create(rotate, move)
    chip_btn:runAction(Spawn)
    SoundUtils:playEffect("sound_jinbi")
end

function GameSceneView:cuopaiTest(cards, card_type)
    local func = function ()
        local UserInfoView = self:getPlayerBySeatId( g_317.my_seat_id )
		UserInfoView:setCards(cards)
		UserInfoView:isShowCardType(true, card_type)
	end
	LayerShuffling.new(cards[#cards], func)
end

function GameSceneView:clearCampare()
    self.compare_vw:hide()
    for idx = 1, 2 do
        local Node = self.compare_vw["Node_"..idx]
        local cardsNode = Node.cards
        Node.img_state:hide()
        Node.ArmatureNode:hide()
        for i,node in ipairs(cardsNode:getChildren()) do
            PokerCard:changeImg(node, 0)
        end
    end
end

function GameSceneView:showCampare(datas)
    self:clearCampare()
    SoundUtils:playCardKindEffect("cmp")
    self.compare_vw:show()
    dump(datas,"showCampare--")
    for idx = 1, 2 do
        local data = datas[idx]
		local uid = data.uid
		local userInfo = g_317.userInfos[uid]
        local strNick = require("hall.GameCommon"):formatNick(userInfo.nickName)
        local Node = self.compare_vw["Node_"..idx]
		Node.txt_name:setString(strNick)
		local img_haed = Node.img_haed
		require("hall.GameCommon"):getUserHead(userInfo.portrait, "", "", img_haed, img_haed:getContentSize().width , false, "", true)
    end
	
    local ArmatureNode_3 = self.compare_vw.ArmatureNode_3:getAnimation()
    self.compare_vw.ArmatureNode_3:show()
    ArmatureNode_3:playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环

    function handler1(Armature, MovementEventType, handlerName)
        if MovementEventType == ccs.MovementEventType.complete then
            for idx = 1, 2 do
                local data = datas[idx]
                local uid = data.uid
                local Node = self.compare_vw["Node_"..idx]
                local cardsNode = Node.cards
                if data.result then
                    Node.img_state:show()
                end
                if data.uidLookCardStatus == 1 then
                    for cardIdx,node in ipairs(cardsNode:getChildren()) do
                        PokerCard:changeImg(node, data.cards[cardIdx])
                    end
                end
            end
        end
    end

    ArmatureNode_3:setMovementEventCallFunc(handler1)
    for idx = 1, 2 do
        local data = datas[idx]
        local uid = data.uid
        if data.result then
            local Node = self.compare_vw["Node_"..idx]
            local ArmatureNode = Node.ArmatureNode:getAnimation()
            Node.ArmatureNode:show()
            ArmatureNode:playWithIndex(0, -1, 0) --第一个参数是动画表index 第二个是时间间隔第三个是是否循环
            function handler1(Armature, MovementEventType, handlerName)
                if MovementEventType == ccs.MovementEventType.complete then
                    Node.ArmatureNode:hide()
                end
            end
            ArmatureNode:setMovementEventCallFunc(handler1)
        end
    end
end

function GameSceneView:recycleChips(seat_id)
    local UserInfoView = self:getPlayerBySeatId( seat_id )
    local targetPos = UserInfoView:getWorldpoint()
    local chids = self.chips_dui_vw:getChildren()
    local time_init = 1.5 / #chids
    local time = 0.1
	for idx, node in ipairs(chids) do
		local jumpHeight = math.random(0,1)
        local mb = cc.JumpTo:create(idx * time_init, targetPos, jumpHeight, 2)
        local fo = cc.FadeOut:create(time)
        local RemoveSelf = cc.RemoveSelf:create()
        local sq = cc.Sequence:create(mb, fo, RemoveSelf)
        node:runAction(sq)
    end
    return time + 1.5
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
        user_result.nick = g_317.userInfos[uid].nickName        --昵称
        user_result.icon_url = g_317.userInfos[uid].portrait        --头像链接
        user_result.sex = g_317.userInfos[uid].sex               --性别
        user_result.isRoomOwer = g_317.OwnerID == uid and 1 or 0        --是否为房主，1是，非1或不填不是
        
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

function GameSceneView:AllCompare()
	local effect = display.newSprite("#allCompare1.png")
    local frames = display.newFrames("allCompare%d.png", 1, 13)
	if frames == nil then
		display.addSpriteFrames("zhajinhua_jb/res/GameScene/allCompare.plist", "zhajinhua_jb/res/GameScene/allCompare.png")
		frames = display.newFrames("allCompare%d.png", 1, 13)
    end
    SoundUtils:playEffect("allin")
    local function stopAllSounds( )
        audio.stopAllSounds()
    end
    local animation = display.newAnimation(frames, 0.1)
	transition.playAnimationOnce(effect, animation, true, stopAllSounds)
    effect:addTo(self)
    local size = self:getContentSize()
	effect:setPosition(cc.p(size.width / 2, size.height / 2))
end

function GameSceneView:onExit( )
    self:stopAllActions()
end

return GameSceneView
