
local MHXLMJData = class("MHXLMJData")
function MHXLMJData: ctor()
    MHXLMJ_SCENE = nil -- 游戏面板
    MHXLMJ_MANYOU_PLANE = nil -- 漫游面板
    MHXLMJ_CARD_POINTER = nil -- 牌指针
    MHXLMJ_CURRENT_CARDNODE = nil

    MHXLMJ_CONTROLLER = nil

    _G.MHXLMJ_MY_USERINFO = {}
    _G.MHXLMJ_SEAT_TABLE = {} -- key = uid
    _G.MHXLMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.MHXLMJ_ROOM = {}
    _G.MHXLMJ_ROOM.tuoguan_ing = 0
    _G.MHXLMJ_ROOM.positionTable = {}
    _G.MHXLMJ_ROOM.userInfos = MHXLMJ_USERINFO_TABLE
    _G.MHXLMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.MHXLMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    MHXLMJ_ZHUANG_UID = nil -- 庄家id

    MHXLMJ_CONTROL_TABLE = nil --操作数据

    MHXLMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    MHXLMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    MHXL_PLAYER_COUNT = 4

    MHXLMJ_TING = 0

    D3_OPERATOR = nil

    MHXLMJ_LAIZI = 65
    CLUB_ID = nil
    MHXLMJ_TOTAL_ROUNDS = nil
    MHXLMJ_ROUND = nil

    MHXLMJ_CARDS_LESS_INIT = 112
    MHXLMJ_REMAIN_CARDS_COUNT = MHXLMJ_CARDS_LESS_INIT

    MHXLMJ_ENDING_DATA = nil
    MHXLMJ_GROUP_ENDING_DATA = nil

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

    MHXLMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    MHXL_PLAYER_COUNT = 4

    BAO_JIAO_FIRST_OUT_CARD = false

    MHXLMJ_MENHUCARD = {}
    MHXLMJ_MENHUCARD[1] = {}
    MHXLMJ_MENHUCARD[2] = {}
    MHXLMJ_MENHUCARD[3] = {}
    MHXLMJ_MENHUCARD[4] = {}

    MHXL_can_out_card = 0
end


return MHXLMJData