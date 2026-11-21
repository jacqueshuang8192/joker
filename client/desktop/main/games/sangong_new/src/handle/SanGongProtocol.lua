--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require('hall.HALL_PROTOCOL')
local P = class('HALL_SERVER_PROTOCOL', HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P

local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER
----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------
P.CLI_HEART = 0x110 --发送心跳
CLIENT[P.CLI_HEART] = {
    ver = 1,
    fmt = {
        {name = 'tid', type = T.INT}
    }
}

P.CLI_REQUEST_BET = 0x1040 --外围请求下注
CLIENT[P.CLI_REQUEST_BET] = {
    ver = 1,
    fmt = {
        {name = 'seatId', type = T.INT},
        {name = 'betChip', type = T.INT}
    }
}

P.CLI_REQUEST_LUZHI = 0x1035 --请求录纸
CLIENT[P.CLI_REQUEST_LUZHI] = {
    ver = 1
}

P.CLI_AUTO_PLAY = 0x1034 --请求托管
CLIENT[P.CLI_AUTO_PLAY] = {
    ver = 1,
    fmt = {
        {name = 'isAuto', type = T.BYTE} --用户id
    }
}

P.CLI_QUIT_ROOM = 0x1033 --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1
}

P.CLI_SIT_DOWN = 0x1031 --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    fmt = {
        {name = 'seatId', type = T.INT} --座位id
    }
}

P.CLI_STAND_UP = 0x1032 --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1
}

P.CLIENT_CMD_FORWARD_MESSAGE = 0x165 --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = 'level', type = T.SHORT}, --游戏level
        {name = 'msg', type = T.STRING}
    }
}

P.CLIENT_CMD_SEND_MSG_TO_SERVER = 0x801 --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = 'level', type = T.SHORT}, --游戏level
        {name = 'msg', type = T.STRING}
    }
}

P.CLI_READYNOW_ROOM = 0x2001 --用户发送准备
CLIENT[P.CLI_READYNOW_ROOM] = {
    ver = 1,
    {name = 'readyState', type = T.INT} -- 0是取消准备，1是准备
}

P.CLI_LOGIN_ROOM = 0x1001 --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = 'tid', type = T.INT}, --桌子ID
        {name = 'uid', type = T.INT}, --用户ID
        {name = 'sex', type = T.BYTE}, --需要验证的key
        --{name = "seatId", type = T.INT}, --需要验证的key
        {name = 'nickName', type = T.STRING}, --用户个人信息
        {name = 'portrait', type = T.STRING}, --用户个人信息
        {name = 'latitude', type = T.STRING}, --用户个人信息
        {name = 'longitude', type = T.STRING}, --用户个人信息
        {name = 'otherInfo', type = T.STRING}, --用户个人信息
        {name = 'activityId', type = T.INT}, --用户个人信息
        {name = 'city', type = T.STRING}, --用户个人信息
        {name = 'ip', type = T.STRING}, --用户个人信息
        {name = 'isWatch', type = T.BYTE} --1玩家 0围观
    }
}

P.CLIENT_COMMAND_START_GAME = 0x2002 --请求开始游戏
CLIENT[P.CLIENT_COMMAND_START_GAME] = {
    ver = 1
}

P.CLI_USER_BASES = 0x2008 --用户加倍倍数
CLIENT[P.CLI_USER_BASES] = {
    ver = 1,
    fmt = {
        {name = 'bases', type = T.INT} --倍数
    }
}

P.CLI_QIANGZHUANG = 0x2007 --用户抢庄
CLIENT[P.CLI_QIANGZHUANG] = {
    ver = 1,
    fmt = {
        {name = 'if_qiang', type = T.INT} --是否抢庄
    }
}

P.CLI_PLAY_CARD = 0x2003 --玩家出牌
CLIENT[P.CLI_PLAY_CARD] = {
    ver = 1,
    fmt = {
        {name = 'mount', type = T.BYTE}, --数量
        {
            name = 'cards',
            type = T.ARRAY,
            fixedLengthParser = 'mount',
            fixedLength = 0,
            fmt = {
                {name = 'card', type = T.BYTE} --牌
            }
        }
    }
}

P.CLI_LOGIN = 0x0116 --登录大厅
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT},
        {name = 'storeId', type = T.INT},
        {name = 'kind', type = T.INT},
        {name = 'userInfo', type = T.STRING}
    }
}

--请求解散房间
P.C2G_CMD_DISSOLVE_ROOM = 0x808
CLIENT[P.C2G_CMD_DISSOLVE_ROOM] = {
    ver = 1
}

--回复请求解散房间
P.C2G_CMD_REPLY_DISSOLVE_ROOM = 0x809
CLIENT[P.C2G_CMD_REPLY_DISSOLVE_ROOM] = {
    ver = 1,
    fmt = {
        {name = 'agree', type = T.INT} --0为拒绝解散，1为解散
    }
}

P.BROADCAST_ERROR_STATUS = 0x159
SERVER[P.BROADCAST_ERROR_STATUS] = {
    ver = 1,
    fmt = {
        {name = 'errorCode', type = T.SHORT}
    }
}

--获取筹码
P.CLI_GET_CHIP = 0x806
CLIENT[P.CLI_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT} --用户id
    }
}

--兑换筹码
P.CLI_CHANGE_CHIP = 0x805
CLIENT[P.CLI_CHANGE_CHIP] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'chip', type = T.INT} --请求兑换筹码数
    }
}

--押注
P.CLIENT_CMD_YA = 0x1101
CLIENT[P.CLIENT_CMD_YA] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT},
        {name = 'zhu', type = T.INT}
    }
}
--出牌
P.CLIENT_CMD_OUT_CARD = 0x1103
CLIENT[P.CLIENT_CMD_OUT_CARD] = {
    ver = 1
}

P.CLIENT_CMD_REQ_YAZHU_INFO = 0x1106
CLIENT[P.CLIENT_CMD_REQ_YAZHU_INFO] = {
    ver = 1
}
P.CLIENT_CMD_REQ_YAZHU_DETAILS = 0x1107
CLIENT[P.CLIENT_CMD_REQ_YAZHU_DETAILS] = {
    ver = 1,
    fmt = {
        {name = 'seatId', type = T.INT}
    }
}
P.CLIENT_CMD_GIVE_COINS = 0x2002
CLIENT[P.CLIENT_CMD_GIVE_COINS] = {
    ver = 1,
    fmt = {
        {name = 'desUid', type = T.INT},
        {name = 'coins', type = T.INT}
    }
}

P.CLIENT_CMD_REQ_TEST = 0x110B --请求带控
CLIENT[P.CLIENT_CMD_REQ_TEST] = {
    ver = 1
}
P.CLIENT_CMD_START_GAME = 0x2006
--请求开始游戏
CLIENT[P.CLIENT_CMD_START_GAME] = {
    ver = 1
}
P.CLIENT_CMD_TEST = 0x110C --带控
CLIENT[P.CLIENT_CMD_TEST] = {
    ver = 1,
    fmt = {
        --{name = "seatId", type = T.INT}, --uid
        {name = 'rank', type = T.BYTE} --排名
    }
}

P.CLI_COMMAND_GAMERESULT_RECORD = 0x1050
CLIENT[P.CLI_COMMAND_GAMERESULT_RECORD] = {
    ver = 1,
    fmt = {
        {name = 'resultIndex', type = T.INT} --请求战绩记录 传0 代表上一把,传某个数字代表带一把,传的下标过大表示要上一把
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_HEART = 0x110 --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

P.SERVER_CMD_RECORD_PAPER = 0x1035 --请求录纸返回
SERVER[P.SERVER_CMD_RECORD_PAPER] = {
    ver = 1,
    fmt = {
        {name = 'record_paper_size', type = T.BYTE},
        {
            name = 'record_paper',
            type = T.ARRAY,
            fixedLengthParser = 'record_paper_size',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}, --头像
                {name = 'single_record_paper_size', type = T.BYTE},
                {
                    name = 'single_record_paper',
                    type = T.ARRAY,
                    fixedLengthParser = 'single_record_paper_size',
                    fixedLength = 0,
                    fmt = {
                        {name = 'balance', type = T.INT},
                        {name = 'niuType', type = T.BYTE}
                        --游戏玩家数
                    }
                }
            }
        }
    }
}

P.BROADCAST_USER_AUTO_PLAY = 0x1034 --广播用户托管
SERVER[P.BROADCAST_USER_AUTO_PLAY] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT},
        {name = 'isAuto', type = T.BYTE}
    }
}

P.BROADCAST_USER_QUIT_ROOM = 0x1033 --广播用户退出
SERVER[P.BROADCAST_USER_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}
    }
}

P.BROADCAST_USER_SIT_DOWN = 0x1031 --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT},
        {name = 'seatId', type = T.INT},
        {name = 'sex', type = T.BYTE}, --座位id
        {name = 'nickName', type = T.STRING}, --用户json字符串
        {name = 'portrait', type = T.STRING}, --用户金币
        {name = 'gold', type = T.INT}, --用户金币
        {name = 'winLoseCount', type = T.INT},
        {name = 'latitude', type = T.STRING}, --用户赢数
        {name = 'longitude', type = T.STRING}, --用户输数
        {name = 'ip', type = T.STRING} --用户状态
    }
}

P.BROADCAST_USER_STAND_UP = 0x1032 --站起
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}
    }
}

P.BROADCAST_ERROR_TIPS = 0x5001 --错误提示
SERVER[P.BROADCAST_ERROR_TIPS] = {
    ver = 1,
    fmt = {
        {name = 'errorCode', type = T.SHORT}
    }
}

P.BROADCAST_USER_IP = 0x106A
SERVER[P.BROADCAST_USER_IP] = {
    ver = 1,
    fmt = {
        {name = 'playercount', type = T.INT},
        {
            name = 'playeripdata',
            type = T.ARRAY,
            fixedLengthParser = 'playercount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'ip', type = T.STRING}
                --游戏玩家数
            }
        }
    }
}

P.SVR_LOGIN_OK = 0x0201 --登录成功
SERVER[P.SVR_LOGIN_OK] = {
    ver = 1,
    fmt = {
        {name = 'ver', type = T.INT},
        {name = 'levelCount', type = T.INT},
        --等级场个数
        {
            name = 'usercount',
            type = T.ARRAY,
            fixedLengthParser = 'levelCount',
            fixedLength = 0,
            fmt = {
                {type = T.INT} --人数
            }
        },
        {name = 'friends', type = T.INT}, --好友数
        {name = 'tid', type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = 'ip', type = T.STRING}, --ip
        {name = 'port', type = T.INT} --端口
        -- {name = "level", type = T.INT}   -- level
    }
}

P.SVR_QUIT_ROOM = 0x100E --广播玩家推出返回
SERVER[P.SVR_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT} --用户id
    }
}

P.SVR_NO_GOLD = 0x700A --svr返回金币不足
SERVER[P.SVR_NO_GOLD] = {
    ver = 1,
    fmt = {
        {name = 'type', type = T.INT} --返回码
    }
}

P.SVR_BROADCAST_COUNT_DOWN = 0x100f --广播倒计时
SERVER[P.SVR_BROADCAST_COUNT_DOWN] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.BYTE} --返回码
    }
}

P.SVR_BRANKRUPT = 0x7002 --破产
SERVER[P.SVR_BRANKRUPT] = {
    ver = 1,
    fmt = {
        {name = 'type', type = T.INT} --返回码
    }
}

P.SERVER_COMMAND_KICK_OUT_ROOM = 0x7007 --新加协议
SERVER[P.SERVER_COMMAND_KICK_OUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = 'type', type = T.INT} --返回码
    }
}

P.SVR_USER_READY_BROADCAST = 0x6001 --广播用户准备
SERVER[P.SVR_USER_READY_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT} --用户id
    }
}

P.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST = 0x6013 --广播玩家抢庄结果（返回）
SERVER[P.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'if_qiang', type = T.INT}, --是否抢庄
        {name = 'isShowHandleView', type = T.BYTE} --是否显示操作界面
    }
}

P.SVR_USER_BASES_RESULT_BROADCAST = 0x6014 --广播玩家加倍倍数
SERVER[P.SVR_USER_BASES_RESULT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'base', type = T.INT}, --倍数
        {name = 'isShowHandleView', type = T.BYTE}
        --是否显示操作界面
    }
}

P.SVR_PLAY_CARD_BROADCAST = 0x6004 --广播玩家开始出牌
SERVER[P.SVR_PLAY_CARD_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.INT}, --超时时间
        {name = 'isShowHandleView', type = T.BYTE} --是否显示操作界面
    }
}

P.SVR_READY_BROADCAST = 0x6001 --广播玩家准备
SERVER[P.SVR_READY_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT} --用户id
    }
}

P.SVR_USER_PLAYED_CARDS_PRE_BROADCAST = 0x6002 --不知道什么鬼
SERVER[P.SVR_USER_PLAYED_CARDS_PRE_BROADCAST] = {
    ver = 1
}
-- end

P.SVR_COST_TAI = 0x6017 --扣除台费
SERVER[P.SVR_COST_TAI] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'tai', type = T.INT}, --台费
        {name = 'money', type = T.INT}, --用户金币
        {name = 'lmoney', type = T.INT64} --用户超级金币
    }
}

P.SVR_BRANK_BROADCAST = 0x6003 --广播庄家id
SERVER[P.SVR_BRANK_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'isShowHandleView', type = T.BYTE}
        --是否显示操作界面
    }
}

P.SVR_SEND_USER_CARD = 0x4001 --发送用户的牌信息
SERVER[P.SVR_SEND_USER_CARD] = {
    ver = 1,
    fmt = {
        {name = 'mount', type = T.SHORT}, --牌的数量
        {
            name = 'cards',
            type = T.ARRAY,
            fixedLengthParser = 'mount',
            fixedLength = 0,
            fmt = {
                {name = 'card', type = T.BYTE} --牌
            }
        },
        {name = 'userMount', type = T.BYTE},
        {
            name = 'users',
            type = T.ARRAY,
            fixedLengthParser = 'userMount',
            fixedLength = 0,
            fmt = {
                {name = 'seatId', type = T.BYTE},
                {name = 'mount', type = T.BYTE}, --牌的数量
                {
                    name = 'cards',
                    type = T.ARRAY,
                    fixedLengthParser = 'mount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'card', type = T.BYTE} --牌
                    }
                }
            }
        }
    }
}

P.SERVER_COMMAND_REMAID_START_GAME = 0x4009 --提示用户，可以开始游戏
SERVER[P.SERVER_COMMAND_REMAID_START_GAME] = {
    ver = 1
}

P.SERVER_COMMAND_REMAID_START_GAME_FAIL = 0x400A --提示用户，开始游戏失败，有玩家未准备
SERVER[P.SERVER_COMMAND_REMAID_START_GAME_FAIL] = {
    ver = 1
}

P.SVR_BROADCAST_GAME_START = 0x6002 --广播牌局可以开始准备
SERVER[P.SVR_BROADCAST_GAME_START] = {
    ver = 1,
    fmt = {
        {name = 'send_card_num', type = T.BYTE} --发几张牌
    }
}

P.SVR_LOGIN_ROOM_FAIL = 0x1005 --登陆房间失败提示
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = 'errorCode', type = T.INT} --错误码
    }
}

P.SVR_OPEN_CARDS_BROADCAST = 0x1043 --玩家开始摊牌
SERVER[P.SVR_OPEN_CARDS_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'openCardTime', type = T.BYTE}, --手牌数量
        {name = 'user_mount', type = T.BYTE}, --闲家数量
        {
            name = 'user_cards',
            type = T.ARRAY,
            fixedLengthParser = 'user_mount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'handCardCount', type = T.BYTE}, --手牌数量
                {
                    name = 'handCardArr',
                    type = T.ARRAY,
                    fixedLengthParser = 'handCardCount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'card', type = T.BYTE} --牌
                    }
                }
            }
        }
    }
}

P.SVR_SETTLEMENT_BROADCAST = 0x6008 --广播游戏结算信息
SERVER[P.SVR_SETTLEMENT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'user_mount', type = T.BYTE}, --用户数量
        {
            name = 'userinfo',
            type = T.ARRAY,
            fixedLengthParser = 'user_mount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}, --用户id
                {name = 'seatId', type = T.BYTE}, --用户id
                {name = 'gold', type = T.INT}, --玩家金币
                {name = 'score', type = T.INT} --玩家输赢
            }
        }
    }
}

P.SVR_BEGIN_QIANFGZHUANG_BROADCAST = 0x6015 --广播开始抢庄（返回）
SERVER[P.SVR_BEGIN_QIANFGZHUANG_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'grab_times_mount', type = T.BYTE}, --数量
        {
            name = 'grab_times',
            type = T.ARRAY,
            fixedLengthParser = 'grab_times_mount',
            fixedLength = 0,
            fmt = {
                {type = T.BYTE} --倍数
            }
        },
        {name = 'mount', type = T.BYTE},
        {
            name = 'ids',
            type = T.ARRAY,
            fixedLengthParser = 'mount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}, --用户id
                {name = 'can_grab_times_mount', type = T.BYTE}, --用户id
                {
                    name = 'can_grab_times',
                    type = T.ARRAY,
                    fixedLengthParser = 'can_grab_times_mount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'times', type = T.BYTE} --倍数
                    }
                }
            }
        },
        {name = 'time', type = T.INT}, --抢庄超时时间
        {name = 'isShowHandleView', type = T.BYTE}
        --是否显示操作界面
    }
}

--组局时长
P.SVR_GROUP_TIME = 0x5101
SERVER[P.SVR_GROUP_TIME] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.INT},
        {name = 'round', type = T.INT},
        {name = 'round_total', type = T.INT}
    }
}

P.SVR_LOGIN_ROOM_BROADCAST = 0x100D --登陆房间广播
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'seatId', type = T.INT}, --用户座位ID
        {name = 'sex', type = T.BYTE}, --用户座位ID
        {name = 'nickName', type = T.STRING}, --
        {name = 'portrait', type = T.STRING}, --
        {name = 'latitude', type = T.STRING}, --
        {name = 'longitude', type = T.STRING}, --
        {name = 'otherInfo', type = T.STRING}, --用户个人信息
        {name = 'ip', type = T.STRING}, --
        {name = 'gold', type = T.INT} --
    }
}

P.SVR_LOGIN_ROOM = 0x1007 --登陆房间返回
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = 'gamePattern', type = T.BYTE}, --房间类型   0金币场  1 房卡场
        {name = 'activityId', type = T.INT}, --activityId
        {name = 'isWatch', type = T.INT}, --1玩家 0围观
        {name = 'inviteCode', type = T.STRING}, --邀请码
        {name = 'baseChip', type = T.INT}, -- 下注倍率 *10 *100.....
        {name = 'club_id', type = T.INT}, -- 俱乐部id
        {name = 'star_game_uid', type = T.INT}, --等于自己房主就可以开始游戏
        {name = 'initialChip', type = T.INT}, --初始筹码
        {name = 'times', type = T.INT}, --最高筹码
        {name = 'tableStatus', type = T.BYTE}, --桌子状态
        {name = 'outCardAniTime', type = T.INT},
        {name = 'gold', type = T.INT},
        {name = 'user_mount', type = T.BYTE}, --用户数量
        {
            name = 'gamePlayerArr',
            type = T.ARRAY,
            fixedLengthParser = 'user_mount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}, --用户id
                {name = 'gold_status', type = T.BYTE}, --1下注 0未下注
                {name = 'sex', type = T.BYTE}, --座位id
                {name = 'nickName', type = T.STRING}, --用户json字符串
                {name = 'portrait', type = T.STRING}, --用户金币
                {name = 'latitude', type = T.STRING}, --用户赢数
                {name = 'longitude', type = T.STRING}, --用户输数
                {name = 'otherInfo', type = T.STRING}, --用户个人信息
                {name = 'ip', type = T.STRING}, --用户状态
                {name = 'city', type = T.STRING}, --城市
                {name = 'gold', type = T.INT}, --金币
                {name = 'seatId', type = T.INT}, --座位id
                {name = 'onLine', type = T.BYTE}, --是否在线
                {name = 'ready', type = T.BYTE}, --是否准备
                -- {name = 'isAuto', type = T.BYTE}, --是否托管
                {name = 'user_status', type = T.INT}, --用户状态
                {name = 'handCardCount', type = T.BYTE},
                {
                    name = 'handCardArr',
                    type = T.ARRAY,
                    fixedLengthParser = 'handCardCount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'card', type = T.BYTE}
                    }
                },
                {name = 'totalGold', type = T.INT},
                {name = 'winLoseCount', type = T.INT},
                {name = 'cards_type', type = T.BYTE},
                {name = 'cards_point', type = T.BYTE},
                {name = 'maxCard', type = T.BYTE}
            }
        },
        {name = 'gameConfig', type = T.STRING}
    }
}

--组局排行榜
P.SVR_GROUP_BILLBOARD = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] = {
    ver = 1,
    fmt = {
        {name = 'playercount', type = T.BYTE},
        {
            name = 'playerlist',
            type = T.ARRAY,
            fixedLengthParser = 'playercount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'sex', type = T.BYTE},
                {name = 'nickName', type = T.STRING}, --游戏玩家数
                {name = 'portrait', type = T.STRING}, --游戏玩家数
                {name = 'chips', type = T.INT}
            }
        },
        {name = 'game_amount', type = T.INT} --总局数
    }
}

P.SERVER_CMD_FORWARD_MESSAGE = 0x0213 --服务器返回组局收到的缓存信息
SERVER[P.SERVER_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = 'msgCount', type = T.INT}, --消息长度
        {
            name = 'msgList',
            type = T.ARRAY,
            fixedLengthParser = 'msgCount',
            fixedLength = 0,
            fmt = {
                {name = 'msg', type = T.STRING} --消息
            }
        }
    }
}

P.SERVER_CMD_MESSAGE = 0x801 --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = 'msg', type = T.STRING} --消息
    }
}

P.SERVER_CMD_REQ_TEST = 0x110B --请求带控返回
SERVER[P.SERVER_CMD_REQ_TEST] = {
    ver = 1,
    fmt = {
        {name = 'seatCount', type = T.BYTE},
        {name = 'count', type = T.BYTE},
        {
            name = 'testSeats',
            type = T.ARRAY,
            fixedLengthParser = 'count',
            fixlength = 0,
            fmt = {
                {name = 'seatId', type = T.INT},
                {name = 'rank', type = T.INT}
            }
        }
    }
}

P.SERVER_CMD_TEST = 0x110C --带控返回
SERVER[P.SERVER_CMD_TEST] = {
    ver = 1,
    fmt = {
        {name = 'errorCode', type = T.BYTE}, --错误码
        {name = 'count', type = T.BYTE},
        {
            name = 'testSeats',
            type = T.ARRAY,
            fixedLengthParser = 'count',
            fixlength = 0,
            fmt = {
                {name = 'seatId', type = T.INT},
                {name = 'rank', type = T.INT}
            }
        }
    }
}

P.SVR_READY_TIME = 0x6009 --广播牌局可以开始准备
SERVER[P.SVR_READY_TIME] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.INT} --准备超时时间
    }
}

P.SVR_QUICK_SUC = 0x1008 --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1
}

--组局历史记录
P.SVR_GET_HISTORY = 0x907
SERVER[P.SVR_GET_HISTORY] = {
    ver = 1,
    fmt = {
        {name = 'playercount', type = T.INT},
        {
            name = 'playerlist',
            type = T.ARRAY,
            fixedLengthParser = 'playercount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'user_info', type = T.STRING}
                --游戏玩家数
            }
        },
        {name = 'history', type = T.STRING}
    }
}

--请求兑换筹码返回
P.SVR_CHANGE_CHIP = 0x905
SERVER[P.SVR_CHANGE_CHIP] = {
    ver = 1,
    fmt = {
        {name = 'ret', type = T.INT}, --成功与否标注，0成功
        {name = 'uid', type = T.INT}, --兑换筹码的uid
        {name = 'chip', type = T.INT}, --服务器ID
        {name = 'money', type = T.INT} --玩家剩余宝贝币
    }
}

--解散房间相关
--没有此房间，解散房间失败  0x908
P.G2H_CMD_DISSOLVE_FAILED = 0x908
SERVER[P.G2H_CMD_DISSOLVE_FAILED] = {
    ver = 1
}

--广播当前组局解散情况
P.G2H_CMD_REFRESH_DISSOLVE_LIST = 0x909
SERVER[P.G2H_CMD_REFRESH_DISSOLVE_LIST] = {
    ver = 1,
    fmt = {
        {name = 'applyId', type = T.INT},
        --申请解散房间的用户id
        {name = 'agreeNum', type = T.INT},
        --当前同意解散的人数
        {
            name = 'agreeMember_arr',
            type = T.ARRAY,
            fixedLengthParser = 'agreeNum',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}--已经同意解散的用户
            }
        }
    }
}

--广播桌子用户请求解散组局
P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP = 0x102A
SERVER[P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
        {name = 'applyId', type = T.INT} --申请解散房间的用户id
    }
}

--广播桌子用户成功解散组局
P.SERVER_BROADCAST_DISSOLVE_GROUP = 0x103A
SERVER[P.SERVER_BROADCAST_DISSOLVE_GROUP] = {
    ver = 1
}

--广播桌子用户解散组局 ，解散组局失败
P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP = 0x104A
SERVER[P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
        {name = 'rejectId', type = T.INT} --拒绝的用户id
    }
}

P.SVR_CHARGE_BROADCAST = 0x111
SERVER[P.SVR_CHARGE_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT},
        {name = 'chargeCoins', type = T.INT}
    }
}

--推锅里的筹码
P.SVR_guochip = 0x5102
SERVER[P.SVR_guochip] = {
    ver = 1,
    fmt = {
        {name = 'chips', type = T.INT}
    }
}

--推锅斗牛里广播庄从筹码里拿筹码到锅里
P.SVR_tuiguo_zuang_start = 0x5103
SERVER[P.SVR_tuiguo_zuang_start] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT},
        --新庄用户UID
        {name = 'chips', type = T.INT}
    }
}

--推锅斗牛里广播庄从锅里拿回属于自己的筹码
P.SVR_tuiguo_zuang_end = 0x5104
SERVER[P.SVR_tuiguo_zuang_end] = {
    ver = 1,
    fmt = {
        {name = 'chips', type = T.INT}
    }
}

--  ========================三公===========================
P.SERVER_BROADCAST_START_YA = 0x1100 ---开始押注
SERVER[P.SERVER_BROADCAST_START_YA] = {
    ver = 1,
    fmt = {
        {name = 'outCardAniTime', type = T.BYTE}
    }
}

P.SERVER_BROADCAST_YA = 0x1101 --- 广播押注
SERVER[P.SERVER_BROADCAST_YA] = {
    ver = 1,
    fmt = {
        {name = 'desUid', type = T.INT}, --压在谁身上
        {name = 'uid', type = T.INT}, --谁押注
        {name = 'gold', type = T.INT}, --这个位置剩余钱数
        {name = 'chip', type = T.INT}, --押了多少
        {name = 'total', type = T.INT},
        {name = 'myTotal', type = T.INT}
    }
}

P.SERVER_BROADCAST_CARD = 0x1102
SERVER[P.SERVER_BROADCAST_CARD] = {
    ver = 1,
    fmt = {
        {name = 'outCardAniTime', type = T.BYTE},
        {name = 'shaiCard', type = T.BYTE},
        {name = 'bankSeatId', type = T.INT},
        {name = 'gamePlayerCount', type = T.BYTE},
        {
            name = 'gamePlayerArr',
            type = T.ARRAY,
            fixedLengthParser = 'gamePlayerCount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'handCardCount', type = T.BYTE},
                {
                    name = 'handCardArr',
                    type = T.ARRAY,
                    fixedLengthParser = 'handCardCount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'card', type = T.BYTE}
                    }
                }
            }
        }
    }
}

P.SERVER_BROADCAST_OUT_CARD = 0x1103 -- 广播出牌
SERVER[P.SERVER_BROADCAST_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = 'outCardAniTime', type = T.BYTE},
        {name = 'uid', type = T.INT},
        {name = 'handCardCount', type = T.BYTE},
        {
            name = 'handCardArr',
            type = T.ARRAY,
            fixedLengthParser = 'handCardCount',
            fixedLength = 0,
            fmt = {
                {name = 'card', type = T.BYTE}
            }
        },
        {name = 'cards_type', type = T.BYTE},
        {name = 'cards_point', type = T.BYTE},
        {name = 'maxCard', type = T.BYTE}
    }
}

P.SERVER_BROADCAST_OPEN_CARD = 0x1104 --- 开牌
SERVER[P.SERVER_BROADCAST_OPEN_CARD] = {
    ver = 1,
    fmt = {
        {name = 'outCardAniTime', type = T.BYTE},
        {name = 'gamePlayerCount', type = T.BYTE},
        {
            name = 'gamePlayerArr',
            type = T.ARRAY,
            fixedLengthParser = 'gamePlayerCount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'handCardCount', type = T.BYTE},
                {
                    name = 'handCardArr',
                    type = T.ARRAY,
                    fixedLengthParser = 'handCardCount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'card', type = T.BYTE}
                    }
                },
                {name = 'cards_type', type = T.BYTE},
                {name = 'cards_point', type = T.BYTE},
                {name = 'maxCard', type = T.BYTE}
            }
        }
    }
}


P.SERVER_BROADCAST_START_OUT_CARD = 0x110A --- 出牌
SERVER[P.SERVER_BROADCAST_START_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = 'outCardAniTime', type = T.BYTE}
    }
}

P.SERVER_CMD_REQ_YAZHU_INFO = 0x1106 --请求押注情况
SERVER[P.SERVER_CMD_REQ_YAZHU_INFO] = {
    ver = 1,
    fmt = {
        {name = 'gamePlayerCount', type = T.BYTE},
        {
            name = 'gamePlayerArr',
            type = T.ARRAY,
            fixedLengthParser = 'gamePlayerCount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'seatId', type = T.INT},
                {name = 'total', type = T.INT},
                {name = 'my_total', type = T.INT}
            }
        }
    }
}
P.SERVER_CMD_REQ_YAZHU_DETAILS = 0x1107
SERVER[P.SERVER_CMD_REQ_YAZHU_DETAILS] = {
    ver = 1,
    fmt = {
        {name = 'total', type = T.INT},
        {name = 'count', type = T.INT},
        {
            name = 'countArr',
            type = T.ARRAY,
            fixedLengthParser = 'count',
            fixedLength = 0,
            fmt = {
                {name = 'no', type = T.STRING},
                {name = 'time', type = T.STRING},
                {name = 'portrait', type = T.STRING},
                {name = 'nickName', type = T.STRING},
                {name = 'zhu', type = T.INT}
            }
        }
    }
}
P.SERVER_NOTIFY_RESULT = 0x1108
SERVER[P.SERVER_NOTIFY_RESULT] = {
    ver = 1,
    fmt = {
        {name = 'gold', type = T.INT},
        {name = 'score', type = T.INT}
    }
}
--请求开始游戏
P.SERVER_BROADCAST_START_GAME = 0x2006
SERVER[P.SERVER_BROADCAST_START_GAME] = {
    ver = 1,
    fmt = {
        {name = 'star_game_uid', type = T.INT}
    }
}
P.SERVER_READYNOW_ROOM = 0x2001 --广播用户准备
SERVER[P.SERVER_READYNOW_ROOM] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}
        -- {name = "readyState", type = T.INT},  -- 0是取消准备，1是准备
    }
}

P.SERVER_BROADCAST_GIVE_COINS = 0x2002
SERVER[P.SERVER_BROADCAST_GIVE_COINS] = {
    ver = 1,
    fmt = {
        {name = 'fromUid', type = T.INT},
        {name = 'fromCoins', type = T.INT},
        {name = 'toUid', type = T.INT},
        {name = 'toCoins', type = T.INT}
    }
}
P.SERVER_BROADCAST_WINLOSE_COUNT = 0x1109
--单局结算
SERVER[P.SERVER_BROADCAST_WINLOSE_COUNT] = {
    ver = 1,
    fmt = {
        {name = 'gamePlayerCount', type = T.BYTE},
        {
            name = 'gamePlayerArr',
            type = T.ARRAY,
            fixedLengthParser = 'gamePlayerCount',
            fixedLength = 0,
            fmt = {
                {name = 'winLoseCount', type = T.INT}
            }
        }
    }
}
P.SVR_BROADCAST_WAIT_START = 0x1100 --广播各阶段倒计时
SERVER[P.SVR_BROADCAST_WAIT_START] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.BYTE} --剩余时间
    }
}

P.BROADCAST_SENDCARD_REMAINDTIME = 0x1041 --广播下注
SERVER[P.BROADCAST_SENDCARD_REMAINDTIME] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.BYTE}
    }
}

P.SVR_CHIP_CHANGE_BROADCAST = 0x4800 --广播玩家钱数变化（用于扣取台费）
SERVER[P.SVR_CHIP_CHANGE_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'user_mount', type = T.BYTE}, --闲家数量
        {
            name = 'userinfo',
            type = T.ARRAY,
            fixedLengthParser = 'user_mount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}, --用户id
                {name = 'change_chip', type = T.INT} --玩家输赢倍数
            }
        }
    }
}

P.SVR_SEND_USED_CARDS = 0x11111 --发送用户的牌信息
SERVER[P.SVR_SEND_USED_CARDS] = {
    ver = 1,
    fmt = {
        {name = 'mount', type = T.SHORT}, --牌的数量
        {
            name = 'cards',
            type = T.ARRAY,
            fixedLengthParser = 'mount',
            fixedLength = 0,
            fmt = {
                {name = 'card', type = T.BYTE} --牌
            }
        }
    }
}

P.SERVER_COMMAND_GAMERESULT_RECORD = 0x1050
SERVER[P.SERVER_COMMAND_GAMERESULT_RECORD] = {
    ver = 1,
    fmt = {
        {name = 'resultIndex', type = T.INT}, --结果的下标 如果是0,代表还没有数据
        {name = 'resultCount', type = T.INT}, --前面总共有多少把的历史战绩了
        {name = 'gameResultCount', type = T.INT}, --数量
        {
            name = 'gameResult',
            type = T.ARRAY,
            fixedLengthParser = 'gameResultCount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'smallPhoto', type = T.STRING},
                {name = 'nickName', type = T.STRING},
                {name = 'card_mount', type = T.BYTE}, --牌的数量
                {
                    name = 'cards',
                    type = T.ARRAY,
                    fixedLengthParser = 'card_mount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'card', type = T.BYTE} --牌
                    }
                },
                {name = 'cards_type', type = T.INT}, --三公类型
                {name = 'cards_point', type = T.INT}, --点数
                {name = 'maxCard', type = T.INT}, --最大的牌
                {name = 'xiazhu', type = T.INT}, --下注的筹码
                {name = 'changeChip', type = T.INT} --输赢分
            }
        }
    }
}

return HALL_SERVER_PROTOCOL
