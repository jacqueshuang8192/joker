--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require('hall.HALL_PROTOCOL')
local P = class('HALL_SERVER_PROTOCOL', HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P
-- P.CONFIG = {}
-- P.CONFIG.CLIENT = {}
-- P.CONFIG.SERVER = {}
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

P.CLI_REQUEST_CHECK_XIAZHU = 0x1039 --请求查看下注情况
CLIENT[P.CLI_REQUEST_CHECK_XIAZHU] = {
    ver = 1
}

P.CLI_REQUEST_BET = 0x1040 --外围请求下注
CLIENT[P.CLI_REQUEST_BET] = {
    ver = 1,
    fmt = {
        {name = 'seat_id', type = T.INT},
        {name = 'betChip', type = T.INT}
    }
}

P.CLI_REQUEST_GRAB_BANKER = 0x1041 --外围请求坐庄
CLIENT[P.CLI_REQUEST_GRAB_BANKER] = {
    ver = 1,
    fmt = {
        {name = 'seat_id', type = T.INT}
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
        {name = 'isOpenAuto', type = T.BYTE},
        {name = 'grab_times', type = T.BYTE},
        {name = 'bet_times', type = T.BYTE}
    }
}

P.CLI_QUIT_ROOM = 0x1033 --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1
}

P.CLI_SIT_DOWN = 0x1031 --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    {name = 'seat_id', type = T.INT} --座位id
}

P.CLI_STAND_UP = 0x1032 --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1
}

-- if GROUP_MODE == 2 then
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
            {name = 'seat_id', type = T.INT}, --需要验证的key
            {name = 'sex', type = T.BYTE}, --需要验证的key
            {name = 'nickName', type = T.STRING}, --用户个人信息
            {name = 'portrait', type = T.STRING}, --用户个人信息
            {name = 'latitude', type = T.STRING}, --用户个人信息
            {name = 'longitude', type = T.STRING}, --用户个人信息
            {name = 'otherInfo', type = T.STRING}, --用户个人信息
            {name = 'activityId', type = T.INT}, --用户个人信息
            {name = 'isWatch', type = T.BYTE}, --1玩家 0围观
            -- {name = 'ip', type = T.INT} --用户个人信息
        }
    }
-- else
--     --P.CLI_GET_ROOM                   = 0x0113    --获取房间id
--     --CLIENT[P.CLI_GET_ROOM] = {
--     --    ver = 1,
--     --    fmt = {
--     --        {name = "level", type = T.SHORT},   --桌子等级
--     --        {name = "Chip", type = T.INT},--请求场次的底注
--     --        {name = "Sid", type = T.INT},--游戏场的id
--     --        {name = "activity_id", type = T.STRING}, --带入活动id
--     --    }
--     --}
--     P.CLIENT_CMD_FORWARD_MESSAGE = 0x165 --向服务器发送向组局里发送的缓存信息
--     CLIENT[P.CLIENT_CMD_FORWARD_MESSAGE] = {
--         ver = 1,
--         fmt = {
--             {name = 'level', type = T.SHORT}, --游戏level
--             {name = 'msg', type = T.STRING}
--         }
--     }

--     P.CLIENT_CMD_SEND_MSG_TO_SERVER = 0x166 --向服务器发送向组局里发送的缓存信息
--     CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
--         ver = 1,
--         fmt = {
--             {name = 'level', type = T.SHORT}, --游戏level
--             {name = 'msg', type = T.STRING}
--         }
--     }

--     P.CLI_READYNOW_ROOM = 0x2001 --用户发送准备
--     CLIENT[P.CLI_READYNOW_ROOM] = {
--         ver = 1
--     }

--     P.CLI_LOGIN_ROOM = 0x1001 --登录房间
--     CLIENT[P.CLI_LOGIN_ROOM] = {
--         ver = 1,
--         fmt = {
--             {name = 'tid', type = T.INT}, --桌子ID
--             {name = 'uid', type = T.INT}, --用户ID
--             {name = 'mtkey', type = T.STRING}, --需要验证的key
--             {name = 'strinfo', type = T.STRING} --用户个人信息
--         }
--     }
-- end

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

-- -- 广播桌子状态
-- P.SERVER_CMD_TABLE_STATE       = 0x159
-- SERVER[P.SERVER_CMD_TABLE_STATE] = {
--     ver = 1,
--     fmt = {
--         {name = "type",type = T.BYTE},
--         {name = "m_nLevel",type = T.SHORT},
--         {name = "tid",type = T.INT}
--     }
-- }

--获取押注情况
P.CLI_CMD_REQ_YAZHU_INFO = 0x1106
CLIENT[P.CLI_CMD_REQ_YAZHU_INFO] = {
    ver = 1
}

--获取押注详情
P.CLI_CMD_REQ_YAZHU_DETAILS = 0x1107
CLIENT[P.CLI_CMD_REQ_YAZHU_DETAILS] = {
    ver = 1,
    fmt = {
        {name = 'seatId', type = T.INT} --用户id
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

P.CLI_COMMAND_REQ_WAIWEI_RESULT = 0x110B --抢外围庄
SERVER[P.CLI_COMMAND_REQ_WAIWEI_RESULT] = {
    ver = 1
}

P.CLI_COMMAND_GRAB_WW_DEALER = 0x110A --抢外围庄
SERVER[P.CLI_COMMAND_GRAB_WW_DEALER] = {
    ver = 1
}

--文字聊天相关
P.CLI_MSG_FACE = 0x1104
CLIENT[P.CLI_MSG_FACE] = {
    ver = 1,
    fmt = {
        {name = 'type', type = T.INT}
    }
}

P.CLI_SEND_TEST_CARD = 0x1110
CLIENT[P.CLI_SEND_TEST_CARD] = {
    ver = 1,
    fmt = {
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

P.CLI_SEND_UP_BANK = 0x2014
CLIENT[P.CLI_SEND_UP_BANK] = {
    ver = 1,
    fmt = {
        {name = 'opt', type = T.BYTE} --牌的数量
    }
}

P.CLI_SEND_DOWN_BANK = 0x2015
CLIENT[P.CLI_SEND_DOWN_BANK] = {
    ver = 1,
    fmt = {
        {name = 'opt', type = T.BYTE} --牌的数量
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

P.SERVER_CMD_BONUS_RECORD = 0x1039 --请求查看下注情况返回
SERVER[P.SERVER_CMD_BONUS_RECORD] = {
    fmt = {
        ver = 1,
        {name = 'max_player_count', type = T.BYTE},
        {
            name = 'bonus_record',
            type = T.ARRAY,
            fixedLengthParser = 'max_player_count',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT},
                {name = 'total_bet_count', type = T.INT},
                {name = 'my_bet_count', type = T.INT}
            }
        }
    }
}

P.BROADCAST_SENDCARD_REMAINDTIME = 0x1041 --广播下注
SERVER[P.BROADCAST_SENDCARD_REMAINDTIME] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.BYTE}
    }
}

P.BROADCAST_USER_BET = 0x1040 --广播下注
SERVER[P.BROADCAST_USER_BET] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --被押注人的UID
        {name = 'bet_uid', type = T.INT}, --押注人的UID
        {name = 'bet_player_chip', type = T.INT}, --押注人的UID
        {name = 'costCoins', type = T.INT},
        {name = 'total_bet_count', type = T.INT},
        {name = 'my_bet_count', type = T.INT}
    }
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
        {name = 'isOpenAuto', type = T.BYTE}
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
        {name = 'seat_id', type = T.INT},
        {name = 'sex', type = T.BYTE}, --座位id
        {name = 'nickName', type = T.STRING}, --用户json字符串
        {name = 'portrait', type = T.STRING}, --用户金币
        {name = 'gold', type = T.INT} --用户金币

        -- {name="latitude",type = T.STRING},   --用户赢数
        -- {name="longitude",type = T.STRING},   --用户输数
        -- {name="ip",type = T.STRING},   --用户状态
    }
}

P.BROADCAST_USER_STAND_UP = 0x1032 --站起
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}
    }
}

P.SVR_BROADCAST_WAIT_START = 0x1100 --广播各阶段倒计时
SERVER[P.SVR_BROADCAST_WAIT_START] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.BYTE} --剩余时间
    }
}

P.SVR_COMMAND_WAITING_USERINFOS = 0x110D --围观者进入房间广播
SERVER[P.SVR_COMMAND_WAITING_USERINFOS] = {
    ver = 1,
    fmt = {
        {name = 'playerCount', type = T.BYTE},
        {
            name = 'wait_players',
            type = T.ARRAY,
            fixedLengthParser = 'playerCount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}, --用户id
                {name = 'seat_id', type = T.INT}, --用户座位ID
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
    }
}

P.SVR_REMAID_4WW = 0x110E
SERVER[P.SVR_REMAID_4WW] = {
    ver = 1,
    fmt = {
        {name = 'typ', type = T.BYTE},
        {name = 'value', type = T.INT}
    }
}

P.SVR_CMD_REQ_YAZHU_INFO = 0x1106 --自己的押注详情
SERVER[P.SVR_CMD_REQ_YAZHU_INFO] = {
    ver = 1,
    fmt = {
        {name = 'waiwei_banker_uid', type = T.INT}, --外围庄家UID
        {name = 'remainTime', type = T.BYTE}, --剩余时间
        {name = 'playerCount', type = T.BYTE}, --剩余时间
        {
            name = 'players_bet_situation',
            type = T.ARRAY,
            fixedLengthParser = 'playerCount',
            fixedLength = 0,
            fmt = {
                {name = 'uid', type = T.INT}, --用户id
                {name = 'seatId', type = T.INT}, --用户座位ID
                {name = 'total_bet_count', type = T.INT}, --用户座位ID
                {name = 'my_bet_count', type = T.INT} --用户座位ID
            }
        }
    }
}

P.SVR_CMD_REQ_YAZHU_DETAILS = 0x1107 --自己的押注详情
SERVER[P.SVR_CMD_REQ_YAZHU_DETAILS] = {
    ver = 1,
    fmt = {
        {name = 'seatId', type = T.INT}, --外围庄家UID
        {name = 'recordCount', type = T.BYTE}, --剩余时间
        {
            name = 'players_bet_situation',
            type = T.ARRAY,
            fixedLengthParser = 'recordCount',
            fixedLength = 0,
            fmt = {
                {name = 'bet_uid', type = T.INT}, --用户id
                {name = 'bet_count', type = T.INT} --用户座位ID
            }
        }
    }
}

P.SVR_BROADCAST_BEGIN_GRAB_WW_DEALER = 0x110C --抢外围庄
SERVER[P.SVR_BROADCAST_BEGIN_GRAB_WW_DEALER] = {
    ver = 1,
    fmt = {
        {name = 'waiwei_grab_time', type = T.BYTE} --外围抢庄总时间
    }
}

P.BROADCAST_WAIWEI_RESULT = 0x110B --外围抢庄结果
SERVER[P.BROADCAST_WAIWEI_RESULT] = {
    ver = 1,
    fmt = {
        {name = 'bet_playercount', type = T.INT},
        {
            name = 'betResult',
            type = T.ARRAY,
            fixedLengthParser = 'bet_playercount',
            fixedLength = 0,
            fmt = {
                {name = 'bet_uid', type = T.INT},
                {name = 'score', type = T.INT},
                {name = 'chip', type = T.INT},
                {name = 'playercount', type = T.BYTE},
                {
                    name = 'betDetailResult',
                    type = T.ARRAY,
                    fixedLengthParser = 'playercount',
                    fixedLength = 0,
                    fmt = {
                        {name = 'seatId', type = T.INT},
                        {name = 'detail_score', type = T.INT}
                    }
                }
            }
        }
    }
}

P.SVR_BROADCAST_GRAB_WW_DEALER = 0x110A --抢外围庄
SERVER[P.SVR_BROADCAST_GRAB_WW_DEALER] = {
    ver = 1,
    fmt = {
        {name = 'waiwei_banker_uid', type = T.INT}, --外围庄家ID
        {name = 'waiwei_bet_time', type = T.BYTE}, --外围下注总时间
        {name = 'waiwei_bet_limit_times', type = T.INT} --外围下注总时间
    }
}

P.BROADCAST_ERROR_TIPS = 0x5001 --站起
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
         --ver
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

--P.SVR_GET_ROOM_OK                = 0x0210    --获取房间id结果
--SERVER[P.SVR_GET_ROOM_OK] = {
--    ver = 1,
--    fmt = {
--        {name = "tid", type = T.INT}, --桌子ID
--        {name = "sid", type = T.SHORT}, --serverid
--        -- {name = "level", type = T.SHORT}, --游戏等级
--        -- {name = "res", type = T.SHORT}, --请求结果
--        {name = "ip", type = T.STRING}, -- ip
--        {name = "port", type = T.INT}, -- 端口
--        {name = "res", type = T.INT}, --请求结果
--        {name = "level", type = T.SHORT}, --请求结果
--    }
--}

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

P.SVR_BROADCAST_COUNT_DOWN = 0x100F --广播倒计时
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

P.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST = 0x6013 --广播玩家抢庄结果（返回）
SERVER[P.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'if_qiang', type = T.INT}, --是否抢庄
        {name = 'isShowHandleView', type = T.BYTE}
     --是否显示操作界面
    }
}

P.SVR_USER_BASES_RESULT_BROADCAST = 0x6014 --广播玩家加倍倍数
SERVER[P.SVR_USER_BASES_RESULT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'base', type = T.INT}, --倍数
        {name = 'isShowHandleView', type = T.BYTE},
         --是否显示操作界面
        {name = 'tuizhu', type = T.BYTE},
         --是否显示可推注
        {name = 'isSheMen', type = T.BYTE}
     --是否显示可推注
    }
}

P.SVR_USER_PLAYED_CARDS_BROADCAST = 0x6005 --广播玩家出牌
SERVER[P.SVR_USER_PLAYED_CARDS_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'card', type = T.BYTE}, --最后那张牌
        {name = 'kind', type = T.BYTE}, --牌型
        {name = 'mount', type = T.BYTE}, --数量
        {
            name = 'cards',
            type = T.ARRAY,
            fixedLengthParser = 'mount',
            fixedLength = 0,
            fmt = {
                {type = T.BYTE} --牌
            }
        },
        {name = 'times', type = T.BYTE}, --倍率
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

P.SVR_PLAY_CARD_BROADCAST = 0x6004 --广播玩家开始出牌
SERVER[P.SVR_PLAY_CARD_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'time', type = T.INT}, --超时时间
        {name = 'isShowHandleView', type = T.BYTE}
     --是否显示操作界面
    }
}

P.SVR_READY_BROADCAST = 0x6001 --广播玩家准备
SERVER[P.SVR_READY_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT}, --用户id
        {name = 'readyState', type = T.BYTE} --用户id
    }
}

-- P.SVR_USER_PLAYED_CARDS_PRE_BROADCAST              = 0x6002   --不知道什么鬼
-- local uidcheckArray={[100001]=true,[100012]=true,[102594]=true,[984]=true}

-- if uidcheckArray[USER_INFO["uid"]] then
--     SERVER[P.SVR_USER_PLAYED_CARDS_PRE_BROADCAST] = {
--         ver = 1,
--         fmt = {
--             {name = "playerCount", type = T.INT}, --用户数量
--             {name = "user_cards", type = T.ARRAY,fixedLengthParser = "playerCount",fixedLength = 0,
--                 fmt = {
--                     {name = "uid", type = T.INT},
--                     {name = "mount", type = T.INT},
--                     {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
--                     fmt = {
--                         {type = T.BYTE},
--                     }
--                 },
--                 }
--             },
--         }

--     }
-- else
-- SERVER[P.SVR_USER_PLAYED_CARDS_PRE_BROADCAST] = {
--     ver = 1,
-- }
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
        {name = 'guodi', type = T.INT}, --当前锅底
        {name = 'isShowHandleView', type = T.BYTE}
     --是否显示操作界面
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
                {type = T.BYTE} --牌
            }
        }
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
                {type = T.BYTE} --牌
            }
        },
        {name = 'userMount', type = T.BYTE},
        {
            name = 'users',
            type = T.ARRAY,
            fixedLengthParser = 'userMount',
            fixedLength = 0,
            fmt = {
                {name = 'seat_id', type = T.BYTE},
                {name = 'mount', type = T.BYTE}, --牌的数量
                {
                    name = 'cards',
                    type = T.ARRAY,
                    fixedLengthParser = 'mount',
                    fixedLength = 0,
                    fmt = {
                        {type = T.BYTE} --牌
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

P.SVR_BROADCAST_GAME_START = 0x6002
SERVER[P.SVR_BROADCAST_GAME_START] = {
    ver = 1,
    fmt = {
        {name = 'send_card_num', type = T.BYTE}, --发几张牌
        {name = 'playerCount', type = T.BYTE}, --用户数量
        {
            name = 'user_datas',
            type = T.ARRAY,
            fixedLengthParser = 'playerCount',
            fixedLength = 0,
            fmt = {
                {name = 'seatId', type = T.BYTE},
                {name = 'mount', type = T.BYTE},
                {
                    name = 'cards',
                    type = T.ARRAY,
                    fixedLengthParser = 'mount',
                    fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}
                    }
                }
            }
        },
        {name = 'hasLeper', type = T.BYTE}, -- 是否癞子  1 经典癞子 2 随机癞子(lepers 返回一个)
        {name = 'leperCount', type = T.BYTE},
        {
            name = 'lepers',
            type = T.ARRAY,
            fixedLengthParser = 'leperCount',
            fixedLength = 0,
            fmt = {
                {name = 'card', type = T.BYTE}
            }
        }
    }
}

P.SVR_LOGIN_ROOM_FAIL = 0x1005 --登陆房间失败提示
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = 'errorCode', type = T.INT} --错误码
    }
}

-- if GROUP_MODE == 2 then
    P.SVR_OPEN_CARDS_BROADCAST = 0x1043 --广播游戏结算信息
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
                        name = 'handCards',
                        type = T.ARRAY,
                        fixedLengthParser = 'handCardCount',
                        fixedLength = 0,
                        fmt = {
                            {type = T.BYTE} --牌
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
            {name = 'bonusPool', type = T.INT}, --奖池
            {name = 'user_mount', type = T.INT}, --闲家数量
            {
                name = 'userinfo',
                type = T.ARRAY,
                fixedLengthParser = 'user_mount',
                fixedLength = 0,
                fmt = {
                    {name = 'uid', type = T.INT}, --用户id
                    {name = 'win_times', type = T.INT}, --玩家输赢倍数
                    {name = 'win_chip', type = T.INT}, --玩家输赢金币
                    {name = 'chips', type = T.INT}, --玩家金币
                    {name = 'handCardCount', type = T.BYTE}, --手牌数量
                    {
                        name = 'handCards',
                        type = T.ARRAY,
                        fixedLengthParser = 'handCardCount',
                        fixedLength = 0,
                        fmt = {
                            {type = T.BYTE} --牌
                        }
                    }
                }
            },
            {name = 'banker_uid', type = T.INT}, --庄家id
            {name = 'banker_win_times', type = T.INT}, --庄家输赢倍数
            {name = 'banker_win_chip', type = T.INT}, --庄家 输赢数
            {name = 'banker_chips', type = T.INT}, --庄家金币
            {name = 'time', type = T.INT}, --播动画时间
            {name = 'round', type = T.INT}, --当前结算时的局数
            {name = 'handCardCount', type = T.BYTE}, --手牌数量
            {
                name = 'handCards',
                type = T.ARRAY,
                fixedLengthParser = 'handCardCount',
                fixedLength = 0,
                fmt = {
                    {type = T.BYTE} --牌
                }
            },
            {name = 'guodi', type = T.INT} --
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
                    },
                    {name = 'canGrabDealer', type = T.BYTE} --是否可以抢庄 0不可以 1 可以
                }
            },
            {name = 'time', type = T.INT}, --抢庄超时时间
            {name = 'isShowHandleView', type = T.BYTE}, --是否显示操作界面

            {name = 'canTuizhuCount', type = T.BYTE}, --可以推注的用户数量
            {
                name = 'canTuizhu', type = T.ARRAY, fixedLengthParser = 'canTuizhuCount', fixedLength = 0,
                fmt = {
                    {name = 'uid', type = T.INT}, --uid
                    {name = 'max_tuizhu', type = T.INT} --推注的数额
                }
            }
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
            {name = 'seat_id', type = T.INT}, --用户座位ID
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
            {name = 'activityId', type = T.INT}, --activityId
            {name = 'isWatch', type = T.INT}, --1玩家 0围观
            {name = 'club_id', type = T.INT}, --联盟id
            {name = 'inviteCode', type = T.STRING}, --邀请码
            {name = 'bonusPool', type = T.INT}, --奖池
            {name = 'start_id', type = T.INT}, --可以开始的人
            {name = 'gameType', type = T.BYTE},
             --游戏类型，1抢庄 2定庄 3 轮庄 4换庄
            {name = 'initialChip', type = T.INT}, --初始筹码
            {name = 'maxPlyaerNum', type = T.BYTE}, --初始筹码
            {name = 'round', type = T.BYTE}, --当前局数
            {name = 'base', type = T.INT}, --砥柱
            {name = 'table_kind', type = T.SHORT}, --桌子类型
            {name = 'seat_id', type = T.INT}, --座位id
            {name = 'gold', type = T.INT}, --金币
            {name = 'win', type = T.INT}, --赢的次数
            {name = 'lost', type = T.INT}, --输的次数
            {name = 'table_status', type = T.BYTE}, --桌子状态
            {name = 'bank_uid', type = T.INT}, --庄家uid
            {name = 'less_time', type = T.INT}, --剩余时间
            {name = 'user_status', type = T.BYTE}, --用户状态
            {name = 'card_mount', type = T.BYTE}, --牌的数量
            {
                name = 'cards',
                type = T.ARRAY,
                fixedLengthParser = 'card_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.BYTE} --牌
                }
            },
            {name = 'grab_times_mount', type = T.BYTE}, --可选的倍数
            {
                name = 'grab_times',
                type = T.ARRAY,
                fixedLengthParser = 'grab_times_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.BYTE} --倍数
                }
            },
            {name = 'can_grab_times_mount', type = T.BYTE}, --可选的倍数
            {
                name = 'can_grab_times',
                type = T.ARRAY,
                fixedLengthParser = 'can_grab_times_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.BYTE} --倍数
                }
            },
            {name = 'canGrabDealer', type = T.BYTE}, --抢庄需要的最低筹码
            {name = 'selects_base_mount', type = T.BYTE}, --可选的倍数
            {
                name = 'selects_base',
                type = T.ARRAY,
                fixedLengthParser = 'selects_base_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.INT} --倍数
                }
            },
            {name = 'can_selects_base_mount', type = T.BYTE}, --可选的倍数
            {
                name = 'can_selects_base',
                type = T.ARRAY,
                fixedLengthParser = 'can_selects_base_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.INT} --倍数
                }
            },
            {name = 'user_base_calltime', type = T.INT}, --用户状态calltime的叫分倍数
            {name = 'user_base_waitplay', type = T.INT}, --用户状态等待出牌的叫分倍数
            {name = 'user_base_waitplay_cards_mount', type = T.BYTE}, --用户状态等待出牌的牌的数量
            {
                name = 'user_base_waitplay_cards',
                type = T.ARRAY,
                fixedLengthParser = 'user_base_waitplay_cards_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.BYTE} --倍数
                }
            },
            {name = 'user_base_out', type = T.INT}, --用户状态出牌阶段的叫分倍数
            {name = 'user_base_out_card_kind', type = T.BYTE}, --用户状态出牌阶段牌的类型
            {name = 'user_base_out_cards_mount', type = T.BYTE}, --用户状态出牌阶段的牌的数量
            {
                name = 'user_base_out_cards',
                type = T.ARRAY,
                fixedLengthParser = 'user_base_out_cards_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.BYTE} --牌
                }
            },
            {name = 'user_mount', type = T.BYTE}, --用户数量
            {
                name = 'users_infos',
                type = T.ARRAY,
                fixedLengthParser = 'user_mount',
                fixedLength = 0,
                fmt = {
                    {name = 'uid', type = T.INT}, --用户id
                    {name = 'seat_id', type = T.INT}, --座位id
                    {name = 'sex', type = T.BYTE}, --座位id
                    {name = 'nickName', type = T.STRING}, --用户json字符串
                    {name = 'portrait', type = T.STRING}, --用户金币
                    {name = 'latitude', type = T.STRING}, --用户赢数
                    {name = 'longitude', type = T.STRING}, --用户输数
                    {name = 'otherInfo', type = T.STRING}, --用户个人信息
                    {name = 'ip', type = T.STRING}, --用户状态
                    {name = 'gold', type = T.INT}, --金币
                    {name = 'win', type = T.INT}, --赢的次数
                    {name = 'lost', type = T.INT}, --输的次数
                    {name = 'user_status', type = T.BYTE}, --用户状态
                    {name = 'user_base_calltime', type = T.INT}, --用户叫的倍数
                    {name = 'tuizhu', type = T.BYTE}, --是否显示可推注 是否推注了
                    {name = 'keTuizhu', type = T.INT}, --是否显示可推注, 可推注的倍数
                    {name = 'user_base_waitplay', type = T.INT}, --用户可以叫的倍数
                    {name = 'user_base_waitplay_cards_mount', type = T.BYTE}, --用户 牌数量
                    {name = 'user_base_out', type = T.INT}, --用户倍数
                    {name = 'user_base_out_cards_cardkind', type = T.BYTE}, --用户牌型
                    {name = 'user_base_out_cards_mount', type = T.BYTE}, --用户牌数量
                    {
                        name = 'user_base_out_cards',
                        type = T.ARRAY,
                        fixedLengthParser = 'user_base_out_cards_mount',
                        fixedLength = 0,
                        fmt = {
                            {type = T.BYTE} --牌
                        }
                    },
                    {name = 'user_if_outline', type = T.BYTE}, --用户是否掉线
                    {name = 'user_if_auto', type = T.BYTE} --用户是否托管，1为托管，0为没托管
                }
            },
            {name = 'isGoldGame', type = T.BYTE}, --为组局场和金币场的标记  1是组局 0是金币
            {name = 'gameConfig', type = T.STRING},
            {name = 'waiweibet_count', type = T.BYTE}, --为组局场和金币场的标记  0是组局 1是金币
            {
                name = 'waiweibet_chips',
                type = T.ARRAY,
                fixedLengthParser = 'waiweibet_count',
                fixedLength = 0,
                fmt = {
                    {type = T.INT} --牌
                }
            },
            {name = 'm_guodi', type = T.INT}, --斗公牛的锅底
            {name = 'm_curGuoJuSize', type = T.INT}, --当前锅进行的局数
            {name = 'bankerOptState', type = T.INT}, --庄操作状态
            {name = 'm_nGuoCount', type = T.INT}, --统计锅的数量
            {name = 'hasLeper', type = T.BYTE}, -- 是否癞子  1 经典癞子 2 随机癞子(lepers 返回一个)
            {name = 'leperCount', type = T.BYTE},
            {
                name = 'lepers',
                type = T.ARRAY,
                fixedLengthParser = 'leperCount',
                fixedLength = 0,
                fmt = {
                    {name = 'card', type = T.BYTE}
                }
            }
        }
    }

    P.SVR_SEND_BASES_TO_USER_BROADCAST = 0x7001 --向特定用户发送可翻倍的数值列表
    SERVER[P.SVR_SEND_BASES_TO_USER_BROADCAST] = {
        ver = 1,
        fmt = {
            {name = 'selects_base_mount', type = T.BYTE}, --数量
            {
                name = 'selects_base',
                type = T.ARRAY,
                fixedLengthParser = 'selects_base_mount',
                fixedLength = 0,
                fmt = {
                    {type = T.INT} --倍数
                }
            },
            {name = 'can_selects_base_mount', type = T.BYTE}, --用户id
            {
                name = 'can_selects_base',
                type = T.ARRAY,
                fixedLengthParser = 'can_selects_base_mount',
                fixedLength = 0,
                fmt = {
                    {name = 'times', type = T.INT} --倍数
                }
            },
            {name = 'time', type = T.INT}, --超时时间
            {name = 'isShowHandleView', type = T.BYTE},
             --是否显示操作界面
            {name = 'tuiZhuBase', type = T.INT},
             --推注倍数
            {name = 'canTuizhuCount', type = T.BYTE}, --可以推注的用户数量
            {
                name = 'canTuizhu',
                type = T.ARRAY,
                fixedLengthParser = 'canTuizhuCount',
                fixedLength = 0,
                fmt = {
                    {name = 'uid', type = T.INT}, --uid
                    {name = 'max_tuizhu', type = T.INT} --推注的数额
                }
            }
        }
    }

    --组局排行榜
    P.SVR_GROUP_BILLBOARD = 0x5100
    SERVER[P.SVR_GROUP_BILLBOARD] = {
        ver = 1,
        fmt = {
            {name = 'playercount', type = T.BYTE},
             --土豪
            {
                name = 'playerlist',
                type = T.ARRAY,
                fixedLengthParser = 'playercount',
                fixedLength = 0,
                fmt = {
                    {name = 'uid', type = T.INT},
                    {name = 'sex', type = T.BYTE},
                    {name = 'nickName', type = T.STRING},
                     --游戏玩家数
                    {name = 'portrait', type = T.STRING},
                     --游戏玩家数
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
                    {name = 'isZhuang', type = T.BYTE}, --是否是庄 1 是 0 不是
                    {name = 'card_mount', type = T.BYTE}, --牌的数量
                    {
                        name = 'cards',
                        type = T.ARRAY,
                        fixedLengthParser = 'card_mount',
                        fixedLength = 0,
                        fmt = {
                            {type = T.BYTE} --牌
                        }
                    },
                    {name = 'cardType', type = T.INT}, --用户牌型
                    {name = 'grab', type = T.INT}, --是否抢庄
                    {name = 'xiazhu', type = T.INT}, --压住倍数
                    {name = 'changeChip', type = T.INT} --输赢分
                }
            }
        }
    }
-- elseif GROUP_MODE == 1 then
--     P.SERVER_CMD_FORWARD_MESSAGE = 0x0213 --服务器返回组局收到的缓存信息
--     SERVER[P.SERVER_CMD_FORWARD_MESSAGE] = {
--         ver = 1,
--         fmt = {
--             {name = 'msgCount', type = T.INT}, --消息长度
--             {
--                 name = 'msgList',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'msgCount',
--                 fixedLength = 0,
--                 fmt = {
--                     {name = 'msg', type = T.STRING} --消息
--                 }
--             }
--         }
--     }

--     P.SERVER_CMD_MESSAGE = 0x0214 --服务器返回组局收到的信息
--     SERVER[P.SERVER_CMD_MESSAGE] = {
--         ver = 1,
--         fmt = {
--             {name = 'msgCount', type = T.INT}, --消息长度
--             {name = 'msg', type = T.STRING} --消息
--         }
--     }

--     --P.SVR_BEGIN_QIANFGZHUANG_BROADCAST              = 0x6015   --广播开始抢庄（返回）
--     --SERVER[P.SVR_BEGIN_QIANFGZHUANG_BROADCAST] = {
--     --    ver = 1,
--     --    fmt = {
--     --        {name = "mount", type = T.BYTE}, --数量
--     --        {name = "ids", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
--     --            fmt = {
--     --                    {name = "uid",type = T.INT},   --用户id
--     --                    {name = "can_grab_times_mount",type = T.BYTE},   --用户id
--     --                    {name = "can_grab_times", type = T.ARRAY,fixedLengthParser = "can_grab_times_mount",fixedLength = 0,
--     --                    fmt = {
--     --
--     --                            {name = "times",type = T.BYTE},   --倍数
--     --                    }
--     --                },
--     --            }
--     --        },
--     --        {name = "time", type = T.INT}, --抢庄超时时间
--     --        {name = "isShowHandleView", type = T.BYTE}--是否显示操作界面
--     --    }
--     --}

--     P.SVR_SEND_BASES_TO_USER_BROADCAST = 0x7001 --向特定用户发送可翻倍的数值列表
--     SERVER[P.SVR_SEND_BASES_TO_USER_BROADCAST] = {
--         ver = 1,
--         fmt = {
--             {name = 'selects_base_mount', type = T.INT}, --数量
--             {
--                 name = 'selects_base',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'selects_base_mount',
--                 fixedLength = 0,
--                 fmt = {
--                     {type = T.INT} --倍数
--                 }
--             },
--             {name = 'time', type = T.INT}, --超时时间
--             {name = 'isShowHandleView', type = T.BYTE},
--              --是否显示操作界面
--             {name = 'tuiZhuBase', type = T.INT}
--          --推注倍数
--         }
--     }

--     P.SVR_LOGIN_ROOM = 0x1007 --登陆房间返回
--     SERVER[P.SVR_LOGIN_ROOM] = {
--         ver = 1,
--         fmt = {
--             {name = 'gameType', type = T.BYTE},
--              --游戏类型，1抢庄 2定庄 3 轮庄 4换庄
--             {name = 'allUsersReadyStatus', type = T.BYTE}, --是否重来显示
--             {name = 'base', type = T.INT}, --砥柱
--             {name = 'initialChip', type = T.INT}, --初始筹码
--             {name = 'table_kind', type = T.SHORT}, --桌子类型
--             {name = 'seat_id', type = T.INT}, --座位id
--             {name = 'gold', type = T.INT}, --金币
--             {name = 'win', type = T.INT}, --赢的次数
--             {name = 'lost', type = T.INT}, --输的次数
--             {name = 'table_status', type = T.BYTE}, --桌子状态
--             {name = 'bank_uid', type = T.INT}, --庄家uid
--             {name = 'less_time', type = T.INT}, --剩余时间
--             {name = 'user_status', type = T.INT}, --用户状态
--             {name = 'card_mount', type = T.INT}, --牌的数量
--             {
--                 name = 'cards',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'card_mount',
--                 fixedLength = 0,
--                 fmt = {
--                     {type = T.BYTE} --牌
--                 }
--             },
--             {name = 'grab_times_mount', type = T.BYTE}, --可选的倍数
--             {
--                 name = 'grab_times',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'grab_times_mount',
--                 fixedLength = 0,
--                 fmt = {
--                     {type = T.BYTE} --倍数
--                 }
--             },
--             {name = 'selects_base_mount', type = T.INT}, --可选的倍数
--             {
--                 name = 'selects_base',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'selects_base_mount',
--                 fixedLength = 0,
--                 fmt = {
--                     {type = T.INT} --倍数
--                 }
--             },
--             {name = 'user_base_calltime', type = T.INT}, --用户状态calltime的叫分倍数
--             {name = 'user_base_waitplay', type = T.INT}, --用户状态等待出牌的叫分倍数
--             {name = 'user_base_waitplay_cards_mount', type = T.INT}, --用户状态等待出牌的牌的数量
--             {
--                 name = 'user_base_waitplay_cards',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'user_base_waitplay_cards_mount',
--                 fixedLength = 0,
--                 fmt = {
--                     {type = T.BYTE} --倍数
--                 }
--             },
--             {name = 'user_base_out', type = T.INT}, --用户状态出牌阶段的叫分倍数
--             {name = 'user_base_out_card_kind', type = T.BYTE}, --用户状态出牌阶段牌的类型
--             {name = 'user_base_out_cards_mount', type = T.INT}, --用户状态出牌阶段的牌的数量
--             {
--                 name = 'user_base_out_cards',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'user_base_out_cards_mount',
--                 fixedLength = 0,
--                 fmt = {
--                     {type = T.BYTE} --牌
--                 }
--             },
--             {name = 'user_mount', type = T.INT}, --用户数量
--             {
--                 name = 'users_infos',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'user_mount',
--                 fixedLength = 0,
--                 fmt = {
--                     {name = 'uid', type = T.INT}, --用户id
--                     {name = 'seat_id', type = T.INT}, --座位id
--                     {name = 'user_info', type = T.STRING}, --用户json字符串
--                     {name = 'gold', type = T.INT}, --用户金币
--                     {name = 'user_win', type = T.INT}, --用户赢数
--                     {name = 'user_lost', type = T.INT}, --用户输数
--                     {name = 'user_status', type = T.INT}, --用户状态
--                     {name = 'user_base_calltime', type = T.INT}, --用户倍数
--                     {name = 'user_base_waitplay', type = T.INT}, --用户倍数
--                     {name = 'user_base_waitplay_cards_mount', type = T.INT}, --用户 牌数量
--                     {name = 'user_base_out_cards', type = T.INT}, --用户倍数
--                     {name = 'user_base_out_cards_cardkind', type = T.BYTE}, --用户牌型
--                     {name = 'user_base_out_cards_mount', type = T.INT}, --用户牌数量
--                     {
--                         name = 'user_base_out_cards',
--                         type = T.ARRAY,
--                         fixedLengthParser = 'user_base_out_cards_mount',
--                         fixedLength = 0,
--                         fmt = {
--                             {type = T.BYTE} --牌
--                         }
--                     },
--                     {name = 'user_if_outline', type = T.BYTE} --用户是否掉线
--                 }
--             },
--             {name = 'isGoldGame', type = T.BYTE}, --为组局场和金币场的标记  1是组局 0是金币
--             {name = 'gameConfig', type = T.STRING}
--         }
--     }

--     P.SVR_LOGIN_ROOM_BROADCAST = 0x100D --登陆房间广播
--     SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
--         ver = 1,
--         fmt = {
--             {name = 'uid', type = T.INT}, --用户id
--             {name = 'seat_id', type = T.INT}, --用户座位ID
--             {name = 'user_info', type = T.STRING}, --用户Json串
--             {name = 'gold', type = T.INT}, --用户金币
--             {name = 'user_win', type = T.INT}, --用户赢局数
--             {name = 'user_lost', type = T.INT} --用户输局数
--         }
--     }

--     --组局排行榜
--     P.SVR_GROUP_BILLBOARD = 0x5100
--     SERVER[P.SVR_GROUP_BILLBOARD] = {
--         ver = 1,
--         fmt = {
--             {name = 'playercount', type = T.INT},
--              --土豪
--             {
--                 name = 'playerlist',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'playercount',
--                 fixedLength = 0,
--                 fmt = {
--                     {name = 'uid', type = T.INT},
--                     {name = 'user_info', type = T.STRING}
--                  --游戏玩家数
--                 }
--             },
--             {name = 'game_amount', type = T.INT} --总局数
--         }
--     }
-- end

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
         --土豪
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
     --土豪
    }
}

--请求获取筹码返回
P.SVR_GET_CHIP = 0x906
SERVER[P.SVR_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = 'ret', type = T.INT}, --成功与否标注，0失败
        {name = 'chip', type = T.INT} --兑换筹码数
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
                {name = 'uid', type = T.INT}
             --已经同意解散的用户
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

P.SVR_MSG_FACE = 0x1104
SERVER[P.SVR_MSG_FACE] = {
    ver = 1,
    fmt = {
        {name = 'uid', type = T.INT},
        {name = 'type', type = T.INT}
    }
}

--通知庄家升庄
P.SERVER_NOTIFY_UP_BANK = 0x1110
SERVER[P.SERVER_NOTIFY_UP_BANK] = {
    ver = 1,
    fmt = {
        {name = 'banker_uid', type = T.INT}, --庄家的id
        {name = 'state', type = T.INT} --根据这个来显示庄操作按钮
    }
}

--广播玩家升庄
P.SERVER_BROADCAST_UP_BANK = 0x2014
SERVER[P.SERVER_BROADCAST_UP_BANK] = {
    ver = 1,
    fmt = {
        {name = 'guodi', type = T.INT}, --锅底金额
        {name = 'banker_uid', type = T.INT}, --庄家的id
        {name = 'm_nGuoCount', type = T.INT} --统计锅的数量
    }
}

--广播新锅
P.SERVER_BROADCAST_NEW_GUO = 0x2015
SERVER[P.SERVER_BROADCAST_NEW_GUO] = {
    ver = 1,
    fmt = {
        {name = 'guodi', type = T.INT}, --锅底金额
        {name = 'banker_uid', type = T.INT}, --庄家的id
        {name = 'm_nGuoCount', type = T.INT} --统计锅的数量
    }
}

-- if GROUP_MODE == 3 then
--     P.SVR_LOGIN_ROOM = 0x1007 --登陆房间返回
--     SERVER[P.SVR_LOGIN_ROOM] = {
--         ver = 1,
--         fmt = {
--             {name = 'activityId', type = T.INT}, --activityId
--             {name = 'inviteCode', type = T.STRING}, --邀请码
--             {name = 'bonusPool', type = T.INT}, --奖池
--             {name = 'base', type = T.INT}, --砥柱
--             {name = 'challengeTimesSize', type = T.BYTE}, --可选的倍数
--             {
--                 name = 'challengeTimes',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'challengeTimesSize',
--                 fixedLength = 0,
--                 fmt = {
--                     {type = T.BYTE} --倍数
--                 }
--             },
--             {name = 'max_challengeCount', type = T.BYTE},
--             {name = 'challengeCount', type = T.BYTE},
--             {name = 'max_changeCount', type = T.BYTE},
--             {name = 'changeCount', type = T.BYTE},
--             {name = 'IsPlay', type = T.BYTE},
--             {name = 'chips', type = T.INT},
--             {name = 'highestScore', type = T.INT},
--             {name = 'score', type = T.INT},
--             {name = 'douniusSize', type = T.BYTE}, --用户数量
--             {
--                 name = 'dounius',
--                 type = T.ARRAY,
--                 fixedLengthParser = 'douniusSize',
--                 fixedLength = 0,
--                 fmt = {
--                     {name = 'douniuTimes', type = T.BYTE},
--                     {name = 'user_base_out_cards_mount', type = T.BYTE}, --用户id
--                     {
--                         name = 'user_base_out_cards',
--                         type = T.ARRAY,
--                         fixedLengthParser = 'user_base_out_cards_mount',
--                         fixedLength = 0,
--                         fmt = {
--                             {type = T.BYTE} --倍数
--                         }
--                     },
--                     {name = 'niuniuType', type = T.BYTE} --用户id
--                 }
--             }
--         }
--     }

--     P.SVR_LOGIN_ROOM_BROADCAST = 0x100D --登陆房间广播
--     SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
--         ver = 1,
--         fmt = {
--             {name = 'uid', type = T.INT}, --用户id
--             {name = 'seat_id', type = T.INT}, --用户座位ID
--             {name = 'nickName', type = T.STRING}, --
--             {name = 'portrait', type = T.STRING}, --
--             {name = 'latitude', type = T.STRING}, --
--             {name = 'longitude', type = T.STRING}, --
--             {name = 'ip', type = T.STRING}, --
--             {name = 'gold', type = T.INT}, --
--             {name = 'm_nWinTimes', type = T.INT}, --
--             {name = 'm_nLoseTimes', type = T.INT}, --
--             {name = 'm_chips', type = T.Int64}, --
--             {name = 'm_nScore', type = T.INT} --
--         }
--     }
-- end

return HALL_SERVER_PROTOCOL
