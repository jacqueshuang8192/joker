--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require("hall.HALL_PROTOCOL")
local P = class("HALL_SERVER_PROTOCOL",HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P

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


P.CLI_QUIT_ROOM                     = 0x1033    --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

P.CLI_SIT_DOWN  =          0x1031   --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    fmt = {
        {name="seat",type = T.INT},   --座位id
    }

}


P.CLI_STAND_UP  =          0x1032   --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1,
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
    {name = "readyState", type = T.INT},  -- 0是取消准备，1是准备
}

P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "sex", type = T.BYTE}, --需要验证的key
        --{name = "seat", type = T.INT}, --需要验证的key
        {name = "nickName", type = T.STRING}, --用户个人信息
        {name = "portrait", type = T.STRING}, --用户个人信息
        {name = "latitude", type = T.STRING}, --用户个人信息
        {name = "longitude", type = T.STRING}, --用户个人信息
        {name = "otherInfo", type = T.STRING}, --用户个人信息
        {name = "activityId", type = T.INT}, --用户个人信息
        {name = "city", type = T.STRING}, --用户个人信息
        {name = "ip", type = T.INT}, --用户个人信息
		{name = "isWatch", type = T.BYTE}, --1玩家 0围观
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
--押注
P.CLIENT_CMD_YA = 0x1101
CLIENT[P.CLIENT_CMD_YA] ={
    ver = 1,
    fmt = {
        {name = "uid" , type =T.INT},
        {name = "zhu" , type = T.INT}
    }
}
--出牌
P.CLIENT_CMD_OUT_CARD = 0x1103
CLIENT[P.CLIENT_CMD_OUT_CARD] = {
    ver = 1,
}

P.CLIENT_CMD_GIVE_COINS = 0x2002
CLIENT[P.CLIENT_CMD_GIVE_COINS] = {
    ver = 1,
    fmt ={
        {name = "desUid", type = T.INT},
        {name = "coins", type = T.INT},
    }
}

P.CLIENT_CMD_REQ_TEST						= 0x110B    --请求带控
CLIENT[P.CLIENT_CMD_REQ_TEST] = {
    ver = 1,
}
P.CLIENT_CMD_START_GAME = 0x2006--请求开始游戏
CLIENT[P.CLIENT_CMD_START_GAME] = {
    ver = 1,
    
}
P.CLIENT_CMD_TEST						= 0x110C    --带控
CLIENT[P.CLIENT_CMD_TEST] = {
    ver = 1,
    fmt = {
        --{name = "seat", type = T.INT}, --uid
        {name = "rank", type = T.BYTE}, --排名
    }
}
-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
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
        {name = "seat", type = T.INT},
        {name = "sex",type = T.BYTE},   --座位id       
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "gold",type = T.INT},   --用户金币
        {name = "count", type = T.INT},
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

P.BROADCAST_ERROR_TIPS  =          0x5001   --错误码
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

P.SVR_LOGIN_ROOM_FAIL               = 0x1005   --登陆房间失败提示
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT},  --错误码
    }
}  


P.SVR_SETTLEMENT_BROADCAST              = 0x6008   --广播游戏结算信息
SERVER[P.SVR_SETTLEMENT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "user_mount", type = T.BYTE}, --用户数量
        {name = "userinfo", type = T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --用户id
                {name = "seat", type = T.BYTE}, --用户id
                {name = "chips", type = T.INT}, --玩家金币
                {name = "score", type = T.INT}, --玩家输赢
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
        {name = "seat", type = T.INT}, --用户座位ID
        {name = "sex", type = T.BYTE}, --用户座位ID
        {name = "nickName", type = T.STRING}, --
        {name = "portrait", type = T.STRING}, --
        {name = "latitude", type = T.STRING}, --
        {name = "longitude", type = T.STRING}, --
        {name = "otherInfo", type = T.STRING}, --用户个人信息
        {name = "ip", type = T.STRING}, -- 
        {name = "gold", type = T.INT}, --
    }
}  


P.SVR_LOGIN_ROOM                = 0x1007    --登陆房间返回
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "gamePattern", type = T.BYTE},  --房间类型   0金币场  1 房卡场
        {name = "activityId", type = T.INT},   --activityId
		{name = "isWatch", type = T.INT}, --1玩家 0围观
        {name = "inviteCode", type = T.STRING},   --邀请码
        {name = "baseChip", type = T.INT},   -- 下注倍率 *10 *100.....
        {name = "club_id", type = T.INT},   -- 俱乐部id
        {name = "star_game_uid", type = T.INT},   --等于自己房主就可以开始游戏
        {name = "initialChip", type = T.INT},   --初始筹码
        {name = "times", type = T.INT},   --最高筹码
        {name = "tableStatus", type = T.BYTE},--桌子状态
        {name = "outCardAniTime", type = T.INT},
        {name = "gold", type = T.INT},
        {name = "user_mount", type = T.BYTE}, --用户数量
        {name = "gamePlayerArr", type = T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
            fmt = {
                {name="uid",type = T.INT},   --用户id
                {name="gold_status",type = T.BYTE},   --1下注 0未下注
                {name="sex",type = T.BYTE},   --座位id
                {name="nickName",type = T.STRING},   --用户json字符串
                {name="portrait",type = T.STRING},   --用户金币
                {name="latitude",type = T.STRING},   --用户赢数
                {name="longitude",type = T.STRING},   --用户输数
                {name ="otherInfo", type = T.STRING}, --用户个人信息
                {name="ip",type = T.STRING},   --用户状态
                {name="city",type = T.STRING},   --城市
                {name="gold", type = T.INT}, --金币
                {name="seat",type = T.INT},   --座位id
                {name="onLine", type = T.BYTE}, --是否在线
                {name="ready", type = T.BYTE}, --是否准备
                {name="user_status",type = T.INT},   --用户状态
                {name = "handCardCount", type = T.BYTE},
                {name = "handCardArr", type = T.ARRAY, fixedLengthParser = "handCardCount", fixedLength = 0,
                    fmt = {
                        {name = "card", type = T.BYTE}
                    }
                },
                {name = "totalGold", type = T.INT},
                {name = "count", type = T.INT},
                {name = "type", type = T.BYTE},
                {name = "point", type = T.BYTE},
                {name = "maxCard", type = T.BYTE}
            }
        },
        {name = "gameConfig", type = T.STRING}, 

    }
}

--组局排行榜
P.SVR_GROUP_BILLBOARD                   = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] =  {
    ver = 1,
    fmt = {  
        {name = "playercount", type = T.BYTE},--土豪
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "sex", type = T.BYTE},
                {name = "nickName", type = T.STRING},--游戏玩家数
                {name = "portrait", type = T.STRING},--游戏玩家数
                {name = "chips", type = T.INT},


            }
        },
        {name = "game_amount", type = T.INT}, --总局数
    }
}

P.SERVER_CMD_MESSAGE                = 0x801    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING}, --消息
    }
}

P.SERVER_CMD_REQ_TEST						= 0x110B    --请求带控返回
SERVER[P.SERVER_CMD_REQ_TEST] = {
    ver = 1,
    fmt = {
        {name = "seatCount", type = T.BYTE},
        {name = "count", type = T.BYTE},
        {name = "testSeats", type = T.ARRAY, fixedLengthParser = "count", fixlength = 0,
            fmt = {
                {name = "seat", type = T.INT},
                {name = "rank", type = T.INT},
            }
        }
    }
}

P.SERVER_CMD_TEST						= 0x110C    --带控返回
SERVER[P.SERVER_CMD_TEST] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.BYTE},  --错误码
        {name = "count", type = T.BYTE},
        {name = "testSeats", type = T.ARRAY, fixedLengthParser = "count", fixlength = 0,
            fmt = {
                {name = "seat", type = T.INT},
                {name = "rank", type = T.INT},
            }
        }
    }
}

P.SVR_QUICK_SUC               = 0x1008   --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
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

P.SVR_CHARGE_BROADCAST                 =0x111
SERVER[P.SVR_CHARGE_BROADCAST]={
    ver=1,
    fmt={
    
        {name="uid",type=T.INT},
        {name="chargeCoins",type=T.INT}
    }

}


--  ========================yahzu===========================
P.SERVER_BROADCAST_START_YA = 0x1100    ---开始押注
SERVER[P.SERVER_BROADCAST_START_YA] = {
    ver = 1,
    fmt = {
        {name="outCardAniTime",type=T.BYTE},
    }
}
P.SERVER_BROADCAST_YA = 0x1101   --- 广播押注
SERVER[P.SERVER_BROADCAST_YA] = {
    ver = 1,
    fmt = {
        {name = "desUid" , type = T.INT},  --压在谁身上
        {name = "uid" , type = T.INT}, --谁押注
        {name = "gold", type = T.INT},  --这个位置剩余钱数
        {name = "chip", type = T.INT},   --押了多少
        {name = "total", type = T.INT},
        {name = "myTotal", type = T.INT},
    }
}

P.SERVER_BROADCAST_CARD = 0x1102
SERVER[P.SERVER_BROADCAST_CARD] = {
    ver = 1,
    fmt = {
        {name = "outCardAniTime", type = T.BYTE},
        {name = "bankSeatId", type = T.INT},
    }
}

P.SERVER_BROADCAST_OUT_CARD = 0x1103   -- 广播出牌
SERVER[P.SERVER_BROADCAST_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "outCardAniTime" , type = T.BYTE},
        {name = "uid", type = T.INT},
        {name = "handCardCount", type = T.BYTE},
        {name = "handCardArr", type = T.ARRAY, fixedLengthParser = "handCardCount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
        {name = "type", type = T.BYTE},
        {name = "point" , type = T.BYTE},
        {name = "maxCard", type = T.BYTE}
    }
}

P.SERVER_BROADCAST_OPEN_CARD = 0x1104   --- 开牌
SERVER[P.SERVER_BROADCAST_OPEN_CARD] = {
    ver = 1,
    fmt = {
        {name = "outCardAniTime", type = T.BYTE},
        {name = "gamePlayerCount", type = T.BYTE},
        {name = "gamePlayerArr" , type = T.ARRAY, fixedLengthParser = "gamePlayerCount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "handCardCount",type = T.BYTE},
                {name = "handCardArr", type = T.ARRAY, fixedLengthParser = "handCardCount", fixedLength = 0,
                     fmt = {
                         {name = "card", type = T.BYTE}
                     }
                },
                {name = "type", type = T.BYTE},
                {name = "point", type = T.BYTE},
                {name = "maxCard", type = T.BYTE}
            }
        }
    }
}


P.SERVER_BROADCAST_START_OUT_CARD = 0x110A   --- 出牌
SERVER[P.SERVER_BROADCAST_START_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "outCardAniTime", type = T.BYTE},
    }
}

P.SERVER_NOTIFY_RESULT = 0x1108
SERVER[P.SERVER_NOTIFY_RESULT] = {
    ver = 1,
    fmt = {
        {name = "gold", type = T.INT},
        {name = "score", type = T.INT},
    }
}
--请求开始游戏
P.SERVER_BROADCAST_START_GAME = 0x2006
SERVER[P.SERVER_BROADCAST_START_GAME] = {
    ver = 1,
    fmt = {
        {name = "star_game_uid", type = T.INT},
        
    }
}
P.SERVER_READYNOW_ROOM                     = 0x2001    --广播用户准备
SERVER[P.SERVER_READYNOW_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        -- {name = "readyState", type = T.INT},  -- 0是取消准备，1是准备
    }
}
--玩家互相赠送金币
P.SERVER_BROADCAST_GIVE_COINS = 0x2002
SERVER[P.SERVER_BROADCAST_GIVE_COINS] = {
    ver = 1,
    fmt = {
        {name = "fromUid", type = T.INT},
        {name = "fromCoins", type = T.INT},
        {name = "toUid", type = T.INT},
        {name = "toCoins", type = T.INT},
    }
}
P.SERVER_BROADCAST_WINLOSE_COUNT = 0x1109--单局结算
SERVER[P.SERVER_BROADCAST_WINLOSE_COUNT] = {
    ver = 1,
    fmt = {
        {name = "gamePlayerCount", type = T.BYTE},
        {name = "gamePlayerArr", type = T.ARRAY, fixedLengthParser = "gamePlayerCount", fixedLength = 0,
         fmt = {
             {name = "count", type =T.INT},
         }
        }
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


P.SVR_SEND_USED_CARDS          = 0x11111   --发送用户的牌信息
SERVER[P.SVR_SEND_USED_CARDS] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.SHORT}, --牌的数量
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },
    }

}

return HALL_SERVER_PROTOCOL