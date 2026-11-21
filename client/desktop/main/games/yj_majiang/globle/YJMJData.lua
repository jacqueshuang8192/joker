
local YJMJData = class("YJMJData")
function YJMJData:ctor()
    YJMJ_SCENE = nil -- 游戏面板
    YJMJ_MANYOU_PLANE = nil -- 漫游面板
    YJMJ_CARD_POINTER = nil -- 牌指针
    YJMJ_CURRENT_CARDNODE = nil

    YJMJ_CONTROLLER = nil

    _G.YJMJ_MY_USERINFO = {}
    _G.YJMJ_SEAT_TABLE = {} -- key = uid
    _G.YJMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.YJMJ_ROOM = {}
    _G.YJMJ_ROOM.tuoguan_ing = 0
    _G.YJMJ_ROOM.positionTable = {}
    _G.YJMJ_ROOM.userInfos = YJMJ_USERINFO_TABLE
    _G.YJMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.YJMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    YJMJ_ZHUANG_UID = nil -- 庄家id

    YJMJ_CONTROL_TABLE = nil --操作数据

    YJMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    YJMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    YJ_PLAYER_COUNT = 4

    YJMJ_TING = 0

    D3_OPERATOR = nil

    YJMJ_LAIZI = 65
    CLUB_ID = nil
    YJMJ_TOTAL_ROUNDS = nil
    YJMJ_ROUND = nil

    YJMJ_CARDS_LESS_INIT = 112
    YJMJ_REMAIN_CARDS_COUNT = YJMJ_CARDS_LESS_INIT

    YJMJ_ENDING_DATA = nil
    YJMJ_GROUP_ENDING_DATA = nil

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

    YJMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    YJ_PLAYER_COUNT = 4

    BAO_JIAO_FIRST_OUT_CARD_YJ = true

end


return YJMJData