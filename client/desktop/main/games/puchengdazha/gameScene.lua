require("puchengdazha.ddzDefine")
local ddzServer = import("puchengdazha.ddzServer")
local ddzHandle = import("puchengdazha.ddzHandle")
local PROTOCOL = require("puchengdazha.ddz_PROTOCOL")
local DDZgameScene = class("DDZgameScene", function()
    return display.newScene()
end)

--添加复制房号功能，放大牌，添加剩余牌数显示，带控牌显示
function DDZgameScene:initData(_type)
    decidecard = nil
    if  _type == "init" then
        --记录房间用户信息

        TpackageName = "puchengdazha"
        
        require("hall.view.voicePlayView.voiceListView"):clearList()

        -- Author:张鸿鹏
        -- Date: 2017-09-05 17:15:13
        GAME_VERSION = "1.0.18"

        PLAY_MODE = 1  --玩法，1为抢地主模式，2为经典抢分模式
        GAME_MODE = 1  --0为金币场，1为房卡场，游戏模式
        GAME_TYPE = 2  --1为3人斗地主1副牌，2为4人斗地主2副牌
    
        GAME_NAME = "浦城打炸"
        FARMER_CARDNUM = 26  --农民的起始牌数量
        LANDLORD_CARDNUM = 26 --地主的起始牌数量
        MAX_CARD_TYPE = 16   
        PLAYERNUM = 4 --玩家人数

        CARD_PLAYERTYPE_MY = 1   --自己
        CARD_PLAYERTYPE_LEFT = 4   --左侧玩家
        CARD_PLAYERTYPE_RIGHT = 2   --右侧玩家
        CARD_PLAYERTYPE_TOP = 3   --对面玩家

        --GAME_STATE
        STATUS_STOP = 0        --停止游戏状态（包含回合与回合之间的停止
        STATUS_LAND_SCORE = 1  --叫地主叫分状态
        STATUS_PLAY  = 2     --正在游戏状态
        STATUS_RESTART = 3    --重新发牌开始状态

        -- SCREEN_WIDTH = 1280  --屏幕尺寸
        -- SCREEN_HEIGHT = 720

        OUT_CARD_TIMEOUT = 30    --出牌超时时间

        -- showDumpData = false   --是否开启DEBUG信息
        DDZ_USERINFO_TABLE  = {}
        initialChip = 0

        DDZ_SEAT_TABLE = {}
        SEAT2USERID = {}
        PLAYERTYPE2UID = {}
        PLAYER_HEADS_POSITION_TABLE = {}

        REMAINCARDS = {}
        for seatId = 0,PLAYERNUM -1 do 
            REMAINCARDS[seatId] = FARMER_CARDNUM
        end

        MY_SEAT_ID = -1
        mustOutCard = true  
        KIND_ERROR = false

        playerOutBombCount = playerOutBombCount or {}

        USERS_READY_STATE = {}

        has_send_apply = false
        has_send_cancel = false

        --出完牌玩家id
        winnerUid = 0

        tbPlayCardInfo = {}

        LandLordSeatId = 1   --地主座位
        LandLordSeatIdBang = -1
        mingpaiState = 0 --明牌场标记
        iTotalTimes = 0

        call_bet_first = 0

        AUTO_OUT_CARD = false

        RELATIVE_SEAT_ID = 0

        LocaArrayByPlayerType = {}

        DDZ_ROUND = 1

        DDZ_TOTAL_ROUND = 1

        FARMER_BONUS_CARDS = {}

        PLAYER_HEADS_TABLE = {}

        PLAYER_HEADS_POSITION_TABLE = {}

        bonus_array = {[0] = 0,[1] = 4,
                        [2] = 0,[3] = 4,
                        [4] = 4,[5] = 4,
                        [6] = 0,[7] = 8,
                        [8] = 4,[9] = 14,
                        [10] = 0,[11] = 0,
                        [12] = 0,[13] = 999}

        SHOW_GAME_CONFIG = { ["地主4张炸弹3连拖 无奖"] = true,
                            ["地主4张炸弹3连拖 1分"] = true,
                            ["地主4张炸弹3连拖 2分"] = true,
                            ["明牌2分"] = true,
                            ["5张炸弹2连拖有奖"] = true,
                            ["7张炸弹2分"] = true,
                            ["封顶8分"] = true,
                    }

        GAME_CONFIG = {
                    }


        --通过接口传来的字符串获取具体配置信息
        if type(USER_INFO["gameConfig"]) =="string" then

            if string.find(USER_INFO["gameConfig"],"不显示剩余牌数") then
                GAME_CONFIG["不显示剩余牌数"] = true 
            end
        end

        PartnerUid = nil
        PartnerCards = nil

    elseif _type == "clearGameData" then
        FARMER_BONUS_CARDS = {}
        PartnerUid = nil
        PartnerCards = nil
        playerOutBombCount = {}

        for seatId in pairs(REMAINCARDS) do
            REMAINCARDS[seatId] = FARMER_CARDNUM
        end

        tbPlayCardInfo["last_cards"] = nil
        tbPlayCardInfo["card_type"]  = nil

        iTotalTimes = 0
        call_bet_first = 0

    elseif _type == "release" then

        require("hall.view.voicePlayView.voiceListView"):clearList()

        dump(collectgarbage("count"),"collectgarbagecount2") --用于检测内存占用
        
        PLAYER_HEADS_TABLE = nil

        PLAYER_HEADS_POSITION_TABLE = nil

        USERS_READY_STATE = nil

        GAME_CONFIG = nil
        TpackageName = nil
        DDZ_ROUND = nil

        DDZ_TOTAL_ROUND = nil

        BASE_CARD_NUM = nil
        LocaArrayByPlayerType = nil

        DDZ_SEAT_TABLE = nil
        SEAT2USERID = nil
        PLAYERTYPE2UID = nil
        PLAYER_HEADS_POSITION_TABLE = nil

        REMAINCARDS = nil
        mustOutCard = nil  
        KIND_ERROR = nil
        playerOutBombCount = nil

        has_send_apply = nil
        has_send_cancel = nil
        winnerUid = nil
        tbPlayCardInfo = nil

        LandLordSeatId = nil   --地主座位
        mingpaiState = nil --明牌场标记
        iTotalTimes = nil
        tbSeatCoin = nil
        call_bet_first = nil

        AUTO_OUT_CARD = nil
        PartnerUid = nil
        PartnerCards = nil

        collectgarbage("collect")
        dump(collectgarbage("count"),"collectgarbagecount3")  --用于检测内存占用
    end
    
end

function DDZgameScene:ctor()

    --DESIGN_SCREEN_HEIGHT = 1280
    --DESIGN_SCREEN_WIDTH = 720
    --SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getFrameSize().width
    --SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getFrameSize().height
    --local scaleY=CONFIG_WIN_HEIGHT/CONFIG_DESIGN_HEIGHT
    --cc.Director:getInstance():getOpenGLView():setFrameSize(CONFIG_WIN_WIDTH, CONFIG_WIN_HEIGHT)
    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_WIN_WIDTH/scaleY, CONFIG_DESIGN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)--cc.ResolutionPolicy.SHOW_ALL
    --Rect rect = Director::getInstance()->getOpenGLView()->getVisibleRect();
    dump(collectgarbage("count"),"collectgarbagecount1") --用于检测内存占用
    self:initData("init")
    
    -- cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)



    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())

    self._scene = cc.CSLoader:createNode("puchengdazha/GameScene.csb"):addTo(self)
    visibleSize = cc.Director:getInstance():getVisibleSize().width
    self.bg_select_index = 1

    -- DESIGN_SCREEN_WIDTH  = 1280
    -- DESIGN_SCREEN_HEIGHT = 720

    --room_bg.jpg
    --room_bg.png

    -- roomBackGround:loadTexture("")
    GameUtils.setNodeNameBindObj(self._scene)
    self:_initUI()
    self:setGameSetting()
    -- self:changeBgImg()

     local w = cc.Director:getInstance():getOpenGLView():getFrameSize().width
    dump(w,"getFrameSize===")
    --local wth = w/2 - self._scene.layout_ui:getContentSize().width/2
    --self._scene.layout_ui:setPositionX(wth)
    --self._scene.layout_ui:getChildByName("btn_ready"):setPositionX(wth)

    display.addSpriteFrames("puchengdazha/images/Game/cards/cards.plist", "puchengdazha/images/Game/cards/cards.png")
    audio.preloadMusic("puchengdazha/audio/Audio_Game_Back.mp3")
    
    cardScene = self._scene
    
    --前端版本号
    local   lbVersion = cc.Label:createWithSystemFont(GAME_VERSION,"Arial",18)
            lbVersion:setColor(cc.c3b(125, 125, 125))
            lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, self._scene:getContentSize().height -lbVersion:getContentSize().height / 2))
            self._scene:addChild(lbVersion, 999)

    local   layer_top = self._scene:getChildByName("play_top")
    local   card_record_plane = self._scene:getChildByName("card_record_plane"):setVisible(false)

    require("puchengdazha.operator.GamePlaneOperator"):init()
    
    local   btn_voice_history = layer_top:getChildByName("btn_voice_history")
    --玩法说明
    local   instruction_bt = layer_top:getChildByName("instruction_bt")

    local   remark_lb = self._scene:getChildByName("remark_lb")
    local   remark_img = self._scene:getChildByName("remark_img")

    local   remark_lb_desktop_up = self._scene:getChildByName("remark_lb_desktop_up"):setVisible(false)
    local   remark_lb_desktop_down = self._scene:getChildByName("remark_lb_desktop_down"):setVisible(false)
            -- remark_lb_desktop_up:setString(USER_INFO["gameConfig"])
            -- remark_lb_desktop_down:setString("")

    local   upConfigCount = 0
    local   upConfig = ""
    local   downConfig = ""

    if next(GAME_CONFIG) then

        for configName,v in pairs(GAME_CONFIG) do
            if v == true and SHOW_GAME_CONFIG[configName] then
                
                if  upConfigCount <= 2 then
                    upConfigCount = upConfigCount + 1
                    upConfig = upConfig .. "  " ..configName
                    -- remark_lb_desktop_up:setString(upConfig)
                else
                    downConfig = downConfig .."  " .. configName
                    -- remark_lb_desktop_down:setString(downConfig)
                end
            end
        end
    end
    
    local   voice_record_plane = self._scene:getChildByName("voice_record_plane")
            voice_record_plane:setVisible(false)

    --邀请微信好友
    local   invite_ly = self._scene:getChildByName("invite_ly")

    local   btn_share = invite_ly:getChildByName("btn_share")
    local   btn_copy_room_id = invite_ly:getChildByName("btn_copy_room_id")
    
    require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copy_room_id,USER_INFO["invote_code"],GAME_NAME,"四人洼地菌瓦")

    --返回大厅
    local   btn_exit   = layer_top:getChildByName("btn_exit"):setVisible(false)
    --设置按钮
    local   btnSetting   = layer_top:getChildByName("btn_setting")

    local   remain_rounds_count_plane   = self._scene:getChildByName("remain_rounds_count_plane")

    local   menuButtonTouchEvent = function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then

                require("hall.GameCommon"):playEffectSound("puchengdazha/audio/Audio_Button_Click.mp3")
                
                local   stSmall = cc.ScaleTo:create(0.1, 0.8)
                local   stNormal = cc.ScaleTo:create(0.1, 1)
                local   sq = cc.Sequence:create(stSmall, stNormal)
                sender:runAction(sq)

                if sender ==  remark_img or sender ==  instruction_bt then
                else
                    -- sender:setScale(0.9)
                end
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                local   stBig = cc.ScaleTo:create(0.1,1.3)
                local   stNormal = cc.ScaleTo:create(0.1,1)
                local   sq = cc.Sequence:create(stBig,stNormal)
                sender:runAction(sq)

                if sender ==  remark_img or sender ==  instruction_bt then
                else
                    -- sender:setScale(1.0)
                end
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                   
                if  sender ==  btn_share then
                
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
                    paras["name"] = "蒲城炸弹，房号：" .. USER_INFO["invote_code"]
                    paras["showType"] = 2;
                    paras["url"] = appDownLoadAddress
                    local shareLayer = require("hall.share.ShareLayer").new(paras)
                    if shareLayer then
                        shareLayer:addTo(SCENENOW["scene"],9999999)
                    end


                elseif sender == btn_voice_history then
                    
                    self:showVoiceRecord()

                elseif sender ==  btn_exit then

                    require("hall.GameTips"):showTips("提示", "quitRoom", 1, "确定要退出房间么？",_,self.quitRoom) 
                
                elseif sender ==  remark_img or sender ==  instruction_bt then
                    if remark_lb:isVisible() then
                       remark_lb:setVisible(false)
                       remark_img:setVisible(false)           
                    else
                       remark_img:setVisible(true)
                       remark_lb:setVisible(true)
                    end
                    
                --设置
                elseif sender == btnSetting then
                    if GAME_STATE == STATUS_STOP then
                        self:loadMoreFuncLayer()
                    else
                        require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始必须打完本局！")
                    end

                end

            end
    end
    
    instruction_bt:addTouchEventListener(menuButtonTouchEvent)  
    remain_rounds_count_plane:addTouchEventListener(menuButtonTouchEvent)  

    remark_lb:setString(GAME_NAME .. " : ".. USER_INFO["gameConfig"])

    remark_img.noScale = true
    remark_img:addTouchEventListener(menuButtonTouchEvent)
   
    btn_voice_history:addTouchEventListener(menuButtonTouchEvent)
    btn_share:addTouchEventListener(menuButtonTouchEvent)

    -- btn_exit:addTouchEventListener(menuButtonTouchEvent)
    btnSetting:addTouchEventListener(menuButtonTouchEvent)   

    --托管      
    local   btn_auto = layer_top:getChildByName("btn_auto")
            :setColor(cc.c3b(140,140,140))
            :setVisible(false)
            
            btn_auto:addTouchEventListener(function(sender,event)
                if  event == TOUCH_EVENT_BEGAN then
                    if  AUTO_OUT_CARD == true then
                        AUTO_OUT_CARD = false
                        sender:setColor(cc.c3b(140,140,140))
                    else
                        AUTO_OUT_CARD = true
                        sender:setColor(cc.c3b(255,255,255))
                    end
                end
            end)
            

    -- if device.platform == "windows" then
    --     btn_auto:setVisible(true)
    -- end

    local   lbVersion = cc.Label:createWithSystemFont(round_info,"Arial",40)
            lbVersion:setColor(cc.c3b(255, 255, 0))
            lbVersion:setPosition(cc.p(SCENENOW["scene"]:getContentSize().width - lbVersion:getContentSize().width / 2 - 40, SCENENOW["scene"]:getContentSize().height -lbVersion:getContentSize().height / 2 - 30))
            SCENENOW["scene"]:addChild(lbVersion, 999)
    -----------------------------文字表情-----------------------------
    local   ddz_face= require("hall.FaceUI.faceUI") --require("puchengdazha.faceUI.faceUI") 
    
    local   ddz_face_node=ddz_face.new()
            ddz_face_node:setHandle(ddzServer)
            self:addChild(ddz_face_node, 9999)
            ddz_face_node:setName("faceUI")

    local chat_bt = cardScene:getChildByName("btn_chat"):setVisible(false)
    local function onface_click(sender)
        -- local posx=sender:getPosition().x    --*0.75
        -- local posy=sender:getPosition().y    --*0.75 
        -- local pos = cc.p(posx,posy)
        -- ddz_face_node:showTxtPanle(pos, 8)
        self:loadGameMsgLayer()
    end

    chat_bt:onClick(onface_click)

    self:init_keyboard()
end

function DDZgameScene:init_keyboard()

    local function onKeyPressed(keyCode, event)

        print(keyCode, "RRRRRRRRRRRRRRRRRRRRRRRRRR我看看改了没1111")
        if keyCode == 47 then
            --清除游戏的缓存
            for filepath in pairs(package.loaded) do
                if string.find(filepath, "puchengdazha") then
                    package.loaded[filepath] = nil
                end
            end
            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
        elseif keyCode == 124 then
            ddzHandle:showRoundRes()
        end

    end

    local function onKeyReleased(keyCode, event)
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function DDZgameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer, 99999999)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function DDZgameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    -- data.sendEditHand = handler(self, self.sendEditTxt)
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function DDZgameScene:sendFaceByIdx(id)
    print("sendFaceMsg --------------------------", id)
    ddzServer:CLI_MSG_FACE(id)
end

function DDZgameScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH/CONFIG_DESIGN_WIDTH)*(disHeight/(frameHeight or 0))
    -- return ((frameHeight or 0)/(disHeight or 1))*(CONFIG_DESIGN_WIDTH/CONFIG_WIN_WIDTH)
end

function DDZgameScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("roomBackGround")
        local precent = self:_getScaleParam2()
        -- if bg then
        --     bg:setScaleX(bg:getScale()*precent)
         
        -- end
        --btn_chat.png
        --btn_voice.png
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
    end
end

function DDZgameScene:setGameSetting()
    self.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self:addChild(self.roomCommonLayer, 15)
    self.roomCommonLayer:setTouchSwallowEnabled(false)
    self.roomCommonLayer:setVisible(false)
    self:loadGameMsgLayer()
end



function DDZgameScene:onEnter()
              
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end
    
    ddzServer:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"] , groupId)
    HEART_BEAT_TID = USER_INFO["tid"]

    local device_info_plane = self._scene:getChildByName("device_info_plane") 
    require("hall.util.GameMenu"):addMenu(nil,device_info_plane,"四人斗地主")
    require("hall.GameCommon"):playEffectMusic("puchengdazha/audio/Audio_Game_Back.mp3",true)
 
    local btn_voice = cardScene:getChildByName("btn_voice"):setVisible(false)
    local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())
    
    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")

    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(btn_voice,999)
        btn_voice:setVisible(false)
    else

        VoiceRecordView:showView(voice_bt_worldpoint.x,voice_bt_worldpoint.y,999)
        btn_voice:setVisible(false)
    end

    -- self:sendPeiPaiToSever()
end

function DDZgameScene:showGameSetting()
    print("=====NiuNiuGameScene:showGameSetting=====")
    print("=====NiuNiuGameScene:showGameSetting=====")
    self:setGameSetting()

    self:loadMoreFuncLayer()

end

function DDZgameScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer, 15)
        -- g_roomCommonLayer = self.moreFuncLayer
    else
        if 0 == SCENENOW["scene"].GameRound then
            self.moreFuncLayer.btnDisbandRoom:setVisible(false)
        else
            self.moreFuncLayer.btnDisbandRoom:setVisible(true)
        end
        self.moreFuncLayer:setVisible(true)
        self.moreFuncLayer:showAni()
    end

    if 0 == SCENENOW["scene"].GameRound then
        self.moreFuncLayer.btnDisbandRoom:setVisible(false)
    else
        self.moreFuncLayer.btnDisbandRoom:setVisible(true)
    end
end

function DDZgameScene:getToDisbandFuncs()
    local data = {} 
    data.quitRoomHandler = handler(self, self.quitRoom)
    data.disbandRoomHandler = handler(self, self.disbandGroup)
    data.rejectDisbandRoomHandler = handler(self, self.rejectDisband)
    data.agreeDisbandRoomHandler = handler(self, self.agreeDisband)
    data.showMoreFuncHandler = handler(self, self.loadMoreFuncLayer)
    data.showGameMsgLayerHandler = handler(self, self.loadGameMsgLayer)
    data.voiceRecordHandler = handler(self,self.addVoiceRecordEvent)
    return data
end

function DDZgameScene:rejectDisband()
    ddzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function DDZgameScene:agreeDisband()
    ddzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end



function DDZgameScene:showShareButton(flag)

    --隐藏邀请好友按钮
    local invite_ly = cardScene:getChildByName("invite_ly")
    invite_ly:setVisible(false)

end

--请求充值
function DDZgameScene:requestCharge()
    if isBuyCardMode then
        -- require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
        require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
    end
end

function DDZgameScene:setRoomId(roomId)
    local room_lb_plane = self._scene:getChildByName("room_lb_plane"):setVisible(true)
    local room_lb = room_lb_plane:getChildByName("room_lb")
    room_lb:setString(roomId)
end
function DDZgameScene:reConnect()
    --SanGongSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function DDZgameScene:LoginRoom()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())
    ddzServer:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"])
end
--function DDZgameScene:reConnect()
--    ddzServer:LoginRoom(USER_INFO["tid"],USER_INFO["seat_id"],USER_INFO["activity_id"])
--end

function DDZgameScene:onExit()
    audio.stopMusic(false)
    AudioEngine.stopAllEffects()
end

function DDZgameScene:showVoiceRecord()

    local   voice_record_plane = self._scene:getChildByName("voice_record_plane")
    voice_record_plane:setVisible(not(voice_record_plane:isVisible()))
    
    if  voice_record_plane:isVisible() == false then
        return
    end 

    local   voiceListView = require("hall.view.voicePlayView.voiceListView")
    local   OLD_MSG = 2

    local   voiceRecords = voiceListView:getList() 
    
    dump(voiceRecords,"voiceRecords")

    -- local voiceRecords = {[1] = { uid = 991, url = "",time = 2},[2] = { uid = 991, url = "",time = 2} }
    if next(voiceRecords) then
        
        local   voice_record_lv = voice_record_plane:getChildByName("voice_record_lv")

        voice_record_lv:removeAllChildren()

        local   voice_record_item = voice_record_plane:getChildByName("voice_record_item")

        for _,item in pairs(voiceRecords) do
   
            local   uid = item.uid
            local   url = item.url
            local   time = item.voiceTime or "3"

            local   user_info = DDZ_USERINFO_TABLE[uid] or {}
            local   icon_url = user_info["icon_url"]

            local   voice_record_item_clone = voice_record_item:clone()
                    voice_record_item_clone:setVisible(true)

            local   voice = voice_record_item_clone:getChildByName("voice")

            local   room_bottom = voice_record_item_clone:getChildByName("room_bottom")
                    room_bottom:addTouchEventListener(function(sender,event)

                        if  event == TOUCH_EVENT_BEGAN then

                            local isPlaying = voiceListView:getVoiceIsPlaying()
                            local isRecording = voiceListView:getVoiceIsRecording()

                            if  isPlaying == 1 or isRecording == 1 then
                                return
                            end

                            local x = 0
                            local speed = 0.2
                            local nowtime = 0
                            
                            voice:runAction(cc.RepeatForever:create(
                                cc.Sequence:create(
                                    cc.DelayTime:create(speed),
                                    cc.CallFunc:create(function()                                    

                                        if x == 0 then
                                            voice:setOpacity(255)
                                        elseif x == 1 then
                                            voice:setOpacity(80)
                                        end

                                        x = x + 1

                                        if x == 2 then
                                            x = 0
                                        end

                                        nowtime = nowtime + speed

                                        if  nowtime >= tonumber(time) or nowtime > 5 then
                                            voice:stopAllActions()
                                            --恢复背景音乐
                                            voice:setOpacity(255)
                                            audio.resumeMusic()
                                        end

                                    end)
                                )

                            ))
                            
                            voiceListView:playVoice(url, uid, 1, OLD_MSG)

                        end

                    end)

            local   player_head = voice_record_item_clone:getChildByName("player_head")
            
            require("hall.GameCommon"):getUserHead(icon_url, uid, 1, player_head, 32, false)
            player_head:setTouchEnabled(false)

            voice_record_lv:pushBackCustomItem(voice_record_item_clone)

        end

    end

end


function DDZgameScene:showAllResultLayer(data)
    -- data = SVR_GROUP_BILLBOARD 
    print("showAllResultLayer ----------------------")
    dump(data)
    if data.playercount == 0 then 
        print("=======data===data.playercount===",data.playercount)
        require("hall.tips.CommonTips"):_gameToHall()
        return 
    end
    self.allResultLayer = self:loadLayerByName("hall.roomCommonUI.CommonEndResult", 5, self:getShowResultData(data))
end

function DDZgameScene:loadLayerByName(path, zOrder, data)
    if path == nil then
        print("DDZgameScene:loadLayerByName [path] is nil ----------------------")
    end
    zOrder = zOrder == nil and self:getChildrenCount() + 1 or zOrder
    local layer = require(path).new(data)
    print("======layer==zOrder=====",zOrder)
    if not tolua.isnull(layer) then
        print("======111111111111======")
        layer:addTo(self, zOrder)
    end
    print("======111111111111======")
    return layer
end

function DDZgameScene:getShowResultData(data)
    local result = {}
    result.user_mount = data.playercount
    result.playerlist = {}
    local winIdx = 1
    local winScore = 0
    for i, v in ipairs( data.playerlist or {} ) do
        if v.chips > winScore then
            winIdx = i
        end

    end
    for i, v in ipairs( data.playerlist or {} ) do
        local tmp = {}
        tmp.uid = v.uid
        tmp.score = v.chips / 100
        tmp.isMaxWin = false
        tmp.nickName = v.nickName
        tmp.portrait = v.portrait
        tmp.match_mount = data.game_amount
        tmp.matchlist= {}
         for j, v2 in ipairs( v.eachScores ) do
             local sTmp = {}
             sTmp.matchScore = v2 / 100
             table.insert(tmp.matchlist, sTmp)
         end
         --tmp.matchlist = v.eachScores
        table.insert(result.playerlist, tmp)
    end
    for i, v in ipairs( result.playerlist or {} ) do
        if v.score > winScore then
            winIdx = i
        end

    end
    if result.playerlist[winIdx] then
        result.playerlist[winIdx].isMaxWin = true
    end
    dump(result.playerlist, "result.playerlist")
    return result 
end

--解散房间
function DDZgameScene:disbandGroup()

    -- local function requestDisband()
    --     dump("C2G_CMD_DISSOLVE_ROOM")
    --     ddzServer:C2G_CMD_DISSOLVE_ROOM()
    -- end
    ddzServer:C2G_CMD_DISSOLVE_ROOM()
    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    -- cct.createHttRq({
    --     url = HttpAddr .. "/freeGame/queryGroupGameStatus",
    --     date = {
    --         activityId = USER_INFO["activity_id"],
    --         interfaceType = "j"
    --     },
    --     type_= "POST",
    --     callBack = function(data)
    --         local responseData = data.netData
    --         responseData = json.decode(responseData)
    --         local returnCode = responseData.returnCode
    --         if returnCode == "0" then
    --             local data = tonumber(responseData.data)
    --             dump(data, "检查当前组局状态")
    --             if data == 1 then
    --                 --创建组局
    --                 require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "提前解散房间不扣钻石，是否确定解散",_,requestDisband)
    --             elseif data == 2 then
    --                 --开始组局
    --                 require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "牌局已开始，确定要申请解散房间？",_,requestDisband)
                    
    --             elseif data == 0 then
    --                 --结束组局
    --                 require("hall.GameTips"):showTips("提示", "tohall", 1, "牌局已结束，是否返回大厅？")

    --             end             
    --         end

    --     end
    -- })
end

--解散房间
function DDZgameScene:quitRoom()
    print ("quitRoom" , SCENENOW["scene"].GameRound)
    if  SCENENOW["scene"].GameRound ~= 0 then
        require("hall.GameTips"):showTips("提示", "", 2, "游戏中不能退出！！！")
        return 
    end
    ddzServer:quitRoom()
end


function DDZgameScene:showButtonAfterSitDown(flag)

    -- local btn_auto_play = hall_plane:getChildByName("btn_auto_play")
    local btn_chat = cardScene:getChildByName("btn_chat")
    local btn_voice = cardScene:getChildByName("btn_voice")
    btn_chat:setVisible(flag)
    btn_voice:setVisible(flag)
    -- btn_auto_play:setVisible(flag)

end


function DDZgameScene:sendPeiPaiToSever()

    local   layer_top = self._scene:getChildByName("play_top")
    local   instruction_bt = layer_top:getChildByName("instruction_bt")
    
    local   player1_cards = {0x01,0x01,0x01,0x01,0x0A,0x04,0x02,0x22,            --地主底牌

    -- --1号玩家
    -- 0x0B,0x0D,0x0C,0x0D,0x02,0x0F,0x0D,0x0C,0x0C,0x0B,     
    -- 0x0B,0x0B,0x0A,0x0A,0x0A,0x02,0x02,0x07,0x06,0x06,
    -- 0x01,0x05,0x0E,0x0E,0x0E,}

    0x08,0x08,0x08,0x08,0x0D,
    0x09,0x09,0x09,0x09,0x0D ,
    0x05,0x05,0x05,0x05, 0x0D,
    0x14,0x13,0x13,0x13,0x0D ,
    0x17,0x16,0x06,0x26,0x0D }
    
    local player1_cards_c={}
    for i =0,#player1_cards-1 do
        player1_cards_c[i] = player1_cards[i+1]
    end

    local bonus_score,bonus_card_array = require("puchengdazha.CardLogic"):GetBonusCardType(player1_cards_c,#player1_cards)
    
    dump(bonus_score,"bonus_score")
    dump(bonus_card_array,"bonus_card_array")

    local   oricarddatas = 

    {0x01,0x01,0x01,0x01,0x0A,0x04,0x02,0x22,            --地主底牌

    -- --1号玩家
    -- 0x0B,0x0D,0x0C,0x0D,0x02,0x0F,0x0D,0x0C,0x0C,0x0B,     
    -- 0x0B,0x0B,0x0A,0x0A,0x0A,0x02,0x02,0x07,0x06,0x06,
    -- 0x01,0x05,0x0E,0x0E,0x0E,}

    0x08,0x08,0x08,0x08,0x0D,
    0x09,0x09,0x09,0x09,0x0D ,
    0x05,0x05,0x05,0x05, 0x0D,
    0x14,0x13,0x13,0x13,0x0D ,
    0x17,0x16,0x06,0x26,0x0D,


    0x01,0x12,0x21,0x2D,0x1D,0x1D,0x2D,0x3D,0x08,0x09,     --1号玩家
    0x08,0x08,0x08,0x08,0x0C,0x0C,0x0C,0x0E,0x07,0x07,
    0x14,0x07,0x08,0x07,0x08,

    --2号玩家
    0x08,0x08,0x08,0x09,0x09,0x09,0x08,0x09,0x1A,0x1A,     
    0x11,0x12,0x13,0x13,0x13,0x13,0x13,0x11,0x1B,0x1A,
    0x1B,0x1B,0x05, 0x21,0x22,
--4号玩家
    0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,      
    0x38,0x3D,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,
    0x39,0x38,0x38,0x3C,0x3D}

    local  cards = {}
    local  Card  = require("puchengdazha.Card")

    for _,cardvalue in ipairs(oricarddatas) do
        local value = Card:Encode(cardvalue)
        table.insert(cards,{["card"]=value})
    end
        
    local btn_voice = cardScene:getChildByName("btn_voice")
    -- local   btn_auto  = layer_top:getChildByName("btn_auto")
    btn_voice:addTouchEventListener(function(sender,evnet)
        ddzServer:CLI_PEI_PAI(cards,#cards)
    end)
end

--按照传入的分隔符，切割字符串
function LuaSplit(str, split_char)  
    if str == "" or str == nil then   
        return {};  
    end  
    local split_len = string.len(split_char)  
    local sub_str_tab = {};  
    local i = 0;  
    local j = 0;  
    while true do  
        j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串  
        if string.len(str) == i then   
            break;  
        end  
  
  
        if j == nil then  
            table.insert(sub_str_tab,string.sub(str,i));  
            break;  
        end;  
  
  
        table.insert(sub_str_tab,string.sub(str,i,j-1));  
        i = j+split_len;  
    end  
    return sub_str_tab;  
end
function DDZgameScene:setTmpScore(value)
    dump(value, "setTmpScore_value")
    if value ~= nil and self._scene then
        if value == 0 then
            self._scene:getChildByName("m_TmpScore"):setString("")
        end
        self._scene:getChildByName("m_TmpScore"):setString("本轮"..value)
    end

end
return DDZgameScene
