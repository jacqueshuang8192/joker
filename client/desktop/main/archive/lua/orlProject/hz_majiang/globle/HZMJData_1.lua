
local HZMJData = class("HZMJData")
function HZMJData: ctor()
    HZMJ_SCENE = nil -- 游戏面板
    HZMJ_MANYOU_PLANE = nil -- 漫游面板
    HZMJ_CARD_POINTER = nil -- 牌指针
    HZMJ_CURRENT_CARDNODE = nil

    HZMJ_CONTROLLER = nil

    _G.HZMJ_MY_USERINFO = {}
    _G.HZMJ_SEAT_TABLE = {} -- key = uid
    _G.HZMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.HZMJ_ROOM = {}
    _G.HZMJ_ROOM.tuoguan_ing = 0
    _G.HZMJ_ROOM.positionTable = {}
    _G.HZMJ_ROOM.userInfos = HZMJ_USERINFO_TABLE
    _G.HZMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.HZMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    HZMJ_ZHUANG_UID = nil -- 庄家id

    HZMJ_CONTROL_TABLE = nil --操作数据

    HZMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    HZMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    HZ_PLAYER_COUNT = 4

    HZMJ_TING = 0

    D3_OPERATOR = nil

    HZMJ_LAIZI = 65
    CLUB_ID = nil
    HZMJ_TOTAL_ROUNDS = nil
    HZMJ_ROUND = nil

    HZMJ_CARDS_LESS_INIT = 112
    HZMJ_REMAIN_CARDS_COUNT = HZMJ_CARDS_LESS_INIT

    HZMJ_ENDING_DATA = nil
    HZMJ_GROUP_ENDING_DATA = nil

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

    HZMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil
    isting=false
    IS_DISSOLVED = false
    HZ_PLAYER_COUNT = 4

    PLAY_CARD_TIME_MAX = 30
end


return HZMJData