local ShiSanZhangRoomScene = require(TpackageName..".view.ShiSanZhangRoomScene")
local ShiSanZhangConfig = require(TpackageName..".config.ShiSanZhangConfig")

local SHISANZHANGGameScene = class("SHISANZHANGGameScene",ShiSanZhangRoomScene)

function SHISANZHANGGameScene:initData(_type)
        -----------------------------------------游戏相关信息-------------------------------------
        --十三水包名
        TpackageName = ShiSanZhangConfig.config.TpackageName
        TIMES_COUNT = -1
        GAME_IS_ENDING = 1
        GAME_OUT_CARD_COUNT =1
        GAME_OVER_RANKING = 1
        RELATIVE_seat = 1
        MY_SEAT_ID = -1
        MAX_PLAYERNUM = 8   --前端支持的最大人数
        TOTAL_PLAYERNUM =  8  --当前模式的最大人数（5,10,12人）
        dump(tonumber(USER_INFO["player_nums"]),"TOTAL_PLAYERNUM")
        PLAYERNUM = 0    --当前在玩的游戏人数
        SCHEDULER = require(cc.PACKAGE_NAME .. ".scheduler")
        CHECK_SCHEDULER_GLOBAL = nil
        GAME_NAME = "十三水"
        GAME_VERSION = "1.0.0"
        GAME_CHIP_CONFIG = {}
        GAME_TYPE_NAME = "十三水"
        GAME_UID_YA =-1
        DESIGN_SCREEN_WIDTH  = 1920
        DESIGN_SCREEN_HEIGHT = 1080
        GAME_IS_OVER = false

        SCREEN_WIDTH = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().width
        SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize().height

        GLOBAL_SCALE = DESIGN_SCREEN_WIDTH/SCREEN_WIDTH

        --旧框架/金币场标记  1为旧框架，2为金币场
        GROUP_MODE = 2
        APPLE_APP_VERSION = 2   --1 为旧IOS包

        -- HAS_BET_MODE = true  --是否带外围模式 

        BET_MODE = false  --是否为外围模式 

        ShiSanZhangSendHandle = import(TpackageName .. ".handle.ShiSanZhangSendHandle")

        ShiSanZhangUtils = require(TpackageName..".ShiSanZhangUtils")


        CURRENTCARDBACKINDEX = 1 --cc.UserDefault:getInstance():getIntegerForKey("CBStyleIndex",2)
        -----------------------------------------房间相关信息--------------------------------------
        All_Card_Nodes = {}
        SHISANZHANG_CARDTYPE_TABLE = {}

        GAME_TIME = 0   --- 投分时间  -- 看牌时间  -- 结束时间
        -----------------------------------------座位相关信息-------------------------------------
		--玩家头像
		PLAYER_HEADS_TABLE ={}
		--玩家头像位置
		PLAYER_HEADS_POSITION_TABLE ={}

        --座位表（服务器座位）
        SHISANZHANG_SEAT_TABLE = {}  --key = uid

        --座位表（服务器座位）
        SHISANZHANG_UID_TABLE = {}  --key = seat
        SHISANZHANG_PLAYERTYPE_COUNT ={}
        --玩家类型表（前端座位）


        --玩家信息表
        SHISANZHANG_USERINFO_TABLE = {} --key = uid
        SHISANZHANG_PLAYERTYPE_TABLE = {}
        SHISANZHANG_SEAT_TABLE_MAPPING = {}
        --------------------------------------游戏过程相关信息-------------------------------------
        USERS_READY_STATE = {}   --坐下的玩家
        Tid = -1
        MY_BET_CHIP =  {}   --我在每个座位上押的注 key是被押注者的UID
        TOTAL_BET_CHIP = {}  --每个座位上被押注的总量 key是被押注者的UID
        GAME_PARTICIPANTS = {}
        MY_seat = 0

        isGoldGame = 1

        GAME_ROUND = 1
        GAME_TOTAL_ROUND = 8    --局数

        initialChip = 20000

        IS_AUTO_PLAY = 0
        GAME_SEAT_DOWN = 0

        STAR_GAME_UID = 0
        BANKER_TYPE = 0 --选庄类型
        MAX_BEISHU = 1 --最大倍数
        SEE_CARD_NUM = 1 --看牌选庄或下注  1.8张 2.9张 3.10张
        BANKER_UID= 0 --庄家id
        BALANCE_SPEED = 3  --结果现实的速度 1.极速 2.快速 3.中速
        ------------------------------------------宏定义------------------------------------------- 

        SHISANZHANG_GAME_STATE = 0
        GAME_STATUS_STOP = 0            --牌局已结束
        GAME_STATUS_START = 1           --开始阶段
        GAME_STATUS_GRAB_BANKER = 2     -- 抢庄阶段
        GAME_STATUS_CALL_TIMES = 3      -- 加注阶段
        GAME_STATUS_SEND_CARD = 4       --发牌阶段
        GAME_STATUS_OUT_CARD = 5        --出牌阶段
        GAME_STATUS_OPEN_CARD = 6       --开牌阶段
        
        GAME_STATUS_WAIT_STOP = 7       --等待停止时期
        GAME_STATUS_OPEN_KIND = 8

        IS_DETAIL_STOP = false
        IS_ON_RANKING = false
        
        --顺时针排列
        CARD_PLAYERTYPE_MY = 1
        CARD_PLAYERTYPE_2 = 2
        CARD_PLAYERTYPE_3 = 3
        CARD_PLAYERTYPE_4 = 4
        CARD_PLAYERTYPE_5 = 5
        CARD_PLAYERTYPE_6 = 6
        CARD_PLAYERTYPE_7 = 7
        CARD_PLAYERTYPE_8 = 8

        SoundUtils = import(TpackageName .. ".SoundUtils")
        MY_BEST_CARDS ={}  ---存放推荐牌型
        MY_HAND_CARDS = {}  ---自己的手牌
        MY_HAND_CARDS_TEMP = {}  ---临时牌
        --比鸡牌型
        ETYPE_INVALID       =   0x00    --/* 无效的牌 */
        ETYPE_SAN_CARD      =   0x01    --/* 散牌 */
        ETYPE_ONE_PAIRS     =   0x02    --/* 一对 */
        ETYPE_STRAIGHT      =   0x03    --/* 顺子 */
        ETYPE_FLUSH         =   0x04    --/* 同花 */
        ETYPE_STRAIT_FLUSH  =   0x05    --/* 同花顺 */
        ETYPE_BAO_ZI        =   0x06    -- /* 豹子 */
        CARD_TYPE_TABLE ={
        [ETYPE_INVALID]         =   "无效牌型",
        [ETYPE_SAN_CARD]        =   "散牌",
        [ETYPE_ONE_PAIRS]       =   "一对",
        [ETYPE_STRAIGHT]        =   "顺子",
        [ETYPE_FLUSH]           =   "同花",
        [ETYPE_STRAIT_FLUSH]    =   "同花顺",
        [ETYPE_BAO_ZI]          =   "三条",
        }

end


function SHISANZHANGGameScene:ctor()
	-- cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1920, 1080, cc.ResolutionPolicy.SHOW_ALL)
    --print(" SHISANZHANGGameScene:ctor() --------------------", debug.traceback())
    self:initData("init")
    SHISANZHANGGameScene.super.ctor(self)
    local ShiSanZhangProtocol = import(TpackageName .. ".handle.ShiSanZhangProtocol")
    local ShiSanZhangReceiveHandle = import(TpackageName .. ".handle.ShiSanZhangReceiveHandle")
    --设置协议和协议处理
    bm.server:setProtocol(ShiSanZhangProtocol)
    bm.server:setHandle(ShiSanZhangReceiveHandle.new())

    dump("进入福建十三水")
    dump(TpackageName,"TpackageName---->>>")
end


function SHISANZHANGGameScene:onEnter()
    --播放背景音乐
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    SoundUtils:playBackgroundMusic()
    --房间信息
    dump(USER_INFO["GroupLevel"], "传到服务器的游戏level")
    dump(USER_INFO["activity_id"], "传到服务器的activity_id")
    ShiSanZhangSendHandle:enterRoom()
    HEART_BEAT_TID = USER_INFO["tid"]
    dump(HEART_BEAT_TID,"发送登陆房间")

end

return  SHISANZHANGGameScene