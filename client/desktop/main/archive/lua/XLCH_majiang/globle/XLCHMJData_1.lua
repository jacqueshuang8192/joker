
local XLCHMJData = class("XLCHMJData")
function XLCHMJData: ctor()
    XLCHMJ_SCENE = nil -- 游戏面板
    XLCHMJ_MANYOU_PLANE = nil -- 漫游面板
    XLCHMJ_CARD_POINTER = nil -- 牌指针
    XLCHMJ_CURRENT_CARDNODE = nil

    XLCHMJ_CONTROLLER = nil

    _G.XLCHMJ_MY_USERINFO = {}
    _G.XLCHMJ_SEAT_TABLE = {} -- key = uid
    _G.XLCHMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.XLCHMJ_ROOM = {}
    _G.XLCHMJ_ROOM.tuoguan_ing = 0
    _G.XLCHMJ_ROOM.positionTable = {}
    _G.XLCHMJ_ROOM.userInfos = XLCHMJ_USERINFO_TABLE
    _G.XLCHMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.XLCHMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    XLCHMJ_ZHUANG_UID = nil -- 庄家id

    XLCHMJ_CONTROL_TABLE = nil --操作数据

    XLCHMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    XLCHMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    XLCH_PLAYER_COUNT = 4

    XLCHMJ_TING = 0

    D3_OPERATOR = nil

    XLCHMJ_LAIZI = 65
    CLUB_ID = nil
    XLCHMJ_TOTAL_ROUNDS = nil
    XLCHMJ_ROUND = nil

    XLCHMJ_CARDS_LESS_INIT = 112
    XLCHMJ_REMAIN_CARDS_COUNT = XLCHMJ_CARDS_LESS_INIT

    XLCHMJ_ENDING_DATA = nil
    XLCHMJ_GROUP_ENDING_DATA = nil

    ---------血流成河全局定义--------
    -----------------------------------------------------
    IS_HUANPAI_STATE=false      --是否是换牌状态
    UserDingQueHuaSe= 99
    Table_STATUS_HUANPAI=5      --换牌状态
    Table_STATUS_DINGQUE=6      --定缺状态
 
    
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

    XLCHMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    XLCH_PLAYER_COUNT = 4

    BAO_JIAO_FIRST_OUT_CARD = false

    XLCHMJ_MENHUCARD = {}
    XLCHMJ_MENHUCARD[1] = {}
    XLCHMJ_MENHUCARD[2] = {}
    XLCHMJ_MENHUCARD[3] = {}
    XLCHMJ_MENHUCARD[4] = {}

    XLCH_can_out_card = 0
end


return XLCHMJData