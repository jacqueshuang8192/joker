require("gxlz_majiang.globle.GXLZData")
require("gxlz_majiang.globle.GXLZDefine")

D3_OPERATOR = require("hall.3DMahjongCard.ShowOperator")

local gamePlaneOperator = require("gxlz_majiang.operator.GamePlaneOperator")
local manyouPlaneOperator = require("gxlz_majiang.operator.ManyouPlaneOperator")

local PROTOCOL = import("gxlz_majiang.handle.GXLZProtocol")
local sendHandle = require("gxlz_majiang.handle.GXLZSendHandle")
local receiveHandle = require("gxlz_majiang.handle.GXLZReceiveHandle")

local GPSShowLayer = require("hall.GPSShowLayer")

local GXLZ_face=require("hall.FaceUI.faceUI")
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
local CHILD_NAME_READY_BT = "ready_bt"
local CHILD_NAME_REMARK = "remark"
local CHILD_NAME_GAME_LB = "game_lb"
local CHL_TG = "take_bg"
local GXLZScene = class("GXLZScene", function()
		return display:newScene()
	end)

local CHILD_NAME_ROOM_LB = "room_lb"

function GXLZScene:ctor()
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())

    
	self._scene = cc.CSLoader:createNode("gxlz_majiang/GameScene.csb"):addTo(self)


    SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
    SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height
    GXLZ_GAME_TG =   self._scene:getChildByName("take_bg")
    self:_initUI()

	GXLZ_GAME_PLANE = self._scene:getChildByName("game_plane")

    --文字聊天模块
    local GXLZ_face_node = GXLZ_face.new();
    GXLZ_face_node:setHandle(sendHandle)
    self._scene:addChild(GXLZ_face_node, 9999)
    GXLZ_face_node:setName("faceUI")

    dump(GXLZ_GAME_PLANE, "gxlz_majiang test")

	GXLZ_CONTROLLER = require("gxlz_majiang.GameController")

	gamePlaneOperator:init()

    D3_OPERATOR:init(GXLZ_CONTROLLER,nil,nil,nil,GXLZ_GAME_PLANE)

	GXLZ_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	manyouPlaneOperator:init()

    local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

    local device_info_plane = self._scene:getChildByName("device_info_plane")
    -- device_info_plane:setVisible(false)

    

    local menu_ly  = self._scene:getChildByName("menu_ly")
    local menu_plane = menu_ly:getChildByName(CHILD_NAME_MENU_PLANE) 
    local menu_bt = menu_ly:getChildByName(CHILD_NAME_MENU_BT)

    local setting_bt = menu_plane:getChildByName(CHILD_NAME_SETTING_BT)
    local disband_bt = menu_plane:getChildByName(CHILD_NAME_DISBAND_BT)
    
    local instruction_bt = menu_ly:getChildByName("instruction_bt")
    local remark_lb = GXLZ_GAME_PLANE:getChildByName("remark_lb")
    local remark_img = GXLZ_GAME_PLANE:getChildByName("remark_img")
    local exit_bt = menu_ly:getChildByName(CHILD_NAME_EXIT_BT)
    instruction_bt:setPosition(cc.p(exit_bt:getPositionX(),exit_bt:getPositionY()))
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
               -- dump(bit.band(91, CONTROL_TYPE_GANG),"hu ---44")
                if  isOpenControl == true then
                    local function CLI_SEND_TEST_CARD_FUNC(card)

                        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_TEST_CARD)
                        :setParameter("card", card)
                        :build()
                        bm.server:send(pack)
                    end

                    require("hall.scene.verify.testConfig"):chooseCard({1,2,3,4,5,6,7,8,9,
                        17,18,19,20,21,22,23,24,25,
                        33,34,35,36,37,38,39,40,41,49,50,51,52,
                        65,66,67},"gxlz_majiang/image/card/",CLI_SEND_TEST_CARD_FUNC)

                else
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
                
                -- if menu_plane:isVisible() then
                --  menu_plane:setVisible(false)
                --  menu_bt:setBrightStyle(0)
                -- else 
                --  menu_plane:setVisible(true)
                --  menu_bt:setBrightStyle(1)
                -- end
                self:loadMoreFuncLayer()
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

                require("hall.GameCommon"):showSettings(true,false,true,true,function(sender, event)
                        --     --触摸开始
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
                    end)

            end
        end
    )

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
                paras["name"] = "广西柳州，房号：" .. USER_INFO["invote_code"]
                paras["showType"] = 2;
                paras["url"] = appDownLoadAddress
                local shareLayer = require("hall.share.ShareLayer").new(paras)
                if shareLayer then
                    shareLayer:addTo(SCENENOW["scene"],9999999)
                end


                -- local   config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
                -- local   share_content = ""
                -- for k,v in pairs(config_arr) do
                --     if v ~= "" then
                --         share_content = share_content .. v .. ","
                --     end
                -- end
                -- share_content = string.sub(share_content, 1, string.len(share_content) - 1)
                -- require("hall.common.ShareLayer"):showShareLayer(GXLZ_PRV_GAME_NAME .. "，房号：" .. USER_INFO["invote_code"], appDownLoadAddress, "url", share_content)
            end
        end
    )
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
                    --todo
                    require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])
                end
            end
        end
        )

    local chat_bt = menu_ly:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(false)
    local function onface_click(sender)
        -- local posx=sender:getPosition().x    --*0.75
        -- local posy=sender:getPosition().y    --*0.75 
        -- local pos = cc.p(posx,posy)
        -- if sender.id ==1 then
        --     ddz_face_node:showFacePanle(pos)
        -- else
            -- GXLZ_face_node:showTxtPanle(pos, 8)
        -- end

        --print("click faceui")\

         self:loadGameMsgLayer()
        
    end
    chat_bt:onClick(onface_click)
    
    local lbVersion = ccui.Text:create()
    lbVersion:setString("1.0.7")
    lbVersion:setFontSize(18)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, lbVersion:getContentSize().height / 2))
    self._scene:addChild(lbVersion, 10000)

    self:setGameSetting()

end
function GXLZScene:showBtnByUserStatus(_type)
    local btn_ready = self._scene:getChildByName(CHILD_NAME_READY_BT)
    if _type == 1 then
        btn_ready:setVisible(false)
    else
        btn_ready:setVisible(true)
    end
end
function GXLZScene:_initUI()
    -- local bg = self._scene:getChildByName("bg")
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
    GXLZ_GAME_TG:setVisible(false)
    GXLZ_GAME_TG:getChildByName("btn_cl"):addTouchEventListener(function(sender,event)
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
    self._scene:getChildByName("btn_tg"):addTouchEventListener(function(sender,event)
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
            sendHandle:CLI_ROBOT(1)
        end
    end)


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
           for k,v in pairs(GXLZ_USERINFO_TABLE) do
               table.insert(temptab,v)
           end
           gpsLayer:setInfo(temptab)

        end
    end)

end

function GXLZScene:showGPSButton()
    dump(GXLZ_USERINFO_TABLE,"showGPSButton--GXLZ_USERINFO_TABLE")
    local temptab = {}
    for k,v in pairs(GXLZ_USERINFO_TABLE) do
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

function GXLZScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
end

function GXLZScene:SendHandle()
    --chatView:hideView()
end

function GXLZScene:TgState(flag)
    dump(flag,"flag==")
    GXLZ_GAME_TG:setVisible(flag)
end

-- --隐藏语音和文字聊天
-- function GXLZScene:hidechatView()
--     chatView:hideView()
-- end
function GXLZScene:reConnect()
    dump("GXLZScene:reConnect")

    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function GXLZScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    sendHandle:LoginGame(USER_INFO["GroupLevel"])
    --require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function GXLZScene:onEnter()
    
	local function getDeviceInfo() 
        
       if tolua.isnull(GXLZ_GAME_PLANE)  then
           return
       end

       local device_info_plane = (GXLZ_GAME_PLANE:getParent()):getChildByName("device_info_plane")
       local wifi_level        = device_info_plane:getChildByName("wifi_level")
       local battery_level     = device_info_plane:getChildByName("battery_level")
       local time              = device_info_plane:getChildByName("time")
       
       local wifi_level_num = 4  --00 -- 04
       dump(PINT_TIME, "PINT_TIME")
       
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

       wifi_level:setTexture("gxlz_majiang/image/wifi_0"..wifi_level_num..".png")

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
    game_lb:setString(GXLZ_PRV_GAME_NAME)
    local remarkSize = cc.size(game_lb:getContentSize().width + 50, remark_frame:getContentSize().height)
    remark_frame:setSize(remarkSize)
    game_lb:setPosition(cc.p(remarkSize.width / 2, remarkSize.height / 2))
end

-- function GXLZScene:setVoiceBtImg( flag )
--     local voice_bt = self.chat_plane:getChildByName(CHILD_NAME_VOICE_BT)

--     local img = "gxlz_majiang/image/record_bt.png"
    
--     if flag == 1 then
--         --todo
--         img = "gxlz_majiang/image/record_bt1.png"
--     end

--     voice_bt:loadTexture(img)
-- end

function GXLZScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = GXLZ_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if GXLZ_USERINFO_TABLE[seatId .. ""] and GXLZ_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = GXLZ_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function GXLZScene:showLeaderLayer()
    local menu_ly = self._scene:getChildByName("menu_ly")
    local record_bt = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    -- require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

function GXLZScene:ShowChatButton()
    local menu_ly = self._scene:getChildByName("menu_ly")
    local chat_bt = menu_ly:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

function GXLZScene:ShowRecordButton()
    local menu_ly = self._scene:getChildByName("menu_ly")
    --local record_bt = menu_ly:getChildByName(CHILD_NAME_RECORD_BT)
    --record_bt:setVisible(false)

     --local voice_temp_bt = menu_ly:getChildByName(CHILD_NAME_VOICE_BT)


    local btn_voice = menu_ly:getChildByName(CHILD_NAME_VOICE_BT)
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

    -- require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)
    -- -- --*0.75
    -- -- self:showLeaderLayer()
    -- local function onface_click(sender)
    -- require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)
    --     --通知本地播放录音
    --     local arr = {}
    --     arr["url"] = msg.url
    --     cct.getDateForApp("playVoice", arr, "V")
    -- end
    -- voice_temp_bt:onClick(onface_click)
end

--获取用户播放录音位置
function GXLZScene:getPosforSeat(uid)
    return GXLZ_ROOM.positionTable[uid .. ""]
end

--显示设置按钮（弃用）
function GXLZScene:ShowSettingButton()
    -- local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

    -- setting_bt:setVisible(true)
end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function GXLZScene:hideCloseRoomButton()
    local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)
    close_room_bt:setVisible(false)
end

function GXLZScene:hideShareButton()
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    share_bt:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function GXLZScene:disbandGroup()

    local function disband()
        GXLZ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
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
--function GXLZScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
--    local s = self:getChildByName("faceUI")
--
--    if tonumber(sex) >= 0 then
--        s:showGetFace(uid, type, tonumber(sex), node_head, isLeft)
--    end
--end

function GXLZScene:test()
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
	dump(CONTROL_TYPE_HU, "controlType test")
	dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_PENG)
	dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_CHI)
	dump(controlType, "controlType test")
	playerPlaneOperator:showControlPlane(self.myPlane, controlType)
end

function GXLZScene:testEnding()

	GXLZ_USERINFO_TABLE[0] = {}
	GXLZ_USERINFO_TABLE[0].uid = 723
	GXLZ_USERINFO_TABLE[0].nick = "zh"

	GXLZ_USERINFO_TABLE[1] = GXLZ_USERINFO_TABLE[0]
	GXLZ_USERINFO_TABLE[2] = GXLZ_USERINFO_TABLE[0]
	GXLZ_USERINFO_TABLE[3] = GXLZ_USERINFO_TABLE[0]


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
function GXLZScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
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

function GXLZScene:showInviteCode()
    local room_lb_plane = self._scene:getChildByName("room_lb_plane")
    local room_lb = room_lb_plane:getChildByName(CHILD_NAME_ROOM_LB)
    room_lb:setString(USER_INFO["invote_code"])
end


function GXLZScene:setGameSetting()
    GXLZScene.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self:addChild(GXLZScene.roomCommonLayer, 15)
    GXLZScene.roomCommonLayer:setTouchSwallowEnabled(false)
    GXLZScene.roomCommonLayer:setVisible(false)
    self:loadGameMsgLayer()
end

function GXLZScene:showGameSetting()
    self:setGameSetting()
    self:loadMoreFuncLayer()
end
function GXLZScene:addVoiceRecordEvent(btn_voice)
    print("voice")
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        print("voice22")
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
    end
end
function GXLZScene:disbandRoom()
    sendHandle:C2G_CMD_DISSOLVE_ROOM()
end

function GXLZScene:rejectDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function GXLZScene:agreeDisband()
    sendHandle:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function GXLZScene:getToDisbandFuncs()
    local data = {}
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandRoom)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
    return data
end

function GXLZScene:loadMoreFuncLayer()
    if tolua.isnull(GXLZScene.moreFuncLayer) then
        GXLZScene.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(GXLZScene.moreFuncLayer, 99)
    else
        GXLZScene.moreFuncLayer:setVisible(true)
        GXLZScene.moreFuncLayer:showAni()
    end

end

function GXLZScene:loadGameMsgLayer()
    if tolua.isnull(GXLZScene.gameMsgLayer) then
        GXLZScene.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(GXLZScene.gameMsgLayer, 99999)
        GXLZScene.gameMsgLayer:setVisible(false)
    else
        GXLZScene.gameMsgLayer:setVisible(true)
        GXLZScene.gameMsgLayer:showContentByType(1)
    end
end

function GXLZScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end
function GXLZScene:quitRoom()
    sendHandle:CLI_QUIT_ROOM()
end

function GXLZScene:sendFaceByIdx(id)
    sendHandle:CLI_MSG_FACE(id)
end


return GXLZScene