require("mhxl_majiang.globle.XLMHData")
require("mhxl_majiang.globle.XLMHDefine")

D3_OPERATOR = require("hall.3DMahjongCard.ShowOperator")

local gamePlaneOperator = require("mhxl_majiang.operator.GamePlaneOperator")
local manyouPlaneOperator = require("mhxl_majiang.operator.ManyouPlaneOperator")

local PROTOCOL = import("mhxl_majiang.handle.XLMHProtocol")
local sendHandle = require("mhxl_majiang.handle.XLMHSendHandle")
local receiveHandle = require("mhxl_majiang.handle.XLMHReceiveHandle")

local XLMH_face=require("hall.FaceUI.faceUI")
--local chatView = require("hall.view.chatView.chatView")

local CHILD_NAME_MANYOU_PLANE = "manyou_plane"

local CHILD_NAME_MENU_PLANE = "menu_plane"
local CHILD_NAME_MENU_BT = "menu_bt"
local CHILD_NAME_BT = ""
local CHILD_NAME_DISBAND_BT = "disband_bt"
local CHILD_NAME_SETTING_BT = "setting_bt"
local CHILD_NAME_CLOSE_ROOM_BT = "close_room_bt"
local CHILD_NAME_EXIT_BT = "exit_bt"
local CHILD_NAME_SHARE_BT = "share_bt"
local CHILD_NAME_RECORD_BT = "record_bt"
local CHILD_NAME_CHAT_BT = "chat_bt"
local CHILD_NAME_VOICE_BT = "voice_temp_bt"

local CHILD_NAME_REMARK = "remark"
local CHILD_NAME_GAME_LB = "game_lb"

local XLMHScene = class("XLMHScene", function()
		return display:newScene("XLMHScene")
	end)

local CHILD_NAME_ROOM_LB = "room_lb"

function XLMHScene:ctor()
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    DESIGN_SCREEN_WIDTH  = 1920
    DESIGN_SCREEN_HEIGHT = 1080

    self.IS_CLUB_GAME = false


    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    
	self._scene = cc.CSLoader:createNode("mhxl_majiang/GameScene.csb"):addTo(self)
    -- self._scene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    self.BG = self._scene:getChildByName("bg")
    XLMH_GAME_OVER = false
    -- BG:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    -- BG:setVisible(false)
    -- BG:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH,SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    self.bg_select_index = 1
	XLMH_GAME_PLANE = self._scene:getChildByName("game_plane")
    self:_initUI()
    --文字聊天模块
    local XLMH_face_node = XLMH_face.new();
    XLMH_face_node:setHandle(sendHandle)
    self._scene:addChild(XLMH_face_node, 9999)
    XLMH_face_node:setName("faceUI")
    -- dump(XLMH_GAME_PLANE, "mhxl_majiang test")

	XLMH_CONTROLLER = require("mhxl_majiang.GameController")

	gamePlaneOperator:init()

    D3_OPERATOR:init(XLMH_CONTROLLER,nil,nil,nil,XLMH_GAME_PLANE)

	XLMH_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	manyouPlaneOperator:init()
    self:setGameSetting()
    local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

    local device_info_plane = self._scene:getChildByName("device_info_plane")
    -- device_info_plane:setVisible(false)

    

    --local menu_plane = menu_ly:getChildByName(CHILD_NAME_MENU_PLANE)
    local menu_bt = self._scene:getChildByName(CHILD_NAME_MENU_BT)

    --local setting_bt = menu_plane:getChildByName(CHILD_NAME_SETTING_BT)
    --local disband_bt = menu_plane:getChildByName(CHILD_NAME_DISBAND_BT)
    --
    local instruction_bt = self._scene:getChildByName("instruction_bt")
    self.remark_lb = XLMH_GAME_PLANE:getChildByName("remark_lb")
    local remark_lb = self.remark_lb
    local remark_img = XLMH_GAME_PLANE:getChildByName("remark_img")
    self.remark_img = remark_img
    local exit_bt = self._scene:getChildByName(CHILD_NAME_EXIT_BT)
    instruction_bt:setPosition(cc.p(exit_bt:getPositionX(),exit_bt:getPositionY()))
    instruction_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(1)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
               -- dump(bit.band(91, CONTROL_TYPE_GANG),"hu ---44")

                sendHandle:CLI_QUERY_CARDS()

                -- if  isOpenControl == true then
                --     local function CLI_SEND_TEST_CARD_FUNC(card)

                --         local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_TEST_CARD)
                --         :setParameter("card", card)
                --         :build()
                --         bm.server:send(pack)
                --     end

                --     require("hall.scene.verify.testConfig"):chooseCard({1,2,3,4,5,6,7,8,9,
                --         17,18,19,20,21,22,23,24,25,
                --         33,34,35,36,37,38,39,40,41,49,50,51,52,
                --         65,66,67},"mhxl_majiang/image/card/",CLI_SEND_TEST_CARD_FUNC)

                -- else
                --     sender:setScale(1.0)
                --     if remark_lb:isVisible() then
                --        remark_lb:setVisible(false)
                --        remark_img:setVisible(false)
                --        remark_lb:setPosition(cc.p(640,remark_img:getPositionY()))
                --     else
                --        remark_lb:setPosition(cc.p(640,remark_img:getPositionY()))
                --        remark_img:setVisible(true)
                --        remark_lb:setVisible(true)
                --     end
                --     -- sendHandle:CLI_ROBOT(1)
                -- end
            end
        end
    )

    remark_img.noScale = true
    remark_img:addTouchEventListener(
        function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                if remark_lb:isVisible() then
                   remark_lb:setVisible(false)
                   remark_img:setVisible(false)
                   remark_lb:setPosition(cc.p(640,remark_img:getPositionY()))
               else
                   remark_lb:setPosition(cc.p(640,remark_img:getPositionY()))
                   remark_img:setVisible(true)
                   remark_lb:setVisible(true)
               end
            end
        end
    )

    local menu_change = self._scene:getChildByName("menu_change")
    local this = self
     menu_change:addTouchEventListener(function(sender,event)
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
                 --menu_bt:setBrightStyle(1)
                this:changeBgImg()
            end
        end)


    --menu_plane:setVisible(false)
    menu_bt:addTouchEventListener(function(sender,event)
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
                 --menu_bt:setBrightStyle(1)
                self:loadMoreFuncLayer()
            end
        end)
    --
    --menu_plane:setTouchEnabled(true)
    --menu_plane:addTouchEventListener(
    --    function(sender,event)
    --
    --        --触摸结束
    --        if event == TOUCH_EVENT_ENDED then
    --            sender:setScale(1.0)
    --
    --            if menu_plane:isVisible() then
    --             menu_plane:setVisible(false)
    --             menu_bt:setBrightStyle(0)
    --            end
    --        end
    --    end
    --)

 
    --disband_bt:addTouchEventListener(
    --    function(sender,event)
    --        --触摸开始
    --        if event == TOUCH_EVENT_BEGAN then
    --            sender:setScale(0.8)
    --        end
    --
    --        --触摸取消
    --        if event == TOUCH_EVENT_CANCELED then
    --            sender:setScale(1.0)
    --        end
    --
    --        --触摸结束
    --        if event == TOUCH_EVENT_ENDED then
    --            sender:setScale(1.0)
    --
    --            self:disbandGroup()
    --
    --        end
    --    end
    --)
    --

    --setting_bt:addTouchEventListener(
    --    function(sender,event)
    --        --触摸开始
    --        if event == TOUCH_EVENT_BEGAN then
    --            sender:setScale(0.9)
    --        end
    --
    --        --触摸取消
    --        if event == TOUCH_EVENT_CANCELED then
    --            sender:setScale(1.0)
    --        end
    --
    --        --触摸结束
    --        if event == TOUCH_EVENT_ENDED then
    --            sender:setScale(1.0)
    --
    --            require("hall.GameCommon"):showSettings(true,false,true,true,function(sender, event)
    --                    --     --触摸开始
    --                    if event == TOUCH_EVENT_BEGAN then
    --                        sender:setScale(0.9)
    --                    end
    --
    --                    --触摸取消
    --                    if event == TOUCH_EVENT_CANCELED then
    --                        sender:setScale(1.0)
    --                    end
    --
    --                    --触摸结束
    --                    if event == TOUCH_EVENT_ENDED then
    --                        sender:setScale(1.0)
    --
    --                        require("hall.GameCommon"):showSettings(false)
    --
    --                        self:disbandGroup()
    --
    --                    end
    --                end)
    --
    --        end
    --    end
    --)

    -- local group_owner = tonumber(USER_INFO["group_owner"])
    --只有房主才出现解散按钮
    -- if group_owner ~= USER_INFO["uid"] then
    --  close_room_bt:setVisible(false)
    -- end

    close_room_bt:addTouchEventListener(
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

                self:disbandGroup()

            end
        end
    )

    --返回按钮

    exit_bt:setVisible(false)
    exit_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.8)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束（检查当前组局状态）
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                --dump(USER_INFO["activity_id"], "-----退出房间按钮，当前activityid-----")

                cct.createHttRq({
                    url = HttpAddr .. "/freeGame/queryGroupGameStatus",
                    date = {
                        activityId = USER_INFO["activity_id"],
                        interfaceType = "j"
                    },
                    type_= "POST",
                    callBack = function(data)
                        --dump(data, "检查当前组局状态")
                        local responseData = data.netData
                        responseData = json.decode(responseData)
                        local returnCode = responseData.returnCode
                        if returnCode == "0" then
                            local data = tonumber(responseData.data)
                            -- --dump(data, "检查当前组局状态")
                            if data == 1 then
                                --创建组局
                                require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？")

                            elseif data == 2 then
                                --开始组局
                                require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
                                
                            elseif data == 0 then
                                --结束组局
                                require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

                            end
                        else
                            require("hall.GameTips"):showTips("提示", "", 2, "游戏数据异常，不能退出房间")
                        end

                    end
                })

            end
        end
    )

    --邀请微信好友
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    share_bt:setVisible(true)
    share_bt:addTouchEventListener(
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
                paras["name"] = "闷胡血流，房号：" .. USER_INFO["invote_code"]
                paras["showType"] = 2;
                paras["url"] = appDownLoadAddress
                local shareLayer = require("hall.share.ShareLayer").new(paras)
                if shareLayer then
                    shareLayer:addTo(SCENENOW["scene"],9999999)
                end




            end
        end
    )

    --local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    --record_bt:setVisible(false)
    --record_bt:addTouchEventListener(
    --    function(sender,event)
    --        --触摸开始
    --        if event == TOUCH_EVENT_BEGAN then
    --            sender:setScale(0.9)
    --        end
    --
    --        --触摸取消
    --        if event == TOUCH_EVENT_CANCELED then
    --            sender:setScale(1.0)
    --        end
    --
    --        --触摸结束
    --        if event == TOUCH_EVENT_ENDED then
    --            sender:setScale(1.0)
    --
    --            if device.platform ~= "windows" then
    --                --todo
    --                require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])
    --            end
    --        end
    --    end
    --    )

    local chat_bt = self._scene:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(false)
    local function onface_click(sender)
        --local posx=sender:getPosition().x    --*0.75
        --local posy=sender:getPosition().y    --*0.75
        --local pos = cc.p(posx,posy)
        -- XLMH_face_node:showTxtPanle(pos, 8)

        self:loadGameMsgLayer()
    end
    chat_bt:onClick(onface_click)
    
    local lbVersion = ccui.Text:create()
    lbVersion:setString("1.0.7")
    lbVersion:setFontSize(18)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
    self._scene:addChild(lbVersion, 10000)
end

function XLMHScene:SendHandle()
    --chatView:hideView()
end

function XLMHScene:changeBgImg()
    if self.bg_select_index == 3 then
        self.bg_select_index = 1
    else
        self.bg_select_index = self.bg_select_index + 1
    end

    self.BG:setTexture("mhxl_majiang/image/bg_"..self.bg_select_index..".png")
    -- self.BG:setVisible(false)
end

function XLMHScene:callBackJiaoYan(pack)
    if  pack.count > 0 and isOpenControl then
       local function CLI_SEND_TEST_CARD_FUNC(card)
            local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_TEST_CARD)
            :setParameter("card", card)
            :build()
            bm.server:send(pack)
        end
        require("hall.scene.verify.testConfig"):chooseCard(pack.cards,"mhxl_majiang/image/card/",
            CLI_SEND_TEST_CARD_FUNC)

    else
        if self.remark_lb:isVisible() then
           self.remark_lb:setVisible(false)
           self.remark_img:setVisible(false)
           self.remark_lb:setPosition(cc.p(640,self.remark_img:getPositionY()))
        else
           self.remark_lb:setPosition(cc.p(640,self.remark_img:getPositionY()))
           self.remark_img:setVisible(true)
           self.remark_lb:setVisible(true)
        end
        -- sendHandle:CLI_ROBOT(1)
    end
end

-- --隐藏语音和文字聊天
-- function XLMHScene:hidechatView()
--     chatView:hideView()
-- end
function XLMHScene:reConnect()
    dump("GXLZScene:reConnect")

    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function XLMHScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    sendHandle:LoginGame(USER_INFO["GroupLevel"])
    --require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function XLMHScene:onEnter()

	local function getDeviceInfo() 
        
       if tolua.isnull(XLMH_GAME_PLANE)  then
           return
       end

       local device_info_plane = (XLMH_GAME_PLANE:getParent()):getChildByName("device_info_plane")
       local wifi_level        = device_info_plane:getChildByName("wifi_level")
       local battery_level     = device_info_plane:getChildByName("battery_level")
       local time              = device_info_plane:getChildByName("time")
       
       local wifi_level_num = 4  --00 -- 04
       -- dump(PINT_TIME, "PINT_TIME")
       
       if PINT_TIME~=nil then
          
          local ping = PINT_TIME
          if tonumber(ping)<=120 then
            wifi_level_num = 4
          elseif tonumber(ping)>120 and tonumber(ping)<=200 then
            wifi_level_num = 3
          elseif tonumber(ping)>200 and tonumber(ping)<=300 then
            wifi_level_num = 2
          elseif tonumber(ping)>300 and tonumber(ping)<=500 then
            wifi_level_num = 1
          elseif tonumber(ping)>500 then
            wifi_level_num = 0
          end   
        end

       wifi_level:setTexture("mhxl_majiang/image/wifi_0"..wifi_level_num..".png")

       local battery_level_degree = 100
       battery_level:setPercent(battery_level_degree) 

       local time_txt = os.date("%H:%M")
       time:setString(time_txt)
        
        if device.platform == "ios" then

            local betteryPercent = cct.getDataForApp("getBetteryPercent", {}, "I")
         
            battery_level:setPercent(betteryPercent) 

       end
    end
    
    local scheduler=cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(getDeviceInfo,5,false)
    local room_lb_plane = self._scene:getChildByName("room_lb_plane")
    local room_lb = room_lb_plane:getChildByName(CHILD_NAME_ROOM_LB)
    room_lb:setString(USER_INFO["invote_code"])
    
    --sendHandle:LoginGame(USER_INFO["GroupLevel"])
    sendHandle:LoginGame(USER_INFO["GroupLevel"])
    if tableIdReload == 0 then --非重登

    else
        tableIdReload = 0
    end

    local remark_frame = self._scene:getChildByName(CHILD_NAME_REMARK)
    local game_lb = remark_frame:getChildByName(CHILD_NAME_GAME_LB)
    game_lb:setString(XLMH_PRV_GAME_NAME)
    local remarkSize = cc.size(game_lb:getContentSize().width + 50, remark_frame:getContentSize().height)
    remark_frame:setSize(remarkSize)
    game_lb:setPosition(cc.p(remarkSize.width / 2, remarkSize.height / 2))
end

-- function XLMHScene:setVoiceBtImg( flag )
--     local voice_bt = self.chat_plane:getChildByName(CHILD_NAME_VOICE_BT)

--     local img = "mhxl_majiang/image/record_bt.png"
    
--     if flag == 1 then
--         --todo
--         img = "mhxl_majiang/image/record_bt1.png"
--     end

--     voice_bt:loadTexture(img)
-- end

function XLMHScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = XLMH_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if XLMH_USERINFO_TABLE[seatId .. ""] and XLMH_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = XLMH_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function XLMHScene:showLeaderLayer()
    --local self._scene = self._scene:getChildByName("self._scene")
    --local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    --require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

function XLMHScene:ShowChatButton()
    local chat_bt = self._scene:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

function XLMHScene:ShowRecordButton()
    --local menu_ly = self._scene:getChildByName("menu_ly")
    --local record_bt = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    --record_bt:setVisible(false)

    local btn_voice = self._scene:getChildByName(CHILD_NAME_VOICE_BT)
    --require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)
    --*0.75
    local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        btn_voice:setVisible(true)
        VoiceRecordView:addVoiceRecordEvent(btn_voice,1)
    else
        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
    end
    self:showLeaderLayer()
end

--获取用户播放录音位置
function XLMHScene:getPosforSeat(uid)
    return XLMH_ROOM.positionTable[uid .. ""]
end

--显示设置按钮（弃用）
function XLMHScene:ShowSettingButton()
    -- local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

    -- setting_bt:setVisible(true)
end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function XLMHScene:hideCloseRoomButton()
    local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)
    close_room_bt:setVisible(false)
end

function XLMHScene:hideShareButton()
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    share_bt:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function XLMHScene:disbandGroup()

    local function disband()
        XLMH_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
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
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if returnCode == "0" then
                local data = tonumber(responseData.data)
                --dump(data, "检查当前组局状态")
                if data == 1 then
                    --创建组局
                          require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？",_,disband)

                elseif data == 2 then
                    --开始组局
                    require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？",_,disband)
                    
                elseif data == 0 then
                    --结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

                end
            else
                    
            end

        end
    })

end

----聊天
--function XLMHScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
--    local s = self:getChildByName("faceUI")
--
--    if tonumber(sex) >= 0 then
--        s:showGetFace(uid, type, tonumber(sex), node_head, isLeft)
--    end
--end

function XLMHScene:test()
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

function XLMHScene:testEnding()

	XLMH_USERINFO_TABLE[0] = {}
	XLMH_USERINFO_TABLE[0].uid = 723
	XLMH_USERINFO_TABLE[0].nick = "tl"

	XLMH_USERINFO_TABLE[1] = XLMH_USERINFO_TABLE[0]
	XLMH_USERINFO_TABLE[2] = XLMH_USERINFO_TABLE[0]
	XLMH_USERINFO_TABLE[3] = XLMH_USERINFO_TABLE[0]


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

--聊天
function XLMHScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
    local faceUI=SCENENOW['scene']._scene:getChildByName("faceUI")
    -- local sexT = sex
    -- if pack["uid"] == USER_INFO["uid"] then
        -- sex = USER_INFO["sex"]
        -- if sexT == 0 then--保密
        --     sexT = 0
        -- else
        --     sexT = sexT -1
        -- end
    -- else
    --     local temp,seat = require("ddz.ddzSettings"):getDOS(USERID2SEAT[pack["uid"]])

    --     if seat==1 then
    --         sex = seat1sex
    --     elseif seat==2 then
    --         sex = seat2sex
    --     end
    -- end
    
    if tonumber(sex) >= 0 then
        faceUI:showGetFace(uid, type, tonumber(sex), node_head, isLeft)
    end
end

function XLMHScene:setGameSetting()
    self.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self._scene:addChild(self.roomCommonLayer, 15)
    self.roomCommonLayer:setTouchSwallowEnabled(false)
    self.roomCommonLayer:setVisible(false)
    self:loadGameMsgLayer()
end


function XLMHScene:showGameSetting()
    self:setGameSetting()
    self:loadMoreFuncLayer()
end
function XLMHScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end
function XLMHScene:disbandRoom()
    XLMH_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
end

function XLMHScene:rejectDisband()
    XLMH_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function XLMHScene:agreeDisband()
    XLMH_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function XLMHScene:getToDisbandFuncs()
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

function XLMHScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self._scene:addChild(self.moreFuncLayer, 999)
        -- g_roomCommonLayer = self.moreFuncLayer
    else
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end
end

function XLMHScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self._scene:addChild(self.gameMsgLayer, 999)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function XLMHScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end
function XLMHScene:quitRoom()
    sendHandle:CLI_QUIT_ROOM()
end

function XLMHScene:sendFaceByIdx(id)
    print("sendFaceMsg --------------------------", id)
    sendHandle:CLI_MSG_FACE(id)
end

function XLMHScene:sendEditTxt(str)
    print("sendEditMsg --------------------------")
end
function XLMHScene:showInviteCode()
    local room_lb_plane = self._scene:getChildByName("room_lb_plane")
    local room_lb = room_lb_plane:getChildByName(CHILD_NAME_ROOM_LB)
    room_lb:setString(USER_INFO["invote_code"])
end
function XLMHScene:_initUI()
    local bg = self._scene:getChildByName("bg")
    local precent = self:_getScaleParam2()
    -- dump(precent,"===precent")
    -- if bg then
    --     bg:setContentSize(cc.size(cc.Director:getInstance():getOpenGLView():getFrameSize().width,cc.Director:getInstance():getOpenGLView():getFrameSize().height))
    -- end
    XLMH_GAME_PLANE:setScaleX(bg:getScale()*precent)
    --XLMH_GAME_PLANE:setContentSize(cc.size(cc.Director:getInstance():getOpenGLView():getFrameSize().width,cc.Director:getInstance():getOpenGLView():getFrameSize().height))
    local child = self._scene:getChildren()
    for i, v in ipairs( child or {} ) do
        local x = v:getPositionX()
        v:setPositionX(x*precent)
        if v:getDescription() == "ListView" then --容器按照比率重新设置大小
            local size = v:getContentSize()
            v:setContentSize(cc.size(size.width * precent, size.height))
        end
    end
    --local child_b = XLMH_GAME_PLANE:getChildren()
    --for i, v in ipairs( child_b or {} ) do
    --    local x = v:getPositionX()
    --    v:setPositionX(x*precent)
    --    if v:getDescription() == "ListView" then --容器按照比率重新设置大小
    --        local size = v:getContentSize()
    --        v:setContentSize(cc.size(size.width * precent, size.height))
    --    end
    --end

end
function XLMHScene:_getScaleParam2()
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH, 720, cc.ResolutionPolicy.SHOW_ALL)
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    -- dump(cc.Director:getInstance():getOpenGLView():getFrameSize(),"CONFIG_WIN_WIDTH")
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end
return XLMHScene