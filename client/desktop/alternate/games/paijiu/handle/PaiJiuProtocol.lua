--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require("hall.HALL_PROTOCOL")
local P = class("HALL_SERVER_PROTOCOL", HALL_PROTOCOL)

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
CLIENT[P.CLI_HEART] ={
    ver = 1,
    fmt = {
        {name = "tid",type = T.INT}, 
    }
}

--获取房间id
--P.CLI_GET_ROOM                   = 0x0113
--CLIENT[P.CLI_GET_ROOM] = {
--    ver = 1,
--    fmt = {
--        {name = "Level", type = T.SHORT},   --桌子等级
--        {name = "Chip", type = T.INT},--请求场次的底注
--        {name = "Sid", type = T.INT},--游戏场的id
--        {name = "activity_id", type = T.STRING} --带入活动id
--        -- {name = "type", type = T.BYTE},   --登陆类型，0--随机登陆，1--指定桌子登陆
--        -- {name = "targetid", type = T.INT} --目标桌子ID，0表示随机登陆
--    }
--}

P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "seatId", type = T.INT}, --需要验证的key
        {name = "sex", type = T.BYTE}, -- 性别
        {name = "nickName", type = T.STRING}, --用户个人信息
        {name = "portrait", type = T.STRING}, --用户个人信息
        {name = "latitude", type = T.STRING}, --用户个人信息
        {name = "longitude", type = T.STRING}, --用户个人信息
        {name = "otherInfoJson", type = T.STRING},
        {name = "activityId", type = T.INT}, --用户个人信息
    }
}

P.CLI_REQUEST_CHECK_XIAZHU                     = 0x1039    --请求查看下注情况
CLIENT[P.CLI_REQUEST_CHECK_XIAZHU] = {
    ver = 1,
}


P.CLI_REQUEST_BET                     = 0x1040    --外围请求下注
CLIENT[P.CLI_REQUEST_BET] = {
    ver = 1,
    fmt ={
        {name = "seat_id", type = T.INT},
        {name = "betChip", type = T.INT},
    }
}

P.CLI_REQUEST_LUZHI                     = 0x1035    --请求录纸
CLIENT[P.CLI_REQUEST_LUZHI] = {
    ver = 1,
}


P.CLI_AUTO_PLAY                     = 0x1034    --请求托管
CLIENT[P.CLI_AUTO_PLAY] = {
    ver = 1,
    fmt ={

        {name = "isOpenAuto", type = T.BYTE},
        {name = "grab_times", type = T.BYTE},
        {name = "bet_times", type = T.BYTE},
    }
}

P.CLI_QUIT_ROOM                     = 0x1033    --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

P.CLI_SIT_DOWN  =          0x1031   --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    {name="seatId",type = T.INT},   --座位id

}


P.CLI_STAND_UP  =          0x1032   --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1,
}

P.CLIENT_CMD_FORWARD_MESSAGE                = 0x165    --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}

P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x801    --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}


P.CLI_READYNOW_ROOM                     = 0x2001    --用户发送准备
CLIENT[P.CLI_READYNOW_ROOM] = {
    ver = 1,
    {name = "readyState", type = T.BYTE},  -- 0是取消准备，1是准备
}

P.CLIENT_COMMAND_START_GAME               =  0x2002 --请求开始游戏 
CLIENT[P.CLIENT_COMMAND_START_GAME] = {
    ver = 1,
}

P.CLI_USER_TIMES                     = 0x1101    --用户加倍倍数
CLIENT[P.CLI_USER_TIMES] = {
    ver = 1,
    fmt = {
        {name = "times", type = T.BYTE},  --倍数
    }
}


P.CLI_QIANGZHUANG                     = 0x1100    --用户抢庄
CLIENT[P.CLI_QIANGZHUANG] = {
    ver = 1,
    fmt = {
        {name = "if_qiang", type = T.BYTE},  --是否抢庄
    }
}


P.CLI_PLAY_CARD                     = 0x1102    --玩家出牌
CLIENT[P.CLI_PLAY_CARD] = {
    ver = 1,
    fmt = {
        {name = "card_1", type = T.BYTE},
        {name = "card_2", type = T.BYTE},
    }
}


P.CLI_LOGIN                      = 0x0116    --登录大厅
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "storeId", type = T.INT},
        {name = "kind", type = T.INT},
        {name = "userInfo", type = T.STRING},
    }
}

--请求解散房间 
P.C2G_CMD_DISSOLVE_ROOM                   = 0x808
CLIENT[P.C2G_CMD_DISSOLVE_ROOM] = {
    ver = 1
}

--回复请求解散房间
P.C2G_CMD_REPLY_DISSOLVE_ROOM                   = 0x809
CLIENT[P.C2G_CMD_REPLY_DISSOLVE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "agree", type = T.INT} --0为拒绝解散，1为解散
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


--获取筹码
P.CLI_GET_CHIP                   = 0x806
CLIENT[P.CLI_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT} --用户id
    }
}


--兑换筹码
P.CLI_CHANGE_CHIP                   = 0x805
CLIENT[P.CLI_CHANGE_CHIP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "chip", type = T.INT} --请求兑换筹码数
    }
}


P.CLI_COMMAND_GAMERESULT_RECORD = 0x1050
CLIENT[P.CLI_COMMAND_GAMERESULT_RECORD] = {
    ver=1,
    fmt = {
        {name = "resultIndex", type =T.INT} --请求战绩记录 传0 代表上一把,传某个数字代表带一把,传的下标过大表示要上一把
    }
}


-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

P.BROADCAST_BONUS_RESULT                     = 0x1038    --开奖结果
SERVER[P.BROADCAST_BONUS_RESULT] = {
    ver = 1,
    fmt ={

        {name = "max_player_count", type = T.BYTE},
        {name = "bonus_record", type = T.ARRAY,fixedLengthParser = "max_player_count",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --头像
                {name = "single_bonus_record_size", type = T.BYTE},
                {name = "single_bonus_record", type = T.ARRAY,fixedLengthParser = "single_bonus_record_size",fixedLength = 0,
                    fmt = {
                        {name = "bet_uid", type = T.INT},
                        {name = "bet_count", type = T.INT},--游戏玩家数
                    }
                }

            }
        },
        {name = "bonusDictSize", type = T.BYTE},
        {name = "bonusDict", type = T.ARRAY,fixedLengthParser = "bonusDictSize",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "nickName", type = T.STRING},--游戏玩家数
                {name = "portrait", type = T.STRING},--游戏玩家数
                {name = "bonusMoney", type = T.INT},
            }
        }
    }
}



P.SERVER_CMD_BONUS_RECORD                   = 0x1039    --请求查看下注情况返回
SERVER[P.SERVER_CMD_BONUS_RECORD] = {
    fmt ={
        ver = 1,
        {name = "max_player_count", type = T.BYTE},
        {name = "bonus_record", type = T.ARRAY,fixedLengthParser = "max_player_count",fixedLength = 0,
            fmt = {
                {name = "bet_uid", type = T.INT},
                {name = "total_bet_count", type = T.INT},
                {name = "bet_count", type = T.INT},
            }
        }

    }
}


P.BROADCAST_WAIWEI_RESULT                   = 0x1042    --广播下注
SERVER[P.BROADCAST_WAIWEI_RESULT] = {
    ver = 1,
    fmt ={

        {name = "banker_uid", type = T.INT},
        {name = "waiwei_result_size", type = T.BYTE},
        {name = "waiwei_result", type = T.ARRAY,fixedLengthParser = "waiwei_result_size",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --
                {name = "nickName", type = T.STRING},
                {name = "portrait", type = T.STRING},
                {name = "score", type = T.INT}
            }
        }

    }
}

P.BROADCAST_SENDCARD_REMAINDTIME                   = 0x1041    --广播下注
SERVER[P.BROADCAST_SENDCARD_REMAINDTIME] = {
    ver = 1,
    fmt ={
        {name = "time", type = T.BYTE},
    }
}



-- 牌九  广播开始加倍
P.BROADCAST_BEGIN_CALL_TIMES = 0x1105
SERVER[P.BROADCAST_BEGIN_CALL_TIMES] = {
    ver = 1,
    fmt = {
        {name = "callTimesTimtOut", type = T.BYTE} -- 加倍超时
    }
}

-- 通知玩家开始加倍
P.SVT_PLAYER_CALL_TIMES = 0x1106
SERVER[P.SVT_PLAYER_CALL_TIMES] = {
    ver = 1,
    fmt = {
        {name = "timesCount", type = T.BYTE}, -- 能加倍的数量
        {name = "timesFenArray", type = T.ARRAY, fixedLengthParser = "timesCount", fixedLength = 0,
            fmt = {type = T.BYTE}
        }
    }
}

-- 牌九，发送下注分给后台
P.SEND_BET_GRADE = 0x0000
CLIENT[P.SEND_BET_GRADE] = {
    ver = 1,
    fmt = {
        {name = "BET_COUNT",    type = T.TNT},
        {name = "BET_FEN",      type = T.TNT},
    }
}

P.BROADCAST_USER_BET                    = 0x1040    --广播下注
SERVER[P.BROADCAST_USER_BET] = {
    ver = 1,
    fmt ={
        {name = "bet_uid", type = T.INT},
        {name = "uid", type = T.INT},
        {name = "costCoins", type = T.INT},
    }
}

P.SERVER_CMD_RECORD_PAPER                     = 0x1035    --请求录纸返回
SERVER[P.SERVER_CMD_RECORD_PAPER] = {
    ver = 1,
    fmt ={
        {name = "record_paper_size", type = T.BYTE},
        {name = "record_paper", type = T.ARRAY,fixedLengthParser = "record_paper_size",fixedLength = 0,

            fmt = {

                {name = "uid", type = T.INT}, --头像
                {name = "single_record_paper_size", type = T.BYTE},
                {name = "single_record_paper", type = T.ARRAY,fixedLengthParser = "single_record_paper_size",fixedLength = 0,
                    fmt = {

                        {name = "balance", type = T.INT},
                        {name = "niuType", type = T.BYTE},--游戏玩家数
                    }
                }

            }
        }

    }
}

P.BROADCAST_USER_AUTO_PLAY  =          0x1034   --广播用户托管
SERVER[P.BROADCAST_USER_AUTO_PLAY] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT},
        {name = "isOpenAuto", type = T.BYTE},
    }
}

P.BROADCAST_USER_QUIT_ROOM  =          0x1033   --广播用户退出
SERVER[P.BROADCAST_USER_QUIT_ROOM] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT},
    }
}

P.BROADCAST_USER_SIT_DOWN  =          0x1031   --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT},
        {name = "seatId", type = T.INT},
        {name = "sex", type = T.BYTE},
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "gold",type = T.INT},   --用户金币
        -- {name = "ip", type = T.INT}, -- 玩家IP，游戏后端目前没有加上
        --  {name = "sex", type = } -- 玩家性别，游戏后端目前没有加上
        -- {name="latitude",type = T.STRING},   --用户赢数
        -- {name="longitude",type = T.STRING},   --用户输数
        -- {name="ip",type = T.STRING},   --用户状态
    }
}

P.BROADCAST_USER_STAND_UP  =          0x1032   --站起
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT},
    }
}

P.BROADCAST_ERROR_TIPS  =          0x5001   --
SERVER[P.BROADCAST_ERROR_TIPS] = {
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT},
    }
}

P.BROADCAST_USER_IP = 0x106A
SERVER[P.BROADCAST_USER_IP] = {
    ver = 1,
    fmt ={
        {name = "playercount",type = T.INT},
        {name = "playeripdata", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "ip", type = T.STRING},--游戏玩家数
            }
        }
    }
}


P.SVR_LOGIN_OK                   = 0x0201    --登录成功
SERVER[P.SVR_LOGIN_OK] = {
    ver = 1,
    fmt = {
        {name = "ver", type = T.INT},--ver
        {name = "levelCount", type = T.INT},--等级场个数
        {name = "usercount", type = T.ARRAY,fixedLengthParser = "levelCount", fixedLength = 0,
            fmt = {
                {type = T.INT},   --人数
            }
        },

        {name = "friends", type = T.INT}, --好友数
        {name = "tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "ip", type = T.STRING}, --ip
        {name = "port", type = T.INT},  --端口
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

P.SVR_QUIT_ROOM                = 0x100E   --广播玩家推出返回
SERVER[P.SVR_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}


P.SVR_NO_GOLD               = 0x700A   --svr返回金币不足
SERVER[P.SVR_NO_GOLD] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --返回码
    }
}


P.SVR_BROADCAST_COUNT_DOWN         = 0x100f   --广播倒计时
SERVER[P.SVR_BROADCAST_COUNT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.BYTE}, --返回码
    }
}


P.SVR_BRANKRUPT              = 0x7002   --破产
SERVER[P.SVR_BRANKRUPT] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --返回码
    }
}

P.SERVER_COMMAND_KICK_OUT_ROOM              = 0x7007   --新加协议
SERVER[P.SERVER_COMMAND_KICK_OUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --返回码
    }
}


P.SVR_READY_BROADCAST              = 0x2001   --广播用户准备或取消准备
SERVER[P.SVR_READY_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "readyState", type = T.BYTE},
    }
}


P.SVR_USER_GRABBANKER_OPTION_BROADCAST            = 0x1100   --玩家选择庄结果（返回）
SERVER[P.SVR_USER_GRABBANKER_OPTION_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "if_qiang", type = T.BYTE}, --是否抢庄
        -- {name = "isShowHandleView", type = T.BYTE}--是否显示操作界面
    }
}

P.SVR_USER_CALL_TIMES_BROADCAST = 0x1101  -- 玩家加倍返回
SERVER[P.SVR_USER_CALL_TIMES_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "sureDaoCount", type = T.BYTE},
        {name = "sureDaoArray", type = T.ARRAY, fixedLengthParser = "sureDaoCount", fixlength = 0,
            fmt = {
                {type = T.BYTE}
            }
        },
        {name = "canCallTimesCount", type = T.BYTE},
        {name = "canCallTimesArray", type = T.ARRAY, fixedLengthParser = "canCallTimesCount", fixlength = 0,
            fmt = {
                {type = T.BYTE}
            }
        }
    }
}


P.SVR_SHAIZI_BROADCAST = 0x1107 -- 广播骰子
SERVER[P.SVR_SHAIZI_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "shaiziTimeOut", type = T.BYTE},
        {name = "shaiziCount", type = T.BYTE},
        {name = "shaiziArray", type = T.ARRAY, fixedLengthParser = "shaiziCount", fixlength = 0,
            fmt = {type = T.BYTE}
        },
        {name = "seatId", type = T.BYTE},

    }
}


P.SVR_OUT_CARD_BROADCAST = 0x110A -- 广播开牌
SERVER[P.SVR_OUT_CARD_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "openCardAniTimeOut", type = T.BYTE}, -- 开牌动画时间
        {name = "playerCount", type = T.BYTE}, -- 玩家数
        {name = "resultInfo", type = T.ARRAY, fixedLengthParser = "playerCount", fixlength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "seatId", type = T.INT},
                --[[{name = "cardGroupsCount", type = T.BYTE},
                {name = "cardGroupArray", type = T.ARRAY, fixedLengthParser = "cardGroupsCount", fixlength = 0,
                    fmt = {
                        {name = "cardsCount", type = T.BYTE},
                        {name = "cards", type = T.ARRAY, fixedLengthParser = "cardsCount", fixlength = 0,
                            fmt = {
                                {type = T.BYTE}
                            }
                        },
                        {name = "type", type = T.BYTE},
                        {name = "point", type = T.BYTE},
                    }
                }]]
                {name = "cardCombinationCountAfterSure", type = T.BYTE},
                {name = "cardCombinationArrayAfterSure", type = T.ARRAY, fixedLengthParser = "cardCombinationCountAfterSure", fixedLength = 0,
                    fmt = {
                        {name = "cardsCount", type = T.BYTE},
                        {name = "cards", type = T.ARRAY, fixedLengthParser = "cardsCount", fixedLength = 0,
                            fmt = {
                                {type = T.BYTE},
                            }
                        },
                        {name = "type", type = T.BYTE},
                        {name = "point", type = T.BYTE},
                    }
                }
            }
        },

        {name = "poolCardsShowCount", type = T.BYTE}, -- 牌堆需要展示出来的牌数
        {name = "showCardsArray", type = T.ARRAY, fixedLengthParser = "poolCardsShowCount", fixedLength = 0,
            fmt = {
                {type = T.BYTE}, -- 牌堆需要显示牌
            }
        },
    }
}


P.SVR_SEND_USER_CARDS = 0x1109 -- 发送用户手牌
SERVER[P.SVR_SEND_USER_CARDS] = {
    ver = 1,
    fmt = {
        {name = "cardsCount", type = T.BYTE},
        {name = "cardsArray", type = T.ARRAY, fixedLengthParser = "cardsCount", fixlength = 0,
            fmt = {
                {type = T.BYTE}
            }
        },
        {name = "allCardsCombinationCount", type = T.BYTE},
        {name = "allCardsCombinationArray", type = T.ARRAY, fixedLengthParser = "allCardsCombinationCount", fixlength = 0,
            fmt = {
                {name = "cardsCount", type = T.BYTE},
                {name = "cards", type = T.ARRAY, fixedLengthParser = "cardsCount", fixlength = 0,
                    fmt = {
                        {type = T.BYTE}
                    }
                },
                {name = "type", type = T.BYTE},
                {name = "point", type = T.BYTE},
            }
        }
    }
}

P.SVR_USER_BASES_RESULT_BROADCAST              = 0x6014   --广播玩家加倍倍数
SERVER[P.SVR_USER_BASES_RESULT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "base", type = T.INT}, --倍数
        {name = "isShowHandleView", type = T.BYTE}--是否显示操作界面

    }
}

P.SVR_USER_PLAYED_CARDS_BROADCAST              = 0x6005   --广播玩家出牌
SERVER[P.SVR_USER_PLAYED_CARDS_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "kind", type = T.BYTE}, --牌型
        {name = "mount", type = T.BYTE}, --数量
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },

    }
}

P.SVR_CHIP_CHANGE_BROADCAST              = 0x4800   --广播玩家钱数变化（用于扣取台费）
SERVER[P.SVR_CHIP_CHANGE_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "user_mount", type = T.BYTE}, --闲家数量
        {name = "userinfo", type = T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --用户id
                {name = "change_chip", type = T.INT}, --玩家输赢倍数
            }
        }
    }
}

P.SVR_READY_OUTCARD_BROADCAST              = 0x1102   --广播玩家开始出牌
SERVER[P.SVR_READY_OUTCARD_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户ID
        {name = "cardGroupsCount", type = T.BYTE}, -- 组数
        {name = "cardGroupsArray", type = T.ARRAY, fixedLengthParser = "cardGroupsCount", fixlength = 0,
            fmt = {
                {name = "cardCount", type = T.BYTE},
                {name = "cards", type = T.ARRAY, fixedLengthParser = "cardCount", fixlength = 0,
                    fmt = {type = T.BYTE}
                },
                {name = "type", type = T.BYTE},
                {name = "point", type = T.BYTE},
            }
        }
    }
}


P.SVR_USER_PLAYED_CARDS_PRE_BROADCAST              = 0x6002   --不知道什么鬼
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
SERVER[P.SVR_USER_PLAYED_CARDS_PRE_BROADCAST] = {
    ver = 1,
}
-- end

P.SVR_COST_TAI           = 0x6017   --扣除台费
SERVER[P.SVR_COST_TAI] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "tai", type = T.INT}, --台费
        {name = "money", type = T.INT}, --用户金币
        {name = "lmoney", type = T.INT64}, --用户超级金币
    }
}

P.SVR_BRANK_BROADCAST              = 0x1104   --广播庄家id
SERVER[P.SVR_BRANK_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "bankerId", type = T.INT}, --庄id
        {name = "showBankerTimeOut", type = T.BYTE}, -- 抢庄的效果时间
        {name = "grabBankerCount", type = T.BYTE}, -- 选择抢庄的人
        {name = "grabBankerArray", type = T.ARRAY, fixedLengthParser = "grabBankerCount", fixedLength = 0,
            fmt = {
                {type = T.INT}
            }
        },
    }
}

P.SVR_START_OUT_CARD_BROADCAST = 0x1108  -- 广播玩家开始出牌
SERVER[P.SVR_START_OUT_CARD_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "outCardTimeOut", type = T.BYTE}, --出牌倒计时时间
        {name = "handCardsCount", type = T.BYTE}, -- 手牌数
        {name = "remainCardsCount", type = T.BYTE} -- 剩余牌堆
    }
}


P.SVR_SEND_USER_CARD              = 0x4001   --发送用户的牌信息
SERVER[P.SVR_SEND_USER_CARD] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.SHORT}, --牌的数量
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },
        {name = "userMount", type = T.BYTE},
        {name = "users", type = T.ARRAY,fixedLengthParser = "userMount",fixedLength = 0,
            fmt = {
                {name = "seat_id", type = T.BYTE},
                {name = "mount", type = T.BYTE}, --牌的数量
                {name = "cards", type = T.ARRAY, fixedLengthParser = "mount", fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},   --牌
                    }
                },
            }
        },
    }
}


P.SERVER_COMMAND_REMAID_START_GAME    = 0x4009  --提示用户，可以开始游戏
SERVER[P.SERVER_COMMAND_REMAID_START_GAME] = {
    ver = 1

}

P.SERVER_COMMAND_REMAID_START_GAME_FAIL    = 0x400A --提示用户，开始游戏失败，有玩家未准备
SERVER[P.SERVER_COMMAND_REMAID_START_GAME_FAIL] = {
    ver = 1

}

P.SVR_BROADCAST_GAME_START                = 0x6002   --广播牌局可以开始准备
SERVER[P.SVR_BROADCAST_GAME_START] = {
    ver = 1,
    fmt = {
        {name = "send_card_num", type = T.BYTE}, --发几张牌

    }
}


P.SVR_LOGIN_ROOM_FAIL               = 0x1005   --登陆房间失败提示
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT},  --错误码
    }
}

P.SVR_SETTLEMENT_BROADCAST              = 0x6008   --广播游戏结算信息
SERVER[P.SVR_SETTLEMENT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "playerCount", type = T.BYTE},
        {name = "userinfo", type = T.ARRAY, fixedLengthParser = "playerCount", fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --用户id
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},
                {name = "portrait", type = T.STRING},
                {name = "m_turnBlc", type = T.INT},
                {name = "chips", type = T.INT},
                {name = "isBanker", type = T.BYTE},
                {name = "cardGroupsCount", type = T.BYTE},
                {name = "cardGroupArray", type = T.ARRAY, fixedLengthParser = "cardGroupsCount", fixlength = 0,
                    fmt = {
                        {name = "cardsCount", type = T.BYTE},
                        {name = "cards", type = T.ARRAY, fixedLengthParser = "cardsCount", fixlength = 0,
                            fmt = {
                                {type = T.BYTE}
                            }
                        },
                        {name = "type", type = T.BYTE},
                        {name = "point", type = T.BYTE},
                    }
                }
            }
        },
    }
}

P.SVR_BEGIN_QIANFGZHUANG_BROADCAST              = 0x1103   --广播开始抢庄（返回）
SERVER[P.SVR_BEGIN_QIANFGZHUANG_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "grabBankerTimeOut", type = T.BYTE}, -- 抢庄倒计时
        {name = "candicatesCount", type = T.BYTE}, -- 符合抢庄的候选人
        {name = "candicatesArray", type = T.ARRAY, fixedLengthParser = "candicatesCount", fixedLength = 0,
            fmt = {
                {type = T.INT}
            }
        }
    }
}




--组局时长
P.SVR_GROUP_TIME                  = 0x5101
SERVER[P.SVR_GROUP_TIME] =  {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT},
        {name = "round", type = T.INT},
        {name = "round_total", type = T.INT}
    }
}


P.SVR_LOGIN_ROOM_BROADCAST                = 0x100D   --登陆房间广播
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "seatId", type = T.INT}, --用户座位ID
        {name = "sex", type = T.BYTE},
        {name = "nickName", type = T.STRING}, --
        {name = "portrait", type = T.STRING}, --
        {name = "latitude", type = T.STRING}, --
        {name = "longitude", type = T.STRING}, --
        {name = "otherInfoJson", type = T.STRING},
        {name = "ip", type = T.STRING}, -- 
        {name = "gold", type = T.INT}, --
    }
}



P.SVR_SEND_BASES_TO_USER_BROADCAST              = 0x7001   --向特定用户发送可翻倍的数值列表
SERVER[P.SVR_SEND_BASES_TO_USER_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "selects_base_mount", type = T.BYTE}, --数量
        {name = "selects_base", type = T.ARRAY,fixedLengthParser = "selects_base_mount",fixedLength = 0,
            fmt = {
                {type = T.INT},   --倍数
            }
        },

        {name = "can_selects_base_mount",type = T.BYTE},   --用户id
        {name = "can_selects_base", type = T.ARRAY,fixedLengthParser = "can_selects_base_mount",fixedLength = 0,
            fmt = {

                {name = "times",type = T.INT},   --倍数
            }
        },

        {name = "time", type = T.INT}, --超时时间
        {name = "isShowHandleView", type = T.BYTE},--是否显示操作界面
        {name = "tuiZhuBase", type = T.INT}--推注倍数
    }
}

--组局排行榜
P.SVR_GROUP_BILLBOARD                   = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] =  {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.BYTE},--人数
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},--游戏玩家数
                {name = "portrait", type = T.STRING},--游戏玩家数
                {name = "chips", type = T.INT},
                
                {name = "maxScore", type = T.INT},
                {name = "maxCardGroupCount", type = T.BYTE},
                {name = "maxCardsArray", type = T.ARRAY, fixedLengthParser = "maxCardGroupCount", fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}
                    }
                },
                {name = "maxCardsType", type = T.BYTE},
                {name = "maxCardPoint", type = T.BYTE},
                {name = "winCount", type = T.INT},
                {name = "winAllCount", type = T.INT}, -- 通杀次数
                {name = "loseAllCount", type = T.INT}, -- 通赔次数
            }
        },
        {name = "game_amount", type = T.INT}, --总局数
    }
}

P.SERVER_CMD_FORWARD_MESSAGE                = 0x0213    --服务器返回组局收到的缓存信息
SERVER[P.SERVER_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msgCount", type = T.INT}, --消息长度
        {name = "msgList", type = T.ARRAY, fixedLengthParser = "msgCount", fixedLength = 0,
            fmt = {
                {name = "msg", type = T.STRING}, --消息
            }
        },
    }
}

P.SERVER_CMD_MESSAGE                = 0x801    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING}, --消息
    }
}


P.SVR_READY_TIME                = 0x6009   --广播牌局可以开始准备
SERVER[P.SVR_READY_TIME] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT}, --准备超时时间

    }
}


P.SVR_QUICK_SUC               = 0x1008   --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
}

--组局历史记录
P.SVR_GET_HISTORY                   = 0x907
SERVER[P.SVR_GET_HISTORY] =  {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--土豪
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "user_info", type = T.STRING},--游戏玩家数
            }
        },
        {name = "history", type = T.STRING},--土豪
    }
}


--请求获取筹码返回
P.SVR_GET_CHIP                = 0x906
SERVER[P.SVR_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, --成功与否标注，0失败
        {name = "chip", type = T.INT}, --兑换筹码数
    }
}

--请求兑换筹码返回
P.SVR_CHANGE_CHIP                = 0x905
SERVER[P.SVR_CHANGE_CHIP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, --成功与否标注，0成功
        {name = "uid", type = T.INT}, --兑换筹码的uid
        {name = "chip", type = T.INT}, --服务器ID
        {name = "money", type = T.INT} --玩家剩余宝贝币
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
        {name = "applyId",type = T.INT},--申请解散房间的用户id
        {name = "agreeNum", type = T.INT},--当前同意解散的人数
        {name = "agreeMember_arr", type = T.ARRAY,fixedLengthParser = "agreeNum",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}--已经同意解散的用户
            }
        }
    }
}

--广播桌子用户请求解散组局
P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP = 0x102A
SERVER[P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
        {name = "applyId",type = T.INT}, --申请解散房间的用户id
    }
}


--广播桌子用户成功解散组局
P.SERVER_BROADCAST_DISSOLVE_GROUP = 0x103A
SERVER[P.SERVER_BROADCAST_DISSOLVE_GROUP] = {
    ver = 1,
}

--广播桌子用户不同意解散
P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP = 0x104A
SERVER[P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
        {name = "rejectId",type = T.INT}, --拒绝的用户id
    }
}

--广播桌子用户同意解散组局
P.SERVER_BROADCAST_AGREE_DISSOLVE_GROUP = 0x105A
SERVER[P.SERVER_BROADCAST_AGREE_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
        {name = "dissolveInfoStr",type = T.STRING}, --拒绝的用户id
    }
}

P.SVR_CHARGE_BROADCAST                 =0x111
SERVER[P.SVR_CHARGE_BROADCAST]={
    ver=1,
    fmt={

        {name="uid",type=T.INT},
        {name="chargeCoins",type=T.INT}
    }

}

---推锅里的筹码
P.SVR_guochip                 = 0x5102
SERVER[P.SVR_guochip]={
    ver=1,
    fmt={
        {name="chips",type=T.INT},
    }

}

--推锅斗牛里广播庄从筹码里拿筹码到锅里
P.SVR_tuiguo_zuang_start                 = 0x5103
SERVER[P.SVR_tuiguo_zuang_start]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},--新庄用户UID
        {name="chips",type=T.INT},
    }

}

--推锅斗牛里广播庄从锅里拿回属于自己的筹码
P.SVR_tuiguo_zuang_end                 = 0x5104
SERVER[P.SVR_tuiguo_zuang_end]={
    ver=1,
    fmt={
        {name="chips",type=T.INT},
    }

}

P.SVR_LOGIN_ROOM                = 0x1007    --登陆房间返回
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "isGoldGame", type = T.BYTE}, --房卡场还是金币场
        {name = "activityId", type = T.INT},   --activityId
        {name = "club_id", type = T.INT},   --俱乐部id
        {name = "inviteCode", type = T.STRING},   --邀请码
        {name = "fenchang", type = T.INT}, --分场
        {name = "initChip", type = T.INT},   --初始筹码
        {name = "gameMode", type = T.BYTE}, -- 1为小牌九，2为大牌九
        {name = "timesSize", type = T.BYTE}, -- 玩家下注分数的数组
        {name = "timesArray", type = T.ARRAY, fixedLengthParser = "timesSize", fixedLength = 0,
            fmt = {
                {type = T.BYTE}, -- 下注分
            }
        },
        {name = "gameStatus", type = T.BYTE}, -- 游戏状态
        {name = "shaiZiTimeOut", type = T.BYTE},
        {name = "shaiZiNumber", type = T.BYTE}, -- 骰子数
        {name = "shaiZiArray", type = T.ARRAY, fixedLengthParser = "shaiZiNumber", fixedLength = 0,
            fmt = {
                {type = T.BYTE}
            }
        },
        {name = "totalCardsCount", type = T.BYTE}, -- 总牌数
        {name = "poolCardsShowCount", type = T.BYTE}, -- 牌堆需要展示出来的牌数
        {name = "showCardsArray", type = T.ARRAY, fixedLengthParser = "poolCardsShowCount", fixedLength = 0,
            fmt = {
                {type = T.BYTE}, -- 牌堆需要显示牌
            }
        },
        {name = "remainCardsCount", type = T.BYTE}, -- 剩余牌数
        {name = "bankerId", type = T.INT}, -- 庄家uid
        {name = "nowUserCount", type = T.BYTE}, -- 现在在线的玩家数
        {name = "usersInfo", type = T.ARRAY, fixedLengthParser = "nowUserCount", fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},
                {name = "portrait", type = T.STRING},
                {name = "latitude", type = T.STRING},
                {name = "longitude", type = T.STRING},
                {name = "otherInfoJson", type = T.STRING},
                {name = "ip", type = T.STRING},
                {name = "gold", type = T.INT},
                {name = "seatId", type = T.INT},
                {name = "isOnline", type = T.BYTE},
                {name = "isReady", type = T.BYTE},
                {name = "feedback", type = T.INT}, -- 玩家是否做了操作：-1：没做操作，1：做了操作
                {name = "daoCount", type = T.BYTE},
                {name = "daoArray", type = T.ARRAY, fixedLengthParser = "daoCount", fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}
                    }
                },
                {name = "handCardsCount", type = T.BYTE},
                {name = "handCardsArray", type = T.ARRAY, fixedLengthParser = "handCardsCount", fixedLength =0,
                    fmt = {
                        {type = T.BYTE}
                    }
                },
                {name = "canCallTimesCount", type = T.BYTE},
                {name = "canCallTimesArray", type = T.ARRAY, fixedLengthParser = "canCallTimesCount", fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}
                    }
                },
                {name = "cardCombinationCountBeforeSure", type = T.BYTE},
                {name = "cardCoombinationArrayBeforeSure", type = T.ARRAY, fixedLengthParser = "cardCombinationCountBeforeSure", fixedLength = 0,
                    fmt = {
                        {name = "cardsCount", type = T.BYTE},
                        {name = "cards", type = T.ARRAY, fixedLengthParser = "cardsCount", fixedLength = 0,
                            fmt = {
                                {type = T.BYTE},
                            }
                        },
                        {name = "type", type = T.BYTE},
                        {name = "point", type = T.BYTE},
                    }
                },
                {name = "cardCombinationCountAfterSure", type = T.BYTE},
                {name = "cardCombinationArrayAfterSure", type = T.ARRAY, fixedLengthParser = "cardCombinationCountAfterSure", fixedLength = 0,
                    fmt = {
                        {name = "cardsCount", type = T.BYTE},
                        {name = "cards", type = T.ARRAY, fixedLengthParser = "cardsCount", fixedLength = 0,
                            fmt = {
                                {type = T.BYTE},
                            }
                        },
                        {name = "type", type = T.BYTE},
                        {name = "point", type = T.BYTE},
                    }
                }
            }
        },
        {name = "gameConfig", type = T.STRING} --游戏配置
    }
}

P.SERVER_BROADCAST_START_GAME   =   0x110B
SERVER[P.SERVER_BROADCAST_START_GAME]={
    ver=1,
    fmt={
        {name = "gameType", type = T.BYTE}, -- 4大牌九 2小牌九
        {name = "cardsCount", type = T.BYTE}, --发牌的数量
        {name = "showCardsCount", type = T.BYTE},
        {name = "showCards", type = T.ARRAY, fixedLengthParser = "showCardsCount", fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            }
        }
    }
}

--[[P.CLIENT_TEST_CARDS			= 0x2000
CLIENT[P.CLIENT_TEST_CARDS] = {
    ver = 1,
    fmt = {
        {name = "count", BYTE = T.BYTE},
        {name = "testCards", type = T.ARRAY, fixedLengthParser = "count", fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            },
        },
    }
}]]

P.SERVER_TEST_CARDS         = 0x2000
SERVER[P.SERVER_TEST_CARDS] = {
    ver = 1,
    fmt = {
        {name = "returnCode", type = T.BYTE },
    }
}

P.CLIENT_TEST_AVAIABLE_CARDS = 0x1FFF
CLIENT[P.CLIENT_TEST_AVAIABLE_CARDS] = {
    ver = 1,
}

P.SERVER_TEST_AVAIABLE_CARDS = 0x1FFF
SERVER[P.SERVER_TEST_AVAIABLE_CARDS] = {
    ver = 1,
    fmt = {
        {name = "count", type = T.BYTE},
        {name = "testCards", type = T.ARRAY, fixedLengthParser = "count", fixlength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            }
        }
    }
}

P.SERVER_COMMAND_GAMERESULT_RECORD = 0x1050
SERVER[P.SERVER_COMMAND_GAMERESULT_RECORD] = {
    ver = 1,
    fmt = {
        {name = "resultIndex", type = T.INT}, --结果的下标 如果是0,代表还没有数据
        {name = "resultCount", type = T.INT}, --前面总共有多少把的历史战绩了
        {name = "gameResultCount", type = T.INT}, --数量
        {name = "gameResult", type = T.ARRAY, fixedLengthParser = "gameResultCount", fixedLength = 0,
         fmt = {
                {name = "uid", type = T.INT}, --用户id
                {name = "smallPhoto", type = T.STRING},
                {name = "nickName", type = T.STRING},
                {name = "isZhuang", type = T.BYTE},  --是否是庄 1 是 0 不是
                {name = "cardGroupsCount", type = T.BYTE},
                {name = "cardGroupArray", type = T.ARRAY, fixedLengthParser = "cardGroupsCount", fixlength = 0,
                    fmt = {
                        {name = "cardsCount", type = T.BYTE},
                        {name = "cards", type = T.ARRAY, fixedLengthParser = "cardsCount", fixlength = 0,
                            fmt = {
                                {type = T.BYTE}
                            }
                        },
                        {name = "type", type = T.BYTE},
                        {name = "point", type = T.BYTE},
                    }
                },
                {name = "changeChip", type = T.INT} --输赢分
         }
        },
    }
}

return HALL_SERVER_PROTOCOL