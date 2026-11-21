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

P.CLI_PLAYER_TONG_CARD                   = 0x1203                         --玩家统
CLIENT[P.CLI_PLAYER_TONG_CARD] = {
    ver = 1,
}

P.CLI_PLAYER_PENG_CARD                   = 0x1204                         --玩家对牌
CLIENT[P.CLI_PLAYER_PENG_CARD] = {
    ver = 1,
}

P.CLI_PLAYER_ZHAO_CARD                    = 0x1205                          --玩家招牌
CLIENT[P.CLI_PLAYER_ZHAO_CARD] = {
    ver = 1,
}

P.CLI_PLAYER_FAN_CARD                    = 0x1206                          --玩家泛牌
CLIENT[P.CLI_PLAYER_FAN_CARD] = {
    ver = 1,
	fmt = {
        {name = "card", type = T.BYTE},--泛的牌
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


P.SVR_LOGOUT_ROOM                = 0x100E    --服务器广播玩家退出
SERVER[P.SVR_LOGOUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
    }
}

P.SVR_PLAYER_TONG_CARD                      = 0x1203             --用户统牌
SERVER[P.SVR_PLAYER_TONG_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},		--用户ID坐位ID
		{name = "tong_count", type = T.INT},	--用户统的次数
    }
}

P.SVR_PLAYER_PENG_CARD                      = 0x1204             --用户碰牌
SERVER[P.SVR_PLAYER_PENG_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},		--用户ID坐位ID
		{name = "diPaiCount", type = T.INT},	--底牌剩余张数
		{name = "peng_count", type = T.INT},	--碰牌数量
		{name = "cards", type = T.ARRAY,fixedLengthParser = "peng_count",fixedLength = 0,
         fmt = {
             {name = "card", type = T.BYTE},               --牌的数值
         }
        },
    }
}

P.SVR_PLAYER_ZHAO_CARD                      = 0x1205             --用户招牌
SERVER[P.SVR_PLAYER_ZHAO_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},		--用户ID坐位ID
		{name = "diPaiCount", type = T.INT},	--底牌剩余张数
		{name = "zhao_count", type = T.INT},	--招牌数量
		{name = "cards", type = T.ARRAY,fixedLengthParser = "zhao_count",fixedLength = 0,
         fmt = {
             {name = "card", type = T.BYTE},               --牌的数值
         }
        },
    }
}

P.SVR_PLAYER_FAN_CARD                      = 0x1206             --用户泛牌
SERVER[P.SVR_PLAYER_FAN_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},		--用户ID坐位ID
		{name = "diPaiCount", type = T.INT},	--底牌剩余张数
		{name = "tong_count", type = T.INT},	--当前统数
		{name = "fan_count", type = T.INT},		--泛牌数量
		{name = "cards", type = T.ARRAY,fixedLengthParser = "fan_count",fixedLength = 0,
         fmt = {
             {name = "card", type = T.BYTE},               --牌的数值
         }
        },
    }
}

P.SVR_PLAYER_HU_CARD                     = 0x1208                        --玩家胡牌
SERVER[P.SVR_PLAYER_HU_CARD] = {
    ver = 1,
    fmt = {
        {name = "nRoundResult", type = T.BYTE},     --流局还是胡牌了
        {name = "isZiMo", type = T.BYTE},     --是否自摸
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
             {name = "uid", type = T.INT},         
             {name = "seat_id", type = T.BYTE},          
             {name = "isHu", type = T.BYTE},             
             {name = "m_chips", type = T.INT},               --用户积分
             {name = "m_totalBlc", type = T.INT},               --总局输赢分
             {name = "m_turnBlc", type = T.INT},               --单局输赢分
             {name = "m_byHandCardCount", type = T.SHORT},               --手牌数量
             {name = "handCardArr", type = T.ARRAY,fixedLengthParser = "m_byHandCardCount",fixedLength = 0,
              fmt = {
                  {type = T.BYTE},               --牌的数值
              }
             },
             {name = "pengcount", type = T.SHORT},                --碰牌的数量（碰了几次牌）
             {name = "pengList", type = T.ARRAY, fixedLengthParser = "pengcount",fixedLength = 0,
                 fmt = {
                     {name = "cardvalue", type = T.BYTE},            --牌的值
                 }
             },

             {name = "zhaocount", type = T.SHORT},                  --招牌的数量（招了几次牌）
             {name = "zhaoList", type = T.ARRAY, fixedLengthParser = "zhaocount",fixedLength = 0,
                 fmt = {
                     {name = "cardvalue", type = T.BYTE},            --牌的值
                 }
             },

             {name = "fancount", type = T.SHORT},                --泛牌的数量（泛了几次牌）
             {name = "fanList", type = T.ARRAY, fixedLengthParser = "fancount",fixedLength = 0,
                 fmt = {
                     {name = "cardvalue", type = T.BYTE},            --牌的值
                 }
                 
             },
         },
        },
        {name = "huUserCount",type=T.BYTE},-- 胡牌组合
        {name = "huUserArr", type = T.ARRAY,fixedLengthParser = "huUserCount",fixedLength = 0,
         fmt = {
			{name = "tong_count", type = T.BYTE},               --统牌的数量
			{name = "tongCardArr", type = T.ARRAY,fixedLengthParser = "tong_count",fixedLength = 0,
				fmt = {
                  {name = "cardCount", type = T.BYTE},
                  {name = "cards", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
                   fmt = {
                       {type = T.BYTE},               --牌的数值
                   },
                  },
				},
            },
			{name = "group_count", type = T.BYTE},               --其它组合的牌的数量
			{name = "groupCardArr", type = T.ARRAY,fixedLengthParser = "group_count",fixedLength = 0,
				fmt = {
                  {name = "cardCount", type = T.BYTE},
                  {name = "cards", type = T.ARRAY,fixedLengthParser = "cardCount",fixedLength = 0,
                   fmt = {
                       {type = T.BYTE},               --牌的数值
                   },
                  },
				},
            },
			{name = "indexBuPai", type = T.INT},               --补牌的索引（-1表示没有，0表示第一个组合，1表示第2个）
			 
             {name = "uid",type = T.INT},               --用户id
             {name = "seat_id",type = T.BYTE},          --用户SEAT_ID
			 {name = "maxHuXi",type = T.INT},           --胡牌最大胡息
             {name = "mainJing",type = T.BYTE},         --主经
         }
        },
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
    }
}

P.SVR_BUPAI_DEAL                               = 0x4011                         --补牌
SERVER[P.SVR_BUPAI_DEAL] = {
    ver = 1,
    fmt = {
        {name = "diPaiCount", type = T.INT},     --底牌数量
        {name = "seat_id", type = T.INT},         -- 玩家座位号
        {name = "card_value", type = T.BYTE},     -- 牌的数值
    }
}

P.SVR_PLAYER_OPRATION                          = 0x4002                         --玩家开始做操作
SERVER[P.SVR_PLAYER_OPRATION] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "isHu", type = T.INT},   --
        {name = "isTong", type = T.INT},   --
        {name = "isZhao", type = T.INT},   --
        {name = "isFan", type = T.INT},   --
        {name = "isDui", type = T.INT},   --
        
    }
}

P.SVR_PLAYER_OUT_CARD                         = 0x4012                         --轮到哪个玩家出牌
SERVER[P.SVR_PLAYER_OUT_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
    }
}

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
                {name = "m_totalBlc",type = T.INT},     -- 玩家积分
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
        {name = "GAME_STATE", type = T.SHORT},--游戏状态  0//停止游戏状态 1//请统状态  2//正在游戏状态 3 //等待下一场游戏开始状态
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
        {name = "out_seat_id", type = T.INT},--最后一个出牌玩家id
        {name = "m_CurOutCard", type = T.BYTE},--最后一个出牌的值ID
        --{name = "LeftTime", type = T.SHORT},   --出牌剩余时间
        --3个玩家出过的牌
        {name = "LastCardDataCount", type = T.SHORT},   --操作牌的玩家个数
        {name = "outCards", fixedLengthParser = "LastCardDataCount",type = T.ARRAY,fixedLength = 3,
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
        {name = "CardData",fixedLengthParser = "CardDataCount", type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "seat_id", type = T.SHORT},   -- 所有玩家的seatid
                {name = "pengcount", type = T.INT},                --碰牌的数量（碰了几次牌）
                {name = "pengList", type = T.ARRAY, fixedLengthParser = "pengcount",fixedLength = 3,
                    fmt = {
                        {name = "cardvalue", type = T.INT},            --牌的值
                    }
                },
                {name = "zhaocount", type = T.INT},                  --招牌的数量（招了几次牌）
                {name = "zhaoList", type = T.ARRAY, fixedLengthParser = "zhaocount",fixedLength = 4,
                    fmt = {
                        {name = "cardvalue", type = T.INT},            --牌的值
                    }
                },
                {name = "fancount", type = T.INT},                --泛牌的数量（泛了几次牌）
                {name = "fanList", type = T.ARRAY, fixedLengthParser = "fancount",fixedLength = 5,
                    fmt = {
                        {name = "cardvalue", type = T.INT},            --牌的值
                    }
                },
				{name = "tong_count", type = T.BYTE},   -- 玩家统的次数
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
P.SVR_ERROR = 0x1005 --登陆错误
SERVER[P.SVR_ERROR] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT} --错误码
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


P.SVR_CHARGE_BROADCAST                 =0x111
SERVER[P.SVR_CHARGE_BROADCAST]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},
        {name="chargeCoins",type=T.INT}
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
             {name = "chargeCoins", type = T.INT}, --玩家输赢倍数
         }
        }
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

P.SVR_PLAYER_CHU_CARD                    = 0x1201                         --玩家出牌
SERVER[P.SVR_PLAYER_CHU_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat_id", type = T.INT},     --玩家座位号
        {name = "CardValue", type = T.INT},   --出牌的数值
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




