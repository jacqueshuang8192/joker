--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--
local T = bm.PACKET_DATA_TYPE

local HALL_PROTOCOL = require("hall.HALL_PROTOCOL")
local P = class("HALL_SERVER_PROTOCOL",HALL_PROTOCOL)

local HALL_SERVER_PROTOCOL = P
--P.CONFIG = {}
--P.CONFIG.CLIENT = {}
--P.CONFIG.SERVER = {}
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
P.CLI_LOGIN_ROOM                         = 0x1001                         --登录房间
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
        {name = "addres", type = T.STRING}, --
    }
}

P.CLI_SIT_DOWN                           = 0x1031                         --坐下
CLIENT[P.CLI_SIT_DOWN] = {
    ver = 1,
    {name="seat_id",type = T.INT}, --座位id       
}

P.CLI_STAND_UP  =          0x1032   --站起
CLIENT[P.CLI_STAND_UP] = {
    ver = 1,
}

P.CLI_READY_GAME                         = 0x2001                         --用户发送准备
CLIENT[P.CLI_READY_GAME] = {
    ver = 1,
    {name = "readyState", type = T.INT},--0是取消准备，1是准备
}

P.CLI_PLAYER_OUT_CARD                    = 0x1201                         --玩家出牌
CLIENT[P.CLI_PLAYER_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "Cardvalue", type = T.INT},--玩家出牌的值(0x01)
    }
}

P.CLI_PASS                               = 0x1202                         --玩家过牌(不要牌 pass)
CLIENT[P.CLI_PASS] = nil

P.CLI_PLAYER_CHI_CARD                    = 0x1203                         --玩家吃牌
CLIENT[P.CLI_PLAYER_CHI_CARD] = {
    ver = 1,
    fmt = {
        {name = "cardV1", type = T.BYTE},    --第一张牌的值
        {name = "cardV2", type = T.BYTE},    --第二张牌的值

        {name = "biCardValue", type = T.INT}, --比牌的数值
        {name = "Cardcount", type = T.INT},   --玩家比牌的数量
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {name = "value", type = T.INT},               --牌的数值
            }
        }
    }
}
--别人偎提示
P.CLI_CHECK_WEI                   = 0x1214
CLIENT[P.CLI_CHECK_WEI] =  {
    ver = 1,
    fmt = {
        {name = "card", type = T.INT},--是否别人有偎
    }
}
P.CLI_PLAYER_BI_CARD                    = 0x1213                         --玩家比牌
CLIENT[P.CLI_PLAYER_BI_CARD] = {
    ver = 1,
    fmt = {
        {name = "biCardValue", type = T.INT}, --比牌的数值
        {name = "Cardcount", type = T.INT},   --玩家比牌的数量
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {name = "value", type = T.INT},               --牌的数值
            }
        }
    }
}

P.CLI_PLAYER_PENG_CARD                   = 0x1204                         --玩家碰牌
CLIENT[P.CLI_PLAYER_PENG_CARD] = {
    ver = 1,
}

P.CLI_PLAYER_PAO_CARD                    = 0x1205                          --玩家跑牌
CLIENT[P.CLI_PLAYER_PAO_CARD] = {
    ver = 1,
}

P.CLI_PLAYER_HU_CARD                     = 0x1208                          --玩家胡牌
CLIENT[P.CLI_PLAYER_HU_CARD] = {
    ver = 1,
}

P.CLI_QUIT_ROOM                          = 0x1033                         --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

P.C2G_CMD_DISSOLVE_ROOM                  = 0x808                          --请求解散房间 
CLIENT[P.C2G_CMD_DISSOLVE_ROOM] = {
    ver = 1
}

P.C2G_CMD_REPLY_DISSOLVE_ROOM            = 0x809                          --回复请求解散房间
CLIENT[P.C2G_CMD_REPLY_DISSOLVE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "agree", type = T.INT} --0为拒绝解散，1为解散
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

-- P.CLI_BROADCAST_GROUP_RESULT             = 0x1209                         --请求总结算
-- CLIENT[P.CLI_BROADCAST_GROUP_RESULT] = {
    -- ver = 1,
-- }


-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------

P.SERVER_CMD_MESSAGE                = 0x801    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING}, --消息
    }
}

P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

P.BROADCAST_ERROR_STATUS = 0x159
SERVER[P.BROADCAST_ERROR_STATUS] = {
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT},
    }
}

P.SVR_LOGIN_ROOM_FAIL               = 0x1005   --登陆房间失败提示
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT},  --错误码
    }
}

P.SVR_QUIT               = 0x1008   --自己退出房间
SERVER[P.SVR_QUIT] = {
    ver = 1,
}
P.SVR_LOGIN_ROOM_BROADCAST               = 0x100D                         --服务器广播用户登陆房间
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},             --玩家uid
        {name = "seat_id", type = T.INT},         --玩家座位号
        {name = "if_ready", type = T.BYTE},       --玩家座位号
        {name = "sex",type = T.BYTE},             --座位id
        {name = "nickName",type = T.STRING},      --用户json字符串
        {name = "portrait",type = T.STRING},      --用户金币
        {name = "latitude",type = T.STRING},      --用户赢数
        {name = "longitude",type = T.STRING},     --用户输数
        {name = "otherInfo", type = T.STRING},    --用户个人信息 
        {name = "ip",type = T.STRING},            --用户状态
		{name = "addres",type = T.STRING},		  --地址
        {name = "m_chips", type = T.INT},       --玩家筹码数
        {name = "m_totalBlc", type = T.INT},  --玩家筹码数
    }
}


P.SVR_LOGIN_ROOM_OK              = 0x1007    --登录房间OK
SERVER[P.SVR_LOGIN_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "max_mount", type = T.SHORT},   --桌子上其他玩家的个数
		{name = "m_bAIUser", type = T.INT}, 
        {name = "Basechip", type = T.INT},       --房间底注
        {name = "seat_id", type = T.SHORT},      --座位ID
        {name = "inviteCode", type = T.STRING},  --房间号

        {name = "user_mount", type = T.SHORT},   --桌子上其他玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLength = "user_mount", fixedLengthParser = "user_mount",
            fmt = {
                {name = "uid", type = T.INT},           -- 其他玩家的uid
                {name = "m_chips",type = T.INT},        -- 玩家积分
                {name = "m_totalBlc",type = T.INT},        -- 玩家累计分数
                {name = "seat_id", type = T.SHORT},     -- 其他玩家的seatid
                {name = "if_ready", type = T.SHORT},    -- 其他玩家是否准备
                {name = "if_online", type = T.SHORT},   -- 其他玩家是否在线
                {name = "sex",type = T.BYTE},           -- 座位id
                {name = "nickName",type = T.STRING},    -- 用户json字符串
                {name = "portrait",type = T.STRING},    -- 用户头像
                {name = "latitude",type = T.STRING},    -- 
                {name = "longitude",type = T.STRING},   --
                {name = "otherInfo", type = T.STRING},  -- 用户个人信息 
                {name = "ip",type = T.STRING},          -- IP 
				{name = "addres",type = T.STRING},      -- 地址  
            }
        },
        {name = "OwnerID", type = T.INT},--房主ID
        {name = "RoomInfo", type = T.STRING}--房间信息
    }
}

P.SVR_BROADCAST_USER_LEAVEROOM                = 0x1033    --服务器广播玩家退出
SERVER[P.SVR_BROADCAST_USER_LEAVEROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
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

P.BROADCAST_USER_SIT_DOWN                = 0x1031                         --广播坐下
SERVER[P.BROADCAST_USER_SIT_DOWN] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT},          --玩家ID
        {name = "seat_id", type = T.INT},      --座位id  
        {name = "sex",type = T.BYTE},          --性别
        {name = "nickName",type = T.STRING},   --用户json字符串
        {name = "portrait",type = T.STRING},   --用户金币
        {name = "m_chips",type = T.INT},     --用户金币
        {name = "m_totalBlc",type = T.INT},     --用户金币
        {name = "latitude",type = T.STRING},    -- 
        {name = "longitude",type = T.STRING},   --
		{name = "ip",type = T.STRING},			--IP
		{name = "addres",type = T.STRING},      -- 地址
    }
}

P.BROADCAST_USER_STAND_UP  =          0x1032   --站起
SERVER[P.BROADCAST_USER_STAND_UP] = {
    ver = 1,
    fmt ={
        {name = "uid", type = T.INT}, 
    }
}


P.SVR_BROADCAST_USER_LEAVEROOM                = 0x1033    --服务器广播玩家退出
SERVER[P.SVR_BROADCAST_USER_LEAVEROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
    }
}

P.SVR_LOGOUT_ROOM                = 0x100E    --服务器广播玩家退出
SERVER[P.SVR_LOGOUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "Uid", type = T.INT},
    }
}


P.SVR_READY_GAME                         = 0x2001                         --用户准备返回
SERVER[P.SVR_READY_GAME] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}--用户ID
    }
}

P.SVR_DEAL                               = 0x4001                         --发牌
SERVER[P.SVR_DEAL] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},          -- 玩家座位号
        {name = "diPaiCount", type = T.INT},       -- 底牌的个数
        {name = "banker_seat_id", type = T.INT},   -- 庄家家座位号
        {name = "Cardcount", type = T.SHORT},      -- 玩家操作数量
        {name = "HandCardDatas", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},              -- 牌的数值
            }
        },
        -- {name = "tingCardcount", type = T.BYTE},      -- 玩家听牌数量
        -- {name = "tingCardDatas", type = T.ARRAY,fixedLengthParser = "tingCardcount",fixedLength = 0,
            -- fmt = {
                -- {type = T.BYTE},              -- 牌的数值
            -- }
        -- }
    }
}

P.SVR_BUPAI_DEAL                               = 0x4011                         --补牌
SERVER[P.SVR_BUPAI_DEAL] = {
    ver = 1,
    fmt = {
        {name = "diPaiCount", type = T.INT},     --底牌数量
        {name = "seat_id", type = T.INT},         -- 玩家座位号
        {name = "card_from", type = T.INT},       -- 牌顶0，牌低1，是否补牌
        {name = "card_value", type = T.BYTE},     -- 牌的数值
        {name = "if_draw", type = T.INT},         -- 是否是第21张 0:不是   1：是
    }
}

P.SVR_PLAYER_OPRATION                          = 0x4002                         --玩家开始做操作
SERVER[P.SVR_PLAYER_OPRATION] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "Cardcount", type = T.INT},   --玩家操作数量
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.INT},               --三个操作，胡、碰、吃、跑(0:表示不显示，1：表示显示)
            }
        }
    }
}

P.SVR_PLAYER_OUT_CARD                         = 0x4012                         --轮到哪个玩家出牌
SERVER[P.SVR_PLAYER_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "out_time", type = T.INT},    --玩家操作时间
    }
}

P.SVR_PLAYER_TING_INFO                         = 0x4013                         --玩家听牌信息
SERVER[P.SVR_PLAYER_TING_INFO] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
		{name = "tingCount", type = T.BYTE},
        {name="tingCards", type = T.ARRAY,fixedLengthParser = "tingCount",fixedLength = 0,
         fmt={
             {name="card",type=T.BYTE},
             {name = "tingHuCount", type = T.BYTE},
             {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCount",fixedLength = 0,
              fmt = {
                  {type = T.BYTE},--打出对应牌后，听胡的牌
              }
             },
         }
        },
    }
}


P.SVR_PLAYER_CHU_CARD                    = 0x1201                         --玩家出牌
SERVER[P.SVR_PLAYER_CHU_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "CardValue", type = T.INT},   --出牌的数值
        {name = "tingCardcount", type = T.BYTE},      -- 玩家听牌数量
        {name = "tingCardDatas", type = T.ARRAY,fixedLengthParser = "tingCardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},              -- 牌的数值
            }
        }
    }
}

P.SVR_PLAYER_CHI_CARD                    = 0x1203                         --玩家吃牌
SERVER[P.SVR_PLAYER_CHI_CARD] = {
    ver = 1,
    fmt = {
        {name = "diPaiCount", type = T.INT},     --底牌数量
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "Cardcount", type = T.INT},   --玩家吃牌的组合
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.INT}, --牌的数值
            }
        }
    }
}

P.SVR_PLAYER_BI_CARD                    = 0x1213                         --玩家比牌
SERVER[P.SVR_PLAYER_BI_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "biCardValue", type = T.INT},     
        {name = "Cardcount", type = T.INT},   --玩家比牌的数量
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.INT},               --牌的数值
            }
        },
		{name = "isDeath", type = T.BYTE},     --玩家是否死手(没有牌可出， 1表示死手，0表示非死手)
    }
}

P.SVR_PLAYER_PENG_CARD                   = 0x1204                         --玩家碰牌
SERVER[P.SVR_PLAYER_PENG_CARD] = {
    ver = 1,
    fmt = {
        {name = "diPaiCount", type = T.INT},     --底牌数量
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "CardValue", type = T.INT},   --碰牌的数值
    }
}

P.SVR_PLAYER_PAO_CARD                    = 0x1205                         --玩家跑
SERVER[P.SVR_PLAYER_PAO_CARD] = {
    ver = 1,
    fmt = {
        {name = "diPaiCount", type = T.INT},     --底牌数量
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "CardValue", type = T.INT},   --跑牌的数值
    }
}

P.SVR_PLAYER_TI_CARD                     = 0x1206                         --玩家提牌
SERVER[P.SVR_PLAYER_TI_CARD] = {
    ver = 1,
    fmt = {
        {name = "diPaiCount", type = T.INT},     --底牌数量
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "CardValue", type = T.INT},   --提牌的数值
    }
}

P.SVR_PLAYER_WEI_CARD                    = 0x1207                        --玩家偎牌
SERVER[P.SVR_PLAYER_WEI_CARD] = {
    ver = 1,
    fmt = {
        {name = "diPaiCount", type = T.INT},     --底牌数量
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "cardType", type = T.INT},     --偎牌的类型 0：明偎，1：暗偎
        {name = "CardValue", type = T.INT},   --偎牌的数值
    }
}
P.SVR_PLAYER_HU_CARD                     = 0x1208                        --玩家胡牌
SERVER[P.SVR_PLAYER_HU_CARD] = {
    ver = 1,
    fmt = {
        {name = "nRoundResult", type = T.SHORT},     --流局还是胡牌了
        {name = "isZiMo", type = T.SHORT},     --是否自摸
        {name = "m_HuCard", type=T.BYTE},  --用户胡的牌
        {name = "nFangPaoSeat", type=T.INT},  --放炮玩家seat id
        {name = "endGame", type=T.BYTE},  --是否组局结束
        {name = "m_CurCardCount",type=T.BYTE},--底牌剩余张数
        {name = "currCardArr", type = T.ARRAY,fixedLengthParser = "m_CurCardCount",fixedLength = 0,
         fmt = {
             {name = "card", type = T.BYTE},               --牌的数值
         }
        },
		{name = "chouPaiCount",type=T.BYTE},--抽牌张数
        {name = "chouCardArr", type = T.ARRAY,fixedLengthParser = "chouPaiCount",fixedLength = 0,
         fmt = {
             {name = "card", type = T.BYTE},               --牌的数值
         }
        },
        {name = "userCount",type=T.SHORT},--用户数量
        {name = "userArr", type = T.ARRAY,fixedLengthParser = "userCount",fixedLength = 0,
         fmt = {
             {name = "uid", type = T.INT},               --userId
             {name = "seat_id", type = T.BYTE},               --userId
             {name = "isHu", type = T.BYTE},               --userId
             {name = "m_chips", type = T.INT},               --用户积分
             {name = "m_totalBlc", type = T.INT},               --总输赢分
             {name = "m_turnBlc", type = T.INT},               --输赢分
             {name = "m_oil", type = T.INT},               --胡息
             {name = "huxi", type = T.INT},               --单局结算胡息数
             {name = "taisCount", type = T.SHORT},
             {name = "taiList", type = T.ARRAY,fixedLengthParser = "taisCount",fixedLength = 0,
              fmt = {
                  {name ="byType",type = T.BYTE},               --全名堂的类型
                  {name ="byCount",type = T.BYTE},              --倍数
				  {name ="iExtHuXi",type = T.INT},              --额外的胡息数
              }
             },
             {name = "m_byHandCardCount", type = T.SHORT},               --手牌数量
             {name = "handCardArr", type = T.ARRAY,fixedLengthParser = "m_byHandCardCount",fixedLength = 0,
              fmt = {
                  {type = T.BYTE},               --牌的数值
              }
             },
             {name = "pen_count", type = T.SHORT},               --碰牌
             {name = "penCardArr", type = T.ARRAY,fixedLengthParser = "pen_count",fixedLength = 0,
              fmt = {
                  {name = "score", type = T.INT},               --碰牌分数
                  {name = "card", type = T.BYTE},               --牌的数值
              }
             },
             {name = "ti_count", type = T.SHORT},               --提牌
             {name = "tiCardArr", type = T.ARRAY,fixedLengthParser = "ti_count",fixedLength = 0,
              fmt = {
                  {name = "score", type = T.INT},               --提牌分数
                  {name = "card", type = T.BYTE},               --牌的数值
              }
             },
             {name = "pao_count", type = T.SHORT},               --跑牌
             {name = "paoCardArr", type = T.ARRAY,fixedLengthParser = "pao_count",fixedLength = 0,
              fmt = {
                  {name = "score", type = T.INT},               --碰牌分数
                  {name = "card", type = T.BYTE},               --牌的数值
              }
             },
             {name = "wei_count", type = T.SHORT},               --偎牌
             {name = "weiCardArr", type = T.ARRAY,fixedLengthParser = "wei_count",fixedLength = 0,
              fmt = {
                  {name = "score", type = T.INT},               --偎牌分数
                  {name = "opt", type = T.BYTE},               --臭偎 或者暗偎
                  {name = "card", type = T.BYTE},               --牌的数值
              }
             },
             {name = "bi_count", type = T.SHORT},                 --比牌的数量（吃了几次牌）
             {name = "biCardArr", type = T.ARRAY, fixedLengthParser = "bi_count",fixedLength = 0,
              fmt = {
                  {name = "xishu", type = T.INT},                --比牌的系数
                  {name = "card_count", type = T.BYTE},
                  {name = "cards", type = T.ARRAY,fixedLengthParser = "card_count",fixedLength = 0,
                   fmt = {
                       {type = T.BYTE},  --扑克牌数值
                   }
                  },
              }
             },
             {name = "chi_count", type = T.SHORT},                 --吃牌的数量（吃了几次牌）
             {name = "chiCardArr", type = T.ARRAY, fixedLengthParser = "chi_count",fixedLength = 0,
                 fmt = {
                     {name = "xishu", type = T.INT},                --吃牌的系数
                     {name = "card_count", type = T.BYTE},
                     {name = "cards", type = T.ARRAY,fixedLengthParser = "card_count",fixedLength = 0,
                         fmt = {
                             {type = T.BYTE},  --扑克牌数值
                         }
                     },
                 }

             },
         },
        },
        {name = "huUserCount",type=T.BYTE},-- 胡牌组合
        {name = "huUserArr", type = T.ARRAY,fixedLengthParser = "huUserCount",fixedLength = 0,
         fmt = {
             {name = "uid",type = T.INT},               --用户id
             {name = "seat_id",type = T.BYTE},               --用户SEAT_ID
             {name = "group_count", type = T.BYTE},               --牌的数数量
             {name = "groupArr", type = T.ARRAY,fixedLengthParser = "group_count",fixedLength = 0,
              fmt = {
                  {type = T.BYTE},               --牌的数值
              },
             },
             {name = "groupType", type = T.BYTE},
             {name = "cardGroupCount", type = T.BYTE},
             {name = "cardGroupArr", type = T.ARRAY,fixedLengthParser = "cardGroupCount",fixedLength = 0,
              fmt = {
                  {name = "type", type = T.BYTE},               --
                  {name = "cardCount", type = T.BYTE},
                  {name = "cards", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
                   fmt = {
                       {type = T.BYTE},               --牌的数值
                   },
                  },
              },
             },
         }
        },
    }
}
--P.SVR_PLAYER_HU_CARD                     = 0x1208                        --玩家胡牌
--SERVER[P.SVR_PLAYER_HU_CARD] = {
--    ver = 1,
--    fmt = {
--
--        {name = "pengcount", type = T.INT},                --碰牌的数量（碰了几次牌）
--        {name = "pengList", type = T.ARRAY, fixedLengthParser = "pengcount",fixedLength = 0,
--            fmt = {
--                {name = "xishu", type = T.INT},                --碰牌的系数
--                {name = "cardvalue", type = T.INT},            --牌的值
--            }
--        },
--
--        {name = "ticount", type = T.INT},                --提牌的数量（提了几次牌）
--        {name = "tiList", type = T.ARRAY, fixedLengthParser = "ticount",fixedLength = 0,
--            fmt = {
--                 {name = "xishu", type = T.INT},                --提牌的系数
--                {name = "cardvalue", type = T.INT},            --牌的值
--            }
--
--        },
--
--        {name = "paocount", type = T.INT},                --跑牌的数量（跑了几次牌）
--        {name = "paoList", type = T.ARRAY, fixedLengthParser = "paocount",fixedLength = 0,
--            fmt = {
--                {name = "xishu", type = T.INT},               --跑牌的系数
--                {name = "cardvalue", type = T.INT},            --牌的值
--            }
--
--        },
--
--        {name = "weicount", type = T.INT},                --偎牌的数量（偎了几次牌）
--        {name = "weiList", type = T.ARRAY, fixedLengthParser = "weicount",fixedLength = 0,
--            fmt = {
--                {name = "xishu", type = T.INT},                --偎牌的系数
--                {name = "cardType", type = T.INT},              --偎牌的类型 0：明偎，1：暗偎
--                {name = "cardvalue", type = T.INT},            --牌的值
--            }
--
--        },
--
--        {name = "chicount", type = T.INT},                 --吃牌的数量（吃了几次牌）
--        {name = "chiList", type = T.ARRAY, fixedLengthParser = "chicount",fixedLength = 0,
--            fmt = {
--                {name = "xishu", type = T.INT},                --吃牌的系数
--                {name = "Cardcount", type = T.INT},
--                {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
--                    fmt = {
--                        {type = T.INT},  --扑克牌数值
--                    }
--                },
--            }
--
--        },
--
--        {name = "bicount", type = T.INT},                 --比牌的数量（吃了几次牌）
--        {name = "biList", type = T.ARRAY, fixedLengthParser = "bicount",fixedLength = 0,
--            fmt = {
--                {name = "xishu", type = T.INT},                --比牌的系数
--                {name = "Cardcount", type = T.INT},
--                {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
--                    fmt = {
--                        {type = T.INT},  --扑克牌数值
--                    }
--                },
--            }
--        },
--
--        {name = "dicount", type = T.INT},                 --剩余底牌的数量(包含胡的那张牌)
--        {name = "diList", type = T.ARRAY, fixedLengthParser = "dicount",fixedLength = 0,
--            fmt = {
--                {type = T.INT},  --扑克牌数值
--            }
--        },
--        {name = "groupSize", type = T.INT},                 --胡牌组合
--        {name = "group", type = T.ARRAY, fixedLengthParser = "groupSize",fixedLength = 0,
--         fmt = {
--             {type = T.INT},  --扑克牌数值
--         }
--        },
--        {name = "groupType", type = T.INT},   --胡牌组合的类型  1，吃 ，2碰，3砍，4一对
--        {name = "groupListSize", type = T.INT},                 --胡牌组合列表
--        {name = "groupList", type = T.ARRAY, fixedLengthParser = "groupListSize",fixedLength = 0,
--         fmt = {
--             {name = "groupType", type = T.INT},   --胡牌组合的类型  1，吃 ，2碰，3砍，4一对
--             {name = "groupSize", type = T.INT},                 --胡牌组合
--             {name = "group", type = T.ARRAY, fixedLengthParser = "groupSize",fixedLength = 0,
--              fmt = {
--                  {type = T.INT},  --扑克牌数值
--              }
--             },
--         }
--        },
--        {name = "huTypeSize", type = T.BYTE},                 --胡牌类型组合
--        {name = "groupHuType", type = T.ARRAY, fixedLengthParser = "huTypeSize",fixedLength = 0,
--         fmt = {
--             {type = T.BYTE},  --胡牌类型
--         }
--        },
--        {name = "tunShu",type = T.INT},                 --屯数
--        {name = "isZiMo",type = T.INT},                   --是否自摸
--        {name = "fanshu",type = T.INT},                   --玩家蕃数多少（好像是可以翻多少倍）
--        {name = "m_CheckCard",type = T.INT},                   --胡的牌
--
--        {name = "playercount", type = T.INT},             --玩家的个数
--        {name = "playerList", type = T.ARRAY, fixedLengthParser = "playercount",fixedLength = 0,
--            fmt = {
--                {name = "uid", type = T.INT},             --玩家id
--                {name = "fxScore",type = T.INT},          --玩家总输赢
--                {name = "isWin", type = T.INT},           --输：-1  平：0  赢：1
--                {name = "score", type = T.INT},           --赢或者输的积分
--                {name = "Cardcount", type = T.SHORT},     --玩家还剩的牌的数量
--                {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
--                    fmt = {
--                        {type = T.INT}, --扑克牌数值
--                    }
--                },
--            }
--        },
--    }
--}

--总结算 
P.G2H_BROADCAST_GROUP_RESULT                   = 0x1209
SERVER[P.G2H_BROADCAST_GROUP_RESULT] =  {
    ver = 1,
    fmt = {
        {name = "isShowSingle", type = T.BYTE},          --是否直接显示总结算
        {name = "player_count", type = T.BYTE},          --游戏玩家总人数
        {name = "player_info", type = T.ARRAY, fixedLengthParser = "player_count",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "sex", type = T.BYTE},
                {name = "nick_name", type = T.STRING},
                {name = "photo_url", type = T.STRING},
                {name = "m_totalBlc", type = T.INT},
                {name = "huxilistNum", type = T.INT},    --每个玩家胡息总数量
                {name = "huxilist", type = T.ARRAY,fixedLengthParser = "huxilistNum",fixedLength = 0,
                    fmt = {
                        {type = T.INT},   --每一局玩家的胡息
                    }
                },
            },
        },
    }
}


P.SVR_RELOAD_ROOM                = 0x1009    --玩家重连逻辑
SERVER[P.SVR_RELOAD_ROOM] = {
    ver = 1,
    fmt = {
        {name = "max_mount", type = T.SHORT},   --桌子上其他玩家的个数
        {name = "Basechip", type = T.INT},       --房间底注
        {name = "inviteCode", type = T.STRING},  --房间号
        {name = "diPaiCount", type = T.INT},     --牌得个数
        {name = "Playercount", type = T.SHORT},  --所有玩家
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "Playercount",fixedLength = 3,
             fmt = {
                {name = "uid", type = T.INT},           -- 所有玩家的uid
                {name = "m_chips",type = T.INT},        -- 玩家积分
                {name = "m_totalBlc",type = T.INT},        -- 玩家积分
                {name = "seat_id", type = T.SHORT},     -- 所有玩家的seatid
                {name = "if_ready", type = T.SHORT},    -- 所有玩家是否准备
                {name = "if_online", type = T.SHORT},   -- 所有玩家是否在线
                {name = "sex",type = T.BYTE},           -- 座位id
                {name = "nickName",type = T.STRING},    -- 用户json字符串
                {name = "portrait",type = T.STRING},    -- 用户头像
                {name = "latitude",type = T.STRING},    -- 
                {name = "longitude",type = T.STRING},   --
				{name = "ip",type = T.STRING},			--IP
				{name = "addres",type = T.STRING},      -- 地址
				{name = "AIState", type = T.BYTE},   --玩家托管状态
            }
        },
        {name = "OwnerID", type = T.INT},--房主ID
        {name = "GAME_STATE", type = T.SHORT},--游戏状态  0 空闲，1:进行中
        {name = "Handcardcount", type = T.SHORT},--手牌数量
        {name = "HandCardDatas", type = T.ARRAY,fixedLengthParser = "Handcardcount",fixedLength = 2,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        },

        {name = "banker_seat_id", type = T.INT},--当前庄家id

        {name = "time", type = T.INT},--当前组局剩余时间
        {name = "round", type = T.INT},--当前组局已进行多少局
        {name = "round_total", type = T.INT},--当前组局总局数
        {name = "m_nCurGetCarCardSeatId",type = T.INT},--当前摸牌ID
        {name = "m_CurGetCard",type = T.BYTE},--当前摸牌的值
        {name = "OutCardUserId", type = T.INT},--当前要出牌玩家id
        {name = "m_CurOutCard", type = T.BYTE},--出牌的值ID
        {name = "LeftTime", type = T.SHORT},   --出牌剩余时间
        --3个玩家出过的牌
        {name = "LastCardDataCount", type = T.SHORT},   --操作牌的玩家个数
        {name = "LastCarddata", fixedLengthParser = "LastCardDataCount",type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "seat_id", type = T.SHORT},   -- 所有玩家的seatid
                {name = "CardCount",type = T.SHORT},--出牌数量
                {name = "cards", type = T.ARRAY,fixedLengthParser = "CardCount",fixedLength = 0,
                    fmt = {
                        {type = T.INT},   --扑克牌数值
                    }
                },
            }
        },
        --3个玩家吃、碰、提、偎、跑的牌
        {name = "CardDataCount", type = T.SHORT},   --操作牌的玩家个数
        {name = "Carddata",fixedLengthParser = "CardDataCount", type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "seat_id", type = T.SHORT},   -- 所有玩家的seatid
                {name = "pengcount", type = T.INT},                --碰牌的数量（碰了几次牌）
                {name = "pengList", type = T.ARRAY, fixedLengthParser = "pengcount",fixedLength = 3,
                    fmt = {
                        {name = "cardvalue", type = T.INT},            --牌的值
                    }
                },

                {name = "ticount", type = T.INT},                  --提牌的数量（提了几次牌）
                {name = "tiList", type = T.ARRAY, fixedLengthParser = "ticount",fixedLength = 3,
                    fmt = {
                        {name = "cardvalue", type = T.INT},            --牌的值
                    }
                    
                },

                {name = "paocount", type = T.INT},                --跑牌的数量（跑了几次牌）
                {name = "paoList", type = T.ARRAY, fixedLengthParser = "paocount",fixedLength = 3,
                    fmt = {
                        {name = "cardvalue", type = T.INT},            --牌的值
                    }
                    
                },

                {name = "weicount", type = T.INT},                --偎牌的数量（偎了几次牌）
                {name = "weiList", type = T.ARRAY, fixedLengthParser = "weicount",fixedLength = 3,
                    fmt = {
                        {name = "cardType", type = T.INT},              --偎牌的类型 0：明偎，1：暗偎
                        {name = "cardvalue", type = T.INT},            --牌的值
                    }
                    
                },

                {name = "chicount", type = T.INT},                 --吃牌的数量（吃了几次牌）
                {name = "chiList", type = T.ARRAY, fixedLengthParser = "chicount",fixedLength = 3,
                    fmt = {
                        {name = "Cardcount", type = T.INT},            
                        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
                            fmt = {
                                {type = T.INT},  --扑克牌数值
                            }
                        },
                    }
                },

                {name = "bicount", type = T.INT},                 --牌的数量（吃了几次牌）
                {name = "biList", type = T.ARRAY, fixedLengthParser = "bicount",fixedLength = 0,
                    fmt = {
                        {name = "card", type = T.INT},                 --比的那张牌
                        {name = "cardsCount", type = T.INT},                 --
                        {name = "cardsList", type = T.ARRAY, fixedLengthParser = "cardsCount",fixedLength = 3,
                         fmt = {

                             {name = "Cardcount", type = T.INT},
                             {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
                              fmt = {
                                  {type = T.INT},  --扑克牌数值
                              }
                             },
                         }
                        },
                    }
                },
            }
        },
		{name = "tingCount", type = T.BYTE},
        {name="tingCards", type = T.ARRAY,fixedLengthParser = "tingCount",fixedLength = 0,
         fmt={
             {name="card",type=T.BYTE},
             {name = "tingHuCount", type = T.BYTE},
             {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCount",fixedLength = 0,
              fmt = {
                  {type = T.BYTE},--打出对应牌后，听胡的牌
              }
             },
         }
        },
		{name = "tingHuCardCount",type = T.BYTE},--当前听胡的牌数量
        {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCardCount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --听胡的牌
            }
        },
        {name = "RoomInfo", type = T.STRING}--房间信息
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
P.BROADCAST_ERROR_TIPS  =          0x5001   --错误提示
SERVER[P.BROADCAST_ERROR_TIPS] = {
    ver = 1,
    fmt ={
        {name = "errorCode", type = T.SHORT},
    }
}
--最后的总结算
P.SVR_GROUP_BILLBOARD                   = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] =  {
    ver = 1,
    fmt = {
        {name = "game_amount", type = T.INT},--总局数
    }
}


--别人偎提示
P.SVR_SEND_WEI                   = 0x1214
SERVER[P.SVR_SEND_WEI] =  {
    ver = 1,
    fmt = {
        {name = "flag", type = T.SHORT},--是否别人有偎
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
--请求测试用牌
P.SVR_REQ_TEST_CARDS                  = 0x1109
SERVER[P.SVR_REQ_TEST_CARDS] =  {
    ver = 1,
    fmt = {
        {name = "cardCount", type = T.BYTE},--
        {name = "cards", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
    }
}
--请求测试用牌
P.CLI_REQ_TEST_CARDS                  = 0x1109
CLIENT[P.CLI_REQ_TEST_CARDS] =  {
    ver = 1,
    fmt = {

    }
}
--请求测试牌
P.CLI_TEST_CARD                  = 0x110A
CLIENT[P.CLI_TEST_CARD] =  {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE},--
    }
}
P.SVR_PLAYER_AI_STATE                    = 0x1212                         --玩家托管状态
SERVER[P.SVR_PLAYER_AI_STATE] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "AIState", type = T.BYTE},    --是否是托管（0未托管，1已托管）
    }
}

P.CLI_PLAYER_CANCELAUTO  =          0x1212   --0玩家取消托管 1托管
CLIENT[P.CLI_PLAYER_CANCELAUTO] = {
    fmt = {
        {name = "auto", type = T.BYTE},--
    }
}
return HALL_SERVER_PROTOCOL




