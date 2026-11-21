require("TaiHeGuoZha.ddzDefine")
local ddzServer = import("TaiHeGuoZha.ddzServer")
local ddzHandle = import("TaiHeGuoZha.ddzHandle")
local PROTOCOL = require("TaiHeGuoZha.ddz_PROTOCOL")
local GPSShowLayer = require("hall.GPSShowLayer")
local fs = require("hall.tool.utils.fs")

local DDZgameScene =
    class(
    "DDZgameScene",
    function()
        return display.newScene()
    end
)

--添加复制房号功能，放大牌，添加剩余牌数显示，带控牌显示
function DDZgameScene:initData(_type)
    HAS_RECEIVE_GROUP_RESULT = false
    decidecard = nil
    if _type == "init" then
        TpackageName = "TaiHeGuoZha"
        THGZ_IS_mAI = false   --是否托管
        require("hall.view.voicePlayView.voiceListView"):clearList()
        --dump1 = function (  )

        --end
        THGZ_USERINFO_TABLE = {}
        THGZ_SEAT_TABLE = {}
        SEAT2USERID = {}
        PLAYER_HEADS_POSITION_TABLE = {}

        REMAINCARDS = {}
        for seatId = 0, PLAYERNUM - 1 do
            REMAINCARDS[seatId] = 0
        end
        MY_SEAT_ID = -1
        USERS_READY_STATE = {}

        tbPlayCardInfo = {}

        LandLordSeatId = 1 --地主座位

        AUTO_OUT_CARD = false

        LocaArrayByPlayerType = {}

        DDZ_ROUND = 1

        DDZ_TOTAL_ROUND = 1

        FARMER_BONUS_CARDS = {}

        PLAYER_HEADS_TABLE = {}

        PLAYER_HEADS_POSITION_TABLE = {}

        bonus_array = {
            [0] = 0,
            [1] = 4,
            [2] = 0,
            [3] = 4,
            [4] = 4,
            [5] = 4,
            [6] = 0,
            [7] = 8,
            [8] = 4,
            [9] = 14,
            [10] = 0,
            [11] = 0,
            [12] = 0,
            [13] = 999
        }

        SHOW_GAME_CONFIG = {
            ["地主4张炸弹3连拖 无奖"] = true,
            ["地主4张炸弹3连拖 1分"] = true,
            ["地主4张炸弹3连拖 2分"] = true,
            ["明牌2分"] = true,
            ["5张炸弹2连拖有奖"] = true,
            ["7张炸弹2分"] = true,
            ["封顶8分"] = true
        }
        --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/res/hallMain/newAnim/anime"..v.."/anime"..v..".png","hall/res/hallMain/newAnim/anime"..v.."/anime"..v..".plist","hall/res/hallMain/newAnim/anime"..v.."/anime"..v..".ExportJson");                         -- 加载动画所用到的数据
        --btn:removeAllChildren()
        GAME_CONFIG = {}

        --通过接口传来的字符串获取具体配置信息
        if type(USER_INFO["gameConfig"]) == "string" then
            if string.find(USER_INFO["gameConfig"], "不显示剩余牌数") then
                GAME_CONFIG["不显示剩余牌数"] = true
            end
        end

        PartnerUid = nil
        PartnerCards = nil
    elseif _type == "clearGameData" then
        FARMER_BONUS_CARDS = {}
        PartnerUid = nil
        PartnerCards = nil

        for seatId in pairs(REMAINCARDS) do
            REMAINCARDS[seatId] = 0 --？？？？？
        end

        tbPlayCardInfo["last_cards"] = nil
    elseif _type == "release" then
        require("hall.view.voicePlayView.voiceListView"):clearList()

        --dump1(collectgarbage("count"),"collectgarbagecount2") --用于检测内存占用

        PLAYER_HEADS_TABLE = {}

        PLAYER_HEADS_POSITION_TABLE = {}

        USERS_READY_STATE = {}

        GAME_CONFIG = nil
        TpackageName = nil
        DDZ_ROUND = nil

        DDZ_TOTAL_ROUND = nil

        BASE_CARD_NUM = nil
        LocaArrayByPlayerType = nil

        THGZ_SEAT_TABLE = nil
        SEAT2USERID = nil
        PLAYER_HEADS_POSITION_TABLE = nil

        REMAINCARDS = nil

        tbPlayCardInfo = nil

        LandLordSeatId = nil --地主座位
        tbSeatCoin = nil

        AUTO_OUT_CARD = nil
        PartnerUid = nil
        PartnerCards = nil

        collectgarbage("collect")
    --dump1(collectgarbage("count"),"collectgarbagecount3")  --用于检测内存占用
    end
end

function DDZgameScene:ctor()
    --dump1(collectgarbage("count"),"collectgarbagecount1") --用于检测内存占用
    self:initData("init")

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())

    self._scene = cc.CSLoader:createNode("TaiHeGuoZha/res/GameScene.csb"):addTo(self)
    visibleSize = cc.Director:getInstance():getVisibleSize().width
    self.bg_select_index = 1

    GameUtils.setNodeNameBindObj(self._scene)
    self:_initUI()
    self:onChangeBg()
    self:setGameSetting()
    local roomBackGround = self._scene:getChildByName("roomBackGround"):setScale(self:_getScaleParam2())

    audio.preloadMusic("TaiHeGuoZha/res/audio/Audio_Game_Back.mp3")

    cardScene = self._scene

    --前端版本号
    self._scene.txt_version:setString(GAME_VERSION)
    self._scene.txt_version:hide()
    self._scene.device_info_plane.battery_shell:onClick(function(  )
        if isOpenControl then
            ddzServer:CLIENT_COMMAND_GET_CARD()
        end
    end,true)

    require("TaiHeGuoZha.operator.GamePlaneOperator"):init()

    --玩法说明

    local upConfigCount = 0
    local upConfig = ""
    local downConfig = ""

    if next(GAME_CONFIG) then
        for configName, v in pairs(GAME_CONFIG) do
            if v == true and SHOW_GAME_CONFIG[configName] then
                if upConfigCount <= 2 then
                    upConfigCount = upConfigCount + 1
                    upConfig = upConfig .. "  " .. configName
                else
                    downConfig = downConfig .. "  " .. configName
                end
            end
        end
    end

    --邀请微信好友
    local invite_ly = self._scene:getChildByName("invite_ly")

    local btn_share = invite_ly:getChildByName("btn_share")
    local btn_copy_room_id = invite_ly:getChildByName("btn_copy_room_id")

    require("hall.util.GameMenu"):registCopyRoomIdFunc(btn_copy_room_id, USER_INFO["invote_code"], GAME_NAME, "四人洼地菌瓦")

    --设置按钮
    local btnSetting = self._scene:getChildByName("btn_setting")

    local remain_rounds_count_plane = self._scene:getChildByName("remain_rounds_count_plane")

    local menuButtonTouchEvent = function(sender, event)
        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("TaiHeGuoZha/res/audio/Audio_Button_Click.mp3")

            local stSmall = cc.ScaleTo:create(0.1, 0.8)
            local stNormal = cc.ScaleTo:create(0.1, 1)
            local sq = cc.Sequence:create(stSmall, stNormal)
            sender:runAction(sq)
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
            local stBig = cc.ScaleTo:create(0.1, 1.3)
            local stNormal = cc.ScaleTo:create(0.1, 1)
            local sq = cc.Sequence:create(stBig, stNormal)
            sender:runAction(sq)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)

            if sender == btn_share then
                --设置
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
                paras["desc"] = USER_INFO["gameConfigMsg"] or " "
                paras["imagePath"] = "url"
                paras["name"] = "蒲城炸弹，房号：" .. USER_INFO["invote_code"]
                paras["showType"] = 2
                paras["url"] = appDownLoadAddress
                local shareLayer = require("hall.share.ShareLayer").new(paras)
                if shareLayer then
                    shareLayer:addTo(SCENENOW["scene"], 9999999)
                end
            elseif sender == btnSetting then
                self:loadMoreFuncLayer()
            end
        end
    end

    btn_share:addTouchEventListener(menuButtonTouchEvent)

    -- btn_exit:addTouchEventListener(menuButtonTouchEvent)
    btnSetting:addTouchEventListener(menuButtonTouchEvent)

    local lbVersion = cc.Label:createWithSystemFont(round_info, "Arial", 40)
    lbVersion:setColor(cc.c3b(255, 255, 0))
    lbVersion:setPosition(
        cc.p(SCENENOW["scene"]:getContentSize().width - lbVersion:getContentSize().width / 2 - 40, SCENENOW["scene"]:getContentSize().height - lbVersion:getContentSize().height / 2 - 30)
    )
    SCENENOW["scene"]:addChild(lbVersion, 999)
    -----------------------------文字表情-----------------------------
    local ddz_face = require("hall.FaceUI.faceUI") 

    local ddz_face_node = ddz_face.new()
    ddz_face_node:setHandle(ddzServer)
    self:addChild(ddz_face_node, 9999)
    ddz_face_node:setName("faceUI")

    local chat_bt = cardScene:getChildByName("btn_chat"):setVisible(false)
    local function onface_click(sender)
        self:loadGameMsgLayer()
    end

    chat_bt:onClick(onface_click)

    --显示表情符号
    local idx = ViewBase:getZOrderByChilds(self)
    local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)
    EmojiArmatureView:setLocalZOrder(idx)
end

function DDZgameScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH / CONFIG_DESIGN_WIDTH) * (disHeight / (frameHeight or 0))
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
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function DDZgameScene:sendFaceByIdx(id, msgType, to_uid)
    ddzServer:Msg_face(id, msgType, to_uid)
end

function DDZgameScene:_getScaleParam2()
    local frameHeight = CONFIG_WIN_HEIGHT
    local disHeight = CONFIG_DESIGN_HEIGHT
    return (CONFIG_WIN_WIDTH / CONFIG_DESIGN_WIDTH) * (disHeight / (frameHeight or 0))
end

function DDZgameScene:_initUI()
    if self._scene then
        local bg = self._scene:getChildByName("roomBackGround")
        local precent = self:_getScaleParam2()
        local root = self._scene
        if root then
            local child = root:getChildren()
            for i, v in ipairs(child or {}) do
                local x = v:getPositionX()
                v:setPositionX(x * precent)
                if v:getDescription() == "ListView" then --容器按照比率重新设置大小
                    local size = v:getContentSize()
                    v:setContentSize(cc.size(size.width * precent, size.height))
                end
            end
        end
    end
    local traceback = string.split(debug.traceback("", 2), "\n")
    print(traceback)

    ---gps按钮
    local gpsBtn = self._scene:getChildByName("distance_gps")
    gpsBtn:setVisible(false)
    gpsBtn:addTouchEventListener(
        function(sender, event)
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
                for k, v in pairs(THGZ_USERINFO_TABLE) do
                    table.insert(temptab, v)
                end
                gpsLayer:setInfo(temptab)
            end
        end
    )
    self._scene.xinyubg:ignoreContentAdaptWithSize(true)
end

function DDZgameScene:showGPSButton()
    local temptab = {}
    for k, v in pairs(THGZ_USERINFO_TABLE) do
        table.insert(temptab, v)
    end
    dump(THGZ_USERINFO_TABLE, "USER_INFO ====== ")

    local btn_gps = self._scene:getChildByName("distance_gps")

    if #temptab == 1 then
        btn_gps:setVisible(false)
        return
    end

    local isWarning = 0
    for i = 1, #temptab do
        for j = i + 1, #temptab do
            if calculateDistance(temptab[i].latitude, temptab[j].latitude, temptab[i].longitude, temptab[j].longitude) <= 100 then
                isWarning = isWarning + 1
                break
            end
        end
    end

    local img_safe = btn_gps:getChildByName("img_safe")
    local img_warnning = btn_gps:getChildByName("img_warning")

    if isWarning > 0 then
        img_safe:setVisible(false)
        img_warnning:setVisible(true)
    else
        img_safe:setVisible(true)
        img_warnning:setVisible(false)
    end

    btn_gps:setVisible(true)
end

function DDZgameScene:setGameSetting()
    self.roomCommonLayer = require("hall.roomCommonUI.RoomCommonPDKLayer").new(self:getToDisbandFuncs())
    self:addChild(self.roomCommonLayer, 15)
    self.roomCommonLayer:setTouchSwallowEnabled(false)
    self.roomCommonLayer:setVisible(false)
    self:loadGameMsgLayer()
end

function DDZgameScene:testSingle(...)
    local result = {
        ["cmd"] = 4616,
        ["playerList"] = {
            [1] = {
                ["cardcount"] = 0,
                ["cards"] = {},
                ["rank"] = 1,
                ["turnchip"] = 40,
                ["uid"] = 10019
            },
            [2] = {
                ["cardcount"] = 23,
                ["cards"] = {
                    [1] = 51,
                    [2] = 35,
                    [3] = 4,
                    [4] = 20,
                    [5] = 52,
                    [6] = 21,
                    [7] = 6,
                    [8] = 40,
                    [9] = 56,
                    [10] = 24,
                    [11] = 9,
                    [12] = 25,
                    [13] = 26,
                    [14] = 26,
                    [15] = 42,
                    [16] = 11,
                    [17] = 44,
                    [18] = 49,
                    [19] = 49,
                    [20] = 50,
                    [21] = 34,
                    [22] = 78,
                    [23] = 79
                },
                ["rank"] = 2,
                ["turnchip"] = -40,
                ["uid"] = 10020
            }
        },
        ["playercount"] = 2
    }

    return result
end

function DDZgameScene:testTotal(...)
    local result = {
        ["cmd"] = 20736,
        ["game_amount"] = 2,
        ["playercount"] = 2,
        ["playerlist"] = {
            [1] = {
                ["nickName"] = "测试0号",
                ["portrait"] = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["sex"] = 1,
                ["totalchips"] = 7000,
                ["turnchip"] = {
                    [1] = 7000
                },
                ["turncount"] = 1,
                ["uid"] = 10019
            },
            [2] = {
                ["nickName"] = "测试1号",
                ["portrait"] = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLiaNuiatuhFzTyEVDNRJzjf1qsibMLXlhOWNaTibEuy65aukic0hv5YwTf94vvTfFM02wP2lSEoWZsw4g/132",
                ["sex"] = 1,
                ["totalchips"] = -7000,
                ["turnchip"] = {
                    [1] = -7000
                },
                ["turncount"] = 1,
                ["uid"] = 10020
            }
        }
    }

    return result
end

function DDZgameScene:onEnter()
    CARD_PLAYERTYPE_MY = 1          --自己
    CARD_PLAYERTYPE_LEFT = 4        --左侧玩家
    CARD_PLAYERTYPE_RIGHT = 2       --右侧玩家
    CARD_PLAYERTYPE_TOP = 3         --对面玩家
    
    local groupId = nil
    if USER_INFO["club_id"] and USER_INFO["club_id"]["tid"] == USER_INFO["tid"] and USER_INFO["club_id"]["activity_id"] == USER_INFO["activity_id"] then
        groupId = USER_INFO["club_id"]["groupId"]
    end

    ddzServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"], groupId)

    local device_info_plane = self._scene:getChildByName("device_info_plane")
    require("hall.util.GameMenu"):addMenu(nil, device_info_plane)
    require("hall.GameCommon"):playEffectMusic("TaiHeGuoZha/res/audio/Audio_Game_Back.mp3", true)

    local btn_voice = cardScene:getChildByName("btn_voice"):setVisible(false)
    local voice_bt_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())

    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")

    if VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(btn_voice, 999)
        btn_voice:setVisible(false)
    else
        VoiceRecordView:showView(voice_bt_worldpoint.x, voice_bt_worldpoint.y, 999)
        btn_voice:setVisible(false)
    end

    self._scene:getChildByName("friendCardNode"):setVisible(false)
    self._scene:getChildByName("huopaiTxt"):setVisible(false)
end

function DDZgameScene:showGameSetting()
    self:setGameSetting()

    self:loadMoreFuncLayer()
end

function DDZgameScene:loadMoreFuncLayer()
    if tolua.isnull(self.moreFuncLayer) then
        self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer, 15)
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
    if fs.exists("TaiHeGuoZha/Difference.lua") then--有些台子不需要解散房间按钮
        local Difference = require("TaiHeGuoZha.Difference")
        Difference:gameScene(self.moreFuncLayer.btnDisbandRoom)
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
    data.voiceRecordHandler = handler(self, self.addVoiceRecordEvent)
    return data
end

function DDZgameScene:rejectDisband()
    ddzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
end

function DDZgameScene:agreeDisband()
    ddzServer:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
end

function DDZgameScene:showShareButton(flag)
    local invite_ly = cardScene:getChildByName("invite_ly")
    invite_ly:setVisible(false)
end

--请求充值
function DDZgameScene:requestCharge()
    if isBuyCardMode then
        require("hall.GameTips"):showTips("提示", "", 2, "有玩家积分不足，已解散！")
    end
end

function DDZgameScene:setRoomId(roomId)
    local room_lb_plane = self._scene:getChildByName("room_lb_plane"):setVisible(true)
    local room_lb = room_lb_plane:getChildByName("room_lb")
    room_lb:setString("房间号：" .. roomId)
end

function DDZgameScene:reConnect()
    dump(USER_INFO["tid"],"USER_INFO[tid]")
    dump(USER_INFO["activity_id"],"USER_INFO[activity_id]")
    dump(USER_INFO["GroupLevel"],"USER_INFO[GroupLevel]")
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end

function DDZgameScene:LoginRoom()
    dump("LoginRoom")
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())
    ddzServer:LoginRoom(USER_INFO["tid"], USER_INFO["seat_id"], USER_INFO["activity_id"])
end

function DDZgameScene:onExit()
    audio.stopMusic(false)
    AudioEngine.stopAllEffects()
end

function DDZgameScene:showAllResultLayer(data)
    if data.playercount == 0 then
        return
    end
    self.allResultLayer = self:loadLayerByName("hall.roomCommonUI.CommonEndResult", 5, self:getShowResultData(data))
end

function DDZgameScene:loadLayerByName(path, zOrder, data)
    if path == nil then
    end
    zOrder = zOrder == nil and self:getChildrenCount() + 1 or zOrder
    local layer = require(path).new(data)
    if not tolua.isnull(layer) then
        layer:addTo(self, zOrder)
    end
    return layer
end

function DDZgameScene:getShowResultData(data)
    local result = {}
    result.user_mount = data.playercount
    result.playerlist = {}
    local winIdx = 1
    local winScore = 0
    for i, v in ipairs(data.playerlist or {}) do
        if v.chips > winScore then
            winIdx = i
        end
    end
    for i, v in ipairs(data.playerlist or {}) do
        local tmp = {}
        tmp.uid = v.uid
        tmp.score = v.chips / 100
        tmp.isMaxWin = false
        tmp.nickName = v.nickName
        tmp.portrait = v.portrait
        tmp.match_mount = data.game_amount
        tmp.matchlist = {}
        table.insert(result.playerlist, tmp)
    end
    for i, v in ipairs(result.playerlist or {}) do
        if v.score > winScore then
            winIdx = i
        end
    end
    if result.playerlist[winIdx] then
        result.playerlist[winIdx].isMaxWin = true
    end
    return result
end

--解散房间
function DDZgameScene:disbandGroup()
    ddzServer:C2G_CMD_DISSOLVE_ROOM()
end

--解散房间
function DDZgameScene:quitRoom()
    print("quitRoom", SCENENOW["scene"].GameRound)
    if SCENENOW["scene"].GameRound > 1 then
        require("hall.GameTips"):showTips("提示", "", 2, "游戏中不能退出！！！")
        return
    end
    ddzServer:quitRoom()
end

function DDZgameScene:showButtonAfterSitDown(flag)
    local btn_chat = cardScene:getChildByName("btn_chat")
    local btn_voice = cardScene:getChildByName("btn_voice")

    if TaiHeGuoZhaRoomInfo and TaiHeGuoZhaRoomInfo.hidechat == 2 then
        flag = false
    end

    btn_chat:setVisible(flag)
    btn_voice:setVisible(flag)
end

function LuaSplit(str, split_char)
    if str == "" or str == nil then
        return {}
    end
    local split_len = string.len(split_char)
    local sub_str_tab = {}
    local i = 0
    local j = 0
    while true do
        j = string.find(str, split_char, i + split_len)
        if string.len(str) == i then
            break
        end

        if j == nil then
            table.insert(sub_str_tab, string.sub(str, i))
            break
        end

        table.insert(sub_str_tab, string.sub(str, i, j - 1))
        i = j + split_len
    end
    return sub_str_tab
end
function DDZgameScene:setTmpScore(value)
    if value ~= nil and self._scene then
        if value == 0 then
            self._scene:getChildByName("m_TmpScore"):setString("")
        end
        self._scene:getChildByName("m_TmpScore"):setString("本轮" .. value)
    end
end

function DDZgameScene:onChangeBg()
    if not isShowChageSceneBg then
        return
    end
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType",1)
    local room_bg1 = self._scene:getChildByName("roomBackGround")
    room_bg1:loadTexture("hall/res/setting/bigBg/bg"..str..".png")
end

return DDZgameScene
