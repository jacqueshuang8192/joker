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

P.CLI_SIT_DOWN  =          0x1031   --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    {name="seatId",type = T.INT},   --座位id
}


P.CLI_STAND_UP  =          0x1032   --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1,
}

P.CLI_QUIT_ROOM                     = 0x1033    --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

P.CLI_CHOICE_CARD                  = 0x1038    --请求牌
CLIENT[P.CLI_CHOICE_CARD] = {
    ver = 1,
    fmt = {
        {name = "card1", type = T.BYTE},
        {name = "card2", type = T.BYTE},
        {name = "card3", type = T.BYTE},
    }
}

-- if  GROUP_MODE == 2 then

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


-- else

    -- P.CLIENT_CMD_FORWARD_MESSAGE                = 0x165    --向服务器发送向组局里发送的缓存信息
    -- CLIENT[P.CLIENT_CMD_FORWARD_MESSAGE] = {
    --     ver = 1,
    --     fmt = {
    --         {name = "level", type = T.SHORT},   --游戏level
    --         {name = "msg", type = T.STRING}
    --     }
    -- }

    -- P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x166    --向服务器发送向组局里发送的缓存信息
    -- CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    --     ver = 1,
    --     fmt = {
    --         {name = "level", type = T.SHORT},   --游戏level
    --         {name = "msg", type = T.STRING}
    --     }
    -- }

-- end
---===============================================================
--P.CLI_GET_ROOM                   = 0x0113    --用户进入游戏
--CLIENT[P.CLI_GET_ROOM] = {
--    ver = 1,
--    fmt = {
--        {name = "level", type = T.SHORT},   --桌子等级
--        {name = "Chip", type = T.INT},--请求场次的底注
--        {name = "Sid", type = T.INT},--游戏场的id
--        {name = "activity_id", type = T.STRING} --带入活动id
--    }
--}


P.CLI_DIU_CARD                 = 0x2104    --弃牌
CLIENT[P.CLI_DIU_CARD] = {
    ver = 1,
}

P.CLI_GEN_CARD                 = 0x2102    --跟注
CLIENT[P.CLI_GEN_CARD] = {
    ver = 1,
    fmt = {
        {name = "gold", type = T.INT},   --金额
    }
}

P.CLI_JIA_CARD                 = 0x2103    --加注
CLIENT[P.CLI_JIA_CARD] = {
    ver = 1,
    fmt = {
        {name = "gold", type = T.INT},   --金额
    }
}


P.CLIENT_COMMAND_USER_OPT                 = 0x2114    --玩家飘牌和摇色子
CLIENT[P.CLIENT_COMMAND_USER_OPT] = {
    ver = 1,
    fmt = {
        {name = "opt", type = T.BYTE},   --金额
    }
}

P.CLIENT_COMMAND_USER_SHOW_CARD                 = 0x2115    --秀牌
CLIENT[P.CLIENT_COMMAND_USER_SHOW_CARD] = {
    ver = 1,
}

P.CLI_READYNOW_ROOM                     = 0x2001    --用户发送准备
CLIENT[P.CLI_READYNOW_ROOM] = {
    ver = 1,
    --fmt = {
    --    {name = "readyState", type = T.INT},  -- 0是取消准备，1是准备
    --}
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

P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "seat_id", type = T.INT}, --需要验证的key
        {name = "sex", type = T.BYTE}, --性别
        {name = "nickName", type = T.STRING}, --用户个人信息
        {name = "photoUrl", type = T.STRING}, --用户个人信息
        {name = "latitude", type = T.STRING}, --用户个人信息
        {name = "longitude", type = T.STRING}, --用户个人信息
        {name = "otherInfo", type = T.STRING}, --用户个人信息
        {name = "activity_id", type = T.INT},   --用户ID
		{name = "ip", type = T.STRING}, --用户个人信息
		{name = "isWatch", type = T.BYTE}, --1玩家 0围观
    }
}


P.CLI_MSG_FACE                 =0x1004
CLIENT[P.CLI_MSG_FACE]={
    ver=1,
    fmt={
        {name="type",type=T.INT},
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
-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
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


P.BROADCAST_USER_SIT_DOWN  =          0x1031   --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT}, 
        {name = "seat", type = T.INT},
        {name = "sex", type = T.BYTE}, --性别
        {name = "nickName",type = T.STRING},   --用户昵称
        {name = "photoUrl",type = T.STRING},   --用户头像
        {name = "gold",type = T.INT},   --用户金币
    }
}

P.BROADCAST_USER_STAND_UP  =          0x1032   --站起
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT}, 
    }
}

P.BROADCAST_CAN_START_GAME  =          0x6030   --广播可以显示开始游戏
SERVER[P.BROADCAST_CAN_START_GAME] = {
    ver = 1
}

P.BROADCAST_START_GAME  =          0x2107   --发送开始游戏
SERVER[P.BROADCAST_START_GAME] = {
    ver = 1
}

P.BROADCAST_USER_QUIT_ROOM  =          0x1033   --广播用户退出
SERVER[P.BROADCAST_USER_QUIT_ROOM] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT},
    }
}

-- if  GROUP_MODE == 2 then

    P.SERVER_CMD_MESSAGE                = 0x801    --服务器返回组局收到的信息
    SERVER[P.SERVER_CMD_MESSAGE] = {
        ver = 1,
        fmt = {
            {name = "msg", type = T.STRING}, --消息
        }
    }

-- else

    -- P.SERVER_CMD_MESSAGE                = 0x0214    --服务器返回组局收到的信息
    -- SERVER[P.SERVER_CMD_MESSAGE] = {
    --     ver = 1,
    --     fmt = {
    --         {name = "msgCount", type = T.INT}, --消息长度
    --         {name = "msg", type = T.STRING}, --消息
    --     }
    -- }

-- end

--P.SVR_GET_ROOM_OK                = 0x0210    --获取房间id结果
--SERVER[P.SVR_GET_ROOM_OK] = {
--    ver = 1,
--    fmt = {
--      {name = "tid", type = T.INT}, --桌子ID
--        {name = "sid", type = T.SHORT}, --serverid
--        -- {name = "level", type = T.SHORT}, --游戏等级
--        -- {name = "res", type = T.SHORT}, --请求结果
--        {name = "ip", type = T.STRING}, -- ip
--        {name = "port", type = T.INT}, -- 端口
--        {name = "res", type = T.INT}, --请求结果
--        {name = "level", type = T.SHORT}, --请求结果
--    }
--}

P.SVR_ERROR                = 0x1005    --登陆错误
SERVER[P.SVR_ERROR] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT}, --错误码
    }
}


P.SVR_KAN_CARD               = 0x6021    --广播看牌
SERVER[P.SVR_KAN_CARD] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --id
        {name = "next_seat", type = T.INT},--操作玩家
        {name = "zhu_mount", type = T.INT},--可加注数量
        {name = "zhus", type = T.ARRAY,fixedLengthParser="zhu_mount",fixedLength = 0,
            fmt = {
                {type= T.INT} --牌
            }
        },
        {name = "now_turns", type = T.INT},--当前轮数
        {name = "all_turns", type = T.INT},--总轮数
        {name = "round_chips", type = T.INT},--当前最大筹码
        {name = "table_chips", type = T.INT},--桌子剩余金额
        {name = "can_compare", type = T.BYTE},-- 是否可以比牌，1：可以
    }
}

P.SVR_QUIT_ROOM                = 0x100E   --广播玩家推出返回
SERVER[P.SVR_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}


P.SVR_READY                = 0x6001    --广播用户准备（返回）
SERVER[P.SVR_READY] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "readyState", type = T.BYTE}, --用户id
    }
}

P.SVR_SEND_CARD                = 0x4001    --发送用户的牌信息
SERVER[P.SVR_SEND_CARD] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.SHORT}, --牌的数量
        {name = "cards", type = T.ARRAY,fixedLengthParser="mount",fixedLength = 0,
            fmt = {
                {type= T.BYTE} --牌
            }
        },
        {name = "card_type", type = T.INT}, --牌型
    }
}

P.SVR_BASE_BROADCAST                = 0x6017    --广播台费()返回
SERVER[P.SVR_BASE_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type  = T.INT},
        {name = "fee", type  = T.INT},--台费
        {name = "gold", type = T.INT},--用户金币

    }
}

P.SVR_DIU_BROADCAST                = 0x6024    --广播玩家弃牌
SERVER[P.SVR_DIU_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type  = T.INT},
        {name = "time", type  = T.INT},--时间
        {name = "next_id", type = T.INT},--下一个id        
        {name = "fillFlag", type = T.BYTE},--是否能加注
        {name = "zhu_mount", type = T.INT},--可加注数量
        {name = "zhus", type = T.ARRAY,fixedLengthParser="zhu_mount",fixedLength = 0,
            fmt = {
                {type= T.INT} --牌
            }
        },
        {name = "user_zhu", type = T.INT},--玩家总下注
        {name = "all_zhu", type = T.INT},--总下注
        {name = "followScore", type = T.INT},-- 需要跟注的金币
        {name = "m_chips", type = T.INT},-- 玩家身上的金币
    }
}

P.SVR_GEN_BROADCAST                = 0x6022    --广播玩家跟注
SERVER[P.SVR_GEN_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type  = T.INT},
        {name = "gold", type  = T.INT},--金币
        {name = "next_seat", type = T.INT},--下一个座位
        {name = "time", type = T.INT},--时间            
        {name = "fillFlag", type = T.BYTE},--是否能加注
        {name = "zhu_mount", type = T.INT},--可加注数量
        {name = "zhus", type = T.ARRAY,fixedLengthParser="zhu_mount",fixedLength = 0,
            fmt = {
                {type= T.INT} --牌
            }
        },
        {name = "user_zhu", type = T.INT},--玩家总下注
        {name = "all_zhu", type = T.INT},--总下注
        {name = "followScore", type = T.INT},-- 需要跟注的金币
        {name = "m_chips", type = T.INT},--全压后用户剩余的金币
        {name = "isFristBet", type = T.INT},--是否为第一次下注
    }
}


P.SVR_JIA_BROADCAST                = 0x6023    --广播玩家加注
SERVER[P.SVR_JIA_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type  = T.INT},
        {name = "gold", type  = T.INT},--金币
        {name = "next_seat", type = T.INT},--下一个座位
        {name = "time", type = T.INT},--时间 
        {name = "fillFlag", type = T.BYTE},--是否能加注
        {name = "zhu_mount", type = T.INT},--可加注数量
        {name = "zhus", type = T.ARRAY,fixedLengthParser="zhu_mount",fixedLength = 0,
            fmt = {
                {type= T.INT} --牌
            }
        },
        {name = "user_zhu", type = T.INT},--玩家总下注
        {name = "all_zhu", type = T.INT},--总下注
        {name = "followScore", type = T.INT},--当前最大筹码
        {name = "m_chips", type = T.INT},--全压后用户剩余的金币
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

P.SVR_START_BROADCAST                = 0x6002    --广播比赛开始（返回）
SERVER[P.SVR_START_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "base", type  = T.INT},--底注
        {name = "handle_seat", type  = T.INT},--当前操作的座位号
        {name = "time", type  = T.INT},--操作时间
        {name = "zhu_mount", type  = T.INT},--可加注列表个数
        {name = "zhu_values", type = T.ARRAY,fixedLengthParser="zhu_mount",fixedLength = 0,
            fmt = {
                {type= T.INT} --牌
            }
        },
        {name = "all_zhu", type = T.INT},--总注
        {name = "playerChipsCount", type = T.BYTE}, --用户数量
        {name = "playersChips", type = T.ARRAY,fixedLengthParser="playerChipsCount",fixedLength = 0,
         fmt = {
             {name = "m_chips", type = T.INT},
             {name = "userId", type = T.INT},
             {name = "user_zhu", type = T.INT},
             
             {name = "card1", type = T.BYTE},
             {name = "card2", type = T.BYTE},
            }
        },
    }
}

P.SERVER_BROADCAST_LAST_CARD                = 0x6040    --广播最后一张牌
SERVER[P.SERVER_BROADCAST_LAST_CARD] = {
    ver = 1,
    fmt = {
        {name = "base", type  = T.INT},--底注
        {name = "handle_seat", type  = T.INT},--当前操作的座位号
        {name = "time", type  = T.INT},--操作时间
        -- {name = "all_zhu", type = T.INT},--总注
        {name = "playerChipsCount", type = T.BYTE}, --用户数量
        {name = "playersChips", type = T.ARRAY,fixedLengthParser="playerChipsCount",fixedLength = 0,
         fmt = {
             -- {name = "m_chips", type = T.INT},
             {name = "userId", type = T.INT},
             {name = "isFold", type = T.BYTE},
             {name = "card1", type = T.BYTE},
             {name = "card2", type = T.BYTE},
             {name = "card3", type = T.BYTE},
            }
        },
    }
}

P.SERVER_BROADCAST_USER_OPT                = 0x6042  --广播玩家飘一张或塞子操作
SERVER[P.SERVER_BROADCAST_USER_OPT] = {
    ver = 1,
    fmt = {
        {name = "uid", type  = T.INT},--操作玩家
        {name = "opt", type  = T.INT},--操作
        {name = "value", type  = T.INT},--色子的点数
        {name = "type", type  = T.INT},--1 飘 2 摇色子
    }
}

P.SERVER_BROADCAST_USER_SHOW_CARD                = 0x6043  --玩家
SERVER[P.SERVER_BROADCAST_USER_SHOW_CARD] = {
    ver = 1,
    fmt = {
        {name = "uid", type  = T.INT},--操作玩家
        {name = "cardSize", type  = T.BYTE},--可加注列表个数
        {name = "cards", type = T.ARRAY,fixedLengthParser="cardSize",fixedLength = 0,
            fmt = {
                {type= T.BYTE} --牌
            }
        },
    }
}

P.SERVER_NOTIFY_USER_OPT                = 0x6041    --通知玩家飘一张或塞子操作
SERVER[P.SERVER_NOTIFY_USER_OPT] = {
    ver = 1,
    fmt = {
        {name = "userId", type  = T.INT},--底注
        {name = "type", type  = T.INT},--1 飘 2 摇色子
    }
}


P.SVR_LOGIN_ROOM_BROADCAST                = 0x100D   --登陆房间广播
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "seat", type = T.INT}, --用户座位ID
        {name = "sex", type = T.BYTE}, --性别
        {name = "nickName", type = T.STRING}, --用户Json串
        {name = "photoUrl", type = T.STRING}, --用户Json串
        {name = "latitude", type = T.STRING}, --用户Json串
        {name = "longitude", type = T.STRING}, --用户Json串
        {name = "otherInfo", type = T.STRING}, --用户个人信息
        {name = "ip", type = T.STRING}, --用户Json串
        {name = "m_chips", type = T.INT}, --用户金币
        {name = "gold", type = T.INT}, --用户金币
        {name = "losttimes", type = T.INT}, --用户失败次数
        {name = "wintimes", type = T.INT}, --用户赢次数
    }
}



P.SVR_QUIT               = 0x1008   --自己退出房间
SERVER[P.SVR_QUIT] = {
    ver = 1,
}


P.SVR_END               = 0x6026  --单局结算
SERVER[P.SVR_END] = {
    ver = 1,
    fmt = {
        {name = "winUid", type = T.INT}, --赢家的id -1 表示没有赢家 为平局
        {name = "count", type = T.INT}, --用户数量

        {name = "userinfos", type = T.ARRAY,fixedLengthParser="count",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --用户数量
                {name = "nickName", type = T.STRING}, --用户昵称
                {name = "photoUrl", type = T.STRING}, --用户头像
                {name = "turngold", type = T.INT}, --本局金币
                {name = "chips", type = T.INT}, --用户金币
                {name = "gold", type = T.INT}, --累计输赢
                {name = "happyMoney", type = T.INT}, --喜钱
                -- {name = "compare", type = T.INT,cache=1}, --是否比牌
                {name = "iscompare", type = T.INT}, --是否比牌
                {name = "mount", type = T.INT}, --牌的数量
                {name = "cards", type = T.ARRAY,fixedLengthParser="mount",fixedLength = 0,
                    fmt = {
                        {type= T.BYTE} --牌
                    }
                },
                {name = "card_type", type = T.INT}, --牌型
                -- {name="compare_content",type = T.ARRAY,request="compare",requestValue=1,fixedLength = 1,
                --     fmt = {
                --         {name = "mount", type = T.INT}, --牌的数量
                --         {name = "cards", type = T.ARRAY,fixedLengthParser="mount",fixedLength = 0,
                --             fmt = {
                --                 {type= T.BYTE} --牌
                --             }
                --         },
                --         {name = "card_type", type = T.INT}, --牌型
                --         -- ETYPE_INVALID       = 0x00,   /* 无效的牌 */
                --         -- ETYPE_SAN_CARD      = 0x01,    /* 散牌 */
                --         -- ETYPE_ONE_PAIRS     = 0x02,    /* 一对 */
                --         -- ETYPE_STRAIGHT      = 0x03,    /* 顺子 */
                --         -- ETYPE_FLUSH     = 0x04,    /* 同花 */
                --         -- ETYPE_STRAIT_FLUSH  = 0x05,    /* 同花顺 */
                --         -- ETYPE_BAO_ZI        = 0x06,    /* 豹子 */
                --         -- ETYPE_SPECIAL_235      = 0x07,    /* 235 */
                --     }

                -- }

            }
        },
    },
}


P.SVR_ALL_COMPARE               = 0x6027   -- 全桌比牌
SERVER[P.SVR_ALL_COMPARE] = {
    ver = 1,
    fmt={
        {name="win_uid",type=T.INT},
        {name = "mount", type = T.SHORT}, --牌的数量,赢家的牌
        {name = "cards", type = T.ARRAY,fixedLengthParser="mount",fixedLength = 0,
            fmt = {
                {type= T.BYTE} --牌
            }
        },
    }
}



P.SVR_LOGIN_ROOM                = 0x1007    --登陆房间返回
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "group_code", type = T.INT}, --组局id
		{name = "isWatch", type = T.INT}, --1玩家 0围观
        {name = "club_id", type = T.INT}, --俱乐部id
        {name = "invote_code", type = T.STRING}, --房间号
        {name = "base", type = T.INT}, --砥柱
        {name = "table_kind", type = T.SHORT}, --桌子类型
        -- {name = "table_chips", type = T.INT}, --桌子剩余金额
        {name = "uid", type = T.INT}, --用户Id
        {name = "seat", type = T.INT}, --座位
        {name = "sex", type = T.BYTE}, --性别
        {name = "nickName", type = T.STRING}, --用户昵称
        {name = "photoUrl", type = T.STRING}, --用户头像
        {name = "latitude", type = T.STRING}, --
        {name = "longitude", type = T.STRING}, --
        {name = "otherInfo", type = T.STRING}, --用户个人信息
        {name = "ip", type = T.STRING}, --用户Json串
        {name = "m_chips", type = T.INT}, --用户金币
        {name = "happy", type = T.INT}, --用户是否选择喜钱
        {name = "gold", type = T.INT}, --用户金币
        {name = "wintimes", type = T.INT}, --赢的次数
        {name = "losttimes", type = T.INT}, --输的次数
        {name = "if_ready", type = T.INT}, --自己是否准备

        --{name = "if_startgame", type = T.INT},--0不显示1开始按钮2准备
        {name = "status", type = T.BYTE,cache=1}, --状态
        {name="nostart",type = T.ARRAY,request="status",requestValue=0,fixedLength = 1,
            fmt = {
                {name = "mount", type = T.INT}, --当前桌子的人数
                {name = "userInfo",type = T.ARRAY,fixedLengthParser="mount",fixedLength = 0,
                    fmt = {
                        {name = "uid", type = T.INT}, --用户id
                        {name = "seat", type = T.INT}, --座位号
                        {name = "sex", type = T.BYTE}, --性别
                        {name = "nickName", type = T.STRING}, --用户Json串
                        {name = "photoUrl", type = T.STRING}, --用户Json串
                        {name = "latitude", type = T.STRING}, --用户Json串
                        {name = "longitude", type = T.STRING}, --用户Json串
                        {name = "otherInfo", type = T.STRING}, --用户个人信息
                        {name = "ip", type = T.STRING}, --用户Json串
                        {name = "m_chips", type = T.INT}, --用户金币
                        {name = "gold", type = T.INT}, --用户金币
                        {name = "if_ready", type = T.INT}, --用户是否准备
                    }
                }
            }
        },

        {name="start",type = T.ARRAY,request="status",requestValue=2,fixedLength = 1,
            fmt = {
                {name = "playing", type = T.INT,cache=1}, --玩家是否在玩
                {name = "play_content",type = T.ARRAY,request="playing",requestValue=1,fixedLength = 1,
                    fmt = {
                        {name = "cancel", type = T.INT}, --玩家是否弃牌
                        {name = "user_all_xia", type = T.INT}, --玩家下注总数
                        {name = "add_mount", type = T.INT}, --玩家可加注数量
                        {name = "add_value", type = T.ARRAY,fixedLengthParser="add_mount",fixedLength = 0,
                            fmt = {
                                {type = T.INT }
                            }
                        }, --玩家可加注
                        
                        -- {name = "cardSize", type = T.BYTE}, --是否可以看牌了
                        -- {name = "card1", type = T.BYTE}, --是否可以看牌了     
                        -- {name = "card2", type = T.BYTE}, --是否可以看牌了  
                        -- {name = "card3", type = T.BYTE}, --是否可以看牌了                   
                        -- {name = "card_type", type = T.INT}, --玩家是否在看牌
                        {name = "bet_mount", type = T.INT}, --玩家可加注数量
                        {name = "bet_values", type = T.ARRAY,fixedLengthParser="bet_mount",fixedLength = 0,
                            fmt = {
                                {type = T.INT }
                            }
                        }, --玩家下注顺序
                    }

                },
                {name = "playingState", type = T.INT}, --游戏中阶段
                {name = "all_xia", type = T.INT}, --当前下注总数
                {name = "fillFlag", type = T.BYTE}, --能否加注
                {name = "now_xia", type = T.INT}, --当前注数
                {name = "now_seat", type = T.INT}, --当前操作的座位号
                {name = "time", type = T.INT}, --当前剩余时间
                {name = "all_mount", type = T.INT}, --当前桌子玩家个数
                {name = "userinfos",type = T.ARRAY,fixedLengthParser="all_mount",fixedLength = 0,
                    fmt = {
                        {name = "uid", type = T.INT}, --用户id
                        {name = "seat", type = T.INT}, --用户座位号
                        {name = "sex", type = T.BYTE}, --性别
                        {name = "nickName", type = T.STRING}, --用户Json串
                        {name = "photoUrl", type = T.STRING}, --用户Json串
                        {name = "latitude", type = T.STRING}, --用户Json串
                        {name = "longitude", type = T.STRING}, --用户Json串
                        {name = "otherInfo", type = T.STRING}, --用户个人信息
                        {name = "ip", type = T.STRING}, --用户Json串
                        {name = "m_chips", type = T.INT}, --用户金币
                        {name = "gold", type = T.INT}, --用户金币
                        {name = "playing", type = T.INT}, --用户是否在玩
                        {name = "cancel", type = T.INT}, --用户是否弃牌
                        {name = "xia", type = T.INT}, --玩家下注金币
                        {name = "bet_mount", type = T.INT}, --玩家可加注数量
                        {name = "bet_values", type = T.ARRAY,fixedLengthParser="bet_mount",fixedLength = 0,
                            fmt = {
                                {type = T.INT }
                            }
                        }, --玩家下注顺序
                        {name = "card_size", type = T.BYTE}, --玩家可加注数量
                        {name = "cards", type = T.ARRAY,fixedLengthParser="card_size",fixedLength = 0,
                            fmt = {
                                {type = T.BYTE }
                            }
                        },
                    }
                },

            }
        },
        {name = "isGoldGame", type = T.BYTE}, --为组局场和金币场的标记  1是组局 0是金币
        {name = "gameConfig", type = T.STRING},-- 配置信息
    }
}


P.SVR_MSG_FACE                 =0x1004
SERVER[P.SVR_MSG_FACE]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},
        {name="type",type=T.INT}
    }

}

--组局排行榜
P.SVR_GROUP_RANKING                   = 0x5100
SERVER[P.SVR_GROUP_RANKING] =  {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.BYTE},--土豪
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "sex", type = T.BYTE}, --性别
                {name = "nickName", type = T.STRING}, --用户Json串
                {name = "photoUrl", type = T.STRING}, --用户Json串
                {name = "totalChips", type = T.INT}, --用户Json串
            }
        },
        {name = "game_amount", type = T.INT},--总局数
    }
}
--组局时长
P.SVR_GROUP_TIME                  = 0x5101
SERVER[P.SVR_GROUP_TIME] =  {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT},--当前组局剩余时间
        {name = "round", type = T.INT},--当前组局已进行多少局
        {name = "round_total", type = T.INT},--当前组局总局数
    }
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
--玩家进入私人房
--[[P.SVR_ENTER_PRIVATE_ROOM                  = 0x0212
SERVER[P.SVR_ENTER_PRIVATE_ROOM] =  {
    ver = 1,
    fmt = {
        {name = "flag", type = T.SHORT},
        {name = "ret", type = T.SHORT}
    }
}]]
--广播玩家ip
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
P.SVR_BROADCAST_COUNT_DOWN         = 0x100f   --广播倒计时
SERVER[P.SVR_BROADCAST_COUNT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.BYTE}, --返回码
    }
}
P.BROADCAST_ERROR_TIPS  =          0x5001   --错误码
SERVER[P.BROADCAST_ERROR_TIPS] = {
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT},
    }
}
P.BROADCAST_ERROR_STATUS = 0x159
SERVER[P.BROADCAST_ERROR_STATUS] = {
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT},
    }
}
P.SVR_KAN_SHOW        = 0x6029   -- 可以看牌
SERVER[P.SVR_KAN_SHOW] = {
    ver = 1,
}

P.SVR_CHARGE_BROADCAST                 =0x111
SERVER[P.SVR_CHARGE_BROADCAST]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},
        {name="chargeCoins",type=T.INT}
    }

}

return HALL_SERVER_PROTOCOL