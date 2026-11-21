
local GXHCMJData = class("GXHCMJData")
function GXHCMJData: ctor()
    GXHCMJ_SCENE = nil -- 游戏面板
    GXHCMJ_MANYOU_PLANE = nil -- 漫游面板
    GXHCMJ_CARD_POINTER = nil -- 牌指针
    GXHCMJ_CURRENT_CARDNODE = nil

    GXHCMJ_CONTROLLER = nil

    _G.GXHCMJ_MY_USERINFO = {}
    _G.GXHCMJ_SEAT_TABLE = {} -- key = uid
    _G.GXHCMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.GXHCMJ_ROOM = {}
    _G.GXHCMJ_ROOM.tuoguan_ing = 0
    _G.GXHCMJ_ROOM.positionTable = {}
    _G.GXHCMJ_ROOM.userInfos = GXHCMJ_USERINFO_TABLE
    _G.GXHCMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.GXHCMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    GXHCMJ_ZHUANG_UID = nil -- 庄家id

    GXHCMJ_CONTROL_TABLE = nil --操作数据

    GXHCMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    GXHCMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    GXLZ_PLAYER_COUNT = 4

    GXHCMJ_TING = 0

    D3_OPERATOR = nil

    GXHCMJ_LAIZI = 65
    CLUB_ID = nil
    GXHCMJ_TOTAL_ROUNDS = nil
    GXHCMJ_ROUND = nil

    GXHCMJ_CARDS_LESS_INIT = 112
    GXHCMJ_REMAIN_CARDS_COUNT = GXHCMJ_CARDS_LESS_INIT

    GXHCMJ_ENDING_DATA = nil
    GXHCMJ_GROUP_ENDING_DATA = nil

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

    GXHCMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil
    isting=false
    IS_DISSOLVED = false
    GXLZ_PLAYER_COUNT = 4
    isAnKejian=false
    GXLZ_NOT_CHI_CARDS_MY = {}

end


return GXHCMJData