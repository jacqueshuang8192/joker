
local XPLPMJData = class("XPLPMJData")
function XPLPMJData: ctor()
    XPLPMJ_SCENE = nil -- 游戏面板
    XPLPMJ_MANYOU_PLANE = nil -- 漫游面板
    XPLPMJ_CARD_POINTER = nil -- 牌指针
    XPLPMJ_CURRENT_CARDNODE = nil

    XPLPMJ_CONTROLLER = nil

    _G.XPLPMJ_MY_USERINFO = {}
    _G.XPLPMJ_SEAT_TABLE = {} -- key = uid
    _G.XPLPMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.XPLPMJ_ROOM = {}
    _G.XPLPMJ_ROOM.tuoguan_ing = 0
    _G.XPLPMJ_ROOM.positionTable = {}
    _G.XPLPMJ_ROOM.userInfos = XPLPMJ_USERINFO_TABLE
    _G.XPLPMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.XPLPMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    XPLPMJ_ZHUANG_UID = nil -- 庄家id

    XPLPMJ_CONTROL_TABLE = nil --操作数据

    XPLPMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    XPLPMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    XPLP_PLAYER_COUNT = 4

    XPLPMJ_TING = 0

    D3_OPERATOR = nil

    XPLPMJ_LAIZI = 65
    CLUB_ID = nil
    XPLPMJ_TOTAL_ROUNDS = nil
    XPLPMJ_ROUND = nil

    XPLPMJ_CARDS_LESS_INIT = 112
    XPLPMJ_REMAIN_CARDS_COUNT = XPLPMJ_CARDS_LESS_INIT

    XPLPMJ_ENDING_DATA = nil
    XPLPMJ_GROUP_ENDING_DATA = nil

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

    XPLPMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    XPLP_PLAYER_COUNT = 4
    STATS_XUAN_GU=false
    XPLP_NOT_CHI_CARDS_MY = {}

    XPLP_GUCHOU_STATUS_UI_ID = {}

end


return XPLPMJData