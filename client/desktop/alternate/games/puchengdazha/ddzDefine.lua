GAME_VERSION = "1.0.16"

GAME_TYPE = 2   --1为3人斗地主1副牌，2为4人斗地主2副牌

if  GAME_TYPE == 2  then

    GAME_NAME = "四人斗地主" 
    FARMER_CARDNUM = 25  --农民的起始牌数量
    LANDLORD_CARDNUM = 33 --地主的起始牌数量
    MAX_CARD_TYPE = 16   
    PLAYERNUM = 4 --玩家人数

elseif GAME_TYPE == 1  then

    GAME_NAME = "斗地主" 
    FARMER_CARDNUM = 17  --农民的起始牌数量
    LANDLORD_CARDNUM = 20 --地主的起始牌数量
    MAX_CARD_TYPE = 12   
    PLAYERNUM = 3 --玩家人数

end

--GAME_STATE
STATUS_STOP = 0        --停止游戏状态（包含回合与回合之间的停止
STATUS_LAND_SCORE = 1  --叫地主叫分状态
STATUS_PLAY  = 2     --正在游戏状态
STATUS_RESTART = 3    --重新发牌开始状态

CARD_PLAYERTYPE_MY = 1   --自己
CARD_PLAYERTYPE_LEFT = 4   --左侧玩家
CARD_PLAYERTYPE_RIGHT = 2   --右侧玩家
CARD_PLAYERTYPE_TOP = 3   --对面玩家

SCREEN_WIDTH = 1280  --屏幕尺寸
SCREEN_HEIGHT = 720