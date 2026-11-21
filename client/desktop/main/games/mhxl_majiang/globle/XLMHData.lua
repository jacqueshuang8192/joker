
local XLMHData = class("XLMHData")

XLMH_GAME_PLANE = nil -- 游戏面板
XLMH_MANYOU_PLANE = nil -- 漫游面板
XLMH_CARD_POINTER = nil -- 牌指针
XLMH_CURRENT_CARDNODE = nil

XLMH_CONTROLLER = nil

XLMH_MY_USERINFO = {}
XLMH_SEAT_TABLE = {} -- key = uid
XLMH_USERINFO_TABLE = {} -- key = seat_id
XLMH_ROOM = {}
XLMH_ROOM.positionTable = {}
XLMH_ROOM.userInfos = XLMH_USERINFO_TABLE
XLMH_GAMEINFO_TABLE = {} -- key = seat_id
XLMH_SEAT_TABLE_BY_TYPE = {} -- key == playerType
XLMH_ZHUANG_UID = nil -- 庄家id
PLAYER_HEADS_POSITION_TABLE ={}
XLMH_CONTROL_TABLE = nil --操作数据

XLMH_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

XLMH_GAME_STATUS = 0 -- 0 未开始 1 进行中

XLMH_LG_CARDS = {}

XLMH_TING = 0

XLMH_TOTAL_ROUNDS = nil
XLMH_ROUND = nil

XLMH_CARDS_LESS_INIT = 45
XLMH_REMAIN_CARDS_COUNT = XLMH_CARDS_LESS_INIT

XLMH_ENDING_DATA = nil
XLMH_GROUP_ENDING_DATA = nil

XLMH_LAIZI = nil

XLMH_PLAYER_COUNT = 4

XLMH_GAME_OVER = false

return XLMHData