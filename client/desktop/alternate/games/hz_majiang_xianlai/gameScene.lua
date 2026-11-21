local GamePlaneOperator = require(TpackageName..".operator.GamePlaneOperator")
local PROTOCOL = import(TpackageName..".handle.HZMJProtocol")
local sendHandle = require(TpackageName..".handle.HZMJSendHandle")
local receiveHandle = require(TpackageName..".handle.HZMJReceiveHandle")
local HZMJ_face=require("hall.FaceUI.faceUI")
local GPSShowLayer = require("hall.GPSShowLayer")

local HZMJScene = class("HZMJScene", function()
		return display:newScene()
    end)
    
function HZMJScene:setDefine( )
    TpackageName = "hz_majiang_xianlai"
    GameName = "闲来红中麻将"
    G_game = {} --游戏内的全局变量 当游戏场景销毁时跟着销毁
    G_game.isYiMaQuanZhong = false
    G_game.isLaiZi = function (m_value)--是否是癞子
        if G_game and type(G_game.laiziCount) == "number" and m_value then
            local tabs = {
                [1] = {65},
                [2] = {65,67},
            }
            local tab = tabs[G_game.laiziCount] or {}
            for i,v in ipairs(tab) do
                if m_value == v then
                    return true
                end
            end
        end
        return false
    end
end

function HZMJScene:ctor()
    self:setDefine( )
    self:setNodeEventEnabled(true)
    require(TpackageName..".globle.HZMJData").new()

    require(TpackageName..".globle.HZMJDefine").new()
    D3_OPERATOR = require("hall.3DMahjongCard.ShowOperator")

    print("===========麻将的level打印！！！==============")
    print(USER_INFO["GroupLevel"])

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    self.bg_select_index = 1
    self._scene = cc.CSLoader:createNode(TpackageName.."/res/GameScene/GameScene.csb"):addTo(self)
    GameUtils.setNodeNameBindObj(self._scene)
    self._scene.bg.titile_bg:ignoreContentAdaptWithSize(true)
    -- display.doLayout(nil, self._scene.bg)
    -- display.doLayout(self._scene.players)
    display.doLayout(self._scene.hall)

    local size = self._scene:getContentSize()
    DESIGN_SCREEN_WIDTH = size.width
    DESIGN_SCREEN_HEIGHT = size.height
    -- SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    -- SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    -- self._scene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)

    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getFrameSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getFrameSize().height
    local scaleY=SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT
    cc.Director:getInstance():getOpenGLView():setFrameSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(SCREEN_WIDTH/scaleY, DESIGN_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc

	HZMJ_SCENE = self._scene
    self._hall = self._scene.hall
    
    self:_initUI()
    self:initEvent()
    self:setGameSetting()

    dump("HZMJ_SCENE",HZMJ_SCENE)
    local HZMJ_face_node = HZMJ_face.new();
    HZMJ_face_node:setHandle(sendHandle)
    self:addChild(HZMJ_face_node, 9999)
    HZMJ_face_node:setName("faceUI")


	HZMJ_CONTROLLER = require(TpackageName..".GameController")
    
    D3_OPERATOR:init(HZMJ_CONTROLLER,nil,nil,nil,HZMJ_SCENE.players)
	GamePlaneOperator:init()

    local device_info_plane = self._hall:getChildByName("device_info_plane")


    local btn_gameConfigMsg = self._hall:getChildByName("btn_gameConfigMsg")

    btn_gameConfigMsg:onClick(function(sender,event)
        if isOpenControl then
            sendHandle:CLI_REQ_TEST_CARDS()
        else
            -- 玩法介绍同意风格
            require("hall.util.GameMenu"):showConfigPanel(gameConfigTable)
        end
    end)
    self._hall.btn_menu:onClick(function(event)
        self:loadMoreFuncLayer()
    end)

    --邀请微信好友
    local btn_share = self._hall:getChildByName("btn_share")
    btn_share:setVisible(false)
    if isiOSVerify then
        btn_share:setVisible(false)
    end
    btn_share:onClick(function(event)
        local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
        local share_content = ""
        for k, v in pairs(config_arr) do
            if v ~= "" then
                share_content = share_content .. v .. ","
            end
        end

        share_content = string.sub(share_content, 1, string.len(share_content) - 1)
        local invote_code = USER_INFO["invote_code"] or ""

        local paras = {}
        paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
        paras["imagePath"] = "url"
        paras["name"] = GameName.."房号：" .. USER_INFO["invote_code"]
        paras["showType"] = 2;
        paras["url"] = appDownLoadAddress
        local shareLayer = require("hall.share.ShareLayer").new(paras)
        if shareLayer then
            shareLayer:addTo(SCENENOW["scene"],9999999)
        end
        -- require("hall.common.ShareLayer"):showShareLayer(GameName .. "，房号：" .. invote_code, "", "url", share_content)
    end)

    
    local btn_record = self._hall:getChildByName("btn_record")
    btn_record:setVisible(false)
    btn_record:onClick(function(sender,event)
        if device.platform ~= "windows" then
            require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])
        end
    end)

    self._hall.btn_chat:setVisible(false)
    self._hall.btn_chat:onClick(function (sender)
        self:loadGameMsgLayer()
    end)

    -- 复制房间号按钮
    local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    btn_copyRoom:onClick(function (event)
        require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copyRoom, USER_INFO["invote_code"], GameName)
    end)
    btn_copyRoom:setVisible(false)

    -- 准备按钮
    local btn_ready = self._hall:getChildByName("btn_ready")
    btn_ready:onClick(function ( event)
        sendHandle:readyNow()
    end)
    btn_ready:setVisible(false)


    local lbVersion = ccui.Text:create()
    lbVersion:setString("1.0.3")
    lbVersion:setFontSize(18)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
    self._scene:addChild(lbVersion, 999)

    --显示表情符号
    local idx = ViewBase:getZOrderByChilds(self)
    local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)
    EmojiArmatureView:setLocalZOrder(idx)
end

function HZMJScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end
function HZMJScene:_getScaleParam()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT

    return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function HZMJScene:changeBgImg()
    if self.bg_select_index == 3 then
        self.bg_select_index = 1
    else
        self.bg_select_index = self.bg_select_index + 1
    end
    local bg = self._scene:getChildByName("bg")
    bg:setTexture(TpackageName.."/res/image/bg_"..self.bg_select_index..".png")
    -- self.BG:setVisible(false)
end

function HZMJScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("Image_1")
        local precent = self:_getScaleParam2()
        if bg then
            bg:setScaleX(bg:getScale()*precent)
            -- local x = bg:getPositionX()
            -- bg:setPositionX(x*precent)
        end

        local root = self._scene
        if root then
            local child = root:getChildren()
            for i, v in ipairs( child or {} ) do
                local x = v:getPositionX()
                v:setPositionX(x*precent)
                if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                    local size = v:getContentSize()
                    v:setContentSize(cc.size(size.width * precent, size.height))
                end
            end
        end

		local mj_danjiChuPai = cc.UserDefault:getInstance():getBoolForKey("mj_danjiChuPai")
        self.checkBox = self._scene.hall.CheckBox_1:setSelectedState(mj_danjiChuPai)
        if mj_danjiChuPai then
            self.checkBox.Text_14:setString("单击")
        else
            self.checkBox.Text_14:setString("双击")
        end
        self:TgState(false)


             ---gps按钮
        local gpsBtn = self._scene:getChildByName("btn_gps")
        gpsBtn:setVisible(false)
        gpsBtn:addTouchEventListener(function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then

               sender:setScale(1)
               local gpsLayer = GPSShowLayer.new()
               self:addChild(gpsLayer)
               local temptab = {}
               for k,v in pairs(HZMJ_USERINFO_TABLE) do
                   table.insert(temptab,v)
               end
               gpsLayer:setInfo(temptab)

            end
        end)


    end
end

function HZMJScene:showGPSButton()
    dump(HZMJ_USERINFO_TABLE,"showGPSButton--HZMJ_USERINFO_TABLE")
    local temptab = {}
    for k,v in pairs(HZMJ_USERINFO_TABLE) do
        table.insert(temptab,v)
    end
    local btn_gps = self._scene:getChildByName("btn_gps")

    if #temptab == 1 then
        btn_gps:setVisible(false)
        return
    end

    local isWarning = 0
    for i=1,#temptab do
        for j=i+1,#temptab do
            if calculateDistance(temptab[i].latitude,temptab[j].latitude,temptab[i].longitude,temptab[j].longitude) <= 100 then
                isWarning = isWarning + 1
                break
            end
        end
    end

    local img_safe = btn_gps:getChildByName("img_safe")
    local img_warnning = btn_gps:getChildByName("img_warnning")

    if isWarning > 0 then
        img_safe:setVisible(false)
        img_warnning:setVisible(true)
    else
        img_safe:setVisible(true)
        img_warnning:setVisible(false)
    end

    btn_gps:setVisible(true)
end

function HZMJScene:initEvent()
    self.checkBox:addEventListenerCheckBox(function(sender,eventType)
        require("hall.GameCommon"):onClickSound()
        if eventType == CHECKBOX_STATE_EVENT_SELECTED then
			cc.UserDefault:getInstance():setBoolForKey("mj_danjiChuPai",true)
            self.checkBox:setSelectedState(true)
            self.checkBox.Text_14:setString("单击")
        elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
			cc.UserDefault:getInstance():setBoolForKey("mj_danjiChuPai",false)
            self.checkBox:setSelectedState(false)
            self.checkBox.Text_14:setString("双击")
        end
    end)
    self._hall:getChildByName("btn_tg"):onClick(function(event)
        sendHandle:CLI_ROBOT(1)
    end)
    self._scene.take_bg.btn_cl:onClick(function(event)
        sendHandle:CLI_ROBOT(0)
    end)
end

function HZMJScene:onEnter()
    local device_info_plane = self._hall:getChildByName("device_info_plane") 
    require("hall.util.GameMenu"):addMenu(nil,device_info_plane,GameName)

    self:showInviteCode()
    sendHandle:LoginGame()
	if tableIdReload == 0 then --非重登
    else
        tableIdReload = 0
    end
    
end

function HZMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = HZMJ_SEAT_TABLE[uid ]

    if seatId then
        --todo

        if HZMJ_USERINFO_TABLE[seatId ] and HZMJ_USERINFO_TABLE[seatId ].ip then
            --todo
            ip_ = HZMJ_USERINFO_TABLE[seatId ].ip
        end
    end

    return ip_
end

function HZMJScene:showLeaderLayer()

end

function HZMJScene:ShowChatButton()
    self._hall.btn_chat:setVisible(true)
end

function HZMJScene:showVoice()
    local scenes  = self._scene
     if scenes then
         local btn_voice = self._hall.btn_voice
         local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())
         local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
         if  VoiceRecordView.addVoiceRecordEvent then
             btn_voice:setVisible(true)
             VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
         else
             VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
         end
     end


end

function HZMJScene:ShowRecordButton()
    self._hall.btn_record:setVisible(false)

    self._hall.btn_chat:setVisible(true)

    --语音按钮

    self:showVoice()
    ------self:showLeaderLayer()
end

--获取用户播放录音位置
function HZMJScene:getPosforSeat(uid)
    return HZMJ_ROOM.positionTable[uid ]
end

--显示设置按钮（弃用）
function HZMJScene:ShowSettingButton()

end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function HZMJScene:hideCloseRoomButton()
end

function HZMJScene:hideShareButton()
	local btn_share = self._hall:getChildByName("btn_share")
	btn_share:setVisible(false)
    -- 复制房间号按钮
    local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    btn_copyRoom:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function HZMJScene:disbandGroup()
 dump(responseData,"gggggg55ggggggggggggg")
	--查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
	cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
        	activityId = USER_INFO["activity_id"],
        	interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            dump(responseData,"ggggggggggggggggggg")
            if returnCode == "0" then
            	local data = tonumber(responseData.data)
            	--dump(data, "检查当前组局状态")
            	if data == 1 then
            		--创建组局
                    if isiOSVerify or isGoldGame ~= 1 then
                        require("hall.GameTips"):showDisbandTips("解散房间", "HZMJ_disbandGroup", 1, "是否解散房间？")
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "HZMJ_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")
                    end

            	elseif data == 2 then
            		--开始组局
                    if isiOSVerify or isGoldGame ~= 1 then
                        require("hall.GameTips"):showDisbandTips("解散房间", "HZMJ_disbandGroup", 1, "是否申请解散房间？")
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "HZMJ_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
                    end
            		
            	elseif data == 0 then
            		--结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

            	end

            else
            		
            end

 		end
	})

end

--聊天
function HZMJScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
    local s = self:getChildByName("faceUI")
    
    if tonumber(sex) >= 0 then
        s:showGetFace(uid, type, tonumber(sex), node_head, isLeft)
    end
end
function HZMJScene:reConnect()
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function HZMJScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    sendHandle:LoginGame()
end
--function HZMJScene:reConnect()
--    dump("test 1123 begin")
--    bm.server:setProtocol(PROTOCOL)
--    bm.server:setHandle(receiveHandle.new())
--    sendHandle:LoginGame()
--end

function HZMJScene:showInviteCode()
    local invote_code = USER_INFO.invote_code or ""
    self._hall.room_lb:setString("房间号："..invote_code)
end

function HZMJScene:hideInviteCode()
    self._hall.room_lb:setVisible(false)
end

function HZMJScene:showCopyInviteBtn(isShow)
    if HZMJ_ROUND and HZMJ_ROUND >= 1 then
        isShow = false
    end
    -- 复制房间号按钮
    local btn_copyRoom = self._hall:getChildByName("btn_copyRoom")
    btn_copyRoom:setVisible(isShow)

    --邀请微信好友
    local btn_share = self._hall:getChildByName("btn_share")
    btn_share:setVisible(isShow)
    if isiOSVerify then
        btn_share:setVisible(false)
        btn_copyRoom:setVisible(false)
    end
    btn_share:onClick(
        function(sender,event)
            local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
            local share_content = ""
            for k, v in pairs(config_arr) do
                if v ~= "" then
                    share_content = share_content .. v .. ","
                end
            end

            share_content = string.sub(share_content, 1, string.len(share_content) - 1)
            local invote_code = USER_INFO["invote_code"] or ""
            
            local paras = {}
            paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
            paras["imagePath"] = "url"
            paras["name"] = GameName.."房号：" .. USER_INFO["invote_code"]
            paras["showType"] = 2;
            paras["url"] = appDownLoadAddress
            local shareLayer = require("hall.share.ShareLayer").new(paras)
            if shareLayer then
                shareLayer:addTo(SCENENOW["scene"],9999999)
            end
            -- require("hall.common.ShareLayer"):showShareLayer(GameName .. "，房号：" .. invote_code, "", "url", share_content)
        end
    )

end


function HZMJScene:showBtnByUserStatus(_type)

    -- 准备按钮
    local btn_ready = self._hall:getChildByName("btn_ready")

    if not _type then

        btn_ready:setVisible(false)

    elseif _type == "ready" then
        btn_ready:setVisible(false)

    elseif _type == "sit" then
        btn_ready:setVisible(true)
    elseif _type == "stand" then
        btn_ready:setVisible(false)

    end
end

function HZMJScene:showGameConfig(gameConfigtbl)
    local gameConfigStr = ""
	for k, v in pairs(gameConfigtbl) do
        if k == "pay_type" then
            if v == "fangka" then
                gameConfigStr = gameConfigStr .. "房主开房 "
            elseif v == "AA" then
                gameConfigStr = gameConfigStr .. "AA开房 "
            end
        -- elseif k == "hufa" then
        --     if v == 0 then
        --         gameConfigStr = gameConfigStr .. "可抢杠胡 "
        --     elseif v == 1 then
        --         gameConfigStr = gameConfigStr .. "自摸胡 "
        --     end
        elseif k == "laiziCount" then
            if v == 0 then
                gameConfigStr = gameConfigStr .. "无宝 "
            elseif v == 1 then
                gameConfigStr = gameConfigStr .. "红中做宝 "
            elseif v == 3 then
                gameConfigStr = gameConfigStr .. "双宝 "
            end
        elseif k == "zhuaniao" then
            if v == 2 then
                gameConfigStr = gameConfigStr .. "2码 "
            elseif v == 4 then
                gameConfigStr = gameConfigStr .. "4码 "
            elseif v == 6 then
				gameConfigStr = gameConfigStr .. "6码 "
			elseif v == 8 then
                gameConfigStr = gameConfigStr .. "8码 "
            elseif v == 999 then
                gameConfigStr = gameConfigStr .. "一码全中 "
                G_game.isYiMaQuanZhong = true
			elseif v == 0 then
                gameConfigStr = gameConfigStr .. "无码 "
			end
		elseif k == "huPaiScore" then
            if v == 2 then
				gameConfigStr = gameConfigStr .. "2分起胡 "
			elseif v == 3 then
                gameConfigStr = gameConfigStr .. "3分起胡 "
            end
        elseif k == "tgTime" then
            if v == 0 then
                gameConfigStr = gameConfigStr .. "无托管 "
			end
        -- elseif k == "canPick" then
        --     local canPickStr= string.split(v, ",")
        --     for _, x in pairs(canPickStr) do
        --         if x == '0' then
        --             gameConfigStr = gameConfigStr .. "庄闲(算分) "
        --         elseif x == '1' then
        --             gameConfigStr = gameConfigStr .. "可胡七对 "
        --         elseif x == '2' then
        --             gameConfigStr = gameConfigStr .. "红中癞子 "
        --         end
        --     end
        end
	end
    USER_INFO["gameConfig"] = "玩法: "..gameConfigStr
    
    gameConfigTable = {{["游戏名"]=GameName, ["底分"] = BASE_CHIP}, {["特殊玩法"] = gameConfigStr}}
end


function HZMJScene:setGameSetting()
    self.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self:addChild(self.roomCommonLayer, 15)
    self.roomCommonLayer:setTouchSwallowEnabled(false)
    self.roomCommonLayer:setVisible(false)
    self:loadGameMsgLayer()
end


function HZMJScene:showGameSetting()
    print("=====self:showGameSetting=====")
    print("=====self:showGameSetting=====")
    self:setGameSetting()
    self:loadMoreFuncLayer()
end
function HZMJScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end
function HZMJScene:disbandRoom()
    sendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function HZMJScene:rejectDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function HZMJScene:agreeDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function HZMJScene:getToDisbandFuncs()
    local data = {}
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    --data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
    data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
    return data
end

function HZMJScene:loadMoreFuncLayer()
    print("=====loadMoreFuncLayer=====")
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
    -- print("======SCENENOW['scene'].GameRound======",SCENENOW["scene"].GameRound)

    if 0 == SCENENOW["scene"].GameRound then
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    end
end

function HZMJScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
       
        self:addChild(self.gameMsgLayer, 99999)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function HZMJScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end
function HZMJScene:quitRoom()
    -- sendHandle:CLI_QUIT_ROOM()
    print("=====quitRoom===6666666===")
    print("=====quitRoom===6666666===")
    print("=====quitRoom===6666666===")
    print("=====quitRoom===6666666===")
    sendHandle:quitRoom()
    -- self:disbandGroup()
end

function HZMJScene:sendFaceByIdx(id, msgType, to_uid)
    print("sendFaceMsg --------------------------", id)
    sendHandle:CLI_MSG_FACE(id, msgType, to_uid)
end

function HZMJScene:sendEditTxt(str)
    print("sendEditMsg --------------------------", id)
end
function HZMJScene:TgState(flag)
    self._scene.take_bg:setVisible(flag)
end

function HZMJScene:onExit()
    dump("---------------退出快乐麻将")
    GamePlaneOperator:clearGameDatas()
    --G_game = nil
    --TpackageName = nil
    D3_CHUPAI = 0

end
return HZMJScene