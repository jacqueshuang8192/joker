
local YLMJData = class("YLMJData")
function YLMJData: ctor()
    YLMJ_SCENE = nil -- 游戏面板
    YLMJ_MANYOU_PLANE = nil -- 漫游面板
    YLMJ_CARD_POINTER = nil -- 牌指针
    YLMJ_CURRENT_CARDNODE = nil

    YLMJ_CONTROLLER = nil

    _G.YLMJ_MY_USERINFO = {}
    _G.YLMJ_SEAT_TABLE = {} -- key = uid
    _G.YLMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.YLMJ_ROOM = {}
    _G.YLMJ_ROOM.tuoguan_ing = 0
    _G.YLMJ_ROOM.positionTable = {}
    _G.YLMJ_ROOM.userInfos = YLMJ_USERINFO_TABLE
    _G.YLMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.YLMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    YLMJ_ZHUANG_UID = nil -- 庄家id

    YLMJ_CONTROL_TABLE = nil --操作数据

    YLMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    YLMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    YL_PLAYER_COUNT = 4

    YLMJ_TING = 0

    D3_OPERATOR = nil

    YLMJ_LAIZI = 65
    CLUB_ID = nil
    YLMJ_TOTAL_ROUNDS = nil
    YLMJ_ROUND = nil

    YLMJ_CARDS_LESS_INIT = 112
    YLMJ_REMAIN_CARDS_COUNT = YLMJ_CARDS_LESS_INIT

    YLMJ_ENDING_DATA = nil
    YLMJ_GROUP_ENDING_DATA = nil

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

    YLMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil
    isting=false
    IS_DISSOLVED = false
    YL_PLAYER_COUNT = 4

   
end


return YLMJData