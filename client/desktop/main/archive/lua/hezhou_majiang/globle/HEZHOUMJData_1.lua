
local HEZHOUMJData = class("HEZHOUMJData")

function HEZHOUMJData: ctor()
    HEZHOUMJ_SCENE = nil -- 游戏面板
    HEZHOUMJ_MANYOU_PLANE = nil -- 漫游面板
    HEZHOUMJ_CARD_POINTER = nil -- 牌指针
    HEZHOUMJ_CURRENT_CARDNODE = nil

    HEZHOUMJ_CONTROLLER = nil

    _G.HEZHOUMJ_MY_USERINFO = {}
    _G.HEZHOUMJ_SEAT_TABLE = {} -- key = uid
    _G.HEZHOUMJ_USERINFO_TABLE = {} -- key = seat_id
    _G.HEZHOUMJ_ROOM = {}
    _G.HEZHOUMJ_ROOM.tuoguan_ing = 0
    _G.HEZHOUMJ_ROOM.positionTable = {}
    _G.HEZHOUMJ_ROOM.userInfos = HEZHOUMJ_USERINFO_TABLE
    _G.HEZHOUMJ_GAMEINFO_TABLE = {} -- key = seat_id
    _G.HEZHOUMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    HEZHOUMJ_ZHUANG_UID = nil -- 庄家id

    HEZHOUMJ_CONTROL_TABLE = nil --操作数据

    HEZHOUMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    HEZHOUMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    HEZHOU_PLAYER_COUNT = 4

    HEZHOUMJ_TING = 0

    D3_OPERATOR = nil

    HEZHOUMJ_LAIZI = 65
    CLUB_ID = nil
    HEZHOUMJ_TOTAL_ROUNDS = nil
    HEZHOUMJ_ROUND = nil

    HEZHOUMJ_CARDS_LESS_INIT = 112
    HEZHOUMJ_REMAIN_CARDS_COUNT = HEZHOUMJ_CARDS_LESS_INIT

    HEZHOUMJ_ENDING_DATA = nil
    HEZHOUMJ_GROUP_ENDING_DATA = nil

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

    HEZHOUMJ_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    HEZHOU_PLAYER_COUNT = 4

   
end


return HEZHOUMJData