
local CXZMJData = class("CXZMJData")
function CXZMJData: ctor()
    CXZMJ_SCENE = nil -- 游戏面板
    CXZMJ_MANYOU_PLANE = nil -- 漫游面板
    CXZMJ_CARD_POINTER = nil -- 牌指针
    CXZMJ_CURRENT_CARDNODE = nil

    CXZMJ_CONTROLLER = nil

    _G.CXZMJ_MY_USERINFO = {}
    _G.CXZMJ_SEAT_TABLE = {} -- key = uid
    _G.CXZMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.CXZMJ_ROOM = {}
    _G.CXZMJ_ROOM.tuoguan_ing = 0
    _G.CXZMJ_ROOM.positionTable = {}
    _G.CXZMJ_ROOM.userInfos = CXZMJ_USERINFO_TABLE
    _G.CXZMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.CXZMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    CXZMJ_ZHUANG_UID = nil -- 庄家id

    CXZMJ_CONTROL_TABLE = nil --操作数据

    CXZMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    CXZMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    CXZ_PLAYER_COUNT = 4

    CXZMJ_TING = 0

    D3_OPERATOR = nil

    CXZMJ_LAIZI = 65
    CLUB_ID = nil
    CXZMJ_TOTAL_ROUNDS = nil
    CXZMJ_ROUND = nil

    CXZMJ_CARDS_LESS_INIT = 112
    CXZMJ_REMAIN_CARDS_COUNT = CXZMJ_CARDS_LESS_INIT

    CXZMJ_ENDING_DATA = nil
    CXZMJ_GROUP_ENDING_DATA = nil

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

    CXZMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false

    CXZ_PLAYER_COUNT = 4

    CXZ_CXZ_LAI_ZI_CARD = 0

    CXZ_LAI_ZI_PI = 0
   
end


return CXZMJData