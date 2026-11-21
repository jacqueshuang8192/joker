
local ZZMJData = class("ZZMJData")
function ZZMJData: ctor()
    ZZMJ_SCENE = nil -- 游戏面板
    ZZMJ_MANYOU_PLANE = nil -- 漫游面板
    ZZMJ_CARD_POINTER = nil -- 牌指针
    ZZMJ_CURRENT_CARDNODE = nil

    ZZMJ_CONTROLLER = nil
    ZZ_IS_MUST = 0  --是否必胡
    _G.ZZMJ_MY_USERINFO = {}
    _G.ZZMJ_SEAT_TABLE = {} -- key = uid
    _G.ZZMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.ZZMJ_ROOM = {}
    _G.ZZMJ_ROOM.tuoguan_ing = 0
    _G.ZZMJ_ROOM.positionTable = {}
    _G.ZZMJ_ROOM.userInfos = ZZMJ_USERINFO_TABLE
    _G.ZZMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.ZZMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    ZZMJ_ZHUANG_UID = nil -- 庄家id
    ZZMJ_CONTROL_TABLE = nil --操作数据
    ZZMJ_AI = 0
    ZZMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    ZZMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    ZZ_PLAYER_COUNT = 4

    ZZMJ_TING = 0

    D3_OPERATOR = nil

    ZZMJ_LAIZI = 65
    CLUB_ID = nil
    ZZMJ_TOTAL_ROUNDS = nil
    ZZMJ_ROUND = nil

    ZZMJ_CARDS_LESS_INIT = 112
    ZZMJ_REMAIN_CARDS_COUNT = ZZMJ_CARDS_LESS_INIT

    ZZMJ_ENDING_DATA = nil
    ZZMJ_GROUP_ENDING_DATA = nil

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

    ZZMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    ZZ_PLAYER_COUNT = 4
    ZZ_IS_OPEN_GANG = false
    ZZ_GAME_CONFIG_JSON = nil
   
end


return ZZMJData