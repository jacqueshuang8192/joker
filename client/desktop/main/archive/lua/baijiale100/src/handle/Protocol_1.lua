--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--

-- *************** 
-- 注意
--[[
    以下为自定义错误码，从 100 开始
    OPC_FAIL_EXCEEDS_LIMIT = 100,    //超出下注限制
    OPC_FAIL_NOT_ENOUGH    = 101,    //低于申请上庄分
    OPC_FAIL_NOT_DOWN      = 102,    //当前状态不能下庄
    
    betType 下注类型 1 表示龙；2 表示虎；3 表示和

    消息标识有 -- new 表示有改动的消息

--]]
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require("hall.HALL_PROTOCOL")
local P = class("HALL_SERVER_PROTOCOL",HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P
-- P.CONFIG = {}
-- P.CONFIG.CLIENT = {}
-- P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

P.CLI_HEART = 0x110 --发送心跳
CLIENT[P.CLI_HEART] ={
    ver = 1,
    fmt = {
        {name = "tid",type = T.INT}, 
    }
}
----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------
P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "seat_id", type = T.INT}, --需要验证的key
        {name = "sex", type = T.BYTE}, --需要验证的key
        {name = "nickName", type = T.STRING}, --用户个人信息
        {name = "portrait", type = T.STRING}, --用户个人信息
        {name = "latitude", type = T.STRING}, --用户个人信息
        {name = "longitude", type = T.STRING}, --用户个人信息 
        {name = "otherInfo", type = T.STRING}, --用户个人信息 
        {name = "activityId", type = T.INT}, --用户个人信息    
        {name = "ip", type = T.STRING}, --用户个人信息 
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


P.SVR_QUICK_SUC               = 0x1008   --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
}


P.CLI_DOUBLE                    = 0x1103    --用户下注
CLIENT[P.CLI_DOUBLE] = {
    ver = 1,
    fmt = {
        {name = "times", type = T.SHORT} --玩家叫的分数
    }
}

--获取筹码
P.CLI_GET_CHIP                   = 0x806
CLIENT[P.CLI_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT} --用户id
    }
}

P.CLI_MSG_FACE                 =0x1004
CLIENT[P.CLI_MSG_FACE]={
    ver=1,
    fmt={
        {name="type",type=T.INT},
    }

}

P.CLI_QUIT_ROOM                     = 0x1033    --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

P.CLI_SIT_DOWN  =          0x1031   --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    {name="seat_id",type = T.INT},   --座位id       
}


P.CLI_STAND_UP  =          0x1032   --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1,
}

-------------------  解散房间相关  ------------------------------
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

-- 游戏相关
----------------------------------------------------------------------------------------

--//下注 -- new
P.CLIENT_COMMAND_USER_BET_SCORE                   = 0x1101
CLIENT[P.CLIENT_COMMAND_USER_BET_SCORE] = {
    ver = 1,
    fmt = {
        {name = "betType", type = T.INT}, --下注类型 1 表示龙；2 表示虎；3 表示和
        {name = "betScore", type = T.INT}, --下注金额
    }
}

--//申请上庄 -- new
-- 服务端 返回 0x4002 消息
P.CLIENT_COMMAND_USER_APPLY_BANKER                   = 0x1102
CLIENT[P.CLIENT_COMMAND_USER_APPLY_BANKER] = {
    ver = 1,
}

--//走势图 -- new
-- 服务端 庄家有变化返回 0x4005 消息 ， 没变化返回  0x4009 消息
P.CLIENT_COMMAND_USER_LOOK_TREND                   = 0X1103
CLIENT[P.CLIENT_COMMAND_USER_LOOK_TREND] = {
    ver = 1,
}

--//申请下庄 -- new
-- 服务端 返回 0x4009 消息
P.CLIENT_COMMAND_USER_DOWN_BANKER                   = 0x1104
CLIENT[P.CLIENT_COMMAND_USER_DOWN_BANKER] = {
    ver = 1,
}

--//取消申请上庄 -- new
-- 服务端 返回 0x4005 消息
P.CLIENT_COMMAND_USER_CANCEL_APPLY                   = 0x1105
CLIENT[P.CLIENT_COMMAND_USER_CANCEL_APPLY] = {
    ver = 1,
}

--//玩家列表（20局战绩） -- new
-- 服务端 返回 0x4008 消息
P.CLIENT_COMMAND_USER_LIST                   = 0x1106
CLIENT[P.CLIENT_COMMAND_USER_LIST] = {
    ver = 1,
}

--//获取玩家信息
P.CLIENT_COMMAND_GET_USER_INFO                   = 0x1107
CLIENT[P.CLIENT_COMMAND_GET_USER_INFO] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, 
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

P.SERVER_CMD_MESSAGE                = 0x801    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING}, --消息
    }
}

P.BROADCAST_ERROR_TIPS  =          0x5001   --站起
SERVER[P.BROADCAST_ERROR_TIPS] = {
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT}, 
    }
}

P.SVR_LOGIN_ROOM_BROADCAST                 = 0x100D    --服务器广播用户登陆房间
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},--玩家uid
        {name = "seat_id", type = T.INT},--玩家座位号
        {name = "if_ready", type = T.BYTE},--玩家座位号
        {name = "sex",type = T.BYTE},   --座位id
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "latitude",type = T.STRING},   --用户赢数
        {name = "longitude",type = T.STRING},   --用户输数
        {name = "otherInfo", type = T.STRING}, --用户个人信息 
        {name = "ip",type = T.STRING},   --用户状态
        {name = "chips", type = T.INT},--玩家筹码数
        {name = "user_gold_64", type = T.INT},--玩家筹码数
    }
}

P.SVR_LOGOUT_ROOM_OK                = 0x1008    --服务器返回玩家退出游戏成功
SERVER[P.SVR_LOGOUT_ROOM_OK] = {
    ver = 1
}


P.BROADCAST_USER_SIT_DOWN  =          0x1031   --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt ={    
        {name = "mostUid", type = T.INT}, -- 大富豪
        {name = "winUid", type = T.INT},  -- 幸运星
        {name = "uid", type = T.INT}, 
        {name = "seat_id", type = T.INT}, 
        {name = "sex",type = T.BYTE},   --座位id       
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "chips",type = T.INT},   --用户金币
        {name = "ip",type = T.STRING},   --用户状态
        {name = "latitude",type = T.STRING},   --用户赢数
        {name = "longitude",type = T.STRING},   --用户输数
    }
}

P.BROADCAST_USER_STAND_UP  =          0x1032   --站起
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT}, 
    }
}

-- new
P.SVR_BROADCAST_USER_LEAVEROOM                = 0x1033    --服务器广播玩家退出
SERVER[P.SVR_BROADCAST_USER_LEAVEROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "mostUid", type = T.INT}, -- 大富豪
        {name = "winUid", type = T.INT},  -- 幸运星
    }
}

P.SVR_LOGOUT_ROOM                = 0x100E    --服务器广播玩家退出
SERVER[P.SVR_LOGOUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "Uid", type = T.INT},
    }
}

-- new
P.SVR_LOGIN_ROOM_OK              = 0x1007    --登录房间OK
SERVER[P.SVR_LOGIN_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "clubId", type = T.INT},  --俱乐部ID
        {name = "maxPlayerSize", type = T.INT},  --最大玩家人数
        {name = "inviteCode", type = T.STRING},  --
        {name = "baseChip", type = T.INT},  --
        {name = "gameStatus", type = T.SHORT},--游戏中的状态
        {name = "trendSize", type = T.SHORT},--记录
        {name = "trendList", type =T.ARRAY,fixedLengthParser = "trendSize",fixedLength = 0,
            fmt = {
                {name = "openRes", type = T.INT},--开牌结果
            }
        },
        -- {name = "paiLuStr", type = T.STRING},  --格式 1;2,2;1,1;3
        {name = "totalBankerScore", type = T.INT},  --庄总下注金额
        {name = "totalPlayerScore", type = T.INT},  --闲总下注金额
        {name = "totalHeScore", type = T.INT},  --和类型的总下注金额
        {name = "totalBankerPairsScore", type = T.INT},  --庄对总下注金额
        {name = "totalPlayerPairsScore", type = T.INT},  --闲对总下注金额
        {name = "bankerSize", type = T.INT},  --庄家数量
        {name = "bankerList", type =T.ARRAY,fixedLengthParser = "bankerSize",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--庄家的uid
                {name = "chips", type = T.INT},                               
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING}, 
            }
        },
        {name = "waitBankerSize", type = T.INT},  --等待庄家数量
        {name = "waitBankerList", type =T.ARRAY,fixedLengthParser = "waitBankerSize",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "chips", type = T.INT},                               
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING}, 
            }
        },

        {name = "mostUid", type = T.INT},--大富豪 游戏没开始值为 0
        {name = "winUid", type = T.INT},--幸运星 游戏没开始值为 0
        {name = "bankerCardSize", type = T.INT},  --庄家的牌
        {name = "bankerCardList", type =T.ARRAY,fixedLengthParser = "bankerCardSize",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
        {name = "playerCardSize", type = T.INT},  --闲家的牌
        {name = "playerCardList", type =T.ARRAY,fixedLengthParser = "playerCardSize",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},--开牌结果
            }
        },
        {name = "opRes", type = T.INT},--开牌结果
        {name = "surpCardSize", type = T.INT},--牌堆剩余数
        {name = "playerCount", type = T.SHORT},  --玩家数量
        {name = "playerList", type =T.ARRAY,fixedLengthParser = "playerCount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--其他玩家的uid
                {name = "seat_id", type = T.SHORT},
                {name = "if_online", type = T.SHORT},
                {name = "sex", type = T.BYTE},
                {name = "nickname", type = T.STRING},  
                {name = "portrait", type = T.STRING},  
                {name = "latitude", type = T.STRING},
                {name = "longitude", type = T.STRING},
                {name = "otherInfo", type = T.STRING},
                {name = "ip", type = T.STRING}, 
                {name = "chips", type = T.INT},
                {name = "isBanker", type = T.INT},--是否为庄家
                {name = "bankTimes", type = T.INT},--连庄的次数
                {name = "winSize", type = T.INT},--连赢次数
                {name = "betStr", type = T.STRING},  --下注信息 格式：betType,betScore;betType,betScore...
            }
        },
        {name = "OwnerID", type = T.INT},--房主ID
        {name="roomConfigStr", type = T.STRING}, --房间配置信息
    }
}

-- new
P.SVR_RELOAD_ROOM                = 0x1009    --玩家重连逻辑
SERVER[P.SVR_RELOAD_ROOM] = {
    ver = 1,
    fmt = {
        {name = "clubId", type = T.INT},  --俱乐部ID
        {name = "maxPlayerSize", type = T.INT},  --最大玩家人数
        {name = "inviteCode", type = T.STRING},  --
        {name = "baseChip", type = T.INT},  --
        {name = "gameStatus", type = T.SHORT},--游戏中的状态
        {name = "trendSize", type = T.SHORT},--记录
        {name = "trendList", type =T.ARRAY,fixedLengthParser = "trendSize",fixedLength = 0,
            fmt = {
                {name = "openRes", type = T.INT},--开牌结果
            }
        },
        {name = "totalBankerScore", type = T.INT},  --庄总下注金额
        {name = "totalPlayerScore", type = T.INT},  --闲总下注金额
        {name = "totalHeScore", type = T.INT},  --和类型的总下注金额
        {name = "totalBankerPairsScore", type = T.INT},  --庄对总下注金额
        {name = "totalPlayerPairsScore", type = T.INT},  --闲对总下注金额
        {name = "bankerSize", type = T.INT},  --庄家数量
        {name = "bankerList", type =T.ARRAY,fixedLengthParser = "bankerSize",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--庄家的uid
                {name = "chips", type = T.INT},                               
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING}, 
            }
        },
        {name = "waitBankerSize", type = T.INT},  --等待庄家数量
        {name = "waitBankerList", type =T.ARRAY,fixedLengthParser = "waitBankerSize",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "chips", type = T.INT},                               
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING},
            }
        },

        {name = "mostUid", type = T.INT},--大富豪 游戏没开始值为 0
        {name = "winUid", type = T.INT},--幸运星 游戏没开始值为 0
        {name = "bankerCardSize", type = T.INT},  --庄家的牌
        {name = "bankerCardList", type =T.ARRAY,fixedLengthParser = "bankerCardSize",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
        {name = "playerCardSize", type = T.INT},  --闲家的牌
        {name = "playerCardList", type =T.ARRAY,fixedLengthParser = "playerCardSize",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},--开牌结果
            }
        },
        {name = "opRes", type = T.INT},--开牌结果
        {name = "surpCardSize", type = T.INT},--牌堆剩余数
        {name = "playerCount", type = T.SHORT},  --玩家数量
        {name = "playerList", type =T.ARRAY,fixedLengthParser = "playerCount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--其他玩家的uid
                {name = "seat_id", type = T.SHORT},
                {name = "if_online", type = T.SHORT},
                {name = "sex", type = T.BYTE},
                {name = "nickname", type = T.STRING},  
                {name = "portrait", type = T.STRING},  
                {name = "latitude", type = T.STRING},
                {name = "longitude", type = T.STRING},
                {name = "otherInfo", type = T.STRING},
                {name = "ip", type = T.STRING}, 
                {name = "chips", type = T.INT},
                {name = "isBanker", type = T.INT},--是否为庄家
                {name = "bankTimes", type = T.INT},--连庄的次数
                {name = "winSize", type = T.INT},--连赢次数
                {name = "betStr", type = T.STRING},  --下注信息 格式：betType,betScore;betType,betScore...
            }
        },
        {name = "OwnerID", type = T.INT},--房主ID
        {name="roomConfigStr", type = T.STRING}, --房间配置信息
    }
}

--解散房间相关（废弃）
--没有此房间，解散房间失败  0x908
P.S2C_DISSOLVE_FAILED = 0x908
SERVER[P.S2C_DISSOLVE_FAILED] = {
    ver = 1
}

--解散房间相关（新）
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
    ver = 1
}

--广播桌子用户解散组局 ，解散组局失败
P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP = 0x104A
SERVER[P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
         {name = "rejectId",type = T.INT}, --拒绝的用户id
    }
}

-- new
P.SERVER_BROADCAST_USER_BET_SCORE                 = 0x4002    --广播玩家下注
SERVER[P.SERVER_BROADCAST_USER_BET_SCORE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},      --下注玩家Id
        {name = "betType", type = T.INT},    --下注类型
        {name = "betScore", type = T.INT},     --下注分数
        {name = "totalBankerScore", type = T.INT},  --庄总下注金额
        {name = "totalPlayerScore", type = T.INT},  --闲总下注金额
        {name = "totalHeScore", type = T.INT},  --和类型的总下注金额
        {name = "totalBankerPairsScore", type = T.INT},  --庄对总下注金额
        {name = "totalPlayerPairsScore", type = T.INT},  --闲对总下注金额
        -- {name = "chips", type = T.INT}, --
    }
}

-- newlo
P.SERVER_BROADCAST_START_BET                 = 0x4003    --广播开始下注
SERVER[P.SERVER_BROADCAST_START_BET] = {
    ver = 1,
    fmt = {
        {name = "times", type = T.INT},           --下注时间
        -- {name = "surpLongMaxScore", type = T.INT}, --龙类型最大的剩余金额
        -- {name = "surpHuMaxScore", type = T.INT}, --虎类型最大的剩余金额
        -- {name = "surpHeMaxScore", type = T.INT}, --和类型最大的剩余金额
    }
}

-- new
P.SERVER_BROADCAST_STOP_BET                 = 0x4014    --广播停止下注
SERVER[P.SERVER_BROADCAST_STOP_BET] = {
    ver = 1,
    fmt = {
        {name = "longCard", type = T.BYTE}, --龙方位的牌
        {name = "huCard", type = T.BYTE},   --胡方位的牌
    }
}

-- new
P.SERVER_COMMAND_USER_APPLY_BANKER                 = 0x4005    --申请上庄
SERVER[P.SERVER_COMMAND_USER_APPLY_BANKER] = {
    ver = 1,
    fmt = {
        {name = "bankerSize", type = T.INT},   --庄家的数量
        {name = "bankerList", type = T.ARRAY,fixedLengthParser = "bankerSize",fixedLength = 0,
            fmt = { 
                {name = "uid", type = T.INT},--庄家Uid
                {name = "chips", type = T.INT},--积分                               
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING},
            }
        },
        {name = "waitBankerSize", type = T.INT},   --庄家的数量
        {name = "waitBankerList", type = T.ARRAY,fixedLengthParser = "waitBankerSize",fixedLength = 0,
            fmt = { 
                {name = "uid", type = T.INT},--庄家Uid
                {name = "chips", type = T.INT},--积分                               
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING},
            }
        },
    }
}

-- new
P.SERVER_COMMAND_USER_LOOK_TREND                 = 0x4006    --走势图
SERVER[P.SERVER_COMMAND_USER_LOOK_TREND] = {
    ver = 1,
    fmt = {
        {name = "trendSize", type = T.INT},   --庄家的数量
        {name = "trendList", type = T.ARRAY,fixedLengthParser = "trendSize",fixedLength = 0,
            fmt = { 
                {name = "openRes", type = T.INT},--单局结果
            }
        },
    }
}

-- new
P.SERVER_BROADCAST_MOST_GLOD_USER                 = 0x4007    --广播大富豪
SERVER[P.SERVER_BROADCAST_MOST_GLOD_USER] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --大富豪的Uid
    }
}

-- new
P.SERVER_BROADCAST_USER_RECORD                 = 0x4008    --玩家列表（20局战绩）
SERVER[P.SERVER_BROADCAST_USER_RECORD] = {
    ver = 1,
    fmt = {
        {name = "playerCount", type = T.INT},  --玩家数量
        {name = "playerList", type =T.ARRAY,fixedLengthParser = "playerCount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--其他玩家的uid 
                {name = "chips", type = T.INT},
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING}, 
                {name = "totalScore", type = T.INT},--总下注金额
                {name = "times", type = T.INT},--赢的次数
            }
        },
    }
}

-- new
P.SERVER_BROADCAST_BANKER_USER                 = 0x4009    --广播新庄家
SERVER[P.SERVER_BROADCAST_BANKER_USER] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},         --申请下庄的玩家 uid 为 0 时，表示服务端下庄（这个时候 opRes 这个值不要管，刷庄列表就可以了）
        {name = "opRes", type = T.INT},       --操作结果
        {name = "mostUid", type = T.INT},      --大富豪的Uid
        {name = "winUid", type = T.INT},       --幸运星的Uid
        {name = "bankerSize", type = T.INT},   --庄家的数量
        {name = "bankerList", type = T.ARRAY,fixedLengthParser = "bankerSize",fixedLength = 0,
            fmt = { 
                {name = "uid", type = T.INT},--庄家Uid
                {name = "chips", type = T.INT},--积分
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING}, 
            }
        },
        {name = "waitBankerSize", type = T.INT},   --庄家的数量
        {name = "waitBankerList", type = T.ARRAY,fixedLengthParser = "waitBankerSize",fixedLength = 0,
            fmt = { 
                {name = "uid", type = T.INT},--庄家Uid
                {name = "chips", type = T.INT},--积分
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING}, 
            }
        },

    }
}

-- new
P.SERVER_BROADCAST_SEND_CARD                 = 0x4015    --发牌
SERVER[P.SERVER_BROADCAST_SEND_CARD] = {
    ver = 1,
    fmt = {
        {name = "bankerCardSize", type = T.INT},  --庄家的牌
        {name = "bankerCardList", type =T.ARRAY,fixedLengthParser = "bankerCardSize",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
        {name = "playerCardSize", type = T.INT},  --闲家的牌
        {name = "playerCardList", type =T.ARRAY,fixedLengthParser = "playerCardSize",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},--开牌结果
            }
        },
    }
}

P.SERVER_BROADCAST_SHOW_USER                 = 0x4010    --显示玩家变化
SERVER[P.SERVER_BROADCAST_SHOW_USER] = {
    ver = 1,
    fmt = {
        {name = "delUId", type = T.INT},--删除玩家的uid 0表示没在显示列表里
        {name = "playerCount", type = T.INT},  --玩家数量
        {name = "playerList", type =T.ARRAY,fixedLengthParser = "playerCount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},--其他玩家的uid
                {name = "seat_id", type = T.SHORT},
                {name = "if_online", type = T.SHORT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},  
                {name = "portrait", type = T.STRING},  
                {name = "latitude", type = T.STRING},
                {name = "longitude", type = T.STRING},
                {name = "otherInfo", type = T.STRING},
                {name = "ip", type = T.STRING}, 
                {name = "chips", type = T.INT},
                {name = "isBanker", type = T.INT},--是否为庄家
                {name = "bankTimes", type = T.INT},--连庄的次数
                {name = "winSize", type = T.INT},--连赢次数
                {name = "betStr", type = T.STRING},  --下注信息 格式：betType,betScore;betType,betScore...
            }
        },
    }
}

-- new
P.SERVER_BROADCAST_SINGLE_USER_INFO                 = 0x4011    --单个玩家信息
SERVER[P.SERVER_BROADCAST_SINGLE_USER_INFO] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},--其他玩家的uid
        {name = "seat_id", type = T.SHORT},
        {name = "if_online", type = T.SHORT},
        {name = "sex", type = T.BYTE},
        {name = "nickName", type = T.STRING},  
        {name = "portrait", type = T.STRING},  
        {name = "latitude", type = T.STRING},
        {name = "longitude", type = T.STRING},
        {name = "otherInfo", type = T.STRING},
        {name = "ip", type = T.STRING}, 
        {name = "chips", type = T.INT},
        {name = "isBanker", type = T.INT},--是否为庄家
        {name = "bankTimes", type = T.INT},--连庄的次数
        {name = "winSize", type = T.INT},--连赢次数
        {name = "betStr", type = T.STRING},  --下注信息 格式：betType,betScore;betType,betScore...
    }
}


-- new
P.SERVER_SEND_TURN_RESULT                 = 0x6008    --单局结算
SERVER[P.SERVER_SEND_TURN_RESULT] = {
    ver = 1,
    fmt = {
        {name = "openRes", type = T.INT},     --结果
        {name = "mostUid", type = T.INT}, --大富豪Uid
        {name = "winUid", type = T.INT}, --幸运星Uid
        -- {name = "longCard", type = T.BYTE}, --龙方位的牌
        -- {name = "huCard", type = T.BYTE}, --虎方位的牌
        {name = "playerCount", type = T.INT},   --玩家的数量
        {name = "playerList", type = T.ARRAY,fixedLengthParser = "playerCount",fixedLength = 0,
            fmt = { 
                {name = "uid", type = T.INT},--Uid
                {name = "chips", type = T.INT},--积分                
                {name = "turnBlc", type = T.INT},--胜负值
            }
        },
    }
}


return HALL_SERVER_PROTOCOL