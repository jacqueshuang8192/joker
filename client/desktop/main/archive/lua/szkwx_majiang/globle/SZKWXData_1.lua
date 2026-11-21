
local SZKWXData = class("SZKWXData")
function SZKWXData: ctor()
    SZKWX_SCENE = nil -- 游戏面板
    SZKWX_MANYOU_PLANE = nil -- 漫游面板
    SZKWX_CARD_POINTER = nil -- 牌指针
    SZKWX_CURRENT_CARDNODE = nil

    SZKWX_CONTROLLER = nil

    _G.SZKWX_MY_USERINFO = {}
    _G.SZKWX_SEAT_TABLE = {} -- key = uid
    _G.SZKWX_USERINFO_TABLE = {} -- key = seat_id
    _G.SZKWX_ROOM = {}
    _G.SZKWX_ROOM.positionTable = {}
    _G.SZKWX_ROOM.userInfos = SZKWX_USERINFO_TABLE
    _G.SZKWX_GAMEINFO_TABLE = {} -- key = seat_id
    _G.SZKWX_SEAT_TABLE_BY_TYPE = {} -- key == playerType

    SZKWX_ZHUANG_UID = nil -- 庄家id

    SZKWX_CONTROL_TABLE = nil --操作数据

    SZKWX_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

    -- D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

    SZKWX_GAME_STATUS = 0 -- 0 未开始 1 进行中 4停止 3等待用户操作

    ZZ_PLAYER_COUNT = 4

    SZKWX_TING = 0

    D3_OPERATOR = nil

    SZKWX_LAIZI = 65
    CLUB_ID = nil
    SZKWX_TOTAL_ROUNDS = nil
    SZKWX_ROUND = nil

    SZKWX_CARDS_LESS_INIT = 112
    SZKWX_REMAIN_CARDS_COUNT = SZKWX_CARDS_LESS_INIT

    SZKWX_ENDING_DATA = nil
    SZKWX_GROUP_ENDING_DATA = nil

    SZKWX_IS_MING = 0  --0：当前还不是选择明牌 1：显示明牌按钮 2：显示扣牌界面 3：显示胡口界面
    KOU_PAI_TABLE = {}
    OTHER_PLAYER_HU_CARDS = {}

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

    SZKWX_PLAYERS_INFOS = {}

    BASE_CHIP = nil

    IS_DISSOLVED = false
    ZZ_PLAYER_COUNT = 4

    GAME_CONFIG_TAB = nil

    LIANGCARDS = {}

    NOT_LIANGCARDS = {}

    LIANGCARDS_HU = {}

end


return SZKWXData