
local ZXMJData = class("ZXMJData")
function ZXMJData: ctor()
    ZXMJ_SCENE = nil -- 游戏面板
    ZXMJ_MANYOU_PLANE = nil -- 漫游面板
    ZXMJ_CARD_POINTER = nil -- 牌指针
    ZXMJ_CURRENT_CARDNODE = nil

    ZXMJ_CONTROLLER = nil

    _G.ZXMJ_MY_USERINFO = {}
    _G.ZXMJ_SEAT_TABLE = {} -- key = uid
    _G.ZXMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.ZXMJ_ROOM = {}
    _G.ZXMJ_ROOM.tuoguan_ing = 0
    _G.ZXMJ_ROOM.positionTable = {}
    _G.ZXMJ_ROOM.userInfos = ZXMJ_USERINFO_TABLE
    _G.ZXMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.ZXMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    ZXMJ_ZHUANG_UID = nil -- 庄家id

    ZXMJ_CONTROL_TABLE = nil --操作数据

    ZXMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    ZXMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    ZX_PLAYER_COUNT = 4

    ZXMJ_TING = 0

    D3_OPERATOR = nil

    ZXMJ_LAIZI = 65
    CLUB_ID = nil
    ZXMJ_TOTAL_ROUNDS = nil
    ZXMJ_ROUND = nil

    ZXMJ_CARDS_LESS_INIT = 112
    ZXMJ_REMAIN_CARDS_COUNT = ZXMJ_CARDS_LESS_INIT

    ZXMJ_ENDING_DATA = nil
    ZXMJ_GROUP_ENDING_DATA = nil

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

    ZXMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil
    isting=false
    IS_DISSOLVED = false
    ZX_PLAYER_COUNT = 4

    ZX_NOT_CHI_CARDS_MY = {}

    ZXMJ_PENGGANG_CARD_PANEL = {}

end


return ZXMJData