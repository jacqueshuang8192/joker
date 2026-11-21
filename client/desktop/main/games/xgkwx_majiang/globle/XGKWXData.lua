
local XGKWXData = class("XGKWXData")
function XGKWXData: ctor()
    XGKWX_SCENE = nil -- 游戏面板
    XGKWX_MANYOU_PLANE = nil -- 漫游面板
    XGKWX_CARD_POINTER = nil -- 牌指针
    XGKWX_CURRENT_CARDNODE = nil

    XGKWX_CONTROLLER = nil

    _G.XGKWX_MY_USERINFO = {}
    _G.XGKWX_SEAT_TABLE = {} -- key = uid
    _G.XGKWX_USERINFO_TABLE = {} -- key = seat_id
    _G.XGKWX_ROOM = {}
    _G.XGKWX_ROOM.positionTable = {}
    _G.XGKWX_ROOM.userInfos = XGKWX_USERINFO_TABLE
    _G.XGKWX_GAMEINFO_TABLE = {} -- key = seat_id
    _G.XGKWX_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    XGKWX_ZHUANG_UID = nil -- 庄家id

    XGKWX_CONTROL_TABLE = nil --操作数据

    XGKWX_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    XGKWX_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    ZZ_PLAYER_COUNT = 4

    XGKWX_TING = 0

    D3_OPERATOR = nil

    XGKWX_LAIZI = 65
    CLUB_ID = nil
    XGKWX_TOTAL_ROUNDS = nil
    XGKWX_ROUND = nil

    XGKWX_CARDS_LESS_INIT = 112
    XGKWX_REMAIN_CARDS_COUNT = XGKWX_CARDS_LESS_INIT

    XGKWX_ENDING_DATA = nil
    XGKWX_GROUP_ENDING_DATA = nil

    XGKWX_IS_MING = 0  --0：当前还不是选择明牌 1：显示明牌按钮 2：显示扣牌界面 3：显示胡口界面
    KOU_PAI_TABLE = {}
    OTHER_PLAYER_HU_CARDS = {}

    --------------------------------------------------
    --是否是金币场
    isGoldGame = nil

    initialChip = nil

    MY_SEAT_ID = nil

    RELATIVE_SEAT_ID = nil

    OnSeatCount = nil

    ROUND_RESULT_DATA = nil

    GAME_NAME = nil

    isShowRecord = false

    XGKWX_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    ZZ_PLAYER_COUNT = 4

   
end


return XGKWXData