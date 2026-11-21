
local GXLZMJData = class("GXLZMJData")
function GXLZMJData: ctor()
    GXLZMJ_SCENE = nil -- 游戏面板
    GXLZMJ_MANYOU_PLANE = nil -- 漫游面板
    GXLZMJ_CARD_POINTER = nil -- 牌指针
    GXLZMJ_CURRENT_CARDNODE = nil

    GXLZMJ_CONTROLLER = nil

    _G.GXLZMJ_MY_USERINFO = {}
    _G.GXLZMJ_SEAT_TABLE = {} -- key = uid
    _G.GXLZMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.GXLZMJ_ROOM = {}
    _G.GXLZMJ_ROOM.tuoguan_ing = 0
    _G.GXLZMJ_ROOM.positionTable = {}
    _G.GXLZMJ_ROOM.userInfos = GXLZMJ_USERINFO_TABLE
    _G.GXLZMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.GXLZMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    GXLZMJ_ZHUANG_UID = nil -- 庄家id

    GXLZMJ_CONTROL_TABLE = nil --操作数据

    GXLZMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    GXLZMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    GXLZ_PLAYER_COUNT = 4

    GXLZMJ_TING = 0

    D3_OPERATOR = nil

    GXLZMJ_LAIZI = 65
    CLUB_ID = nil
    GXLZMJ_TOTAL_ROUNDS = nil
    GXLZMJ_ROUND = nil

    GXLZMJ_CARDS_LESS_INIT = 112
    GXLZMJ_REMAIN_CARDS_COUNT = GXLZMJ_CARDS_LESS_INIT

    GXLZMJ_ENDING_DATA = nil
    GXLZMJ_GROUP_ENDING_DATA = nil

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

    GXLZMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil
    isting=false
    IS_DISSOLVED = false
    GXLZ_PLAYER_COUNT = 4

    GXLZ_NOT_CHI_CARDS_MY = {}

end


return GXLZMJData