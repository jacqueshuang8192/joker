
local JXMJData = class("JXMJData")
function JXMJData: ctor()
    JXMJ_SCENE = nil -- 游戏面板
    JXMJ_MANYOU_PLANE = nil -- 漫游面板
    JXMJ_CARD_POINTER = nil -- 牌指针
    JXMJ_CURRENT_CARDNODE = nil

    JXMJ_CONTROLLER = nil

    _G.JXMJ_MY_USERINFO = {}
    _G.JXMJ_SEAT_TABLE = {} -- key = uid
    _G.JXMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.JXMJ_ROOM = {}
    _G.JXMJ_ROOM.tuoguan_ing = 0
    _G.JXMJ_ROOM.positionTable = {}
    _G.JXMJ_ROOM.userInfos = JXMJ_USERINFO_TABLE
    _G.JXMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.JXMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    JXMJ_ZHUANG_UID = nil -- 庄家id

    JXMJ_CONTROL_TABLE = nil --操作数据

    JXMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    JXMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    JX_PLAYER_COUNT = 4

    JXMJ_TING = 0

    D3_OPERATOR = nil

    JXMJ_LAIZI = 65
    CLUB_ID = nil
    JXMJ_TOTAL_ROUNDS = nil
    JXMJ_ROUND = nil

    JXMJ_CARDS_LESS_INIT = 112
    JXMJ_REMAIN_CARDS_COUNT = JXMJ_CARDS_LESS_INIT

    JXMJ_ENDING_DATA = nil
    JXMJ_GROUP_ENDING_DATA = nil

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

    JXMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil
    isting=false
    IS_DISSOLVED = false
    JX_PLAYER_COUNT = 4

    JX_is_GenDa = {0,0,0,0}

    Jx_BaiDa_Card = nil

    Jx_PengCard = 0

    PLAY_CARD_TIME_MAX = 20
end


return JXMJData