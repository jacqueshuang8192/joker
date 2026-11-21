local CDSGameScene = class("CDSGameScene",function()
    return display.newScene("CDSGameScene")
end)

function CDSGameScene:initData(_type)
        -----------------------------------------游戏相关信息-------------------------------------
        TpackageName = "cds"
        CDSPanel = nil
        STAKESCENE = nil
        ROUND_ENDING = nil
        TIMES_COUNT = -1
        GAME_IS_ENDING = 1
        GAME_OUT_CARD_COUNT =1
        GAME_OVER_RANKING = 1
        RELATIVE_seat = 1
        MY_SEAT_ID = -1

        --测试用的
        MAX_PLAYERNUM = 13   --前端支持的最大人数
        TOTAL_PLAYERNUM =  13  --当前模式的最大人数（5,10,12人）

        isRide = true --筹码除以100
        isNewLowerScore=true --新下注界面
        isChatVoice=true   --聊天和语音按钮关闭
        dump(tonumber(USER_INFO["player_nums"]),"TOTAL_PLAYERNUM")
        PLAYERNUM = 0    --当前在玩的游戏人数
        SCHEDULER = require(cc.PACKAGE_NAME .. ".scheduler")
        CHECK_SCHEDULER_GLOBAL = nil
        GAME_NAME = "猜单双"
        GAME_VERSION = "1.0.0"
        GAME_CHIP_CONFIG = {}
        GAME_TYPE_NAME = "猜单双"
        GAME_UID_YA =-1
        DESIGN_SCREEN_WIDTH  = 1920
        DESIGN_SCREEN_HEIGHT = 1080

        MY_TOTAL_XIAZHU_TAB = {}

        SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
        SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

        GLOBAL_SCALE = DESIGN_SCREEN_WIDTH/SCREEN_WIDTH

        --旧框架/金币场标记  1为旧框架，2为金币场
        GROUP_MODE = 2
        APPLE_APP_VERSION = 2   --1 为旧IOS包

        -- HAS_BET_MODE = true  --是否带外围模式 

        BET_MODE = false  --是否为外围模式 

        CDSSendHandle = import(TpackageName .. ".handle.CDSSendHandle")

        CDSUtils = require(TpackageName..".CDSUtils")

        -- TABLE_IMG = TpackageName .. "/images/pieces_card/card_back.png"

        CURRENTCARDBACKINDEX = cc.UserDefault:getInstance():getIntegerForKey("CBStyleIndex",2)
        CURRENTCARDBACKINDEX = 5
        -----------------------------------------房间相关信息--------------------------------------
        -- All_Card_Nodes = {}
        SANGONG_CARDTYPE_TABLE = {}

        GAME_TIME = 0   --- 投分时间  -- 看牌时间  -- 结束时间
        -----------------------------------------座位相关信息-------------------------------------
		--玩家头像
		PLAYER_HEADS_TABLE ={}
		--玩家头像位置
		PLAYER_HEADS_POSITION_TABLE ={}

        --座位表（服务器座位）
        CDS_SEAT_TABLE = {}  --key = uid
        CDS_SEAT_TABLE_MAPPING = {}  --key = uid
        CDS_PLAYERTYPE_TABLE_MAPPING = {}
        CDS_SEAT_TABLE[USER_INFO["uid"]] = -1
        --座位表（服务器座位）
        SANGONG_UID_TABLE = {}  --key = seat
        SANGONG_PLAYERTYPE_COUNT ={}
        --玩家类型表（前端座位）
        CDS_PLAYERTYPE_TABLE = {}   --key = uid

        GAME_CONFIG = {}
        SANGONG_PLAYERTYPE_CHIP = {} --key = uid 用户在哪个座位上压了多少钱
        --玩家信息表
        CDS_USERINFO_TABLE = {} --key = uid
        --------------------------------------游戏过程相关信息-------------------------------------
        USERS_READY_STATE = {}   --坐下的玩家
        Tid = -1
        MY_BET_CHIP =  {}   --我在每个座位上押的注 key是被押注者的UID
        TOTAL_BET_CHIP = {}  --每个座位上被押注的总量 key是被押注者的UID
        GAME_PARTICIPANTS = {}
        MY_seat = 0
        MY_seat = 1

        isGoldGame = 0

        GAME_ROUND = 0
        GAME_TOTAL_ROUND = 8    --局数

        initialChip = 20000
        maxChip = 20000

        IS_AUTO_PLAY = 0
        GAME_SEAT_DOWN = 0
       -- BANKSEATID = niil
        SHAICARD = nil

        SHOW_PLAYER_HEAD_INFO = {}

        ------------------------------------------宏定义------------------------------------------- 


        GAME_STATUS_STOP = 0            --牌局已结束
        GAME_STATUS_START = 1           --牌局开始阶段
        GAME_STATUS_YA = 2              --押注阶段
        GAME_STATUS_SEND_CARD = 3       --发牌阶段
        GAME_STATUS_OUT_CARD = 4        --出牌阶段
        GAME_STATUS_OPEN_CARD = 5       --开牌阶段
        GAME_STATUS_YAOSHAIZI = 6       --摇色子
        GAME_STATUS_STOP_YA = 7       --停止下注
        GAME_STATUS_WAIT_STOP = 8       --等待停止时期


        GAME_STATUS_OPEN_KIND = 6

        IS_DETAIL_STOP = false
        IS_ON_RANKING = false
        --顺时针排列
        -- CARD_PLAYERTYPE_MY = 0
        CARD_PLAYERTYPE_MY = 1

        CARD_PLAYERTYPE_1 = 1
        CARD_PLAYERTYPE_2 = 2
        CARD_PLAYERTYPE_3 = 3
        CARD_PLAYERTYPE_4 = 4

        CARD_PLAYERTYPE_5 = 5
        CARD_PLAYERTYPE_6 = 6
        CARD_PLAYERTYPE_7 = 7
        CARD_PLAYERTYPE_8 = 8
        
        CARD_PLAYERTYPE_9 = 9
        CARD_PLAYERTYPE_10 = 10
        CARD_PLAYERTYPE_11 = 11
        CARD_PLAYERTYPE_12 = 12
        SoundUtils = import(TpackageName .. ".SoundUtils")

end



function CDSGameScene:ctor()
	-- cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1920, 1080, cc.ResolutionPolicy.SHOW_ALL)
    self:initData("init")
    -- display_scene("sangong.view.SanGongRoomScene", 1)
    GamePlaneOperator = require(TpackageName .. ".operator.GamePlaneOperator")

    local CDSProtocol = import(TpackageName .. ".handle.CDSProtocol")
    local CDSReceiveHandle = import(TpackageName .. ".handle.CDSReceiveHandle")
    --设置协议和协议处理
    bm.server:setProtocol(CDSProtocol)
    bm.server:setHandle(CDSReceiveHandle.new())

end


function CDSGameScene:onEnter()
    require("hall.GameCommon"):landLoading(true)
    --播放背景音乐
    cc.SimpleAudioEngine:getInstance():stopAllEffects()

    cc.SimpleAudioEngine:getInstance():stopMusic()
    audio.stopMusic(true) 

    --房间信息
    dump(USER_INFO["GroupLevel"], "传到服务器的游戏level")
    dump(USER_INFO["activity_id"], "传到服务器的activity_id")
    display_scene("cds.view.CDSRoomScene", 1)
    CDSSendHandle:LoginRoom(USER_INFO["tid"],USER_INFO["seat"],USER_INFO["activity_id"])
    HEART_BEAT_TID = USER_INFO["tid"]
    dump(HEART_BEAT_TID,"发送登陆房间")

    --self:onChangeBg()
end

function CDSGameScene:onChangeBg()
    local str = cc.UserDefault:getInstance():getIntegerForKey("GameBgType",1)
    local room_bg1 = CDSPanel:getChildByName("background")
    room_bg1:loadTexture(TpackageName.."/csb/GameSceneSector/bg_"..str..".png")
end


return  CDSGameScene