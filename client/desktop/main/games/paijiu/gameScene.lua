require(TpackageName .. ".Global")

local PaiJiuGameScene = class("PaiJiuGameScene", function()
    return display.newScene("PaiJiuGameScene")
end)

function PaiJiuGameScene:initData(_type)

    if _type == "init" then
        -----------------------------------------游戏相关信息-------------------------------------
        --牌九包名
        TpackageName = "paijiu"
        MAX_PLAYERNUM = 4   --前端支持的最大人数，一个游戏有多种玩法，不同玩法有不同的人数，这个代表游戏最大支持的人数
        -- TOTAL_PLAYERNUM = tonumber(USER_INFO["player_nums"]) or 4  --代表本玩法模式下场上的座位数
        TOTAL_PLAYERNUM = 4
        dump(tonumber(USER_INFO["player_nums"]),"TOTAL_PLAYERNUM")

        PLAYERNUM = 0    --当前在玩的游戏人数

        GAME_VERSION = "1.0.0"

        --产品版本区别：1为1.0，2为2.0
        GROUP_MODE = 2
        GAME_NAME = "湘西骨牌"
        -- 是否为金币场
        isGoldGame = 0

        -- 游戏模式：小牌九，2是大牌九，3是加锅牌九
        GAME_MODE = ""

        PAJIU_ACTIVITY_ID = 0

        -- Global.lua中常量初始化
        PJ_TOTAL_CARD_COUNT = 0
        PJ_REMAIN_CARD_COUNT = 0
        PJ_HANDCARD_COUNT = 0
        PJ_CARDS_SELECTED = {}
        PJ_HANDCARDS = {}
        --中间2个牌型的表
        PJ_AVAI_CARD_GROUPS = {}
        PJ_SURE_OPEN_CARD = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}
        PJ_IP_TABLE = {}

        PJ_GROUP_TYPE_SPE = 10
        PJ_GROUP_TYPE = {"杂","短","长","娥","人","地","天","","","分割","地杠","天杠","对杂五","对杂七","对杂八","对杂九","对短","对长","对娥","对人","对地","对天","地九娘娘","天王九","皇上","鬼子","炸弹"}
        PJ_GROUP_TYPE[0] = "毕十"
        PJ_GROUP_POINT = {"一","二","三","四","五","六","七","八","九"}
        PJ_GROUP_POINT[0] = "零"
        PJ_CARD_TYPE = {
            -- ["炸弹"] = "zd",  ["鬼子"] = "guizi",  ["皇上"] = "hs",  ["天王九"] = "tw9",["地九娘娘"] = "djnn",
            -- ["对天"] = "dt",  ["对地"] = "dd",  ["对人"] = "dr",  ["对娥"] = "de", ["对长"] = "dc", ["对短"] = "dduan", ["对杂九"] = "dz9", ["对杂八"] = "dz8", ["对杂七"] = "dz7", ["对杂五"] = "dz5",
            -- ["天杠"] = "tg", ["地杠"] = "dg", ["天九"] = "t9", ["地九"] = "d9", ["人九"] = "r9", ["娥九"] = "e9", ["长九"] = "c9", ["短九"] = "duan9",
            -- ["天八"] = "t8", ["地八"] = "d8", ["人八"] = "r8", ["娥八"] = "e8", ["长八"] = "c8", ["短八"] = "duan8",
            -- ["天七"] = "t7", ["地七"] = "d7", ["人七"] = "r7", ["娥七"] = "e7", ["长七"] = "c7", ["短七"] = "duan7", ["杂七"] = "z7",
            -- ["天六"] = "t6", ["地六"] = "d6", ["人六"] = "r6", ["长六"] = "c6", ["短六"] = "duan6", ["杂六"] = "z6",
            -- ["天五"] = "t5", ["地五"] = "d5", ["人五"] = "r5", ["娥五"] = "e5", ["长五"] = "c5", ["短五"] = "duan5", ["杂五"] = "z5",
            -- ["天四"] = "t4", ["人四"] = "r4", ["娥四"] = "e4", ["长四"] = "c4", ["短四"] = "duan4", ["杂四"] = "z4",
            -- ["天三"] = "t3", ["地三"] = "d3", ["人三"] = "r3", ["娥三"] = "e3", ["长三"] = "c3", ["短三"] = "duan3", ["杂三"] = "z3",
            -- ["天二"] = "t2", ["地二"] = "d2", ["人二"] = "r2", ["娥二"] = "e2", ["长二"] = "c2", ["短二"] = "duan2", ["杂二"] = "z2",
            -- ["地一"] = "d1", ["人一"] = "r1", ["娥一"] = "e1", ["长一"] = "c1", ["短一"] = "duan1", ["杂一"] = "z1", ["毕十"] = "b10",
            ["炸弹"] = 1, ["鬼子"] = 2, ["皇上"] = 4, ["天王九"] = 5, ["地九娘娘"] = 6, ["对天"] = 7, ["对地"] = 8, ["对人"] = 9,
        ["对娥"] = 10, ["对长"] = 11, ["对短"] = 14, ["对杂九"] = 18, ["对杂八"] = 19, ["对杂七"] = 20, ["对杂五"] = 21,
        ["天杠"] = 22, ["地杠"] = 23, ["天九"] = 24, ["地九"] = 25, ["人九"] = 26, ["娥九"] = 27, ["长九"] = 28, ["短九"] = 29,
        ["天八"] = 30, ["地八"] = 31, ["人八"] = 32, ["娥八"] = 33, ["长八"] = 34, ["短八"] = 35, ["天七"] = 37, ["地七"] = 38,
        ["人七"] = 39, ["娥七"] = 40, ["长七"] = 41, ["短七"] = 42, ["杂七"] = 43, ["天六"] = 44, ["地六"] = 45, ["人六"] = 46,
        ["长六"] = 47, ["短六"] = 48, ["杂六"] = 49, ["天五"] = 50, ["地五"] = 51, ["人五"] = 52, ["娥五"] = 53, ["长五"] = 54,
        ["短五"] = 55, ["杂五"] = 56, ["天四"] = 57, ["人四"] = 58, ["娥四"] = 59, ["长四"] = 60, ["短四"] = 61, ["杂四"] = 62,
        ["天三"] = 63, ["地三"] = 64, ["人三"] = 65, ["娥三"] = 66, ["长三"] = 67, ["短三"] = 68, ["杂三"] = 69, ["天二"] = 70,
        ["地二"] = 71, ["人二"] = 72, ["娥二"] = 73, ["长二"] = 74, ["短二"] = 75, ["杂二"] = 76, ["地一"] = 78, ["人一"] = 79,
        ["娥一"] = 80, ["长一"] = 81, ["短一"] = 82, ["杂一"] = 83, ["毕十"] = 84,

        }

        GROUP_RESULT = nil
        

        --IS_SURE_OPEN = false

        -- 道数
        DAO_COUNT = 2
        -- 加倍次数
        CALL_TIMES_COUNT = 0

        -- 庄模式
        ZHUANG_MODE = ""
        -- 每行的牌数
        RAW_CARDS_COUNT = 8
        -- 牌堆里的牌间距
        --CARD_POOL_INTERVAL = 10
        -- 剩余牌数
        REMAIN_CARDS = 32
        -- 牌堆里原始牌变成发牌后牌大小的倍数
        --CARD_POOL_TIMES = 1.3
        initialChip = 20000
        -- 玩家下注分数的数量
        TIMES_SIZE = 5
        -- 玩家下注的分数的数组
        TIMES_ARRAY = {}

        DESIGN_SCREEN_WIDTH  = 1920
        DESIGN_SCREEN_HEIGHT = 1080

        SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
        SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

        GLOBAL_SCALE = DESIGN_SCREEN_WIDTH/SCREEN_WIDTH

        HAS_OUTCARD = false   --是否带摊牌效果
        HAS_CUOPAI = false   --是否带搓牌效果

        APPLE_APP_VERSION = 2   --1 为旧IOS包

        -- HAS_BET_MODE = true  --是否带外围模式

        BET_MODE = false  --是否为外围模式

        PaiJiuSendHandle = import(TpackageName .. ".handle.PaiJiuSendHandle")
        GamePlaneOperator = import(TpackageName .. ".operator.GamePlaneOperator")

        -- TABLE_IMG = TpackageName .. "/images/pieces_card/card_back.png"

        CURRENTCARDBACKINDEX = cc.UserDefault:getInstance():getIntegerForKey("CBStyleIndex",1)
        -----------------------------------------房间相关信息--------------------------------------
        GAME_CONFIG = {
            ["小牌九"] = false,
            ["大牌九"] = false,
            ["加锅牌九"] = false,
            ["两道杠"] = false,
            ["三道杠"] = false,
            ["炸弹"] = false,
            ["地九娘娘"] = false,
            ["鬼子"] = false,
            ["天九王"] = false,
            ["轮庄"] = false,
            ["抢庄"] = false,
            ["霸王庄"] = false,
            ['每次选分'] = false,
            ["固定选分"] = false,
            ["固定2分"] = false,
            ["固定5分"] = false,
            ["固定8分"] = false,
            ["固定10分"] = false,
        }
        -----------------------------------------玩家相关信息-------------------------------------
        -- 玩家头像

        PLAYER_HEADS_TABLE ={}

        -- 玩家头像位置
        PLAYER_HEADS_POSITION_TABLE ={}

        --座位表（服务器座位）
        PAIJIU_SEAT_TABLE = {}  --key = uid

        --玩家类型表（前端座位）
        PAIJIU_PLAYERTYPE_TABLE = {}   --key = uid

        --玩家信息表
        PAIJIU_USERINFO_TABLE = {} --key = uid

        --------------------------------------游戏过程相关信息-------------------------------------
        USERS_READY_STATE = {}

        -- LIANGCARDNUM = 4
        -- BETCOUNT = 1

        -- CHECK_WAIWEI_RESULT_ABLE = false

        -- WAIWEI_BET_LIMIT = 1000000
        -- WAIWEI_BET_CHIPS = {}

        -- SINGLE_BET_CHIP = {}   --押注者的下注总数

        -- MY_BET_CHIP =  {}   --我在每个座位上押的注 key是被押注者的UID
        -- TOTAL_BET_CHIP = {}  --每个座位上被押注的总量 key是被押注者的UID

        --[[        FIRSTSENDCARD = true
                GAME_PARTICIPANTS = {}--]]
        MY_SEAT_ID = 0
        RELATIVE_SEAT_ID = 0
        BANKER_UID = 0
        MY_CARDS = {}
        -- BONUS_POOL_COINS = 0  --奖池

        BASE_CHIP = 5
        GAME_STATE = 1
        GROUP_RECORD = {}
        PAIJIUKIND = {}   --记录玩家牌型
        PAIJIU_OUTCARDS = {}   --记录玩家出牌

        GAME_ROUND = 0
        GAME_TOTAL_ROUND = 0

        --RANDOM_BANKER = {}
        --initialChip = 20000

        IS_AUTO_PLAY = 0

        EMPTY_TABLE = {[1] = 0, [2] = 0, [3] = 0}
        ------------------------------------------宏定义-------------------------------------------
        --[[        CARDKIND_WUXIAONIU = 17
                CARDKIND_SIZHA = 16
                CARDKIND_HULUNIU = 15
                CARDKIND_TONGHUANIU = 14
                CARDKIND_WUHUA = 13
                CARDKIND_SHUNZI = 12--]]

        GAME_STATUS_STOP = 0			-- 牌局已结束
        GAME_STATUS_GRAB_BANKER = 1	    -- 抢庄阶段
        GAME_STATUS_CALL_TIMES = 2		-- 加道杠阶段
        GAME_STATUS_SEND_CARDS = 3		-- 发牌阶段 -- 摇骰子
        GAME_STATUS_OUT_CARDS = 4      -- 出牌阶段 --
        GAME_STATUS_OPEN_CARDS = 5      -- 开牌阶段

        --顺时针排列
        CARD_PLAYERTYPE_MY = 1

        CARD_PLAYERTYPE_LEFT = 2
        --[[        CARD_PLAYERTYPE_LEFT1 = 2
                CARD_PLAYERTYPE_LEFT2 = 3
                CARD_PLAYERTYPE_LEFT3 = 4--]]

        CARD_PLAYERTYPE_TOP = 3
        --[[        CARD_PLAYERTYPE_TOP1 = 5
                CARD_PLAYERTYPE_TOP2 = 6
                CARD_PLAYERTYPE_TOP3 = 7--]]

        CARD_PLAYERTYPE_RIGHT = 4
        --[[        CARD_PLAYERTYPE_RIGHT1 = 8
                CARD_PLAYERTYPE_RIGHT2 = 9
                CARD_PLAYERTYPE_RIGHT3 = 10--]]

        --[[        if TOTAL_PLAYERNUM == 5 then

                    CARD_PLAYERTYPE_MY = 1

                    CARD_PLAYERTYPE_LEFT2 = 2

                    CARD_PLAYERTYPE_TOP1 = 3
                    CARD_PLAYERTYPE_TOP3 = 4

                    CARD_PLAYERTYPE_RIGHT2 = 5

                    CARD_PLAYERTYPE_LEFT1 = 6
                    CARD_PLAYERTYPE_LEFT3 = 7
                    CARD_PLAYERTYPE_TOP2 = 8
                    CARD_PLAYERTYPE_RIGHT1 = 9
                    CARD_PLAYERTYPE_RIGHT3 = 10

                end--]]

        SoundUtils = import(TpackageName .. ".SoundUtils")

    elseif _type == "clearGameData" then

        EMPTY_TABLE = {[1] = 0, [2] = 0, [3] = 0}
        PAIJIU_OUTCARDS = {}
        CALL_TIMES_COUNT = 0
        PJ_SURE_OPEN_CARD = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}

        for uid, ready_uid in pairs(USERS_READY_STATE) do
            USERS_READY_STATE[uid]=0
        end
        --MY_BET_CHIP = {}
        --SINGLE_BET_CHIP = {}
        --TOTAL_BET_CHIP = {}

    elseif _type == "release" then
        PAJIU_ACTIVITY_ID = nil
        -- Global.lua中的常量清除
        PJ_TOTAL_CARD_COUNT = nil
        PJ_REMAIN_CARD_COUNT = nil
        PJ_HANDCARD_COUNT = nil
        PJ_CARDS_SELECTED = nil
        PJ_HANDCARDS = nil
        PJ_AVAI_CARD_GROUPS = nil
        PJ_GROUP_TYPE_SPE = nil
        PJ_GROUP_TYPE = nil
        PJ_GROUP_POINT = nil
        --IS_SURE_OPEN = nil
        PJ_SURE_OPEN_CARD = nil
        PJ_IP_TABLE = nil
        PJ_GROUP_TYPE_SPE = 10
        PJ_GROUP_TYPE = nil
        PJ_GROUP_POINT = nil
        GROUP_RESULT = nil

        DAO_COUNT = nil
        CALL_TIMES_COUNT = nil
        ZHUANG_MODE = nil
        RAW_CARDS_COUNT = nil
        -- CARD_POOL_TIMES = nil
        --CARD_POOL_INTERVAL = nil
        REMAIN_CARDS = nil
        initialChip = nil
        TIMES_SIZE = nil
        TIMES_ARRAY = nil

        PLAYERNUM = nil
        WAIWEI_BET_LIMIT = nil
        WAIWEI_BET_CHIPS = nil
        SINGLE_BET_CHIP = nil
        TOTAL_BET_CHIP = nil
        BET_MODE = nil
        EMPTY_TABLE = nil
        RELATIVE_SEAT_ID = nil
        TpackageName = nil
        TOTAL_PLAYERNUM = nil
        GAME_NAME = nil
        GAME_VERSION = nil
        GAME_MODE = nil
        DESIGN_SCREEN_WIDTH = nil
        DESIGN_SCREEN_HEIGHT = nil
        SCREEN_WIDTH = nil
        SCREEN_HEIGHT = nil
        GLOBAL_SCALE = nil
        HAS_OUTCARD = nil
        HAS_CUOPAI = nil
        PaiJiuSendHandle = nil
        SoundUtils = nil
        -- GROUP_MODE = nil
        GAME_CONFIG = nil
        PLAYER_HEADS_TABLE = nil
        PLAYER_HEADS_POSITION_TABLE = nil
        PAIJIU_SEAT_TABLE = nil
        PAIJIU_PLAYERTYPE_TABLE = nil
        PAIJIU_USERINFO_TABLE = nil
        USERS_READY_STATE = nil
        FIRSTSENDCARD = nil
        MY_SEAT_ID = nil
        BANKER_UID = nil
        MY_CARDS = nil
        GAME_STATE = nil
        GROUP_RECORD = nil
        PAIJIUKIND = nil
        PAIJIU_OUTCARDS = nil
        GAME_ROUND = nil
        GAME_TOTAL_ROUND = nil
        RANDOM_BANKER = nil
        GAME_PARTICIPANTS = nil
        IS_AUTO_PLAY = nil
        BONUS_POOL_COINS = nil
        BETCOUNT = nil
        initialChip = nil
        isGoldGame = nil

        CARDKIND_WUXIAONIU = nil
        CARDKIND_SIZHA = nil
        CARDKIND_HULUNIU = nil
        CARDKIND_TONGHUANIU = nil
        CARDKIND_WUHUA = nil
        CARDKIND_SHUNZI = nil

        CARD_PLAYERTYPE_MY  = nil
        CARD_PLAYERTYPE_LEFT1 = nil
        CARD_PLAYERTYPE_LEFT2 = nil
        CARD_PLAYERTYPE_LEFT3 = nil
        CARD_PLAYERTYPE_TOP1 = nil
        CARD_PLAYERTYPE_TOP2 = nil
        CARD_PLAYERTYPE_TOP3 = nil
        CARD_PLAYERTYPE_RIGHT1 = nil
        CARD_PLAYERTYPE_RIGHT2 = nil
        CARD_PLAYERTYPE_RIGHT3 = nil

        PAIJIU_GAME_SCENE = nil

        GAME_STATUS_STOP = nil       --牌局已结束
        GAME_STATUS_GRAB = nil       --等待用户抢庄
        GAME_STATUS_TIMES = nil      --等待用户选择倍数
        GAME_STATUS_OUTCARD = nil      --牌局进行中
         
        dump(collectgarbage("count"),"检测退出时内存占用")
    end

end

function PaiJiuGameScene:ctor()

    -- cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1920, 1080, cc.ResolutionPolicy.SHOW_ALL)

    self:initData("init")

    local PaiJiuProtocol = import(TpackageName .. ".handle.PaiJiuProtocol")
    local PaiJiuReceiveHandle = import(TpackageName .. ".handle.PaiJiuReceiveHandle")

    dump(PaiJiuProtocol.CONFIG.CLIENT[0x110],"心跳协议")

    --设置协议和协议处理
    bm.server:setProtocol(PaiJiuProtocol)
    bm.server:setHandle(PaiJiuReceiveHandle.new())

    self._scene = cc.CSLoader:createNode(TpackageName.."/csb/NewgameScene/NewgameScene.csb"):addTo(self)
    self._scene:setScale(SCREEN_WIDTH/DESIGN_SCREEN_WIDTH, SCREEN_HEIGHT/DESIGN_SCREEN_HEIGHT)
    
    GameUtils.setNodeNameBindObj(self._scene)
    PAIJIU_GAME_SCENE = self._scene


    require(TpackageName .. ".operator.GamePlaneOperator"):init()

    --添加牌九版本号显示
    local lbVersion = cc.Label:createWithSystemFont(GAME_VERSION, "Arial", 22)
    lbVersion:setColor(cc.c3b(125, 125, 125))
    lbVersion:setPosition(cc.p(self._scene:getContentSize().width - lbVersion:getContentSize().width / 2, self._scene:getContentSize().height -lbVersion:getContentSize().height / 2))
    self._scene:addChild(lbVersion, 1000)

    --文字聊天界面
    local faceUI_node = require("hall.FaceUI.faceUI").new()
    
    faceUI_node:setHandle(PaiJiuSendHandle)
    self:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")

    --显示表情符号
    local idx = ViewBase:getZOrderByChilds(self)
    local EmojiArmatureView = require("hall.EmojiArmatureView.EmojiArmatureView"):newEmojiArmatureView(self:getToSendFaceAndTxtFuncs(), self)
    EmojiArmatureView:setLocalZOrder(idx)

    ---------------------------- 设备信息 --------------------------
    local  device_info_panel = PAIJIU_GAME_SCENE:getChildByName("room_top")
    if  device_info_panel then
        require("hall.util.GameMenu"):getDeviceInfo(device_info_panel)
    end

    --------------------------- 界面按钮 ---------------------------
    --设置
    local btn_setting = PAIJIU_GAME_SCENE:getChildByName("btn_setting")
    btn_setting:onClick(
    function(event)
            self:loadMoreFuncLayer()
            -- if isGoldGame == 0 then
            --     local quitRoom_action = function(sender,event)

            --         --触摸开始
            --         if event == TOUCH_EVENT_BEGAN then
            --             sender:setScale(0.9)
            --         end

            --         --触摸取消
            --         if event == TOUCH_EVENT_CANCELED then
            --             sender:setScale(1.0)
            --         end

            --         --触摸结束
            --         if event == TOUCH_EVENT_ENDED then
            --             sender:setScale(1.0)

            --             require("hall.GameCommon"):showSettings(false)
            --             self:quitRoom()
            --         end

            --     end
            --     require("hall.GameCommon"):showSettings(true, false, true, true, quitRoom_action,"退出房间")
            -- elseif isGoldGame == 1 then
            --     local disband_action = function(sender,event)

            --         --触摸开始
            --         if event == TOUCH_EVENT_BEGAN then
            --             sender:setScale(0.9)
            --         end

            --         --触摸取消
            --         if event == TOUCH_EVENT_CANCELED then
            --             sender:setScale(1.0)
            --         end

            --         --触摸结束
            --         if event == TOUCH_EVENT_ENDED then
            --             sender:setScale(1.0)

            --             require("hall.GameCommon"):showSettings(false)

            --             self:disbandGroup()

            --         end
            --     end

            --     require("hall.GameCommon"):showSettings(true, false, true, true, disband_action)
                
            -- end
    end)

    -- 文字表情按钮
    local btn_msg = PAIJIU_GAME_SCENE:getChildByName("btn_msg")
    btn_msg:onClick(
    function(event)
        -- local pos = sender:getPosition()
        -- faceUI_node:showTxtPanle(pos, 4)
        self:loadGameMsgLayer()
    end)

    -- 录音按钮
    local btn_voice = PAIJIU_GAME_SCENE:getChildByName("btn_voice")
    --local btn_voice_worldpoint = (btn_voice:getParent()):convertToWorldSpace(btn_voice:getPosition())

    local VoiceRecordView = require("hall.VoiceRecord.VoiceRecordView")
    if  VoiceRecordView.addVoiceRecordEvent then
        VoiceRecordView:addVoiceRecordEvent(btn_voice, 999)
    else
        VoiceRecordView:showView(btn_voice.x, btn_voice.y, 999)
        -- VoiceRecordView:showView(1861, 163, 999)
    end

    PAIJIU_GAME_SCENE:getChildByName("btn_huifang"):onClick(function(event)
        local game_round = 1
        if GAME_ROUND and GAME_ROUND > 2 then
            game_round = GAME_ROUND - 1
        end
        PaiJiuSendHandle:CLI_COMMAND_GAMERESULT_RECORD(game_round)
    end)

    --[[-- 旧方法
    require("hall.VoiceRecord.VoiceRecordView"):showView(btn_voice:getPosition().x, btn_voice:getPosition().y, -1)--]]
    ----------------------- 房间信息 -----------------------
    
end

function PaiJiuGameScene:loadGameMsgLayer()
    if tolua.isnull(self.gameMsgLayer) then
        self.gameMsgLayer = require("hall.roomCommonUI.GameMsgLayer").new(self:getToSendFaceAndTxtFuncs())
        self:addChild(self.gameMsgLayer)
        self.gameMsgLayer:setVisible(false)
    else
        self.gameMsgLayer:setVisible(true)
        self.gameMsgLayer:showContentByType(1)
    end
end

function PaiJiuGameScene:getToSendFaceAndTxtFuncs()
    local data = {}
    data.sendFaceHand = handler(self, self.sendFaceByIdx)
    return data
end

function PaiJiuGameScene:sendFaceByIdx(id, msgType, to_uid)
    print("sendFaceMsg --------------------------", id)
    PaiJiuSendHandle:CLI_MSG_FACE(id, msgType, to_uid)
end



function PaiJiuGameScene:onEnter()

    --播放背景音乐
    SoundUtils:playBackgroundMusic()


    --房间信息
    dump(USER_INFO["GroupLevel"], "传到服务器的游戏level")
    dump(USER_INFO["activity_id"], "传到服务器的activity_id")

    dump(USER_INFO["tid"], "gameScene_tid")

    -- dump(HEART_BEAT_TID, "发送登陆房间")
    if  GROUP_MODE == 2 then
        -- 2代
        dump(USER_INFO["tid"], "gameScene_tid")
        PaiJiuSendHandle:LoginRoom(USER_INFO["tid"], -1)

    else
        -- 1代
        -- self:updateRoomInfo(nil, nil, USER_INFO["invote_code"])
        PaiJiuSendHandle:enterGroupRoom(USER_INFO["GroupLevel"], 1, 36, USER_INFO["activity_id"])
    end

end

function PaiJiuGameScene:testPageEffect()
    cc.Director:getInstance():setDepthTest(false)
    local card = require(TpackageName .. ".PokerCard").new()
    local NodeGrid = cc.NodeGrid:create()
    card:setCard(0x09)
    NodeGrid:setRotation(90)
    NodeGrid:addChild(card)
    -- Rect gridRect = cc.Rect(visibleSize.width * 0.2,
    --                  visibleSize.height * 0.2,
    --                  visibleSize.width * 0.6,
    --                  visibleSize.height * 0.6);

    SCENENOW["scene"]:addChild(NodeGrid)
    NodeGrid:setPosition(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2))
    local effect = cc.PageTurn3D:create(4, cc.size(32, 24))
    -- local effect = cc.FlipY3D:create(2)
    -- local effect = cc.FadeOutUpTiles:create(2, cc.size(15, 10))
    -- local effect = cc.Shaky3D:create(6, cc.size(2, 1), 5, false)
    local pageTurn3D = cc.Sequence:create(effect,cc.CallFunc:create(function() NodeGrid:setPosition(cc.p(SCREEN_WIDTH/2,SCREEN_HEIGHT/2)) end) )
    NodeGrid:runAction(cc.RepeatForever:create(pageTurn3D))

end

function PaiJiuGameScene:modifyConfig()
    local file, msg = io.open("niuniu/gameConfig.txt")
    local s = file:read("*all")
    dump(s,"modifyConfig")
    local gameConfig = json.decode(s)
    gameConfig["level"] = 42
    gameConfig["gameId"] = 42

    local news = json.encode(gameConfig)
    file:close()

    local newfile = io.open("D:/work/hellouniverse/gameClient/trunk/niuniu/gameConfig1.txt","w")
    newfile:write(news)
    newfile:close()
end

function PaiJiuGameScene:showShareButton(flag)

    local control_panel = PAIJIU_GAME_SCENE:getChildByName("control_panel")
    --邀请微信好友
    local btn_invite = control_panel:getChildByName("btn_invite")
    btn_invite:setVisible(flag)
end

function PaiJiuGameScene:showDisbandButton(flag)
    --邀请微信好友
    local hall_panel = self._scene:getChildByName("hall_panel")
    local btn_disband = hall_panel:getChildByName("btn_disband")
    btn_disband:setVisible(flag)

end

function PaiJiuGameScene:showButtonAfterSitDown(flag)
    local hall_panel = self._scene:getChildByName("hall_panel")

    local btn_auto_play = hall_panel:getChildByName("btn_auto_play")
    local btn_msg = hall_panel:getChildByName("btn_msg")
    local btn_voice = hall_panel:getChildByName("btn_voice")
    btn_msg:setVisible(flag)
    btn_voice:setVisible(flag)
    btn_auto_play:setVisible(flag)

end

--请求充值
function PaiJiuGameScene:requestCharge()
    if isBuyCardMode then
        require("hall.BuyRoomCard.BuyRoomCardScene"):showScene(isNotShowBuyCard, 1)
    end
end

function PaiJiuGameScene:updateRoomInfo(baseScore, bankerUid, inviteCode, round, total_round, gameConfig)
    dump("--------------标签10086-----------------")
    print(baseScore, bankerUid, inviteCode, round, total_round, gameConfig)
    -- local hall_panel = self._scene:getChildByName("hall_panel")
   

    if  baseScore then
        local text_difeng = room_info:getChildByName("text_difeng")
        text_difeng:setString("底注：  "..baseScore)
    end

    if  bankerUid then
        local banker_id = room_info:getChildByName("banker_id")
        if bankerUid == -1 then
            bankerUid = ""
        end

        banker_id:setString("庄号：  "..bankerUid)
    end

    if  inviteCode then
        PAIJIU_GAME_SCENE.room_top.room_base_num:setString("房间号："..inviteCode)
    end

    if  round then
        PAIJIU_GAME_SCENE.room_top.room_base_gouptime:setString("局数："..round.."/"..total_round)
    end

    -- 显示游戏配置信息
    if gameConfig then
        --config_txt:setString(gameConfig)
        self.gamemsg=gameConfig
    end

    -- 玩法按钮：
    local btn_rule = PAIJIU_GAME_SCENE:getChildByName("btn_rule")
    btn_rule:addTouchEventListener(
    function (sender, event)
        -- 触摸开始
        if event == TOUCH_EVENT_BEGAN then
            sender:setScale(0.9)
        end

        -- 触摸取消
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        -- 触摸结束
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            --require("hall.scene.introduce.introduceScene"):showScene()
            if isOpenControl then
                PaiJiuSendHandle:CLIENT_TEST_AVAIABLE_CARDS()
            else
                dump(self.gamemsg,"------游戏配置信息-----------------------------------+++++++")
                require("hall.util.GameMenu"):showConfigPanel(self.gamemsg)
                --PaiJiuSendHandle:CLIENT_TEST_AVAIABLE_CARDS()
                --require(TpackageName..".ChoiceCard"):init2()
            end
        end
    end
    )
end

-- 退出房间
function PaiJiuGameScene:quitRoom()
    PaiJiuSendHandle:quitRoom()
end

-- 解散组局相关
-- 解散组局
function PaiJiuGameScene:disbandGroup()

    local function disband()
        PaiJiuSendHandle:C2G_CMD_DISSOLVE_ROOM()
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
                dump(data, "-----检查当前组局状态-----")
                data=1
                if data == 1 then
                    --创建组局
                    if isiOSVerify then
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "是否解散房间？",_,disband)
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？",_,disband)
                    end

                elseif data == 2 then
                    --开始组局
                    if isiOSVerify then
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "是否解散房间？",_,disband)
                    else
                        require("hall.GameTips"):showDisbandTips("解散房间", "new_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？",_,disband)
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

function PaiJiuGameScene:showWaiWeiButton(flag,ableBet)

    local hall_panel = self._scene:getChildByName("hall_panel")
    local btn_switch_bet_mode = hall_panel:getChildByName("btn_switch_bet_mode")

    local effect_light = btn_switch_bet_mode:getChildByName("effect_light")
    local bottom_img = btn_switch_bet_mode:getChildByName("bottom_img")

    if  flag ~= nil then
        btn_switch_bet_mode:setVisible(flag)

        -- --查看录纸
        -- local win_trend_bt = hall_panel:getChildByName("win_trend_bt")
        -- win_trend_bt:setVisible(flag)
    end

    if  ableBet == true then
        bottom_img:setColor(cc.c3b(255,255,255))
        effect_light:setVisible(true)
        effect_light:runAction(cc.Repeat:create(
        cc.Spawn:create(
        cc.Sequence:create(cc.ScaleTo:create(0.25,0.5),cc.ScaleTo:create(0.25,0.65)),
        cc.RotateBy:create(0.5,30)
        ),5)
        )

    elseif  ableBet == false then
        effect_light:setVisible(false)
        bottom_img:setColor(cc.c3b(125,125,125))
        GamePlaneOperator:showWaiWeiButton(false)
    end

end
function PaiJiuGameScene:reConnect()
    --SanGongSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
    require("hall.HallServer"):loginGameNew(USER_INFO["GroupLevel"], USER_INFO["tid"], USER_INFO["activity_id"], 1)
end
function PaiJiuGameScene:LoginRoom()
    bm.server:setProtocol(import(TpackageName .. ".handle.PaiJiuProtocol"))
    bm.server:setHandle(import(TpackageName .. ".handle.PaiJiuReceiveHandle").new())
    PaiJiuSendHandle:LoginRoom(USER_INFO["tid"], -1)
end
--function PaiJiuGameScene:reConnect()
--    bm.server:setProtocol(import(TpackageName .. ".handle.PaiJiuProtocol"))
--    bm.server:setHandle(import(TpackageName .. ".handle.PaiJiuReceiveHandle").new())
--    PaiJiuSendHandle:LoginRoom(USER_INFO["tid"], -1)
--end

function PaiJiuGameScene:switchBackGroundImg(index)

    local background = PAIJIU_GAME_SCENE:getParent():getChildByName("background")

    dump(index,"switchBackGroundImg")
    if index == 1 then
        background:loadTexture(TpackageName .. "/images/background_img.png")
        dump("成功更换桌布")
    elseif index == 2 then
        background:loadTexture(TpackageName .. "/images/background_img_1.png")
    elseif index == 3 then
        background:loadTexture(TpackageName .. "/images/background_img_2.png")
    end

end

--[[function PaiJiuGameScene:onExit()
    --移除录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):removeView()
    self:initData("release")
end]]

-- 为兼容1.5代重连
function PaiJiuGameScene:oldReConnect()
    -- body
    dump("------ PaiJiuGameScene:oldReConnect ---------")
    dump(PAJIU_ACTIVITY_ID, "--------- oldReConnect --------- ")
    bm.server:setProtocol(import(TpackageName .. ".handle.PaiJiuProtocol"))
    bm.server:setHandle(import(TpackageName .. ".handle.PaiJiuReceiveHandle").new())
    PaiJiuSendHandle:enterGroupRoom(USER_INFO["GroupLevel"], 1, 36, PAJIU_ACTIVITY_ID)
end

function PaiJiuGameScene:setLimitBetTotal(count)
    if count == 10 then
        NEW_TIMES_SIZE = 3
    elseif count == 20 then
        NEW_TIMES_SIZE = 4
    elseif count == 50 then 
        NEW_TIMES_SIZE = 5
    else
        NEW_TIMES_SIZE = 6 
    end
end

function PaiJiuGameScene:loadMoreFuncLayer()
	print("=====loadMoreFuncLayer=====")
	if tolua.isnull(self.moreFuncLayer) then
		self.moreFuncLayer = require("hall.roomCommonUI.GameMoreFuncLayer").new()
        self:addChild(self.moreFuncLayer)
        local data = {}
        data.quitRoom = handler(self, self.quitRoom)
        data.disbandRoom = handler(self, self.disbandGroup)
        self.moreFuncLayer:registerDisbandFuncs(data)
	else
		self.moreFuncLayer:setVisible(true)
		self.moreFuncLayer:showAni()
	end
end

return  PaiJiuGameScene
