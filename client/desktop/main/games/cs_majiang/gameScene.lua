D3_OPERATOR = require("hall.3DMahjongCard.ShowOperator")

local gamePlaneOperator = require("cs_majiang.operator.GamePlaneOperator")
local manyouPlaneOperator = require("cs_majiang.operator.ManyouPlaneOperator")
local PROTOCOL = import("cs_majiang.handle.CSMJProtocol")
local sendHandle = require("cs_majiang.handle.CSMJSendHandle")
local receiveHandle = require("cs_majiang.handle.CSMJReceiveHandle")
local csmj_face=require("hall.FaceUI.faceUI")

local CHILD_NAME_MANYOU_PLANE = "manyou_plane"
local CHILD_NAME_MENU_PLANE = "menu_plane"
local CHILD_NAME_MENU_BT = "menu_bt"
local CHILD_NAME_BT = ""
local CHILD_NAME_DISBAND_BT = "disband_bt"
local CHILD_NAME_SETTING_BT = "setting_bt"
local CHILD_NAME_CLOSE_ROOM_BT = "close_room_bt"
local CHILD_NAME_EXIT_BT = "exit_bt"
local CHILD_NAME_SHARE_BT = "share_bt"
local CHILD_NAME_RECORD_BT = "voice_btn"
local CHILD_NAME_CHAT_BT = "talk_btn"
local CHILD_NAME_VOICE_BT = "voice_temp_bt"
local CHILD_NAME_REMARK = "remark"
local CHILD_NAME_GAME_LB = "game_lb"
local CHILD_NAME_ROOM_LB = "room_lb"

local CSMJScene = class("CSMJScene", function()
		return display:newScene()
	end)

function CSMJScene:ctor()

    local errorlist = {[5449]=true}
    if  errorlist[USER_INFO["uid"]]  then
        isShowErrorScene = true
    end

    require("cs_majiang.globle.CSMJData"):init()
    require("cs_majiang.globle.CSMJDefine"):init()
    if USER_INFO.GroupLevel == 320 then
        GameNameValue = "长沙麻将"
    elseif USER_INFO.GroupLevel == 358 then
        GameNameValue = "沅江麻将"
    end
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())

	self._scene = cc.CSLoader:createNode("cs_majiang/GameScene.csb"):addTo(self)

    local lbVersion = ccui.Text:create()
    lbVersion:setString("1.0.0")
    lbVersion:setFontSize(18)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
    self._scene:addChild(lbVersion, 9999)

    CSMJ_GAME_PLANE = self._scene:getChildByName("game_plane")
    CSMJ_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	CSMJ_CONTROLLER = require("cs_majiang.GameController")

    D3_OPERATOR:init(CSMJ_CONTROLLER,nil,nil,nil,CSMJ_GAME_PLANE)
    -- 设置房间模式 1房卡场、2金币场
    if USER_INFO["GroupLevel"] == 130 then
        GROUP_MODE = GOLD_MODE
    else
        GROUP_MODE = ROOMCARD_MODE
    end
	gamePlaneOperator:init()
	manyouPlaneOperator:init()

   

    --local copy_btn = self._scene:getChildByName("copy_btn")
    CS_GAME_TG =   self._scene:getChildByName("take_bg")
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)
    local menu_ly  = self._scene:getChildByName("menu_ly")
    local menu_bt = menu_ly:getChildByName(CHILD_NAME_MENU_BT)
    local instruction_bt = menu_ly:getChildByName("instruction_bt")
    local menu_plane = menu_ly:getChildByName(CHILD_NAME_MENU_PLANE) 
    local setting_bt = menu_ly:getChildByName(CHILD_NAME_SETTING_BT)
    local disband_bt = menu_plane:getChildByName(CHILD_NAME_DISBAND_BT)
    if GROUP_MODE == GOLD_MODE then
        disband_bt:setVisible(false)
    end
    local remark_lb = CSMJ_GAME_PLANE:getChildByName("remark_lb")
    local remark_img = CSMJ_GAME_PLANE:getChildByName("remark_img")
    local exit_bt = menu_ly:getChildByName(CHILD_NAME_EXIT_BT)
	exit_bt:setVisible(false)
    local ready_bt = self._scene:getChildByName("ready_bt")

    --[[local sit_btn = self._scene:getChildByName("sit_btn")
    sit_btn:setVisible(false)--]]

    --[[local stand_btn = self._scene:getChildByName("stand_btn")
    stand_btn:setVisible(false)--]]

   --[[ local recharge_btn = self._scene:getChildByName("recharge_btn")
    recharge_btn:setVisible(false)

    local record_bt = self._scene:getChildByName("record_bt")
    record_bt:setVisible(false)--]]

    local function onTouchEvent(sender,event)
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
    
            sender:setScale(1.0)
            if sender == instruction_bt then
                        
                if  isOpenControl == true then
                    local function CLI_SEND_TEST_CARD_FUNC(card)

                        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_TEST_CARD)
                        :setParameter("card", card)
                        :build()
                        bm.server:send(pack)
                    end

                    require("hall.scene.verify.testConfig"):chooseCard({1,2,3,4,5,6,7,8,9,
                        17,18,19,20,21,22,23,24,25,
                        33,34,35,36,37,38,39,40,41
                        },"cs_majiang/image/card/",CLI_SEND_TEST_CARD_FUNC)

                else
                        self:show_game_config(true)
                end
                --  if remark_lb:isVisible() then
                --      remark_lb:setVisible(false)
                --      remark_img:setVisible(false)
                --      remark_lb:setPosition(cc.p(640,instruction_bt:getPositionY()))            
                -- else
                --      remark_lb:setPosition(cc.p(640,instruction_bt:getPositionY()))
                --      remark_img:setVisible(true)
                --      remark_lb:setVisible(true)
                -- end
            elseif sender == ready_bt then
                sendHandle:H2G_ACCOUNT_READY(1)

            elseif sender == sit_btn then
                -- sendHandle:H2G_ACCOUNT_SIT(-1)
                --add by zzy 2019-9-2
                -- self:loadMoreFuncLayer()
            elseif sender == stand_btn then
                sendHandle:H2G_ACCOUNT_STAND()

            elseif sender == copy_btn then
                require("hall.util.GameMenu"):registCopyRoomIdFunc(copy_btn,USER_INFO["invote_code"],GameNameValue)
            
            elseif sender == recharge_btn then
                -- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)

            elseif sender == record_bt then
                sendHandle:H2G_GET_LAST_RECORD()

            elseif sender == menu_bt then

                self:loadMoreFuncLayer()

            elseif sender == menu_plane then
                if menu_plane:isVisible() then
                    menu_plane:setVisible(false)
                    menu_bt:setBrightStyle(0)
                end

            elseif sender == disband_bt then
                self:disbandGroup()

            elseif sender == setting_bt then
                -- local btn_action = function(sender,event)
                --     --触摸开始
                --     if event == TOUCH_EVENT_BEGAN then
                --         sender:setScale(0.9)
                --     end
                --     --触摸取消
                --     if event == TOUCH_EVENT_CANCELED then
                --         sender:setScale(1.0)
                --     end
                --     --触摸结束
                --     if event == TOUCH_EVENT_ENDED then
                --         sender:setScale(1.0)
                --         if GROUP_MODE == GOLD_MODE or IS_ONLOOKER == true then
                --             local quitRoom_action = function()
                --                 self:quitRoom()
                --             end 
                --             require("hall.GameTips"):showTips("提示", "", 1, "确定退出房间？",nil,quitRoom_action) 
                --         else
                --             require("hall.GameCommon"):showSettings(false)
                --             self:disbandGroup()                   
                --             end
                --     end
                -- end

                -- if GROUP_MODE == GOLD_MODE or IS_ONLOOKER == true then
                --     require("hall.GameCommon"):showSettings(true, false, true, true, btn_action,"退出房间")
                -- else
                --     require("hall.GameCommon"):showSettings(true, false, true, true, btn_action,"解散房间")
                -- end
                self:loadMoreFuncLayer()
            elseif sender == close_room_bt then
                if GROUP_MODE == GOLD_MODE then
                    self:quitRoom()
                else
                    self:disbandGroup()
                end
                

            elseif sender == exit_bt then
                local quitRoom_action = function()
                    self:quitRoom()
                end 
                local disband_action = function ()
                    self:disbandGroup()
                end
                if GROUP_MODE == GOLD_MODE then
                    require("hall.GameTips"):showTips("提示", "", 1, "确定退出房间？",nil,quitRoom_action) 
                else
                    require("hall.GameTips"):showTips("提示", "", 1, "确定解散房间？",nil,disband_action)
                end

            elseif sender == share_bt then
                -- require("hall.common.ShareLayer"):showShareLayer("长沙麻将，房号：" .. USER_INFO["invote_code"], "http://fir.im/168mja", "url", USER_INFO["gameConfig"])
                 USER_INFO["invote_code"] = USER_INFO["invote_code"] or " "
                local   config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
                local   share_content = ""
                for k,v in pairs(config_arr) do
                    if v ~= "" then
                        share_content = share_content .. v .. ","
                    end
                end

                share_content = string.sub(share_content, 1, string.len(share_content) - 1)  
                local paras = {}
                paras["desc"] =  USER_INFO["gameConfigMsg"] or " "
                paras["imagePath"] = "url"
                paras["name"] = GameNameValue.."，房号：" .. USER_INFO["invote_code"]
                paras["showType"] = 2;
                paras["url"] = appDownLoadAddress
                local shareLayer = require("hall.share.ShareLayer").new(paras)
                if shareLayer then
                    shareLayer:addTo(SCENENOW["scene"],9999999)
                end
            elseif sender == record_bt then
                if device.platform ~= "windows" then
                    require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])
                end
            end
        end
    end

    instruction_bt:addTouchEventListener(onTouchEvent)
    menu_bt:addTouchEventListener(onTouchEvent)
    menu_plane:addTouchEventListener(onTouchEvent)
    disband_bt:addTouchEventListener(onTouchEvent)
    --setting_bt:addTouchEventListener(onTouchEvent)

    close_room_bt:addTouchEventListener(onTouchEvent)
    exit_bt:addTouchEventListener(onTouchEvent)
    share_bt:addTouchEventListener(onTouchEvent)
    ready_bt:addTouchEventListener(onTouchEvent)
    --copy_btn:addTouchEventListener(onTouchEvent)
    --[[sit_btn:addTouchEventListener(onTouchEvent)
    stand_btn:addTouchEventListener(onTouchEvent)
    recharge_btn:addTouchEventListener(onTouchEvent)
    record_bt:addTouchEventListener(onTouchEvent)--]]

    remark_img.noScale = true
    remark_img:addTouchEventListener(
        function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                if remark_lb:isVisible() then
                   remark_lb:setVisible(false)
                   remark_img:setVisible(false)
                   remark_lb:setPosition(cc.p(640,instruction_bt:getPositionY()))            
               else
                   remark_lb:setPosition(cc.p(640,instruction_bt:getPositionY()))
                   remark_img:setVisible(true)
                   remark_lb:setVisible(true)
               end
            end
        end
    )

    -- local group_owner = tonumber(USER_INFO["group_owner"])
    --只有房主才出现解散按钮
    -- if group_owner ~= USER_INFO["uid"] then
    --  close_room_bt:setVisible(false)
    -- end

    local csmj_face_node = csmj_face.new();
    csmj_face_node:setHandle(sendHandle)
    self:addChild(csmj_face_node, 9999)
    csmj_face_node:setName("faceUI")

    -- 聊天
    local talk_btn = menu_ly:getChildByName(CHILD_NAME_CHAT_BT)
    -- talk_btn:setVisible(false)
    local function onface_click(sender)
        -- local pos = sender:getPosition()
        -- csmj_face_node:showTxtPanle(pos,8)
        self:loadGameMsgLayer()
    end
    talk_btn:onClick(onface_click)

    local voice_btn = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    local voice_bt_worldpoint = (voice_btn:getParent()):convertToWorldSpace(voice_btn:getPosition())
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(voice_btn,999)
    else
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end
    CS_GAME_TG:setVisible(false)
    CS_GAME_TG:getChildByName("btn_cl"):addTouchEventListener(function(sender,event)
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
            sendHandle:CLI_ROBOT(0)
        end
    end)
    --self._scene:getChildByName("btn_tg"):addTouchEventListener(function(sender,event)
    --    --触摸开始
    --    if event == TOUCH_EVENT_BEGAN then
    --        sender:setScale(0.9)
    --    end
    --
    --    --触摸取消
    --    if event == TOUCH_EVENT_CANCELED then
    --        sender:setScale(1)
    --    end
    --
    --    --触摸结束
    --    if event == TOUCH_EVENT_ENDED then
    --        sender:setScale(1)
    --        sendHandle:CLI_ROBOT(1)
    --    end
    --end)
    self:setGameSetting()

end

function CSMJScene:onEnter()

	-- cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    local device_info_plane = self._scene:getChildByName("device_info_plane")
    local time = device_info_plane:getChildByName("time")
     time:setFontName("cs_majiang/fonts/fzcs.ttf")
    require("hall.util.GameMenu"):addMenu(nil,device_info_plane,GameNameValue)
    
    sendHandle:LoginGame()

    if tableIdReload == 0 then --非重登

    else
        tableIdReload = 0
    end

    local remark_frame = self._scene:getChildByName(CHILD_NAME_REMARK)
    local game_lb = remark_frame:getChildByName(CHILD_NAME_GAME_LB)
    game_lb:setString(GameNameValue)
    local remarkSize = cc.size(game_lb:getContentSize().width + 50, remark_frame:getContentSize().height)
    remark_frame:setSize(remarkSize)
    game_lb:setPosition(cc.p(remarkSize.width / 2, remarkSize.height / 2))



    self:_initUI()

end

function CSMJScene:_initUI()
    -- local bg = self._scene:getChildByName("Image_1")
    local precent = self:_getScaleParam2()
    -- bg:setContentSize(cc.size(cc.Director:getInstance():getOpenGLView():getFrameSize().width,cc.Director:getInstance():getOpenGLView():getFrameSize().height))
    -- XLMH_GAME_PLANE:setScaleX(bg:getScale()*precent)
    -- XLMH_GAME_PLANE:setContentSize(cc.size(cc.Director:getInstance():getOpenGLView():getFrameSize().width,cc.Director:getInstance():getOpenGLView():getFrameSize().height))
    local child = self._scene:getChildren()
    for i, v in ipairs( child or {} ) do
        local x = v:getPositionX()
        v:setScaleX(precent)
        v:setPositionX(x*precent)
        if v:getDescription() == "ListView" then --容器按照比率重新设置大小
            local size = v:getContentSize()
            v:setContentSize(cc.size(size.width * precent, size.height))
        end
    end
end

function CSMJScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
end

function CSMJScene:ShowChatButton(flag)
    if flag == nil then
        flag = true
    end
    local menu_ly = self._scene:getChildByName("menu_ly")
    local chat_bt = menu_ly:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(flag)
end



function CSMJScene:ShowRecordButton(flag)
    if flag == nil then
        flag = true
    end
	local menu_ly = self._scene:getChildByName("menu_ly")
    local record_bt = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(flag)
end

--获取用户播放录音位置
function CSMJScene:getPosforSeat(uid)
    return CSMJ_ROOM.positionTable[uid .. ""]
end

--显示设置按钮
function CSMJScene:ShowSettingButton()
	-- local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

	-- setting_bt:setVisible(true)
end

function CSMJScene:hideCloseRoomButton()
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

	close_room_bt:setVisible(false)
end

function CSMJScene:hideShareButton()
	local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
	share_bt:setVisible(false)
end

function CSMJScene:showShareButton(flag)
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    if share_bt then
        share_bt:setVisible(flag)
    end
end

function CSMJScene:showReadyBtn(flag)
    local ready_bt = self._scene:getChildByName("ready_bt")
    if ready_bt then
        ready_bt:setVisible(flag)
    end
end

function CSMJScene:showCopyBtn(flag)
    --[[local copy_btn = self._scene:getChildByName("copy_btn")
    if copy_btn then
        copy_btn:setVisible(flag)
    end--]]
end

-- function CSMJScene:quitRoom()
--    sendHandle:H2G_QUIT_ROOM()
-- end
--解散房间
function CSMJScene:disbandGroup()

    local function disband()
        sendHandle:H2G_DISSOLVE_ROOM()
    end
    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
            activityId = USER_INFO["activity_id"],
            interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            -- local responseData = data.netData
            -- responseData = json.decode(responseData)
            -- local returnCode = responseData.returnCode
            -- if returnCode == "0" then
                -- local data = tonumber(responseData.data)
                -- -- dump(data, "-----检查当前组局状态-----")
                -- if data == 1 then
                    -- --创建组局
                    -- if isiOSVerify then
                        -- require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "是否解散房间？",_,disband)
                    -- else
                        -- require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？",_,disband)
                    -- end
                -- elseif data == 2 then
                    -- --开始组局
                    -- if isiOSVerify then
                        -- require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "是否解散房间？",_,disband)
                    -- else
                        -- require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？",_,disband)
                    -- end
                    
                -- elseif data == 0 then
                    -- --结束组局
                    -- require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")
                -- end
            -- else     
            -- end
			local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
			print('-----returnCode---',returnCode)
            if returnCode == "0" then
                local data = tonumber(responseData.data)
                dump(data, "检查当前组局状态")
                if data == 1 then
                    --创建组局
                    require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "提前解散房间不扣钻石，是否确定解散",_,requestDisband)
                elseif data == 2 then
                    --开始组局
                    require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "牌局已开始，确定要申请解散房间？",_,requestDisband)
                    
                elseif data == 0 then
                    --结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "牌局已结束，是否返回大厅？")

                end             
            end
        end
    })
end

function CSMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = CSMJ_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if CSMJ_USERINFO_TABLE[seatId .. ""] and CSMJ_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = CSMJ_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function CSMJScene:test()
	local cards = {}
	for i=1,13 do

		local card = {}
		card["value"] = i
		table.insert(cards, card)
	end
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_MY, self.myPlane, cards)
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_LEFT, self.leftPlane, cards)
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_RIGHT, self.rightPlane, cards)
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_TOP, self.topPlane, cards)

	local controlType = bit.bor(CONTROL_TYPE_HU, CONTROL_TYPE_GANG)
	-- dump(CONTROL_TYPE_HU, "controlType test")
	-- dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_PENG)
	-- dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_CHI)
	-- dump(controlType, "controlType test")
	playerPlaneOperator:showControlPlane(self.myPlane, controlType)
end

function CSMJScene:testEnding()

	CSMJ_USERINFO_TABLE[0] = {}
	CSMJ_USERINFO_TABLE[0].uid = 723
	CSMJ_USERINFO_TABLE[0].nick = "zh"

	CSMJ_USERINFO_TABLE[1] = CSMJ_USERINFO_TABLE[0]
	CSMJ_USERINFO_TABLE[2] = CSMJ_USERINFO_TABLE[0]
	CSMJ_USERINFO_TABLE[3] = CSMJ_USERINFO_TABLE[0]


	local testData = {}
	testData.type = 2
	testData.spendTime = 50
	testData.time = 123214214
	testData.uid = 723

	testData.players = {}

	local player = {}
	player.uid = 723
	player.isOnline = 1
	player.coins = 3000
	player.changeCoins = 3
	player.remainCardsCount = 2
	player.remainCards = {2,2}
	player.agCount = 0
	player.gCount = 0
	player.pCount = 0
	player.cCount = 0
	player.huTypeCount = 0

	table.insert(testData.players, player)
	table.insert(testData.players, player)
	table.insert(testData.players, player)
	table.insert(testData.players, player)

	testData.birdCount = 0
	testData.huCard = 1
	testData.isOver = 1

	return testData
end

function CSMJScene:showInviteCode()
    local room_lb_plane = self._scene:getChildByName("room_lb_plane")
    local room_lb = room_lb_plane:getChildByName(CHILD_NAME_ROOM_LB)
    -- room_lb:setFontName("cs_majiang/fonts/fzcs.ttf")
    local txt_lb = display.newTTFLabel({
                text = content,
                font = "cs_majiang/fonts/fzcs.ttf",
                size = 25,
                color = cc.c3b(166, 59, 6),
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                dimensions = cc.size(txtWidth, 0)
            })

    txt_lb:setAnchorPoint(room_lb:getAnchorPoint())
    room_lb_plane:addChild(txt_lb)
    txt_lb:setPosition(room_lb:getPosition())
    txt_lb:setString(USER_INFO["invote_code"])
    room_lb:setString(USER_INFO["invote_code"])
    room_lb:setVisible(false)
end
function CSMJScene:reConnect()
    --SanGongSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function CSMJScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    sendHandle:LoginGame()
    --require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
--function CSMJScene:reConnect()
--    -- dump("test 1123 begin")
--    bm.server:setProtocol(PROTOCOL)
--    bm.server:setHandle(receiveHandle.new())
--    sendHandle:LoginGame()
--end

function CSMJScene:after_account_login()
    local ready_btn = self._scene:getChildByName("ready_bt")
    -- if GROUP_GENERATION == 1 or GROUP_MODE == ROOMCARD_MODE then
        --ready_btn:setPosition(cc.p(640,160))
    -- end
    --[[local copy_btn = self._scene:getChildByName("copy_btn")
    copy_btn:addTouchEventListener(function (sender,event)
        if event == TOUCH_EVENT_ENDED then
            require("hall.util.GameMenu"):registCopyRoomIdFunc(copy_btn,USER_INFO["invote_code"],GameNameValue)
        end
    end)--]]
end

function CSMJScene:refresh_user_info()
    local cardUtils = require("cs_majiang.utils.cardUtils")
    for i = 1, GAME_PLAYER_COUNT do
        gamePlaneOperator:hidePlayerInfo(i)
        CSMJ_SEAT_TABLE_BY_TYPE[i .. ""] = nil
    end

    self:showReadyBtn(false)
    gamePlaneOperator:clearAllReadyStatus()

    dump(CSMJ_USERINFO_TABLE,"CSMJ_USERINFO_TABLE333")
    for seat_id,userInfo in pairs(CSMJ_USERINFO_TABLE) do
        local seat_id = tonumber(seat_id)
        if seat_id < 0 then
        else
            local uid = CSMJ_USERINFO_TABLE[seat_id .. ""].uid
            local playerType = CARD_PLAYERTYPE_MY
            if seat_id ~= CSMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] then
                playerType = cardUtils:getPlayerType(seat_id)
                CSMJ_SEAT_TABLE_BY_TYPE[playerType .. ""] = seat_id
            end

            --设置用户已经准备
            if uid == USER_INFO["uid"] then
                if CSMJ_GAME_STATUS == 0 then
                    if CSMJ_USERINFO_TABLE[seat_id .. ""].ready_flag == 1 then
                        gamePlaneOperator:setReadyStatus(playerType)
                        self:showReadyBtn(false)
                    else
                        gamePlaneOperator:setReadyStatus(playerType,false)
                        self:showReadyBtn(true)
                    end
                else
                    gamePlaneOperator:setReadyStatus(playerType,false)
                    self:showReadyBtn(false)
                end
            else

                if CSMJ_USERINFO_TABLE[seat_id .. ""].ready_flag == 1 and CSMJ_GAME_STATUS == 0 then
                    gamePlaneOperator:setReadyStatus(playerType) 
                else
                    gamePlaneOperator:setReadyStatus(playerType,false)
                end
            end

            -- 播放录音的位置
            local infoPlane = gamePlaneOperator:showPlayerInfo(playerType, userInfo)
            local head = infoPlane:getChildByName("portrait") 
            local point = cc.p(head:getAnchorPoint().x * head:getSize().width, head:getAnchorPoint().y * infoPlane:getSize().height)
            CSMJ_ROOM.positionTable[USER_INFO["uid"] .. ""] = head:convertToWorldSpace(point)
            local position = CSMJ_ROOM.positionTable[USER_INFO["uid"] .. ""] 
            require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid,position)
        end
    end
end

function CSMJScene:set_game_config(game_config,fenchang)
    GAME_CONFIG_TABLE = nil 
    local game_config = json.decode(game_config)
    local niao = game_config["niao"]
    local zhuang = game_config["zhuang"]
    local zhuaniao = game_config["zhuaniao"]

    --dump (zhuang ,"---------可选----------")
    dump (zhuaniao ,"---------zhuaniao可选----------")

    local niao_string = ""
    local zhuang_string = ""
    local fengchang_string = ""
    local zhongniao_string = ""
    --[[
    if zhuang == "2" then
        zhuang_string = "庄闲模式"
    else
        zhuang_string = "非庄闲模式"
    end
    --]]
    if zhuaniao == 0 then
        zhongniao_string = "翻倍"
    elseif zhuaniao == 1 then
        zhongniao_string = "加分"
    end
    
    
    if string.find(zhuang, "2") then 
        zhuang_string = "庄闲模式"
    else
        zhuang_string = "非庄闲模式"
    end
    if string.find(zhuang, "3") then 
        zhuang_string = zhuang_string ..((zhuang_string ~= "") and "，六六顺" or "六六顺")
    end 
    if string.find(zhuang, "4") then 
        zhuang_string = zhuang_string ..((zhuang_string ~= "") and "，缺一色" or "缺一色")
    end 
    if string.find(zhuang, "5") then 
        zhuang_string = zhuang_string ..((zhuang_string ~= "") and "，板板胡" or "板板胡")
    end 
    if string.find(zhuang, "6") then 
        zhuang_string = zhuang_string ..((zhuang_string ~= "") and "，大四喜" or "大四喜")
    end 
    if string.find(zhuang, "7") then 
        zhuang_string = zhuang_string ..((zhuang_string ~= "") and "，节节高" or "节节高")
    end 
    if string.find(zhuang, "8") then 
        zhuang_string = zhuang_string ..((zhuang_string ~= "") and "，三同" or "三同")
    end 
    if string.find(zhuang, "9") then 
        zhuang_string = zhuang_string ..((zhuang_string ~= "") and "，一枝花" or "一枝花")
    end 

    if niao == 2 then
        niao_string = "抓2鸟"
    elseif niao == 4 then
        niao_string = "抓4鸟"
    elseif niao == 6 then
        niao_string = "抓6鸟"
    end

    if GROUP_MODE == ROOMCARD_MODE then
        fengchang_string = "房卡场"
    else
        fengchang_string = "金币场"..fenchang.."分场"
    end

    local gameConfigTable =     
        { 
            {["游戏"] = GameNameValue},
            {["分场"] = fengchang_string},
          --{["分场"] = fengchang_string},
          --{["庄闲"] = zhuang_string,["抓鸟"] = niao_string},  
          {["中鸟"] = zhongniao_string,["抓鸟"] = niao_string},  
          {["规则"] = zhuang_string},  
        }
    GAME_CONFIG_TABLE = gameConfigTable
end

--设置游戏配置信息
function CSMJScene:show_game_config(flag)
    dump(GAME_CONFIG_TABLE,"GAME_CONFIG_TABLE333")
    if GAME_CONFIG_TABLE ~= nil and next(GAME_CONFIG_TABLE) ~= nil then
        require("hall.util.GameMenu"):showConfigPanel(GAME_CONFIG_TABLE)
    end

    if not flag then
        if SCENENOW["scene"]:getChildByName("ConfigPanel") then
            SCENENOW["scene"]:getChildByName("ConfigPanel"):removeFromParent()
        end
    end
    -- local hall_plane = TDK_GAME_SCENE:getChildByName("hall_plane")
    -- local game_content_plane = hall_plane:getChildByName("game_content_plane")
    -- if game_content_plane:isVisible() then
    --  game_content_plane:setVisible(false)
    -- else
    --  game_content_plane:setVisible(true)
    -- end
    -- if flag ~= nil then
    --  game_content_plane:setVisible(flag)
    -- end
end


function CSMJScene:setGameSetting()
    CSMJScene.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self:addChild(CSMJScene.roomCommonLayer, 15)
    CSMJScene.roomCommonLayer:setTouchSwallowEnabled(false)
    CSMJScene.roomCommonLayer:setVisible(false)
    self:loadGameMsgLayer()
end

function CSMJScene:showGameSetting()
    self:setGameSetting()
    self:loadMoreFuncLayer()
end
function CSMJScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end
function CSMJScene:disbandRoom()
    sendHandle:H2G_DISSOLVE_ROOM()
end

function CSMJScene:rejectDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0) 
end

function CSMJScene:agreeDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function CSMJScene:getToDisbandFuncs()
    local data = {}
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
    return data
end

function CSMJScene:loadMoreFuncLayer()
    if tolua.isnull(CSMJScene.moreFuncLayer) then
        CSMJScene.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(CSMJScene.moreFuncLayer, 99)
    else
	
        CSMJScene.moreFuncLayer:setVisible(true)
        CSMJScene.moreFuncLayer:showAni()
    end
    -- if 0 == bm.Room.now_turns and CSMJScene.isHide == false then
    --     self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    -- else
    --     self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    -- end
	
	if not CSMJ_ROUND or 0 == CSMJ_ROUND then
	    self.moreFuncLayer.btnDisbandRoom:setVisible(false)
	else
	    self.moreFuncLayer.btnDisbandRoom:setVisible(true)
	end
end

function CSMJScene:loadGameMsgLayer()
    if tolua.isnull(CSMJScene.gameMsgLayer) then
        CSMJScene.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(CSMJScene.gameMsgLayer, 99999)
        CSMJScene.gameMsgLayer:setVisible(false)
    else
        CSMJScene.gameMsgLayer:setVisible(true)
        CSMJScene.gameMsgLayer:showContentByType(1)
    end
end

function CSMJScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end
function CSMJScene:quitRoom()
    -- sendHandle:CLI_QUIT_ROOM()
    sendHandle:H2G_QUIT_ROOM()
end

function CSMJScene:sendFaceByIdx(id)
    sendHandle:CLI_MSG_FACE(id)
end


function CSMJScene:TgState(flag)
    dump(flag,"flag==")
    CS_GAME_TG:setVisible(flag)
end
return CSMJScene
