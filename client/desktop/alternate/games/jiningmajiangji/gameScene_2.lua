


local gamePlaneOperator = require("jiningmajiangji.operator.GamePlaneOperator")
-- local manyouPlaneOperator = require("jiningmajiangji.operator.ManyouPlaneOperator")

local PROTOCOL = import("jiningmajiangji.handle.ZZMJProtocol")
local sendHandle = require("jiningmajiangji.handle.ZZMJSendHandle")
local receiveHandle = require("jiningmajiangji.handle.ZZMJReceiveHandle")

local ZZMJ_face=require("hall.FaceUI.faceUI")


-- local CHILD_NAME_MANYOU_PLANE = "manyou_plane"

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
local CHILD_NAME_COPYROOM_BT = "btn_copyRoom"
local CHILD_NAME_READY_BT = "ready_bt"
local CHILD_NAME_BUYCOIN_BT = "btn_buyCoin"
local CHILD_NAME_ZHANJI = "btn_zhanji"

local ZZMJScene = class("ZZMJScene", function()
		return display:newScene()
	end)

local CHILD_NAME_ROOM_LB = "room_lb"

function ZZMJScene:ctor()
    require("jiningmajiangji.globle.ZZMJData").new()
    require("jiningmajiangji.globle.ZZMJDefine").new()
    D3_OPERATOR = require("hall.3DMahjongCard.ShowOperator")
    GameName = "济宁麻将"

    TpackageName = "jiningmajiangji"

    --给特定用户开红屏
    local errorlist = {[5553]=true,[100005]=true,[100012]=true,[100022]=true,[100011]=true,[100022]=true}   
    local errorcheckId =  USER_INFO["uid"] or 1
    if  errorlist[errorcheckId]  then
        isShowErrorScene = true
    end
    
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
    
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())

	self._scene = cc.CSLoader:createNode("jiningmajiangji/GameScene.csb"):addTo(self)
    -- self._scene:setScale(0.75)
	ZZMJ_GAME_PLANE = self._scene:getChildByName("game_plane")
    print("ZZMJ_GAME_PLANE",ZZMJ_GAME_PLANE)
    local ZZMJ_face_node = ZZMJ_face.new();
    ZZMJ_face_node:setHandle(sendHandle)
    self:addChild(ZZMJ_face_node, 9999)
    ZZMJ_face_node:setName("faceUI")

    --dump(ZZMJ_GAME_PLANE, "jiningmajiangji test")

	ZZMJ_CONTROLLER = require("jiningmajiangji.GameController")
    
    D3_OPERATOR:init(ZZMJ_CONTROLLER,nil,nil,nil,ZZMJ_GAME_PLANE)
	gamePlaneOperator:init()

	-- ZZMJ_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	-- manyouPlaneOperator:init()   
    local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

    local device_info_plane = self._scene:getChildByName("device_info_plane")

    local menu_ly  = self._scene:getChildByName("menu_ly")
    local menu_plane = menu_ly:getChildByName(CHILD_NAME_MENU_PLANE) 
    local menu_bt = self._scene:getChildByName(CHILD_NAME_MENU_BT)

    local remark = self._scene:getChildByName("remark")
    local gameName_lb = remark:getChildByName("Text_1")
          gameName_lb:setString(GameName)
          remark:setSize((gameName_lb:getSize().width+20),remark:getSize().height)
          gameName_lb:setPositionX(remark:getSize().width/2)

	local setting_bt = menu_plane:getChildByName(CHILD_NAME_SETTING_BT)
    local disband_bt = menu_plane:getChildByName(CHILD_NAME_DISBAND_BT)
    
    local instruction_bt = menu_ly:getChildByName("instruction_bt")
    local remark_lb = ZZMJ_GAME_PLANE:getChildByName("remark_lb")
    local remark_img = ZZMJ_GAME_PLANE:getChildByName("remark_img")

    instruction_bt:addTouchEventListener(
        function(sender,event)
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

                if isOpenControl then
                    sendHandle:CLI_REQ_TEST_CARDS()
                else
                    -- 玩法介绍同意风格
                    require("hall.util.GameMenu"):showConfigPanel(gameConfigTable)

                end
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
                   remark_lb:setPosition(cc.p(640,instruction_bt:getPositionY()))            
               else
                   remark_lb:setPosition(cc.p(640,instruction_bt:getPositionY()))
                   remark_img:setVisible(true)
                   remark_lb:setVisible(true)
               end
            end
        end
    )

    menu_plane:setVisible(false)
    menu_bt:addTouchEventListener(
        function(sender,event)
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
                
                if menu_plane:isVisible() then
                    menu_plane:setVisible(false)
                    menu_bt:setBrightStyle(0)
                else
                    menu_plane:setVisible(true)
                    local disband_bt = menu_plane:getChildByName(CHILD_NAME_DISBAND_BT)

                    if isGoldGame == 0 and ZZMJ_TOTAL_ROUNDS == 0 then
                        disband_bt:setVisible(false)
                    end
                    menu_bt:setBrightStyle(1)
                end
            end
        end
    )

    menu_plane:setTouchEnabled(true)
    menu_plane:addTouchEventListener(
        function(sender,event)

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                
                if menu_plane:isVisible() then
                 menu_plane:setVisible(false)
                 menu_bt:setBrightStyle(0)
                end
            end
        end
    )

    disband_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.8)
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
    
	setting_bt:addTouchEventListener(
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
                if isGoldGame == 0 then
                    local quitRoom_action = function(sender,event)

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

                            require("hall.GameCommon"):showSettings(false)
                            sendHandle:quitRoom()
                        end
                    end
                    require("hall.GameCommon"):showSettings(true, false, true, true, quitRoom_action,"退出房间")    
                else--[[if isGoldGame == 1 then--]]
                    local disband_action = function(sender,event)

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

                            require("hall.GameCommon"):showSettings(false)

                            self:disbandGroup()

                        end
                    end

                    require("hall.GameCommon"):showSettings(true, false, true, true, disband_action)
                end
            end
        end
    )

	-- local group_owner = tonumber(USER_INFO["group_owner"])
	--只有房主才出现解散按钮
	-- if group_owner ~= USER_INFO["uid"] then
	-- 	close_room_bt:setVisible(false)
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
	local exit_bt = menu_ly:getChildByName(CHILD_NAME_EXIT_BT)
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
                sendHandle:quitRoom()
            end
        end
    )

    --邀请微信好友
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    share_bt:setVisible(false)
    if isiOSVerify then
        share_bt:setVisible(false)
    end
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
                paras["name"] = "济宁麻将，房号：" .. USER_INFO["invote_code"]
                paras["showType"] = 2;
                paras["url"] = appDownLoadAddress
                local shareLayer = require("hall.share.ShareLayer").new(paras)
                if shareLayer then
                    shareLayer:addTo(SCENENOW["scene"],9999999)
                end

                -- require("hall.common.ShareLayer"):showShareLayer(GameName .. "，房号：" .. invote_code, "", "url", share_content)
            end
        end
    )

    local record_bt = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(false)
    record_bt:addTouchEventListener(
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

            	if device.platform ~= "windows" then
            		require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])
            	end

            end
        end)

    local chat_bt = menu_ly:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(false)
    local function onface_click(sender)
        -- local posx=sender:getPosition().x*0.75
        -- local posy=sender:getPosition().y*0.75 
        local posx=sender:getPosition().x
        local posy=sender:getPosition().y
        local pos = cc.p(posx,posy)
        -- if sender.id ==1 then
        --     ddz_face_node:showFacePanle(pos)
        -- else
            ZZMJ_face_node:showTxtPanle(pos, 8)
        -- end

        --print("click faceui")
        
    end
    chat_bt:onClick(onface_click)

    -- 复制房间号按钮
    local btn_copyRoom = self._scene:getChildByName(CHILD_NAME_COPYROOM_BT)
    btn_copyRoom:addTouchEventListener(function (sender, event)
        -- body
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
                require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copyRoom, USER_INFO["invote_code"], GameName)
            end
    end)
    btn_copyRoom:setVisible(false)

    -- 准备按钮
    local btn_ready = self._scene:getChildByName(CHILD_NAME_READY_BT)
    btn_ready:addTouchEventListener(
        function (sender, event)
            -- body
            if event == TOUCH_EVENT_ENDED then
                sendHandle:readyNow()
            end
        end
    )
    btn_ready:setVisible(false)

    -- local btn_zhanji = self._scene:getChildByName(CHILD_NAME_ZHANJI)
    -- -- btn_zhanji:setVisible(false)
    -- btn_zhanji:addTouchEventListener(function (sender, event)
    --     -- body
    --      --触摸开始
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
    --         if ZZMJ_ENDING_DATA then
    --             isShowRecord = true
    --             require(TpackageName..".RoundEndingLayer"):showZhuaniao(ZZMJ_ENDING_DATA, false)
    --         else
    --             sendHandle:CLIENT_COMMAND_LAST_RECORD()
    --         end
    --     end
    -- end)

    local btn_buyCoin = self._scene:getChildByName("btn_buyCoin")

    btn_buyCoin:addTouchEventListener(function (sender, event)
        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            --sender:setScale(1.0)
            dump("-------- 22222222222 ----------")
            -- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
            require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
        end
    end)
    btn_buyCoin:setVisible(false)
    
    local lbVersion = ccui.Text:create()
    lbVersion:setString("1.0.3")
    lbVersion:setFontSize(18)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
    self._scene:addChild(lbVersion, 999)

end

function ZZMJScene:onEnter()

    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
    

    -- require("jiningmajiangji.result_effect_layout"):reset_niaocard_data({1,2,3,4,5,6,7,8,9,10
    --     9,10,11,12,13,14,
    --     9,10,11,12,13,14,
    --     -- 9,10,11,12,13,14,
    --     -- 9,10,11,12,13,14,
                                                          -- } ,{1,2})
    -- local function getDeviceInfo() 
       
    --    if not ZZMJ_GAME_PLANE  then
    --        return
    --    end
    --    if tolua.isnull(ZZMJ_GAME_PLANE)  then
    --        return
    --    end

    --    local device_info_plane = (ZZMJ_GAME_PLANE:getParent()):getChildByName("device_info_plane")
    --    local wifi_level        = device_info_plane:getChildByName("wifi_level")
    --    local battery_level     = device_info_plane:getChildByName("battery_level")
    --    local time              = device_info_plane:getChildByName("time")
       
    --    local wifi_level_num = 4  --00 -- 04
    --    if PINT_TIME~=nil then
    --       dump(PINT_TIME, "PINT_TIME")
    --       local ping = PINT_TIME
    --       if tonumber(ping)<=120 then
    --         wifi_level_num = 4
    --       elseif tonumber(ping)>120 and tonumber(ping)<=200 then
    --         wifi_level_num = 3
    --       elseif tonumber(ping)>200 and tonumber(ping)<=300 then
    --         wifi_level_num = 2
    --       elseif tonumber(ping)>300 and tonumber(ping)<=500 then
    --         wifi_level_num = 1
    --       elseif tonumber(ping)>500 then
    --         wifi_level_num = 0
    --       end
    --    end
    --    wifi_level:setTexture("jiningmajiangji/image/wifi_0"..wifi_level_num..".png")

    --    if device.platform == "ios" then

    --         local betteryPercent = cct.getDataForApp("getBetteryPercent", {}, "I")

    --         battery_level:setPercent(betteryPercent) 

    --    end

    --    local time_txt = os.date("%H:%M")
    --    time:setString(time_txt)

    -- end
    
    -- getDeviceInfo()
    -- local scheduler=cc.Director:getInstance():getScheduler()
    -- DeviceUpdater = scheduler:scheduleScriptFunc(getDeviceInfo,10,false)
    local device_info_plane = self._scene:getChildByName("device_info_plane") 
    require("hall.util.GameMenu"):addMenu(nil,device_info_plane,"济宁麻将")

    local room_lb_plane = self._scene:getChildByName("room_lb_plane")
	local room_lb = room_lb_plane:getChildByName(CHILD_NAME_ROOM_LB)
	room_lb:setString(USER_INFO["invote_code"])

	-- --dump(tableIdReload, "tableIdReload test")
    
    sendHandle:LoginGame()

	if tableIdReload == 0 then --非重登
        -- if require("hall.gameSettings"):getGameMode() == "group" then
        --             --todo
        --             --dump(tableIdReload, "tableIdReload test group")
            
        -- else
        --     display_scene("majiang/gameScenes")
        -- end

    else
        -- local pack_data = {}
        -- pack_data.tid = tableIdReload

        -- receiveHandle:SVR_GET_ROOM_OK(pack_data)
        tableIdReload = 0
    end
    

    
    -- require("jiningmajiangji.RoundEndingLayer"):show(self:testEnding())
    -- require("jiningmajiangji.operator.GamePlaneOperator"):beginPlayCard(CARD_PLAYERTYPE_MY)
    -- ------self:showLeaderLayer()
end

function ZZMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = ZZMJ_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if ZZMJ_USERINFO_TABLE[seatId .. ""] and ZZMJ_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = ZZMJ_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function ZZMJScene:showLeaderLayer()
    --local menu_ly = self._scene:getChildByName("menu_ly")
    --local record_bt = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    --require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

function ZZMJScene:ShowChatButton()
    local menu_ly = self._scene:getChildByName("menu_ly")
    local chat_bt = menu_ly:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

function ZZMJScene:ShowRecordButton()
    local menu_ly = self._scene:getChildByName("menu_ly")
	local record_bt = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(false)

    -- 
    local chat_bt = menu_ly:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)

    --语音按钮
    local voice_temp_bt = menu_ly:getChildByName(CHILD_NAME_VOICE_BT)
    -- require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x*0.75, voice_temp_bt:getPosition().y*0.75, -1)
    -- require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)

    ------self:showLeaderLayer()
end

--获取用户播放录音位置
function ZZMJScene:getPosforSeat(uid)
    return ZZMJ_ROOM.positionTable[uid .. ""]
end

--显示设置按钮（弃用）
function ZZMJScene:ShowSettingButton()
	-- local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

	-- setting_bt:setVisible(true)
end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function ZZMJScene:hideCloseRoomButton()
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)
	close_room_bt:setVisible(false)
end

function ZZMJScene:hideShareButton()
	local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
	share_bt:setVisible(false)
    -- 复制房间号按钮
    local btn_copy_room = self._scene:getChildByName(CHILD_NAME_COPYROOM_BT)
    btn_copy_room:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function ZZMJScene:disbandGroup()

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
                    if isiOSVerify or isGoldGame ~= 1 then
                        require("hall.GameTips"):showDisbandTips("解散房间", "ZZMJ_disbandGroup", 1, "是否解散房间？")
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "ZZMJ_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")
                    end

            	elseif data == 2 then
            		--开始组局
                    if isiOSVerify or isGoldGame ~= 1 then
                        require("hall.GameTips"):showDisbandTips("解散房间", "ZZMJ_disbandGroup", 1, "是否申请解散房间？")
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "ZZMJ_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
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
function ZZMJScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
    local s = self:getChildByName("faceUI")
    
    if tonumber(sex) >= 0 then
        s:showGetFace(uid, type, tonumber(sex), node_head, isLeft)
    end
end

function ZZMJScene:reConnect()
    dump("test 1123 begin")
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    sendHandle:LoginGame()
end

function ZZMJScene:showInviteCode()
    local room_lb_plane = self._scene:getChildByName("room_lb_plane")
    local room_lb = room_lb_plane:getChildByName(CHILD_NAME_ROOM_LB)
    room_lb:setString(USER_INFO["invote_code"])
end

function ZZMJScene:hideInviteCode()
    local room_lb_plane = self._scene:getChildByName("room_lb_plane")
    -- local room_lb = room_lb_plane:getChildByName(CHILD_NAME_ROOM_LB)
    -- room_lb:setString(USER_INFO["invote_code"])
    room_lb_plane:setVisible(false)
end

function ZZMJScene:showCopyInviteBtn(isShow)
    -- body
    -- 复制房间号按钮
    local btn_copyRoom = self._scene:getChildByName(CHILD_NAME_COPYROOM_BT)
    btn_copyRoom:addTouchEventListener(function (sender, event)
        -- body
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
                require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copyRoom, USER_INFO["invote_code"], GameName)
            end
    end)
    btn_copyRoom:setVisible(false)

    --邀请微信好友
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    share_bt:setVisible(isShow)
    if isiOSVerify then
        share_bt:setVisible(false)
    end
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
                paras["name"] = "济宁麻将，房号：" .. USER_INFO["invote_code"]
                paras["showType"] = 2;
                paras["url"] = appDownLoadAddress
                local shareLayer = require("hall.share.ShareLayer").new(paras)
                if shareLayer then
                    shareLayer:addTo(SCENENOW["scene"],9999999)
                end

                -- require("hall.common.ShareLayer"):showShareLayer(GameName .. "，房号：" .. invote_code, "", "url", share_content)
            end
        end
    )

end


function ZZMJScene:showBtnByUserStatus(_type)
    --[[    _type：
                    ready，全隐藏
                    sit, 显示站起和准备按钮
                    stand, 显示坐下按钮]]
    -- 站起按钮
    --local btn_stand = self._scene:getChildByName("btn_stand")
    --[[    btn_stand:addTouchEventListener(function (sender, event)

            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                sendHandle:standNow()
            end
        end)]]

    -- 坐下按钮
    --local btn_sit = self._scene:getChildByName("btn_sit")
    --[[    btn_sit:addTouchEventListener(function (sender, event)
            if event == TOUCH_EVENT_ENDED then
                sendHandle:sitNow(-1)
            end
        end)]]

    -- 准备按钮
    local btn_ready = self._scene:getChildByName(CHILD_NAME_READY_BT)

    --[[    btn_ready:addTouchEventListener(function (sender, event)
            dump("-------- btn_ready -------")
            if event == TOUCH_EVENT_ENDED then
                sendHandle:readyNow()
            end
        end)]]

    -- 充值按钮
    local btn_buyCoin = self._scene:getChildByName("btn_buyCoin")
    btn_buyCoin:addTouchEventListener(function (sender, event)
        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            --sender:setScale(1.0)
            dump("-------- 22222222222 ----------")
            -- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
            require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
        end
    end)
    btn_buyCoin:setVisible(false)
    --btn_buyCoin:setVisible(true)
    if not _type then

--[[        btn_stand:setVisible(false)
        btn_sit:setVisible(false)--]]
        btn_ready:setVisible(false)
        btn_buyCoin:setVisible(false)

    elseif _type == "ready" then
--[[
        btn_stand:setVisible(false)
        btn_sit:setVisible(false)--]]
        btn_ready:setVisible(false)

    elseif _type == "sit" then

--[[        btn_sit:setVisible(false)
        --btn_stand:setVisible(true)
        --先不做围观
        btn_stand:setVisible(false)--]]
        btn_ready:setVisible(true)
        dump(isGoldGame, "--- showBtnByUserStatus ---- isGoldGame")
        if isGoldGame == 0 then
            btn_buyCoin:setVisible(true)
        else
            btn_buyCoin:setVisible(false)
        end

    elseif _type == "stand" then
--[[
        btn_stand:setVisible(false)
        --btn_sit:setVisible(true)
        --先不做围观
        btn_sit:setVisible(false)--]]
        btn_ready:setVisible(false)
        btn_buyCoin:setVisible(false)

    end
end

function ZZMJScene:showGameConfig(config_str)
    -- local remark_lb = YKMJ_GAME_PLANE:getChildByName("remark_lb")
    -- remark_lb:setString(config_str)
    gameConfigTable = {{["游戏名"]="济宁麻将", ["底分"] = BASE_CHIP}, {["特殊玩法"] = config_str}}
    --table.insert(gameConfigTable, )

end

return ZZMJScene