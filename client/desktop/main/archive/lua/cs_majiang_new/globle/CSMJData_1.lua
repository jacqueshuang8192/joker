
local CSMJData = class("CSMJData")
function CSMJData: ctor()
    CSMJ_SCENE = nil -- 游戏面板
    CSMJ_MANYOU_PLANE = nil -- 漫游面板
    CSMJ_CARD_POINTER = nil -- 牌指针
    CSMJ_CURRENT_CARDNODE = nil

    CSMJ_CONTROLLER = nil

    _G.CSMJ_MY_USERINFO = {}
    _G.CSMJ_SEAT_TABLE = {} -- key = uid
    _G.CSMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.CSMJ_ROOM = {}
    _G.CSMJ_ROOM.tuoguan_ing = 0
    _G.CSMJ_ROOM.positionTable = {}
    _G.CSMJ_ROOM.userInfos = CSMJ_USERINFO_TABLE
    _G.CSMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.CSMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    CSMJ_ZHUANG_UID = nil -- 庄家id

    CSMJ_CONTROL_TABLE = nil --操作数据

    CSMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    CSMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    CS_PLAYER_COUNT = 4

    CSMJ_TING = 0

    D3_OPERATOR = nil

    CSMJ_LAIZI = 65
    CLUB_ID = nil
    CSMJ_TOTAL_ROUNDS = nil
    CSMJ_ROUND = nil

    CSMJ_CARDS_LESS_INIT = 112
    CSMJ_REMAIN_CARDS_COUNT = CSMJ_CARDS_LESS_INIT

    CSMJ_ENDING_DATA = nil
    CSMJ_GROUP_ENDING_DATA = nil

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

    CSMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    CS_PLAYER_COUNT = 4

    CS_NOT_CHI_CARDS_MY = {}

    CS_HAS_QISHOUHU = false

    CS_AFTER_QISHOUHU_OUTCARD = false

    CS_SHA_GANG = {}

    CSMJ_isting = false

    CSMJ_First_Grab_card = {}

    CSMJ_BUZHANG_OR_GANG = 1   --1 是杠  2是补张
end


return CSMJData