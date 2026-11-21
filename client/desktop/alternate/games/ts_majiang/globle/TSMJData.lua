
local TSMJData = class("TSMJData")
function TSMJData: ctor()
    TSMJ_SCENE = nil -- 游戏面板
    TSMJ_MANYOU_PLANE = nil -- 漫游面板
    TSMJ_CARD_POINTER = nil -- 牌指针
    TSMJ_CURRENT_CARDNODE = nil

    TSMJ_CONTROLLER = nil

    _G.TSMJ_MY_USERINFO = {}
    _G.TSMJ_SEAT_TABLE = {} -- key = uid
    _G.TSMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.TSMJ_ROOM = {}
    _G.TSMJ_ROOM.tuoguan_ing = 0
    _G.TSMJ_ROOM.positionTable = {}
    _G.TSMJ_ROOM.userInfos = TSMJ_USERINFO_TABLE
    _G.TSMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.TSMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    TSMJ_ZHUANG_UID = nil -- 庄家id

    TSMJ_CONTROL_TABLE = nil --操作数据

    TSMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    TSMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    TS_PLAYER_COUNT = 4

    TSMJ_TING = 0

    D3_OPERATOR = nil

    TSMJ_LAIZI = 65
    CLUB_ID = nil
    TSMJ_TOTAL_ROUNDS = nil
    TSMJ_ROUND = nil

    TSMJ_CARDS_LESS_INIT = 112
    TSMJ_REMAIN_CARDS_COUNT = TSMJ_CARDS_LESS_INIT

    TSMJ_ENDING_DATA = nil
    TSMJ_GROUP_ENDING_DATA = nil

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

    TSMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    TS_PLAYER_COUNT = 4

   
end


return TSMJData