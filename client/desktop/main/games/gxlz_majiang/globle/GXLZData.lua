
local GXLZData = class("GXLZData")

GXLZ_GAME_PLANE = nil -- 游戏面板
GXLZ_MANYOU_PLANE = nil -- 漫游面板
GXLZ_CARD_POINTER = nil -- 牌指针
GXLZ_CURRENT_CARDNODE = nil

GXLZ_CONTROLLER = nil

GXLZ_MY_USERINFO = {}
GXLZ_SEAT_TABLE = {} -- key = uid
GXLZ_USERINFO_TABLE = {} -- key = seat_id
GXLZ_ROOM = {}
GXLZ_ROOM.positionTable = {}
GXLZ_ROOM.userInfos = GXLZ_USERINFO_TABLE
GXLZ_GAMEINFO_TABLE = {} -- key = seat_id
GXLZ_SEAT_TABLE_BY_TYPE = {} -- key == playerType
GXLZ_ZHUANG_UID = nil -- 庄家id
PLAYER_HEADS_POSITION_TABLE ={}
GXLZ_CONTROL_TABLE = nil --操作数据

GXLZ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

D3_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

GXLZ_GAME_STATUS = 0 -- 0 未开始 1 进行中

GXLZ_LG_CARDS = {}

GXLZ_TING = 0

GXLZ_TOTAL_ROUNDS = nil
GXLZ_ROUND = nil

GXLZ_CARDS_LESS_INIT = 45
GXLZ_REMAIN_CARDS_COUNT = GXLZ_CARDS_LESS_INIT

GXLZ_ENDING_DATA = nil
GXLZ_GROUP_ENDING_DATA = nil

GXLZ_LAIZI = nil

GXLZ_PLAYER_COUNT = 4

return GXLZData